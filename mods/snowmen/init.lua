ch_base.open_mod(minetest.get_current_modname())
-- snowman node

local off = 0.25 -- Y offset so we can scale to 2x

minetest.register_node("snowmen:snowman", {
	description = "velký sněhulák",
	drawtype = "nodebox",
	tiles = {
		"snowmen_top.png", "snowmen_bottom.png", "snowmen_right.png",
		"snowmen_left.png", "snowmen_back.png", "snowmen_front.png"
	},
	inventory_image = "snowmen_inv.png",
	paramtype = "light",
	paramtype2 = "4dir",
	use_texture_alpha = "clip",
	visual_scale = 2.0,
	is_ground_content = false,
	drop = {
        items = {
            {
                items = {"default:snow", "default:stick 2"},
            },
        },
    },
	groups = {crumbly = 3, cools_lava = 1, snowy = 1},
	sounds = default.node_sound_snow_defaults(),

	on_construct = function(pos)

		pos.y = pos.y - 1

		if minetest.get_node(pos).name == "default:dirt_with_grass" then
			minetest.set_node(pos, {name = "default:dirt_with_snow"})
		end
	end,

	node_box = {
		type = "fixed",
		fixed = {
			{-4/16, off + -8/16, -4/16, 4/16, off + 2/16, 4/16}, -- bottom
			{-3/16, off + 2/16, -3/16, 3/16, off + 8/16, 3/16}, -- head
			{-8/16, off + -8/16, 0.0, 8/16, off + 3/16, 0.0} -- hands overlay
		}
	},

	selection_box ={
		{-5/16, off + -8/16, -5/16 , -5/16, off + 8/16, 5/16}
	}
})

-- snowman recipe

core.register_craft({
	output = "snowmen:snowman",
	recipe = {
		{"default:stick", "christmas_decor:snowman", "default:stick"},
		{"", "default:snowblock", ""},
		{"", "", ""},
	}
})
ch_base.close_mod(minetest.get_current_modname())
