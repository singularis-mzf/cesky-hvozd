--        ______
--       |
--       |
--       |        __       ___  _   __         _  _
-- |   | |       |  | |\ |  |  |_| |  | |  |  |_ |_|
-- |___| |______ |__| | \|  |  | \ |__| |_ |_ |_ |\  tube
-- |
-- |
--

-- Reference
-- ports = get_real_port_states(pos): gets if inputs are powered from outside
-- newport = merge_port_states(state1, state2): just does result = state1 or state2 for every port
-- set_port(pos, rule, state): activates/deactivates the mesecons according to the port states
-- set_port_states(pos, ports): Applies new port states to a Luacontroller at pos
-- run_inner(pos, code, event): runs code on the controller at pos and event
-- reset_formspec(pos, code, errmsg): installs new code and prints error messages, without resetting LCID
-- reset_meta(pos, code, errmsg): performs a software-reset, installs new code and prints error message
-- run(pos, event): a wrapper for run_inner which gets code & handles errors via reset_meta
-- resetn(pos): performs a hardware reset, turns off all ports
--
-- The Sandbox
-- The whole code of the controller runs in a sandbox,
-- a very restricted environment.
-- Actually the only way to damage the server is to
-- use too much memory from the sandbox.
-- You can add more functions to the environment
-- (see where local env is defined)
-- Something nice to play is appending minetest.env to it.
local S = minetest.get_translator("pipeworks")
local BASENAME = "pipeworks:lua_tube"

local rules = {
	red    = {x = -1, y =  0, z =  0, name = "red"},
	blue   = {x =  1, y =  0, z =  0, name = "blue"},
	yellow = {x =  0, y = -1, z =  0, name = "yellow"},
	green  = {x =  0, y =  1, z =  0, name = "green"},
	black  = {x =  0, y =  0, z = -1, name = "black"},
	white  = {x =  0, y =  0, z =  1, name = "white"},
}

local output_rules = {}
local input_rules = {}

local node_box = {
	type = "fixed",
	fixed = {
		pipeworks.tube_leftstub[1],   -- tube segment against -X face
		pipeworks.tube_rightstub[1],  -- tube segment against +X face
		pipeworks.tube_bottomstub[1], -- tube segment against -Y face
		pipeworks.tube_topstub[1],    -- tube segment against +Y face
		pipeworks.tube_frontstub[1],  -- tube segment against -Z face
		pipeworks.tube_backstub[1],   -- tube segment against +Z face
	}
}

local selection_box = {
	type = "fixed",
	fixed = pipeworks.tube_selectboxes,
}

local function go_back(velocity)
	local adjlist={{x=0,y=0,z=1},{x=0,y=0,z=-1},{x=0,y=1,z=0},{x=0,y=-1,z=0},{x=1,y=0,z=0},{x=-1,y=0,z=0}}
	local speed = math.abs(velocity.x + velocity.y + velocity.z)
	if speed == 0 then
		speed = 1
	end
	local vel = {x = velocity.x/speed, y = velocity.y/speed, z = velocity.z/speed,speed=speed}
	if speed >= 4.1 then
		speed = 4
	elseif speed >= 1.1 then
		speed = speed - 0.1
	else
		speed = 1
	end
	vel.speed = speed
	return pipeworks.notvel(adjlist, vel)
end

local tiles_base = {
	"pipeworks_mese_tube_plain_4.png", "pipeworks_mese_tube_plain_3.png",
	"pipeworks_mese_tube_plain_2.png", "pipeworks_mese_tube_plain_1.png",
	"pipeworks_mese_tube_plain_6.png", "pipeworks_mese_tube_plain_5.png"}

local tiles_on_off = {
	R__0   = "^pipeworks_lua_tube_port_%s.png",
	R_90  = "^(pipeworks_lua_tube_port_%s.png^[transformR90)",
	R180 = "^(pipeworks_lua_tube_port_%s.png^[transformR180)",
	R270 = "^(pipeworks_lua_tube_port_%s.png^[transformR270)"
}

local texture_alpha_mode = minetest.features.use_texture_alpha_string_modes
	and "clip" or true

local red, blue, yellow, green, black, white = 0, 0, 0, 0, 0, 0
local cid = white..black..green..yellow..blue..red
local node_name = BASENAME..cid

