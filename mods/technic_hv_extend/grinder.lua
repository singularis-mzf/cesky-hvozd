-- HV grinder

minetest.register_craft({
	output = 'technic_hv_extend:hv_grinder',
	recipe = {
		{'technic:carbon_plate',          'technic:mv_grinder',   'technic:composite_plate'},
		{'pipeworks:tube_1',              'technic:hv_transformer', 'pipeworks:tube_1'},
		{'technic:stainless_steel_ingot', 'technic:hv_cable',       'technic:stainless_steel_ingot'},
	}
})

technic.register_grinder({tier="HV", demand={700, 500, 320}, speed=3, upgrade=1, tube=1, modname="technic_hv_extend"})
