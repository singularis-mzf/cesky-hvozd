--------------------------------------------------------
-- Minetest :: Generic Flags Mod (flags)
--
-- See README.txt for licensing and other information.
-- Made by AwesomeDragon97 with code from Wuzzy.
-- Modified for Český Hvozd server by Singularis
--------------------------------------------------------

local wind_noise = PerlinNoise( 204, 1, 0, 500 )
-- Check whether the new `get_2d` Perlin function is available,
-- otherwise use `get2d`. Needed to suppress deprecation
-- warning in newer Minetest versions.
local old_get2d = true
if wind_noise.get_2d then
	old_get2d = false
end
local active_flags = {}

local pi = math.pi
local rad_180 = pi
local rad_90 = pi / 2

-- This flag is used as the default or fallback in case of error/missing data
local DEFAULT_FLAG = "white"

generic_flags = {
	flag_list = {}, -- i => flag_def
	flag_index = {}, -- name => i
}

local flag_list, flag_index = generic_flags.flag_list, generic_flags.flag_index

--[[
	flag_def = {
		name = "",
		description = "",
		[ on_holiday = "cz|sk" ],
		[ texture = "image.png" ],
	}
]]

local cz = {cz = true}
local sk = {sk = true}
local cz_sk = {cz = true, sk = true}

local holidays = {
	["01-01"] = cz_sk, -- Nový rok, Deň vzniku Slovenskej republiky
	-- ["05-01"] = cz, -- Svátek práce
	["05-08"] = cz, -- Den vítězství
	["07-05"] = cz_sk, -- Den slovanských věrozvěstů Cyrila a Metoděje, Sviatok svätého Cyrila a svätého Metoda
	["07-06"] = cz, -- Den upálení mistra Jana Husa
	["08-29"] = sk, -- Výročie Slovenského národného povstania
	["09-01"] = sk, -- Deň Ústavy Slovenskej republiky
	["09-28"] = cz, -- Den české státnosti
	["10-28"] = cz_sk, -- Den vzniku samostatného československého státu, Deň vzniku samostatného česko-slovenského štátu
	["11-17"] = cz_sk, -- Den boje za svobodu a demokracii a Mezinárodní den studentstva, Deň boja za slobodu a demokraciu
	["12-03"] = cz_sk, -- (výročí otevření Českého hvozdu)
	-- ["12-24"] = cz, -- Štědrý den
	-- ["12-25"] = cz, -- 1. svátek vánoční
	-- ["12-26"] = cz, -- 2. svátek vánoční
}

local function is_holiday(country, year, month, day)
	local def = holidays[string.format("%02d-%02d", month, day)]
	return (def and def[country]) ~= nil
end

local function get_texture_from_flag_name(flag_name)
	local flag_idx = flag_index[flag_name]
	local flag_def = flag_idx and flag_list[flag_idx]
	return flag_def and flag_def.texture or "ch_core_empty.png"
end

-- returns true for inactive dynamic flags, false for active dynamic flags and nil for non-dynamic and unknown flags
local function is_flag_inactive(flag_name)
	local flag_idx = flag_index[flag_name]
	local flag_def = flag_idx and flag_list[flag_idx]
	if flag_def == nil or flag_def.on_holiday == nil then
		return nil -- unknown or non-dynamic flag
	end
	local now = ch_core.aktualni_cas()
	if is_holiday(flag_def.on_holiday, now.rok, now.mesic, now.den) then
		return false
	else
		return true
	end
end

