-- c_doors by TumeniNodes, Nathan.S, and Napiophelios Jan 2017

-- Definitions for windows
c_doors.windowed = {
	{
		"steel",
		"Steel",
		"c_doors_dble_steel_sides.png", 
		"c_doors_dble_steel.png",
		"default:steel_ingot"
	},
	{
		"obsidian_glass", 
		"Obsidian Glass", 
		"c_doors_dble_obsidian_glass_sides.png", 
		"c_doors_dble_obsidian_glass.png", 
		"default:obsidian_glass"
	},
	{
		"glass",
		"Glass", 
		"c_doors_dble_glass_sides.png", 
		"c_doors_dble_glass.png", 
		"default:glass"
	},
	{
		"wood",
		"Wood", 
		"c_doors_dble_wood_sides.png", 
		"c_doors_dble_wood.png", 
		"default:wood"
	},
}


-- open and close actions as generalized functions
c_doors.window_open = function (pos, node, name, size)
	minetest.swap_node(pos, {name = "c_doors:dbl_" ..name.. "_win_" .. size .. "_open", param2 = node.param2})
	minetest.sound_play("c_doors_glass_open", {pos = pos, gain = 0.50, max_hear_distance = 10})
end

c_doors.window_close = function (pos, node, name, size)
	minetest.swap_node(pos, {name = "c_doors:dbl_" ..name.. "_win_" .. size, param2 = node.param2})
	minetest.sound_play("c_doors_glass_close", {pos = pos, gain = 0.30, max_hear_distance = 10})
end


