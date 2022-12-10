--[[
	## StreetsMod 2.0 ##
	Submod: trafficlight
	Optional: true
]]

streets.tlBox = {
	{ -0.1875, -0.5, 0.5, 0.1875, 0.5, 0.75 }, --Box

	{ -0.125, -0.125, 0.85, 0.125, 0.125, 0.75 }, -- Pole Mounting Bracket

	{ -0.125, 0.3125, 0.3125, -0.0625, 0.375, 0.5 }, --Top Visor, Left
	{ -0.0625, 0.375, 0.3125, 0.0625, 0.4375, 0.5 }, --Top Visor, Center
	{ 0.0625, 0.3125, 0.3125, 0.125, 0.38, 0.5 }, --Top Visor, Right

	{ -0.125, 0, 0.3125, -0.0625, 0.0625, 0.5 }, --Middle Visor, Left
	{ -0.0625, 0.0625, 0.3125, 0.0625, 0.125, 0.5 }, --Middle Visor, Center
	{ 0.0625, 0, 0.3125, 0.125, 0.0625, 0.5 }, --Middle Visor, Right

	{ -0.125, -0.3125, 0.3125, -0.0625, -0.25, 0.5 }, --Bottom Visor, Left
	{ -0.0625, -0.25, 0.3125, 0.0625, -0.1875, 0.5 }, --Bottom Visor, Center
	{ 0.0625, -0.3125, 0.3125, 0.125, -0.25, 0.5 }, --Bottom Visor, Right
}

streets.tleBox = {
	{ -0.1875, -0.1875, 0.5, 0.1875, 0.5, 0.75 }, --Box

	{ -0.125, 0.3125, 0.3125, -0.0625, 0.375, 0.5 }, --Top Visor, Left
	{ -0.0625, 0.375, 0.3125, 0.0625, 0.4375, 0.5 }, --Top Visor, Center
	{ 0.0625, 0.3125, 0.3125, 0.125, 0.38, 0.5 }, --Top Visor, Right

	{ -0.125, 0, 0.3125, -0.0625, 0.0625, 0.5 }, --Middle Visor, Left
	{ -0.0625, 0.0625, 0.3125, 0.0625, 0.125, 0.5 }, --Middle Visor, Center
	{ 0.0625, 0, 0.3125, 0.125, 0.0625, 0.5 }, --Middle Visor, Right
}

streets.plBox = {
	{ -0.1875, -0.5, 0.5, 0.1875, 0.5, 0.75 }, --Box

	{ -0.125, -0.125, 0.85, 0.125, 0.125, 0.75 }, -- Pole Mounting Bracket

	{ -0.1875, 0.0625, 0.3125, -0.1375, 0.4375, 0.5 }, --Top Visor, Left
	{ -0.1375, 0.3875, 0.3125, 0.1375, 0.4375, 0.5 }, --Top Visor, Center
	{ 0.1875, 0.0625, 0.3125, 0.1375, 0.4375, 0.5 }, --Top Visor, Right

	{ -0.1875, -0.0625, 0.3125, -0.1375, -0.4375, 0.5 }, --Bottom Visor, Left
	{ -0.1375, -0.0625, 0.3125, 0.1375, -0.1125, 0.5 }, --Bottom Visor, Center
	{ 0.1875, -0.0625, 0.3125, 0.1375, -0.4375, 0.5 }, --Bottom Visor, Right
}

streets.bBox = {
	{ -0.1875, -0.1875, 0.5, 0.1875, 0.1875, 0.75 }, --Box

	{ -0.125, -0.125, 0.85, 0.125, 0.125, 0.75 }, -- Pole Mounting Bracket

	{ -0.125, 0, 0.3125, -0.0625, 0.0625, 0.5 }, --Visor, Left
	{ -0.0625, 0.0625, 0.3125, 0.0625, 0.125, 0.5 }, --Visor, Center
	{ 0.0625, 0, 0.3125, 0.125, 0.0625, 0.5 }, --Visor, Right
}

streets.hbBox = {
	{ -0.375, -0.25, 0.5, 0.375, 0.25, 0.75 }, --Box

	{ -0.125, -0.125, 0.85, 0.125, 0.125, 0.75 }, -- Pole Mounting Bracket

	{ -0.3, 0.0625, 0.3125, -0.2375, 0.125, 0.5 }, --Top Left Visor, Left
	{ -0.2375, 0.125, 0.3125, -0.1125, 0.1875, 0.5 }, --Top Left Visor, Center
	{ -0.1125, 0.0625, 0.3125, -0.05, 0.125, 0.5 }, --Top Left Visor, Right

	{ 0.1125, 0.0625, 0.3125, 0.05, 0.125, 0.5 }, --Top Right Visor, Left
	{ 0.2375, 0.125, 0.3125, 0.1125, 0.1875, 0.5 }, --Top Right Visor, Center
	{ 0.3, 0.0625, 0.3125, 0.2375, 0.125, 0.5 }, --Top Right Visor, Right

	{ -0.125, -0.125, 0.3125, -0.0625, -0.0625, 0.5 }, --Bottom Visor, Left
	{ -0.0625, -0.0625, 0.3125, 0.0625, 0, 0.5 }, --Bottom Visor, Center
	{ 0.0625, -0.125, 0.3125, 0.125, -0.0625, 0.5 }, --Bottom Visor, Right
}

streets.tlDigilineRules = {
	{ x = 0, y = 0, z = -1 },
	{ x = 0, y = 0, z = 1 },
	{ x = 1, y = 0, z = 0 },
	{ x = -1, y = 0, z = 0 },
	{ x = 0, y = -1, z = 0 },
	{ x = 0, y = 1, z = 0 }
}

streets.tlSwitch = function(pos, to)
	if not pos or not to then
		return
	end
	local node = minetest.get_node(pos)
	node.name = to
	minetest.swap_node(pos, node)
end

local signals = {
	{ msg = "OFF", description = "vypnuto" },
	{ msg = "RED", description = "červená" },
	{ msg = "REDYELLOW", description = "červená+žlutá" },
	{ msg = "GREEN", description = "zelená" },
	{ msg = "YELLOW", description = "žlutá" },
	{ msg = "FLASHRED", description = "blikající červená" },
	{ msg = "FLASHYELLOW", description = "blikající žlutá" },
	{ msg = "FLASHGREEN", description = "blikající zelená" },
}

