--[[

bushy_leaves – Minetest mod to render leaves bushy
Copyright © 2022  Nils Dagsson Moskopp (erlehmann)
Copyright © 2022  Singularis <singularis@volny.cz>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

Dieses Programm hat das Ziel, die Medienkompetenz der Leser zu
steigern. Gelegentlich packe ich sogar einen handfesten Buffer
Overflow oder eine Format String Vulnerability zwischen die anderen
Codezeilen und schreibe das auch nicht dran.

]]--

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

-- supported programs:
--		"none" => no model change (but is make leaves climbable, non-walkable and waving)
--		"plantlike" => use drawtype = "plantlike"
--		"cheap" => use drawtype = "mesh" and a cheap bushy model
--		"bushy" => use drawtype = "mesh" and a full bushy model

local leaves_nodes = {
	["darkage:dry_leaves"] = "cheap_nostick", -- special (no sticks!)

	-- More Trees
	["moretrees:apple_tree_leaves"] = "cheap",
	["moretrees:beech_leaves"] = "cheap",
	["moretrees:birch_leaves"] = "cheap",
	["moretrees:cedar_leaves"] = "cheap",
	["moretrees:date_palm_leaves"] = "cheap",
	["moretrees:fir_leaves"] = "cheap",
	["moretrees:fir_leaves_bright"] = "cheap",
	["moretrees:oak_leaves"] = "cheap",
	["moretrees:palm_leaves"] = "cheap",
	["moretrees:poplar_leaves"] = "cheap",
	["moretrees:sequoia_leaves"] = "cheap",
	["moretrees:spruce_leaves"] = "cheap",
	["moretrees:willow_leaves"] = "cheap",
	["moretrees:rubber_tree_leaves"] = "cheap",
	["moretrees:jungletree_leaves_red"] = "cheap",
	["moretrees:jungletree_leaves_yellow"] = "cheap",
	["moretrees:cherrytree_leaves"] = "cheap",
	["moretrees:chestnut_tree_leaves"] = "cheap",
	["moretrees:ebony_leaves"] = "cheap",
	["moretrees:plumtree_leaves"] = "cheap",

	-- Ethereal
	["ethereal:bananaleaves"] = "plantlike_nostick",

	-- default
	["default:acacia_bush_leaves"] = "plantlike_nostick",
	["default:acacia_leaves"] = "plantlike_nostick",
	["default:aspen_leaves"] = "cheap",
	["default:blueberry_bush_leaves"] = "bushy_nostick",
	["default:blueberry_bush_leaves_with_berries"] = "bushy_nostick",
	["default:bush_leaves"] = "bushy_nostick",
	["default:leaves"] = "cheap",

	["default:jungleleaves"] = "cheap",
	["default:pine_bush_needles"] = "bushy",
	["default:pine_needles"] = "cheap",
}

local node_box_full_node = {
	type = "fixed",
	fixed = { -8/16, -8/16, -8/16,  8/16,  8/16,  8/16 },
}

local programs = {}

-- "none" => no model change (but is make leaves climbable, non-walkable and waving)
programs.none = {
	climbable = true,
	walkable = false,
	waving = 2,
	move_resistance = 1,
	collision_box = node_box_full_node,
}

-- "plantlike" => use drawtype = "plantlike"
local p = table.copy(programs.none)
p.drawtype = "plantlike"
p.visual_scale = 1.4
programs.plantlike = p
programs.plantlike_nostick = p

-- "cheap" => use drawtype = "mesh" and a cheap bushy model
p = table.copy(programs.none)
p.drawtype = "mesh"
p.mesh = "bushy_leaves_cheap_model.obj"
p.use_texture_alpha = "clip"
programs.cheap = p
programs.cheap_nostick = p

-- "bushy" => use drawtype = "mesh" and a full bushy model
p = table.copy(p)
p.mesh = "bushy_leaves_full_model.obj"
programs.bushy = p
programs.bushy_nostick = p

local nostick_programs = {
	["bushy_nostick"] = true,
	["cheap_nostick"] = true,
	["plantlike_nostick"] = true,
}

for name, program_name in pairs(leaves_nodes) do
	local def = minetest.registered_nodes[name]
	local program = programs[program_name]
	if def then
		if not program then
			error("Invalid program: "..program_name)
		end
		if not nostick_programs[program_name] then
			program = table.copy(program)
			if type(def.drop) ~= "table" then
				error("Unexpected type of drop for "..name.."!")
			end
			local new_drop_items = {
				{items = {"default:stick"}, rarity = 16}
			}
			program.drop = def.drop
			table.insert_all(new_drop_items, program.drop.items)
			program.drop.items = new_drop_items
		end
		minetest.override_item(name, program)
	end
end

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
