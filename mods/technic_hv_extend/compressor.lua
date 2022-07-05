-- HV compressor

minetest.register_craft({
	output = 'technic_hv_extend:hv_compressor',
	recipe = {
		{'technic:carbon_plate',          'technic:mv_compressor',   'technic:composite_plate'},
		{'pipeworks:tube_1',              'technic:hv_transformer', 'pipeworks:tube_1'},
		{'technic:stainless_steel_ingot', 'technic:hv_cable',       'technic:stainless_steel_ingot'},
	}
})

technic.register_compressor({tier = "HV", demand = {1500, 1000, 750}, speed = 6, upgrade = 1, tube = 1, modname="technic_hv_extend"})
