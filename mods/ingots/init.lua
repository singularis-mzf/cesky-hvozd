--[[
	Ingots - allows the placemant of ingots in the world
	Copyright (C) 2018  Skamiz Kazzarch
	Copyright (C) 2023, 2024  Singularis

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
]]--

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local IS_BIG = 1000

local S = minetest.get_translator("ingots")

local normal_limit, big_limit = 64, 8

local allow_normal_ingots = minetest.settings:get_bool("ingots_allow_normal_ingots", true)
local allow_big_ingots = minetest.settings:get_bool("ingots_allow_big_ingots", true)
local upgrade_legacy_ingots = minetest.settings:get_bool("upgrade_legacy_ingots", true)

ingots = {
	mod = "redo",
	version = "20240106",
	supported_ingots = {
		-- This table defines the mapping between ingot item and an index 0-63
		-- in the palette ingots_palette.png.
		-- To use big ingots for given ingot item, add IS_BIG constant to the index, example:
		--			["default:steel_ingot"] = 15 + IS_BIG,
		-- To use big ingots for all ingots, all IS_BIG to all indices.
		["default:bronze_ingot"] = 1,
		["default:tin_ingot"] = 2,
		["technic:chromium_ingot"] = 3,
		["technic:cast_iron_ingot"] = 4,
		["default:copper_ingot"] = 5,
		["moreores:mithril_ingot"] = 6,
		["basic_materials:brass_ingot"] = 7,
		["technic:stainless_steel_ingot"] = 8,
		["technic:lead_ingot"] = 9,
		["moreores:silver_ingot"] = 10,
		["technic:carbon_steel_ingot"] = 11,
		["technic:mixed_metal_ingot"] = 12,
		["technic:zinc_ingot"] = 13,
		["default:gold_ingot"] = 14,
		["default:steel_ingot"] = 15,
		["technic:uranium0_ingot"] = 16,
		["aloz:aluminum_ingot"] = 17,
		-- To add support for a new ingot item:
		-- 1. Add optional dependency on the mod that registers the ingot item
		--    to mod.conf of ingots mod.
		-- 2. Add a colored pixel on the empty (non-used) index in
		--    ingots_palette.png palette.
		-- 3. Add a mapping to this table (supported_ingots).
		-- That's it.
	},
}

--[[
local function get_box(i)
	return {type = "fixed", fixed = {
		-0.5, -0.5, -0.5,
		0.5, (((i - 1 - ((i-1)%8)) / 8) - 3) / 8, 0.5
	}}
end
]]

local function ifthenelse(condition, true_result, false_result)
	if condition then
		return true_result
	else
		return false_result
	end
end

local ingot_to_param2 = {}
local param2_to_ingot = {}

for ingot, n in pairs(ingots.supported_ingots) do
	local is_big = n >= IS_BIG
	if is_big then
		if not allow_big_ingots then
			error("Cannot register a big ingot node of "..ingot.." because ingots_allow_big_ingots setting is false!")
		end
	else
		if not allow_normal_ingots then
			error("Cannot register a normal ingot node of "..ingot.." because ingots_allow_normal_ingots setting is false!")
		end
	end
	local param2 = ifthenelse(is_big, n - IS_BIG, n)
	if param2 < 0 or param2 > 64 or param2 ~= math.floor(param2) then
		error("Invalid ingot index: "..n)
	end
	param2 = 4 * param2
	if param2_to_ingot[param2] ~= nil then
		error("Index conflict between "..param2_to_ingot[param2].." and "..ingot.."!")
	end
	param2_to_ingot[param2] = ingot
	param2_to_ingot[param2 + 1] = ingot
	param2_to_ingot[param2 + 2] = ingot
	param2_to_ingot[param2 + 3] = ingot
	ingot_to_param2[ingot] = param2
end

local function get_ingot_info(param2, count, is_big)
	local ingot = param2_to_ingot[param2]
	if ingot == nil then
		return nil
	end
	local ingot_def = minetest.registered_items[ingot]
	if ingot_def == nil then
		return nil
	end
	return {
		param2 = param2,
		param2_base = param2 - param2 % 4,
		count = count or 1,
		description = ingot_def.description or "",
		ingot = ingot,
		is_big = is_big,
		limit = ifthenelse(is_big, big_limit, normal_limit),
	}
end

