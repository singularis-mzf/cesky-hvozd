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

-- 0 => do not change
-- 1 => simple model
-- 2 => full bushy model

local leaves_nodes = {
	-- Cool Trees
	["baldcypress:leaves"] = 1,
	["bamboo:leaves"] = 1,
	["birch:leaves"] = 1,
	["cacaotree:leaves"] = 1,
	["clementinetree:leaves"] = 1,
	["ebony:leaves"] = 1,
	["hollytree:leaves"] = 1,
	["cherrytree:leaves"] = 2,
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
	["moretrees:apple_tree_leaves"] = 2,
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
	["default:blueberry_bush_leaves"] = 1,
	["default:blueberry_bush_leaves_with_berries"] = 2,
	["default:bush_leaves"] = 1,
	["default:leaves"] = 1,

	["default:jungleleaves"] = 1,
	["default:pine_bush_needles"] = 1,
	["default:pine_needles"] = 1,
}

local node_box_bushy_leaves = {
	type = "fixed",
	fixed = {
		{  0/16, -4/16,-12/16,  0/16,  4/16, 12/16 },
		{  0/16, -8/16, -8/16,  0/16,  8/16,  8/16 },
		{  0/16,-12/16, -4/16,  0/16, 12/16,  4/16 },

		{-12/16,  0/16, -4/16, 12/16,  0/16,  4/16 },
		{ -8/16,  0/16, -8/16,  8/16,  0/16,  8/16 },
		{ -4/16,  0/16,-12/16,  4/16,  0/16, 12/16 },

		{-12/16, -4/16,  0/16, 12/16,  4/16,  0/16 },
		{ -8/16, -8/16,  0/16,  8/16,  8/16,  0/16 },
		{ -4/16,-12/16,  0/16,  4/16, 12/16,  0/16 },
	},
}

local node_box_bushy_leaves_low_budget = {
	type = "fixed",
	fixed = {
		{  0/16, -4/16,-12/16,  0/16,  4/16, 12/16 },
		{  0/16, -8/16, -8/16,  0/16,  8/16,  8/16 },
		-- {  0/16,-12/16, -4/16,  0/16, 12/16,  4/16 },

		{ -8/16,  0/16, -8/16,  8/16,  0/16,  8/16 },

		{-12/16, -4/16,  0/16, 12/16,  4/16,  0/16 },
		{ -8/16, -8/16,  0/16,  8/16,  8/16,  0/16 },
		-- { -4/16,-12/16,  0/16,  4/16, 12/16,  0/16 },
	},
}

local node_box_full_node = {
	type = "fixed",
	fixed = { -8/16, -8/16, -8/16,  8/16,  8/16,  8/16 },
}

--[[
local bushy_leaves_override = {
	drawtype = "nodebox",
	node_box = node_box_bushy_leaves,
	collision_box = node_box_full_node,
	use_texture_alpha = "clip",
} ]]

local override_0 = {
	climbable = true,
	walkable = false,
}
local override_1 = {
	climbable = true,
	walkable = false,
	drawtype = "nodebox",
	node_box = node_box_bushy_leaves_low_budget,
-- 	collision_box = node_box_full_node,
	use_texture_alpha = "clip",
}
local override_2 = {
	climbable = true,
	walkable = false,
	drawtype = "nodebox",
	node_box = node_box_bushy_leaves,
--	collision_box = node_box_full_node,
	use_texture_alpha = "clip",
}

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

--[[
local add_bushy_leaves = function()
	-- local counter = 0
	for i, v in ipairs(leaves_nodes) do
		if minetest.registered_nodes[v] then
			minetest.override_item(v, bushy_leaves_override)
		end
	end
	-- print(string.format("[MOD] Bushy Leaves: %d items redefined.\n", counter))
end

minetest.register_on_mods_loaded(add_bushy_leaves)
]]
print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