local function on_place_flag(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" or itemstack:is_empty() then
		return itemstack
	end
	local item_def = minetest.registered_items[itemstack:get_name()]
	local flag_name = item_def and item_def._flag_name
	if flag_name == nil or flag_index[flag_name] == nil then
		return itemstack
	end
	local pos = pointed_thing.under
	local pos_under = vector.offset(pos, 0, -1, 0)
	local node = minetest.get_node(pos)
	local node2 = minetest.get_node(pos_under)
	if (node.name ~= "generic_flags:lower_mast" or node2.name ~= "generic_flags:lower_mast") then
		return itemstack
	end

	local pn = placer:get_player_name()
	if minetest.is_protected(pos, pn) then
		minetest.record_protection_violation(pointed_thing.under, pn)
		return itemstack
	elseif minetest.is_protected(pos_under, pn) then
		minetest.record_protection_violation(pos_under, pn)
		return itemstack
	end

	local yaw = placer:get_look_horizontal()
	local dir = minetest.yaw_to_dir(yaw)
	local param2 = (minetest.dir_to_facedir(dir) + 3) % 4
	minetest.set_node(pos_under, {name = "generic_flags:upper_mast", param2 = param2 })
	minetest.set_node(pos, {name = "generic_flags:upper_mast_hidden_1"})

	-- function generic_flags.set_flag_at(pos, flag_name)
	generic_flags.set_flag_at(pos_under, flag_name)

	if not (minetest.is_creative_enabled(pn)) then
		itemstack:take_item()
	end

	local def = minetest.registered_nodes["generic_flags:upper_mast"]
	if def and def.sounds then
		minetest.sound_play(def.sounds.place, {pos = pos}, true)
	end

	return itemstack
end

function generic_flags.add_flag(name, flag_def)
	if flag_index[name] ~= nil then
		return false
	end
	local i = #flag_list + 1
	flag_def = table.copy(flag_def)
	flag_list[i] = flag_def
	flag_def.name = name
	if flag_def.texture == nil then
		if flag_def.color ~= nil then
			flag_def.texture = "ch_core_white_pixel.png^[multiply:"..flag_def.color.."^[resize:13x10"
		else
			flag_def.texture = "flag_"..name..".png"
		end
	end
	flag_index[name] = i

	local groups = {flag = 1}
	if flag_def.on_holiday ~= nil then
		groups.dynamic_flag = 1
	end

	local image = "ch_core_white_pixel.png\\^[multiply\\:#999999\\^[resize\\:52x1"
	image = "[combine:64x64:0,0=flags_pole_top_inv.png\\^[resize\\:64x64:12,4=("..flag_def.texture:gsub("([%^:])", "\\%1")..")\\^[resize\\:52x48:12,4="..image..":12,51="..image
	-- image = "[combine:64x64:12,4=ch_core_white_pixel.png\\^[resize:52x4:12,51=ch_core_white_pixel.png\\^[resize:64x64"
	-- flag_def.texture
	local def = {
		description = flag_def.description,
		inventory_image = image, -- TODO
		range = 30,
		on_place = on_place_flag,
		groups = groups,
		_flag_name = name,
		_ch_help = "Pro umístění vlajky na stožár je potřeba postavit alespoň dva díly stožáru\nna vlajky nad sebe a pravým klikem aplikovat vlajku na horní díl stožáru.\nVytěžením dílu s vlajkou získáte vlajku zpět. Umístěnou vlajku lze otáčet jen vodorovně.",
		_ch_help_group = "gflag",
	}
	minetest.register_craftitem("generic_flags:"..name, def)
	return true
end

local function color_texture(color)
	return "ch_core_white_pixel.png^[multiply:"..color.."^[resize:13x10"
end

generic_flags.add_flag("white", {description = "bílá vlajka (na stožár)", color = "#ffffff"})
generic_flags.add_flag("red", {description = "červená vlajka (na stožár)", color = "#fb0207"})
generic_flags.add_flag("green", {description = "zelená vlajka (na stožár)", color = "#21ff06"})
generic_flags.add_flag("brown", {description = "hnědá vlajka (na stožár)", color = "#996633"})
generic_flags.add_flag("blue", {description = "modrá vlajka (na stožár)", color = "#0003ff"})
generic_flags.add_flag("black", {description = "černá vlajka (na stožár)", color = "#000000"})
generic_flags.add_flag("orange", {description = "oranžová vlajka (na stožár)", color = "#ff0691"})
generic_flags.add_flag("yellow", {description = "žlutá vlajka (na stožár)", color = "#ffff0a"})
generic_flags.add_flag("purple", {description = "purpurová vlajka (na stožár)", color = "#80017f"})
generic_flags.add_flag("pink", {description = "světle růžová vlajka (na stožár)", color = "#fda49f"})
generic_flags.add_flag("gray", {description = "šedá vlajka (na stožár)", color = "#7f7f7f"})
generic_flags.add_flag("cyan", {description = "tyrkysová vlajka (na stožár)", color = "#0f79a5"})
generic_flags.add_flag("magenta", {description = "tmavě růžová vlajka (na stožár)", color = "#ff0691"})
generic_flags.add_flag("dark_green", {description = "tmavě zelená vlajka (na stožár)", color = "#107e02"})
generic_flags.add_flag("dark_gray", {description = "tmavě šedá vlajka (na stožár)", color = "#4d4d4d"})
generic_flags.add_flag("cz", {description = "vlajka České republiky (na stožár)", texture = "flag_cz.png"})
generic_flags.add_flag("sk", {description = "vlajka Slovenska (na stožár)", texture = "flag_sk.png"})
generic_flags.add_flag("czx", {description = "vlajka České republiky (na stožár, jen o svátcích)", texture = "flag_cz.png", on_holiday = "cz"})
generic_flags.add_flag("skx", {description = "vlajka Slovenska (na stožár, jen o svátcích)", texture = "flag_sk.png", on_holiday = "sk"})

local function flag_exists(flag_name)
	return flag_index[flag_name] ~= nil
end

-- Delete entity if there is no flag mast node
local function delete_if_orphan(self)
	local pos = self.object:get_pos()
	local node = minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z})
	if node.name ~= "generic_flags:upper_mast" and node.name ~= "ignore" then
		minetest.log("action", "[flags] Orphan flag entity removed at "..minetest.pos_to_string(pos, 1))
		self.object:remove()
		return true
	end
	return false
