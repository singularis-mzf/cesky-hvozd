-- ch_extras:shaft
---------------------------------------------------------------
local def = {
	description = "dřík kamenného sloupu",
	tiles = {
		{name = "ch_extras_shaft_top.png"},
		{name = "ch_extras_shaft_top.png"},
		{name = "ch_extras_shaft.png"},
	},
	paramtype2 = "colorwallmounted",
	palette = "unifieddyes_palette_colorwallmounted.png",
	groups = {cracky = 3, ud_param2_colorable = 1},
	is_ground_content = false,
	on_construct = unifieddyes.on_construct,
	on_dig = unifieddyes.on_dig,
}

minetest.register_node("ch_extras:shaft", def)

minetest.register_craft({
	output = "ch_extras:shaft 2",
	recipe = {
		{"pillars:stone", ""},
		{"pillars:stone", ""},
	}
})
