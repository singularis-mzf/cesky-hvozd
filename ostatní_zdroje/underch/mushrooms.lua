underch.mushrooms = {}

function underch.mushrooms.register_mushroom(id, name, texture, heal, box)
	minetest.register_node(id, {
		description = name,
		tiles = {texture},
		inventory_image = texture,
		wield_image = texture,
		drawtype = "plantlike",
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		buildable_to = true,
		groups = {snappy = 3, attached_node = 1, flammable = 1},
		sounds = default.node_sound_leaves_defaults(),
		on_use = minetest.item_eat(heal),
		selection_box = {
			type = "fixed",
			fixed = box,
		}
	})
end

underch.mushrooms.register_mushroom("underch:green_mushroom", "Green Mushroom", "underch_green_mushroom.png", -9, {-6 / 16, -0.5, -6 / 16, 6 / 16, 5 / 16, 6 / 16});
underch.mushrooms.register_mushroom("underch:black_mushroom", "Black Mushroom", "underch_black_mushroom.png", 0, {-4 / 16, -0.5, -4 / 16, 4 / 16, 1 / 16, 4 / 16});
underch.mushrooms.register_mushroom("underch:orange_mushroom", "Orange Mushroom", "underch_orange_mushroom.png", 1, {-3 / 16, -0.5, -3 / 16, 3 / 16, 7 / 16, 3 / 16});

minetest.register_node("underch:burning_mushroom", {
	description = "Burning Mushroom",
	tiles = {{
		name = "underch_burning_mushroom.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 0.5,
		},
	}},
	inventory_image = "[combine:16x16:0,0=underch_burning_mushroom.png",
	wield_image = "[combine:16x16:0,0=underch_burning_mushroom.png",
	drawtype = "plantlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	groups = {snappy = 3, attached_node = 1},
	sounds = default.node_sound_leaves_defaults(),
	on_use = minetest.item_eat(-2),
	light_source = 8,
	damage_per_second = 1,
	selection_box = {
		type = "fixed",
		fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, 1 / 16, 4 / 16},
	}
})

minetest.register_node("underch:dark_tuber", {
	description = "Dark Tuber",
	tiles = {"underch_dark_tuber.png"},
	drawtype = "mesh",
	mesh = "underch_dark_tuber.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	groups = {snappy = 3, attached_node = 1},
	sounds = default.node_sound_leaves_defaults(),
	on_use = minetest.item_eat(2),
})

