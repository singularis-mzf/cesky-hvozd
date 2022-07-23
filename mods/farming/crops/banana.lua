--[[
	Textures from Cucina Vegana (LGPLv3)
	https://forum.minetest.net/viewtopic.php?t=20001
]]

local S = farming.intllib

local banana_item = "ethereal:banana"
local banana_item_t = {banana_item}

-- node definitions
local def = {
	drawtype = "plantlike",
	tiles = {"cucina_vegana_banana_1.png"},
	paramtype = "light",
	sunlight_propagates = true,
	waving = 1,
	walkable = false,
	buildable_to = true,
	drop = "",
	selection_box = farming.select,
	groups = {
		snappy = 3, flammable = 2, plant = 1, attached_node = 1,
		not_in_creative_inventory = 1, growing = 1
	},
	sounds = default.node_sound_leaves_defaults()
}

-- stage 1
minetest.register_node("farming:banana_1", table.copy(def))

-- stage 2
def.tiles = {"cucina_vegana_banana_2.png"}
minetest.register_node("farming:banana_2", table.copy(def))

-- stage 3
def.tiles = {"cucina_vegana_banana_3.png"}
minetest.register_node("farming:banana_3", table.copy(def))

-- stage 4
def.tiles = {"cucina_vegana_banana_4.png"}
minetest.register_node("farming:banana_4", table.copy(def))

-- stage 5
def.tiles = {"cucina_vegana_banana_5.png"}
def.drop = {
	items = {
		{items = banana_item_t, rarity = 3},
	}
}
minetest.register_node("farming:banana_5", table.copy(def))

-- stage 6
def.tiles = {"cucina_vegana_banana_6.png"}
def.drop = {
	items = {
		{items = banana_item_t, rarity = 1},
	}
}
minetest.register_node("farming:banana_6", table.copy(def))

-- stage 7
def.tiles = {"cucina_vegana_banana_7.png"}
def.drop = {
	items = {
		{items = banana_item_t, rarity = 1},
		{items = {banana_item.." 2"}, rarity = 2},
	}
}
minetest.register_node("farming:banana_7", table.copy(def))

-- stage 8
def.tiles = {"cucina_vegana_banana_8.png"}
def.drop = {
	items = {
		{items = {banana_item.." 2"}, rarity = 1},
		{items = {banana_item.." 2"}, rarity = 2},
		{items = banana_item_t, rarity = 3},
	}
}
def.groups.growing = nil
minetest.register_node("farming:banana_8", table.copy(def))

-- add to registered_plants
farming.registered_plants["farming:banana"] = {
	crop = banana_item,
	seed = banana_item,
	minlight = farming.min_light,
	maxlight = farming.max_light,
	steps = 8
}