local function switch_to_next_signal(pos, node, player_name)
	local name = node.name
	local meta = minetest.get_meta(pos)
	local current_signal = meta:get_int("signal")
	local new_signal = current_signal
	local signal_def = signals[1]
	local first_cycle = true
	local msg

	while (first_cycle or new_signal ~= current_signal) and minetest.get_node(pos).name == name do
		new_signal = new_signal + 1
		if not signals[new_signal] then
			new_signal = 1
		end
		signal_def = signals[new_signal]
		msg = signal_def.msg
		first_cycle = false

		if msg == "OFF" then
			if name:find("pedlight") then
				streets.tlSwitch(pos, "streets:pedlight_top_off")
			elseif name:find("extender_left") then
				streets.tlSwitch(pos, "streets:trafficlight_top_extender_left_off")
			elseif name:find("extender_right") then
				streets.tlSwitch(pos, "streets:trafficlight_top_extender_right_off")
			elseif name:find("left") then
				streets.tlSwitch(pos, "streets:trafficlight_top_left_off")
			elseif name:find("right") then
				streets.tlSwitch(pos, "streets:trafficlight_top_right_off")
			elseif name:find("beacon_hybrid") then
				streets.tlSwitch(pos, "streets:beacon_hybrid_off")
			elseif name:find("beacon") then
				streets.tlSwitch(pos, "streets:beacon_off")
			else
				streets.tlSwitch(pos, "streets:trafficlight_top_off")
			end
		elseif msg == "GREEN" then
			if name:find("pedlight") then
				streets.tlSwitch(pos, "streets:pedlight_top_walk")
			elseif name:find("extender_left") then
				streets.tlSwitch(pos, "streets:trafficlight_top_extender_left_green")
			elseif name:find("extender_right") then
				streets.tlSwitch(pos, "streets:trafficlight_top_extender_right_green")
			elseif name:find("left") then
				streets.tlSwitch(pos, "streets:trafficlight_top_left_green")
			elseif name:find("right") then
				streets.tlSwitch(pos, "streets:trafficlight_top_right_green")
			elseif name:find("beacon_hybrid") then
				--Not Supported
			elseif name:find("beacon") then
				--Not Supported
			else
				streets.tlSwitch(pos, "streets:trafficlight_top_green")
			end
		elseif msg == "RED" then
			if name:find("pedlight") then
				streets.tlSwitch(pos, "streets:pedlight_top_dontwalk")
			elseif name:find("extender_left") then
				streets.tlSwitch(pos, "streets:trafficlight_top_extender_left_off")
			elseif name:find("extender_right") then
				streets.tlSwitch(pos, "streets:trafficlight_top_extender_right_off")
			elseif name:find("left") then
				streets.tlSwitch(pos, "streets:trafficlight_top_left_red")
			elseif name:find("right") then
				streets.tlSwitch(pos, "streets:trafficlight_top_right_red")
			elseif name:find("beacon_hybrid") then
				streets.tlSwitch(pos, "streets:beacon_hybrid_red")
			elseif name:find("beacon") then
				--Not Supported
			else
				streets.tlSwitch(pos, "streets:trafficlight_top_red")
			end
		elseif msg == "FLASHGREEN" then
			if name:find("pedlight") then
				streets.tlSwitch(pos, "streets:pedlight_top_flashingwalk")
			elseif name:find("extender_left") then
				streets.tlSwitch(pos, "streets:trafficlight_top_extender_left_flashgreen")
			elseif name:find("extender_right") then
				streets.tlSwitch(pos, "streets:trafficlight_top_extender_right_flashgreen")
			elseif name:find("left") then
				streets.tlSwitch(pos, "streets:trafficlight_top_left_flashgreen")
			elseif name:find("right") then
				streets.tlSwitch(pos, "streets:trafficlight_top_right_flashgreen")
			elseif name:find("beacon_hybrid") then
				--Not Supported
			elseif name:find("beacon") then
				--Not Supported
			else
				streets.tlSwitch(pos, "streets:trafficlight_top_flashgreen")
			end
		elseif msg == "REDYELLOW" then
			if name:find("pedlight") then
				--Not Supported
			elseif name:find("extender_left") then
				--Not Supported
			elseif name:find("extender_right") then
				--Not Supported
			elseif name:find("left") then
				streets.tlSwitch(pos, "streets:trafficlight_top_left_redyellow")
			elseif name:find("right") then
				streets.tlSwitch(pos, "streets:trafficlight_top_right_redyellow")
			elseif name:find("beacon_hybrid") then
				--Not Supported
			elseif name:find("beacon") then
				--Not Supported
			else
				streets.tlSwitch(pos, "streets:trafficlight_top_redyellow")
			end
		elseif msg == "FLASHYELLOW" then
			if name:find("pedlight") then
				streets.tlSwitch(pos, "streets:pedlight_top_flashingdontwalk")
			elseif name:find("extender_left") then
				streets.tlSwitch(pos, "streets:trafficlight_top_extender_left_off")
			elseif name:find("extender_right") then
				streets.tlSwitch(pos, "streets:trafficlight_top_extender_right_off")
			elseif name:find("left") then
				streets.tlSwitch(pos, "streets:trafficlight_top_left_warn")
			elseif name:find("right") then
				streets.tlSwitch(pos, "streets:trafficlight_top_right_warn")
			elseif name:find("beacon_hybrid") then
				streets.tlSwitch(pos, "streets:beacon_hybrid_flashyellow")
			elseif name:find("beacon") then
				streets.tlSwitch(pos, "streets:beacon_flashyellow")
			else
				streets.tlSwitch(pos, "streets:trafficlight_top_warn")
			end
		elseif msg == "YELLOW" then
			if name:find("pedlight") then
				streets.tlSwitch(pos, "streets:pedlight_top_flashingdontwalk")
			elseif name:find("extender_left") then
				streets.tlSwitch(pos, "streets:trafficlight_top_extender_left_yellow")
			elseif name:find("extender_right") then
				streets.tlSwitch(pos, "streets:trafficlight_top_extender_right_yellow")
			elseif name:find("left") then
				streets.tlSwitch(pos, "streets:trafficlight_top_left_yellow")
			elseif name:find("right") then
				streets.tlSwitch(pos, "streets:trafficlight_top_right_yellow")
			elseif name:find("beacon_hybrid") then
				streets.tlSwitch(pos, "streets:beacon_hybrid_yellow")
			elseif name:find("beacon") then
				--Not Supported
			else
				streets.tlSwitch(pos, "streets:trafficlight_top_yellow")
			end
		elseif msg == "FLASHRED" then
			if name:find("pedlight") then
				streets.tlSwitch(pos, "streets:pedlight_top_flashingdontwalk")
			elseif name:find("extender_left") then
				-- streets.tlSwitch(pos, "streets:trafficlight_top_extender_left_off")
			elseif name:find("extender_right") then
				-- streets.tlSwitch(pos, "streets:trafficlight_top_extender_right_off")
			elseif name:find("left") then
				streets.tlSwitch(pos, "streets:trafficlight_top_left_flashred")
			elseif name:find("right") then
				streets.tlSwitch(pos, "streets:trafficlight_top_right_flashred")
			elseif name:find("beacon_hybrid") then
				streets.tlSwitch(pos, "streets:beacon_hybrid_flashred")
			elseif name:find("beacon") then
				streets.tlSwitch(pos, "streets:beacon_flashred")
			else
				streets.tlSwitch(pos, "streets:trafficlight_top_flashred")
			end
		end
	end
	if new_signal ~= current_signal then
		meta:set_int("signal", new_signal)
	end
	if player_name then
		ch_core.systemovy_kanal(player_name, "Signál přepnut do stavu: "..signal_def.description)
	end
