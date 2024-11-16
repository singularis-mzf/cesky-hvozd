
--[[
	Textures edited from:
	http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1288375-food-plus-mod-more-food-than-you-can-imagine-v2-9)
]]

local S = farming.intllib

-- tomato_yellow
minetest.register_craftitem("farming:tomato_yellow", {
	description = S("Yellow Tomato"),
	inventory_image = "farming_tomato_yellow.png",
	groups = {seed = 2, food_tomato = 1, flammable = 2, ch_food = 4},
	on_place = function(itemstack, placer, pointed_thing)
		return farming.place_seed(itemstack, placer, pointed_thing, "farming:tomato_yellow_1")
	end,
	on_use = minetest.item_eat(4)
})

-- tomato_yellow definition
local def = {
	description = S("Yellow Tomato"),
	drawtype = "plantlike",
	tiles = {"farming_tomato_1.png"},
	paramtype = "light",
	sunlight_propagates = true,
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
minetest.register_node("farming:tomato_yellow_1", table.copy(def))

-- stage2
def.tiles = {"farming_tomato_2.png"}
minetest.register_node("farming:tomato_yellow_2", table.copy(def))

-- stage 3
def.tiles = {"farming_tomato_3.png"}
def.move_resistance = 1
minetest.register_node("farming:tomato_yellow_3", table.copy(def))

-- stage 4
def.tiles = {"farming_tomato_4.png"}
minetest.register_node("farming:tomato_yellow_4", table.copy(def))

-- stage 5
def.tiles = {"farming_tomato_5.png"}
minetest.register_node("farming:tomato_yellow_5", table.copy(def))

-- stage 6
def.tiles = {"farming_tomato_6.png"}
minetest.register_node("farming:tomato_yellow_6", table.copy(def))

-- stage 7
def.tiles = {"farming_tomato_yellow_7.png"}
def.drop = {
	items = {
		{items = {"farming:tomato_yellow"}, rarity = 1},
		{items = {"farming:tomato_yellow"}, rarity = 3}
	}
}
minetest.register_node("farming:tomato_yellow_7", table.copy(def))

-- stage 8 (final)
def.tiles = {"farming_tomato_yellow_8.png"}
def.groups.growing = nil
def.drop = {
	items = {
		{items = {"farming:tomato_yellow 3"}, rarity = 1},
		{items = {"farming:tomato_yellow 2"}, rarity = 2},
		{items = {"farming:tomato_yellow 1"}, rarity = 3}
	}
}
minetest.register_node("farming:tomato_yellow_8", table.copy(def))

-- add to registered_plants
farming.registered_plants["farming:tomato_yellow"] = {
	crop = "farming:tomato_yellow",
	seed = "farming:tomato_yellow",
	minlight = farming.min_light,
	maxlight = farming.max_light,
	steps = 8
}