end

local function entity_on_activate(self, staticdata, dtime)
	if delete_if_orphan(self) then
		return
	end
	-- Init stuff
	self:reset_animation(true)
	self.object:set_armor_groups( { immortal = 1 } )

	if staticdata ~= "" then
		local data = minetest.deserialize( staticdata )
		if data.flag_name then
			self.flag_name = data.flag_name
		else
			self.flag_name = DEFAULT_FLAG
		end
		self.node_idx = data.node_idx

		if not self.flag_name or not self.node_idx then
			self.object:remove( )
			return
		end

		self:reset_texture( self.flag_name )

		active_flags[self.node_idx] = self.object
	else
		self.flag_name = DEFAULT_FLAG
	end

	-- Delete entity if there is already one for this pos
	local objs = minetest.get_objects_inside_radius( self.object:get_pos(), 0.5 )
	for o=1, #objs do
		local obj = objs[o]
		local lua = obj:get_luaentity( )
		if lua and self ~= lua and lua.name == "generic_flags:wavingflag" then
			if lua.node_idx == self.node_idx then
				self.object:remove()
				return
			end
		end
	end
end

local function entity_on_deactivate(self)
	if self.sound_id then
		minetest.sound_stop(self.sound_id)
	end
end

local function entity_on_step(self, dtime)
	self.anim_timer = self.anim_timer - dtime

	if self.anim_timer <= 0 then
		if delete_if_orphan( self) then
			return
		end
		self:reset_animation()
	end
end

local function entity_reset_animation(self, initial)
	local flag_name = self.flag_name
	local is_inactive = is_flag_inactive(flag_name)
	local pos = self.object:get_pos()
	local cur_wind = generic_flags.get_wind( pos )
	minetest.log("verbose", "[flags] Current wind at "..minetest.pos_to_string(pos, 1)..": " .. cur_wind)
	local anim_speed
	local wave_sound

	if cur_wind < 10 then
		anim_speed = 10	-- 2 cycle
		wave_sound = "flags_flagwave1"
	elseif cur_wind < 20 then
		anim_speed = 20  -- 4 cycles
		wave_sound = "flags_flagwave1"
	elseif cur_wind < 40 then
		anim_speed = 40  -- 8 cycles
		wave_sound = "flags_flagwave2"
	else
		anim_speed = 80  -- 16 cycles
		wave_sound = "flags_flagwave3"
	end
	-- slightly anim_speed change to desyncronize flag waving
	anim_speed = anim_speed + math.random(0, 200) * 0.01

	if self.object then
		if initial or (not self.object.set_animation_frame_speed) then
			self.object:set_animation( { x = 1, y = 575 }, anim_speed, 0, true )
		else
			self.object:set_animation_frame_speed(anim_speed)
		end
	end
	if is_inactive then
		if self.sound_id then
			minetest.sound_stop(self.sound_id)
			self.sound_id = nil
		end
	else
		if not self.sound_id then
			self.sound_id = minetest.sound_play( wave_sound, { object = self.object, gain = 0.2, loop = true } )
		end
	end

	self.anim_timer = 115 + math.random(-10, 10) -- time to reset animation
