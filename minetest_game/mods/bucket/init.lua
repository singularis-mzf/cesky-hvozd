-- Minetest 0.4 mod: bucket
-- See README.txt for licensing and other information.

-- Load support for MT game translation.
local S = minetest.get_translator("bucket")

bucket = {
	-- empty_buckets = {
	--   ["empty_bucket_item"] = {
	--     node = {name = "empty_bucket_node", param2 = ...}, -- optional
	--     full_bucket_<liquid_source> = "full_bucket_item", -- optional
	--   }
	-- }
	empty_buckets = {}, -- item_name => node_name or ""

	-- full_buckets = {
	--   ["full_bucket_item"] = {
	--     node = {name = "full_bucket_node", param2 = ...}, -- optional
	--     liquid = "liquid_source", -- optional,
	--     empty_bucket = "empty_bucket_item", -- required
	--     force_renew = ..., -- optional
	--   }
	-- }
	-- NOTE: empty bucket item name is embedded as ["empty_bucket"] to the defintion of the full bucket
	full_buckets = {},

	-- liquids = { -- legacy table, not read
	--    ["liquid_source"] = {
	--        source = ...,
	--        flowing = ...,
	--        itemname = ...,
	--        force_renew = ...,
	--    }
	-- }
	liquids = {},
}

local function check_protection(pos, name, text)
	if minetest.is_protected(pos, name) then
		minetest.log("action", (name ~= "" and name or "A mod")
			.. " tried to " .. text
			.. " at protected position "
			.. minetest.pos_to_string(pos)
			.. " with a bucket")
		minetest.record_protection_violation(pos, name)
		return true
	end
	return false
end

local function strip_prefix_colon(s)
	if string.len(s) > 0 and s:sub(1, 1) == ":" then
		return s:sub(2, -1)
	else
		return s
	end
end

local function empty_bucket_on_use(itemstack, user, pointed_thing)
	if pointed_thing.type == "object" then
		pointed_thing.ref:punch(user, 1.0, {full_punch_interval = 1.0}, nil)
		return user:get_wielded_item()
	elseif pointed_thing.type ~= "node" then
		return
	end

	-- Check if pointing to a liquid source supported by the bucket
	local empty_bucket  = itemstack:get_name()
	local empty_bucket_def = bucket.empty_buckets[empty_bucket]
	local node = minetest.get_node(pointed_thing.under)
	local item_count = itemstack:get_count()
	local full_bucket = empty_bucket_def and empty_bucket_def["full_bucket_"..node.name]

	-- print("DEBUG: empty bucket on use: empty_bucket="..empty_bucket..", empty_bucket_def="..type(empty_bucket_def)..", node under="..node.name..", item_count = "..item_count..", full_bucket="..(full_bucket or "nil"))

	if not full_bucket then
		-- non-supported nodes will have their on_punch triggered
		local node_def = minetest.registered_nodes[node.name]
		if node_def then
			return node_def.on_punch(pointed_thing.under, node, user, pointed_thing)
		end
	end
	if check_protection(pointed_thing.under, user:get_player_name(), "take "..node.name) then return end

	local full_bucket_def = bucket.full_buckets[full_bucket]
	if not full_bucket_def then
		error("Internal error: full bucket "..full_bucket.." required by empty bucket "..empty_bucket.." and liquid source "..node.name.." is not registered!")
	end

	local giving_back = full_bucket
	-- check if holding more than 1 empty bucket
	if item_count > 1 then
		-- if space in inventory add filled bucked, otherwise drop as item
		local inv = user:get_inventory()
		if inv:room_for_item("main", {name = full_bucket}) then
			inv:add_item("main", full_bucket)
		else
			local pos = user:get_pos()
			pos.y = math.floor(pos. y + 0.5)
			minetest.add_item(pos, full_bucket)
		end

		-- set to return empty buckets minus 1
		giving_back = empty_bucket.." "..tostring(item_count - 1)
	end
	-- force_renew requires a source neighbour
	if not full_bucket_def.force_renew or not minetest.find_node_near(pointed_thing.under, 1, node.name) then
		minetest.remove_node(pointed_thing.under)
	end
	return ItemStack(giving_back)
end

