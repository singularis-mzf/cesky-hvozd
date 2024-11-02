-- Doors that are especially useful for travelnet elevators but can also be used in other situations.
-- All doors (not only these here) in front of a travelnet or elevator are opened automaticly when a player arrives
-- and are closed when a player departs from the travelnet or elevator.
-- Autor: Sokomine
local S = minetest.get_translator("travelnet")

local function door_state(self)
	return minetest.get_node(self.pos).name:match("_open$") ~= nil
end

local function door_open(self, player)
	local meta = minetest.get_meta(self.pos)
	if player and not doors.check_player_privs(self.pos, meta, player) then
		return false
	end
	local node = minetest.get_node(self.pos)
	local new_name = node.name:gsub("_closed$", "_open")
	if new_name ~= nil and new_name ~= node.name and minetest.registered_nodes[new_name] ~= nil then
		node.name = new_name
		minetest.swap_node(self.pos, node)
		if meta:get_int("zavirasamo") > 0 then
			minetest.get_node_timer(self.pos):start(1)
		end
		return true
	end
end

local function door_close(self, player)
	local meta = minetest.get_meta(self.pos)
	if player and not doors.check_player_privs(self.pos, meta, player) then
		return false
	end
	local node = minetest.get_node(self.pos)
	local new_name = node.name:gsub("_open$", "_closed")
	if new_name ~= nil and new_name ~= node.name and minetest.registered_nodes[new_name] ~= nil then
		node.name = new_name
		minetest.swap_node(self.pos, node)
		if meta:get_int("zavirasamo") > 0 then
			minetest.get_node_timer(self.pos):stop()
		end
		return true
	end
end

local function door_toggle(self, player)
	if door_state(self) then
		return door_close(self, player)
	else
		return door_open(self, player)
	end
end

local door_class = {
	open = door_open,
	close = door_close,
	toggle = door_toggle,
	state = door_state,
}

function travelnet.register_door(node_base_name, def_tiles, material)
	local closed_door = node_base_name .. "_closed"
	local open_door = node_base_name .. "_open"

	minetest.register_node(open_door, {
		description = S("elevator door (open)"),
		drawtype = "nodebox",
		tiles = def_tiles,
		use_texture_alpha = "clip",
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = true,
		-- only the closed variant is in creative inventory
		groups = {
			snappy = 2,
			choppy = 2,
			oddly_breakable_by_hand = 2,
			not_in_creative_inventory = 1,
			door = 1,
		},
		-- larger than one node but slightly smaller than a half node so
		-- that wallmounted torches pose no problem
		node_box = {
			type = "fixed",
			fixed = {
				{ -0.90, -0.5, 0.4, -0.49, 1.5, 0.5 },
				{  0.49, -0.5, 0.4,   0.9, 1.5, 0.5 },
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{ -0.9, -0.5, 0.4, 0.9, 1.5, 0.5 },
			},
		},
		drop = closed_door,
		on_rightclick = assert(doors.door_rightclick),
		on_timer = assert(doors.on_timer),
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			local player_name = placer:get_player_name()
			local meta = minetest.get_meta(pos)
			meta:set_string("placer", player_name)
			doors.update_infotext(pos, nil, meta)
			return minetest.is_creative_enabled(player_name)
		end,
	})

	minetest.register_node(closed_door, {
		description = S("elevator door (closed)"),
		drawtype = "nodebox",
		tiles = def_tiles,
		use_texture_alpha = "clip",
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = true,
		groups = {
			snappy = 2,
			choppy = 2,
			oddly_breakable_by_hand = 2,
			door = 2,
		},
		node_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, 0.4, -0.01, 1.5, 0.5 },
				{ 0.01, -0.5, 0.4,   0.5, 1.5, 0.5 },
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, 0.4, 0.5, 1.5, 0.5 },
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
	})

	-- add a craft receipe for the door
	minetest.register_craft({
		output = closed_door,
		recipe = {
			{ material, "", material },
			{ material, "", material },
			{ material, "", material }
		}
	})


	-- Make doors reacts to mesecons
	if minetest.get_modpath("mesecons") then
		local mesecons = {
			effector = {
				action_on = function(pos, node)
					door_open({pos = pos})
				end,
				action_off = function(pos, node)
					door_close({pos = pos})
				end,
				rules = mesecon.rules.pplate
			}
		}

		minetest.override_item(closed_door, { mesecons=mesecons })
		minetest.override_item(open_door,   { mesecons=mesecons })
	end

	doors.register_custom_door(open_door, door_class)
	doors.register_custom_door(closed_door, door_class)
end

-- actually register the doors
-- (but only if the materials for them exist)
if minetest.get_modpath("default") then
	travelnet.register_door("travelnet:elevator_door_steel", { "default_stone.png" },           "default:steel_ingot")
	travelnet.register_door("travelnet:elevator_door_glass", { "travelnet_elevator_door_glass.png" }, "default:glass")
	travelnet.register_door("travelnet:elevator_door_tin",   { "default_clay.png" },              "default:tin_ingot")
end
