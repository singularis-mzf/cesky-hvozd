-- doors/init.lua

-- our API object
doors = {}

doors.registered_doors = {}
doors.registered_trapdoors = {}

-- Load support for MT game translation.
local modpath = minetest.get_modpath("doors")
local S = minetest.get_translator("doors")

function doors.login_to_viewname(login)
	return login
end

if minetest.get_modpath("screwdriver") then
	doors.screwdriver_rightclick_override_list = screwdriver.rightclick_override_list
end
if not doors.screwdriver_rightclick_override_list then
	doors.screwdriver_rightclick_override_list = {}
end

-- returns an object to a door object or nil
function doors.get(pos)
	local node_name = minetest.get_node(pos).name
	if doors.registered_doors[node_name] then
		-- A normal upright door
		return {
			pos = pos,
			open = function(self, player)
				if self:state() then
					return false
				end
				return doors.door_toggle(self.pos, nil, player)
			end,
			close = function(self, player)
				if not self:state() then
					return false
				end
				return doors.door_toggle(self.pos, nil, player)
			end,
			toggle = function(self, player)
				return doors.door_toggle(self.pos, nil, player)
			end,
			state = function(self)
				local state = minetest.get_meta(self.pos):get_int("state")
				return state %2 == 1
			end
		}
	elseif doors.registered_trapdoors[node_name] then
		-- A trapdoor
		return {
			pos = pos,
			open = function(self, player)
				if self:state() then
					return false
				end
				return doors.trapdoor_toggle(self.pos, nil, player)
			end,
			close = function(self, player)
				if not self:state() then
					return false
				end
				return doors.trapdoor_toggle(self.pos, nil, player)
			end,
			toggle = function(self, player)
				return doors.trapdoor_toggle(self.pos, nil, player)
			end,
			state = function(self)
				return minetest.get_node(self.pos).name:sub(-5) == "_open"
			end
		}
	else
		return nil
	end
end

dofile(modpath.."/cpanel.lua")

-- this hidden node is placed on top of the bottom, and prevents
-- nodes from being placed in the top half of the door.
minetest.register_node("doors:hidden", {
	description = S("Hidden Door Segment"),
	inventory_image = "doors_hidden_segment.png^default_invisible_node_overlay.png",
	wield_image = "doors_hidden_segment.png^default_invisible_node_overlay.png",
	drawtype = "airlike",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	-- has to be walkable for falling nodes to stop falling.
	walkable = true,
	pointable = false,
	diggable = false,
	buildable_to = false,
	floodable = false,
	drop = "",
	groups = {not_in_creative_inventory = 1},
	on_blast = function() end,
	-- 1px block inside door hinge near node top
	collision_box = {
		type = "fixed",
		fixed = {-15/32, 13/32, -15/32, -13/32, 1/2, -13/32},
	},
})

minetest.register_tool("doors:key", {
	description = S("Key for a door"),
	inventory_image = "keys_key.png",
	wield_image = "keys_key.png",
	_ch_help = "Pravým klikem nenastaveným klíčem na nějaké vaše dveře tento klíč\ns danými dveřmi spárujete a ostatní hráčské postavy budou k otevření dveří\npotřebovat daný klíč. Nastaveným klíčem můžete otevřít či zavřít dveře,\nkteré byly s klíčem spárovány, i když vám nepatří a jsou zamčené.\nVlastník/ice může svoje dveře otevřít i bez klíče.",
})

minetest.register_craft({
	output = "doors:key 8",
	recipe = {
		{"default:steel_ingot", "", ""},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"", "", ""},
	},
})

minetest.register_craft({
	output = "doors:key",
	recipe = {{"doors:key"}},
})

function doors.can_dig_door(pos, digger)
	-- minetest.log("warning", "can_dig_door() called at "..minetest.pos_to_string(pos))
	replace_old_owner_information(pos)
	if not default.can_interact_with_node(digger, pos) then
		return false
	end
	local meta = minetest.get_meta(pos)
	if meta:get_int("hes") ~= 0 then
		-- hotel doors
		if digger:get_player_name() ~= meta:get_string("owner")..meta:get_string("placer") and not minetest.check_player_privs(digger, "protection_bypass") then
			minetest.chat_send_player(digger:get_player_name(), "*** Hotelové dveře může odstranit jen jejich vlastník/ice nebo Administrace!")
			return false
		end
	end
	return true
end

dofile(modpath.."/doors_normal.lua")
dofile(modpath.."/doors_trapdoor.lua")
dofile(modpath.."/doors_fencegate.lua")
dofile(modpath.."/fuels.lua")

doors.can_dig_door = nil
doors.screwdriver_rightclick_override_list = nil
