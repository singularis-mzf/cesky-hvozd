screwdriver = screwdriver or {}

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

pkarcs_doors3 = {}

-- Register Door Nodes
pkarcs_doors3.door = {
	{
		"acacia_wood",
		"z akáciového dřeva",
		{choppy = 2, door = 1},
		default.node_sound_wood_defaults(),
		"doors_door",
		{name = "pkarcs_doors3_acacia.png", backface_culling = true},
		"default:acacia_wood"
	},

	{
		"aspen_wood",
		"z osikového dřeva",
		{choppy = 2, door = 1},
		default.node_sound_wood_defaults(),
		"doors_door",
		{name = "pkarcs_doors3_aspen.png", backface_culling = true},
		"default:aspen_wood"
	},

	{
		"junglewood",
		"z dřeva džunglovníku",
		{choppy = 2, door = 1},
		default.node_sound_wood_defaults(),
		"doors_door",
		{name = "pkarcs_doors3_junglewood.png", backface_culling = true},
		"default:junglewood"
	},

	{
		"pine_wood",
		"z borového dřeva",
		{choppy = 2, door = 1},
		default.node_sound_wood_defaults(),
		"doors_door",
		{name = "pkarcs_doors3_pine.png", backface_culling = true},
		"default:pine_wood"
	},

	{
		"wood",
		"z jabloňového dřeva",
		{choppy = 2, door = 1},
		default.node_sound_wood_defaults(),
		"doors_door",
		{name = "pkarcs_doors3_wood.png", backface_culling = true},
		"default:wood"
	},

	{
		"bronze",
		"z bronzu",
		{cracky = 1, level = 2, door = 1},
		default.node_sound_metal_defaults(),
		"doors_steel_door",
		{name = "pkarcs_doors3_bronze.png", backface_culling = true},
		"default:bronzeblock"
	},

	{
		"copper",
		"z mědi",
		{cracky = 1, level = 2, door = 1},
		default.node_sound_metal_defaults(),
		"doors_steel_door",
		{name = "pkarcs_doors3_copper.png", backface_culling = true},
		"default:copperblock"
	},

	{
		"iron",
		"ze železa",
		{cracky = 1, level = 2, door = 1},
		default.node_sound_metal_defaults(),
		"doors_steel_door",
		{name = "pkarcs_doors3_iron.png", backface_culling = true},
		"default:iron_lump"
	},

	{
		"steel",
		"z oceli",
		{cracky = 1, level = 2, door = 1},
		default.node_sound_metal_defaults(),
		"doors_steel_door",
		{name = "pkarcs_doors3_steel.png", backface_culling = true},
		"default:steelblock"
	},

	{
		"tin",
		"z cínu",
		{cracky = 1, level = 2, door = 1},
		default.node_sound_metal_defaults(),
		"doors_steel_door",
		{name = "pkarcs_doors3_tin.png", backface_culling = true},
		"default:tinblock"
	},

	{
		"bar",
		"z kovových mříží",
		{cracky = 1, level = 2, door = 1},
		default.node_sound_metal_defaults(),
		"doors_steel_door",
		{name = "pkarcs_doors3_bar.png", backface_culling = true},
		"xpanes:bar_flat"
	},
}


-- open and close actions as generalized functions
pkarcs_doors3.open = function (pos, node, name, side, door_sound)
	local meta = minetest.get_meta(pos)
	local timer = minetest.get_node_timer(pos)
	if not side or side == "L" then
		minetest.swap_node(pos, {name = "pkarcs_doors3:" ..name.. "_Ldoor_open", param2 = node.param2})
	elseif side == "R" or side then
		minetest.swap_node(pos, {name = "pkarcs_doors3:" ..name.. "_Rdoor_open", param2 = node.param2})
	end
	minetest.sound_play(door_sound.."_open", {pos = pos, gain = 0.20, max_hear_distance = 10})
	if meta:get_int("zavirasamo") > 0 then
		timer:start(1)
	end
end

pkarcs_doors3.close = function (pos, node, name, side, door_sound)
	local meta = minetest.get_meta(pos)
	local timer = minetest.get_node_timer(pos)
	if not side or side == "L" then
		minetest.swap_node(pos, {name = "pkarcs_doors3:" ..name.. "_Ldoor", param2 = node.param2})
	elseif side == "R" or side then
		minetest.swap_node(pos, {name = "pkarcs_doors3:" ..name.. "_Rdoor", param2 = node.param2})
	end
	minetest.sound_play(door_sound.."_close", {pos = pos, gain = 0.15, max_hear_distance = 10})
	if meta:get_int("zavirasamo") > 0 then
		timer:stop()
	end