end

local function on_construct(pos)
	local meta = minetest.get_meta(pos)
	meta:set_int("signal", 1)
end

local function on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	local player_name = clicker and clicker:get_player_name()
	if not player_name then
		return
	end
	if minetest.is_protected(pos, player_name) then
		minetest.record_protection_violation(pos, player_name)
		return
	end
	switch_to_next_signal(pos, node, player_name)
end

--[[
minetest.register_node(":streets:digiline_distributor", {
	description = "Digiline distributor",
	tiles = { "streets_lampcontroller_top.png", "streets_lampcontroller_bottom.png", "streets_lampcontroller_sides.png" },
	groups = { cracky = 1 },
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
			{ -0.05, 0.5, -0.05, 0.05, 1.6, 0.05 }
		}
	},
	digiline = {
		wire = {
			rules = {
				{ x = 0, y = 0, z = -1 },
				{ x = 0, y = 0, z = 1 },
				{ x = 1, y = 0, z = 0 },
				{ x = -1, y = 0, z = 0 },
				{ x = 0, y = 2, z = 0 }
			}
		}
	}
})
]]

minetest.register_node(":streets:beacon_hybrid_off", {
	description = "signalizace železničního přejezdu",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, level = 2 },
	inventory_image = "streets_hybrid_beacon_inv.png",
	light_source = 11,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = streets.hbBox
	},
	tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_hb_off.png" },
	use_texture_alpha = "opaque",
	on_construct = on_construct,
	on_rightclick = on_rightclick,
})

minetest.register_node(":streets:beacon_hybrid_yellow", {
	drop = "streets:beacon_hybrid_off",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, level = 2, not_in_creative_inventory = 1 },
	light_source = 11,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = streets.hbBox
	},
	tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_hb_yellow.png" },
	use_texture_alpha = "opaque",
	on_construct = on_construct,
	on_rightclick = on_rightclick,
})

minetest.register_node(":streets:beacon_hybrid_red", {
	drop = "streets:beacon_hybrid_off",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, level = 2, not_in_creative_inventory = 1 },
	light_source = 11,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = streets.hbBox
	},
	tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_hb_red.png" },
	use_texture_alpha = "opaque",
	on_construct = on_construct,
	on_rightclick = on_rightclick,
})

minetest.register_node(":streets:beacon_hybrid_flashyellow", {
	drop = "streets:beacon_hybrid_off",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, level = 2, not_in_creative_inventory = 1 },
	light_source = 11,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = streets.hbBox
	},
	tiles = {
		"streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", {
			name = "streets_hb_flashyellow.png",
			animation = { type = "vertical_frames", aspect_w = 64, aspect_h = 64, length = 1.2 },
		}
	},
	use_texture_alpha = "opaque",
	on_construct = on_construct,
	on_rightclick = on_rightclick,
})

minetest.register_node(":streets:beacon_hybrid_flashred", {
	drop = "streets:beacon_hybrid_off",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, level = 2, not_in_creative_inventory = 1 },
	light_source = 11,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = streets.hbBox
	},
	tiles = {
		"streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", {
			name = "streets_hb_flashred.png",
			animation = { type = "vertical_frames", aspect_w = 64, aspect_h = 64, length = 1.2 },
		}
	},
	use_texture_alpha = "opaque",
	on_construct = on_construct,
	on_rightclick = on_rightclick,
})

minetest.register_node(":streets:beacon_off", {
	description = "blikající návěst (červeně či žlutě)",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, level = 2 },
	inventory_image = "streets_beacon_inv.png",
	light_source = 11,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = streets.bBox
	},
	tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_off.png" },
	use_texture_alpha = "opaque",
	on_construct = on_construct,
	on_rightclick = on_rightclick,
})

minetest.register_node(":streets:beacon_flashred", {
	drop = "streets:beacon_off",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, level = 2, not_in_creative_inventory = 1 },
	light_source = 11,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = streets.bBox
	},
	tiles = {
		"streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", {
			name = "streets_b_flashred.png",
			animation = { type = "vertical_frames", aspect_w = 64, aspect_h = 64, length = 1.2 },
		}
	},
	use_texture_alpha = "opaque",
	on_construct = on_construct,
	on_rightclick = on_rightclick,
})

minetest.register_node(":streets:beacon_flashyellow", {
	drop = "streets:beacon_off",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, level = 2, not_in_creative_inventory = 1 },
	light_source = 11,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = streets.bBox
	},
	tiles = {
		"streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", {
			name = "streets_tl_warn.png",
			animation = { type = "vertical_frames", aspect_w = 64, aspect_h = 64, length = 1.2 },
		}
	},
	use_texture_alpha = "opaque",
	on_construct = on_construct,
	on_rightclick = on_rightclick,
})

