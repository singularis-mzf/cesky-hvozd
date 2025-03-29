ch_base.open_mod(minetest.get_current_modname())
local S = attrans


advtrains.register_wagon("engine_industrial", {
	mesh="advtrains_engine_industrial.b3d",
	textures = {"advtrains_engine_industrial.png"},
	drives_on={default=true},
	max_speed=20,
	seats = {
		{
			name=S("Driver Stand (right)"),
			attach_offset={x=5, y=-3, z=-8},
			view_offset={x=5.2, y=-4, z=0},
			driving_ctrl_access=true,
			group = "dstand",
		},
		{
			name=S("Driver Stand (left)"),
			attach_offset={x=5, y=7, z=-8},
			view_offset={x=-5.2, y=-4, z=0},
			driving_ctrl_access=true,
			group = "dstand",
		},
	},
	seat_groups = {
		dstand={
			name = S("Driver Stand"),
			access_to = {},
			driving_ctrl_access = true,
		},
	},
	assign_to_seat_group = {"dstand"},
	coupler_types_front = {chain=true},
	coupler_types_back = {chain=true},
	visual_size = {x=1, y=1},
	wagon_span=2.6,
	light_level = 10,
	is_locomotive=true,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock 5", "advtrains:driver_cab", "advtrains:wheel"},
	horn_sound = "advtrains_industrial_horn",
}, S("Industrial Train Engine"), "advtrains_engine_industrial_inv.png")

--[[
--big--
advtrains.register_wagon("engine_industrial_big", {
	mesh="advtrains_engine_industrial_big.b3d",
	textures = {"advtrains_engine_industrial_big.png"},
	drives_on={default=true},
	max_speed=30,
	seats = {
		{
			name=S("Driver Stand (right)"),
			attach_offset={x=5, y=-3, z=20},
			view_offset={x=5.2, y=-4, z=11},
			driving_ctrl_access=true,
			group = "dstand",
		},
		{
			name=S("Driver Stand (left)"),
			attach_offset={x=5, y=-3, z=-8},
			view_offset={x=-5.2, y=-4, z=0},
			driving_ctrl_access=true,
			group = "dstand",
		},
	},
	seat_groups = {
		dstand={
			name = S("Driver Stand"),
			access_to = {},
			driving_ctrl_access = true,
		},
	},
	assign_to_seat_group = {"dstand"},
	coupler_types_front = {chain=true},
	coupler_types_back = {chain=true},
	visual_size = {x=1, y=1},
	wagon_span=4,
	is_locomotive=true,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock 4"},
	horn_sound = "advtrains_industrial_horn",
}, S("Big Industrial Train Engine"), "advtrains_engine_industrial_inv.png")
]]
advtrains.register_wagon("wagon_tank", {
	mesh="advtrains_wagon_tank.b3d",
	textures = {"advtrains_wagon_tank.png"},
	seats = {},
	drives_on={default=true},
	max_speed=20,
	coupler_types_front = {chain=true},
	coupler_types_back = {chain=true},
	visual_size = {x=1, y=1},
	wagon_span=2.2,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock 5", "default:steel_ingot", "advtrains:wheel 2"},
	has_inventory = true,
	get_inventory_formspec = advtrains.standard_inventory_formspec,
	inventory_list_sizes = {
		box=8*3,
	},
}, S("Industrial tank wagon"), "advtrains_wagon_tank_inv.png")

--[[
advtrains.register_wagon("wagon_wood", {
	mesh="advtrains_wagon_wood.b3d",
	textures = {"advtrains_wagon_wood.png"},
	seats = {},
	drives_on={default=true},
	max_speed=20,
	coupler_types_front = {chain=true},
	coupler_types_back = {chain=true},
	visual_size = {x=1, y=1},
	wagon_span=1.8,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock 4"},
	has_inventory = true,
	get_inventory_formspec = advtrains.standard_inventory_formspec,
	inventory_list_sizes = {
		box=8*3,
	},
}, S("Industrial wood wagon"), "advtrains_wagon_wood_inv.png")
]]

-- Craftings

minetest.register_craft({
	output = 'advtrains:engine_industrial',
	recipe = {
		{'default:steelblock', 'default:steelblock', 'default:steelblock'},
		{'advtrains:driver_cab', 'default:steelblock', 'default:steelblock'},
		{'advtrains:wheel', '', 'advtrains:wheel'},
	},
})

--[[Engine Industrial Big
minetest.register_craft({
	output = 'advtrains:engine_industrial_big',
	recipe = {
		{'default:glass', 'default:steelblock', 'default:steelblock'},
		{'advtrains:driver_cab', 'default:steelblock', 'default:steelblock'},
		{'advtrains:wheel', 'advtrains:wheel', 'advtrains:wheel'},
	},
})
]]

--Industrial tank wagon
minetest.register_craft({
	output = 'advtrains:wagon_tank',
	recipe = {
		{'default:steelblock', 'default:steel_ingot', 'default:steelblock'},
		{'default:steelblock', '', 'default:steelblock'},
		{'advtrains:wheel', 'default:steelblock', 'advtrains:wheel'},
	},
})

--[[
--Industrial wood wagon
minetest.register_craft({
	output = 'advtrains:wagon_wood',
	recipe = {
		{'default:steel_ingot', '', 'default:steel_ingot'},
		{'default:steelblock', 'default:steelblock', 'default:steelblock'},
		{'advtrains:wheel', '', 'advtrains:wheel'},
	},
})
]]
ch_base.close_mod(minetest.get_current_modname())