end

local function entity_reset_texture(self, flag_name)
	self.flag_name = flag_name
	local texture
	if is_flag_inactive(flag_name) then
		texture = "ch_core_empty.png"
	else
		texture = get_texture_from_flag_name(flag_name)
	end
	self.object:set_properties( { textures = { texture } } )
	self:reset_animation()
	return self.flag_name
end

local function entity_get_staticdata(self)
	return minetest.serialize( {
		node_idx = self.node_idx,
		flag_name = self.flag_name,
	} )
end

minetest.register_entity( "generic_flags:wavingflag", {
	initial_properties = {
		physical = false,
		visual = "mesh",
		visual_size = { x = 8.5, y = 8.5 },
		collisionbox = { 0, 0, 0, 0, 0, 0 },
		backface_culling = false,
		pointable = false,
		mesh = "flags_wavingflag.b3d",
		textures = { "flag_" .. DEFAULT_FLAG .. ".png" },
		use_texture_alpha = false,
	},

	on_activate = entity_on_activate,
	on_deactivate = entity_on_deactivate,
	on_step = entity_on_step,
	reset_animation = entity_reset_animation,
	reset_texture = entity_reset_texture,
	get_staticdata = entity_get_staticdata,
})

local metal_sounds = default.node_sound_metal_defaults()
local lower_mast_box = {
	type = "fixed",
	fixed = { -2/16, -1/2, -2/16, 2/16, 1/2, 2/16 },
}

minetest.register_node("generic_flags:lower_mast", {
	description = ("stožár na vlajku"),
	drawtype = "mesh",
	paramtype = "light",
	mesh = "flags_mast_lower.obj",
	paramtype2 = "facedir",
	tiles = { "flags_baremetal.png", "flags_baremetal.png" },
	wield_image = "flags_pole_bottom_inv.png",
	inventory_image = "flags_pole_bottom_inv.png",
	groups = { cracky = 2 },
	sounds = default.node_sound_metal_defaults(),
	is_ground_content = false,

	selection_box = lower_mast_box,
	collision_box = lower_mast_box,

	on_rotate = function(pos, node, user, mode, new_param2)
		if new_param2 > 3 then
			return false
		end
	end,
})

local function get_flag_pos(pos, param2)
	local facedir_to_pos = {
		[0] = { x = 0, y = 0.5, z = -0.125 },
		[1] = { x = -0.125, y = 0.5, z = 0 },
		[2] = { x = 0, y = 0.5, z = 0.125 },
		[3] = { x = 0.125, y = 0.5, z = 0 },
	}
	return vector.add( pos, vector.multiply( facedir_to_pos[ param2 ], 1 ) )
end

local function rotate_flag_by_param2( flag, param2 )
	local facedir_to_yaw = {
		[0] = rad_90,
		[1] = 0,
		[2] = -rad_90,
		[3] = rad_180,
	}
	local baseyaw = facedir_to_yaw[ param2 ]
	if not baseyaw then
		minetest.log("warning", "[flags] Unsupported flag pole node param2: "..tostring(param2))
		return
	end
	flag:set_yaw( baseyaw - rad_180 )
end

local function spawn_flag( pos )
	local node_idx = minetest.hash_node_position( pos )
	local param2 = minetest.get_node( pos ).param2

	local flag_pos = get_flag_pos( pos, param2 )
	local obj = minetest.add_entity( flag_pos, "generic_flags:wavingflag" )
	if not obj or not obj:get_luaentity( ) then
		return
	end

	obj:get_luaentity( ).node_idx = node_idx
	rotate_flag_by_param2( obj, param2 )

	active_flags[ node_idx ] = obj
	return obj
end

