--[[
	Textures from Cucina Vegana (LGPLv3)
	https://forum.minetest.net/viewtopic.php?t=20001
]]

local S = farming.intllib

-- flax seed
minetest.register_node("farming:seed_flax", {
	description = S("Flax Seed"),
	tiles = {"cucina_vegana_flax_seed.png"},
	inventory_image = "cucina_vegana_flax_seed.png",
	wield_image = "cucina_vegana_flax_seed.png",
	drawtype = "signlike",
	groups = {seed = 1, snappy = 3, attached_node = 1, flammable = 4},
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	sunlight_propagates = true,
	selection_box = farming.select,
	on_place = function(itemstack, placer, pointed_thing)
		return farming.place_seed(itemstack, placer, pointed_thing, "farming:flax_1")
	end
})

-- raw flax
minetest.register_craftitem("farming:raw_flax", {
	description = S("Raw Flax"),
	inventory_image = "cucina_vegana_flax_raw.png",
	groups = {flammable = 1, string = 1},
})

-- roasted flax
minetest.register_craftitem("farming:flax_roasted", {
	description = S("Flax"),
	inventory_image = "cucina_vegana_flax.png",
	groups = {flammable = 1, string = 1},
})

-- node definitions
local def = {
	description = S("Flax"),
	drawtype = "plantlike",
	tiles = {"cucina_vegana_flax_1.png"},
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
minetest.register_node("farming:flax_1", table.copy(def))

-- stage 2
def.tiles = {"cucina_vegana_flax_2.png"}
minetest.register_node("farming:flax_2", table.copy(def))

-- stage 3
def.tiles = {"cucina_vegana_flax_3.png"}
def.move_resistance = 1
minetest.register_node("farming:flax_3", table.copy(def))

-- stage 4
def.tiles = {"cucina_vegana_flax_4.png"}
minetest.register_node("farming:flax_4", table.copy(def))

-- stage 5
def.tiles = {"cucina_vegana_flax_5.png"}
def.drop = {
	items = {
		{items = {"farming:seed_flax"}, rarity = 2},
	}
}
minetest.register_node("farming:flax_5", table.copy(def))

-- stage 6
def.tiles = {"cucina_vegana_flax_6.png"}
def.drop = {
	items = {
		{items = {"farming:raw_flax 3"}, rarity = 1},
		{items = {"farming:raw_flax 4"}, rarity = 3},
		{items = {"farming:seed_flax 3"}, rarity = 1},
		{items = {"farming:seed_flax 4"}, rarity = 3},
	}
}
def.selection_box = farming.select_final
def.groups.growing = nil
minetest.register_node("farming:flax_6", table.copy(def))

-- add to registered_plants
farming.registered_plants["farming:flax"] = {
	crop = "farming:raw_flax",
	seed = "farming:seed_flax",
	minlight = farming.min_light,
	maxlight = farming.max_light,
	steps = 6
}

-- oil
minetest.register_node("farming:flax_seed_oil", {
	description = S("Bottle of Flaxseed Oil"),
	drawtype = "plantlike",
	tiles = {"cucina_vegana_flax_seed_oil.png"},
	inventory_image = "cucina_vegana_flax_seed_oil.png",
	wield_image = "cucina_vegana_flax_seed_oil.png",
	paramtype = "light",
	walkable = false,
	on_use = minetest.item_eat(2, "vessels:glass_bottle"),
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
	},
	groups = {dig_immediate = 3, food = 1, food_oil = 1, eatable = 1, vessel = 1},
	sounds = default.node_sound_glass_defaults(),
})

-- craft recipes
minetest.register_craft({
	type = "cooking",
	output = "farming:flax_roasted",
	recipe = "farming:raw_flax",
	cooktime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "farming:flax_seed_oil",
	burntime = 30,
})

minetest.register_craft({
	output = "wool:white",
	recipe = {
		{"farming:flax_roasted", "farming:flax_roasted", "farming:flax_roasted"},
		{"farming:flax_roasted", "farming:flax_roasted", "farming:flax_roasted"},
	},
})

local buckets = {
	["bucket:bucket_water"] = {"bucket:bucket_water", "bucket:bucket_empty"},
	["bucket:bucket_river_water"] = {"bucket:bucket_river_water", "bucket:bucket_empty"},
}

for _, stone in ipairs({"default:stone", "default:desert_stone"}) do
	local stone_stone = {stone, stone}
	for bucket_in, bucket_replacement in pairs(buckets) do
		minetest.register_craft({
			output = "default:paper 4",
			recipe = {
				{stone, "farming:flax_roasted", stone},
				{stone, "farming:flax_roasted", stone},
				{"", bucket_in, ""},
			},
			replacements = {
				stone_stone, stone_stone, stone_stone, stone_stone,
				bucket_replacement,
			},
		})
	end
end

minetest.register_craft({
	output = "farming:cotton 2",
	recipe = {
		{"farming:flax_roasted", "default:stick", "farming:flax_roasted"},
	},
	replacements = {
		{"default:stick", "default:stick"},
	},
})

minetest.register_craft({
	output = "farming:flax_seed_oil",
	recipe = {
		{"farming:seed_flax", "farming:seed_flax", "farming:seed_flax"},
		{"farming:seed_flax", "farming:seed_flax", "farming:seed_flax"},
		{"", "vessels:glass_bottle", ""},
	},
})
