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
-- Something nice to play is appending core.env to it.
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

-----------------------
-- Node Registration --
-----------------------

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

local texture_alpha_mode = core.features.use_texture_alpha_string_modes
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
	tiles[3] = tiles[3]..tiles_on_off.R180:format(yellow == 1 and "on" or "off");
	tiles[4] = tiles[4]..tiles_on_off.R180:format(yellow == 1 and "on" or "off");
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

	local groups = {snappy = 3, tube = 1, tubedevice = 1, overheat = 1, dig_generic = 4, axey=1, handy=1, pickaxey=1}
	if red + blue + yellow + green + black + white ~= 0 then
		groups.not_in_creative_inventory = 1
	end

	output_rules[cid] = {}
	input_rules[cid] = {}
	if red    == 1 then table.insert(output_rules[cid], rules.red)    end
	if blue   == 1 then table.insert(output_rules[cid], rules.blue)   end
	if yellow == 1 then table.insert(output_rules[cid], rules.yellow) end
	if green  == 1 then table.insert(output_rules[cid], rules.green)  end
	if black  == 1 then table.insert(output_rules[cid], rules.black)  end
	if white  == 1 then table.insert(output_rules[cid], rules.white)  end

	if red    == 0 then table.insert( input_rules[cid], rules.red)    end
	if blue   == 0 then table.insert( input_rules[cid], rules.blue)   end
	if yellow == 0 then table.insert( input_rules[cid], rules.yellow) end
	if green  == 0 then table.insert( input_rules[cid], rules.green)  end
	if black  == 0 then table.insert( input_rules[cid], rules.black)  end
	if white  == 0 then table.insert( input_rules[cid], rules.white)  end

	local mesecons = {
		effector = {
			rules = input_rules[cid],
			action_change = function (pos, _, rule_name, new_state)
				update_real_port_states(pos, rule_name, new_state)
				run(pos, {type=new_state, pin=rule_name})
			end,
		},
		receptor = {
			state = mesecon.state.on,
			rules = output_rules[cid]
		},
	}

	core.register_node(node_name, {
		description = S("Lua controlled Tube (priority @1)", "50"),
		drawtype = "nodebox",
		tiles = tiles,
		use_texture_alpha = texture_alpha_mode,
		paramtype = "light",
		is_ground_content = false,
		groups = groups,
		_mcl_hardness=0.8,
		drop = BASENAME.."000000",
		sunlight_propagates = true,
		selection_box = selection_box,
		node_box = node_box,
		_sound_def = {
			key = "node_sound_wood_defaults",
		},
		mesecons = mesecons,
		-- Virtual portstates are the ports that
		-- the node shows as powered up (light up).
		virtual_portstates = {
			red    = red    == 1,
			blue   = blue   == 1,
			yellow = yellow == 1,
			green  = green  == 1,
			black  = black  == 1,
			white  = white  == 1,
		},
		after_dig_node = function(pos, node)
			mesecon.do_cooldown(pos)
			mesecon.receptor_off(pos, output_rules)
			pipeworks.after_dig(pos, node)
		end,
		tubelike = 1,
		tube = {
			connect_sides = {front = 1, back = 1, left = 1, right = 1, top = 1, bottom = 1},
			priority = 50,
			can_go = function(pos, node, velocity, stack, tags)
				local src = {name = nil}
				-- add color of the incoming tube explicitly; referring to rules, in case they change later
				for _, rule in pairs(rules) do
					if (-velocity.x == rule.x and -velocity.y == rule.y and -velocity.z == rule.z) then
						src.name = rule.name
						break
					end
				end
				local succ, _, msg = run(pos, {
					type = "item",
					pin = src,
					itemstring = stack:to_string(),
					item = stack:to_table(),
					velocity = velocity,
					tags = table.copy(tags),
					side = src.name,
				})
				if not succ then
					return go_back(velocity)
				end
				if type(msg) == "string" then
					local side = rules[msg]
					return side and {side} or go_back(velocity)
				elseif type(msg) == "table" then
					if pipeworks.enable_item_tags then
						local new_tags
						if type(msg.tags) == "table" or type(msg.tags) == "string" then
							new_tags = pipeworks.sanitize_tags(msg.tags)
						elseif type(msg.tag) == "string" then
							new_tags = pipeworks.sanitize_tags({msg.tag})
						end
						if new_tags then
							for i=1, math.max(#tags, #new_tags) do
								tags[i] = new_tags[i]
							end
						end
					end
					local side = rules[msg.side]
					return side and {side} or go_back(velocity)
				end
				return go_back(velocity)
			end,
		},
		after_place_node = pipeworks.after_place,
		on_blast = function(pos, intensity)
			if not intensity or intensity > 1 + 3^0.5 then
				core.remove_node(pos)
				return
			end
			core.swap_node(pos, {name = "pipeworks:broken_tube_1"})
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

core.register_node(BASENAME .. "_burnt", {
	drawtype = "nodebox",
	tiles = tiles_burnt,
	use_texture_alpha = texture_alpha_mode,
	is_burnt = true,
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy = 3, tube = 1, tubedevice = 1, not_in_creative_inventory=1, dig_generic = 4, axey=1, handy=1, pickaxey=1},
	_mcl_hardness=0.8,
	drop = BASENAME.."000000",
	sunlight_propagates = true,
	selection_box = selection_box,
	node_box = node_box,
	_sound_def = {
        key = "node_sound_wood_defaults",
    },
	virtual_portstates = {red = false, blue = false, yellow = false,
		green = false, black = false, white = false},
	mesecons = {
		effector = {
			rules = mesecon.rules.alldirs,
			action_change = function(pos, _, rule_name, new_state)
				update_real_port_states(pos, rule_name, new_state)
			end,
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
			core.remove_node(pos)
			return
		end
		core.swap_node(pos, {name = "pipeworks:broken_tube_1"})
		pipeworks.scan_for_tube_objects(pos)
	end,
})

------------------------
-- Craft Registration --
------------------------

core.register_craft({
	type = "shapeless",
	output = BASENAME.."000000",
	recipe = {"pipeworks:mese_tube_000000", "mesecons_luacontroller:luacontroller0000"},
})
