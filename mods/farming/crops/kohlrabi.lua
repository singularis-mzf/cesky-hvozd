
local S = farming.intllib

-- kohlrabi
minetest.register_craftitem("farming:kohlrabi", {
	description = S("kohlrabi"),
	inventory_image = "cucina_vegana_kohlrabi.png",
	groups = {seed = 2, food_kohlrabi = 1, flammable = 2, ch_food = 1},
	on_place = function(itemstack, placer, pointed_thing)
		return farming.place_seed(itemstack, placer, pointed_thing, "farming:kohlrabi_1")
	end,
	on_use = minetest.item_eat(1)
})

-- kohlrabi definition
local def = {
	description = S("kohlrabi"),
	drawtype = "plantlike",
	tiles = {"cucina_vegana_kohlrabi_1.png"},
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
minetest.register_node("farming:kohlrabi_1", table.copy(def))

-- stage 2
def.tiles = {"cucina_vegana_kohlrabi_2.png"}
minetest.register_node("farming:kohlrabi_2", table.copy(def))

-- stage 3
def.tiles = {"cucina_vegana_kohlrabi_3.png"}
minetest.register_node("farming:kohlrabi_3", table.copy(def))

-- stage 4
def.tiles = {"cucina_vegana_kohlrabi_4.png"}
def.drop = {
	items = {
		{items = {"farming:kohlrabi"}, rarity = 2}
	}
}
minetest.register_node("farming:kohlrabi_4", table.copy(def))

-- stage 5
def.tiles = {"cucina_vegana_kohlrabi_5.png"}
def.drop = {
	items = {
		{items = {"farming:kohlrabi"}, rarity = 1},
		{items = {"farming:kohlrabi 2"}, rarity = 2}
	}
}
minetest.register_node("farming:kohlrabi_5", table.copy(def))

-- stage 6
def.tiles = {"cucina_vegana_kohlrabi_6.png"}
def.groups.growing = nil
def.selection_box = farming.select_final
def.drop = {
	items = {
		{items = {"farming:kohlrabi"}, rarity = 1},
		{items = {"farming:kohlrabi 2"}, rarity = 2},
		{items = {"farming:kohlrabi 2"}, rarity = 3},
	}
}
minetest.register_node("farming:kohlrabi_6", table.copy(def))

-- add to registered_plants
farming.registered_plants["farming:kohlrabi"] = {
	crop = "farming:kohlrabi",
	seed = "farming:kohlrabi",
	minlight = 7,
	maxlight = farming.max_light,
	steps = 6
}
