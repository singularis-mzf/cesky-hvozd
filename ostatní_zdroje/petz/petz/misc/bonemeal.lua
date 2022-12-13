--Bonemeal support

minetest.register_craft({
	type = "shapeless",
	output = "petz:bone 2",
	recipe = {"bonemeal:bone","bonemeal:bone"},
})

minetest.register_craft({
	type = "shapeless",
	output = "bonemeal:bone 2",
	recipe = {"petz:bone", "petz:bone"},
})

minetest.register_craft({
	type = "shapeless",
	output = "bonemeal:mulch",
	recipe = {"petz:poop"},
})