local tiles = table.copy(tiles_base)
-- Red
tiles[1] = tiles[1]..tiles_on_off.R_90:format(red == 1 and "on" or "off");
tiles[2] = tiles[2]..tiles_on_off.R_90:format(red == 1 and "on" or "off");
tiles[5] = tiles[5]..tiles_on_off.R270:format(red == 1 and "on" or "off");
tiles[6] = tiles[6]..tiles_on_off.R_90:format(red == 1 and "on" or "off");
-- Blue
tiles[1] = tiles[1]..tiles_on_off.R270:format(blue == 1 and "on" or "off");
tiles[2] = tiles[2]..tiles_on_off.R270:format(blue == 1 and "on" or "off");
tiles[5] = tiles[5]..tiles_on_off.R_90:format(blue == 1 and "on" or "off");
tiles[6] = tiles[6]..tiles_on_off.R270:format(blue == 1 and "on" or "off");
-- Yellow
tiles[1] = tiles[1]..tiles_on_off.R180:format(yellow == 1 and "on" or "off");
tiles[2] = tiles[2]..tiles_on_off.R180:format(yellow == 1 and "on" or "off");
tiles[5] = tiles[5]..tiles_on_off.R180:format(yellow == 1 and "on" or "off");
tiles[6] = tiles[6]..tiles_on_off.R180:format(yellow == 1 and "on" or "off");
-- Green
tiles[3] = tiles[3]..tiles_on_off.R__0:format(green == 1 and "on" or "off");
tiles[4] = tiles[4]..tiles_on_off.R__0:format(green == 1 and "on" or "off");
tiles[5] = tiles[5]..tiles_on_off.R__0:format(green == 1 and "on" or "off");
tiles[6] = tiles[6]..tiles_on_off.R__0:format(green == 1 and "on" or "off");
-- Black
tiles[1] = tiles[1]..tiles_on_off.R180:format(black == 1 and "on" or "off");
tiles[2] = tiles[2]..tiles_on_off.R__0:format(black == 1 and "on" or "off");
tiles[3] = tiles[3]..tiles_on_off.R_90:format(black == 1 and "on" or "off");
tiles[4] = tiles[4]..tiles_on_off.R270:format(black == 1 and "on" or "off");
-- White
tiles[1] = tiles[1]..tiles_on_off.R__0:format(white == 1 and "on" or "off");
tiles[2] = tiles[2]..tiles_on_off.R180:format(white == 1 and "on" or "off");
tiles[3] = tiles[3]..tiles_on_off.R270:format(white == 1 and "on" or "off");
tiles[4] = tiles[4]..tiles_on_off.R_90:format(white == 1 and "on" or "off");

local groups = {snappy = 3, tube = 1, tubedevice = 1, overheat = 1, dig_generic = 4}

output_rules[cid] = {}
input_rules[cid] = {rules.red, rules.blue, rules.yellow, rules.green, rules.black, rules.white}

local mesecons = {
	effector = {
		rules = input_rules[cid],
	},
	receptor = {
		state = mesecon.state.on,
		rules = output_rules[cid]
	},
}

minetest.register_node(node_name, {
	description = S("Lua controlled Tube (priority @1)", 50),
	drawtype = "nodebox",
	tiles = tiles,
	use_texture_alpha = texture_alpha_mode,
	paramtype = "light",
	is_ground_content = false,
	groups = groups,
	drop = BASENAME.."000000",
	sunlight_propagates = true,
	selection_box = selection_box,
	node_box = node_box,
	sounds = default.node_sound_wood_defaults(),
	mesecons = mesecons,
	after_dig_node = function(pos, node)
		mesecon.do_cooldown(pos)
		mesecon.receptor_off(pos, output_rules)
		pipeworks.after_dig(pos, node)
	end,
	tubelike = 1,
	tube = {
		connect_sides = {front = 1, back = 1, left = 1, right = 1, top = 1, bottom = 1},
		priority = 50,
		can_go = function(pos, node, velocity, stack)
			return go_back(velocity)
		end,
	},
	after_place_node = pipeworks.after_place,
	on_blast = function(pos, intensity)
		if not intensity or intensity > 1 + 3^0.5 then
			minetest.remove_node(pos)
			return
		end
		minetest.swap_node(pos, {name = "pipeworks:broken_tube_1"})
		pipeworks.scan_for_tube_objects(pos)
	end,
})

