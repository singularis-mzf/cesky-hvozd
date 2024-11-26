-- MV extractor

minetest.register_craft({
	output = 'technic:mv_extractor',
	recipe = {
		{'technic:treetap', 'basic_materials:motor',          'technic:treetap'},
		{'technic:treetap', 'technic:machine_casing', 'technic:treetap'},
		{'',                'technic:lv_cable',       ''},
	}
})

technic.register_extractor({tier = "MV", demand = {800, 600, 400}, speed = 2, upgrade = 1, tube = 1})
