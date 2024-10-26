local sounds = {}

local function on_construct(pos)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	local ndef = minetest.registered_nodes[node.name]
	if ndef ~= nil then
		meta:set_string("infotext", ndef.description)
	end
end

minetest.register_node("handdryer:a",{
	description = "vysoušeč rukou",
	groups = {cracky=3},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3, -0.25, 0.204, 0.3, 0.25, 0.5}, --Body
			{-0.202, -0.094, 0.1, -0.077, 0.1085, 0.204}, --Outlet
			{0.125, -0.045, 0.15, 0.22, 0.045, 0.204}, --Button
		},
	},
	tiles = {
		"handdryer_a_xa5_sides.png",
		"handdryer_a_xa5_bottom.png^[transformFY",
		"handdryer_a_xa5_sides.png^[transformR270",
		"handdryer_a_xa5_sides.png^[transformR90",
		"handdryer_metal.png",
		"handdryer_a_front.png",
	},
	on_construct = on_construct,
	on_rightclick = function(pos)
		local hash = minetest.hash_node_position(pos)
		local handle = sounds[hash]
		if handle then
			minetest.sound_stop(handle)
		end
		sounds[hash] = minetest.sound_play("handdryer_a_ra_run",{pos=pos,gain=0.75,max_hear_distance=20})
	end,
})

minetest.register_node("handdryer:ra",{
	description = "vestavěný vysoušeč rukou",
	groups = {cracky=3},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3, -0.45, 0.45, 0.3, 0.25, 0.5}, --Body
			{-0.202, -0.094, 0.35, -0.077, 0.1085, 0.45}, --Outlet
			{0.125, -0.045, 0.4, 0.22, 0.045, 0.45}, --Button
		},
	},
	tiles = {
		"handdryer_a_xa5_sides.png",
		"handdryer_a_xa5_bottom.png^[transformFY",
		"handdryer_a_xa5_sides.png^[transformR270",
		"handdryer_a_xa5_sides.png^[transformR90",
		"handdryer_metal.png",
		"handdryer_ra_front.png",
	},
	on_construct = on_construct,
	on_rightclick = function(pos)
		local hash = minetest.hash_node_position(pos)
		local handle = sounds[hash]
		if handle then
			minetest.sound_stop(handle)
		end
		sounds[hash] = minetest.sound_play("handdryer_a_ra_run",{pos=pos,gain=0.75,max_hear_distance=20})
	end,
})

minetest.register_node("handdryer:xa5",{
	description = "automatický vysoušeč rukou",
	groups = {cracky=3},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3, -0.25, 0.204, 0.3, 0.25, 0.5}, --Body
			{-0.202, -0.094, 0.1, -0.077, 0.1085, 0.204}, --Outlet
		},
	},
	on_construct = on_construct,
	tiles = {
		"handdryer_a_xa5_sides.png",
		"handdryer_a_xa5_bottom.png^[transformFY",
		"handdryer_a_xa5_sides.png^[transformR270",
		"handdryer_a_xa5_sides.png^[transformR90",
		"handdryer_metal.png",
		"handdryer_xa5_front.png",
	},
})

minetest.register_abm({
	label = "Automatic hand dryers",
	interval = 1,
	chance = 1,
	nodenames = {"handdryer:xa5"},
	action = function(pos)
		local posbelow = vector.add(pos,vector.new(0,-1,0))
		local player = next(ch_core.get_active_objects_inside_radius("player", posbelow, 1)) ~= nil
		local hash = minetest.hash_node_position(pos)
		local handle = sounds[hash]
		local meta = minetest.get_meta(pos)
		if player then
			if meta:get_int("running") == 0 then
				if handle then minetest.sound_stop(handle) end
				meta:set_int("running",1)
				minetest.sound_play("handdryer_xa5_start",{pos=pos,gain=0.75,max_hear_distance=20})
				minetest.after(2,function(pos,hash)
					local meta = minetest.get_meta(pos)
					if not meta:get_int("running") == 1 then return end
					sounds[hash] = minetest.sound_play("handdryer_xa5_run",{pos=pos,gain=0.75,max_hear_distance=20,loop=true})
				end,pos,hash)
			end
		else
			if handle then minetest.sound_stop(handle) end
			if meta:get_int("running") == 1 then
				meta:set_int("running",0)
				minetest.sound_play("handdryer_xa5_stop",{pos=pos,gain=0.75,max_hear_distance=20})
			end
		end
	end,
})

minetest.register_craft({
	output = "handdryer:a",
	recipe = {
		{"default:steel_ingot","default:steel_ingot","mesecons_button:button_off"},
		{"default:steel_ingot","homedecor:fan_blades","homedecor:motor"},
		{"default:steel_ingot","homedecor:heating_element","default:steel_ingot"},
	},
})

minetest.register_craft({
	output = "handdryer:ra",
	recipe = {
		{"default:steel_ingot","default:steel_ingot","mesecons_button:button_off"},
		{"homedecor:motor","homedecor:fan_blades","default:steel_ingot"},
		{"default:steel_ingot","homedecor:heating_element","default:steel_ingot"},
	},
})

minetest.register_craft({
	output = "handdryer:xa5",
	recipe = {
		{"default:steel_ingot","default:steel_ingot","homedecor:ic"},
		{"default:steel_ingot","homedecor:fan_blades","homedecor:motor"},
		{"default:steel_ingot","homedecor:heating_element","mesecons_solarpanel:solar_panel_off"},
	},
})
