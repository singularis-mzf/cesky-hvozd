--
--BUNNY
--
local S = ...

local pet_name = "bunny"
local scale_model = 1.3
local scale_baby = 0.5
local visual_size = {x=petz.settings.visual_size.x*scale_model, y=petz.settings.visual_size.y*scale_model}
local visual_size_baby = {x=petz.settings.visual_size.x*scale_model*scale_baby, y=petz.settings.visual_size.y*scale_model*scale_baby}
local mesh = 'petz_bunny.b3d'
local skin_colors = {"brown", "gray", "black", "white", "pink"}
local textures = {}
for n = 1, #skin_colors do
	textures[n] = "petz_"..pet_name.."_"..skin_colors[n]..".png"
end
local p1 = {x= -0.25, y = -0.5, z = -0.125}
local p2 = {x= 0.25, y = -0.0625, z = 0.1875}
local collisionbox, collisionbox_baby = petz.get_collisionbox(p1, p2, scale_model, scale_baby)

minetest.register_entity("petz:"..pet_name, {
	--Petz specifics
	type = "bunny",
	init_tamagochi_timer = true,
	is_pet = true,
	has_affinity = true,
	is_wild = false,
	give_orders = true,
	can_be_brushed = true,
	can_jump = true,
	jump_ratio = 10,
	jump_impulse = 1.2,
	breed = true,
	mutation = 1,
	capture_item = "net",
	follow = petz.settings.bunny_follow,
	drops = {
		{name = "petz:raw_rabbit", chance = 1, min = 1, max = 1,},
		{name = "petz:rabbit_hide", chance = 3, min = 1, max = 1,},
		{name = "petz:bone", chance = 5, min = 1, max = 1,},
	},
	sleep_at_night = true,
	sleep_ratio = 0.3,
	rotate = petz.settings.rotate,
	physical = true,
	stepheight = 0.1,	--EVIL!
	collide_with_objects = true,
	collisionbox = collisionbox,
	collisionbox_baby = collisionbox_baby,
	visual = petz.settings.visual,
	mesh = mesh,
	textures = textures,
	skin_colors = skin_colors,
	visual_size = visual_size,
	visual_size_baby = visual_size_baby,
	static_save = true,
	get_staticdata = kitz.statfunc,
	-- api props
	springiness= 0,
	buoyancy = 0.5, -- portion of hitbox submerged
	max_speed = 4,
	jump_height = 1.5,
	view_range = 10,
	lung_capacity = 10, -- seconds
	max_hp = 8,
	makes_footstep_sound = false,

	--head = {
		--position = vector.new(0, 0.0969, 0.1939),
		--rotation_origin = vector.new(-90, -90, 0), --in degrees, normally values are -90, 0, 90
	--},

	attack={range=0.5, damage_groups={fleshy=3}},
	animation = {
		walk={range={x=1, y=12}, speed=25, loop=true},
		run={range={x=13, y=25}, speed=25, loop=true},
		stand={
			{range={x=26, y=46}, speed=5, loop=true},
			{range={x=47, y=59}, speed=5, loop=true},
			{range={x=82, y=94}, speed=5, loop=true},
		},
		sit = {range={x=60, y=73}, speed=10, loop=false},
		sleep = {range={x=94, y=113}, speed=10, loop=false},
		jump = {range={x=114, y=117}, speed=5, loop=false},
	},
	sounds = {
		misc = {"petz_bunny_squeak", "petz_bunny_squeak2", "petz_bunny_squeak3"},
		moaning = "petz_bunny_moaning",
	},

	logic = petz.herbivore_brain,

	on_activate = function(self, staticdata, dtime_s) --on_activate, required
		kitz.actfunc(self, staticdata, dtime_s)
		petz.set_initial_properties(self, staticdata, dtime_s)
	end,

	on_deactivate = function(self)
		petz.on_deactivate(self)
	end,

	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		petz.on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir)
	end,

	on_rightclick = function(self, clicker)
		petz.on_rightclick(self, clicker)
	end,

	on_step = function(self, dtime)
		kitz.stepfunc(self, dtime) -- required
		petz.on_step(self, dtime)
	end,
})

petz:register_egg("petz:bunny", S("Bunny"), "petz_spawnegg_bunny.png", true)