minetest.register_node(":streets:trafficlight_top_extender_left_off", {
	description = "doplňková šipka k semaforu (odbočení vlevo)",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, level = 2 },
	inventory_image = "streets_trafficlight_inv_extender_left.png",
	light_source = 11,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = streets.tleBox
	},
	tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_left_off.png" },
	use_texture_alpha = "opaque",
	on_construct = on_construct,
	on_rightclick = on_rightclick,
})

minetest.register_node(":streets:trafficlight_top_extender_left_yellow", {
	drop = "streets:trafficlight_top_extender_left_off",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, level = 2, not_in_creative_inventory = 1 },
	light_source = 11,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = streets.tleBox
	},
	tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tle_left_yellow.png" },
	use_texture_alpha = "opaque",
	on_construct = on_construct,
	on_rightclick = on_rightclick,
})

minetest.register_node(":streets:trafficlight_top_extender_left_green", {
	drop = "streets:trafficlight_top_extender_left_off",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, level = 2, not_in_creative_inventory = 1 },
	light_source = 11,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = streets.tleBox
	},
	tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tle_left_green.png" },
	use_texture_alpha = "opaque",
	on_construct = on_construct,
	on_rightclick = on_rightclick,
})

minetest.register_node(":streets:trafficlight_top_extender_left_flashgreen", {
	drop = "streets:trafficlight_top_extender_left_off",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, level = 2, not_in_creative_inventory = 1 },
	light_source = 11,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = streets.tleBox
	},
	tiles = {
		"streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", {
			name = "streets_tle_left_flashgreen.png",
			animation = { type = "vertical_frames", aspect_w = 64, aspect_h = 64, length = 1.2 },
		}
	},
	use_texture_alpha = "opaque",
	on_construct = on_construct,
	on_rightclick = on_rightclick,
})

minetest.register_node(":streets:trafficlight_top_extender_right_off", {
	description = "doplňková šipka k semaforu (odbočení vpravo)",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, level = 2 },
	inventory_image = "streets_trafficlight_inv_extender_right.png",
	light_source = 11,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = streets.tleBox
	},
	tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_right_off.png" },
	use_texture_alpha = "opaque",
	on_construct = on_construct,
	on_rightclick = on_rightclick,
})

minetest.register_node(":streets:trafficlight_top_extender_right_yellow", {
	drop = "streets:trafficlight_top_extender_right_off",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, level = 2, not_in_creative_inventory = 1 },
	light_source = 11,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = streets.tleBox
	},
	tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tle_right_yellow.png" },
	use_texture_alpha = "opaque",
	on_construct = on_construct,
	on_rightclick = on_rightclick,
})

minetest.register_node(":streets:trafficlight_top_extender_right_green", {
	drop = "streets:trafficlight_top_extender_right_off",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, level = 2, not_in_creative_inventory = 1 },
	light_source = 11,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = streets.tleBox
	},
	tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tle_right_green.png" },
	use_texture_alpha = "opaque",
	on_construct = on_construct,
	on_rightclick = on_rightclick,
})

minetest.register_node(":streets:trafficlight_top_extender_right_flashgreen", {
	drop = "streets:trafficlight_top_extender_right_off",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, level = 2, not_in_creative_inventory = 1 },
	light_source = 11,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = streets.tleBox
	},
	tiles = {
		"streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", {
			name = "streets_tle_right_flashgreen.png",
			animation = { type = "vertical_frames", aspect_w = 64, aspect_h = 64, length = 1.2 },
		}
	},
	use_texture_alpha = "opaque",
	on_construct = on_construct,
	on_rightclick = on_rightclick,
})

minetest.register_node(":streets:pedlight_top_off", {
	description = "signál pro chodce",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { cracky = 1, level = 2 },
	inventory_image = "streets_pedlight_inv.png",
	light_source = 11,
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = streets.plBox
	},
	tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_pl_off.png" },
	use_texture_alpha = "opaque",
	on_construct = on_construct,
	on_rightclick = on_rightclick,
})

minetest.register_node(":streets:pedlight_top_dontwalk", {
	drop = "streets:pedlight_top_off",
	groups = { cracky = 1, not_in_creative_inventory = 1 },
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	drawtype = "nodebox",
	tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_pl_dontwalk.png" },
	node_box = {
		type = "fixed",
		fixed = streets.plBox
	},
	light_source = 6,
	use_texture_alpha = "opaque",
	on_construct = on_construct,
	on_rightclick = on_rightclick,
})

minetest.register_node(":streets:pedlight_top_walk", {
	drop = "streets:pedlight_top_off",
	groups = { cracky = 1, not_in_creative_inventory = 1 },
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	drawtype = "nodebox",
	tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_pl_walk.png" },
	node_box = {
		type = "fixed",
		fixed = streets.plBox
	},
	light_source = 6,
	use_texture_alpha = "opaque",
	on_construct = on_construct,
	on_rightclick = on_rightclick,
})

minetest.register_node(":streets:pedlight_top_flashingdontwalk", {
	drop = "streets:pedlight_top_off",
	groups = { cracky = 1, not_in_creative_inventory = 1 },
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	drawtype = "nodebox",
	tiles = {
		"streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", {
			name = "streets_pl_flashingdontwalk.png",
			animation = { type = "vertical_frames", aspect_w = 128, aspect_h = 128, length = 1.2 },
		}
	},
	node_box = {
		type = "fixed",
		fixed = streets.plBox
	},
	light_source = 6,
	use_texture_alpha = "opaque",
	on_construct = on_construct,
	on_rightclick = on_rightclick,
})

minetest.register_node(":streets:pedlight_top_flashingwalk", {
	drop = "streets:pedlight_top_off",
	groups = { cracky = 1, not_in_creative_inventory = 1 },
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	drawtype = "nodebox",
	tiles = {
		"streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", {
			name = "streets_pl_flashingwalk.png",
			animation = { type = "vertical_frames", aspect_w = 128, aspect_h = 128, length = 1.2 },
		}
	},
	node_box = {
		type = "fixed",
		fixed = streets.plBox
	},
	light_source = 6,
	use_texture_alpha = "opaque",
	on_construct = on_construct,
	on_rightclick = on_rightclick,
})


