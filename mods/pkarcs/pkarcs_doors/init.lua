screwdriver = screwdriver or {}

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

pkarcs_doors = {}

-- Register Door Nodes
pkarcs_doors.door = {
	{
		"acacia_wood",
		"z akáciového dřeva",
		{choppy = 2, door = 1},
		default.node_sound_wood_defaults(),
		"doors_door",
		{name = "pkarcs_doors_acacia.png", backface_culling = true},
		"default:acacia_wood"
	},

	{
		"aspen_wood",
		"z osikového dřeva",
		{choppy = 2, door = 1},
		default.node_sound_wood_defaults(),
		"doors_door",
		{name = "pkarcs_doors_aspen.png", backface_culling = true},
		"default:aspen_wood"
	},

	{
		"junglewood",
		"z dřeva džunglovníku",
		{choppy = 2, door = 1},
		default.node_sound_wood_defaults(),
		"doors_door",
		{name = "pkarcs_doors_junglewood.png", backface_culling = true},
		"default:junglewood"
	},

	{
		"pine_wood",
		"z borového dřeva",
		{choppy = 2, door = 1},
		default.node_sound_wood_defaults(),
		"doors_door",
		{name = "pkarcs_doors_pine.png", backface_culling = true},
		"default:pine_wood"
	},

	{
		"wood",
		"z jabloňového dřeva",
		{choppy = 2, door = 1},
		default.node_sound_wood_defaults(),
		"doors_door",
		{name = "pkarcs_doors_wood.png", backface_culling = true},
		"default:wood"
	},

	{
		"bronze",
		"z bronzu",
		{cracky = 1, level = 2, door = 1},
		default.node_sound_metal_defaults(),
		"doors_steel_door",
		{name = "pkarcs_doors_bronze.png", backface_culling = true},
		"default:bronzeblock"
	},

	{
		"copper",
		"z mědi",
		{cracky = 1, level = 2, door = 1},
		default.node_sound_metal_defaults(),
		"doors_steel_door",
		{name = "pkarcs_doors_copper.png", backface_culling = true},
		"default:copperblock"
	},

	{
		"iron",
		"ze železa",
		{cracky = 1, level = 2, door = 1},
		default.node_sound_metal_defaults(),
		"doors_steel_door",
		{name = "pkarcs_doors_iron.png", backface_culling = true},
		"default:iron_lump"
	},

	{
		"steel",
		"z oceli",
		{cracky = 1, level = 2, door = 1},
		default.node_sound_metal_defaults(),
		"doors_steel_door",
		{name = "pkarcs_doors_steel.png", backface_culling = true},
		"default:steelblock"
	},

	{
		"tin",
		"z cínu",
		{cracky = 1, level = 2, door = 1},
		default.node_sound_metal_defaults(),
		"doors_steel_door",
		{name = "pkarcs_doors_tin.png", backface_culling = true},
		"default:tinblock"
	},

	{
		"bar",
		"z kovových mříží",
		{cracky = 1, level = 2, door = 1},
		default.node_sound_metal_defaults(),
		"doors_steel_door",
		{name = "pkarcs_doors_bar.png", backface_culling = true},
		"xpanes:bar_flat"
	},
}


-- open and close actions as generalized functions
pkarcs_doors.open = function (pos, node, name, side, door_sound)
	if not side or side == "L" then
		minetest.swap_node(pos, {name = "pkarcs_doors:" ..name.. "_Ldoor_open", param2 = node.param2})
	elseif side == "R" or side then
		minetest.swap_node(pos, {name = "pkarcs_doors:" ..name.. "_Rdoor_open", param2 = node.param2})
	end
	minetest.sound_play(door_sound.."_open", {pos = pos, gain = 0.20, max_hear_distance = 10})
end

pkarcs_doors.close = function (pos, node, name, side, door_sound)
	if not side or side == "L" then
		minetest.swap_node(pos, {name = "pkarcs_doors:" ..name.. "_Ldoor", param2 = node.param2})
	elseif side == "R" or side then
		minetest.swap_node(pos, {name = "pkarcs_doors:" ..name.. "_Rdoor", param2 = node.param2})
	end
	minetest.sound_play(door_sound.."_close", {pos = pos, gain = 0.15, max_hear_distance = 10})
end

