local S
if minetest.get_modpath("intllib") then
    S = intllib.Getter()
else
    S = function(s,a,...)a={a,...}return s:gsub("@(%d+)",function(n)return a[tonumber(n)]end)end
end


advtrains.register_wagon("engine_zugspitzbahn", {
	mesh="advtrains_engine_bzb.b3d",
	textures = {"advtrains_engine_bzb.png"},
	drives_on={default=true},
	max_speed=15,
	seats = {
        {
			name=S("Driver Stand (front)"),
            attach_offset={x=0, y=6, z=8},
			view_offset={x=0, y=-3, z=0},
			group = "dstand",
		},
		{
			name=S("Driver Stand (back)"),
			  attach_offset={x=0, y=-6, z=8},
			view_offset={x=0, y=-3, z=0},
			group = "dstand",
		},
	},
	seat_groups = {
		dstand={
			name = "Driver Stand",
			access_to = {},
			driving_ctrl_access=true,
		},
	},
    assign_to_seat_group = {"dstand"},
	wagon_span=2.7,
    visual_size = {x=1, y=1},
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	is_locomotive=true,
	drops={"advtrains:engine_zugspitzbahn"},
	
}, S("Zugspitzbahn engine"), "advtrains_engine_bzb_inv.png")

advtrains.register_wagon("wagon_zugspitzbahn", {
	mesh="advtrains_wagon_bzb.b3d",
	textures = {"advtrains_bzb.png"},
	drives_on={default=true},
	max_speed=10,
	seats = {
		{
			name="1",
			attach_offset={x=2, y=6, z=8},
			view_offset={x=0, y=-4, z=0},
			group="pass",
		},
		{
			name="2",
			attach_offset={x=-1, y=6, z=8},
			view_offset={x=0, y=-4, z=0},
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
		pass={
			name = "Passenger area",
			access_to = {},
		},
	},
	assign_to_seat_group = {"pass"},
	visual_size = {x=1, y=1},
	wagon_span=3,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={"default:steelblock 4"},
}, S("Passenger Zugspitzbahn wagon"), "advtrains_wagon_bzb_inv.png") 
