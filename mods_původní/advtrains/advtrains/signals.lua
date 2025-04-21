--advtrains by orwell96
--signals.lua

local mrules_wallsignal = advtrains.meseconrules

local function can_dig_func(pos, player)
	if advtrains.interlocking then
		return advtrains.interlocking.signal.can_dig(pos, player)
	end
	return true
end
local function after_dig_func(pos, oldnode, oldmetadata, digger)
	if advtrains.interlocking then
		return advtrains.interlocking.signal.after_dig(pos, oldnode, oldmetadata, digger)
	end
	return true
end

local function aspect(b)
return {
	main = b and -1 or 0,
	shunt = false,
	proceed_as_main = true,
	dst = false,
	info = {}
}
end

local main_aspects = {
	{ name = "free", description = "Free" }
}

local function simple_apply_aspect(offname, onname)
	return function(pos, node, main_aspect, rem_aspect, rem_aspinfo)
		if main_aspect.halt then
			advtrains.ndb.swap_node(pos, {name = offname, param2 = node.param2})
		else
			advtrains.ndb.swap_node(pos, {name = onname, param2 = node.param2})
		end
	end
end

for r,f in pairs({on={as="off", ls="green", als="red"}, off={as="on", ls="red", als="green"}}) do

	for rotid, rotation in ipairs({"", "_30", "_45", "_60"}) do
		local crea=1
		if rotid==1 and r=="off" then crea=0 end
		
		minetest.register_node("advtrains:retrosignal_"..r..rotation, {
			drawtype = "mesh",
			paramtype="light",
			paramtype2="facedir",
			walkable = false,
			selection_box = {
				type = "fixed",
				fixed = {-1/4, -1/2, -1/4, 1/4, 2, 1/4},
			},
			mesh = "advtrains_retrosignal_"..r..rotation..".b3d",
			tiles = {"advtrains_retrosignal.png"},
			inventory_image="advtrains_retrosignal_inv.png",
			drop="advtrains:retrosignal_off",
			description=attrans("Lampless Signal"),
			sunlight_propagates=true,
			groups = {
				cracky=3,
				not_blocking_trains=1,
				not_in_creative_inventory=crea,
				save_in_at_nodedb=1,
				advtrains_signal = 2,
			},
			mesecons = {effector = {
				rules=advtrains.meseconrules,
				["action_"..f.as] = function (pos, node)
					advtrains.ndb.swap_node(pos, {name = "advtrains:retrosignal_"..f.as..rotation, param2 = node.param2}, true)
					if advtrains.interlocking then
						-- forcefully clears any set aspect, so that aspect system doesnt override it again
						advtrains.interlocking.signal.unregister_aspect(pos)
						-- notify trains
						advtrains.interlocking.signal.notify_trains(pos)
					end
				end
			}},
			on_rightclick=function(pos, node, player)
				local pname = player:get_player_name()
				local sigd = advtrains.interlocking and advtrains.interlocking.db.get_sigd_for_signal(pos)
				if sigd then
					advtrains.interlocking.show_signalling_form(sigd, pname)
				elseif advtrains.interlocking and player:get_player_control().aux1 then
					advtrains.interlocking.show_ip_form(pos, pname)
				elseif advtrains.check_turnout_signal_protection(pos, player:get_player_name()) then
					advtrains.ndb.swap_node(pos, {name = "advtrains:retrosignal_"..f.as..rotation, param2 = node.param2}, true)
					if advtrains.interlocking then
						-- forcefully clears any set aspect, so that aspect system doesnt override it again
						advtrains.interlocking.signal.unregister_aspect(pos)
						-- notify trains
						advtrains.interlocking.signal.notify_trains(pos)
					end
				end
			end,
			-- very new signal API
			advtrains = {
				main_aspects = main_aspects,
				apply_aspect = simple_apply_aspect("advtrains:retrosignal_off"..rotation, "advtrains:retrosignal_on"..rotation),
				get_aspect_info = function() return aspect(r=="on") end,
			},
			can_dig = can_dig_func,
			after_dig_node = after_dig_func,
			--TODO add rotation using trackworker
		})
		
		minetest.register_node("advtrains:signal_"..r..rotation, {
			drawtype = "mesh",
			paramtype="light",
			paramtype2="facedir",
			walkable = false,
			selection_box = {
				type = "fixed",
				fixed = {-1/4, -1/2, -1/4, 1/4, 2, 1/4},
			},
			mesh = "advtrains_signal"..rotation..".b3d",
			tiles = {"advtrains_signal_"..r..".png"},
			inventory_image="advtrains_signal_inv.png",
			drop="advtrains:signal_off",
			description=attrans("Signal"),
			groups = {
				cracky=3,
				not_blocking_trains=1,
				not_in_creative_inventory=crea,
				save_in_at_nodedb=1,
				advtrains_signal = 2,
			},
			light_source = 1,
			sunlight_propagates=true,
			mesecons = {effector = {
				rules=advtrains.meseconrules,
				["action_"..f.as] = function (pos, node)
					advtrains.setstate(pos, f.als, node)
				end
			}},
			on_rightclick=function(pos, node, player)
				local pname = player:get_player_name()
				local sigd = advtrains.interlocking and advtrains.interlocking.db.get_sigd_for_signal(pos)
				if sigd then
					advtrains.interlocking.show_signalling_form(sigd, pname)
				elseif advtrains.interlocking and player:get_player_control().aux1 then
					advtrains.interlocking.show_ip_form(pos, pname)
				elseif advtrains.check_turnout_signal_protection(pos, player:get_player_name()) then
					advtrains.setstate(pos, f.als, node)
				end
			end,
			-- very new signal API
			advtrains = {
				main_aspects = main_aspects,
				apply_aspect = simple_apply_aspect("advtrains:signal_off"..rotation, "advtrains:signal_on"..rotation),
				get_aspect_info = function() return aspect(r=="on") end,
				node_state = f.ls,
				node_state_map = { red = "advtrains:signal_off"..rotation, green = "advtrains:signal_on"..rotation},
				node_on_switch_state = function(pos, new_node, old_state, new_state)
					if advtrains.interlocking then
						-- forcefully clears any set aspect, so that aspect system doesnt override it again
						advtrains.interlocking.signal.unregister_aspect(pos)
						-- notify trains
						advtrains.interlocking.signal.notify_trains(pos)
					end
				end,
			},
			can_dig = can_dig_func,
			after_dig_node = after_dig_func,
			--TODO add rotation using trackworker
		})
	end
	
	local crea=1
	if r=="off" then crea=0 end
	
	--tunnel signals. no rotations.
	local swdesc = { -- needed for xgettext
		l = attrans("Wallmounted Signal (left)"),
		r = attrans("Wallmounted Signal (right)"),
		t = attrans("Wallmounted Signal (top)"),
	}
	for loc, sbox in pairs({l={-1/2, -1/2, -1/4, 0, 1/2, 1/4}, r={0, -1/2, -1/4, 1/2, 1/2, 1/4}, t={-1/2, 0, -1/4, 1/2, 1/2, 1/4}}) do
		minetest.register_node("advtrains:signal_wall_"..loc.."_"..r, {
			drawtype = "mesh",
			paramtype="light",
			paramtype2="facedir",
			walkable = false,
			selection_box = {
				type = "fixed",
				fixed = sbox,
			},
			mesh = "advtrains_signal_wall_"..loc..".b3d",
			tiles = {"advtrains_signal_wall_"..r..".png"},
			drop="advtrains:signal_wall_"..loc.."_off",
			description=swdesc[loc],
			groups = {
				cracky=3,
				not_blocking_trains=1,
				not_in_creative_inventory=crea,
				save_in_at_nodedb=1,
				advtrains_signal = 2,
			},
			light_source = 1,
			sunlight_propagates=true,
			mesecons = {effector = {
				rules = mrules_wallsignal,
				["action_"..f.as] = function (pos, node)
					advtrains.setstate(pos, f.als, node)
				end
			}},
			on_rightclick=function(pos, node, player)
				local pname = player:get_player_name()
				local sigd = advtrains.interlocking and advtrains.interlocking.db.get_sigd_for_signal(pos)
				if sigd then
					advtrains.interlocking.show_signalling_form(sigd, pname)
				elseif advtrains.interlocking and player:get_player_control().aux1 then
					advtrains.interlocking.show_ip_form(pos, pname)
				elseif advtrains.check_turnout_signal_protection(pos, player:get_player_name()) then
					advtrains.setstate(pos, f.als, node)
				end
			end,
			-- very new signal API
			advtrains = {
				main_aspects = main_aspects,
				apply_aspect = simple_apply_aspect("advtrains:signal_wall_"..loc.."_off", "advtrains:signal_wall_"..loc.."_on"),
				get_aspect_info = function() return aspect(r=="on") end,
				node_state = f.ls,
				node_state_map = { red = "advtrains:signal_wall_"..loc.."_off", green = "advtrains:signal_wall_"..loc.."_on" },
				node_on_switch_state = function(pos, new_node, old_state, new_state)
					if advtrains.interlocking then
						-- forcefully clears any set aspect, so that aspect system doesnt override it again
						advtrains.interlocking.signal.unregister_aspect(pos)
						-- notify trains
						advtrains.interlocking.signal.notify_trains(pos)
					end
				end,
			},
			can_dig = can_dig_func,
			after_dig_node = after_dig_func,
		})
	end
