local function override_homedecor_oven(hd_base_name, data)
	local hd_oven_def = minetest.registered_nodes[hd_base_name]
	local hd_oven_active_def = minetest.registered_nodes[hd_base_name.."_active"]
	local data2 = table.copy(data)

	data2.def_override = {
		drawtype = hd_oven_def.drawtype,
		tiles = hd_oven_def.tiles,
		use_texture_alpha = hd_oven_def.use_texture_alpha,
		node_box = hd_oven_def.node_box,
		sounds = hd_oven_def.sounds,
	}
	data2.def_override_active = {
		drawtype = hd_oven_active_def.drawtype,
		tiles = hd_oven_active_def.tiles,
		use_texture_alpha = hd_oven_active_def.use_texture_alpha,
		node_box = hd_oven_active_def.node_box,
		sounds = hd_oven_active_def.sounds,
	}
	technic.register_base_machine(data2)

	minetest.unregister_item(hd_base_name)
	minetest.unregister_item(hd_base_name.."_active")
	minetest.unregister_item(hd_base_name.."_locked")
	minetest.unregister_item(hd_base_name.."_active_locked")
	return true
end

local def = {
	typename = "cooking",
	modname = "ch_overrides",
	tier = "LV",
	demand = {300},
	speed = 2,
}

def.machine_name = "microwave_oven"
def.machine_desc = "NN Mikrovlnná trouba"
override_homedecor_oven("homedecor:microwave_oven", def)

def.machine_name = "oven_white"
def.machine_desc = "NN sporák (bílý)"
override_homedecor_oven("homedecor:oven", def)

def.machine_name = "oven_steel"
def.machine_desc = "NN sporák (nerezový)"
override_homedecor_oven("homedecor:oven_steel", def)
