local ch_help = "roztomilé světlo\numístěte a rozsviťte je levým klikem"
local ch_help_group = "cutelight"

minetest.register_node(":cutepie:cute_block", {
	description = "roztomilé světlo (žluté)",
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
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
})

minetest.register_node(":cutepie:cute_block_light", {
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

minetest.register_node(":cutepie:cute_block2", {
	description = "roztomilé světlo (fialové)",
	drawtype = "normal",
	tiles = {"cute_block2_tb.png","cute_block2_tb.png","cute_block2_frown.png","cute_block2_frown.png","cute_block2_frown.png","cute_block2_frown.png"},
	paramtype = "light",
  	paramtype2 = "facedir",
	groups = {cracky = 2 , oddly_breakable_by_hand = 1},
	on_punch = function(pos, node, player, pointed_thing)
		minetest.set_node(pos,{name = "cutepie:cute_block_light2", param2 = node.param2})
	end,
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
})

minetest.register_node(":cutepie:cute_block_light2", {
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

minetest.register_craft({
	output = "cutepie:cute_block",
	recipe = {
		{"dye:black", ""},
		{"mesecons_lightstone:lightstone_yellow_off", "mesecons_button:button_off"},
	},
})


minetest.register_craft({
	output = "cutepie:cute_block2",
	recipe = {
		{"dye:black", ""},
		{"mesecons_lightstone:lightstone_magenta_off", "mesecons_button:button_off"},
	},
})
