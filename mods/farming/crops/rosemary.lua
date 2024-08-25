
local S = farming.intllib

-- rosemary
minetest.register_craftitem("farming:rosemary", {
	description = S("rosemary"),
	inventory_image = "cucina_vegana_rosemary.png",
	groups = {seed = 2, food_rosemary = 1, flammable = 2},
	on_place = function(itemstack, placer, pointed_thing)
		return farming.place_seed(itemstack, placer, pointed_thing, "farming:rosemary_1")
	end,
})

-- rosemary definition
local def = {
	description = S("rosemary"),
	drawtype = "plantlike",
	tiles = {"cucina_vegana_rosemary_1.png"},
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 3,
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
minetest.register_node("farming:rosemary_1", table.copy(def))

-- stage 2
def.tiles = {"cucina_vegana_rosemary_2.png"}
minetest.register_node("farming:rosemary_2", table.copy(def))

-- stage 3
def.tiles = {"cucina_vegana_rosemary_3.png"}
minetest.register_node("farming:rosemary_3", table.copy(def))

-- stage 4
def.tiles = {"cucina_vegana_rosemary_4.png"}
minetest.register_node("farming:rosemary_4", table.copy(def))

-- stage 5
def.tiles = {"cucina_vegana_rosemary_5.png"}
def.drop = {
	items = {
		{items = {"farming:rosemary"}, rarity = 1},
		{items = {"farming:rosemary 2"}, rarity = 2},
	}
}
minetest.register_node("farming:rosemary_5", table.copy(def))

-- stage 6
def.tiles = {"cucina_vegana_rosemary_6.png"}
def.groups.growing = nil
def.selection_box = farming.select_final
def.drop = {
	items = {
		{items = {"farming:rosemary"}, rarity = 1},
		{items = {"farming:rosemary 2"}, rarity = 2},
		{items = {"farming:rosemary 3"}, rarity = 3},
	}
}
minetest.register_node("farming:rosemary_6", table.copy(def))

-- add to registered_plants
farming.registered_plants["farming:rosemary"] = {
	crop = "farming:rosemary",
	seed = "farming:rosemary",
	minlight = 7,
	maxlight = farming.max_light,
	steps = 6
}
