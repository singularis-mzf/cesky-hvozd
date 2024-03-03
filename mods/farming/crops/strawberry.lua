--[[
	Textures from Ethereal NG
	https://forum.minetest.net/viewtopic.php?t=14638
]]

local S = farming.intllib

-- strawberry
minetest.register_craftitem("farming:strawberry", {
	description = S("Strawberry"),
	inventory_image = "farming_strawberry.png",
	groups = {seed = 2, food_strawberry = 1, food_berry = 1, flammable = 2, ch_food = 1},
	on_place = function(itemstack, placer, pointed_thing)
		return farming.place_seed(itemstack, placer, pointed_thing, "farming:strawberry_1")
	end,
	on_use = minetest.item_eat(1),
})

-- node definitions
local def = {
	description = S("Strawberry"),
	drawtype = "plantlike",
	tiles = {"farming_strawberry_1.png"},
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
minetest.register_node("farming:strawberry_1", table.copy(def))

-- stage 2
def.tiles = {"farming_strawberry_2.png"}
minetest.register_node("farming:strawberry_2", table.copy(def))

-- stage 3
def.tiles = {"farming_strawberry_3.png"}
def.move_resistance = 1
minetest.register_node("farming:strawberry_3", table.copy(def))

-- stage 4
def.tiles = {"farming_strawberry_4.png"}
minetest.register_node("farming:strawberry_4", table.copy(def))

-- stage 5
def.tiles = {"farming_strawberry_5.png"}
minetest.register_node("farming:strawberry_5", table.copy(def))

-- stage 6
def.tiles = {"farming_strawberry_6.png"}
def.drop = {
	items = {
		{items = {"farming:strawberry"}, rarity = 1},
	}
}
minetest.register_node("farming:strawberry_6", table.copy(def))

-- stage 7
def.tiles = {"farming_strawberry_7.png"}
def.drop = {
	items = {
		{items = {"farming:strawberry"}, rarity = 1},
		{items = {"farming:strawberry"}, rarity = 2},
	}
}
minetest.register_node("farming:strawberry_7", table.copy(def))

-- stage 8
def.tiles = {"farming_strawberry_8.png"}
def.drop = {
	items = {
		{items = {"farming:strawberry"}, rarity = 1},
		{items = {"farming:strawberry"}, rarity = 2},
		{items = {"farming:strawberry"}, rarity = 3},
	}
}
def.groups.growing = nil
def.selection_box = farming.select_final
minetest.register_node("farming:strawberry_8", table.copy(def))

-- add to registered_plants
farming.registered_plants["farming:strawberry"] = {
	crop = "farming:strawberry",
	seed = "farming:strawberry",
	minlight = farming.min_light,
	maxlight = farming.max_light,
	steps = 8
}