for _, i in pairs({ "", "_left", "_right" }) do
	minetest.register_node(":streets:trafficlight_top" .. i .. "_off", {
		description = (i == "" and "semafor") or (i == "_left" and "semafor (odbočení vlevo)") or (i == "_right" and "semafor (odbočení vpravo)"),
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = { cracky = 1, level = 2 },
		inventory_image = ((i == "") and "streets_trafficlight_inv_straight.png") or ((i == "_left") and "streets_trafficlight_inv_left.png") or ((i == "_right") and "streets_trafficlight_inv_right.png"),
		light_source = 11,
		sunlight_propagates = true,
		node_box = {
			type = "fixed",
			fixed = streets.tlBox
		},
		tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl" .. i .. "_off.png" },
		use_texture_alpha = "opaque",
		on_construct = on_construct,
		on_rightclick = on_rightclick,
	})

	minetest.register_node(":streets:trafficlight_top" .. i .. "_red", {
		drop = "streets:trafficlight_top" .. i .. "_off",
		groups = { cracky = 1, not_in_creative_inventory = 1 },
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		drawtype = "nodebox",
		tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl" .. i .. "_red.png" },
		node_box = {
			type = "fixed",
			fixed = streets.tlBox
		},
		light_source = 6,
		use_texture_alpha = "opaque",
		on_construct = on_construct,
		on_rightclick = on_rightclick,
	})

	minetest.register_node(":streets:trafficlight_top" .. i .. "_yellow", {
		drop = "streets:trafficlight_top" .. i .. "_off",
		groups = { cracky = 1, not_in_creative_inventory = 1 },
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		drawtype = "nodebox",
		tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl" .. i .. "_yellow.png" },
		node_box = {
			type = "fixed",
			fixed = streets.tlBox
		},
		light_source = 6,
		use_texture_alpha = "opaque",
		on_construct = on_construct,
		on_rightclick = on_rightclick,
	})

	minetest.register_node(":streets:trafficlight_top" .. i .. "_redyellow", {
		drop = "streets:trafficlight_top" .. i .. "_off",
		groups = { cracky = 1, not_in_creative_inventory = 1 },
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		drawtype = "nodebox",
		tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl" .. i .. "_redyellow.png" },
		node_box = {
			type = "fixed",
			fixed = streets.tlBox
		},
		light_source = 6,
		use_texture_alpha = "opaque",
		on_construct = on_construct,
		on_rightclick = on_rightclick,
	})

	minetest.register_node(":streets:trafficlight_top" .. i .. "_green", {
		drop = "streets:trafficlight_top" .. i .. "_off",
		groups = { cracky = 1, not_in_creative_inventory = 1 },
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		drawtype = "nodebox",
		tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl" .. i .. "_green.png" },
		node_box = {
			type = "fixed",
			fixed = streets.tlBox
		},
		light_source = 6,
		use_texture_alpha = "opaque",
		on_construct = on_construct,
		on_rightclick = on_rightclick,
	})

	minetest.register_node(":streets:trafficlight_top" .. i .. "_warn", {
		drop = "streets:trafficlight_top" .. i .. "_off",
		groups = { cracky = 1, not_in_creative_inventory = 1 },
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		drawtype = "nodebox",
		tiles = {
			"streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", {
				name = "streets_tl" .. i .. "_warn.png",
				animation = { type = "vertical_frames", aspect_w = 64, aspect_h = 64, length = 1.2 },
			}
		},
		node_box = {
			type = "fixed",
			fixed = streets.tlBox
		},
		light_source = 6,
		use_texture_alpha = "opaque",
		on_construct = on_construct,
		on_rightclick = on_rightclick,
	})

	minetest.register_node(":streets:trafficlight_top" .. i .. "_flashred", {
		drop = "streets:trafficlight_top" .. i .. "_off",
		groups = { cracky = 1, not_in_creative_inventory = 1 },
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		drawtype = "nodebox",
		tiles = {
			"streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", {
				name = "streets_tl" .. i .. "_flashred.png",
				animation = { type = "vertical_frames", aspect_w = 64, aspect_h = 64, length = 1.2 },
			}
		},
		node_box = {
			type = "fixed",
			fixed = streets.tlBox
		},
		light_source = 6,
		use_texture_alpha = "opaque",
		on_construct = on_construct,
		on_rightclick = on_rightclick,
	})

	minetest.register_node(":streets:trafficlight_top" .. i .. "_flashgreen", {
		drop = "streets:trafficlight_top" .. i .. "_off",
		groups = { cracky = 1, not_in_creative_inventory = 1 },
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		drawtype = "nodebox",
		tiles = {
			"streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_bg.png", {
				name = "streets_tl" .. i .. "_flashgreen.png",
				animation = { type = "vertical_frames", aspect_w = 64, aspect_h = 64, length = 1.2 },
			}
		},
		node_box = {
			type = "fixed",
			fixed = streets.tlBox
		},
		light_source = 6,
		use_texture_alpha = "opaque",
		on_construct = on_construct,
		on_rightclick = on_rightclick,
	})
end

minetest.register_craft({
	output = "streets:trafficlight_top_off",
	recipe = {
		{ "default:steel_ingot", "dye:red", "default:steel_ingot" },
		{ "default:steel_ingot", "dye:yellow", "default:steel_ingot" },
		{ "default:steel_ingot", "dye:green", "default:steel_ingot" }
	}
})

minetest.register_craft({
	output = "streets:trafficlight_top_left_off",
	recipe = {
		{ "dye:red", "default:steel_ingot", "default:steel_ingot" },
		{ "dye:yellow", "default:steel_ingot", "default:steel_ingot" },
		{ "dye:green", "default:steel_ingot", "default:steel_ingot" }
	}
})

minetest.register_craft({
	output = "streets:trafficlight_top_right_off",
	recipe = {
		{ "default:steel_ingot", "default:steel_ingot", "dye:red" },
		{ "default:steel_ingot", "default:steel_ingot", "dye:yellow" },
		{ "default:steel_ingot", "default:steel_ingot", "dye:green" }
	}
})

minetest.register_craft({
	output = "streets:pedlight_top_off",
	recipe = {
		{ "default:steel_ingot", "dye:orange", "default:steel_ingot" },
		{ "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" },
		{ "default:steel_ingot", "dye:white", "default:steel_ingot" }
	}
})

minetest.register_craft({
	output = "streets:trafficlight_top_extender_left_off",
	recipe = {
		{ "dye:yellow", "default:steel_ingot", "default:steel_ingot" },
		{ "dye:green", "default:steel_ingot", "default:steel_ingot" }
	}
})

