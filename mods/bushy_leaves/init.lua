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

local get_node_box = function(node_name, node_def)
	local node_box
	if (
		string.match(node_name, "leaves") or
		string.match(node_name, "needles")
	) then
		node_box = node_box_bushy_leaves
	end
	return node_box
end

local add_bushy_leaves = function()
	for node_name, node_def in pairs(minetest.registered_nodes) do
		local node_box = get_node_box(node_name, node_def)
		if nil ~= node_box then
			minetest.override_item(
				node_name,
				{
					drawtype = "nodebox",
					node_box = node_box,
					collision_box = node_box_full_node,
				}
			)
		end
	end
end

minetest.register_on_mods_loaded(add_bushy_leaves)
