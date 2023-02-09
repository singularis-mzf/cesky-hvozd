print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local side_texture = mesecon.texture.steel_block or "mesecons_detector_side.png"

local S = minetest.get_translator("mesecons_detector")

local od_default_radius = 10
local od_max_radius = 64

local function get_od_formspec(pos, node)
	local meta = minetest.get_meta(pos)
	local scanname = meta:get_string("scanname")
	local radius = meta:get_int("radius")
	if radius == 0 then
		radius = od_default_radius
	end
	return "size[9,2.5]" ..
	"field[0.3,  0;9,2;scanname;"..S("Name of player to scan for (empty for any):")..";"..minetest.formspec_escape(scanname).."]"..
	"field[0.3,1.5;4,2;radius;".."Dosah (1-"..od_max_radius..") \\[m\\] (volitelný):"..";"..radius.."]"..
	"button_exit[7,0.75;2,3;save;"..S("Save").."]"
end

-- Object detector
-- Detects players in a certain radius

local function object_detector_formspec_callback(custom_state, player, formname, fields)
	if not fields.save then return end
	if minetest.is_protected(custom_state.pos, player:get_player_name()) then return end

	local meta = minetest.get_meta(custom_state.pos)
	meta:set_string("scanname", ch_core.jmeno_na_prihlasovaci(fields.scanname))
	local new_radius = tonumber(fields.radius)
	if new_radius ~= nil then
		new_radius = math.round(new_radius)
		if 1 <= new_radius and new_radius <= od_max_radius then
			meta:set_int("radius", new_radius)
		end
	end
end

-- returns true if player was found, false if not
local function object_detector_scan(pos)
	-- local objs = minetest.get_objects_inside_radius(pos, mesecon.setting("detector_radius", 6))
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	local scanname = meta:get_string("scanname")
	local radius = meta:get_int("radius")
	if radius <= 0 then
		radius = 10
	end
	local scan_for
	if scanname ~= "" then
		scan_for = {}
		for _, str in pairs(string.split(scanname:gsub(" ", ""), ",")) do
			scan_for[str] = true
		end
	end

	for player_name, player in pairs(minetest.get_connected_players()) do
		if (scan_for == nil or scan_for[player_name]) and vector.distance(player:get_pos(), pos) <= radius then
			return true
		end
	end
	return false
end

local function object_detector_on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	local player_name = clicker and clicker:get_player_name()
	if player_name == nil then return end
	if minetest.is_protected(pos, player_name) then
		return
	end
	ch_core.show_formspec(clicker, "mesecons_detector:object_detector", get_od_formspec(pos, node), object_detector_formspec_callback, {pos = pos}, {})
end

local def = {
	tiles = {side_texture, side_texture, "jeija_object_detector_off.png", "jeija_object_detector_off.png", "jeija_object_detector_off.png", "jeija_object_detector_off.png"},
	paramtype = "light",
	is_ground_content = false,
	walkable = true,
	groups = {cracky=3},
	description="detektor hráčských postav",
	mesecons = {receptor = {
		state = mesecon.state.off,
		rules = mesecon.rules.pplate
	}},
	on_rightclick = object_detector_on_rightclick,
	sounds = mesecon.node_sound.stone,
	on_blast = mesecon.on_blastnode,
}

if minetest.get_modpath("unifieddyes") then
	def.paramtype2 = "color"
	def.palette = "unifieddyes_palette_extended.png"
	def.groups.ud_param2_colorable = 1
	def.on_construct = unifieddyes.on_construct
	def.on_dig = unifieddyes.on_dig
end

minetest.register_node("mesecons_detector:object_detector_off", table.copy(def))

def.tiles = {side_texture, side_texture, "jeija_object_detector_on.png", "jeija_object_detector_on.png", "jeija_object_detector_on.png", "jeija_object_detector_on.png"}
def.groups = {cracky=3,not_in_creative_inventory=1}
def.mesecons = {receptor = {
	state = mesecon.state.on,
	rules = mesecon.rules.pplate
}}

if minetest.get_modpath("unifieddyes") then
	def.groups.ud_param2_colorable = 1
	def.on_dig = function(pos, node, digger)
		node.name = "mesecons_detector:object_detector_off"
		minetest.swap_node(pos, node)
		return unifieddyes.on_dig(pos, node, digger)
	end
else
	def.drop = "mesecons_detector:object_detector_off"
end

minetest.register_node("mesecons_detector:object_detector_on", def)

