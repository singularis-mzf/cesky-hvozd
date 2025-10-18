-- c_doors by TumeniNodes, Nathan.S, and Napiophelios Jan 2017

-- Definitions for doors
c_doors.door = {
	{
		"steel", 
		"Steel", 
		{cracky = 1, door = 1}, 
		default.node_sound_metal_defaults(), 
		"c_doors_metal", 
		{name = "doors_door_steel.png", backface_culling = true}, 
		{"default:steel_ingot", "doors:door_steel"}
	},
	{
		"obsidian_glass", 
		"Obsidian Glass", 
		{cracky = 1, door = 1}, 
		default.node_sound_glass_defaults(), 
		"c_doors_glass", 
		{name = "doors_door_obsidian_glass.png"},
		{"default:obsidian_glass", "doors:door_obsidian_glass"}
	},
	{
		"glass", 
		"Glass", 
		{cracky = 3, door = 1}, 
		default.node_sound_glass_defaults(), 
		"c_doors_glass", 
		{name = "doors_door_glass.png"}, 
		{"default:glass", "doors:door_glass"}
	},
	{
		"wood", 
		"Wood", 
		{choppy = 2, door = 1}, 
		default.node_sound_wood_defaults(), 
		"doors_door", 
		{name = "doors_door_wood.png", backface_culling = true}, 
		{"default:wood", "doors:door_wood"}
	},
}


-- open and close actions as generalized functions
c_doors.open = function (pos, node, name, side, door_sound)
	if not side or side == "L" then
		minetest.swap_node(pos, {name = "c_doors:" ..name.. "_Ldoor_open", param2 = node.param2})
	elseif side == "R" or side then
		minetest.swap_node(pos, {name = "c_doors:" ..name.. "_Rdoor_open", param2 = node.param2})
	end
	minetest.sound_play(door_sound.."_open", {pos = pos, gain = 0.20, max_hear_distance = 10})
end

c_doors.close = function (pos, node, name, side, door_sound)
	if not side or side == "L" then
		minetest.swap_node(pos, {name = "c_doors:" ..name.. "_Ldoor", param2 = node.param2})
	elseif side == "R" or side then
		minetest.swap_node(pos, {name = "c_doors:" ..name.. "_Rdoor", param2 = node.param2})
	end
	minetest.sound_play(door_sound.."_close", {pos = pos, gain = 0.15, max_hear_distance = 10})
end


