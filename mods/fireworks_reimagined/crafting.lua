-- Only 0 delay can be crafted.
minetest.register_craft({
	output = "fireworks_reimagined:firework_ring",
	recipe = {
		{"default:stick", "dye:red", "default:stick"},
		{"dye:red", "tnt:tnt", "dye:red"},
		{"default:stick", "dye:red", "default:stick"}
	},
})
minetest.register_craft({
	output = "fireworks_reimagined:firework_sphere",
	recipe = {
		{"default:stick", "dye:orange", "default:stick"},
		{"dye:red", "tnt:tnt", "dye:red"},
		{"default:stick", "dye:orange", "default:stick"}
	},
})
minetest.register_craft({
	output = "fireworks_reimagined:firework_2025",
	recipe = {
		{"default:stick", "dye:yellow", "default:stick"},
		{"dye:yellow", "tnt:tnt", "dye:yellow"},
		{"default:stick", "dye:yellow", "default:stick"}
	},
})
minetest.register_craft({
	output = "fireworks_reimagined:firework_multi 5",
	recipe = {
		{"fireworks_reimagined:firework_red", "fireworks_reimagined:firework_orange", "fireworks_reimagined:firework_yellow"},
		{"tnt:tnt", "fireworks_reimagined:firework_white", "tnt:tnt"},
		{"fireworks_reimagined:firework_green", "fireworks_reimagined:firework_blue", "fireworks_reimagined:firework_violet"}
	},
})
