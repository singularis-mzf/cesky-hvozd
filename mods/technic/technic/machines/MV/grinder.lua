-- MV grinder

minetest.register_craft({
	output = 'technic:mv_grinder',
	recipe = {
		{'default:desert_stone', 'default:diamond',        'default:desert_stone'},
		{'default:desert_stone', 'technic:machine_casing', 'default:desert_stone'},
		{'technic:granite',      'technic:lv_cable',       'technic:granite'},
	}
})

technic.register_grinder({tier="MV", demand={600, 450, 300}, speed=2, upgrade=1, tube=1})

