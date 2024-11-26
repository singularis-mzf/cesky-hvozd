-- MV alloy furnace

minetest.register_craft({
	output = 'technic:mv_alloy_furnace',
	recipe = {
		{'default:brick', 'default:brick',          'default:brick'},
		{'default:brick', 'technic:machine_casing', 'default:brick'},
		{'default:brick', 'technic:lv_cable',       'default:brick'},
	}
})


technic.register_alloy_furnace({tier = "MV", speed = 1.5, upgrade = 1, tube = 1, demand = {3000, 2000, 1000}})

