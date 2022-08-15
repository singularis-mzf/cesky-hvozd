--[[

bushy_leaves – Minetest mod to render leaves bushy
Copyright © 2022  Nils Dagsson Moskopp (erlehmann)

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

-- 0 => no model change (only make leaves climbable, non-walkable and waving)
-- 1 => use a cheap model
-- 2 => use the full model

local leaves_nodes = {
	-- Cool Trees
	["baldcypress:leaves"] = 1,
	["bamboo:leaves"] = 1,
	["birch:leaves"] = 1,
	["cacaotree:leaves"] = 1,
	["clementinetree:leaves"] = 1,
	["ebony:leaves"] = 1,
	["hollytree:leaves"] = 1,
	["cherrytree:leaves"] = 1,
	["chestnuttree:leaves"] = 1,
	["jacaranda:blossom_leaves"] = 1,
	["larch:leaves"] = 1,
	["lemontree:leaves"] = 1,
	["mahogany:leaves"] = 1,
	["maple:leaves"] = 1,
	["oak:leaves"] = 1,
	["palm:leaves"] = 1,
	["plumtree:leaves"] = 1,
	["pomegranate:leaves"] = 1,
	["sequoia:leaves"] = 1,
	["willow:leaves"] = 1,

	-- More Trees
	["moretrees:apple_tree_leaves"] = 1,
	["moretrees:beech_leaves"] = 1,
	["moretrees:birch_leaves"] = 1,
	["moretrees:cedar_leaves"] = 1,
	["moretrees:date_palm_leaves"] = 1,
	["moretrees:fir_leaves"] = 1,
	["moretrees:fir_leaves_bright"] = 1,
	["moretrees:oak_leaves"] = 1,
	["moretrees:palm_leaves"] = 1,
	["moretrees:poplar_leaves"] = 1,
	["moretrees:sequoia_leaves"] = 1,
	["moretrees:spruce_leaves"] = 1,
	["moretrees:willow_leaves"] = 1,
	["moretrees:rubber_tree_leaves"] = 1,
	["moretrees:jungletree_leaves_red"] = 1,
	["moretrees:jungletree_leaves_yellow"] = 1,

	-- default
	["default:acacia_bush_leaves"] = 1,
	["default:acacia_leaves"] = 1,
	["default:aspen_leaves"] = 1,
	["default:blueberry_bush_leaves"] = 2,
	["default:blueberry_bush_leaves_with_berries"] = 2,
	["default:bush_leaves"] = 2,
	["default:leaves"] = 1,

	["default:jungleleaves"] = 1,
	["default:pine_bush_needles"] = 2,
	["default:pine_needles"] = 1,
}

local node_box_full_node = {
	type = "fixed",
	fixed = { -8/16, -8/16, -8/16,  8/16,  8/16,  8/16 },
}

local override_0 = {
	climbable = true,
	walkable = false,
	waving = 2,
	move_resistance = 1,
	collision_box = node_box_full_node,
}
local override_1 = table.copy(override_0)
override_1.drawtype = "mesh"
override_1.mesh = "bushy_leaves_cheap_model.obj"
override_1.use_texture_alpha = "clip"
local override_2 = table.copy(override_1)
override_2.mesh = "bushy_leaves_full_model.obj"

for name, level in pairs(leaves_nodes) do
	local def = minetest.registered_nodes[name]
	if def then
		def.walkable = false
		if level == 2 then
			minetest.override_item(name, override_2)
		elseif level == 1 then
			minetest.override_item(name, override_1)
		else
			minetest.override_item(name, override_0)
		end
	end
end

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
