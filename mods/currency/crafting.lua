minetest.register_craft({
	output = "currency:safe",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:mese_crystal", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
	}
})

minetest.register_craft({
	output = "currency:barter",
	recipe = {
		{"default:sign_wall"},
		{"default:chest"},
	}
})
