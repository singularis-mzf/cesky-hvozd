local S = minetest.get_translator("doors")

local normal_door_box = {type = "fixed", fixed = {-1/2,-1/2,-1/2,1/2,3/2,-6/16}}
local centered_door_box_ab = {type = "fixed", fixed = {-1/2,-1/2,0,1/2,3/2,2/16}}
local centered_door_box_c = {type = "fixed", fixed = {-1,-1/2,-1/2,0,3/2,-6/16}}
local centered_door_box_d = {type = "fixed", fixed = {0,-1/2,-1/2,1,3/2,-6/16}}

-- table used to aid door opening/closing
local transform = {
	{
		{v = "_a", param2 = 3},
		{v = "_a", param2 = 0},
		{v = "_a", param2 = 1},
		{v = "_a", param2 = 2},
	},
	{
		{v = "_c", param2 = 1},
		{v = "_c", param2 = 2},
		{v = "_c", param2 = 3},
		{v = "_c", param2 = 0},
	},
	{
		{v = "_b", param2 = 1},
		{v = "_b", param2 = 2},
		{v = "_b", param2 = 3},
		{v = "_b", param2 = 0},
	},
	{
		{v = "_d", param2 = 3},
		{v = "_d", param2 = 0},
		{v = "_d", param2 = 1},
		{v = "_d", param2 = 2},
	},
}

local can_dig_door = doors.can_dig_door
local screwdriver_rightclick_override_list = doors.screwdriver_rightclick_override_list

