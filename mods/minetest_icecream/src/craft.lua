--Crafting IceCream

--Dough
minetest.register_craft({
	output = "icecream:dough",
	recipe = {
		{"","",""},
		{"farming:flour","","farming:flour"},
		{"","group:food_egg",""},
	}
})
--Dough Cone
minetest.register_craft({
	output = "icecream:notcone 5",
	recipe = {
		{"icecream:dough"},
	}
})
minetest.register_craft({
	type  =  "cooking",
	recipe  = "icecream:notcone",
	output = "icecream:cone",
})
--apple icecream
minetest.register_craft({
	output = "icecream:apple",
	recipe = {
		{"default:snow"},
		{"default:apple"},
		{"icecream:cone"},
	}
})
--banana icecream
minetest.register_craft({
	output = "icecream:banana",
	recipe = {
		{"default:snow"},
		{"ethereal:banana"},
		{"icecream:cone"},
	}
})
--carrot icecream
minetest.register_craft({
	output = "icecream:carrot",
	recipe = {
		{"default:snow"},
		{"farming:carrot"},
		{"icecream:cone"},
	}
})
--chocolate icecream
minetest.register_craft({
	output = "icecream:chocolate",
	recipe = {
		{"default:snow"},
		{"farming:chocolate_dark"},
		{"icecream:cone"},
	}
})
--chocolate with cookies icecream
minetest.register_craft({
	output = "icecream:chocolate_with_cookies",
	recipe = {
		{"farming:cookie"},
		{"icecream:chocolate"},
	}
})

--vanilla with cookies icecream
minetest.register_craft({
	output = "icecream:vanilla_with_cookies",
	recipe = {
		{"farming:cookie"},
		{"icecream:vanilla"},
	}
})

--Watermelon icecream
minetest.register_craft({
	output = "icecream:watermelon",
	recipe = {
		{"default:snow"},
		{"farming:melon_slice"},
		{"icecream:cone"},
	}
})
--orange icecream
minetest.register_craft({
	output = "icecream:orange",
	recipe = {
		{"default:snow"},
		{"ethereal:orange"},
		{"icecream:cone"},
	}
})
--pineapple icecream
minetest.register_craft({
	output = "icecream:pineapple",
	recipe = {
		{"default:snow"},
		{"farming:pineapple"},
		{"icecream:cone"},
	}
})
--Vanilla icecream
minetest.register_craft({
	output = "icecream:vanilla",
	recipe = {
		{"default:snow"},
		{"farming:vanilla"},
		{"icecream:cone"},
	}
})
--Pumpkin icecream
minetest.register_craft({
	output = "icecream:pumpkin",
	recipe = {
		{"default:snow"},
		{"farming:pumpkin_slice"},
		{"icecream:cone"},
	}
})
--Mint icecream
minetest.register_craft({
	output = "icecream:mint",
	recipe = {
		{"default:snow"},
		{"farming:mint_leaf"},
		{"icecream:cone"},
	}
})
--Blueberries icecream
minetest.register_craft({
	output = "icecream:blueberries",
	recipe = {
		{"default:snow"},
		{"default:blueberries"},
		{"icecream:cone"},
	}
})
--Strawberry icecream
minetest.register_craft({
	output = "icecream:strawberry",
	recipe = {
		{"default:snow"},
		{"ethereal:strawberry"},
		{"icecream:cone"},
	}
})