end

-- level crossing
-- german version (Andrew's Cross)
minetest.register_node("advtrains:across_off", {
	drawtype = "mesh",
	paramtype="light",
	paramtype2="facedir",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-1/4, -1/2, -1/2, 1/4, 1.5, 0},
	},
	mesh = "advtrains_across.obj",
	tiles = {"advtrains_across.png"},
	drop="advtrains:across_off",
	description=attrans("Andrew's Cross"),
	groups = {
		cracky=3,
		not_blocking_trains=1,
		save_in_at_nodedb=1,
		not_in_creative_inventory=nil,
	},
	light_source = 1,
	sunlight_propagates=true,
	mesecons = {effector = {
		rules = advtrains.meseconrules,
		action_on = function (pos, node)
			advtrains.ndb.swap_node(pos, {name = "advtrains:across_on", param2 = node.param2}, true)
		end
	}},
	advtrains = {
		node_state = "off",
		node_state_map = { on = "advtrains:across_on", off = "advtrains:across_off" },
	},
	on_rightclick=function(pos, node, player)
		if advtrains.check_turnout_signal_protection(pos, player:get_player_name()) then
			advtrains.ndb.swap_node(pos, {name = "advtrains:across_on", param2 = node.param2}, true)
		end
	end,
})
minetest.register_node("advtrains:across_on", {
	drawtype = "mesh",
	paramtype="light",
	paramtype2="facedir",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-1/4, -1/2, -1/2, 1/4, 1.5, 0},
	},
	mesh = "advtrains_across.obj",
	tiles = {{name="advtrains_across_anim.png", animation={type="vertical_frames", aspect_w=64, aspect_h=64, length=1.0}}},
	drop="advtrains:across_off",
	description=attrans("Andrew's Cross"),
	groups = {
		cracky=3,
		not_blocking_trains=1,
		save_in_at_nodedb=1,
		not_in_creative_inventory=1,
	},
	light_source = 1,
	sunlight_propagates=true,
	mesecons = {effector = {
		rules = advtrains.meseconrules,
		action_off = function (pos, node)
			advtrains.ndb.swap_node(pos, {name = "advtrains:across_off", param2 = node.param2}, true)
		end
	}},
	advtrains = {
		node_state = "on",
		node_state_map = { on = "advtrains:across_on", off = "advtrains:across_off" },
		node_fallback_state = "off",
	},
	on_rightclick=function(pos, node, player)
		if advtrains.check_turnout_signal_protection(pos, player:get_player_name()) then
			advtrains.ndb.swap_node(pos, {name = "advtrains:across_off", param2 = node.param2}, true)
		end
	end,
})

minetest.register_abm(
	{
        label = "Sound for Level Crossing",
        nodenames = {"advtrains:across_on"},
        interval = 3,
        chance = 1,
        action = function(pos, node, active_object_count, active_object_count_wider)
			minetest.sound_play("advtrains_crossing_bell", {
				pos = pos,
				gain = 1.0, -- default
				max_hear_distance = 16, -- default, uses an euclidean metric
			})
        end,
    }
)
