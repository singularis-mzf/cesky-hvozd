local S = minetest.get_translator("doors")
local can_dig_door = doors.can_dig_door

----trapdoor----

local function replace_old_owner_information(pos)
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("doors_owner")
	if owner and owner ~= "" then
		meta:set_string("owner", owner)
		meta:set_string("doors_owner", "")
	end
end

function doors.trapdoor_toggle(pos, node, clicker)
	node = node or minetest.get_node(pos)

	replace_old_owner_information(pos)

	if clicker and not default.can_interact_with_node(clicker, pos) then
		return false
	end

	local def = minetest.registered_nodes[node.name]
	local meta = minetest.get_meta(pos)
	local timer = minetest.get_node_timer(pos)

	if string.sub(node.name, -5) == "_open" then
		minetest.sound_play(def.sound_close,
			{pos = pos, gain = def.gain_close, max_hear_distance = 10}, true)
		minetest.swap_node(pos, {name = string.sub(node.name, 1,
			string.len(node.name) - 5), param1 = node.param1, param2 = node.param2})
		if meta:get_int("zavirasamo") > 0 then
			timer:stop()
		end
	else
		minetest.sound_play(def.sound_open,
			{pos = pos, gain = def.gain_open, max_hear_distance = 10}, true)
		minetest.swap_node(pos, {name = node.name .. "_open",
			param1 = node.param1, param2 = node.param2})
		if meta:get_int("zavirasamo") > 0 then
			timer:start(1)
		end
	end
end

function doors.register_trapdoor(name, def)
	if not name:find(":") then
		name = "doors:" .. name
	end

	local name_closed = name
	local name_opened = name.."_open"

	def.on_rightclick = doors.door_rightclick
			--[[ function(pos, node, clicker, itemstack, pointed_thing)
		doors.trapdoor_toggle(pos, node, clicker)
		return itemstack
	end ]]

	-- Common trapdoor configuration
	def.drawtype = "nodebox"
	def.paramtype = "light"
	def.paramtype2 = "facedir"
	def.is_ground_content = false
	def.use_texture_alpha = def.use_texture_alpha or "clip"

	if def.protected then
		def.can_dig = can_dig_door
		def.after_place_node = function(pos, placer, itemstack, pointed_thing)
			local pn = placer:get_player_name()
			local meta = minetest.get_meta(pos)
			meta:set_string("owner", pn)
			doors.update_infotext(pos, nil, meta)
			return minetest.is_creative_enabled(pn)
		end

		def.on_blast = function() end
		def.on_key_use = function(pos, player)
			local door = doors.get(pos)
			door:toggle(player)
		end
		def.on_skeleton_key_use = function(pos, player, newsecret)
			replace_old_owner_information(pos)
			local meta = minetest.get_meta(pos)
			local owner = meta:get_string("owner")
			local pname = player:get_player_name()

			-- verify placer is owner of lockable door
			if owner ~= pname then
				minetest.record_protection_violation(pos, pname)
				minetest.chat_send_player(pname, S("You do not own this trapdoor."))
				return nil
			end

			local secret = meta:get_string("key_lock_secret")
			if secret == "" then
				secret = newsecret
				meta:set_string("key_lock_secret", secret)
			end

			return secret, S("a locked trapdoor"), owner
		end
		def.node_dig_prediction = ""
	else
		def.on_blast = function(pos, intensity)
			minetest.remove_node(pos)
			return {name}
		end
		def.after_place_node = function(pos, placer, itemstack, pointed_thing)
			local pn = placer:get_player_name()
			local meta = minetest.get_meta(pos)
			meta:set_string("placer", pn)
			doors.update_infotext(pos, nil, meta)
			return minetest.is_creative_enabled(pn)
		end
	end

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

	if not def.on_timer then
		def.on_timer = doors.on_timer
	end

	local def_opened = table.copy(def)
	local def_closed = table.copy(def)

	if def.nodebox_closed and def.nodebox_opened then
		def_closed.node_box = def.nodebox_closed
	else
		def_closed.node_box = {
		    type = "fixed",
		    fixed = {-0.5, -0.5, -0.5, 0.5, -6/16, 0.5}
		}
	end
	def_closed.selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -6/16, 0.5}
	}
	def_closed.tiles = {
		def.tile_front,
		def.tile_front .. '^[transformFY',
		def.tile_side,
		def.tile_side,
		def.tile_side,
		def.tile_side
	}

	if def.nodebox_opened and def.nodebox_closed then
		def_opened.node_box = def.nodebox_opened
	else
		def_opened.node_box = {
		    type = "fixed",
		    fixed = {-0.5, -0.5, 6/16, 0.5, 0.5, 0.5}
		}
	end
	def_opened.selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 6/16, 0.5, 0.5, 0.5}
	}
	def_opened.tiles = {
		def.tile_side,
		def.tile_side .. '^[transform2',
		def.tile_side .. '^[transform3',
		def.tile_side .. '^[transform1',
		def.tile_front .. '^[transform46',
		def.tile_front .. '^[transform6'
	}

	def_opened.drop = name_closed
	def_opened.groups.not_in_creative_inventory = 1

	minetest.register_node(name_opened, def_opened)
	minetest.register_node(name_closed, def_closed)

	doors.registered_trapdoors[name_opened] = true
	doors.registered_trapdoors[name_closed] = true
end

doors.register_trapdoor("doors:trapdoor", {
	description = S("Wooden Trapdoor"),
	inventory_image = "doors_trapdoor.png",
	wield_image = "doors_trapdoor.png",
	tile_front = "doors_trapdoor.png",
	tile_side = "doors_trapdoor_side.png",
	gain_open = 0.06,
	gain_close = 0.13,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, door = 1},
})

doors.register_trapdoor("doors:trapdoor_steel", {
	description = S("Steel Trapdoor"),
	inventory_image = "doors_trapdoor_steel.png",
	wield_image = "doors_trapdoor_steel.png",
	tile_front = "doors_trapdoor_steel.png",
	tile_side = "doors_trapdoor_steel_side.png",
	protected = true,
	sounds = default.node_sound_metal_defaults(),
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",
	gain_open = 0.2,
	gain_close = 0.2,
	groups = {cracky = 1, level = 2, door = 1},
})

minetest.register_craft({
	output = "doors:trapdoor 2",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"group:wood", "group:wood", "group:wood"},
		{"", "", ""},
	}
})

minetest.register_craft({
	output = "doors:trapdoor_steel",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot"},
	}
})