minetest.register_craft({
	output = "streets:trafficlight_top_extender_right_off",
	recipe = {
		{ "default:steel_ingot", "default:steel_ingot", "dye:yellow" },
		{ "default:steel_ingot", "default:steel_ingot", "dye:green" }
	}
})

minetest.register_craft({
	output = "streets:beacon_off",
	recipe = {
		{ "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" },
		{ "default:steel_ingot", "dye:red", "default:steel_ingot" },
		{ "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" }
	}
})

minetest.register_craft({
	output = "streets:beacon_hybrid_off",
	recipe = {
		{ "dye:red", "default:steel_ingot", "dye:red" },
		{ "default:steel_ingot", "dye:yellow", "default:steel_ingot" },
		{ "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" }
	}
})

minetest.register_craft({
	output = "streets:digiline_distributor",
	recipe = {
		{ "", "digilines:wire_std_00000000", "" },
		{ "digilines:wire_std_00000000", "mesecons_luacontroller:luacontroller0000", "digilines:wire_std_00000000" },
		{ "", "digilines:wire_std_00000000", "" }
	}
})

streets.portable_tl_on_receive_fields = function(pos, formname, fields, sender)
	local meta = minetest.get_meta(pos)
	if fields.normal then
		meta:set_string("mode", "Normal")
	elseif fields.yyflash then
		meta:set_string("mode", "Y-Y Flash")
	elseif fields.yrflash then
		meta:set_string("mode", "Y-R Flash")
	elseif fields.rrflash then
		meta:set_string("mode", "R-R Flash")
	elseif fields.save then
		if tonumber(fields.yellow) then
			meta:set_int("yellow", fields.yellow)
		end
		if tonumber(fields.allred) then
			meta:set_int("allred", fields.allred)
		end
		if tonumber(fields.maingreen) then
			meta:set_int("maingreen", fields.maingreen)
		end
		if tonumber(fields.sidegreen) then
			meta:set_int("sidegreen", fields.sidegreen)
		end
	end
end

local translate = {
	["Normal"] = "normální",
	["All Red A"] = "všude červená A",
	["All Red B"] = "všude červená B",
	["Yellow A"] = "žlutá A",
	["Yellow B"] = "žlutá B",
	["Main Green"] = "hlavní zelená",
	["Side Green"] = "vedlejší zelená",
	["R-R Flash"] = "Č-Č blikání",
	["Y-Y Flash"] = "Ž-Ž blikání",
	["Y-R Flash"] = "Ž-Č blikání",
	[""] = "",
}

streets.portable_tl_tick = function(pos, meta)
	local yellow = meta:get_int("yellow")
	local allred = meta:get_int("allred")
	local sidegreen = meta:get_int("sidegreen")
	local maingreen = meta:get_int("maingreen")
	local tick = meta:get_int("tick")
	local mode = meta:get_string("mode")
	local phase = meta:get_string("phase")
	local time = ""
	if mode == "Normal" then
		local phaselen = 0
		if phase == "All Red A" or phase == "All Red B" then
			phaselen = allred
		elseif phase == "Yellow A" or phase == "Yellow B" then
			phaselen = yellow
		elseif phase == "Side Green" then
			phaselen = sidegreen
		elseif phase == "Main Green" then
			phaselen = maingreen
		end
		tick = tick + 1
		if tick >= phaselen then
			tick = 0
			if phase == "All Red A" then
				phase = "Side Green"
			elseif phase == "Side Green" then
				phase = "Yellow B"
			elseif phase == "Yellow B" then
				phase = "All Red B"
			elseif phase == "All Red B" then
				phase = "Main Green"
			elseif phase == "Main Green" then
				phase = "Yellow A"
			elseif phase == "Yellow A" then
				phase = "All Red A"
			end
			if phase == "All Red A" or phase == "All Red B" then
				phaselen = allred
			elseif phase == "Yellow A" or phase == "Yellow B" then
				phaselen = yellow
			elseif phase == "Side Green" then
				phaselen = sidegreen
			elseif phase == "Main Green" then
				phaselen = maingreen
			end
		end
		time = string.format("zbývá %s z %s sekund", phaselen - tick, phaselen)
	end
	meta:set_int("tick", tick)
	local need_swap = phase ~= meta:get_string(phase)
	local swap_to = "streets:trafficlight_portable_rrflash"
	meta:set_string("phase", phase)

	if mode == "R-R Flash" then
		need_swap = true
		swap_to = "streets:trafficlight_portable_rrflash"
	elseif mode == "Y-Y Flash" then
		need_swap = true
		swap_to = "streets:trafficlight_portable_yyflash"
	elseif mode == "Y-R Flash" then
		need_swap = true
		swap_to = "streets:trafficlight_portable_yrflash"
	end

	if need_swap then
		if mode == "Normal" then
			if phase == "All Red A" or phase == "All Red B" then
				swap_to = "streets:trafficlight_portable_allred"
			elseif phase == "Yellow A" then
				swap_to = "streets:trafficlight_portable_yellowa"
			elseif phase == "Yellow B" then
				swap_to = "streets:trafficlight_portable_yellowb"
			elseif phase == "Main Green" then
				swap_to = "streets:trafficlight_portable_maingreen"
			elseif phase == "Side Green" then
				swap_to = "streets:trafficlight_portable_sidegreen"
			end
		end
		local node = minetest.get_node(pos)
		minetest.swap_node(pos, { name = swap_to, param2 = node.param2 })
	end

	local formspec = "size[8,4]" ..
			"label[0,0;Režim: " .. translate[mode] .. "]" ..
			"label[0,0.5;" .. (mode == "Normal" and "Fáze: " .. translate[phase] or "") .. "]" ..
			"label[0,1;" .. time .. "]" ..
			"label[0,2;Zvolte režim:]" ..
			"button[0,2.5;2,1;normal;Normální]" ..
			"button[2,2.5;2,1;rrflash;Č-Č blikání]" ..
			"button[0,3.5;2,1;yyflash;Ž-Ž blikání]" ..
			"button[2,3.5;2,1;yrflash;Ž-Č blikání]" ..
			"label[5.5,0;Nastavení časů:]"
	if mode == "Normální" then
		formspec = formspec .. "label[5.5,1;Za běhu nelze\nupravovat časy.\nZvolte nejprve režim blikání.]"
	else
		formspec = formspec .. "field[4.5,1;2,1;yellow;Žlutá;${yellow}]" ..
				"field[6.5,1;2,1;allred;Všude červená;${allred}]" ..
				"field[4.5,2;2,1;maingreen;Hlavní zelená;${maingreen}]" ..
				"field[6.5,2;2,1;sidegreen;Vedlejší zelená;${sidegreen}]" ..
				"button[5.25,3;2,1;save;Uložit]"
	end
	meta:set_string("formspec", formspec)
