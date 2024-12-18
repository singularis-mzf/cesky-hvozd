ch_base.open_mod(minetest.get_current_modname())

--[[
mesecon.rules.flat2 =
{{x = 2, y = 0, z = 0},
 {x =-2, y = 0, z = 0},
 {x = 0, y = 0, z = 2},
 {x = 0, y = 0, z =-2}
}

mesecon.rules.shunting_signal =
{{x = 1, y = 0, z = 0},
 {x =-1, y = 0, z = 0},
 {x = 0, y = 0, z = 1},
 {x = 0, y = 0, z =-1},
 {x = 0, y = -1, z = 0}
}

mesecon.rules.switch = {
 p0 = {{x = 0, y = 0, z = 1}},
 p1 = {{x = 1, y = 0, z = 0}},
 p2 = {{x = 0, y = 0, z = -1}},
 p3 = {{x = -1, y = 0, z = 0}}
}
]]

-- param = 2
-- {{x = 0, y = 0, z = -1}}
-- param = 0
-- {{x = 0, y = 0, z = 1}}
-- param = 3
-- {{x = -1, y = 0, z = 0}}
-- param = 1
-- {{x = 1, y = 0, z = 0}}

--[[
local function switch_get_rules(orientation)
	if orientation == 0 then
		return {{x = 0, y = 0, z = 1}}
	elseif orientation == 1 then
		return {{x = 1, y = 0, z = 0}}
	elseif orientation == 2 then
		return {{x = 0, y = 0, z = -1}}
	elseif orientation == 3 then
		return {{x = -1, y = 0, z = 0}}
	end
	return {{ x = 0, y = 0, z = 0 }}
end
]]

-- POINT LEVERS WITH ARROW INDICATORS

minetest.register_node("railroad_paraphernalia:switch_with_arrow_off_0", {
	description = 'výměnové návěstidlo se šipkou',
	drawtype = "mesh",
	mesh = "switch_arrow_2_off.b3d",
	tiles = { "points_lever_arrow.png" },
	selection_box = { 
				type = "fixed",
				fixed = {
						{-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},
						{-0.5, -0.5, -1.5, 0.5, 0.5, -0.5}
						}
				},
	walkable = false,
	groups = {snappy=1, choppy=2, oddly_breakable_by_hand=2, flammable=3, not_blocking_trains = 1},
	on_place = minetest.rotate_node,
	paramtype = "light",
	paramtype2 = "facedir",
	mesecons = {receptor = {state = mesecon.state.off}},
	after_place_node = function (pos, placer, itemstack, pointed_thing)
		mesecon.receptor_off(pos)
	end,
	on_rightclick = function (pos, node, player, itemstack, pointed_thing)
		minetest.set_node(pos, { name = "railroad_paraphernalia:switch_with_arrow_on_0", param2 = minetest.get_node(pos).param2 } )
		minetest.sound_play("piston_extend", {
			pos = pos,
			max_hear_distance = 20,
			gain = 0.3,
		})
		mesecon.receptor_on(pos)
	end,
})

minetest.register_node("railroad_paraphernalia:switch_with_arrow_on_0", {
	--description = 'Point lever w/arrow',
	drawtype = "mesh",
	mesh = "switch_arrow_2_on.b3d",
	tiles = { "points_lever_arrow.png" },
	selection_box = { 
				type = "fixed",
				fixed = {
						{-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},
						{-0.5, -0.5, -1.5, 0.5, 0.5, -0.5}
						}
				},
	walkable = false,
	groups = {snappy=1, choppy=2, oddly_breakable_by_hand=2, flammable=3, not_in_creative_inventory=1, not_blocking_trains = 1},
	on_place = minetest.rotate_node,
	paramtype = "light",
	paramtype2 = "facedir",
	mesecons = {receptor = {state = mesecon.state.on}},
	on_rightclick = function (pos, node, player, itemstack, pointed_thing)
		minetest.set_node(pos, { name = "railroad_paraphernalia:switch_with_arrow_off_0", param2 = minetest.get_node(pos).param2 } )
		minetest.sound_play("piston_retract", {
			pos = pos,
			max_hear_distance = 20,
			gain = 0.3,
		})
		mesecon.receptor_off(pos)
	end,
	drop = "railroad_paraphernalia:switch_with_arrow_off_0"
})

