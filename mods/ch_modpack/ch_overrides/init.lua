print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local modpath = minetest.get_modpath("ch_overrides")

-- homedecor_kitchen
if minetest.get_modpath("homedecor_kitchen") then

	local function override_homedecor_oven(hd_base_name, data, recipe)
		if minetest.get_modpath("technic") then
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
		end

		minetest.clear_craft({output = hd_base_name})
		minetest.clear_craft({output = hd_base_name.."_locked"})

		minetest.unregister_item(hd_base_name)
		minetest.unregister_item(hd_base_name.."_active")
		minetest.unregister_item(hd_base_name.."_locked")
		minetest.unregister_item(hd_base_name.."_active_locked")

		if recipe then
			minetest.register_craft({output = "ch_overrides:lv_"..data.machine_name, recipe = recipe})
		end
		return true
	end

	local def = {
		typename = "cooking",
		modname = "ch_overrides",
		tier = "LV",
		demand = {300},
		speed = 2,
	}
	local recipe

	def.machine_name = "microwave_oven"
	def.machine_desc = "NN Mikrovlnná trouba"
	recipe = {
		{ "default:steel_ingot", "default:steel_ingot" , "default:steel_ingot", },
		{ "default:steel_ingot", "default:glass", "basic_materials:ic", },
		{ "default:steel_ingot", "basic_materials:energy_crystal_simple", "" },
	}
	override_homedecor_oven("homedecor:microwave_oven", def, recipe)

	def.machine_name = "oven_white"
	def.machine_desc = "NN sporák (bílý)"
	recipe = {
		{"ch_overrides:lv_oven_steel", "", ""},
		{"dye:white", "", ""},
		{"dye:white", "", ""},
	}
	override_homedecor_oven("homedecor:oven", def, recipe)

	def.machine_name = "oven_steel"
	def.machine_desc = "NN sporák (nerezový)"
	recipe = {
		{ "basic_materials:heating_element", "default:steel_ingot" , "basic_materials:heating_element", },
		{ "default:steel_ingot", "default:glass", "default:steel_ingot", },
		{ "default:steel_ingot", "basic_materials:heating_element", "default:steel_ingot", }
	}
	override_homedecor_oven("homedecor:oven_steel", def, recipe)
end -- homedecor_kitchen

-- moreblocks + technic
if minetest.get_modpath("moreblocks") and minetest.get_modpath("technic") then
	stairsplus:register_all("technic", "warning_block", "technic:warning_block", {
		description = "varovný blok",
		tiles = {"technic_hv_cable.png"},
		groups = {cracky = 1},
		sounds = default.node_sound_wood_defaults(),
	})
end

if minetest.get_modpath("farming") and minetest.get_modpath("technic_cnc") then
	minetest.override_item("farming:melon_8", {
		drawtype = "mesh",
		mesh = "technic_cnc_oblate_spheroid.obj",
		tiles = {name = "farming_melon_side.png", backface_culling = true},
		paramtype2 = "facedir",
	})
	minetest.override_item("farming:pumpkin_8", {
		drawtype = "mesh",
		mesh = "technic_cnc_oblate_spheroid.obj",
		tiles = {name = "farming_pumpkin_side.png", backface_culling = true},
		paramtype2 = "facedir",
	})
end

-- screwdriver
if minetest.get_modpath("screwdriver") then
	minetest.override_item("screwdriver:screwdriver", {_ch_help = "Slouží k otáčení bloků.\nKliknutí levým tlačítkem otočí blok okolo osy, kliknutí pravým změní osu otáčení."})
end

dofile(modpath.."/chests.lua")
dofile(modpath.."/colored_chairs.lua")
dofile(modpath.."/extra_recipes.lua")
dofile(modpath.."/falling_nodes.lua")
dofile(modpath.."/ores.lua")
dofile(modpath.."/sitting.lua")

-- log giveme

local giveme_func = minetest.registered_chatcommands["giveme"].func
minetest.override_chatcommand("giveme", {func = function(player_name, param)
	minetest.log("action", player_name.." gives themself: "..param)
	return giveme_func(player_name, param)
end})

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
