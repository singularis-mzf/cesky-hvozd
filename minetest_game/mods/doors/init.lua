ch_base.open_mod(minetest.get_current_modname())
-- doors/init.lua

-- our API object
doors = {}

doors.registered_doors = {}
doors.registered_trapdoors = {}
doors.registered_fencegates = {}
doors.registered_custom_doors = {}

-- Load support for MT game translation.
local modpath = minetest.get_modpath("doors")
local S = minetest.get_translator("doors")

function doors.login_to_viewname(login)
	return login
end

function doors.viewname_to_login(viewname)
	return viewname
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
	elseif doors.registered_fencegates[node_name] then
		-- A fencegate
		return {
			pos = pos,
			open = doors.fencegate_open,
			close = doors.fencegate_close,
			toggle = doors.fencegate_toggle,
			state = doors.fencegate_state,
		}
	elseif doors.registered_custom_doors[node_name] then
		-- A custom door
		local custom = doors.registered_custom_doors[node_name]
		return {
			pos = pos,
			open = custom.open,
			close = custom.close,
			toggle = custom.toggle,
			state = custom.state,
		}
	else
		return nil
	end
end

dofile(modpath.."/cpanel.lua")

-- this hidden node is placed on top of the bottom, and prevents
-- nodes from being placed in the top half of the door.
local base_def = {
	description = S("Hidden Door Segment"),
	inventory_image = "doors_hidden_segment.png^default_invisible_node_overlay.png",
	wield_image = "doors_hidden_segment.png^default_invisible_node_overlay.png",
	drawtype = "airlike",
	paramtype = "light",
	paramtype2 = "4dir",
	sunlight_propagates = true,
	-- has to be walkable for falling nodes to stop falling.
	walkable = true,
	pointable = false,
	diggable = false,
	buildable_to = false,
	floodable = false,
	drop = "",
	groups = {not_in_creative_inventory = 1, doors_hidden = 1}, -- 1 = normal, 2 = green, 3 = red
	on_blast = function() end,
	-- 1px block inside door hinge near node top
	collision_box = {
		type = "fixed",
		fixed = {-15/32, 13/32, -15/32, -13/32, 1/2, -13/32},
	},
}
core.register_node("doors:hidden", table.copy(base_def))

base_def.drawtype = "nodebox"

local green_tiles = {{name = "blank.png^[noalpha^[colorize:#00ff00:255"}}
local red_tiles = {{name = "blank.png^[noalpha^[colorize:#ff0000:255"}}
local green_groups = {not_in_creative_inventory = 1, doors_hidden = 2}
local red_groups = {not_in_creative_inventory = 1, doors_hidden = 3, doors_hidden_red = 3}

local function register_hidden(name, tiles, groups, fixed)
	local def = table.copy(base_def)
	def.tiles = tiles
	def.groups = groups
	def.node_box = {type = "fixed", fixed = fixed}
	core.register_node(name, def)
end

local function register_hidden_pair(name_template, fixed)
	local name = name_template:gsub("*", "green")
	register_hidden(name, green_tiles, green_groups, fixed)
	name = name_template:gsub("*", "red")
	register_hidden(name, red_tiles, red_groups, fixed)
end

local x1, x2, x3, x4, x5, x6 = 4/16, -12/16, -9/16, 6/16, -10/16, -5/16

register_hidden_pair("doors:hidden_*_a", {x1, x2, x3, x4, x5, x6})
-- a2 = b
register_hidden_pair("doors:hidden_*_b",  {-x4, x2, x3, -x1, x5, x6})
-- b2 = a
register_hidden_pair("doors:hidden_*_ca",  { x1, x2, x3 + 1/2, x4, x5, x6 + 1/2})
register_hidden_pair("doors:hidden_*_ca2", {-x4 - 1/2, x2, x3, -x1 - 1/2, x5, x6})
register_hidden_pair("doors:hidden_*_cb",  {-x4, x2, x3 + 1/2, -x1, x5, x6 + 1/2})
register_hidden_pair("doors:hidden_*_cb2", { x1 + 1/2, x2, x3, x4 + 1/2, x5, x6})

