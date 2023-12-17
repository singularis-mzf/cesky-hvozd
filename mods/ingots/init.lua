--[[
	Ingots - allows the placemant of ingots in the world
	Copyright (C) 2018  Skamiz Kazzarch
	Copyright (C) 2023  Singularis

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

ingots = {
	mod = "redo",
	version = "20231217",
	supported_ingots = {},
}

--[[
local function get_box(i)
	return {type = "fixed", fixed = {
		-0.5, -0.5, -0.5,
		0.5, (((i - 1 - ((i-1)%8)) / 8) - 3) / 8, 0.5
	}}
end
]]

local color_to_ingot = {
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
}

local ingot_to_color = table.key_value_swap(color_to_ingot)

local function get_ingot_info(color)
	if color == 0 then
		return nil
	end
	local item = color_to_ingot[color]
	if item == nil then
		return nil
	end
	local item_def = minetest.registered_items[item]
	if item_def == nil then
		return nil
	end
	return {
		color = color,
		count = 1,
		description = item_def.description or "",
		item = item,
	}
end

local function get_info_from_itemstack(itemstack)
	if itemstack:get_count() == 0 then
		return nil
	end
	local item = itemstack:get_name()
	if item == nil or item == "" or not minetest.registered_items[item] then
		return nil
	end
	local color = ingot_to_color[item]
	if color == nil then
		return nil
	end
	local result = get_ingot_info(color)
	result.count = itemstack:get_count()
	return result
end

local function get_info_from_node(node)
	if node == nil then
		return nil
	end
	local count = minetest.get_item_group(node.name, "ingots")
	if count == 0 then
		return nil
	end
	local result = get_ingot_info(node.param2)
	if result ~= nil then
		result.count = count
	end
	return result
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

	local pos = pointed_thing.under
	local pos_above = pointed_thing.above
	local node = minetest.get_node_or_nil(pos)
	if node == nil then
		minetest.log("warning", "Unexpected nil at "..minetest.pos_to_string(pos).."!")
		return
	end
	-- call on_rightclick function of pointed node if aplicable and not sneak
	-- might or might not break if item is placed by mod devices
	local on_rightclick = minetest.registered_nodes[node.name].on_rightclick
	local sneak = placer:get_player_control().sneak
	if on_rightclick and not sneak then
		on_rightclick(pointed_thing.under, table.copy(node), placer, itemstack)
		return
	end

	local placed_ingot = get_info_from_itemstack(itemstack)
	if placed_ingot == nil then
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
		count_to_place = math.min(placed_ingot.count, 10)
	end
	local current_ingot = get_info_from_node(node)
	if current_ingot ~= nil and current_ingot.color == placed_ingot.color and current_ingot.count < 64 then
		-- add to the current ingot
		count_to_place = math.min(count_to_place, 64 - current_ingot.count)
		node.name = "ingots:ingots_"..(current_ingot.count + count_to_place)
		set_node_and_description(pos, node, placed_ingot.description .." ("..(current_ingot.count + count_to_place)..")")
		if not is_creative then
			itemstack:take_item(count_to_place)
		end
		return itemstack
	end
	local node_above = minetest.get_node(pos_above)
	if node_above.name == "air" or (minetest.registered_nodes[node_above.name] or {}).buildable_to then
		set_node_and_description(pos_above, {name = "ingots:ingots_"..count_to_place, param = node.param, param2 = placed_ingot.color}, placed_ingot.description.." ("..count_to_place..")")
		if not is_creative then
			itemstack:take_item(count_to_place)
		end
		return itemstack
	end
	-- no place for a new ingot
end

local function on_punch_ingot(pos, node, puncher, pointed_thing)
	local current_ingot = get_info_from_node(node)
	local wielded_item = puncher:get_wielded_item()
	local wielded_ingot = get_info_from_itemstack(wielded_item)

	if current_ingot == nil then
		return -- no ingot to punch
	end
	if wielded_item:get_count() ~= 0 and (wielded_ingot == nil or wielded_ingot.color ~= current_ingot.color) then
		return -- a stack can be taken appart only by hand or relevant ingot_item
	end

	-- check protection
	local player_name = puncher:get_player_name()
	if minetest.is_protected(pos, player_name) and not minetest.check_player_privs(puncher, "protection_bypass") then
		minetest.record_protection_violation(pos, player_name)
		return
	end
	local is_creative = minetest.is_creative_enabled(player_name)
	local sneak = puncher:get_player_control().sneak

	-- prepare a new node
	local count_to_take = 1
	if sneak then
		count_to_take = 10
	end
	local new_description
	if current_ingot.count > count_to_take then
		new_description = current_ingot.description .." ("..(current_ingot.count - count_to_take)..")"
		node.name = "ingots:ingots_"..(current_ingot.count - count_to_take)
	else
		count_to_take = current_ingot.count
		node = nil
	end

	local stack = ItemStack(current_ingot.item.." "..count_to_take)
	if wielded_item:item_fits(stack) then
		-- add ingot the the wielded item
		set_node_and_description(pos, node, new_description)
		wielded_item:add_item(stack)
		if not is_creative or wielded_item:get_count() == 1 then
			puncher:set_wielded_item(wielded_item)
		end
	else
		local inv = puncher:get_inventory()
		if inv:room_for_item("main", stack) then
			-- add ingot to the inventory
			set_node_and_description(pos, node, new_description)
			if not is_creative or not inv:contains_item("main", stack) then
				inv:add_item("main", stack)
			end
		end
	end
end

local function preserve_metadata(pos, oldnode, oldmeta, drops)
	local ingot_info = get_info_from_node(oldnode)
	if ingot_info ~= nil then
		drops[1] = ItemStack(ingot_info.item.." "..ingot_info.count)
	end
end

local default_ingot
if minetest.registered_items["technic:mixed_metal_ingot"] then
	default_ingot = "technic:mixed_metal_ingot"
else
	default_ingot = "default:steel_ingot"
end

local sounds
if minetest.get_modpath("default") then
	sounds = default.node_sound_metal_defaults()
end
local tiles = {{name = "ingot_normal.png", backface_culling = true}}

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
		description = "1 ingot"
	elseif count < 5 then
		description = count.." ingoty"
	else
		description = count.." ingotů"
	end
	def = {
		description = description,
		drawtype = "mesh",
		tiles = tiles,
		mesh = "ingot_"..count..".obj",
		selection_box = box,
		collision_box = box,
		paramtype = "light",
		paramtype2 = "color",
		palette = "ingots_palette.png",
		is_ground_content = false,
		groups = {cracky = 3, level = 2, ingots = count, not_in_creative_inventory = 1},
		sounds = sounds,
		drop = default_ingot.." "..count,
		on_punch = on_punch_ingot,
		preserve_metadata = preserve_metadata,
	}
	minetest.register_node("ingots:ingots_"..count, def)
end

local override = {
	on_place = on_place_ingot,
}
for color, ingot in ipairs(color_to_ingot) do
	-- override the ingot if exists
	local idef = minetest.registered_items[ingot]
	if idef ~= nil then
		minetest.override_item(ingot, override)
		ingots.supported_ingots[ingot] = true
	end
end

-- LBM to upgrade from the old ingots:

local nodenames = {}
local results = {}

local function lbm_func(pos, node, dtime_s)
	local result = results[node.name]
	local old_name = node.name
	node.name = result.name
	node.param2 = result.param2
	minetest.set_node(pos, node)
	print("Ingots node "..old_name.." at "..minetest.pos_to_string(pos).." upgraded to "..node.name..".")
end

for color, metal in pairs({
	"bronze", -- 1
	"tin", -- 2
	"chromium", -- 3
	"cast_iron", -- 4
	"copper", -- 5
	"mithril", -- 6
	"brass", -- 7
	"stainless_steel", -- 8
	"lead", -- 9
	"silver", -- 10
	"carbon_steel", -- 11
	"mixed_metal", -- 12
	"zinc", -- 13
	"gold", -- 14
	"steel", -- 15
	-- "uranium0", -- 16
                           }) do
	for i = 1, 64 do
		local name = "ingots:"..metal.."_ingot_"..i
		table.insert(nodenames, name)
		results[name] = {
			name = "ingots:ingots_"..i,
			param2 = color,
		}
	end
end

minetest.register_lbm({
	label = "Upgrade ingots",
	name = "ingots:upgrade_ingots",
	nodenames = nodenames,
	run_at_every_load = false,
	action = lbm_func,
})

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