-- Register Window Nodes
for _, row in ipairs(c_doors.windowed) do
	local name = row[1]
	local desc = row[2]
	local side_tile = row[3]
	local face_tile = row[4]
	local craft_material = row[5]

	local win_sml_def = {
		description = "Small " ..desc.. " Double Window",
		drawtype = "nodebox",
		tiles = {side_tile, side_tile, side_tile, side_tile, face_tile, face_tile},
		use_texture_alpha = true,
		paramtype = "light",
		paramtype2 = "facedir",
		on_rotate = screwdriver.rotate_simple,
		sunlight_propogates = true,
		is_ground_content = false,
		groups = {cracky = 3},
		sounds = default.node_sound_glass_defaults(),
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.027133, -0.4375, 0.5, 0.027133},
				{-0.5, -0.5, -0.027133, 0.5, -0.4375, 0.027133},
				{0.4375, -0.5, -0.027133, 0.5, 0.5, 0.027133},
				{-0.0625, -0.5, -0.027133, 0.0625, 0.5, 0.027133},
				{-0.5, 0.4375, -0.027133, 0.5, 0.5, 0.027133},
				{-0.4375, -0.4375, -0.02, -0.0625, 0.4375, 0.02},
				{0.0625, -0.4375, -0.02, 0.4375, 0.4375, 0.02},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.03, 0.5, 0.5, 0.03},
			},
		},
		on_rightclick = function(pos, node, puncher)
			c_doors.window_open(pos, node, name, "sml")
		end,
	}
	
	
	if minetest.get_modpath("mesecons") then
		win_sml_def.mesecons = {
			effector = {
				action_on = function(pos, node)
					c_doors.window_open(pos, node, name, "sml")
				end,
				rules = mesecon.rules.pplate
			}
		}
	end
	
	minetest.register_node("c_doors:dbl_" ..name.. "_win_sml", win_sml_def)

	local win_sml_open_def = {
		drawtype = "nodebox",
		tiles = {side_tile, side_tile, face_tile, face_tile, side_tile, side_tile},
		use_texture_alpha = true,
		paramtype = "light",
		paramtype2 = "facedir",
		on_rotate = screwdriver.rotate_simple,
		sunlight_propogates = true,
		is_ground_content = false,
		drop = "c_doors:dbl_" ..name.. "_win_sml",
		groups = {cracky = 3, not_in_creative_inventory = 1},
		sounds = default.node_sound_glass_defaults(),
		node_box = {
			type = "fixed",
			fixed = {
				{0.472867, -0.5, -0.5, 0.5, 0.5, -0.4375},
				{0.472867, -0.5, -0.0625, 0.5, 0.5, 0},
				{-0.5, -0.5, -0.5, -0.472867, 0.5, -0.4375},
				{-0.5, -0.5, -0.0625, -0.472867, 0.5, 0},
				{0.472867, 0.4375, -0.5, 0.5, 0.5, 0},
				{-0.5, 0.4375, -0.5, -0.472867, 0.5, 0},
				{-0.5, -0.5, -0.5, -0.472867, -0.4375, 0},
				{0.472867, -0.5, -0.5, 0.5, -0.4375, 0},
				{-0.472867, -0.4375, -0.4375, -0.5, 0.4375, -0.0625},
				{0.472867, -0.4375, -0.4375, 0.5, 0.4375, -0.0625},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, -0.4375, 0.5, 0},
				{0.4375, -0.5, -0.5, 0.5, 0.5, 0},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, -0.472867, 0.5, 0},
				{0.472867, -0.5, -0.5, 0.5, 0.5, 0},
			},
		},
		on_rightclick = function(pos, node, puncher)
			c_doors.window_close(pos, node, name, "sml")
		end,
	}
	
	if minetest.get_modpath("mesecons") then
		win_sml_open_def.mesecons = {
			effector = {
				action_off = function(pos, node)
					c_doors.window_close(pos, node, name, "sml")
				end,
				rules = mesecon.rules.pplate
			}
		}
	end
	
	minetest.register_node("c_doors:dbl_" ..name.. "_win_sml_open", win_sml_open_def)

	local win_lg_def = {
		description = "Large " ..desc.. " Double Window",
		inventory_image = "c_doors_dble_" ..name.. "_inv.png",
		wield_image = "c_doors_dble_" ..name.. "_inv.png",
		drawtype = "nodebox",
		tiles = {side_tile, side_tile, side_tile, side_tile, face_tile, face_tile},
		use_texture_alpha = true,
		paramtype = "light",
		paramtype2 = "facedir",
		on_rotate = screwdriver.rotate_simple,
		sunlight_propogates = true,
		is_ground_content = false,
		groups = {cracky = 3},
		sounds = default.node_sound_glass_defaults(),
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.027133, -0.4375, 1.5, 0.027133},
				{-0.5, -0.5, -0.027133, 0.5, -0.4375, 0.027133},
				{0.4375, -0.5, -0.027133, 0.5, 1.5, 0.027133},
				{-0.0625, -0.5, -0.027133, 0.0625, 1.5, 0.027133},
				{-0.5, 0.4375, -0.027133, 0.5, 0.5625, 0.027133},
				{-0.5, 1.4375, -0.027133, 0.5, 1.5, 0.027133},
				{-0.4375, 0.5625, -0.02, -0.0625, 1.4375, 0.02},
				{0.0625, 0.5625, -0.02, 0.4375, 1.4375, 0.02},
				{0.0625, -0.4375, -0.02, 0.4375, 0.4375, 0.02},
				{-0.4375, -0.4375, -0.02, -0.0625, 0.4375, 0.02},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.03, 0.5, 1.5, 0.03},
			},
		},
		on_rightclick = function(pos, node, puncher)
			c_doors.window_open(pos, node, name, "lg")
		end,
	}
	
	if minetest.get_modpath("mesecons") then
		win_lg_def.mesecons = {
			effector = {
				action_on = function(pos, node)
					c_doors.window_open(pos, node, name, "lg")
				end,
				rules = mesecon.rules.pplate
			}
		}
	end
	
	minetest.register_node("c_doors:dbl_" ..name.. "_win_lg", win_lg_def)

	local win_lg_open_def = {
		drawtype = "nodebox",
		tiles = {side_tile, side_tile, face_tile, face_tile, side_tile, side_tile},
		use_texture_alpha = true,
		paramtype = "light",
		paramtype2 = "facedir",
		on_rotate = screwdriver.rotate_simple,
		sunlight_propogates = true,
		is_ground_content = false,
		drop = "c_doors:dbl_" ..name.. "_win_lg",
		groups = {cracky = 3, not_in_creative_inventory = 1},
		sounds = default.node_sound_glass_defaults(),
		node_box = {
			type = "fixed",
			fixed = {
				{0.472867, -0.5, -0.5, 0.5, 1.5, -0.4375},
				{0.472867, -0.5, -0.0625, 0.5, 1.5, 0},
				{-0.5, -0.5, -0.5, -0.472867, 1.5, -0.4375},
				{-0.5, -0.5, -0.0625, -0.472867, 1.5, 0},
				{0.472867, 0.4375, -0.5, 0.5, 0.5625, 0},
				{-0.5, 0.4375, -0.5, -0.472867, 0.5625, 0},
				{-0.5, -0.5, -0.5, -0.472867, -0.4375, 0},
				{0.472867, -0.5, -0.5, 0.5, -0.4375, 0},
				{0.472867, 1.4375, -0.5, 0.5, 1.5, 0},
				{-0.5, 1.4375, -0.5, -0.472867, 1.5, -0.0625},
				{0.472867, 0.5625, -0.4375, 0.5, 1.4375, -0.0625},
				{0.472867, -0.4375, -0.4375, 0.5, 0.4375, -0.0625},
				{-0.472867, 0.5625, -0.4375, -0.5, 1.4375, -0.0625},
				{-0.472867, -0.4375, -0.4375, -0.5, 0.4375, -0.0625},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, -0.4375, 1.5, 0},
				{0.4375, -0.5, -0.5, 0.5, 1.5, 0},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{0.472867, -0.5, -0.5, 0.5, 1.5, 0},
				{-0.5, -0.5, -0.5, -0.472867, 1.5, 0},
			},
		},
		on_rightclick = function(pos, node, puncher)
			c_doors.window_close(pos, node, name, "lg")
		end,
	}
	
	
	if minetest.get_modpath("mesecons") then
		win_lg_open_def.mesecons = {
			effector = {
				action_off = function(pos, node)
					c_doors.window_close(pos, node, name, "lg")
				end,
				rules = mesecon.rules.pplate
			}
		}
	end
	
	minetest.register_node("c_doors:dbl_" ..name.. "_win_lg_open", win_lg_open_def)
	
	--
	-- Crafting
	--
			
	minetest.register_craft({
		output = "c_doors:dbl_" ..name.. "_win_lg",
		recipe = {
			{"c_doors:dbl_" ..name.. "_win_sml"},
			{"c_doors:dbl_" ..name.. "_win_sml"},
		}
	})

	minetest.register_craft({
		output = "c_doors:dbl_" ..name.. "_win_sml 16",
		recipe = {
			{ craft_material , "default:glass", craft_material},
			{"default:glass", "", "default:glass"},
			{ craft_material , "default:glass", craft_material},
		}
	})

end