minetest.register_craft({
	output = 'railroad_paraphernalia:switch_with_arrow_off_0 3',
	recipe = {
		{'dye:black', 'dye:white', 'dye:black'},
		{'', 'default:stick', 'default:stick'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
	}
})

-- POINT LEVERS WITH LAMP INDICATORS

minetest.register_node("railroad_paraphernalia:switch_with_lamp_off_0", {
	description = 'výměnové návěstidlo s lampou',
	drawtype = "mesh",
	mesh = "switch_lamp_2_off.b3d",
	tiles = { "points_lever_lamp.png" },
	selection_box = { 
				type = "fixed",
				fixed = {
						{-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},
						{-0.5, -0.5, -1.5, 0.5, 1, -0.5}
						}
				},
	walkable = false,
	groups = {snappy=1, choppy=2, oddly_breakable_by_hand=2, flammable=3, not_blocking_trains = 1},
	on_place = minetest.rotate_node,
	paramtype = "light",
	paramtype2 = "facedir",
	mesecons = {receptor = {state = mesecon.state.off}},
	after_place_node = function (pos, placer, itemstack, pointed_thing)
		mesecon.receptor_off(pos)
	end,
	on_rightclick = function (pos, node, player, itemstack, pointed_thing)
		minetest.set_node(pos, { name = "railroad_paraphernalia:switch_with_lamp_on_0", param2 = minetest.get_node(pos).param2 } )
		minetest.sound_play("piston_extend", {
			pos = pos,
			max_hear_distance = 20,
			gain = 0.3,
		})
		mesecon.receptor_on(pos)
	end,
})


minetest.register_node("railroad_paraphernalia:switch_with_lamp_on_0", {
	--description = 'Point lever w/lamp',
	drawtype = "mesh",
	mesh = "switch_lamp_2_on.b3d",
	tiles = { "points_lever_lamp.png" },
	selection_box = { 
				type = "fixed",
				fixed = {
						{-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},
						{-0.5, -0.5, -1.5, 0.5, 1, -0.5}
						}
				},
	walkable = false,
	groups = {snappy=1, choppy=2, oddly_breakable_by_hand=2, flammable=3, not_in_creative_inventory=1, not_blocking_trains = 1},
	on_place = minetest.rotate_node,
	paramtype = "light",
	paramtype2 = "facedir",
	mesecons = {receptor = {state = mesecon.state.on}},
	on_rightclick = function (pos, node, player, itemstack, pointed_thing)
		minetest.set_node(pos, { name = "railroad_paraphernalia:switch_with_lamp_off_0", param2 = minetest.get_node(pos).param2 } )
		minetest.sound_play("piston_retract", {
			pos = pos,
			max_hear_distance = 20,
			gain = 0.3,
		})
		mesecon.receptor_off(pos)
	end,
	drop = "railroad_paraphernalia:switch_with_lamp_off_0"
})

	
minetest.register_craft({
	output = 'railroad_paraphernalia:switch_with_lamp_off_0 3',
	recipe = {
		{'dye:grey', 'dye:yellow', 'dye:white'},
		{'', 'default:stick', 'default:stick'},
		{'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot'},
	}
})


-- POINT LEVERS WITH A RED  BALL
--[[
minetest.register_node("railroad_paraphernalia:switch_with_ball_off_0", {
	description = 'výměnové návěstidlo s terčem',
	drawtype = "mesh",
	mesh = "switch_ball_off.b3d",
	tiles = { "switch_ball_off.png" },
	selection_box = { type = "fixed",
				 fixed = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}}
				 },
	collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	groups = {snappy=1, choppy=2, oddly_breakable_by_hand=2, flammable=3},
	on_place = minetest.rotate_node,
	paramtype = "light",
	paramtype2 = "facedir",
	mesecons = { 
		receptor = {
			state = mesecon.state.off,
			rules = mesecon.rules.flat
			}
		},
	after_place_node = function (pos, placer, itemstack, pointed_thing)
		mesecon.receptor_off(pos, switch_get_rules(minetest.get_node(pos).param2))
	end,
	on_rightclick = function (pos, node, player, itemstack, pointed_thing)
		minetest.set_node(pos, { name = "railroad_paraphernalia:switch_with_ball_on_0", param2 = minetest.get_node(pos).param2 } )
		minetest.sound_play("piston_extend", {
			pos = pos,
			max_hear_distance = 20,
			gain = 0.3,
		})
		mesecon.receptor_on(pos)
	end
})


minetest.register_node("railroad_paraphernalia:switch_with_ball_on_0", {
	--description = 'Point lever w/ball',
	drawtype = "mesh",
	mesh = "switch_ball_on.b3d",
	tiles = { "switch_ball_on.png" },
	selection_box = { type = "fixed",
				 fixed = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}}
				 },
	collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	groups = {snappy=1, choppy=2, oddly_breakable_by_hand=2, flammable=3, not_in_creative_inventory=1},
	on_place = minetest.rotate_node,
	paramtype = "light",
	paramtype2 = "facedir",
	mesecons = { 
		receptor = {
			state = mesecon.state.off,
			rules = mesecon.rules.flat2
		}
	},
	on_rightclick = function (pos, node, player, itemstack, pointed_thing)
		minetest.set_node(pos, { name = "railroad_paraphernalia:switch_with_ball_off_0", param2 = minetest.get_node(pos).param2 } )
		minetest.sound_play("piston_retract", {
			pos = pos,
			max_hear_distance = 20,
			gain = 0.3,
		})
		mesecon.receptor_off(pos)
	end
})
]]

