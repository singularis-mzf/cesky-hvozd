--[[
    Dense Ores mod for Minetest
    Copyright (C) 2021 benedict424

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

--]]

local S = minetest.get_translator("denseores")

-- Mithril, Tin, Silver. That's my pattern.

--[	Large Ore Nodes	--]
--[	Finished!	--]

minetest.register_node("denseores:large_mithril_ore", {
	description = S("Heavy Mithril Ore"),
	tiles ={"default_stone.png^large_mithril_ore.png"},
	groups = {cracky=3},
	drop = 'moreores:mithril_lump 2',
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("denseores:large_silver_ore", {
	description = S("Heavy Silver Ore"),
	tiles ={"default_stone.png^large_silver_ore.png"},
	groups = {cracky=3},
	drop = 'moreores:silver_lump 2',
	sounds = default.node_sound_stone_defaults(),
})


--[	Large Ore Defenitions	--]
--[	Finished!	--]

minetest.register_ore({
    ore_type       = "scatter",
    ore            = "denseores:large_mithril_ore",
    wherein        = "moreores:mineral_mithril",
    clust_scarcity = 12,
    clust_num_ores = 2,
    clust_size     = 2,
    y_min     = -31000,
    y_max     = 64,
})

minetest.register_ore({
    ore_type       = "scatter",
    ore            = "denseores:large_silver_ore",
    wherein        = "moreores:mineral_silver",
    clust_scarcity = 12,
    clust_num_ores = 2,
    clust_size     = 2,
    y_min     = -31000,
    y_max     = 64,
})


--[	Crafting Recipies	--]
--[	From Large to Normal	--]

minetest.register_craft( {
	type = "shapeless",
	output = "moreores:mithril_lump 2", --mithril
	recipe = {
		"denseores:large_mithril_ore",
	}
})

minetest.register_craft( {
	type = "shapeless",
	output = "moreores:silver_lump 2", --silver
	recipe = {
		"denseores:large_silver_ore",
	}
})

