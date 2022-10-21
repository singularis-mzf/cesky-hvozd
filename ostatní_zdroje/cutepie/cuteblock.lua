minetest.register_node("cutepie:cute_block", {
	description = "Cutepie Block",
	drawtype = "normal",
	tiles = {
		"cute_block_tb.png",
		"cute_block_tb.png",
		"cute_block_frown.png",
		"cute_block_frown.png",
		"cute_block_frown.png",
		"cute_block_frown.png"
		},
	paramtype = "light",
  	paramtype2 = "facedir",
	groups = {cracky = 2 , oddly_breakable_by_hand = 1},
	on_punch = function(pos, node, player, pointed_thing)
		minetest.set_node(pos,{name = "cutepie:cute_block_light", param2 = node.param2})
	end,
})

minetest.register_node("cutepie:cute_block_light", {
	drawtype = "normal",
	tiles = {
		"cute_block_tb.png",
		"cute_block_tb.png",
		"cute_block.png",
		"cute_block.png",
		"cute_block.png",
		"cute_block.png"
		},
	paramtype = "light",
  	paramtype2 = "facedir",
	light_source = 14,
	groups = {cracky = 2 , oddly_breakable_by_hand = 1},
	drop = "cutepie:cute_block",
	on_punch = function(pos, node, player, pointed_thing)
		minetest.set_node(pos,{name = "cutepie:cute_block", param2 = node.param2})
	end,
})

minetest.register_node("cutepie:cute_block2", {
	description = "Cutepie Block 2",
	drawtype = "normal",
	tiles = {"cute_block2_tb.png","cute_block2_tb.png","cute_block2_frown.png","cute_block2_frown.png","cute_block2_frown.png","cute_block2_frown.png"},
	paramtype = "light",
  	paramtype2 = "facedir",
	groups = {cracky = 2 , oddly_breakable_by_hand = 1},
	on_punch = function(pos, node, player, pointed_thing)
		minetest.set_node(pos,{name = "cutepie:cute_block_light2", param2 = node.param2})
	end,
})

minetest.register_node("cutepie:cute_block_light2", {
	drawtype = "normal",
	tiles = {"cute_block2_tb.png","cute_block2_tb.png","cute_block2.png","cute_block2.png","cute_block2.png","cute_block2.png"},
	paramtype = "light",
  	paramtype2 = "facedir",
	light_source = 14,
	groups = {cracky = 2 , oddly_breakable_by_hand = 1},
	drop = "cutepie:cute_block2",
	on_punch = function(pos, node, player, pointed_thing)
		minetest.set_node(pos,{name = "cutepie:cute_block2", param2 = node.param2})
	end,
})
