-- extra recipes
minetest.register_craft({
	output = "default:permafrost",
	recipe = {
		{"default:ice", "", ""},
		{"default:dirt", "", ""},
		{"", "", ""},
}})

minetest.register_craft({
	output = "default:permafrost_with_moss",
	recipe = {
		{"default:mossycobble", "", ""},
		{"default:permafrost", "", ""},
		{"", "", ""},
}})

minetest.register_craft({
	output = "default:permafrost_with_stones",
	recipe = {
		{"default:cobble", "", ""},
		{"default:permafrost", "", ""},
		{"", "", ""},
}})

minetest.register_craft({
	output = "default:dirt_with_coniferous_litter",
	recipe = {
		{"default:pine_needles", "", ""},
		{"default:dirt", "", ""},
		{"", "", ""},
}})

minetest.register_craft({
	output = "default:dirt_with_dry_grass",
	recipe = {
		{"default:dry_grass_1", "", ""},
		{"default:dirt", "", ""},
		{"", "", ""},
}})

minetest.register_craft({
	output = "default:dirt_with_rainforest_litter",
	recipe = {
		{"default:jungleleaves", "", ""},
		{"default:dirt", "", ""},
		{"", "", ""},
}})

minetest.register_craft({
	output = "default:dirt_with_snow",
	recipe = {
		{"default:snow", "", ""},
		{"default:dirt", "", ""},
		{"", "", ""},
}})

minetest.register_craft({
	output = "default:dry_dirt",
	type = "cooking",
	recipe = "default:dirt",
})

minetest.register_craft({
	output = "default:dry_dirt_with_dry_grass",
	recipe = {
		{"default:dry_grass_1", "", ""},
		{"default:dry_dirt", "", ""},
		{"", "", ""},
}})

if minetest.get_modpath("fireflies") and minetest.get_modpath("vessels") then
	minetest.register_craft( {
		output = "fireflies:firefly",
		recipe = {
			{"fireflies:firefly_bottle"},
		},
		replacements = {{"fireflies:firefly_bottle", "vessels:glass_bottle"}},
	})
end

if minetest.get_modpath("jonez") and minetest.get_modpath("technic_worldgen") and minetest.get_modpath("darkage") then
	minetest.register_craft({
		output = "jonez:marble",
		type = "shapeless",
		recipe = {"darkage:marble", "technic:marble"},
		replacements = {{"darkage:marble", "technic:stone_dust"}},
	})
end

if minetest.get_modpath("cottages") then
	minetest.register_craft({
		output = "cottages:red 4",
		recipe = {
			{"", "homedecor:roof_tile_terracotta", ""},
			{"homedecor:roof_tile_terracotta", "default:pine_wood", "homedecor:roof_tile_terracotta"},
			{"", "", ""},
		},
	})

	minetest.register_craft({
		output = "cottages:brown 4",
		recipe = {
			{"", "homedecor:roof_tile_terracotta", ""},
			{"homedecor:roof_tile_terracotta", "default:junglewood", "homedecor:roof_tile_terracotta"},
			{"", "", ""},
		},
	})

	minetest.register_craft({
		output = "cottages:black 4",
		recipe = {
			{"", "building_blocks:Tar", ""},
			{"building_blocks:Tar", "", "building_blocks:Tar"},
			{"", "", ""},
		},
	})
end

if minetest.get_modpath("technic") then
	minetest.register_craft({
		output = "technic:cast_iron_block",
		type = "cooking",
		cooktime = 10,
		recipe = "default:steelblock",
	})

	minetest.register_craft({
		output = "default:steelblock",
		type = "cooking",
		cooktime = 20,
		recipe = "technic:cast_iron_block",
	})

	technic.register_alloy_recipe({input = {"default:steelblock", "technic:coal_dust 5"}, output = "technic:carbon_steel_block", time = 50})
	technic.register_alloy_recipe({input = {"technic:carbon_steel_block", "technic:coal_dust 5"}, output = "technic:cast_iron_block", time = 50})
	technic.register_alloy_recipe({input = {"default:copperblock 7", "default:tinblock"}, output = "default:bronzeblock 8", time = 120})
	technic.register_alloy_recipe({input = {"technic:carbon_steel_block 4", "technic:chromium_block"}, output = "technic:stainless_steel_block 5", time = 75})
	technic.register_alloy_recipe({input = {"default:copperblock 2", "technic:zinc_block"}, output = "basic_materials:brass_block 3", time = 10})
end