end

local function pkarcs_state(self)
	local ndef = minetest.registered_nodes[minetest.get_node(self.pos).name]
	return ndef and ndef._pkarcs_is_open
end

local function pkarcs_toggle(self, player)
	local meta = minetest.get_meta(self.pos)
	if player and not doors.check_player_privs(self.pos, meta, player) then
		return false
	end
	local node = minetest.get_node(self.pos)
	local ndef = minetest.registered_nodes[node.name]
	if ndef._pkarcs_on_open then
		return ndef._pkarcs_on_open(self.pos, node, player)
	elseif ndef._pkarcs_on_close then
		return ndef._pkarcs_on_close(self.pos, node, player)
	end
end

local function pkarcs_open(self, player)
	local meta = minetest.get_meta(self.pos)
	if player and not doors.check_player_privs(self.pos, meta, player) then
		return false
	end
	local node = minetest.get_node(self.pos)
	local ndef = minetest.registered_nodes[node.name]
	if ndef._pkarcs_on_open then
		return ndef._pkarcs_on_open(self.pos, node, player)
	end
end

local function pkarcs_close(self, player)
	local meta = minetest.get_meta(self.pos)
	if player and not doors.check_player_privs(self.pos, meta, player) then
		return false
	end
	local node = minetest.get_node(self.pos)
	local ndef = minetest.registered_nodes[node.name]
	if ndef._pkarcs_on_close then
		return ndef._pkarcs_on_close(self.pos, node, player)
	end
end

local pkarcs_class = {
	open = pkarcs_open,
	close = pkarcs_close,
	toggle = pkarcs_toggle,
	state = pkarcs_state,
}

