--
--LEOPARD
--
local S = ...

local scale_model = 2.0
local scale_baby = 0.5
local visual_size = {x=petz.settings.visual_size.x*scale_model, y=petz.settings.visual_size.y*scale_model}
local visual_size_baby = {x=petz.settings.visual_size.x*scale_model*scale_baby, y=petz.settings.visual_size.y*scale_model*scale_baby}
local mesh = 'petz_leopard.b3d'
local p1 = {x= -0.0625, y = -0.5, z = -0.375}
local p2 = {x= 0.125, y = 0.0, z = 0.375}
local collisionbox, collisionbox_baby = petz.get_collisionbox(p1, p2, scale_model, scale_baby)

for i = 1, 2  do

	local pet_name
	local description
	local skin_colors
	local textures = {}
	local mutation

	if i == 1 then
		pet_name = "leopard"
		description = "Leopard"
		skin_colors = {"green_eyes", "blue_eyes", "black"}
		mutation = 1
	else
		pet_name = "snow_leopard"
		description = "Snow Leopard"
		skin_colors = {"yellow_eyes", "orange_eyes"}
		mutation = false
	end

	for n = 1, #skin_colors do
		textures[n] = "petz_"..pet_name.."_"..skin_colors[n]..".png"
	end

	minetest.register_entity("petz:"..pet_name, {
		--Petz specifics
		type = pet_name,
		init_tamagochi_timer = true,
		is_pet = true,
		has_affinity = true,
		is_wild = true,
		breed = true,
		mutation = mutation,
		attack_player = true,
		give_orders = true,
		can_be_brushed = true,
		capture_item = "lasso",
		follow = petz.settings.leopard_follow,
		drops = {
			{name = "petz:bone", chance = 5, min = 1, max = 1,},
			{name = "petz:leopard_skin", chance = 3, min = 1, max = 1,},
		},
		rotate = petz.settings.rotate,
		physical = true,
		stepheight = 0.1,	--EVIL!
		mesh = mesh,
		textures = textures,
		skin_colors = skin_colors,
		visual = petz.settings.visual,
		visual_size = visual_size,
		visual_size_baby = visual_size_baby,
		collisionbox = collisionbox,
		collisionbox_baby = collisionbox_baby,
		collide_with_objects = true,

		static_save = true,
		get_staticdata = kitz.statfunc,
		-- api props
		springiness= 0,
		buoyancy = 0.5, -- portion of hitbox submerged
		max_speed = 4.0,
		jump_height = 1.5,
		view_range = 10,
		lung_capacity = 10, -- seconds
		max_hp = 25,

		attack = {range=0.5, damage_groups= {fleshy = 9}},
		animation = {
			walk={range={x=1, y=12}, speed=25, loop=true},
			run={range={x=13, y=25}, speed=25, loop=true},
			stand={
				{range={x=26, y=46}, speed=5, loop=true},
				{range={x=47, y=59}, speed=5, loop=true},
				{range={x=82, y=94}, speed=5, loop=true},
			},
			sit = {range={x=60, y=65}, speed=5, loop=false},
			attack = {range={x=72, y=84}, speed=5, loop=false},
		},
		sounds = {
			misc = "petz_leopard_roar",
			moaning = "petz_leopard_moaning",
			attack = "petz_leopard_attack",
		},

		logic = petz.predator_brain,

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
	petz:register_egg("petz:"..pet_name, S(description), "petz_spawnegg_"..pet_name..".png", true)
end