local function get_ingot_info_from_itemstack(itemstack)
	local ingot = itemstack:get_name()
	if itemstack:is_empty() or ingot == nil or ingot == "" or ingot_to_param2[ingot] == nil then
		return nil
	end
	local param2 = ingot_to_param2[ingot]
	return get_ingot_info(param2, itemstack:get_count(), ingots.supported_ingots[ingot] >= IS_BIG)
end

local function get_ingot_info_from_node(node)
	if node == nil then
		return nil
	end
	local count = minetest.get_item_group(node.name, "ingots")
	if count == 0 then
		return nil
	end
	return get_ingot_info(node.param2, count, minetest.get_item_group(node.name, "ingots_big") ~= 0)
end

local function get_node_name(ingots, count)
	local prefix = ifthenelse(ingots.is_big, "ingots:ingots_big_", "ingots:ingots_v2_")
	if count == nil then
		count = ingots.count
	end
	if count > ingots.limit then
		error("Can't place "..count.." ingots, limits is "..ingots.limit.."! DUMP: "..dump2(ingots))
	end
	return prefix..count
end

local function set_node_and_description(pos, new_node, new_description)
	if new_node ~= nil then
		minetest.set_node(pos, new_node)
		if new_description ~= nil then
			minetest.get_meta(pos):set_string("infotext", new_description)
		end
	else
		minetest.remove_node(pos)
	end
end

