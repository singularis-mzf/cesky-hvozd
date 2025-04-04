ch_base.open_mod(minetest.get_current_modname())
local S = attrans

local driver_stand = S("Driver stand")
local passenger_area = S("Passenger area")

local function jr_set_livery(self, puncher, itemstack,data)
		-- Get color data
	local meta = itemstack:get_meta()
	local color = meta:get_string("paint_color")
	local alpha = tonumber(meta:get_string("alpha"))
	if color and color:find("^#%x%x%x%x%x%x$") then
		data.livery = self.base_texture.."^("..self.base_livery.."^[colorize:"..color..":255)" -- livery texture has no own texture....
		self:set_textures(data)
	end
end

local function	jr_set_textures(self, data)
	if data.livery then
		self.object:set_properties({
				textures={data.livery}
		})
	end
end

advtrains.register_wagon("KuHa_E231", {
	mesh="advtrains_KuHa_E231.b3d",
	textures = {"advtrains_KuHa_E231.png"},
	drives_on={default=true},
	max_speed=20,
	seats = {
		{
			name=S("Driver stand"),
			attach_offset={x=0, y=-2, z=18},
			view_offset={x=0, y=0, z=0},
			driving_ctrl_access=true,
			group="dstand",
		},
		{
			name="1",
			attach_offset={x=-4, y=-2, z=0},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="2",
			attach_offset={x=4, y=-2, z=0},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="3",
			attach_offset={x=-4, y=-2, z=-8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="4",
			attach_offset={x=4, y=-2, z=-8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
	},
	seat_groups = {
		dstand={
			name = driver_stand,
			access_to = {"pass"},
			require_doors_open=true,
			driving_ctrl_access=true,
		},
		pass={
			name = passenger_area,
			access_to = {"dstand"},
			require_doors_open=true,
		},
	},
	assign_to_seat_group = {"dstand", "pass"},
	doors={
		open={
			[-1]={frames={x=0, y=40}, time=1},
			[1]={frames={x=80, y=120}, time=1},
			sound = "advtrains_train_jre231_door_chime",
		},
		close={
			[-1]={frames={x=40, y=80}, time=1},
			[1]={frames={x=120, y=160}, time=1},
			sound = "advtrains_train_jre231_door_chime",
		}
	},
	door_entry={-1},
	assign_to_seat_group = {"dstand", "pass"},
	visual_size = {x=1, y=1},
	wagon_span=2.5,
	light_level = 10,
	is_locomotive=true,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={
		"default:steelblock 4",
		"advtrains:dtrack_atc_placer",
		"building_blocks:smoothglass",
		"dlxtrains:bogie",
	},
	horn_sound = "advtrains_train_jre231_horn",
	base_texture = "advtrains_KuHa_E231.png",
	base_livery = "advtrains_KuHa_E231_livery.png",
	set_textures = jr_set_textures,
	set_livery = jr_set_livery,
                                       
	custom_on_velocity_change = function(self, velocity, old_velocity, dtime)
		if not velocity or not old_velocity then return end
		if old_velocity == 0 and velocity > 0 then
			if self.sound_arrive_handle then
				minetest.sound_stop(self.sound_arrive_handle)
				self.sound_arrive_handle = nil
			end
			self.sound_depart_handle = minetest.sound_play("advtrains_train_jre231_depart", {object = self.object})
		end
		if velocity < 2 and (old_velocity >= 2 or old_velocity == velocity) and not self.sound_arrive_handle then
			if self.sound_depart_handle then
				minetest.sound_stop(self.sound_depart_handle)
				self.sound_depart_handle = nil
			end
			self.sound_arrive_handle = minetest.sound_play("advtrains_train_jre231_arrive", {object = self.object})
		elseif (velocity > old_velocity) and self.sound_arrive_handle then
			minetest.sound_stop(self.sound_arrive_handle)
			self.sound_arrive_handle = nil
		end
	end,

}, "jednotka E231: řídicí vůz (KuHa)", "advtrains_KuHa_E231_inv.png^advtrains_jre231_inv_overlay_right.png^advtrains_jre231_inv_overlay_middle.png")

advtrains.register_wagon("MoHa_E231", {
	mesh="advtrains_MoHa_E231.b3d",
	textures = {"advtrains_MoHa_E231.png"},
	drives_on={default=true},
	max_speed=20,
	seats = {
		{
			name="1",
			attach_offset={x=-4, y=-2, z=8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="2",
			attach_offset={x=4, y=-2, z=8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="1a",
			attach_offset={x=-4, y=-2, z=0},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="2a",
			attach_offset={x=4, y=-2, z=0},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="3",
			attach_offset={x=-4, y=-2, z=-8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="4",
			attach_offset={x=4, y=-2, z=-8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
	},
	seat_groups = {
		pass={
			name = passenger_area,
			access_to = {},
			require_doors_open=true,
		},
	},
	assign_to_seat_group = {"pass"},
	doors={
		open={
			[-1]={frames={x=0, y=40}, time=1},
			[1]={frames={x=80, y=120}, time=1},
			sound = "advtrains_train_jre231_door_chime",
		},
		close={
			[-1]={frames={x=40, y=80}, time=1},
			[1]={frames={x=120, y=160}, time=1},
			sound = "advtrains_train_jre231_door_chime",
		}
	},
	door_entry={-1, 1},
	visual_size = {x=1, y=1},
	wagon_span=2.3,
	light_level = 8,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	base_texture = "advtrains_MoHa_E231.png",
	base_livery = "advtrains_MoHa_E231_livery.png",
	set_textures = jr_set_textures,
	set_livery = jr_set_livery,
	drops={
		"default:steelblock 4",
		"minitram_crafting_recipes:minitram_pantograph",
		"basic_materials:plastic_sheet",
		"dlxtrains:bogie",
	},
}, "jednotka E231: vnitřní článek E231 s pantografem (MoHa)",
"advtrains_MoHa_E231_inv.png^advtrains_jre231_inv_overlay_middle.png^advtrains_jre231_inv_overlay_left.png^advtrains_jre231_inv_overlay_right.png^advtrains_jre231_inv_overlay_top.png")

advtrains.register_wagon("SaHa_E231", {
	mesh="advtrains_SaHa_E231.b3d",
	textures = {"advtrains_SaHa_E231.png"},
	drives_on={default=true},
	max_speed=20,
	seats = {
		{
			name="1",
			attach_offset={x=-4, y=-2, z=8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="2",
			attach_offset={x=4, y=-2, z=8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="1a",
			attach_offset={x=-4, y=-2, z=0},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="2a",
			attach_offset={x=4, y=-2, z=0},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="3",
			attach_offset={x=-4, y=-2, z=-8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="4",
			attach_offset={x=4, y=-2, z=-8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
	},
	seat_groups = {
		pass={
			name = passenger_area,
			access_to = {},
			require_doors_open=true,
		},
	},
	assign_to_seat_group = {"pass"},
	doors={
		open={
			[-1]={frames={x=0, y=40}, time=1},
			[1]={frames={x=80, y=120}, time=1},
			sound = "advtrains_train_jre231_door_chime",
		},
		close={
			[-1]={frames={x=40, y=80}, time=1},
			[1]={frames={x=120, y=160}, time=1},
			sound = "advtrains_train_jre231_door_chime",
		}
	},
	door_entry={-1, 1},
	visual_size = {x=1, y=1},
	wagon_span=2.3,
	light_level = 8,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	drops={
		"default:steelblock 5",
		"basic_materials:plastic_sheet 2",
		"dlxtrains:bogie",
	},
	base_texture = "advtrains_SaHa_E231.png",
	base_livery = "advtrains_MoHa_E231_livery.png",
	set_textures = jr_set_textures,
	set_livery = jr_set_livery,
}, "jednotka E231: vnitřní článek E231 (SaHa)", "advtrains_SaHa_E231_inv.png^advtrains_jre231_inv_overlay_left.png^advtrains_jre231_inv_overlay_right.png")

advtrains.register_wagon("MoHa_E230", {
	mesh="advtrains_MoHa_E230.b3d",
	textures = {"advtrains_MoHa_E230.png"},
	drives_on={default=true},
	max_speed=20,
	seats = {
		{
			name="1",
			attach_offset={x=-4, y=-2, z=8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="2",
			attach_offset={x=4, y=-2, z=8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="1a",
			attach_offset={x=-4, y=-2, z=0},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="2a",
			attach_offset={x=4, y=-2, z=0},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="3",
			attach_offset={x=-4, y=-2, z=-8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="4",
			attach_offset={x=4, y=-2, z=-8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
	},
	seat_groups = {
		pass={
			name = passenger_area,
			access_to = {},
			require_doors_open=true,
		},
	},
	assign_to_seat_group = {"pass"},
	doors={
		open={
			[-1]={frames={x=0, y=40}, time=1},
			[1]={frames={x=80, y=120}, time=1},
			sound = "advtrains_train_jre231_door_chime",
		},
		close={
			[-1]={frames={x=40, y=80}, time=1},
			[1]={frames={x=120, y=160}, time=1},
			sound = "advtrains_train_jre231_door_chime",
		}
	},
	door_entry={-1, 1},
	visual_size = {x=1, y=1},
	wagon_span=2.3,
	light_level = 8,
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	base_texture = "advtrains_MoHa_E230.png",
	base_livery = "advtrains_MoHa_E231_livery.png",
	set_textures = jr_set_textures,
	set_livery = jr_set_livery,
	drops={
		"default:steelblock 5",
		"basic_materials:plastic_sheet 2",
		"dlxtrains:bogie",
	},
}, "jednotka E231: vnitřní článek E230 (MoHa)",
"advtrains_MoHa_E230_inv.png^advtrains_jre231_inv_overlay_middle.png^advtrains_jre231_inv_overlay_left.png^advtrains_jre231_inv_overlay_right.png")

-- Crafts:

-- řídicí vůz
core.register_craft({
	output = "advtrains:KuHa_E231",
	recipe = {
		{"default:steelblock", "default:steelblock", "default:steelblock"},
		{"", "advtrains:dtrack_atc_placer", "building_blocks:smoothglass"},
		{"default:steelblock", "dlxtrains:bogie", "default:steelblock"},
	},
})

-- vnitřní články
core.register_craft({
	output = "advtrains:MoHa_E230",
	recipe = {
		{"default:steelblock", "default:steelblock", "default:steelblock"},
		{"basic_materials:plastic_sheet", "basic_materials:plastic_sheet", ""},
		{"default:steelblock", "dlxtrains:bogie", "default:steelblock"},
	},
})
core.register_craft({
	output = "advtrains:SaHa_E231",
	recipe = {
		{"default:steelblock", "default:steelblock", "default:steelblock"},
		{"", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet"},
		{"default:steelblock", "dlxtrains:bogie", "default:steelblock"},
	},
})

-- vnitřní článek s pantografem
core.register_craft({
	output = "advtrains:MoHa_E231",
	recipe = {
		{"default:steelblock", "minitram_crafting_recipes:minitram_pantograph", "default:steelblock"},
		{"", "basic_materials:plastic_sheet", ""},
		{"default:steelblock", "dlxtrains:bogie", "default:steelblock"},
	},
})

ch_base.close_mod(minetest.get_current_modname())
