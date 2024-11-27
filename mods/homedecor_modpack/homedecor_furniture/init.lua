ch_base.open_mod(minetest.get_current_modname())
local S = minetest.get_translator("homedecor_furniture")


local ob_cbox = {
	type = "fixed",
	fixed = { -0.5, -0.5, 0, 0.5, 0.5, 0.5 }
}

local wood_tex = homedecor.textures.default_wood

homedecor.register("openframe_bookshelf", {
	description = S("Bookshelf (open-frame)"),
	drawtype = "mesh",
	mesh = "homedecor_openframe_bookshelf.obj",
	tiles = {
		"homedecor_openframe_bookshelf_books.png",
		wood_tex
	},
	groups = {choppy=3,oddly_breakable_by_hand=2,flammable=3},
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	paramtype2 = "facedir",
	selection_box = ob_cbox,
	collision_box = ob_cbox,
	crafts = {
		{
			recipe = {
				{"group:wood", "", "group:wood"},
				{"book", "book", "book"},
				{"group:wood", "", "group:wood"},
			},
		}
	}
})

homedecor.register("wall_shelf", {
	description = S("Wall Shelf"),
	tiles = {
		wood_tex,
	},
	groups = { snappy = 3, dig_tree = 2 },
	sounds = default.node_sound_wood_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.4, 0.47, 0.5, 0.47, 0.5},
			{-0.5, 0.47, -0.1875, 0.5, 0.5, 0.5}
		}
	}
})

ch_base.close_mod(minetest.get_current_modname())
