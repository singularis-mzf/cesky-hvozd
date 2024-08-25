
local S = farming.intllib

-- chives
minetest.register_craftitem("farming:chives", {
	description = S("chives"),
	inventory_image = "cucina_vegana_chives.png",
	groups = {seed = 2, food_chives = 1, flammable = 2},
	on_place = function(itemstack, placer, pointed_thing)
		return farming.place_seed(itemstack, placer, pointed_thing, "farming:chives_1")
	end,
})

-- chives definition
local def = {
	description = S("chives"),
	drawtype = "plantlike",
	tiles = {"cucina_vegana_chives_1.png"},
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
minetest.register_node("farming:chives_1", table.copy(def))

-- stage 2
def.tiles = {"cucina_vegana_chives_2.png"}
minetest.register_node("farming:chives_2", table.copy(def))

-- stage 3
def.tiles = {"cucina_vegana_chives_3.png"}
minetest.register_node("farming:chives_3", table.copy(def))

-- stage 4
def.tiles = {"cucina_vegana_chives_4.png"}
def.drop = {
	items = {
		{items = {"farming:chives"}, rarity = 2}
	}
}
minetest.register_node("farming:chives_4", table.copy(def))

-- stage 5
def.tiles = {"cucina_vegana_chives_5.png"}
def.groups.growing = nil
def.selection_box = farming.select_final
def.drop = {
	items = {
		{items = {"farming:chives"}, rarity = 1},
		{items = {"farming:chives 2"}, rarity = 2}
	}
}
minetest.register_node("farming:chives_5", table.copy(def))

-- add to registered_plants
farming.registered_plants["farming:chives"] = {
	crop = "farming:chives",
	seed = "farming:chives",
	minlight = 7,
	maxlight = farming.max_light,
	steps = 5
}
