local S
if minetest.get_modpath("intllib") then
    S = intllib.Getter()
else
    S = function(s,a,...)a={a,...}return s:gsub("@(%d+)",function(n)return a[tonumber(n)]end)end
end

local bed = 'wool:white'
if  minetest.get_modpath("beds") then
	bed = 'beds:bed'
end

local door = 'default:steel_ingot'
if minetest.get_modpath("doors") then
	door = 'doors:door_steel'
end

advtrains.register_wagon("moretrains_nightline_couchette", {
	mesh="moretrains_nightline_couchette.b3d",
	textures = {"moretrains_nightline_couchette.png"},
	drives_on={default=true},
	max_speed=20,
	seats = {
		{
			name="1",
			attach_offset={x=0, y=-2, z=17},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="2",
			attach_offset={x=0, y=-2, z=6},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="3",
			attach_offset={x=0, y=-2, z=-6},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="4",
			attach_offset={x=0, y=-2, z=-17},
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
			[-1]={frames={x=21, y=30}, time=1},
			[1]={frames={x=1, y=10}, time=1}
		},
		close={
			[-1]={frames={x=30, y=41}, time=1},
			[1]={frames={x=10, y=20}, time=1}
		}
	},
	door_entry={-2, 2},
	assign_to_seat_group = {"pass"},
	visual_size = {x=1, y=1},
	wagon_span=3,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock"},
}, S("Night Line Couchette Wagon"), "moretrains_nightline_couchette_inv.png")

minetest.register_craft({
	output = 'advtrains:moretrains_nightline_couchette',
	recipe = {
		{'default:steelblock', 'dye:blue', 'default:steelblock'},
		{'default:glass', bed, door},
		{'advtrains:wheel', 'default:steelblock', 'advtrains:wheel'},
	},
})

advtrains.register_wagon("moretrains_nightline_seat_car", {
	mesh="moretrains_nightline_seat_car.b3d",
	textures = {"moretrains_nightline_seat_car.png"},
	drives_on={default=true},
	max_speed=20,
	seats = {
		{
			name="1",
			attach_offset={x=0, y=-2, z=17},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="2",
			attach_offset={x=0, y=-2, z=6},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="3",
			attach_offset={x=0, y=-2, z=-6},
			view_offset={x=0, y=-2, z=0},
			group="pass",
		},
		{
			name="4",
			attach_offset={x=0, y=-2, z=-17},
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
			[-1]={frames={x=21, y=30}, time=1},
			[1]={frames={x=1, y=10}, time=1}
		},
		close={
			[-1]={frames={x=30, y=41}, time=1},
			[1]={frames={x=10, y=20}, time=1}
		}
	},
	door_entry={-2, 2},
	assign_to_seat_group = {"pass"},
	visual_size = {x=1, y=1},
	wagon_span=3,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock"},
}, S("Night Line Seat Wagon"), "moretrains_nightline_seat_car_inv.png")

minetest.register_craft({
	output = 'advtrains:moretrains_nightline_seat_car',
	recipe = {
		{'default:steelblock', 'dye:blue', 'default:steelblock'},
		{'default:glass', 'wool:blue', door},
		{'advtrains:wheel', 'default:steelblock', 'advtrains:wheel'},
	},
})


