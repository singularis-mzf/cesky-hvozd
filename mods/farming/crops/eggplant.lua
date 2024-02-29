
local S = farming.intllib

-- eggplant
minetest.register_craftitem("farming:eggplant", {
	description = S("Eggplant"),
	inventory_image = "farming_eggplant.png",
	groups = {seed = 2, food_eggplant = 1, flammable = 2, ch_food = 3},
	on_place = function(itemstack, placer, pointed_thing)
		return farming.place_seed(itemstack, placer, pointed_thing, "farming:eggplant_1")
	end,
	on_use = minetest.item_eat(3)
})

-- definition
local def = {
	description = S("Eggplant"),
	drawtype = "plantlike",
	tiles = {"farming_eggplant_1.png"},
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
minetest.register_node("farming:eggplant_1", table.copy(def))

-- stage 2
def.tiles = {"farming_eggplant_2.png"}
minetest.register_node("farming:eggplant_2", table.copy(def))

-- stage 3
def.tiles = {"farming_eggplant_3.png"}
def.drop = {
	items = {
		{items = {"farming:eggplant"}, rarity = 1},
		{items = {"farming:eggplant"}, rarity = 3}
	}
}
minetest.register_node("farming:eggplant_3", table.copy(def))

-- stage 4
def.tiles = {"farming_eggplant_4.png"}
def.groups.growing = nil
def.selection_box = farming.select_final
def.drop = {
	items = {
		{items = {"farming:eggplant 2"}, rarity = 1},
		{items = {"farming:eggplant 2"}, rarity = 2}
	}
}
minetest.register_node("farming:eggplant_4", table.copy(def))

-- add to registered_plants
farming.registered_plants["farming:eggplant"] = {
	crop = "farming:eggplant",
	seed = "farming:eggplant",
	minlight = 7,
	maxlight = farming.max_light,
	steps = 4
}