local function spawn_flag_and_set_texture( pos )
	local flag = spawn_flag( pos )
	if flag and flag:get_luaentity() then
		local meta = minetest.get_meta( pos )
		local flag_name = meta:get_string("flag_name")
		if flag_name == "" then
			flag_name = DEFAULT_FLAG
			meta:set_string("flag_idx", "")
			meta:set_string("flag_name", flag_name)
		end
		local entity = flag:get_luaentity()
		entity:reset_texture( flag_name )
		entity:reset_animation()
	end
	return flag
end

local function update_dynamic_flag(pos, node)
	if node.name ~= "generic_flags:upper_mast" then return end
	local meta = minetest.get_meta(pos)
	local flag_name = meta:get_string("flag_name")
	local is_inactive = is_flag_inactive(flag_name)
	if is_inactive == nil then return end -- non-dynamic or unknown flag
	local is_inactive_value = meta:get_int("flag_inactive")
	if is_inactive then
		if is_inactive_value == 1 then
			return -- everything is OK
		else
			is_inactive_value = 1
		end
	else
		if is_inactive_value == 0 then
			return -- everything is OK
		else
			is_inactive_value = 0
		end
	end
	meta:set_int("flag_inactive", is_inactive_value)
	local node_idx = minetest.hash_node_position(pos)
	local aflag = active_flags[node_idx]
	local flag = aflag and aflag:get_luaentity()
	if not flag then
		return -- entity not found
	end
	flag:reset_texture(flag_name)
	meta:set_string("flag_name", flag_name)
	minetest.log("verbose", "[generic_flags] dynamic flag "..flag_name.." at "..minetest.pos_to_string(pos).." updated to flag_inactive = "..is_inactive_value)
end

--[[
local function change_flag(pos, flag_name)
	if flag_index[flag_name] == nil then
		return false
	end
	local node_idx = minetest.hash_node_position( pos )
	local aflag = active_flags[node_idx]
	local flag
	if aflag then
		flag = aflag:get_luaentity()
	end
	if flag then
		local meta = minetest.get_meta( pos )
		meta:set_string("flag_name", flag_name)
		flag:reset_texture(flag_name)
	else
		spawn_flag_and_set_texture(pos)
	end
	return true
end
]]

local upper_mast_box = {
	type = "fixed",
	fixed = { -2/16, -1/2, -2/16, 2/16, 3/2, 2/16 },
}

local function um_on_construct(pos)
	local flag = spawn_flag(pos)
	if flag and flag:get_luaentity() then
		local meta = minetest.get_meta( pos )
		meta:set_string("flag_name", flag:get_luaentity().flag_name)
	end
end

local function um_on_destruct(pos)
	local node_idx = minetest.hash_node_position(pos)
	if active_flags[ node_idx ] then
		active_flags[ node_idx ]:remove()
	end
end

local function um_after_destruct(pos)
	local above1 = {x=pos.x, y=pos.y+1, z=pos.z}
	if minetest.get_node( above1 ).name == "generic_flags:upper_mast_hidden_1" then
		minetest.remove_node( above1 )
	end
end

local function um_on_rotate(pos, node, user, mode, new_param2)
	if new_param2 > 3 then
		return false
	end
	local node_idx = minetest.hash_node_position( pos )
	local aflag = active_flags[ node_idx ]
	if aflag then
		local lua = aflag:get_luaentity( )
		if not lua then
			aflag = spawn_flag_and_set_texture( pos )
			if aflag then
				lua = aflag:get_luaentity()
				if not lua then
					return
				end
			end
		end
		local flag_pos_idx = lua.node_idx
		local flag_pos = minetest.get_position_from_hash( flag_pos_idx )
		flag_pos = get_flag_pos( flag_pos, new_param2 )
		rotate_flag_by_param2( aflag, new_param2 )
		aflag:set_pos( flag_pos )
	end
end

local function um_preserve_metadata(pos, oldnode, oldmeta, drops)
	local flag_name = oldmeta["flag_name"]
	if minetest.registered_items["generic_flags:"..flag_name] then
		table.insert(drops, ItemStack("generic_flags:"..flag_name))
	end
end

