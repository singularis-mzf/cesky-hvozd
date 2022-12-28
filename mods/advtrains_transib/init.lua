local S = attrans

advtrains.register_wagon("engine_transib", {
	mesh="advtrains_engine_transib.b3d",
	textures = {"advtrains_engine_transib.png"},
	backface_culling = false,
	drives_on={default=true},
	max_speed=20,
	seats = {
		{
			name=S("Driver stand"),
			attach_offset={x=0, y=8, z=13},
			view_offset={x=0, y=0, z=0},
			driving_ctrl_access=true,
			group="dstand",
		},
		{
			name="1",
			attach_offset={x=-4, y=8, z=0},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="2",
			attach_offset={x=4, y=8, z=0},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="3",
			attach_offset={x=-4, y=8, z=-8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="4",
			attach_offset={x=4, y=8, z=-8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
	},
	seat_groups = {
		dstand={
			name = S("Driver Stand"),
			access_to = {"pass"},
			require_doors_open=true,
		},
		pass={
			name = S("Passenger area"),
			access_to = {"dstand"},
			require_doors_open=true,
		},
	},
	assign_to_seat_group = {"dstand", "pass"},
	doors={
		open={
			[-1]={frames={x=0, y=20}, time=1},
			[1]={frames={x=40, y=60}, time=1}
		},
		close={
			[-1]={frames={x=20, y=40}, time=1},
			[1]={frames={x=60, y=80}, time=1}
		}
	},
	door_entry={-1},
	visual_size = {x=1, y=1},
	wagon_span=3.4,
	is_locomotive=true,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={
		"wool:blue 2",
		"advtrains:driver_cab",
		"default:steelblock 2",
		"basic_materials:motor",
		"advtrains:wheel 3",
	},
}, S("transib"), "advtrains_engine_transib_inv.png")

advtrains.register_wagon("wagon_coal", {
	mesh="advtrains_wagon_coal.b3d",
	textures = {"advtrains_wagon_coal.png"},
	drives_on={default=true},
	max_speed=10,
	seats = {},
	visual_size = {x=1, y=1},
	wagon_span=2.2,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={
		"default:steelblock 5",
		"dye:brown",
		"advtrains:wheel 2",
	},
	has_inventory = true,
	get_inventory_formspec = advtrains.standard_inventory_formspec,
	inventory_list_sizes = {
		box=8*6,
	},
}, S("Coal Wagon(for transib)"), "advtrains_wagon_coal_inv.png")

minetest.register_craft({
	output = "advtrains:engine_transib",
	recipe = {
		{"wool:blue", "advtrains:driver_cab", "wool:blue"},
		{"default:steelblock", "basic_materials:motor", "default:steelblock"},
		{"advtrains:wheel", "advtrains:wheel", "advtrains:wheel"},
	},
})


minetest.register_craft({
	output = "advtrains:wagon_coal",
	recipe = {
		{"default:steelblock", "dye:brown", "default:steelblock"},
		{"default:steelblock", "", "default:steelblock"},
		{"advtrains:wheel", "default:steelblock", "advtrains:wheel"},
	},
})


