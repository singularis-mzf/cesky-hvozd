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


--[[
Order of everything here:
coal, iron, copper, gold, mese, diamond
Large, small
--]]

denseores_modpath = minetest.get_modpath("denseores")


--[	Large Ore Nodes	--]

minetest.register_node("denseores:large_coal_ore", {	--coal
	description = "Large Coal Ore",
	tiles ={"default_stone.png^large_coal_ore.png"},
	groups = {cracky=3},
	drop = 'default:coal_lump 2',
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("denseores:large_iron_ore", {	--iron
	description = "Large Iron Ore",
	tiles ={"default_stone.png^large_iron_ore.png"},
	groups = {cracky=2},
	drop = 'default:iron_lump 2',
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("denseores:large_copper_ore", {	--copper
	description = "Large Copper Ore",
	tiles ={"default_stone.png^large_copper_ore.png"},
	groups = {cracky=2},
	drop = 'default:copper_lump 2',
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("denseores:large_tin_ore", {	--tin
	description = "Large Tin Ore",
	tiles ={"default_stone.png^large_tin_ore.png"},
	groups = {cracky=3},
	drop = 'default:tin_lump 2',
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("denseores:large_gold_ore", {	--gold
	description = "Large Gold Ore",
	tiles ={"default_stone.png^large_gold_ore.png"},
	groups = {cracky=2},
	drop = 'default:gold_lump 2',
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("denseores:large_mese_ore", {	--mese
	description = "Large Mese Ore",
	tiles ={"default_stone.png^large_mese_ore.png"},
	groups = {cracky=1},
	drop = 'default:mese_crystal 2',
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("denseores:large_diamond_ore", {	--diamond
	description = "Large Diamond Ore",
	tiles ={"default_stone.png^large_diamond_ore.png"},
	groups = {cracky=1},
	drop = 'default:diamond 2',
	sounds = default.node_sound_stone_defaults(),
})


--[	Large Ore Defenitions	--]

minetest.register_ore({
    ore_type       = "scatter",
    ore            = "denseores:large_coal_ore",
    wherein        = "default:stone_with_coal",
    clust_scarcity = 14,
    clust_num_ores = 2,
    clust_size     = 2,
    height_min     = -31000,
    height_max     = 64,
})

minetest.register_ore({
    ore_type       = "scatter",
    ore            = "denseores:large_iron_ore",
    wherein        = "default:stone_with_iron",
    clust_scarcity = 14,
    clust_num_ores = 2,
    clust_size     = 2,
    height_min     = -31000,
    height_max     = 2,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "denseores:large_copper_ore",
	wherein        = "default:stone_with_copper",
	clust_scarcity = 14,
	clust_num_ores = 2,
	clust_size     = 2,
	height_min     = -31000,
	height_max     = 2,
})

minetest.register_ore({
    ore_type       = "scatter",
    ore            = "denseores:large_tin_ore",
    wherein        = "default:stone_with_tin",
    clust_scarcity = 12,
    clust_num_ores = 2,
    clust_size     = 2,
    height_min     = -31000,
    height_max     = 64,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "denseores:large_gold_ore",
	wherein        = "default:stone_with_gold",
	clust_scarcity = 14,
	clust_num_ores = 2,
	clust_size     = 2,
	height_min     = -31000,
	height_max     = 2,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "denseores:large_mese_ore",
	wherein        = "default:stone_with_mese",
	clust_scarcity = 14,
	clust_num_ores = 2,
	clust_size     = 2,
	height_min     = -31000,
	height_max     = -64,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "denseores:large_diamond_ore",
	wherein        = "default:stone_with_diamond",
	clust_scarcity = 14,
	clust_num_ores = 2,
	clust_size     = 2,
	height_min     = -31000,
	height_max     = -128,
})


--[	Crafting Recipies	--]
--[	From Large to Normal	--]

minetest.register_craft( {
	type = "shapeless",
	output = "default:coal_lump 2", --coal
	recipe = {
		"denseores:large_coal_ore",
	}
})

minetest.register_craft( {
	type = "shapeless",
	output = "default:iron_lump 2", --iron
	recipe = {
		"denseores:large_iron_ore",
	}
})

minetest.register_craft( {
	type = "shapeless",
	output = "default:copper_lump 2", --copper
	recipe = {
		"denseores:large_copper_ore",
	}
})

minetest.register_craft( {
	type = "shapeless",
	output = "moreores:tin_lump 2", --tin
	recipe = {
		"denseores:large_tin_ore",
	}
})

minetest.register_craft( {
	type = "shapeless",
	output = "default:gold_lump 2", --gold
	recipe = {
		"denseores:large_gold_ore",
	}
})

minetest.register_craft( {
	type = "shapeless",
	output = "default:mese_crystal 2", --mese
	recipe = {
		"denseores:large_mese_ore",
	}
})

minetest.register_craft( {
	type = "shapeless",
	output = "default:diamond 2", --diamond
	recipe = {
		"denseores:large_diamond_ore",
	}
})


-- Special things happen from this line down.


-- Does moreores exist? Let's find out!
if minetest.get_modpath("moreores") then		--Thank you Kazea of the Minetest Fourums.
	dofile(denseores_modpath .. "/mo.lua")
end