local image = "flags_baremetal.png^[multiply:#e0e0e0"
minetest.register_node( "generic_flags:upper_mast", {
	description = ("vlajka na stožáru"),
	drawtype = "mesh",
	paramtype = "light",
	light_source = 2,
	mesh = "flags_mast_upper.obj",
	paramtype2 = "facedir",
	tiles = {image, image},
	wield_image = "flags_pole_top_inv.png",
	inventory_image = "flags_pole_top_inv.png",
	groups = { cracky = 2, not_in_creative_inventory = 1 },
	sounds = default.node_sound_metal_defaults(),
	is_ground_content = false,

	drop = "generic_flags:lower_mast 2",

	selection_box = upper_mast_box,
	collision_box = upper_mast_box,

	node_placement_prediction = "",

	on_construct = um_on_construct,
	on_destruct = um_on_destruct,
	after_destruct = um_after_destruct,
	on_rotate = um_on_rotate,
	preserve_metadata = um_preserve_metadata,
} )

minetest.register_lbm({
	name = "generic_flags:respawn_flags",
	label = "Respawn flags",
	nodenames = {"generic_flags:upper_mast"},
	run_at_every_load = true,
	action = function(pos, node)
		local node_idx = minetest.hash_node_position( pos )
		local aflag = active_flags[ node_idx ]
		if aflag then
			return
		end
		spawn_flag_and_set_texture( pos )
		update_dynamic_flag(pos, node)
	end
})

minetest.register_lbm({
	name = "generic_flags:update_node_meta",
	label = "Update mast node meta",
	nodenames = {"generic_flags:upper_mast"},
	run_at_every_load = false,
	action = function(pos, node)
		local meta = minetest.get_meta( pos )
		local flag_idx = meta:get_int("flag_idx")
		if flag_idx ~= 0 then
			flag_name = DEFAULT_FLAG
			meta:set_string("flag_idx", "")
			meta:set_string("flag_name", flag_name)
		end
	end
})

minetest.register_abm({
	name = "generic_flags:dynamic_flags",
	label = "Update dynamic flags",
	nodenames = {"generic_flags:upper_mast"},
	interval = 60,
	chance = 1,
	catch_up = true,
	action = function(pos, node, active_object_count, active_object_count_wider)
		update_dynamic_flag(pos, node)
	end,
})

local flagpole_material = minetest.settings:get('flagpole_material') or "default:steel_ingot"

if minetest.registered_items[flagpole_material] then
	minetest.register_craft({
		output = "generic_flags:lower_mast 3",
		recipe = {
			{flagpole_material},
			{flagpole_material},
			{flagpole_material},
		},
	})
end
minetest.register_craft({
	output = "generic_flags:upper_mast",
	recipe = {
		{"group:wool", "group:wool", "group:wool"},
		{"group:wool", "group:wool", "group:wool"},
	},
})

-- Add a hidden upper mast segments to block the node
-- the upper mast occupies. This is also needed to prevent
-- collision issues.
-- This node will be automatically
-- added/removed when the upper mast is constructed
-- or destructed.
minetest.register_node( "generic_flags:upper_mast_hidden_1", {
	drawtype = "airlike",
	pointable = false,
	paramtype = "light",
	sunlight_propagates = true,
	wield_image = "flags_pole_hidden1_inv.png",
	inventory_image = "flags_pole_hidden1_inv.png",
	groups = { not_in_creative_inventory = 1 },
	sounds = default.node_sound_metal_defaults(),
        collision_box = {
                type = "fixed",
                fixed = { { -3/32, -1/2, -3/32, 3/32, 1/5, 3/32 } },
        },
	is_ground_content = false,
	on_blast = function() end,
	can_dig = function() return false end,
	drop = "",
	diggable = false,
	floodable = false,
})

-- API
generic_flags.get_flags = function()
	local result = {}
	for i, flag_def in ipairs(flag_list) do
		result[i] = flag_def.name
	end
	return result
end

function generic_flags.set_flag_at(pos, flag_name)
	local node = minetest.get_node(pos)
	if node.name ~= "generic_flags:upper_mast" then
		return false
	end
	if flag_index[flag_name] == nil then
		return false
	end
	local node_idx = minetest.hash_node_position(pos)
	local aflag = active_flags[node_idx]
	local flag
	if aflag then
		flag = aflag:get_luaentity()
	end
	if flag then
		local set_flag_name = flag:reset_texture(flag_name)
		if set_flag_name == flag_name then
			local meta = minetest.get_meta(pos)
			meta:set_string("flag_name", flag_name)
			return true
		end
	end
	return false