-- Register Door Nodes
for _, row in ipairs(c_doors.door) do
	local name = row[1]
	local desc = row[2]
	local mat_groups = row[3]
	local mat_sound = row[4]
	local door_sound = row[5]
	local door_tiles = row[6]
	local craft_material = row[7]

	local Ldoor_def = {
		description = desc.. " Door (left)",
		inventory_image = "doors_item_" ..name.. ".png^[transformFXX",
		wield_image = "doors_item_" ..name.. ".png^[transformFXX",
		drawtype = "mesh",
		mesh = "c_door_L.obj",
		tiles = {door_tiles},
		use_texture_alpha = true,
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
				{-0.5, -0.5, -0.0625, 0.5, 1.5, 0.0625},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.0625, 0.5, 1.5, 0.0625},
			},
		},
		on_rightclick = function(pos, node, puncher)
			c_doors.open(pos, node, name, "L", door_sound)
		end,
	}
	
	if minetest.get_modpath("mesecons") then
		Ldoor_def.mesecons = {
			effector = {
				action_on = function(pos, node)
					c_doors.open(pos, node, name, "L", door_sound)
				end,
				rules = mesecon.rules.pplate
			}
		}
	end
	
	minetest.register_node("c_doors:" ..name.. "_Ldoor", Ldoor_def)

	local Ldoor_open_def = {
		drawtype = "mesh",
		mesh = "c_door_L_open.obj",
		tiles = {door_tiles},
		use_texture_alpha = true,
		paramtype = "light",
		paramtype2 = "facedir",
		on_rotate = screwdriver.rotate_simple,
		legacy_facedir_simple = true,
		sunlight_propogates = true,
		is_ground_content = false,
		groups = mat_groups,
		drop = "c_doors:" ..name.. "_Ldoor",
		sounds = mat_sound,
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.9375, -0.375, 1.5, 0.0625},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.9375, -0.375, 1.5, 0.0625},
			},
		},
		on_rightclick = function(pos, node, puncher)
			c_doors.close(pos, node, name, "L", door_sound)
		end,
	}
	
	if minetest.get_modpath("mesecons") then
		Ldoor_open_def.mesecons = {
			effector = {
				action_off = function(pos, node)
					c_doors.close(pos, node, name, "L", door_sound)
				end,
				rules = mesecon.rules.pplate
			}
		}
	end
	
	minetest.register_node("c_doors:" ..name.. "_Ldoor_open", Ldoor_open_def)

	local Rdoor_def = {
		description = desc.. " Door (right)",
		inventory_image = "doors_item_" ..name.. ".png",
		wield_image = "doors_item_" ..name.. ".png",
		drawtype = "mesh",
		mesh = "c_door_R.obj",
		tiles = {door_tiles},
		use_texture_alpha = true,
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
				{-0.5, -0.5, -0.0625, 0.5, 1.5, 0.0625},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.0625, 0.5, 1.5, 0.0625},
			},
		},
		on_rightclick = function(pos, node, puncher)
			c_doors.open(pos, node, name, "R", door_sound)
		end,
	}
	
	if minetest.get_modpath("mesecons") then
		Rdoor_def.mesecons = {
			effector = {
				action_on = function(pos, node)
					c_doors.open(pos, node, name, "R", door_sound)
				end,
				rules = mesecon.rules.pplate
			}
		}
	end
	
	minetest.register_node("c_doors:" ..name.. "_Rdoor", Rdoor_def)

	local Rdoor_open_def = {
		drawtype = "mesh",
		mesh = "c_door_R_open.obj",
		tiles = {door_tiles},
		use_texture_alpha = true,
		paramtype = "light",
		paramtype2 = "facedir",
		on_rotate = screwdriver.rotate_simple,
		legacy_facedir_simple = true,
		sunlight_propogates = true,
		is_ground_content = false,
		groups = mat_groups,
		drop = "c_doors:" ..name.. "_Rdoor",
		sounds = mat_sound,
		selection_box = {
			type = "fixed",
			fixed = {
				{0.375, -0.5, -0.9375, 0.5, 1.5, 0.0625},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{0.375, -0.5, -0.9375, 0.5, 1.5, 0.0625},
			},
		},
		on_rightclick = function(pos, node, puncher)
			c_doors.close(pos, node, name, "R", door_sound)
		end,
	}
	
	if minetest.get_modpath("mesecons") then
		Rdoor_open_def.mesecons = {
			effector = {
				action_off = function(pos, node)
					c_doors.close(pos, node, name, "R", door_sound)
				end,
				rules = mesecon.rules.pplate
			}
		}
	end
	
	minetest.register_node("c_doors:" ..name.. "_Rdoor_open", Rdoor_open_def)

	--
	-- Crafting
	--
	
	if c_doors.from_doors then
	
		-- make centered doors out of regular ones
		minetest.register_craft({
			output = "c_doors:" ..name.. "_Ldoor",
			recipe = {
				{"", "default:stick",   ""},
				{"", craft_material[2], ""},
				{"", "default:stick",   ""},
			}
		})
		
		-- register recipe to undo the transformation
		minetest.register_craft({
			output = craft_material[2] .. " 2",
			recipe = {
				{"c_doors:" ..name.. "_Ldoor", "c_doors:" ..name.. "_Rdoor"},
			}
		})
	
	else
	
		minetest.register_craft({
			output = "c_doors:" ..name.. "_Ldoor",
			recipe = {
				{"", craft_material[1], ""},
				{"", craft_material[1], ""},
				{"", craft_material[1], ""},
			}
		})
	
	end

	minetest.register_craft({
		output = "c_doors:" ..name.. "_Rdoor",
		recipe = {
			{"c_doors:" ..name.. "_Ldoor"},
		}
	})

	minetest.register_craft({
		output = "c_doors:" ..name.. "_Ldoor",
		recipe = {
			{"c_doors:" ..name.. "_Rdoor"},
		}
	})

end

