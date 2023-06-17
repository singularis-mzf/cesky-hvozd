minetest.register_node("ch_decor:ivoire", {
	tiles = {
		"[combine:64x64:0,0=ephesus_ivoire.png:0,32=ephesus_ivoire.png:32,0=ephesus_ivoire.png:32,32=ephesus_ivoire.png^[noalpha"
	},
	groups = {cracky = 2},
	paramtype = "light",
	paramtype2 = "facedir",
	description = "slonovina",
	sounds = default and default.node_sound_stone_defaults(),
	_ch_help = "slonovina je vzácný materiál, který nelze uměle vyrobit",
})

--[[
minetest.register_craft({
	output = "ch_decor:ivoire",
	recipe = {
		{"", "", ""},
		{"", "", ""},
		{"", "", ""},
	}
})
]]