end

minetest.register_node(":streets:trafficlight_portable_off", {
	description = "přenosný semafor",
	inventory_image = "streets_trafficlight_inv_portable.png",
	groups = { cracky = 1, portable_tl = 1 },
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	drawtype = "nodebox",
	on_receive_fields = streets.portable_tl_on_receive_fields,
	tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_off.png", "streets_tl_off.png", "streets_tl_off.png", "streets_tl_off.png" },
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.1875, -0.5, -0.1875, 0.1875, 0.5, 0.1875 }, --Box

			--Needs visors at some point. Converting to a mesh would be best.
		}
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("yellow", 3)
		meta:set_int("allred", 2)
		meta:set_int("sidegreen", 5)
		meta:set_int("maingreen", 10)
		meta:set_int("tick", 0)
		meta:set_string("mode", "R-R Flash")
		meta:set_string("phase", "All Red A")
	end,
	light_source = 6,
})

minetest.register_node(":streets:trafficlight_portable_allred", {
	drop = "streets:trafficlight_portable_off",
	groups = { cracky = 1, portable_tl = 1, not_in_creative_inventory = 1 },
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	drawtype = "nodebox",
	on_receive_fields = streets.portable_tl_on_receive_fields,
	tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_red.png", "streets_tl_red.png", "streets_tl_red.png", "streets_tl_red.png" },
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.1875, -0.5, -0.1875, 0.1875, 0.5, 0.1875 }, --Box

			--Needs visors at some point. Converting to a mesh would be best.
		}
	},
	light_source = 6,
})

minetest.register_node(":streets:trafficlight_portable_yellowa", {
	drop = "streets:trafficlight_portable_off",
	groups = { cracky = 1, portable_tl = 1, not_in_creative_inventory = 1 },
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	drawtype = "nodebox",
	on_receive_fields = streets.portable_tl_on_receive_fields,
	tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_red.png", "streets_tl_red.png", "streets_tl_yellow.png", "streets_tl_yellow.png" },
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.1875, -0.5, -0.1875, 0.1875, 0.5, 0.1875 }, --Box

			--Needs visors at some point. Converting to a mesh would be best.
		}
	},
	light_source = 6,
})

minetest.register_node(":streets:trafficlight_portable_yellowb", {
	drop = "streets:trafficlight_portable_off",
	groups = { cracky = 1, portable_tl = 1, not_in_creative_inventory = 1 },
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	drawtype = "nodebox",
	on_receive_fields = streets.portable_tl_on_receive_fields,
	tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_yellow.png", "streets_tl_yellow.png", "streets_tl_red.png", "streets_tl_red.png" },
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.1875, -0.5, -0.1875, 0.1875, 0.5, 0.1875 }, --Box

			--Needs visors at some point. Converting to a mesh would be best.
		}
	},
	light_source = 6,
})

minetest.register_node(":streets:trafficlight_portable_maingreen", {
	drop = "streets:trafficlight_portable_off",
	groups = { cracky = 1, portable_tl = 1, not_in_creative_inventory = 1 },
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	drawtype = "nodebox",
	on_receive_fields = streets.portable_tl_on_receive_fields,
	tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_red.png", "streets_tl_red.png", "streets_tl_green.png", "streets_tl_green.png" },
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.1875, -0.5, -0.1875, 0.1875, 0.5, 0.1875 }, --Box

			--Needs visors at some point. Converting to a mesh would be best.
		}
	},
	light_source = 6,
})

minetest.register_node(":streets:trafficlight_portable_sidegreen", {
	drop = "streets:trafficlight_portable_off",
	groups = { cracky = 1, portable_tl = 1, not_in_creative_inventory = 1 },
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	drawtype = "nodebox",
	on_receive_fields = streets.portable_tl_on_receive_fields,
	tiles = { "streets_tl_bg.png", "streets_tl_bg.png", "streets_tl_green.png", "streets_tl_green.png", "streets_tl_red.png", "streets_tl_red.png" },
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.1875, -0.5, -0.1875, 0.1875, 0.5, 0.1875 }, --Box

			--Needs visors at some point. Converting to a mesh would be best.
		}
	},
	light_source = 6,
})

streets.portable_tl_tile_flashred = {
	name = "streets_tl_flashred.png",
	animation = { type = "vertical_frames", aspect_w = 64, aspect_h = 64, length = 1.2 }
}

streets.portable_tl_tile_flashyellow = {
	name = "streets_tl_warn.png",
	animation = { type = "vertical_frames", aspect_w = 64, aspect_h = 64, length = 1.2 }
}

minetest.register_node(":streets:trafficlight_portable_rrflash", {
	drop = "streets:trafficlight_portable_off",
	groups = { cracky = 1, portable_tl = 1, not_in_creative_inventory = 1 },
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	drawtype = "nodebox",
	on_receive_fields = streets.portable_tl_on_receive_fields,
	tiles = { "streets_tl_bg.png", "streets_tl_bg.png", streets.portable_tl_tile_flashred, streets.portable_tl_tile_flashred, streets.portable_tl_tile_flashred, streets.portable_tl_tile_flashred },
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.1875, -0.5, -0.1875, 0.1875, 0.5, 0.1875 }, --Box

			--Needs visors at some point. Converting to a mesh would be best.
		}
	},
	light_source = 6,
})

minetest.register_node(":streets:trafficlight_portable_yyflash", {
	drop = "streets:trafficlight_portable_off",
	groups = { cracky = 1, portable_tl = 1, not_in_creative_inventory = 1 },
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	drawtype = "nodebox",
	on_receive_fields = streets.portable_tl_on_receive_fields,
	tiles = { "streets_tl_bg.png", "streets_tl_bg.png", streets.portable_tl_tile_flashyellow, streets.portable_tl_tile_flashyellow, streets.portable_tl_tile_flashyellow, streets.portable_tl_tile_flashyellow },
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.1875, -0.5, -0.1875, 0.1875, 0.5, 0.1875 }, --Box

			--Needs visors at some point. Converting to a mesh would be best.
		}
	},
	light_source = 6,
})

