local hd_mw_oven_def = minetest.registered_nodes["homedecor:microwave_oven"]
local hd_mw_oven_active_def = minetest.registered_nodes["homedecor:microwave_oven_active"]

local data = {
	typename = "cooking",
	machine_name = "microwave_oven",
	modname = "ch_overrides",
	machine_desc = "NN Mikrovlnná trouba",
	tier = "LV",
	demand = {300},
	speed = 2,
	def_override = {
		drawtype = hd_mw_oven_def.drawtype,
		tiles = hd_mw_oven_def.tiles,
		use_texture_alpha = hd_mw_oven_def.use_texture_alpha,
		node_box = hd_mw_oven_def.node_box,
		sounds = hd_mw_oven_def.sounds,
	},
	def_override_active = {
		drawtype = hd_mw_oven_active_def.drawtype,
		tiles = hd_mw_oven_active_def.tiles,
		use_texture_alpha = hd_mw_oven_active_def.use_texture_alpha,
		node_box = hd_mw_oven_active_def.node_box,
		sounds = hd_mw_oven_active_def.sounds,
	},
}
technic.register_base_machine(data)
minetest.unregister_item("homedecor:microwave_oven")
minetest.unregister_item("homedecor:microwave_oven_active")
minetest.unregister_item("homedecor:microwave_oven_locked")
minetest.unregister_item("homedecor:microwave_oven_locked_active")