local is_hidden_types = {"normal", "green", "red"}

function doors.is_hidden(name)
	return is_hidden_types[core.get_item_group(name, "doors_hidden")]
end

function doors.get_door_side(door_pos, door_node, pos) -- => "inside" or "outside" or nil
	assert(door_pos)
	assert(door_node)
	assert(pos)
	local ndef = core.registered_nodes[door_node.name]
	if ndef == nil or type(ndef.mesh) ~= "string" then
		return nil
	end
	local wc_config = doors.wc_config[ndef.mesh]
	local inside_mode = wc_config and wc_config.inside_mode
	if inside_mode == nil then
		return nil
	end
	local dir = door_node.param2 % 4
	local diff_x, diff_z = pos.x - door_pos.x, pos.z - door_pos.z
	local is_inside
	if inside_mode == "a" or inside_mode == "b" then
		if dir == 0 then
			is_inside = diff_z > -0.5
		elseif dir == 1 then
			is_inside = diff_x > -0.5
		elseif dir == 2 then
			is_inside = diff_z <= 0.5
		else
			is_inside = diff_x <= 0.5
		end
	else
		if dir == 0 then
			is_inside = diff_z > 0
		elseif dir == 1 then
			is_inside = diff_x > 0
		elseif dir == 2 then
			is_inside = diff_z <= 0
		else
			is_inside = diff_x <= 0
		end
	end
	if inside_mode == "a" or inside_mode == "ca" then
		if is_inside then
			return "inside"
		else
			return "outside"
		end
	elseif inside_mode == "b" or inside_mode == "cb" then
		if not is_inside then
			return "inside"
		else
			return "outside"
		end
	else
		core.log("error", "Internal error: invalid inside_mode of "..door_node.name.."!")
		return nil
	end
end

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
	-- replace_old_owner_information(pos)
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

function doors.check_player_privs(pos, meta, clicker)
	local clicker_name = clicker:get_player_name()
	local owner = meta:get_string("owner")
	local hes = meta:get_int("hes")
	local is_admin = core.check_player_privs(clicker, "protection_bypass")
	if is_admin then
		return true
	end
	if owner == "" then
		owner = meta:get_string("placer")
	end
	-- Hotel door?
	if
		hes ~= 0 and
		clicker_name ~= "" and
		owner ~= "" and
		clicker_name ~= owner
	then
		-- key to the hotel-door required
		local key = clicker:get_wielded_item()
		if key:get_name() ~= "doors:key" then
			return false
		end
		local key_meta = key:get_meta()
		local key_hes = key_meta:get_int("hes")
		if key_hes ~= hes then
			-- access denied
			minetest.chat_send_player(clicker_name, "*** Tento klíč nepatří k těmto dveřím!")
			return false
		end
	end
	-- occupied WC door?
	if core.is_player(clicker) and meta:get_int("zachodove") ~= 0 then
		local pos_above = vector.offset(pos, 0, 1, 0)
		local node_above = core.get_node(pos_above)
		if
			doors.is_hidden(node_above.name) == "red" and
			doors.get_door_side(pos, core.get_node(pos), assert(clicker:get_pos())) == "outside"
		then
			core.chat_send_player(clicker_name, "Obsazeno!")
			return false
		end
	end
	if not default.can_interact_with_node(clicker, pos) then
		return false
	end
	return true
end