for _, row in ipairs(pkarcs_doors3.door) do
	local name = row[1]
	local desc = row[2]
	local mat_groups = row[3]
	local mat_groups_nici = table.copy(row[3])
	local mat_sound = row[4]
	local door_sound = row[5]
	local door_tiles = row[6]
	local craft_material = row[7]

	mat_groups_nici.not_in_creative_inventory = 1

	local Ldoor_def = {
		description = "zaoblené dveře levé (výška 3 m) " .. desc,
		inventory_image = "pkarcs_doors3_" ..name.. "_item.png",
		wield_image = "pkarcs_doors3_" ..name.. "_item.png",
		drawtype = "mesh",
		mesh = "pkarcs_doors3_L.obj",
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
				{-0.5, -0.5, -0.5, 0.5, 2.4375, -0.375},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 2.4375, -0.375},
			},
		},
		on_rightclick = doors.door_rightclick,
		on_timer = doors.on_timer,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			local player_name = placer:get_player_name()
			local meta = minetest.get_meta(pos)
			meta:set_string("placer", player_name)
			doors.update_infotext(pos, nil, meta)
			return minetest.is_creative_enabled(player_name)
		end,
		_pkarcs_is_open = false,
		_pkarcs_on_open = function(pos, node, puncher)
			pkarcs_doors3.open(pos, node, name, "L", door_sound)
		end,
	}
	
	if minetest.get_modpath("mesecons") then
		Ldoor_def.mesecons = {
			effector = {
				action_on = function(pos, node)
					pkarcs_doors3.open(pos, node, name, "L", door_sound)
				end,
				rules = mesecon.rules.pplate
			}
		}
	end
	
	minetest.register_node(":pkarcs_doors3:" ..name.. "_Ldoor", Ldoor_def)
	doors.register_custom_door("pkarcs_doors3:"..name.."_Ldoor", pkarcs_class)

	local Ldoor_open_def = {
		drawtype = "mesh",
		mesh = "pkarcs_doors3_L_open.obj",
		tiles = {door_tiles},
		use_texture_alpha = "clip",
		paramtype = "light",
		paramtype2 = "facedir",
		on_rotate = screwdriver.rotate_simple,
		legacy_facedir_simple = true,
		sunlight_propogates = true,
		is_ground_content = false,
		groups = mat_groups_nici,
		drop = "pkarcs_doors3:" ..name.. "_Ldoor",
		sounds = mat_sound,
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -1.4375, -0.375, 2.4375, -0.4375},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -1.4375, -0.375, 2.4375, -0.4375},
			},
		},
		on_rightclick = doors.door_rightclick,
		on_timer = doors.on_timer,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			local player_name = placer:get_player_name()
			local meta = minetest.get_meta(pos)
			meta:set_string("placer", player_name)
			doors.update_infotext(pos, nil, meta)
			return minetest.is_creative_enabled(player_name)
		end,
		_pkarcs_on_close = function(pos, node, puncher)
			pkarcs_doors3.close(pos, node, name, "L", door_sound)
		end,
		_pkarcs_is_open = true,
	}
	
		if minetest.get_modpath("mesecons") then
		Ldoor_open_def.mesecons = {
			effector = {
				action_off = function(pos, node)
					pkarcs_doors3.close(pos, node, name, "L", door_sound)
				end,
				rules = mesecon.rules.pplate
			}
		}
	end

	minetest.register_node(":pkarcs_doors3:" ..name.. "_Ldoor_open", Ldoor_open_def)
	doors.register_custom_door("pkarcs_doors3:"..name.."_Ldoor_open", pkarcs_class)

	local Rdoor_def = {
		description = "zaoblené dveře pravé (výška 3 m) " .. desc,
		inventory_image = "pkarcs_doors3_" ..name.. "_item.png^[transformFXX",
		wield_image = "pkarcs_doors3_" ..name.. "_item.png^[transformFXX",
		drawtype = "mesh",
		mesh = "pkarcs_doors3_R.obj",
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
				{-0.5, -0.5, -0.5, 0.5, 2.4375, -0.375},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 2.4375, -0.375},
			},
		},
		on_rightclick = doors.door_rightclick,
		on_timer = doors.on_timer,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			local player_name = placer:get_player_name()
			local meta = minetest.get_meta(pos)
			meta:set_string("placer", player_name)
			doors.update_infotext(pos, nil, meta)
			return minetest.is_creative_enabled(player_name)
		end,
		_pkarcs_on_open = function(pos, node, puncher)
			pkarcs_doors3.open(pos, node, name, "R", door_sound)
		end,
		_pkarcs_is_open = false,
	}

	if minetest.get_modpath("mesecons") then
		Rdoor_def.mesecons = {
			effector = {
				action_on = function(pos, node)
					pkarcs_doors3.open(pos, node, name, "R", door_sound)
				end,
				rules = mesecon.rules.pplate
			}
		}
	end

	minetest.register_node(":pkarcs_doors3:" ..name.. "_Rdoor", Rdoor_def)
	doors.register_custom_door("pkarcs_doors3:"..name.."_Rdoor", pkarcs_class)

	local Rdoor_open_def = {
		drawtype = "mesh",
		mesh = "pkarcs_doors3_R_open.obj",
		tiles = {door_tiles},
		use_texture_alpha = "clip",
		paramtype = "light",
		paramtype2 = "facedir",
		on_rotate = screwdriver.rotate_simple,
		legacy_facedir_simple = true,
		sunlight_propogates = true,
		is_ground_content = false,
		groups = mat_groups_nici,
		drop = "pkarcs_doors3:" ..name.. "_Rdoor",
		sounds = mat_sound,
		selection_box = {
			type = "fixed",
			fixed = {
				{0.375, -0.5, -1.4375, 0.5, 2.4375, -0.4375},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{0.375, -0.5, -1.4375, 0.5, 2.4375, -0.4375},
			},
		},
		on_rightclick = doors.door_rightclick,
		on_timer = doors.on_timer,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			local player_name = placer:get_player_name()
			local meta = minetest.get_meta(pos)
			meta:set_string("placer", player_name)
			doors.update_infotext(pos, nil, meta)
			return minetest.is_creative_enabled(player_name)
		end,
		_pkarcs_on_close = function(pos, node, puncher)
			pkarcs_doors3.close(pos, node, name, "R", door_sound)
		end,
		_pkarcs_is_open = true,
	}

		if minetest.get_modpath("mesecons") then
		Rdoor_open_def.mesecons = {
			effector = {
				action_off = function(pos, node)
					pkarcs_doors3.close(pos, node, name, "R", door_sound)
				end,
				rules = mesecon.rules.pplate
			}
		}
	end

	minetest.register_node(":pkarcs_doors3:" ..name.. "_Rdoor_open", Rdoor_open_def)
	doors.register_custom_door("pkarcs_doors3:"..name.."_Rdoor_open", pkarcs_class)

--
-- Crafting
--

	minetest.register_craft({
		output = "pkarcs_doors3:" ..name.. "_Ldoor",
		recipe = {
			{"", craft_material, ""},
			{craft_material, craft_material, ""},
			{craft_material, craft_material, ""},
		}
	})

	minetest.register_craft({
		output = "pkarcs_doors3:" ..name.. "_Rdoor",
		recipe = {
			{"", craft_material, ""},
			{"", craft_material, craft_material},
			{"", craft_material, craft_material},
		}
	})
end
print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