-- TRACK BLOCKER


minetest.register_node("railroad_paraphernalia:track_blocker_off_0", {
	description = 'blokátor tratě (zatím jen dekorativní)',
	drawtype = "mesh",
	mesh = "switch_blocker_off.b3d",
	tiles = { "track_blocker.png" },
	selection_box = { 
				type = "fixed",
				fixed = {
						{-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},
						{-0.5, -0.5, -1.5, 0.5, 1, -0.5}
						}
				},
	groups = {snappy=1, choppy=2, oddly_breakable_by_hand=2, flammable=3, not_blocking_trains = 1},
	on_place = minetest.rotate_node,
	paramtype = "light",
	paramtype2 = "facedir",
	--light_source = 3,
	mesecons = { receptor = {state = mesecon.state.off}},
	walkable = false,
	after_place_node = function (pos, placer, itemstack, pointed_thing)
		mesecon.receptor_off(pos)
	end,
	on_rightclick = function (pos, node, player, itemstack, pointed_thing)
		minetest.set_node(pos, { name = "railroad_paraphernalia:track_blocker_on_0", param2 = minetest.get_node(pos).param2 } )
		minetest.sound_play("piston_extend", {
			pos = pos,
			max_hear_distance = 20,
			gain = 0.3,
		})
		mesecon.receptor_on(pos)
	end,
})

minetest.register_node("railroad_paraphernalia:track_blocker_on_0", {
	--description = 'Track Blocker',
	drawtype = "mesh",
	mesh = "switch_blocker_on.b3d",
	tiles = { "track_blocker.png" },
	selection_box = { 
				type = "fixed",
				fixed = {
						{-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},
						{-0.5, -0.5, -1.5, 0.5, 1, -0.5}
						}
				},
	groups = {snappy=1, choppy=2, oddly_breakable_by_hand=2, flammable=3, not_in_creative_inventory=1},
	on_place = minetest.rotate_node,
	paramtype = "light",
	paramtype2 = "facedir",
	--light_source = 3,
	mesecons = { receptor = {
		state = mesecon.state.on,
	}},
	walkable = true,
	on_rightclick = function (pos, node, player, itemstack, pointed_thing)
		minetest.set_node(pos, { name = "railroad_paraphernalia:track_blocker_off_0", param2 = minetest.get_node(pos).param2 } )
		minetest.sound_play("piston_retract", {
			pos = pos,
			max_hear_distance = 20,
			gain = 0.3,
		})
		mesecon.receptor_off(pos)
	end,
	drop = "railroad_paraphernalia:track_blocker_off_0"
})
	
minetest.register_craft({
	output = 'railroad_paraphernalia:track_blocker 2',
	recipe = {
		{'dye:white', 'dye:black', 'dye:white'},
		{'', 'default:stick', ''},
		{'dye:red', 'default:steel_ingot', 'default:steel_ingot'},
	}
})
	
-- -------------------------