-- Area watering
local function water_bucket_on_use(itemstack, user, pointed_thing)
	if pointed_thing.type ~= "node" then return nil end

	local orig_pos = pointed_thing.under
	local orig_node = minetest.get_node(orig_pos)
	local orig_ndef = minetest.registered_nodes[orig_node.name]

	-- activate on_punch on the punched node
	if orig_ndef and orig_ndef.on_punch then
		local on_punch_result = orig_ndef.on_punch(orig_pos, orig_node, user, pointed_thing)
		if on_punch_result ~= nil then
			return on_punch_result
		end
	end

	local bucket_name = itemstack:get_name()
	local full_bucket = bucket.full_buckets[bucket_name]
	if not full_bucket then
		return nil
	end
	local water_remains_original = 8
	local water_remains = bucket.water_land(orig_pos, water_remains_original)
	if water_remains < water_remains_original and full_bucket.empty_bucket then
		return ItemStack(full_bucket.empty_bucket)
	else
		return nil -- nothing watered
	end
end

local function bucket_on_place(itemstack, user, pointed_thing)
	if pointed_thing.type ~= "node" then return end
	local node = minetest.get_node_or_nil(pointed_thing.under)
	local ndef = node and minetest.registered_nodes[node.name]
	local controls = (user:is_player() and user:get_player_control()) or {}

	-- Call on_rightclick if the pointed node defines it
	if not controls.sneak and ndef and ndef.on_rightclick then
		return ndef.on_rightclick(pointed_thing.under, node, user, itemstack)
	end

	local lpos
	if ndef and ndef.buildable_to then
		-- buildable; replace the node
		lpos = pointed_thing.under
	else
		-- not buildable to; place the liquid above
		-- check if the node above can be replaced
		lpos = pointed_thing.above
		node = minetest.get_node_or_nil(lpos)
		local above_ndef = node and minetest.registered_nodes[node.name]
		if above_ndef and not above_ndef.buildable_to then
			-- do not remove the bucket with the liquid
			return itemstack
		end
	end

	local bucket_name = itemstack:get_name()
	local bucket_def = bucket.empty_buckets[bucket_name] or bucket.full_buckets[bucket_name]
	if not bucket_def then
		-- bucket not known => do nothing
		return itemstack
	end

	if controls.aux1 then
		-- place a liquid source
		node = bucket_def.liquid
		if not node or check_protection(lpos, user and user:get_player_name() or "", "place "..node) then
			return
		end
		minetest.set_node(lpos, {name = node, param2 = 2})
		return ItemStack(bucket_def.empty_bucket)
	else
		-- place a bucket node (if available)
		node = bucket_def.node
		if not node then
			-- a bucket with no node => do nothing
			return itemstack
		end
		if check_protection(lpos, user and user:get_player_name() or "", "place "..node.name) then
			return
		end
		minetest.set_node(lpos, node)
		itemstack:take_item(1)
		return itemstack
	end
end

function bucket.register_empty_bucket(name, def)
	if not def.description or not def.inventory_image then
		error("")
	end

	-- register item
	local long_name = name
	name = strip_prefix_colon(name)
	local base_groups = def.groups or {}
	local groups = table.copy(base_groups)
	groups.bucket = 1
	groups.bucket_empty = 1
	groups.tool = 1
	local ndef = {
		description = def.description,
		inventory_image = def.inventory_image,
		groups = groups,
		liquids_pointable = true,
		on_use = def.on_use or empty_bucket_on_use,
		on_place = def.on_place or bucket_on_place,
	}
	minetest.register_craftitem(long_name, ndef)
	bucket.empty_buckets[name] = {}

	local node_name = def.node_name or ""
	if node_name ~= "" then
		groups = table.copy(base_groups)
		groups.bucket = 1
		groups.bucket_empty = 1
		groups.dig_immediate = 2
		groups.attached_node = 1
		groups.not_in_creative_inventory = 1
		ndef = {
			description = def.description,
			drawtype = "plantlike",
			tiles = def.tiles or {def.inventory_image},
			use_texture_alpha = def.use_texture_alpha or "clip",
			paramtype = "light",
			paramtype2 = "meshoptions",
			place_paramtype2 = 2,
			is_ground_content = false,
			sunlight_propagates = true,
			walkable = false,
			groups = groups,
			sounds = def.sounds or default.node_sound_stone_defaults(),
			drop = name,
		}
		minetest.register_node(node_name, ndef)
		bucket.empty_buckets[name].node = {name = strip_prefix_colon(node_name), param2 = 2}
	end