minetest.register_craft({
	output = 'mesecons_detector:object_detector_off',
	recipe = {
		{"mesecons_gamecompat:steel_ingot", "mesecons_gamecompat:steel_ingot", "mesecons_gamecompat:steel_ingot"},
		{"mesecons_gamecompat:steel_ingot", "mesecons_luacontroller:luacontroller0000", "mesecons_gamecompat:steel_ingot"},
		{"mesecons_gamecompat:steel_ingot", "group:mesecon_conductor_craftable", "mesecons_gamecompat:steel_ingot"},
	}
})

minetest.register_craft({
	output = 'mesecons_detector:object_detector_off',
	recipe = {
		{"mesecons_gamecompat:steel_ingot", "mesecons_gamecompat:steel_ingot", "mesecons_gamecompat:steel_ingot"},
		{"mesecons_gamecompat:steel_ingot", "mesecons_microcontroller:microcontroller0000", "mesecons_gamecompat:steel_ingot"},
		{"mesecons_gamecompat:steel_ingot", "group:mesecon_conductor_craftable", "mesecons_gamecompat:steel_ingot"},
	}
})

minetest.register_abm({
	nodenames = {"mesecons_detector:object_detector_off"},
	interval = 1,
	chance = 1,
	action = function(pos, node)
		if not object_detector_scan(pos) then return end

		node.name = "mesecons_detector:object_detector_on"
		minetest.swap_node(pos, node)
		mesecon.receptor_on(pos, mesecon.rules.pplate)
	end,
})

minetest.register_abm({
	nodenames = {"mesecons_detector:object_detector_on"},
	interval = 1,
	chance = 1,
	action = function(pos, node)
		if object_detector_scan(pos) then return end

		node.name = "mesecons_detector:object_detector_off"
		minetest.swap_node(pos, node)
		mesecon.receptor_off(pos, mesecon.rules.pplate)
	end,
})

minetest.register_lbm({
	label = "Upgrade legacy object detectors",
	name = "mesecons_detector:upgrade_object_detectors",
	nodenames = {"mesecons_detector:object_detector_on", "mesecons_detector:object_detector_off"},
	action = function(pos, node, dtime_s)
		local meta = minetest.get_meta(pos)
		if meta:get_string("formspec") ~= "" then
			meta:set_string("formspec", "")
			node.param2 = 240
			minetest.swap_node(pos, node)
			minetest.log("action", "Legacy object detector at "..minetest.pos_to_string(pos).." upgraded.")
		end
	end,
})

-- Node detector
-- Detects the node in front of it

local function node_detector_make_formspec(pos)
	local meta = minetest.get_meta(pos)
	if meta:get_string("distance") == ""  then meta:set_string("distance", "0") end
	meta:set_string("formspec", "size[9,2.5]" ..
		"field[0.3,  0;9,2;scanname;"..S("Name of node to scan for (empty for any):")..";${scanname}]"..
		"field[0.3,1.5;2.5,2;distance;"..S("Distance (0-@1):", mesecon.setting("node_detector_distance_max", 10))..";${distance}]"..
		-- "field[3,1.5;4,2;digiline_channel;"..S("Digiline Channel (optional):")..";${digiline_channel}]"..
		"button_exit[7,0.75;2,3;;"..S("Save").."]")
end

local function node_detector_on_receive_fields(pos, _, fields, sender)
	if not fields.scanname --[[or not fields.digiline_channel]] then return end

	if minetest.is_protected(pos, sender:get_player_name()) then return end

	local meta = minetest.get_meta(pos)
	meta:set_string("scanname", fields.scanname)
	meta:set_string("distance", fields.distance or "0")
	-- meta:set_string("digiline_channel", fields.digiline_channel)
	meta:set_string("digiline_channel", "")
	node_detector_make_formspec(pos)
end

-- returns true if node was found, false if not
local function node_detector_scan(pos)
	local node = minetest.get_node_or_nil(pos)
	if not node then return end

	local meta = minetest.get_meta(pos)

	local distance = meta:get_int("distance")
	local distance_max = mesecon.setting("node_detector_distance_max", 10)
	if distance < 0 then distance = 0 end
	if distance > distance_max then distance = distance_max end

	local frontname = minetest.get_node(
		vector.subtract(pos, vector.multiply(minetest.facedir_to_dir(node.param2), distance + 1))
	).name
	local scanname = meta:get_string("scanname")

	return (frontname == scanname) or
		(frontname ~= "air" and frontname ~= "ignore" and scanname == "")
end

