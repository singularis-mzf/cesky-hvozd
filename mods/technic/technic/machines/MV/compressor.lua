-- MV compressor

minetest.register_craft({
	output = 'technic:mv_compressor',
	recipe = {
		{'default:stone',            'basic_materials:motor',          'default:stone'},
		{'mesecons_pistons:piston_normal_off', 'technic:machine_casing', 'mesecons_pistons:piston_normal_off'},
		{'basic_materials:silver_wire', 'technic:lv_cable',       'basic_materials:silver_wire'},
	},
	replacements = {
		{"basic_materials:silver_wire", "basic_materials:empty_spool"},
		{"basic_materials:silver_wire", "basic_materials:empty_spool"}
	},
})

technic.register_compressor({tier = "MV", demand = {800, 600, 400}, speed = 2, upgrade = 1, tube = 1})
