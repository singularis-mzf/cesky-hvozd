-- Code cut from Your Dad's BBQ Mod
-- (c) Grizzly Adam
-- (c) Singularis — slight modifications (names and properties changed)
-- LGPLv2.1+

-- Chimeny Smoke
minetest.register_node("bbq_smoke:chimney_smoke", {
	description = "Permantentní kouř",
	inventory_image = "bbq_chimney_smoke.png",
	wield_image = "bbq_chimney_smoke.png",
	drawtype = "plantlike",
	paramtype = "light",
	paramtype2 = "facedir",
	buildable_to = true,
	floodable = true,
	sunlight_propagates = true,
	tiles = {
		{
			image = "bbq_chimney_smoke_animation.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.5
			},
		},
	},
	groups = {dig_immediate = 3,
              --attached_node = 1
	},
})

--Chimeny Smoke Craft Recipe
minetest.register_craft( {
	output = "bbq_smoke:chimney_smoke",
	recipe = {
		{"", "group:wood", ""},
		{"", "group:wood", ""},
		{"", "default:torch", ""}
	}
})
