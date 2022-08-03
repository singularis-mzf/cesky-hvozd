local S
if minetest.get_modpath("intllib") then
    S = intllib.Getter()
else
    S = function(s,a,...)a={a,...}return s:gsub("@(%d+)",function(n)return a[tonumber(n)]end)end
end


advtrains.register_wagon("moretrains_railroad_car", {
	mesh="moretrains_railroad_car.b3d",
	textures = {"moretrains_railroad_car.png"},
	drives_on={default=true},
	max_speed=20,
	seats = {
		{
			name="1",
			attach_offset={x=-4, y=-2, z=8},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="2",
			attach_offset={x=4, y=-2, z=8},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="1a",
			attach_offset={x=-4, y=-2, z=0},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="2a",
			attach_offset={x=4, y=-2, z=0},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="3",
			attach_offset={x=-4, y=-2, z=-8},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="4",
			attach_offset={x=4, y=8, z=-8},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
	},
	seat_groups = {
		pass={
			name = "Passenger area",
			access_to = {},
			require_doors_open=true,
		},
	},
	doors={
		open={
			[-1]={frames={x=0, y=10}, time=1},
			[1]={frames={x=20, y=30}, time=1}
		},
		close={
			[-1]={frames={x=10, y=20}, time=1},
			[1]={frames={x=30, y=40}, time=1}
		}
	},
	door_entry={-1.7},
	assign_to_seat_group = {"pass"},
	visual_size = {x=1, y=1},
	wagon_span=2.94,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock"},
}, S("Railroad Car"), "moretrains_railroad_car_inv.png")

advtrains.register_wagon("moretrains_silberling", {
	mesh="moretrains_silberling.b3d",
	textures = {"moretrains_silberling.png"},
	drives_on={default=true},
	max_speed=20,
	seats = {
		{
			name="1",
			attach_offset={x=-4, y=-2, z=8},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="2",
			attach_offset={x=4, y=-2, z=8},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="1a",
			attach_offset={x=-4, y=-2, z=0},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="2a",
			attach_offset={x=4, y=-2, z=0},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="3",
			attach_offset={x=-4, y=-2, z=-8},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="4",
			attach_offset={x=4, y=8, z=-8},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
	},
	seat_groups = {
		pass={
			name = "Passenger area",
			access_to = {},
			require_doors_open=true,
		},
	},
	doors={
		open={
			[-1]={frames={x=20, y=30}, time=1},
			[1]={frames={x=0, y=10}, time=1}
		},
		close={
			[-1]={frames={x=30, y=40}, time=1},
			[1]={frames={x=10, y=20}, time=1}
		}
	},
	door_entry={-1.7},
	assign_to_seat_group = {"pass"},
	visual_size = {x=1, y=1},
	wagon_span=3,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock"},
}, S("MT Silberling Wagon"), "moretrains_silberling_inv.png")

advtrains.register_wagon("moretrains_silberling_dining", {
	mesh="moretrains_silberling_dining.b3d",
	textures = {"moretrains_silberling_dining.png"},
	drives_on={default=true},
	max_speed=20,
	seats = {
		{
			name="1L",
			attach_offset={x=-3.4, y=-2, z=18},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="1R",
			attach_offset={x=3.4, y=-2, z=18},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="2R",
			attach_offset={x=3.4, y=-2, z=8},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="3L",
			attach_offset={x=-3.4, y=-2, z=-4},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="3R",
			attach_offset={x=3.4, y=-2, z=-3},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="4L",
			attach_offset={x=-3.4, y=-2, z=-14},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
	},
	seat_groups = {
		pass={
			name = "Passenger area",
			access_to = {},
			require_doors_open=true,
		},
	},
	doors={
		open={
			[-1]={frames={x=20, y=30}, time=1},
			[1]={frames={x=0, y=10}, time=1}
		},
		close={
			[-1]={frames={x=30, y=40}, time=1},
			[1]={frames={x=10, y=20}, time=1}
		}
	},
	door_entry={-1.7},
	assign_to_seat_group = {"pass"},
	visual_size = {x=1, y=1},
	wagon_span=3,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock"},
}, S("MT Silberling Dining Wagon"), "moretrains_silberling_dining_inv.png")

advtrains.register_wagon("moretrains_diesel_german", {
	mesh="moretrains_diesel_german.b3d",
	textures = {"moretrains_diesel_german.png"},
	drives_on={default=true},
	max_speed=20,
	seats = {
		{
			name=S("Driver Stand (right)"),
			attach_offset={x=1, y=1.4, z=-7.2},
			view_offset={x=2, y=3.1, z=-8},
			driving_ctrl_access=true,
			group = "dstand",
		},
		
	},
	seat_groups = {
		dstand={
			name = "Driver Stand",
			access_to = {},
			driving_ctrl_access = true,
		},
	},
	assign_to_seat_group = {"dstand"},
	visual_size = {x=1, y=1},
	wagon_span=2.8,
	is_locomotive=true,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock 4"},
	horn_sound = "advtrains_industrial_horn",
}, S("Old German Diesel"), "moretrains_diesel_german_inv.png")

advtrains.register_wagon("moretrains_silberling_train", {
	mesh="moretrains_silberling_train.b3d",
	textures = {"moretrains_silberling_train.png"},
	drives_on={default=true},
	max_speed=20,
	seats = {
		{
			name=S("Driver stand"),
			attach_offset={x=0, y=-0.4, z=21},
			view_offset={x=10.4, y=9, z=0},
			group="dstand",
		},
		{
			name="1",
			attach_offset={x=-4, y=-2, z=8},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="2",
			attach_offset={x=4, y=-2, z=8},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="1a",
			attach_offset={x=-4, y=-2, z=0},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="2a",
			attach_offset={x=4, y=-2, z=0},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="3",
			attach_offset={x=-4, y=-2, z=-8},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="4",
			attach_offset={x=4, y=8, z=-8},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
	},
	seat_groups = {
		dstand={
			name = "Driver Stand",
			access_to = {"pass"},
			driving_ctrl_access=true,
		},
		pass={
			name = "Passenger area",
			access_to = {"dstand"},
			require_doors_open=true,
		},
	},
	assign_to_seat_group = {"dstand", "pass"},
	doors={
		open={
			[-1]={frames={x=0, y=10}, time=1},
			[1]={frames={x=20, y=30}, time=1}
		},
		close={
			[-1]={frames={x=10, y=20}, time=1},
			[1]={frames={x=30, y=40}, time=1}
		}
	},
	visual_size = {x=1, y=1},
	wagon_span=3,
	is_locomotive=false,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock 4"},
	horn_sound = "advtrains_industrial_horn",
}, S("MT Silberling Cab Car"), "moretrains_silberling_train_inv.png")


minetest.register_craft({
	output = 'advtrains:moretrains_diesel_german',
	recipe = {
		{'default:glass', 'dye:red', ''},
		{'default:steelblock', 'advtrains:driver_cab', 'default:steelblock'},
		{'advtrains:wheel', 'advtrains:wheel', 'advtrains:wheel'},
	},
})

local block = 'default:steelblock'
local ingot = 'default:steel_ingot'
if  minetest.get_modpath("moreores") then
	block = 'moreores:silver_block'
	ingot = 'moreores:silver_ingot'
	
end

minetest.register_craft({
	output = 'advtrains:moretrains_silberling',
	recipe = {
		{'default:steelblock', block, 'default:steelblock'},
		{ingot, 'default:glass', ingot},
		{'advtrains:wheel', '', 'advtrains:wheel'},
	},
})

minetest.register_craft({
	output = 'advtrains:moretrains_silberling_dining',
	recipe = {
		{'default:steelblock', block, 'default:steelblock'},
		{ingot, 'default:furnace', ingot},
		{'advtrains:wheel', '', 'advtrains:wheel'},
	},
})

minetest.register_craft({
	output = 'advtrains:moretrains_silberling_train',
	recipe = {
		{'default:steelblock', block, 'default:steelblock'},
		{block, 'default:glass', ingot},
		{'advtrains:wheel', 'advtrains:wheel', 'advtrains:wheel'},
	},
})

minetest.register_craft({
	output = 'advtrains:moretrains_railroad_car',
	recipe = {
		{'default:steelblock', 'default:tin_ingot', 'default:steelblock'},
		{'default:steelblock', 'default:glass', 'default:steelblock'},
		{'advtrains:wheel', '', 'advtrains:wheel'},
	},
})
