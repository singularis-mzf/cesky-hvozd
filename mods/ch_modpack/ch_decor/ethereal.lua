minetest.register_node(":ethereal:bamboo", {
	description = "stonek bambusu",
	drawtype = "nodebox",
	tiles = {"ch_decor_bamboo.png"},
	groups = {choppy = 3, flammable = 2, oddly_breakable_by_hand = 2},
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 2,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {{-0.1,-0.5,-0.1,0.1,0.5,0.1}},
	},
	selection_box = {
		type = "fixed",
		fixed = {{-0.1,-0.5,-0.1,0.1,0.5,0.1}},
	},
	sounds = default and default.node_sound_leaves_defaults(),
	after_dig_node = function(pos, node, metadata, digger)
		default.dig_up(pos, node, digger)
	end,
})