function doors.door_rightclick(pos, node, clicker, itemstack, pointed_thing)
	if not clicker then
		return false
	end
	local door_object = doors.get(pos)
	if not door_object then
		minetest.log("warning", "doors.door_rightclick() called at "..minetest.pos_to_string(pos).." on "..node.name.." that is not a door!")
		return false
	end
	-- Aux1 => show control panel
	local controls = clicker:get_player_control()
	if controls.aux1 then
		-- Show control panel
		doors.show_control_panel(clicker, pos)
		return itemstack
	end

	-- Empty key used by owner (special case)
	if default.can_interact_with_node(clicker, pos) then
		local clicker_name = clicker:get_player_name()
		local key = clicker:get_wielded_item()
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")..meta:get_string("placer")
		-- local door_hes = meta:get_int("hes")
		if key:get_name() == "doors:key" and clicker_name ~= "" and owner ~= "" and (clicker_name == owner or minetest.check_player_privs(clicker, "server")) then
			local key_meta = key:get_meta()
			local key_hes = key_meta:get_int("hes")
			if key_hes == 0 then
				-- a new key to be set up to be used with this door
				local new_hes = math.random(2147483647)
				local door_name = meta:get_string("nazev")
				if door_name == "" then
					door_name = S("Door")
				end
				meta:set_int("hes", new_hes)
				key_meta:set_int("hes", new_hes)
				key_meta:set_string("description", S("Key for: @1 (hash @2)", door_name, new_hes))
				minetest.chat_send_player(clicker_name, "*** Dveře a klíč úspěšně spárovány (kód = "..new_hes..")")
				doors.update_infotext(pos, node, minetest.get_meta(pos))
				return key
			end
		end
	end

	door_object:toggle(clicker)
	return nil
end

function doors.update_infotext(pos, node, meta)
	local result = {}
	local nazev = meta:get_string("nazev")
	local owner = meta:get_string("owner")
	if owner ~= "" then
		table.insert(result, "<soukromé dveře>")
	elseif meta:get_int("hes") ~= 0 then
		table.insert(result, "<hotelové dveře>")
	end
	if nazev ~= "" then
		table.insert(result, "["..nazev.."]")
	end
	if owner ~= "" then
		table.insert(result, "Dveře vlastní: "..doors.login_to_viewname(owner))
	else
		local placer = meta:get_string("placer")
		table.insert(result, "Dveře postavil/a: "..doors.login_to_viewname(placer))
	end
	if meta:get_int("zavirasamo") > 0 then
		table.insert(result, "Zavírá samo")
	end
	result = table.concat(result, "\n")
	meta:set_string("infotext", result)
	return result
end

function doors.on_timer(pos, elapsed)
	local obj = doors.get(pos)
	if not obj then
		return
	end
	-- don't close until no player is in 3-meter radius
	local player_radius = 3
	local player_radius2 = player_radius * player_radius
	for _, player in pairs(minetest.get_connected_players()) do
		local player_pos = player:get_pos()
		local x, y, z = player_pos.x - pos.x, player_pos.y - pos.y, player_pos.z - pos.z
		if x * x + y * y + z * z <= player_radius2 then
			return true -- wait again
		end
	end
	obj:close()
end

dofile(modpath.."/wc.lua")
dofile(modpath.."/doors_normal.lua")
dofile(modpath.."/doors_trapdoor.lua")
dofile(modpath.."/doors_fencegate.lua")
dofile(modpath.."/fuels.lua")

doors.can_dig_door = nil
doors.screwdriver_rightclick_override_list = nil

function doors.register_custom_door(node_name, methods)
	local ndef = minetest.registered_nodes[node_name]
	if not methods.open or not methods.close or not methods.toggle or not methods.state then
		error("doors.register_custom_door("..node_name.."): some of the required methods is missing!")
	end
	if doors.registered_custom_doors[node_name] then
		minetest.log("warning", node_name.." already registered as a custom door")
		return
	end
	doors.registered_custom_doors[node_name] = methods
	return true
end

minetest.register_lbm({
	label = "Update door infotext",
	name = "doors:update_infotext_v1",
	nodenames = {"group:door"},
	action = function(pos, node, dtime_s) return doors.update_infotext(pos, node, minetest.get_meta(pos)) end,
})
ch_base.close_mod(minetest.get_current_modname())