local function node_detector_send_node_name(pos, node, channel, meta)
	local distance = meta:get_int("distance")
	local distance_max = mesecon.setting("node_detector_distance_max", 10)
	if distance < 0 then distance = 0 end
	if distance > distance_max then distance = distance_max end
	local nodename = minetest.get_node(
		vector.subtract(pos, vector.multiply(minetest.facedir_to_dir(node.param2), distance + 1))
	).name

	digiline:receptor_send(pos, digiline.rules.default, channel, nodename)
end

--[[
-- set player name when receiving a digiline signal on a specific channel
local node_detector_digiline = {
	effector = {
		action = function(pos, node, channel, msg)
			local meta = minetest.get_meta(pos)

			if channel ~= meta:get_string("digiline_channel") then return end

			if type(msg) == "table" then
				if msg.distance or msg.scanname then
					if msg.distance then
						meta:set_string("distance", msg.distance)
					end
					if msg.scanname then
						meta:set_string("scanname", msg.scanname)
					end
					node_detector_make_formspec(pos)
				end
				if msg.command == "get" then
					node_detector_send_node_name(pos, node, channel, meta)
				elseif msg.command == "scan" then
					local result = node_detector_scan(pos)
					digiline:receptor_send(pos, digiline.rules.default, channel, result)
				end
			else
				if msg == GET_COMMAND then
					node_detector_send_node_name(pos, node, channel, meta)
				else
					meta:set_string("scanname", msg)
					node_detector_make_formspec(pos)
				end
			end
		end,
	},
	receptor = {}
}
]]

minetest.register_node("mesecons_detector:node_detector_off", {
	tiles = {side_texture, side_texture, side_texture, side_texture, side_texture, "jeija_node_detector_off.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	walkable = true,
	groups = {cracky=3},
	description="detektor předmětů",
	mesecons = {receptor = {
		state = mesecon.state.off
	}},
	on_construct = node_detector_make_formspec,
	on_receive_fields = node_detector_on_receive_fields,
	sounds = mesecon.node_sound.stone,
	-- digiline = node_detector_digiline,
	on_blast = mesecon.on_blastnode,
})

minetest.register_node("mesecons_detector:node_detector_on", {
	tiles = {side_texture, side_texture, side_texture, side_texture, side_texture, "jeija_node_detector_on.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	walkable = true,
	groups = {cracky=3,not_in_creative_inventory=1},
	drop = 'mesecons_detector:node_detector_off',
	mesecons = {receptor = {
		state = mesecon.state.on
	}},
	on_construct = node_detector_make_formspec,
	on_receive_fields = node_detector_on_receive_fields,
	sounds = mesecon.node_sound.stone,
	-- digiline = node_detector_digiline,
	on_blast = mesecon.on_blastnode,
})

minetest.register_craft({
	output = 'mesecons_detector:node_detector_off',
	recipe = {
		{"mesecons_gamecompat:steel_ingot", "group:mesecon_conductor_craftable", "mesecons_gamecompat:steel_ingot"},
		{"mesecons_gamecompat:steel_ingot", "mesecons_luacontroller:luacontroller0000", "mesecons_gamecompat:steel_ingot"},
		{"mesecons_gamecompat:steel_ingot", "mesecons_gamecompat:steel_ingot", "mesecons_gamecompat:steel_ingot"},
	}
})

minetest.register_craft({
	output = 'mesecons_detector:node_detector_off',
	recipe = {
		{"mesecons_gamecompat:steel_ingot", "group:mesecon_conductor_craftable", "mesecons_gamecompat:steel_ingot"},
		{"mesecons_gamecompat:steel_ingot", "mesecons_microcontroller:microcontroller0000", "mesecons_gamecompat:steel_ingot"},
		{"mesecons_gamecompat:steel_ingot", "mesecons_gamecompat:steel_ingot", "mesecons_gamecompat:steel_ingot"},
	}
})

minetest.register_abm({
	nodenames = {"mesecons_detector:node_detector_off"},
	interval = 1,
	chance = 1,
	action = function(pos, node)
		if not node_detector_scan(pos) then return end

		node.name = "mesecons_detector:node_detector_on"
		minetest.swap_node(pos, node)
		mesecon.receptor_on(pos)
	end,
})

minetest.register_abm({
	nodenames = {"mesecons_detector:node_detector_on"},
	interval = 1,
	chance = 1,
	action = function(pos, node)
		if node_detector_scan(pos) then return end

		node.name = "mesecons_detector:node_detector_off"
		minetest.swap_node(pos, node)
		mesecon.receptor_off(pos)
	end,
})

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
