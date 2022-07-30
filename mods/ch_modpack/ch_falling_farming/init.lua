
print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local modname = minetest.get_current_modname()

-- FALLING NODES
local falling_nodes = {
	"default:dirt",
	"default:dirt_with_grass",
	"default:dirt_with_dry_grass",
	"default:dirt_with_snow",
	"default:dirt_with_rainforest_litter",
	"default:dirt_with_coniferous_litter",
	"default:dry_dirt",
	"default:default:dry_dirt_with_dry_grass",
	"farming:soil",
	"farming:soil_wet",
	"farming:dry_soil",
	"farming:dry_soil_wet",
}

local def, groups, counter
counter = 0
for _, name in ipairs(falling_nodes) do
	def = minetest.registered_nodes[name]
	if def then
		groups = def.groups
		if groups then
			groups.falling_node = 1
		else
			def.groups = {falling_node = 1}
		end
		counter = counter + 1
	end
end
print("["..modname.."] "..counter.." falling nodes added")

-- WATERING

local bucket_to_empty_bucket = {
	["bucket:bucket_water"] = "bucket:bucket_empty",
	["bucket:bucket_river_water"] = "bucket:bucket_empty",
	["bucket_wooden:bucket_water"] = "bucket_wooden:bucket_empty",
	["bucket_wooden:bucket_river_water"] = "bucket_wooden:bucket_empty",
}

local cans_to_on_use = {
	["technic:water_can"] = 1,
	["technic:river_water_can"] = 1,
}

local function on_use_bucket_water(itemstack, user, pointed_thing)
	local itemstack_name = itemstack:get_name()

	if pointed_thing.type ~= "node" or not itemstack_name or not bucket_to_empty_bucket[itemstack_name] then
		return nil
	end
	local node = minetest.get_node_or_nil(pointed_thing.under)
	local pointed_node_def = node and minetest.registered_nodes[node.name]

	if not pointed_node_def then
		return nil
	end

	-- check protection
	local pos = pointed_thing.under
	if minetest.is_protected(pos, user:get_player_name()) then
		minetest.log("action", user:get_player_name().." tried to water at protected position "
			..minetest.pos_to_string(pos).." with "..itemstack_name)
		minetest.record_protection_violation(pos, user:get_player_name())
		return nil
	end

	local soils = minetest.find_nodes_in_area(
		vector.new(pos.x - 2, pos.y - 4, pos.z - 2),
		vector.new(pos.x + 2, pos.y, pos.z + 2),
		{"group:field"}, true)
	local counter = 0

	for nodename, positions in pairs(soils) do
		local def = minetest.registered_nodes[nodename]
		if def and def.soil and def.soil.dry and def.soil.dry == nodename then
			local wet_soil = {name = def.soil.wet}
			for _, soil_pos in ipairs(positions) do
				local node_above = minetest.get_node_or_nil(vector.new(soil_pos.x, soil_pos.y + 1, soil_pos.z))
				if node_above and (node_above.name == "air" or minetest.get_item_group(node_above.name, "plant") > 0) then
					minetest.swap_node(soil_pos, wet_soil)
					counter = counter + 1
				end
			end
		end
	end
	if counter > 0 then
		minetest.log("action", "Watering: "..counter.." nodes turned into wet soil.")
		return ItemStack(bucket_to_empty_bucket[itemstack_name])
	end
	return itemstack
end
minetest.override_item("bucket:bucket_water", {on_use = on_use_bucket_water})
minetest.override_item("bucket:bucket_river_water", {on_use = on_use_bucket_water})

if minetest.registered_items["bucket_wooden:bucket_water"] then
	minetest.override_item("bucket_wooden:bucket_water", {on_use = on_use_bucket_water})
	minetest.override_item("bucket_wooden:bucket_river_water", {on_use = on_use_bucket_water})
end

if minetest.registered_tools["technic:water_can"] then
	local function empty_on_use(itemstack, user, pointed_thing)
		return itemstack
	end
	for name, _ in pairs(table.copy(cans_to_on_use)) do
		cans_to_on_use[name] = minetest.registered_tools[name].on_use or empty_on_use
	end

	local function on_use_technic_can(itemstack, user, pointed_thing)
		local can_name = itemstack:get_name()
		local on_use_orig = cans_to_on_use[can_name]
		local technic_can_def = minetest.registered_tools[can_name]
		local get_level = technic_can_def and technic_can_def.get_can_level
		local set_level = technic_can_def and technic_can_def.set_can_level

		if not on_use_orig or not technic_can_def or not get_level or not set_level then
			minetest.log("error", "on_use_technic_can(): something is missing: "..(on_use_orig and "true" or "false").." "..(technic_can_def and "true" or "false").." "..(get_level and "true" or "false").." "..(set_level and "true" or "false"))
			return on_use_orig(itemstack, user, pointed_thing)
		end

		local can_level = get_level(itemstack)
		if can_level == 0 then
			return nil -- the can is empty
		end

		if pointed_thing.type == "node" and minetest.get_item_group(minetest.get_node(pointed_thing.under).name, "water") == 0 then
			local result = on_use_bucket_water(ItemStack("bucket:bucket_water"), user, pointed_thing)
			if result then
				if result:get_name() == "bucket:bucket_empty" then
					itemstack = set_level(itemstack, can_level - 1)
				end
				return itemstack
			end
		end
		return on_use_orig(itemstack, user, pointed_thing)
	end

	for name, _ in pairs(cans_to_on_use) do
		minetest.override_item(name, {on_use = on_use_technic_can})
	end
end

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
