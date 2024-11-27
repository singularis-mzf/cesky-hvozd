ch_base.open_mod(minetest.get_current_modname())
local S = attrans

advtrains.register_wagon("engine_BBOE_1080", {
	mesh="advtrains_engine_BBOE_1080.b3d",
	textures = {"advtrains_engine_BBOE_1080.png"},
	drives_on={default=true},
	max_speed=20,
	seats = {
		{
			name=S("Driver stand"),
			attach_offset={x=0, y=8, z=13},
			view_offset={x=0, y=0, z=0},
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
			driving_ctrl_access = true
		},
		pass={
			name = S("Crew Seats"),
			access_to = {"dstand"},
			require_doors_open=true,
		},
	},
	assign_to_seat_group = {"dstand"},
	doors={
		open={
			[-1]={frames={x=0, y= 20}, time=1},
			[1]={frames={x=40, y=60}, time=1}
		},
		close={
			[-1]={frames={x=20, y=40}, time=1},
			[1]={frames={x=60, y=80}, time=1}
		}
	},
	door_entry={-1},
	visual_size = {x=1, y=1},
	wagon_span=3.0,
	is_locomotive=true,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={
		"dye:green",
		"basic_materials:steel_bar",
		"default:steelblock 2",
		"advtrains:driver_cab",
		"advtrains:wheel 5",
		"basic_materials:motor 3",
		"dye:blue", -- only because of the crafting recipe
	},
}, S("BBÖ 1080"), "advtrains_engine_BBOE_1080_inv.png")

advtrains.register_wagon("wagon_ware", {
	mesh="advtrains_wagon_BBOE_ware.b3d",
	textures = {"advtrains_wagon_BBOE_ware.png"},
	drives_on={default=true},
	max_speed=10,
	seats = {},
	visual_size = {x=1, y=1},
	wagon_span=2.8,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={
		"moreblocks:slab_steelblock 3",
		"advtrains:wheel 2",
	},
	has_inventory = true,
	get_inventory_formspec = advtrains.standard_inventory_formspec,
	inventory_list_sizes = {
		box=8*2,
	},
}, S("Ware Wagon (BBÖ)"), "advtrains_wagon_BBOE_ware_inv.png")

minetest.register_craft({
	output = "advtrains:engine_BBOE_1080",
	recipe = {
		{"", "dye:green", ""},
		{"basic_materials:motor", "basic_materials:motor", "basic_materials:motor"},
		{"advtrains:wheel", "advtrains:engine_zugspitzbahn", "advtrains:wheel"},
	},
})

minetest.register_craft({
	output = "advtrains:wagon_ware",
	recipe = {
		{"", "", ""},
		{"moreblocks:slab_steelblock", "moreblocks:slab_steelblock", "moreblocks:slab_steelblock"},
		{"advtrains:wheel", "", "advtrains:wheel"},
	},
})
ch_base.close_mod(minetest.get_current_modname())
