local depends, default_sounds = ...
local S = minetest.get_translator("christmas_decor")

minetest.register_node("christmas_decor:icicles_wall", {
	description = S("Icicles (wall)"),
	tiles = {
		{
			name = "christmas_decor_icicles.png",
			backface_culling = false,
		}
	},
	inventory_image = "christmas_decor_icicles_inv.png",
	sunlight_propagates = true,
	walkable = false,
	climbable = false,
	is_ground_content = false,
	selection_box = {
		type = "wallmounted",
	},
	legacy_wallmounted = true,
	use_texture_alpha = "clip",
	drawtype = "signlike",
	paramtype = "light",
	light_source = 3,
	paramtype2 = "wallmounted",
	groups = {snappy = 3},
	sounds = default_sounds("node_sound_glass_defaults"),
})

if depends.default then
	minetest.register_craft({
		output = "christmas_decor:icicles_wall 4",
		recipe = {
			{"default:ice", "", "default:ice"},
			{"default:ice", "", "default:ice"},
		},
	})
end

--[[
if depends.homedecor_exterior then
	minetest.register_node("christmas_decor:christmas_shrubbery_large", {
		description = "Christmas Shrubbery (large)",
		drawtype = "mesh",
		mesh = "homedecor_cube.obj",
		tiles = {
			{
				name = "christmas_decor_shrubbery.png",
				backface_culling = false,
				animation = {
					type = "vertical_frames",
					aspect_w = 8,
					aspect_h = 8,
					length = 3
				},
			}
		},
		paramtype = "light",
		light_source = 8,
		is_ground_content = false,
		groups = {snappy = 3},
		sounds = default_sounds("node_sound_leaves_defaults"),
	})

	minetest.register_node("christmas_decor:christmas_shrubbery", {
		description = "Christmas Shrubbery",
		drawtype = "mesh",
		mesh = "homedecor_shrubbery.obj",
		tiles = {
			{
				name = "christmas_decor_shrubbery.png",
				backface_culling = false,
				animation = {
					type = "vertical_frames",
					aspect_w = 8,
					aspect_h = 8,
					length = 3
				},
			},
			"homedecor_shrubbery_green_bottom.png",
			"homedecor_shrubbery_roots.png"
		},
		paramtype = "light",
		light_source = 8,
		is_ground_content = false,
		groups = {snappy = 3},
		sounds = default_sounds("node_sound_leaves_defaults"),
		selection_box = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
		collision_box = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
	})

	minetest.register_craft({
		output = "christmas_decor:christmas_shrubbery",
		type = "shapeless",
		recipe = {"homedecor:shrubbery_green", "christmas_decor:lights_multicolor"},
	})

	minetest.register_craft({
		output = "christmas_decor:christmas_shrubbery_large",
		type = "shapeless",
		recipe = {"homedecor:shrubbery_large_green", "christmas_decor:lights_multicolor"},
	})

	minetest.register_craft({
		output = "christmas_decor:christmas_shrubbery",
		type = "shapeless",
		recipe = {"christmas_decor:christmas_shrubbery_large"},
	})

	minetest.register_craft({
		output = "christmas_decor:christmas_shrubbery_large",
		type = "shapeless",
		recipe = {"christmas_decor:christmas_shrubbery"},
	})

end
]]

minetest.register_node("christmas_decor:nutcracker", {
	description = S("Nutcracker"),
	drawtype = "mesh",
	mesh = "christmas_decor_nutcracker.obj",
	tiles = {"christmas_decor_nutcracker.png"},
	use_texture_alpha = "clip",
	inventory_image = "christmas_decor_nutcracker_inv.png",
	walkable = true,
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, 0.4, 0.2},
	},
	collision_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, 0.4, 0.2},
	},
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {snappy = 3},
	sounds = default_sounds("node_sound_wood_defaults"),
})

if depends.dye and depends.default then
	minetest.register_craft({
		output = "christmas_decor:nutcracker",
		recipe = {
			{"dye:yellow", "dye:black", "dye:yellow"},
			{"dye:red", "default:wood", "dye:red"},
			{"dye:blue", "dye:black", "dye:blue"},
		}
	})
end

minetest.register_node("christmas_decor:snowman", {
	description = S("Snowman"),
	drawtype = "mesh",
	mesh = "christmas_decor_snowman.obj",
	tiles = {"christmas_decor_snowman.png"},
	use_texture_alpha = "blend",
	inventory_image = "christmas_decor_snowman_inv.png",
	walkable = true,
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 1.2, 0.5},
	},
	collision_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 1.2, 0.5},
	},
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "colordegrotate",
	palette = "christmas_decor_snowman_palette.png",
	groups = {snappy = 3},
	sounds = default_sounds("node_sound_leaves_defaults"),
	on_place = function(itemstack, placer, pointed_thing)
		local param2 = math.random(0, 7) * 32 + math.random(0, 23)
		return core.item_place_node(itemstack, placer, pointed_thing, param2)
	end,
})

if depends.default then
	minetest.register_craft({
		output = "christmas_decor:snowman",
		recipe = {
			{"default:coal_lump", "default:snowblock", "default:coal_lump"},
			{"default:coal_lump", "default:snowblock", "default:coal_lump"},
			{"", "default:snowblock", ""},
		},
	})
end