local function on_place_ingot(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" then
		return
	end

	local pos, pos_above = pointed_thing.under, pointed_thing.above
	local node = minetest.get_node_or_nil(pos)
	if node == nil then
		minetest.log("warning", "Placing ingot failed: Unexpected nil at "..minetest.pos_to_string(pos).."!")
		return
	end
	-- call on_rightclick function of pointed node if aplicable and not sneak
	-- might or might not break if item is placed by mod devices
	local on_rightclick = minetest.registered_nodes[node.name].on_rightclick
	local sneak = placer:get_player_control().sneak
	if on_rightclick and not sneak then
		on_rightclick(pos, node, placer, itemstack)
		return
	end

	local ingots_to_place = get_ingot_info_from_itemstack(itemstack)
	if ingots_to_place == nil then
		return
	end

	-- check protection
	local player_name = placer:get_player_name()
	if minetest.is_protected(pos_above, player_name) and not minetest.check_player_privs(placer, "protection_bypass") then
		minetest.record_protection_violation(pos_above, player_name)
		return
	end
	local is_creative = minetest.is_creative_enabled(player_name)

	local count_to_place = 1
	if sneak then
		count_to_place = math.min(ingots_to_place.count, 10)
	end
	local placed_ingots = get_ingot_info_from_node(node)
	if placed_ingots ~= nil and placed_ingots.param2_base == ingots_to_place.param2_base and placed_ingots.count < placed_ingots.limit then
		-- add ingots to the current node
		count_to_place = math.min(count_to_place, placed_ingots.limit - placed_ingots.count)
		local new_count = placed_ingots.count + count_to_place
		node.name = get_node_name(placed_ingots, new_count)
		set_node_and_description(pos, node, placed_ingots.description.." ("..new_count..")")
		if not minetest.is_creative_enabled(player_name) then
			itemstack:take_item(count_to_place)
		end
		return itemstack
	end
	local node_above = minetest.get_node(pos_above)
	if node_above == "air" or (minetest.registered_nodes[node_above.name] or {}).buildable_to then
		-- place a new node
		count_to_place = math.min(count_to_place, ingots_to_place.limit)
		local direction = math.floor(7.0 - (placer:get_look_horizontal() / math.pi * 2.0 + 0.5)) % 4
		local new_node = {
			name = get_node_name(ingots_to_place, count_to_place),
			param = node_above.param or 0,
			param2 = ingots_to_place.param2_base + direction,
		}
		set_node_and_description(pos_above, new_node, ingots_to_place.description.." ("..count_to_place..")")
		if not minetest.is_creative_enabled(player_name) then
			itemstack:take_item(count_to_place)
		end
		return itemstack
	end
	-- else: no place for a new ingot
end

local function on_punch_ingot(pos, node, puncher, pointed_thing)
	local current_ingots = get_ingot_info_from_node(node)
	local wielded_item = puncher:get_wielded_item()
	local wielded_ingots = get_ingot_info_from_itemstack(wielded_item)

	if current_ingots == nil then
		return -- no ingots to punch
	end
	if not wielded_item:is_empty() and (wielded_ingots == nil or wielded_ingots.param2_base ~= current_ingots.param2_base) then
		return -- a stack can be taken appart only by hand or relevant ingot_item
	end

	-- check protection
	local player_name = puncher:get_player_name()
	if minetest.is_protected(pos, player_name) and not minetest.check_player_privs(puncher, "protection_bypass") then
		minetest.record_protection_violation(pos, player_name)
		return
	end
	local sneak = puncher:get_player_control().sneak

	local count_to_take = ifthenelse(sneak, 10, 1)
	local new_description
	if current_ingots.count > count_to_take then
		new_description = current_ingots.description .." ("..(current_ingots.count - count_to_take)..")"
		node.name = get_node_name(current_ingots, current_ingots.count - count_to_take)
	else
		-- take all ingots:
		count_to_take = current_ingots.count
		node = nil
	end

	local stack = ItemStack(current_ingots.ingot.." "..count_to_take)
	if wielded_item:item_fits(stack) then
		-- add ingot the the wielded item
		set_node_and_description(pos, node, new_description)
		wielded_item:add_item(stack)
		if not minetest.is_creative_enabled(player_name) or wielded_item:get_count() == count_to_take then
			puncher:set_wielded_item(wielded_item)
		end
	else
		local inv = puncher:get_inventory()
		if inv:room_for_item("main", stack) then
			-- add ingot to the main inventory
			set_node_and_description(pos, node, new_description)
			if not minetest.is_creative_enabled(player_name) or not inv:contains_item("main", stack) then
				inv:add_item("main", stack)
			end
		end
	end
end

local function preserve_metadata(pos, oldnode, oldmeta, drops)
	local ingot_info = get_ingot_info_from_node(oldnode)
	if ingot_info ~= nil then
		drops[1] = ItemStack(ingot_info.ingot.." "..ingot_info.count)
	end
end

local sounds, tiles
if minetest.get_modpath("default") then
	sounds = default.node_sound_metal_defaults()
end

-- Register normal ingots (64 per node):

if allow_normal_ingots then
	tiles = {{name = "ingot_normal.png", backface_culling = true}}
	for count = 1, 64 do
		local box, def, description
		box = {
			type = "fixed",
			fixed = {
				-0.5, -0.5, -0.5,
				0.5, (((count - 1 - ((count-1)%8)) / 8) - 3) / 8, 0.5
			}
		}
		if count == 1 then
			description = S("@1 ingot", "1")
		elseif count < 5 then
			description = S("@1 ingots", tostring(count))
		else
			description = S("@1 ingots!", tostring(count))
		end
		def = {
			description = description,
			drawtype = "mesh",
			tiles = tiles,
			mesh = "ingot_"..count..".obj",
			selection_box = box,
			collision_box = box,
			paramtype = "light",
			paramtype2 = "color4dir",
			palette = "ingots_palette.png",
			is_ground_content = false,
			groups = {cracky = 3, level = 2, ingots = count, not_in_creative_inventory = 1},
			on_punch = on_punch_ingot,
			preserve_metadata = preserve_metadata,
		}
		if minetest.registered_items["technic:mixed_metal_ingot"] then
			def.drop = "technic:mixed_metal_ingot "..count
		elseif minetest.registered_items["default:steel_ingot"] then
			def.drop = "default:steel_ingot "..count
		else
			def.drop = ""
		end
		if sounds ~= nil then
			def.sounds = sounds
		end
		minetest.register_node("ingots:ingots_v2_"..count, def)
	end
end

-- Register big ingots (8 per node):
if allow_big_ingots then
	tiles = {{name = "ingot_normal.png", backface_culling = true}}
	for count = 1, 8 do
		local box, def, description
		box = {
			type = "fixed",
			fixed = {
				-0.5, -0.5, -0.5,
				0.5, (((count + 1 - ((count + 1) % 2)) / 8) - 0.5), 0.5
			}
		}
		if count == 1 then
			description = S("@1 ingot", "1")
		elseif count < 5 then
			description = S("@1 ingots", tostring(count))
		else
			description = S("@1 ingots!", tostring(count))
		end
		def = {
			description = description,
			drawtype = "mesh",
			tiles = tiles,
			mesh = "ingot_big_"..count..".obj",
			selection_box = box,
			collision_box = box,
			paramtype = "light",
			paramtype2 = "color4dir",
			palette = "ingots_palette.png",
			is_ground_content = false,
			groups = {cracky = 3, level = 2, ingots = count, ingots_big = count, not_in_creative_inventory = 1},
			on_punch = on_punch_ingot,
			preserve_metadata = preserve_metadata,
		}
		if minetest.registered_items["technic:mixed_metal_ingot"] then
			def.drop = "technic:mixed_metal_ingot "..count
		elseif minetest.registered_items["default:steel_ingot"] then
			def.drop = "default:steel_ingot "..count
		else
			def.drop = ""
		end
		if sounds ~= nil then
			def.sounds = sounds
		end
		minetest.register_node("ingots:ingots_big_"..count, def)
	end
end

-- Override ingots:
local override = {
	on_place = on_place_ingot,
}
for ingot, n in pairs(ingots.supported_ingots) do
	local idef = minetest.registered_items[ingot]
	if idef ~= nil then
		minetest.override_item(ingot, override)
	end
end

-- LBM to upgrade (CH variant):
local nodenames = {
	"ingots:ingots_1",
	"ingots:ingots_2",
	"ingots:ingots_3",
	"ingots:ingots_4",
	"ingots:ingots_5",
	"ingots:ingots_6",
	"ingots:ingots_7",
	"ingots:ingots_8",
	"ingots:ingots_9",
	"ingots:ingots_10",
	"ingots:ingots_11",
	"ingots:ingots_12",
	"ingots:ingots_13",
	"ingots:ingots_14",
	"ingots:ingots_15",
	"ingots:ingots_16",
	"ingots:ingots_17",
	"ingots:ingots_18",
	"ingots:ingots_19",
	"ingots:ingots_20",
	"ingots:ingots_21",
	"ingots:ingots_22",
	"ingots:ingots_23",
	"ingots:ingots_24",
	"ingots:ingots_25",
	"ingots:ingots_26",
	"ingots:ingots_27",
	"ingots:ingots_28",
	"ingots:ingots_29",
	"ingots:ingots_30",
	"ingots:ingots_31",
	"ingots:ingots_32",
	"ingots:ingots_33",
	"ingots:ingots_34",
	"ingots:ingots_35",
	"ingots:ingots_36",
	"ingots:ingots_37",
	"ingots:ingots_38",
	"ingots:ingots_39",
	"ingots:ingots_40",
	"ingots:ingots_41",
	"ingots:ingots_42",
	"ingots:ingots_43",
	"ingots:ingots_44",
	"ingots:ingots_45",
	"ingots:ingots_46",
	"ingots:ingots_47",
	"ingots:ingots_48",
	"ingots:ingots_49",
	"ingots:ingots_50",
	"ingots:ingots_51",
	"ingots:ingots_52",
	"ingots:ingots_53",
	"ingots:ingots_54",
	"ingots:ingots_55",
	"ingots:ingots_56",
	"ingots:ingots_57",
	"ingots:ingots_58",
	"ingots:ingots_59",
	"ingots:ingots_60",
	"ingots:ingots_61",
	"ingots:ingots_62",
	"ingots:ingots_63",
	"ingots:ingots_64",
}
local old_param2_to_ingot = {
	-- 0 = unused
	"default:bronze_ingot", -- 1
	"default:tin_ingot", -- 2
	"technic:chromium_ingot", -- 3
	"technic:cast_iron_ingot", -- 4
	"default:copper_ingot", -- 5
	"moreores:mithril_ingot", -- 6
	"basic_materials:brass_ingot", -- 7
	"technic:stainless_steel_ingot", -- 8
	"technic:lead_ingot", -- 9
	"moreores:silver_ingot", -- 10
	"technic:carbon_steel_ingot", -- 11
	"technic:mixed_metal_ingot", -- 12
	"technic:zinc_ingot", -- 13
	"default:gold_ingot", -- 14
	"default:steel_ingot", -- 15
	"technic:uranium0_ingot", -- 16
	"aloz:aluminum_ingot", -- 17
}

local function lbm_func(pos, node, dtime_s)
	local count = tonumber(node.name:sub(15, -1))
	if count == nil then
		minetest.log("error", "[ingots] Internal error during node upgrade of "..node.name.."/"..node.param2.." at "..minetest.pos_to_string(pos)..": count not recognized from node name!")
		return
	end
	local old_ingot = old_param2_to_ingot[node.param2]
	if old_ingot == nil then
		minetest.log("warning", "[ingots] Node upgrade of "..node.name.."/"..node.param2.." at "..minetest.pos_to_string(pos).." did not recognize the ingot from param2. Will continue with default:steel_ingot.")
		old_ingot = "default:steel_ingot"
	end
	local new_param2 = ingot_to_param2[old_ingot]
	if new_param2 == nil then
		minetest.log("error", "[ingots] Node upgrade of "..node.name.."/"..node.param2.." at "..minetest.pos_to_string(pos).." failed: placing of "..old_ingot.." not supported!")
		return
	end
	local is_big = ingots.supported_ingots[old_ingot] >= IS_BIG
	local limit = ifthenelse(is_big, big_limit, normal_limit)
	if count > limit then
		minetest.log("warning", "[ingots] Node upgrade of "..node.name.."/"..node.param2.." at "..minetest.pos_to_string(pos)..": the count of ingots per node "..count.." will be forcibly decreased to the limit "..limit..". This will cause a loss of ingots!")
		count = limit
	end
	local ingot_info = get_ingot_info(new_param2, count, is_big)
	local new_node = {
		name = get_node_name(ingot_info),
		param = node.param,
		param2 = new_param2,
	}
	minetest.swap_node(pos, new_node)
	minetest.log("action", "[ingots] Node at "..minetest.pos_to_string(pos).." upgraded from "..node.name.."/"..node.param2.." to "..new_node.name.."/"..new_node.param2..".")
end

minetest.register_lbm({
	label = "Upgrade ingots (Cesky hvozd)",
	name = "ingots:upgrade_ingots_ch",
	nodenames = nodenames,
	run_at_every_load = false,
	action = lbm_func,
})

if upgrade_legacy_ingots then
	-- LBM to upgrade (old ingots variant):
	local old_infix_to_ignot = {
		bronze = "default:bronze_ingot",
		tin = "default:tin_ingot",
		chromium = "technic:chromium_ingot",
		cast_iron = "technic:cast_iron_ingot",
		copper = "default:copper_ingot",
		mithril = "moreores:mithril_ingot",
		brass = "basic_materials:brass_ingot",
		stainless_steel = "technic:stainless_steel_ingot",
		lead = "technic:lead_ingot",
		silver = "moreores:silver_ingot",
		carbon_steel = "technic:carbon_steel_ingot",
		mixed_metal = "technic:mixed_metal_ingot",
		zinc = "technic:zinc_ingot",
		gold = "default:gold_ingot",
		steel = "default:steel_ingot",
	}

	nodenames = {}
	for infix, ingot in pairs(old_infix_to_ignot) do
		for i = 1, 64 do
			table.insert(nodenames, "ingots:"..infix.."_ingot_"..i)
		end
		for i = 1, 8 do
			table.insert(nodenames, "ingots:"..infix.."_big_ingot_"..i)
		end
	end

	lbm_func = function(pos, node, dtime_s)
		local metal, count
		for m, c in node.name:gmatch("ingots:(.*)_ingot_([^_]+)") do
			metal, count = m, tonumber(c)
		end
		for m, c in node.name:gmatch("ingots:(.*)_ingot_big_([^_]+)") do
			metal, count = m, tonumber(c)
		end
		local ingot = old_infix_to_ignot[metal or ""]
		if ingot == nil or count == nil then
			minetest.log("error", "[ingots] Node upgrade of "..node.name.."/"..node.param2.." at "..minetest.pos_to_string(pos).." failed: ingot or count not recognized!")
			return
		end
		local new_param2 = ingot_to_param2[ingot]
		if new_param2 == nil then
			minetest.log("error", "[ingots] Node upgrade of "..node.name.."/"..node.param2.." at "..minetest.pos_to_string(pos).." failed: placing of "..ingot.." not supported!")
			return
		end
		local is_big = ingots.supported_ingots[ingot] >= IS_BIG
		local limit = ifthenelse(is_big, big_limit, normal_limit)
		if count > limit then
			minetest.log("warning", "[ingots] Node upgrade of "..node.name.."/"..node.param2.." at "..minetest.pos_to_string(pos)..": the count of ingots per node "..count.." will be forcibly decreased to the limit "..limit..". This will cause a loss of ingots!")
			count = limit
		end
		local ingot_info = get_ingot_info(new_param2, count, is_big)
		local new_node = {
			name = get_node_name(ingot_info),
			param = node.param,
			param2 = new_param2,
		}
		set_node_and_description(pos, new_node, ingot_info.description.." ("..count..")")
		minetest.log("action", "[ingots] Node at "..minetest.pos_to_string(pos).." upgraded from "..node.name.."/"..node.param2.." to "..new_node.name.."/"..new_node.param2..".")
	end

	minetest.register_lbm({
		label = "Upgrade legacy ingots",
		name = "ingots:upgrade_ingots_legacy",
		nodenames = nodenames,
		run_at_every_load = false,
		action = lbm_func,
	})
end

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