pipeworks.ui_cat_tube_list[#pipeworks.ui_cat_tube_list+1] = BASENAME.."000000"

------------------------------------
-- Overheated Lua controlled Tube --
------------------------------------

local tiles_burnt = table.copy(tiles_base)
tiles_burnt[1] = tiles_burnt[1].."^(pipeworks_lua_tube_port_burnt.png^[transformR90)"
tiles_burnt[2] = tiles_burnt[2].."^(pipeworks_lua_tube_port_burnt.png^[transformR90)"
tiles_burnt[5] = tiles_burnt[5].."^(pipeworks_lua_tube_port_burnt.png^[transformR270)"
tiles_burnt[6] = tiles_burnt[6].."^(pipeworks_lua_tube_port_burnt.png^[transformR90)"
tiles_burnt[1] = tiles_burnt[1].."^(pipeworks_lua_tube_port_burnt.png^[transformR270)"
tiles_burnt[2] = tiles_burnt[2].."^(pipeworks_lua_tube_port_burnt.png^[transformR270)"
tiles_burnt[5] = tiles_burnt[5].."^(pipeworks_lua_tube_port_burnt.png^[transformR90)"
tiles_burnt[6] = tiles_burnt[6].."^(pipeworks_lua_tube_port_burnt.png^[transformR270)"
tiles_burnt[3] = tiles_burnt[3].."^(pipeworks_lua_tube_port_burnt.png^[transformR180)"
tiles_burnt[4] = tiles_burnt[4].."^(pipeworks_lua_tube_port_burnt.png^[transformR180)"
tiles_burnt[5] = tiles_burnt[5].."^(pipeworks_lua_tube_port_burnt.png^[transformR180)"
tiles_burnt[6] = tiles_burnt[6].."^(pipeworks_lua_tube_port_burnt.png^[transformR180)"
tiles_burnt[3] = tiles_burnt[3].."^pipeworks_lua_tube_port_burnt.png"
tiles_burnt[4] = tiles_burnt[4].."^pipeworks_lua_tube_port_burnt.png"
tiles_burnt[5] = tiles_burnt[5].."^pipeworks_lua_tube_port_burnt.png"
tiles_burnt[6] = tiles_burnt[6].."^pipeworks_lua_tube_port_burnt.png"
tiles_burnt[1] = tiles_burnt[1].."^(pipeworks_lua_tube_port_burnt.png^[transformR180)"
tiles_burnt[2] = tiles_burnt[2].."^pipeworks_lua_tube_port_burnt.png"
tiles_burnt[3] = tiles_burnt[3].."^(pipeworks_lua_tube_port_burnt.png^[transformR90)"
tiles_burnt[4] = tiles_burnt[4].."^(pipeworks_lua_tube_port_burnt.png^[transformR270)"
tiles_burnt[1] = tiles_burnt[1].."^pipeworks_lua_tube_port_burnt.png"
tiles_burnt[2] = tiles_burnt[2].."^(pipeworks_lua_tube_port_burnt.png^[transformR180)"
tiles_burnt[3] = tiles_burnt[3].."^(pipeworks_lua_tube_port_burnt.png^[transformR270)"
tiles_burnt[4] = tiles_burnt[4].."^(pipeworks_lua_tube_port_burnt.png^[transformR90)"

minetest.register_node(BASENAME .. "_burnt", {
	drawtype = "nodebox",
	tiles = tiles_burnt,
	use_texture_alpha = texture_alpha_mode,
	is_burnt = true,
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy = 3, tube = 1, tubedevice = 1, not_in_creative_inventory=1, dig_generic = 4},
	drop = BASENAME.."000000",
	sunlight_propagates = true,
	selection_box = selection_box,
	node_box = node_box,
	sounds = default.node_sound_wood_defaults(),
	mesecons = {
		effector = {
			rules = mesecon.rules.alldirs,
		},
	},
	tubelike = 1,
	tube = {
		connect_sides = {front = 1, back = 1, left = 1, right = 1, top = 1, bottom = 1},
		priority = 50,
	},
	after_place_node = pipeworks.after_place,
	after_dig_node = pipeworks.after_dig,
	on_blast = function(pos, intensity)
		if not intensity or intensity > 1 + 3^0.5 then
			minetest.remove_node(pos)
			return
		end
		minetest.swap_node(pos, {name = "pipeworks:broken_tube_1"})
		pipeworks.scan_for_tube_objects(pos)
	end,
})

------------------------
-- Craft Registration --
------------------------

minetest.register_craft({
	type = "shapeless",
	output = BASENAME.."000000",
	recipe = {"pipeworks:mese_tube_000000", "mesecons_luacontroller:luacontroller0000"},
})
