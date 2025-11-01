ch_base.open_mod(minetest.get_current_modname())
-- snowman node

local off = 0.25 -- Y offset so we can scale to 2x
local box_scale = 1.75

local snowman_box = {
	type = "fixed",
	fixed = {
		box_scale*(-5/16), 2 * (off + -8/16), box_scale*(-5/16),
		box_scale*(5/16), 2*(off + 8/16), box_scale*(5/16)
	},
}

minetest.register_node("snowmen:snowman", {
	description = "velký sněhulák",
	drawtype = "mesh",
	mesh = "snowmen.obj",
	tiles = {
		{name = "snowmen_top.png", backface_culling = true},
		{name = "snowmen_bottom.png", backface_culling = true},
		{name = "snowmen_right.png", backface_culling = true},
		{name = "snowmen_left.png", backface_culling = true},
		{name = "snowmen_back.png", backface_culling = true},
		{name = "snowmen_front.png", backface_culling = true},
	},
	inventory_image = "snowmen_inv.png",
	paramtype = "light",
	paramtype2 = "colordegrotate",
	palette = "christmas_decor_snowman_palette.png",
	use_texture_alpha = "clip",
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
	selection_box = snowman_box,
	collision_box = snowman_box,

	on_construct = function(pos)

		pos.y = pos.y - 1

		if minetest.get_node(pos).name == "default:dirt_with_grass" then
			minetest.set_node(pos, {name = "default:dirt_with_snow"})
		end
	end,
	on_place = function(itemstack, placer, pointed_thing)
		local param2 = math.random(0, 7) * 32 + math.random(0, 23)
		return core.item_place_node(itemstack, placer, pointed_thing, param2)
	end,
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