end

function bucket.register_full_bucket(name, empty_bucket, liquid_source, def)
	local empty_bucket_info = bucket.empty_buckets[empty_bucket]
	if not empty_bucket_info then
		error("bucket.register_full_bucket(): non-registered empty bucket "..empty_bucket.." referenced!")
	end
	local long_name = name
	name = strip_prefix_colon(name)
	if bucket.full_buckets[name] then
		error("bucket "..name.." already registered!")
	end
	if liquid_source and liquid_source == "" then
		liquid_source = nil
	end

	local base_groups = def.groups or {}
	local groups = table.copy(base_groups)
	groups.bucket = 1
	groups.bucket_full = 1
	groups.tool = 1
	local on_use = def.on_use
	if not on_use then
		if groups.water_bucket then
			on_use = water_bucket_on_use
		else
			on_use = nil
		end
	end

	local ndef = {
		description = def.description,
		inventory_image = def.inventory_image,
		stack_max = def.stack_max or 1,
		liquids_pointable = true,
		groups = groups,
		on_use = on_use,
		on_place = def.on_place or bucket_on_place,
	}
	minetest.register_craftitem(long_name, ndef)
	bucket.full_buckets[name] = {
		force_renew = def.force_renew,
		empty_bucket = empty_bucket,
		liquid = liquid_source,
	}
	if liquid_source then
		empty_bucket_info["full_bucket_"..liquid_source] = name

		-- legacy:
		if not bucket.liquids[liquid_source] then
			bucket.liquids[liquid_source] = {
				source = liquid_source,
				flowing = def.flowing,
				itemname = name,
				force_renew = def.force_renew,
			}
			bucket.liquids[def.flowing] = bucket.liquids[liquid_source]
		end
	end

	-- define a node
	local node_name = def.node_name or ""
	if node_name ~= "" then
		groups = table.copy(base_groups)
		groups.bucket = 1
		groups.bucket_full = 1
		groups.dig_immediate = 2
		groups.attached_node = 1
		groups.not_in_creative_inventory = 1
		ndef = {
			description = def.description,
			drawtype = "plantlike",
			tiles = def.tiles or {def.inventory_image},
			use_texture_alpha = def.use_texture_alpha or "clip",
			paramtype = "light",
			paramtype2 = "meshoptions",
			place_param2 = 2,
			is_ground_content = false,
			sunlight_propagates = true,
			walkable = false,
			groups = groups,
			sounds = def.sounds or default.node_sound_stone_defaults(),
			drop = name,
		}
		minetest.register_node(node_name, ndef)
		bucket.full_buckets[name].node = {name = strip_prefix_colon(node_name), param2 = 2}
	end
end

-- Register a new liquid (legacy function, use register_full_bucket instead)
--    source = name of the source node
--    flowing = name of the flowing node
--    itemname = name of the new bucket item (or nil if liquid is not takeable)
--    inventory_image = texture of the new bucket item (ignored if itemname == nil)
--    name = text description of the bucket item
--    groups = (optional) groups of the bucket item, for example {water_bucket = 1}
--    force_renew = (optional) bool. Force the liquid source to renew if it has a
--                  source neighbour, even if defined as 'liquid_renewable = false'.
--                  Needed to avoid creating holes in sloping rivers.
-- This function can be called from any mod (that depends on bucket).
function bucket.register_liquid(source, flowing, itemname, inventory_image, name, groups, force_renew)
	if not itemname then
		-- a liquid with no bucket
		local def = {
			source = source,
			flowing = flowing,
			itemname = itemname,
			force_renew = force_renew
		}
		bucket.liquids[source] = def
		bucket.liquids[flowing] = def
		return
	end
	bucket.register_full_bucket(itemname, "bucket:bucket_empty", source, {
		description = name,
		flowing = flowing,
		inventory_image = inventory_image,
		groups = groups,
		force_renew = force_renew,
		node_name = itemname.."_placed",
	})
end

-- If itemstack is a stack of empty buckets and they support the specified
-- liquid source, this function will take one of them from the stack
-- and returns a new item stack consisting of the one full bucket.
-- Otherwise the function does not change itemstack and returns nil.
function bucket.fill_bucket(itemstack, liquid_source_name)
	local bucket_name = itemstack:get_name()
	local empty_def = bucket.empty_buckets[bucket_name]
	local result = empty_def and empty_def["full_bucket_"..liquid_source_name]
	if result then
		itemstack:take_item(1)
		return ItemStack(result)
	else
		return nil
	end
