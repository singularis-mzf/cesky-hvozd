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

local leaves_nodes = {
	"default:acacia_bush_leaves",
	"default:acacia_leaves",
	"default:aspen_leaves",
	"default:blueberry_bush_leaves",
	"default:blueberry_bush_leaves_with_berries",
	"default:bush_leaves",
	"default:leaves",
	"ebony:leaves",
	"cherrytree:blossom_leaves",
	"cherrytree:leaves",
	"chestnuttree:leaves",
	"plumtree:leaves",
	"moretrees:apple_tree_leaves",
	"moretrees:beech_leaves",
	"moretrees:birch_leaves",
	"moretrees:cedar_leaves",
	"moretrees:date_palm_leaves",
	"moretrees:fir_leaves",
	"moretrees:fir_leaves_bright",
	"moretrees:oak_leaves",
	"moretrees:palm_leaves",
	"moretrees:poplar_leaves",
	"moretrees:rubber_tree_leaves",
	"moretrees:sequoia_leaves",
	"moretrees:spruce_leaves",
	"moretrees:willow_leaves",
	"willow:leaves",
	-- "default:jungleleaves",
	-- "moretrees:jungletree_leaves_yellow",
	-- "moretrees:jungletree_leaves_red",
	-- "default:pine_bush_needles",
	-- "default:pine_needles",
}

-- local mods_with_leaves = {
    -- ["default"] = 1,
    -- ["moretrees"] = 1,
-- }

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

local node_box_full_node = {
	type = "fixed",
	fixed = { -8/16, -8/16, -8/16,  8/16,  8/16,  8/16 },
}

local bushy_leaves_override = {
	drawtype = "nodebox",
	node_box = node_box_bushy_leaves,
	collision_box = node_box_full_node,
	use_texture_alpha = "blend",
}

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
print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