function doors.door_toggle(pos, node, clicker)
	local meta = minetest.get_meta(pos)
	node = node or minetest.get_node(pos)
	local timer = minetest.get_node_timer(pos)
	local def = minetest.registered_nodes[node.name]
	local name = def.door.name

	local state = meta:get_string("state")
	if state == "" then
		-- fix up lvm-placed right-hinged doors, default closed
		if node.name:sub(-2) == "_b" then
			state = 2
		else
			state = 0
		end
	else
		state = tonumber(state)
	end

	if clicker and not doors.check_player_privs(pos, meta, clicker) then
		return false
	end

	-- until Lua-5.2 we have no bitwise operators :(
	if state % 2 == 1 then
		state = state - 1
	else
		state = state + 1
	end

	local dir = node.param2 % 4
	local param2_remains = node.param2 - dir

	-- It's possible param2 is messed up, so, validate before using
	-- the input data. This indicates something may have rotated
	-- the door, even though that is not supported.
	if not transform[state + 1] or not transform[state + 1][dir + 1] then
		return false
	end

	if state % 2 == 0 then
		-- close the door
		minetest.sound_play(def.door.sounds[1],
			{pos = pos, gain = def.door.gains[1], max_hear_distance = 10}, true)
		if meta:get_int("zavirasamo") > 0 then
			timer:stop()
		end
	else
		-- open the door
		minetest.sound_play(def.door.sounds[2],
			{pos = pos, gain = def.door.gains[2], max_hear_distance = 10}, true)
		if meta:get_int("zavirasamo") > 0 then
			timer:start(1)
		end
	end

	minetest.swap_node(pos, {
		name = name .. transform[state + 1][dir+1].v,
		param2 = transform[state + 1][dir+1].param2 + param2_remains
	})
	meta:set_int("state", state)

	return true
end

local function on_place_node(place_to, newnode,
	placer, oldnode, itemstack, pointed_thing)
	-- Run script hook
	for _, callback in ipairs(minetest.registered_on_placenodes) do
		-- Deepcopy pos, node and pointed_thing because callback can modify them
		local place_to_copy = {x = place_to.x, y = place_to.y, z = place_to.z}
		local newnode_copy =
			{name = newnode.name, param1 = newnode.param1, param2 = newnode.param2}
		local oldnode_copy =
			{name = oldnode.name, param1 = oldnode.param1, param2 = oldnode.param2}
		local pointed_thing_copy = {
			type  = pointed_thing.type,
			above = vector.new(pointed_thing.above),
			under = vector.new(pointed_thing.under),
			ref   = pointed_thing.ref,
		}
		callback(place_to_copy, newnode_copy, placer,
			oldnode_copy, itemstack, pointed_thing_copy)
	end
end

function doors.register(name, def)
	if not name:find(":") then
		name = "doors:" .. name
	end
	local base_description = def.description or ""

	local mesh_prefix, mesh_level
	-- mesh_level 1: single mesh (currently not supported)
	-- mesh_level 2: _a, _b; (custom meshes)
	-- mesh_level 4: _a, _a2, _b, _b2 (currently only "door")
	if not def.mesh then
		mesh_prefix = "door"
		mesh_level = def.mesh_level or 4
	elseif string.sub(def.mesh, #def.mesh - 3, #def.mesh) == ".obj" then
		mesh_prefix = string.sub(def.mesh, 1, #def.mesh - 4)
		mesh_level = def.mesh_level or 2
	else
		mesh_prefix = def.mesh
		mesh_level = def.mesh_level or 2
	end

	if mesh_level == 1 then
		minetest.log("warning", "mesh level 1: " .. def.mesh .. "!")
	end

	-- replace old doors of this type automatically
	minetest.register_lbm({
		name = ":doors:replace_" .. name:gsub(":", "_"),
		nodenames = {name.."_b_1", name.."_b_2"},
		action = function(pos, node)
			local l = tonumber(node.name:sub(-1))
			local meta = minetest.get_meta(pos)
			local h = meta:get_int("right") + 1
			local p2 = node.param2
			local replace = {
				{{type = "a", state = 0}, {type = "a", state = 3}},
				{{type = "b", state = 1}, {type = "b", state = 2}}
			}
			local new = replace[l][h]
			-- retain infotext and doors_owner fields
			minetest.swap_node(pos, {name = name .. "_" .. new.type, param2 = p2})
			meta:set_int("state", new.state)
			-- properly place doors:hidden at the right spot
			local p3 = p2
			if new.state >= 2 then
				p3 = (p3 + 3) % 4
			end
			if new.state % 2 == 1 then
				if new.state >= 2 then
					p3 = (p3 + 1) % 4
				else
					p3 = (p3 + 3) % 4
				end
			end
			-- wipe meta on top node as it's unused
			minetest.set_node({x = pos.x, y = pos.y + 1, z = pos.z},
				{name = "doors:hidden", param2 = p3})
		end
	})

	local craftitem_def = {
		description = base_description,
		inventory_image = def.inventory_image,
		groups = table.copy(def.groups),

		on_place = function(itemstack, placer, pointed_thing)
			local pos
			local itemstack_name = itemstack:get_name() or name

			if not pointed_thing.type == "node" then
				return itemstack
			end

			local node = minetest.get_node(pointed_thing.under)
			local pdef = minetest.registered_nodes[node.name]
			if pdef and pdef.on_rightclick and
					not (placer and placer:is_player() and
					placer:get_player_control().sneak) then
				return pdef.on_rightclick(pointed_thing.under,
						node, placer, itemstack, pointed_thing)
			end

			if pdef and pdef.buildable_to then
				pos = pointed_thing.under
			else
				pos = pointed_thing.above
				node = minetest.get_node(pos)
				pdef = minetest.registered_nodes[node.name]
				if not pdef or not pdef.buildable_to then
					return itemstack
				end
			end

			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			local top_node = minetest.get_node_or_nil(above)
			local topdef = top_node and minetest.registered_nodes[top_node.name]

			if not topdef or not topdef.buildable_to then
				return itemstack
			end

			local pn = placer and placer:get_player_name() or ""
			if minetest.is_protected(pos, pn) or minetest.is_protected(above, pn) then
				return itemstack
			end

			local dir = placer and minetest.dir_to_facedir(placer:get_look_dir()) or 0

			local ref = {
				{x = -1, y = 0, z = 0},
				{x = 0, y = 0, z = 1},
				{x = 1, y = 0, z = 0},
				{x = 0, y = 0, z = -1},
			}

			local aside = {
				x = pos.x + ref[dir + 1].x,
				y = pos.y + ref[dir + 1].y,
				z = pos.z + ref[dir + 1].z,
			}

			local state = 0
			if minetest.get_item_group(minetest.get_node(aside).name, "door") == 1 then
				state = state + 2
				-- print("Will place node '"..itemstack_name.."_b'")
				minetest.set_node(pos, {name = itemstack_name .. "_b", param2 = dir})
				minetest.set_node(above, {name = "doors:hidden", param2 = (dir + 3) % 4})
			else
				-- print("Will place node '"..itemstack_name.."_a'")
				minetest.set_node(pos, {name = itemstack_name .. "_a", param2 = dir})
				minetest.set_node(above, {name = "doors:hidden", param2 = dir})
			end

			local meta = minetest.get_meta(pos)
			meta:set_int("state", state)

			if def.protected then
				meta:set_string("owner", pn)
				-- meta:set_string("infotext", def.description .. "\n" .. S("Owned by @1", pn))
			else
				meta:set_string("placer", pn)
			end

			if not minetest.is_creative_enabled(pn) then
				itemstack:take_item()
			end

			minetest.sound_play(def.sounds.place, {pos = pos}, true)

			on_place_node(pos, minetest.get_node(pos),
				placer, node, itemstack, pointed_thing)

			doors.update_infotext(pos, nil, meta)

			return itemstack
		end
	}
	minetest.register_craftitem(":" .. name, table.copy(craftitem_def))
-- 
	if mesh_prefix == "door" then -- centering support
		craftitem_def.description = base_description.." (vystředěné)"
		minetest.register_craftitem(":" .. name .. "_cd", craftitem_def)

		minetest.register_craft({output = name, recipe = {{name.."_cd"}}})
		minetest.register_craft({output = name.."_cd", recipe = {{name}}})
	end

	def.inventory_image = nil

	if def.recipe then
		minetest.register_craft({
			output = name,
			recipe = def.recipe,
		})
	end
	def.recipe = nil

	if not def.sounds then
		def.sounds = default.node_sound_wood_defaults()
	end

	if not def.sound_open then
		def.sound_open = "doors_door_open"
	end

	if not def.sound_close then
		def.sound_close = "doors_door_close"
	end

	if not def.gain_open then
		def.gain_open = 0.3
	end

	if not def.gain_close then
		def.gain_close = 0.3
	end

	def.groups.not_in_creative_inventory = 1
	def.groups.door = 1
	def.drop = name
	def.door = {
		name = name,
		sounds = {def.sound_close, def.sound_open},
		gains = {def.gain_close, def.gain_open},
	}
	if not def.on_rightclick then
		def.on_rightclick = doors.door_rightclick
		--[[ function(pos, node, clicker, itemstack, pointed_thing)
			doors.door_toggle(pos, node, clicker)
			return itemstack
		end ]]
	end
	def.after_dig_node = function(pos, node, meta, digger)
		minetest.remove_node({x = pos.x, y = pos.y + 1, z = pos.z})
		minetest.check_for_falling({x = pos.x, y = pos.y + 1, z = pos.z})
	end
	def.on_rotate = function(pos, node, user, mode, new_param2)
		return false
	end
	if not def.on_timer then
		def.on_timer = doors.on_timer
	end

	def.can_dig = can_dig_door
	if def.protected then
		def.on_blast = function() end
		def.on_key_use = function(pos, player)
			local door = doors.get(pos)
			door:toggle(player)
		end
		def.on_skeleton_key_use = function(pos, player, newsecret)
			-- replace_old_owner_information(pos)
			local meta = minetest.get_meta(pos)
			local owner = meta:get_string("owner")
			local pname = player:get_player_name()

			-- verify placer is owner of lockable door
			if owner ~= pname then
				minetest.record_protection_violation(pos, pname)
				minetest.chat_send_player(pname, S("You do not own this locked door."))
				return nil
			end

			local secret = meta:get_string("key_lock_secret")
			if secret == "" then
				secret = newsecret
				meta:set_string("key_lock_secret", secret)
			end

			return secret, S("a locked door"), owner
		end
		def.node_dig_prediction = ""
	else
		def.on_blast = function(pos, intensity)
			minetest.remove_node(pos)
			-- hidden node doesn't get blasted away.
			minetest.remove_node({x = pos.x, y = pos.y + 1, z = pos.z})
			return {name}
		end
	end

	def.on_destruct = function(pos)
		minetest.remove_node({x = pos.x, y = pos.y + 1, z = pos.z})
	end

	def.drawtype = "mesh"
	def.paramtype = "light"
	if def.paramtype2 == nil then
		def.paramtype2 = "4dir"
	end
	def.sunlight_propagates = true
	def.walkable = true
	def.is_ground_content = false
	def.buildable_to = false
	def.selection_box = normal_door_box
	def.collision_box = normal_door_box
	if not def.use_texture_alpha then
		def.use_texture_alpha = "clip"
	end

	def.mesh = mesh_prefix .. "_a.obj"
	def.description = base_description.." (klika vpravo)"
	minetest.register_node(":" .. name .. "_a", table.copy(def))
	screwdriver_rightclick_override_list[name.."_a"] = 1

	def.mesh = mesh_prefix .. "_b.obj"
	def.description = base_description.." (klika vlevo)"
	minetest.register_node(":" .. name .. "_b", table.copy(def))
	screwdriver_rightclick_override_list[name.."_b"] = 1

	def.mesh = mesh_prefix .. (mesh_level > 2 and "_a2.obj" or "_b.obj")
	def.description = base_description.." (klika vpravo)"
	minetest.register_node(":" .. name .. "_c", table.copy(def))
	screwdriver_rightclick_override_list[name.."_c"] = 1

	def.mesh = mesh_prefix .. (mesh_level > 2 and "_b2.obj" or "_a.obj")
	def.description = base_description.." (klika vlevo)"
	minetest.register_node(":" .. name .. "_d", table.copy(def))
	screwdriver_rightclick_override_list[name.."_d"] = 1

	if mesh_prefix == "door" then
		def = table.copy(def)
		def.selection_box = centered_door_box_ab
		def.collision_box = centered_door_box_ab
		def.drop = name .. "_cd"
		def.door = table.copy(def.door)
		def.door.name = name .. "_cd"

		def.mesh = "doors_cdoor_a.obj"
		def.description = base_description.." (klika vpravo, vystředěné)"
		minetest.register_node(":" .. name .. "_cd_a", table.copy(def))
		screwdriver_rightclick_override_list[name.."_cd_a"] = 1

		def.mesh = "doors_cdoor_b.obj"
		def.description = base_description.." (klika vlevo, vystředěné)"
		minetest.register_node(":" .. name .. "_cd_b", table.copy(def))
		screwdriver_rightclick_override_list[name.."_cd_b"] = 1

		-- def = table.copy(def) -- ?
		def.selection_box = centered_door_box_c
		def.collision_box = centered_door_box_c
		def.mesh = "doors_cdoor_a2.obj"
		def.description = base_description.." (klika vpravo, vystředěné)"
		minetest.register_node(":" .. name .. "_cd_c", table.copy(def))
		screwdriver_rightclick_override_list[name.."_cd_c"] = 1

		def.selection_box = centered_door_box_d
		def.collision_box = centered_door_box_d
		def.mesh = "doors_cdoor_b2.obj"
		def.description = base_description.." (klika vlevo, vystředěné)"
		minetest.register_node(":" .. name .. "_cd_d", table.copy(def))
		screwdriver_rightclick_override_list[name.."_cd_d"] = 1
	end

	doors.registered_doors[name .. "_a"] = true
	doors.registered_doors[name .. "_b"] = true
	doors.registered_doors[name .. "_c"] = true
	doors.registered_doors[name .. "_d"] = true
	if mesh_prefix == "door" then
		doors.registered_doors[name .. "_cd_a"] = true
		doors.registered_doors[name .. "_cd_b"] = true
		doors.registered_doors[name .. "_cd_c"] = true
		doors.registered_doors[name .. "_cd_d"] = true
	end
end

-- Capture mods using the old API as best as possible.
function doors.register_door(name, def)
	if def.only_placer_can_open then
		def.protected = true
	end
	def.only_placer_can_open = nil

	local i = name:find(":")
	local modname = name:sub(1, i - 1)
	if not def.tiles then
		if def.protected then
			def.tiles = {{name = "doors_door_steel.png", backface_culling = true}}
		else
			def.tiles = {{name = "doors_door_wood.png", backface_culling = true}}
		end
		minetest.log("warning", modname .. " registered door \"" .. name .. "\" " ..
				"using deprecated API method \"doors.register_door()\" but " ..
				"did not provide the \"tiles\" parameter. A fallback tiledef " ..
				"will be used instead.")
	end

	doors.register(name, def)
end

doors.register("door_wood", {
		tiles = {{ name = "doors_door_wood.png", backface_culling = true }},
		description = S("Wooden Door"),
		inventory_image = "doors_item_wood.png",
		groups = {node = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
		gain_open = 0.06,
		gain_close = 0.13,
		recipe = {
			{"group:wood", "group:wood"},
			{"group:wood", "group:wood"},
			{"group:wood", "group:wood"},
		}
})

doors.register("door_steel", {
		tiles = {{name = "doors_door_steel.png", backface_culling = true}},
		description = S("Steel Door"),
		inventory_image = "doors_item_steel.png",
		protected = true,
		groups = {node = 1, cracky = 1, level = 2},
		sounds = default.node_sound_metal_defaults(),
		sound_open = "doors_steel_door_open",
		sound_close = "doors_steel_door_close",
		gain_open = 0.2,
		gain_close = 0.2,
		recipe = {
			{"default:steel_ingot", "default:steel_ingot"},
			{"default:steel_ingot", "default:steel_ingot"},
			{"default:steel_ingot", "default:steel_ingot"},
		}
})

doors.register("door_glass", {
		tiles = {"doors_door_glass.png"},
		description = S("Glass Door"),
		inventory_image = "doors_item_glass.png",
		groups = {node = 1, cracky=3, oddly_breakable_by_hand=3},
		sounds = default.node_sound_glass_defaults(),
		sound_open = "doors_glass_door_open",
		sound_close = "doors_glass_door_close",
		gain_open = 0.3,
		gain_close = 0.25,
		recipe = {
			{"default:glass", "default:glass"},
			{"default:glass", "default:glass"},
			{"default:glass", "default:glass"},
		}
})

doors.register("door_obsidian_glass", {
		tiles = {"doors_door_obsidian_glass.png"},
		description = S("Obsidian Glass Door"),
		inventory_image = "doors_item_obsidian_glass.png",
		groups = {node = 1, cracky=3},
		sounds = default.node_sound_glass_defaults(),
		sound_open = "doors_glass_door_open",
		sound_close = "doors_glass_door_close",
		gain_open = 0.3,
		gain_close = 0.25,
		recipe = {
			{"default:obsidian_glass", "default:obsidian_glass"},
			{"default:obsidian_glass", "default:obsidian_glass"},
			{"default:obsidian_glass", "default:obsidian_glass"},
		},
})