for _, row in ipairs(pkarcs_doors.door) do
	local name = row[1]
	local desc = row[2]
	local mat_groups = row[3]
	local mat_sound = row[4]
	local door_sound = row[5]
	local door_tiles = row[6]
	local craft_material = row[7]

	local Ldoor_def = {
		description = "zaoblené dveře levé (výška 2 m) " .. desc,
		inventory_image = "pkarcs_doors_" ..name.. "_item.png",
		wield_image = "pkarcs_doors_" ..name.. "_item.png",
		drawtype = "mesh",
		mesh = "pkarcs_door_L.obj",
		tiles = {door_tiles},
		use_texture_alpha = "clip",
		paramtype = "light",
		paramtype2 = "facedir",
		on_rotate = screwdriver.rotate_simple,
		sunlight_propogates = true,
		is_ground_content = false,
		groups = mat_groups,
		sounds = mat_sound,
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 1.4375, -0.375},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 1.4375, -0.375},
			},
		},
		on_rightclick = function(pos, node, puncher)
			pkarcs_doors.open(pos, node, name, "L", door_sound)
		end,
	}

	if minetest.get_modpath("mesecons") then
		Ldoor_def.mesecons = {
			effector = {
				action_on = function(pos, node)
					pkarcs_doors.open(pos, node, name, "L", door_sound)
				end,
				rules = mesecon.rules.pplate
			}
		}
	end

	minetest.register_node(":pkarcs_doors:" ..name.. "_Ldoor", Ldoor_def)


	local Ldoor_open_def = {
		drawtype = "mesh",
		mesh = "pkarcs_door_L_open.obj",
		tiles = {door_tiles},
		use_texture_alpha = "clip",
		paramtype = "light",
		paramtype2 = "facedir",
		on_rotate = screwdriver.rotate_simple,
		legacy_facedir_simple = true,
		sunlight_propogates = true,
		is_ground_content = false,
		groups = mat_groups,
		drop = "pkarcs_doors:" ..name.. "_Ldoor",
		sounds = mat_sound,
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -1.4375, -0.375, 1.4375, -0.4375},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -1.4375, -0.375, 1.4375, -0.4375},
			},
		},
		on_rightclick = function(pos, node, puncher)
			pkarcs_doors.close(pos, node, name, "L", door_sound)
		end,
	}
	
		if minetest.get_modpath("mesecons") then
		Ldoor_open_def.mesecons = {
			effector = {
				action_off = function(pos, node)
					pkarcs_doors.close(pos, node, name, "L", door_sound)
				end,
				rules = mesecon.rules.pplate
			}
		}
	end
	
	minetest.register_node(":pkarcs_doors:" ..name.. "_Ldoor_open", Ldoor_open_def)


	local Rdoor_def = {
		description = "zaoblené dveře pravé (výška 2 m) " .. desc,
		inventory_image = "pkarcs_doors_" ..name.. "_item.png^[transformFXX",
		wield_image = "pkarcs_doors_" ..name.. "_item.png^[transformFXX",
		drawtype = "mesh",
		mesh = "pkarcs_door_R.obj",
		tiles = {door_tiles},
		use_texture_alpha = "clip",
		paramtype = "light",
		paramtype2 = "facedir",
		on_rotate = screwdriver.rotate_simple,
		sunlight_propogates = true,
		is_ground_content = false,
		groups = mat_groups,
		sounds = mat_sound,
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 1.4375, -0.375},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 1.4375, -0.375},
			},
		},
		on_rightclick = function(pos, node, puncher)
			pkarcs_doors.open(pos, node, name, "R", door_sound)
		end,
	}

	if minetest.get_modpath("mesecons") then
		Rdoor_def.mesecons = {
			effector = {
				action_on = function(pos, node)
					pkarcs_doors.open(pos, node, name, "R", door_sound)
				end,
				rules = mesecon.rules.pplate
			}
		}
	end
	
	minetest.register_node(":pkarcs_doors:" ..name.. "_Rdoor", Rdoor_def)


	local Rdoor_open_def = {
		drawtype = "mesh",
		mesh = "pkarcs_door_R_open.obj",
		tiles = {door_tiles},
		use_texture_alpha = "clip",
		paramtype = "light",
		paramtype2 = "facedir",
		on_rotate = screwdriver.rotate_simple,
		legacy_facedir_simple = true,
		sunlight_propogates = true,
		is_ground_content = false,
		groups = mat_groups,
		drop = "pkarcs_doors:" ..name.. "_Rdoor",
		sounds = mat_sound,
		selection_box = {
			type = "fixed",
			fixed = {
				{0.375, -0.5, -1.4375, 0.5, 1.4375, -0.4375},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{0.375, -0.5, -1.4375, 0.5, 1.4375, -0.4375},
			},
		},
		on_rightclick = function(pos, node, puncher)
			pkarcs_doors.close(pos, node, name, "R", door_sound)
		end,
	}
	
		if minetest.get_modpath("mesecons") then
		Rdoor_open_def.mesecons = {
			effector = {
				action_off = function(pos, node)
					pkarcs_doors.close(pos, node, name, "R", door_sound)
				end,
				rules = mesecon.rules.pplate
			}
		}
	end
	
	minetest.register_node(":pkarcs_doors:" ..name.. "_Rdoor_open", Rdoor_open_def)


--
-- Crafting
--

	minetest.register_craft({
		output = "pkarcs_doors:" ..name.. "_Ldoor",
		recipe = {
			{"",        "",        ""},
			{"", craft_material, ""},
			{craft_material, craft_material, ""},
		}
	})

			minetest.register_craft({
		output = "pkarcs_doors:" ..name.. "_Rdoor",
		recipe = {
			{"",        "",        ""},
			{"", craft_material, ""},
			{"", craft_material, craft_material},
		}
	})
end
print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