minetest.register_node(":streets:trafficlight_portable_yrflash", {
	drop = "streets:trafficlight_portable_off",
	groups = { cracky = 1, portable_tl = 1, not_in_creative_inventory = 1 },
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	drawtype = "nodebox",
	on_receive_fields = streets.portable_tl_on_receive_fields,
	tiles = { "streets_tl_bg.png", "streets_tl_bg.png", streets.portable_tl_tile_flashred, streets.portable_tl_tile_flashred, streets.portable_tl_tile_flashyellow, streets.portable_tl_tile_flashyellow },
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.1875, -0.5, -0.1875, 0.1875, 0.5, 0.1875 }, --Box

			--Needs visors at some point. Converting to a mesh would be best.
		}
	},
	light_source = 6,
})

minetest.register_abm({
	nodenames = "group:portable_tl",
	interval = 1,
	chance = 1,
	action = function(pos)
		streets.portable_tl_tick(pos, minetest.get_meta(pos))
	end,
})

minetest.register_craft({
	output = "streets:trafficlight_portable_off",
	type = "shapeless",
	recipe = { "streets:trafficlight_top_off", "mesecons_luacontroller:luacontroller0000" }
})

--[[
minetest.register_node("streets:pedbutton_left", {
	drawtype = "nodebox",
	tiles = {
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_pedbutton_us_back.png",
		"streets_pedbutton_us_left.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_wallmounted = true,
	walkable = false,
	sunlight_propagates = true,
	selection_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, 0.65, 0.5, 0.5, 0.85 }
	},
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.1, -0.1, 0.7, 0.1, 0.1, 0.85 },
			{ -0.5, -0.5, 0.7, 0.5, 0.5, 0.7 },
			{ -0.06, -0.41, 0.7, 0.05, -0.32, 0.65 }
		}
	},
	{
		receptor = {}
	},
	groups = { cracky = 1 },
	description = "Pedestrian Crossing Button Assembly - Left",
})

minetest.register_node("streets:pedbutton_left_off", {
	drawtype = "nodebox",
	tiles = {
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_pedbutton_us_back.png",
		"streets_pedbutton_us_left.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_wallmounted = true,
	walkable = false,
	sunlight_propagates = true,
	selection_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, 0.65, 0.5, 0.5, 0.85 }
	},
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.1, -0.1, 0.7, 0.1, 0.1, 0.85 },
			{ -0.5, -0.5, 0.7, 0.5, 0.5, 0.7 },
			{ -0.06, -0.41, 0.7, 0.05, -0.32, 0.65 }
		}
	},
	digiline =
	{
		receptor = {}
	},
	groups = { cracky = 1, not_in_creative_inventory = 1 },
	drop = "streets:pedbutton_left",
	on_rightclick = function(pos)
		local meta = minetest.get_meta(pos)
		digiline:receptor_send(pos, digiline.rules.default, meta:get_string("channel"), meta:get_string("msg"))
	end,
	on_punch = function(pos)
		local meta = minetest.get_meta(pos)
		digiline:receptor_send(pos, digiline.rules.default, meta:get_string("channel"), meta:get_string("msg"))
	end,
})

minetest.register_node("streets:pedbutton_right", {
	drawtype = "nodebox",
	tiles = {
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_pedbutton_us_back.png",
		"streets_pedbutton_us_right.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_wallmounted = true,
	walkable = false,
	sunlight_propagates = true,
	selection_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, 0.65, 0.5, 0.5, 0.85 }
	},
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.1, -0.1, 0.7, 0.1, 0.1, 0.85 },
			{ -0.5, -0.5, 0.7, 0.5, 0.5, 0.7 },
			{ -0.06, -0.41, 0.7, 0.05, -0.32, 0.65 }
		}
	},
	{
		receptor = {}
	},
	groups = { cracky = 1 },
	description = "Pedestrian Crossing Button Assembly - Right",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "size[8,4;]field[1,1;6,2;channel;Channel;${channel}]field[1,2;6,2;msg;Message;${msg}]button_exit[2.25,3;3,1;submit;Save]")
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		if fields.channel and fields.msg and fields.channel ~= "" and fields.msg ~= "" then
			meta:set_string("channel", fields.channel)
			meta:set_string("msg", fields.msg)
			meta:set_string("formspec", "")
			minetest.swap_node(pos, { name = "streets:pedbutton_right_off", param2 = minetest.get_node(pos).param2 })
		else
			minetest.chat_send_player(sender:get_player_name(), "Channel and message must both be set!")
		end
	end,
})

minetest.register_node("streets:pedbutton_right_off", {
	drawtype = "nodebox",
	tiles = {
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_tl_bg.png",
		"streets_pedbutton_us_back.png",
		"streets_pedbutton_us_right.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_wallmounted = true,
	walkable = false,
	sunlight_propagates = true,
	selection_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, 0.65, 0.5, 0.5, 0.85 }
	},
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.1, -0.1, 0.7, 0.1, 0.1, 0.85 },
			{ -0.5, -0.5, 0.7, 0.5, 0.5, 0.7 },
			{ -0.06, -0.41, 0.7, 0.05, -0.32, 0.65 }
		}
	},
	digiline =
	{
		receptor = {}
	},
	groups = { cracky = 1, not_in_creative_inventory = 1 },
	drop = "streets:pedbutton_right",
	on_rightclick = function(pos)
		local meta = minetest.get_meta(pos)
		digiline:receptor_send(pos, digiline.rules.default, meta:get_string("channel"), meta:get_string("msg"))
	end,
	on_punch = function(pos)
		local meta = minetest.get_meta(pos)
		digiline:receptor_send(pos, digiline.rules.default, meta:get_string("channel"), meta:get_string("msg"))
	end,
})

minetest.register_craft({
	output = "streets:pedbutton_left",
	type = "shapeless",
	recipe = { "streets:sign_us_pushtocross_left", "digilines:wire_std_00000000" }
})

minetest.register_craft({
	output = "streets:pedbutton_right",
	type = "shapeless",
	recipe = { "streets:sign_us_pushtocross_right", "digilines:wire_std_00000000" }
})
]]