end

function generic_flags.get_flag_at(pos)
	local node = minetest.get_node(pos)
	if node.name ~= "generic_flags:upper_mast" then
		return nil
	end
	local meta = minetest.get_meta(pos)
	local flag_name = meta:get_string("flag_name")
	if flag_name ~= "" then
		return flag_name
	end
end

-- Returns the wind strength at pos.
-- Can be overwritten by mods.
function generic_flags.get_wind(pos)
	-- The default wind function ignores pos.
	-- Returns a wind between ca. 0 and 55
	local coords = { x = os.time( ) % 65535, y = 0 }
	local cur_wind
	if old_get2d then
		cur_wind = wind_noise:get2d(coords)
	else
		cur_wind = wind_noise:get_2d(coords)
	end
	cur_wind = cur_wind * 15 + 15
	return cur_wind
end

-- Crafts
for _, color in ipairs({"black", "blue", "brown", "cyan", "dark_green", "green",
	                    "orange", "red", "white", "yellow"}) do
	if minetest.registered_items["wool:"..color] and flag_index[color] ~= nil then
		local wool_item = flag_list[flag_index[color]].recipe_wool_item or "wool:"..color
		minetest.register_craft({
			output = "generic_flags:"..color,
			recipe = {
				{"generic_flags:lower_mast", wool_item, wool_item},
				{"generic_flags:lower_mast", wool_item, wool_item},
				{"generic_flags:lower_mast", "", ""},
			},
		})
	else
		minetest.log("warning", "Flag "..color.." not recipe registered!")
	end
end

minetest.register_craft({
	output = "generic_flags:pink",
	recipe = {
		{"generic_flags:lower_mast", "wool:white", "wool:pink"},
		{"generic_flags:lower_mast", "wool:pink", "wool:white"},
		{"generic_flags:lower_mast", "", ""},
	},
})

minetest.register_craft({
	output = "generic_flags:purple",
	recipe = {
		{"generic_flags:lower_mast", "wool:magenta", "wool:magenta"},
		{"generic_flags:lower_mast", "wool:magenta", "wool:magenta"},
		{"generic_flags:lower_mast", "", ""},
	},
})

minetest.register_craft({
	output = "generic_flags:magenta",
	recipe = {
		{"generic_flags:lower_mast", "wool:pink", "wool:pink"},
		{"generic_flags:lower_mast", "wool:pink", "wool:pink"},
		{"generic_flags:lower_mast", "", ""},
	},
})

minetest.register_craft({
	output = "generic_flags:gray",
	recipe = {
		{"generic_flags:lower_mast", "wool:grey", "wool:grey"},
		{"generic_flags:lower_mast", "wool:grey", "wool:grey"},
		{"generic_flags:lower_mast", "", ""},
	},
})

minetest.register_craft({
	output = "generic_flags:dark_gray",
	recipe = {
		{"generic_flags:lower_mast", "wool:dark_grey", "wool:dark_grey"},
		{"generic_flags:lower_mast", "wool:dark_grey", "wool:dark_grey"},
		{"generic_flags:lower_mast", "", ""},
	},
})

minetest.register_craft({
	output = "generic_flags:cz",
	recipe = {
		{"generic_flags:lower_mast", "wool:white", "wool:white"},
		{"generic_flags:lower_mast", "wool:blue", "wool:red"},
		{"generic_flags:lower_mast", "", ""},
	},
})

minetest.register_craft({
	output = "generic_flags:sk",
	recipe = {
		{"generic_flags:lower_mast", "wool:white", "wool:blue"},
		{"generic_flags:lower_mast", "wool:red", "wool:red"},
		{"generic_flags:lower_mast", "", ""},
	},
})

minetest.register_craft({
	output = "generic_flags:czx",
	type = "shapeless",
	recipe = {"generic_flags:cz", "technic:control_logic_unit"},
})

minetest.register_craft({
	output = "generic_flags:skx",
	type = "shapeless",
	recipe = {"generic_flags:sk", "technic:control_logic_unit"},
})
