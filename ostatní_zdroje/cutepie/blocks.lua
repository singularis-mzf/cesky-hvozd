local cute_blocks = {
	{"cutepie:cute_cobble","Cutepie Cobble","cute_cobble.png"},
	{"cutepie:cute_purple_tile","Cutepie Purple Tile","cute_purple_tile.png"},
	{"cutepie:cute_blocks","Cutepie Beans",{name="cute_blocks_ani.png", animation={type="vertical_frames",
											aspect_w=16, aspect_h=16, length=0.8}},},
	{"cutepie:cute_rainbow","Cutepie Rainbow",{name="cute_rainbow.png", animation={type="vertical_frames",
											aspect_w=16, aspect_h=16, length=0.8}},
		}
	}
	for i in ipairs(cute_blocks) do
		local itm = cute_blocks[i][1]
		local des = cute_blocks[i][2]
		local img = cute_blocks[i][3]

minetest.register_node(itm, {
	description = des,
	drawtype = "normal",
	tiles = {img},
	paramtype = "light",
	groups = {cracky = 2},

})

end

--Cute Cane

minetest.register_node("cutepie:cute_cane", {
	description = "Cutepie Cane",
	tiles = {"cute_cane.png"},
	drawtype = "nodebox",
	paramtype = "light",
	groups = {cracky = 2 , oddly_breakable_by_hand = 1},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.25, -0.5, -0.1875, 0.25, 0.5, 0.1875},
			{-0.1875, -0.5, -0.25, 0.1875, 0.5, 0.25},
			{-0.125, -0.5, -0.3125, 0.125, 0.5, 0.3125},
			{-0.3125, -0.5, -0.125, 0.3125, 0.5, 0.125},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.25, -0.5, -0.1875, 0.25, 0.5, 0.1875}, 
			{-0.1875, -0.5, -0.25, 0.1875, 0.5, 0.25},
			{-0.125, -0.5, -0.3125, 0.125, 0.5, 0.3125}, 
			{-0.3125, -0.5, -0.125, 0.3125, 0.5, 0.125},
		}
	}
})

--cute light

minetest.register_node("cutepie:cute_light", {
	description = "Cutepie Light",
	tiles = {
		"cute_yellow.png",
		"cute_yellow.png",
		"cute_yellow.png",
		"cute_yellow.png",
		"cute_smile.png",
		"cute_smile.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky = 2, snappy=2 , oddly_breakable_by_hand = 1},
	sunlight_propagates = true,
	light_source = 14,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.1875, 0.375, 0.5, 0.1875, 0.5},
			{-0.1875, -0.5, 0.375, 0.1875, 0.5, 0.5},
			{-0.4375, -0.3125, 0.375, 0.4375, 0.3125, 0.5},
			{-0.3125, -0.4375, 0.375, 0.3125, 0.4375, 0.5},
		}
	}
})