minetest.register_node("railroad_paraphernalia:shunting_signal_off_0", {
	description = "posunové návěstidlo (zatím jen dekorativní)",
	drawtype = "mesh",
	mesh = "shunting_signal.b3d",
	tiles = { "shunting_signal_blue.png" },
	selection_box = { type = "fixed",
				 fixed = {{-0.33, -0.5, -0.33, 0.33, 0.4, 0.33}}
				 },
	collisionbox = {-0.33, -0.5, -0.33, 0.33, 0.4, 0.33},
	groups = {snappy=1, choppy=2, oddly_breakable_by_hand=2, flammable=3, not_blocking_trains = 1},
	on_place = minetest.rotate_node,
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 1,
	mesecons = {
		effector = {
			action_on = function (pos, node)
					minetest.swap_node(pos, {name = "railroad_paraphernalia:shunting_signal_on_0", param2 = node.param2}, true)
				end
		}
	},
	on_rightclick = function (pos, node, player, itemstack, pointed_thing)
		minetest.set_node(pos, { name = "railroad_paraphernalia:shunting_signal_on_0", param2 = minetest.get_node(pos).param2 } )
		minetest.sound_play("piston_extend", {
			pos = pos,
			max_hear_distance = 20,
			gain = 0.3,
		})
	end,
	luaautomation = {
		getstate = "off",
		setstate = function(pos, node, newstate)
			if newstate == "on" then
				advtrains.ndb.swap_node(pos, {name = "railroad_paraphernalia:shunting_signal_on_0", param2 = node.param2}, true)
			end
		end,
	},
})


minetest.register_node("railroad_paraphernalia:shunting_signal_on_0", {
	--description = "Shunting signal",
	drawtype = "mesh",
	mesh = "shunting_signal.b3d",
	tiles = { "shunting_signal_white.png" },
	selection_box = { type = "fixed",
				 fixed = {{-0.33, -0.5, -0.33, 0.33, 0.4, 0.33}}
				 },
	collisionbox = {-0.33, -0.5, -0.33, 0.33, 0.4, 0.33},
	groups = {snappy=1, choppy=2, oddly_breakable_by_hand=2, flammable=3, not_in_creative_inventory=1, not_blocking_trains = 1},
	on_place = minetest.rotate_node,
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 1,
	mesecons = {
            effector = {
				action_off = function (pos, node)
					minetest.swap_node(pos, {name = "railroad_paraphernalia:shunting_signal_off_0", param2 = node.param2})
				end
			}
	},
	on_rightclick = function (pos, node, player, itemstack, pointed_thing)
		minetest.set_node(pos, { name = "railroad_paraphernalia:shunting_signal_off_0", param2 = minetest.get_node(pos).param2 } )
		minetest.sound_play("piston_extend", {
			pos = pos,
			max_hear_distance = 20,
			gain = 0.3,
		})
	end,
	luaautomation = {
		getstate = "on",
		setstate = function(pos, node, newstate)
			if newstate == "off" then
				advtrains.ndb.swap_node(pos, {name = "railroad_paraphernalia:shunting_signal_off_0", param2 = node.param2}, true)
			end
		end,
	},
	drop = "railroad_paraphernalia:shunting_signal_off_0"
})


minetest.register_craft({
	output = 'railroad_paraphernalia:shunting_signal_off_0',
	recipe = {
		{'', 'dye:white', ''},
		{'', 'dye:blue', ''},
		{'', 'default:stone', ''},
	}
})

-- MISC ---------------------

minetest.register_node("railroad_paraphernalia:limit_post", {
	description = "železniční oddělovací sloupek (jen dekorativní)",
	drawtype = "mesh",
	mesh = "limit_post.b3d",
	tiles = { "limit_post.png" },
	selection_box = { type = "fixed", fixed = {{-0.33, -0.5, -0.33, 0.33, 0.4, 0.33}}},
	collisionbox = {-0.33, -0.5, -0.33, 0.33, 0.4, 0.33},
	groups = {snappy=1, choppy=2, oddly_breakable_by_hand=2, flammable=3},
	on_place = minetest.rotate_node,
	paramtype = "light",
	paramtype2 = "facedir"
})

minetest.register_craft({
	output = 'railroad_paraphernalia:limit_post',
	recipe = {
		{'', 'dye:black', ''},
		{'', 'dye:white', ''},
		{'', 'default:stone', ''},
	}
})

----

ch_base.close_mod(minetest.get_current_modname())