end

-- If itemstack is a stack of one full bucket, the function will return
-- a new itemstack with an empty bucket and a name of liquid source node
-- (if available - may be nil). Otherwise the function returns nil.
-- Original itemstack will be unchanged.
function bucket.spill_bucket(itemstack)
	local full_def = bucket.full_buckets[itemstack:get_name()]
	if full_def then
		return ItemStack(full_def.empty_bucket), full_def.liquid
	else
		return nil, nil
	end
end

-- Do area watering and returns max_nodes - number_of_watered_nodes.
function bucket.water_land(pos, max_nodes)
	if max_nodes <= 0 then
		return max_nodes
	end
	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	if not ndef or not ndef.walkable then
		pos = vector.new(pos.x, pos. y - 1, pos.z)
	elseif not vector.check(pos) then
		pos = vector.new(pos.x, pos.y, pos.z)
	end

	local waterable_nodes = minetest.find_nodes_in_area(vector.offset(pos, -2, -1, -2), vector.offset(pos, 2, 0, 2), "group:waterable", true)
	for node_name, positions in pairs(waterable_nodes) do
		local on_watered = minetest.registered_nodes[node_name]
		on_watered = on_watered and on_watered.on_watered
		if on_watered then
			for _, wpos in ipairs(positions) do
				minetest.log("info", "on_watered() will be called on position "..minetest.pos_to_string(wpos))
				on_watered(wpos)
				max_nodes = max_nodes - 1
				if max_nodes <= 0 then return 0 end
			end
		end
	end
	return max_nodes
end

bucket.register_empty_bucket("bucket:bucket_empty", {
	description = S("Empty Bucket"),
	inventory_image = "bucket.png",
	node_name = "bucket:bucket_empty_placed",
})

bucket.register_full_bucket("bucket:bucket_water", "bucket:bucket_empty", "default:water_source", {
	description = S("Water Bucket"),
	flowing = "default:water_flowing",
	inventory_image = "bucket_water.png",
	groups = {water_bucket = 1},
	node_name = "bucket:bucket_water_placed",
})

-- River water source is 'liquid_renewable = false' to avoid horizontal spread
-- of water sources in sloping rivers that can cause water to overflow
-- riverbanks and cause floods.
-- River water source is instead made renewable by the 'force renew' option
-- used here.

bucket.register_full_bucket("bucket:bucket_river_water", "bucket:bucket_empty", "default:river_water_source", {
	description = S("River Water Bucket"),
	flowing = "default:river_water_flowing",
	inventory_image = "bucket_river_water.png",
	groups = {water_bucket = 1},
	node_name = "bucket:bucket_river_water_placed",
	force_renew = true,
})

bucket.register_full_bucket("bucket:bucket_lava", "bucket:bucket_empty", "default:lava_source", {
	description = S("Lava Bucket"),
	flowing = "default:lava_flowing",
	inventory_image = "bucket_lava.png",
	node_name = "bucket:bucket_lava_placed",
	groups = {lava_bucket = 1},
})

-- ALIASES
minetest.register_alias("bucket", "bucket:bucket_empty")
minetest.register_alias("bucket_water", "bucket:bucket_water")
minetest.register_alias("bucket_lava", "bucket:bucket_lava")

-- CRAFTS:
minetest.register_craft({
	output = "bucket:bucket_empty 1",
	recipe = {
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"", "default:steel_ingot", ""},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "bucket:bucket_lava",
	burntime = 60,
	replacements = {{"bucket:bucket_lava", "bucket:bucket_empty"}},
})

--[[ Register buckets as dungeon loot
if minetest.global_exists("dungeon_loot") then
	dungeon_loot.register({
		{name = "bucket:bucket_empty", chance = 0.55},
		-- water in deserts/ice or above ground, lava otherwise
		{name = "bucket:bucket_water", chance = 0.45,
			types = {"sandstone", "desert", "ice"}},
		{name = "bucket:bucket_water", chance = 0.45, y = {0, 32768},
			types = {"normal"}},
		{name = "bucket:bucket_lava", chance = 0.45, y = {-32768, -1},
			types = {"normal"}},
	})
end
]]
