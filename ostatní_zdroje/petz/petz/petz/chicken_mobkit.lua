--
--CHICKEN
--
local S = ...

for i=1, 3 do
	local pet_name
	local mesh
	local scale_model
	local description
	local textures
	local p1
	local p2
	local lay_eggs
	local parents
	local aggressive
	local is_baby
	local is_male
	local sounds
	local backface_culling
	if i == 1 then
		pet_name = "hen"
		description = "Hen"
		lay_eggs = "nest"
		mesh = 'petz_hen.b3d'
		backface_culling = false
		scale_model = 2.1
		textures= {"petz_hen.png", "petz_hen2.png", "petz_hen3.png"}
		p1 = {x= -0.0625, y = -0.5, z = -0.125}
		p2 = {x= 0.125, y = -0.125, z = 0.1875}
		sounds = {
			misc = {"petz_hen_cluck", "petz_hen_cluck_2", "petz_hen_cluck_3"},
		}
		parents = nil
		aggressive = false
		is_baby = false
		is_male = false
	elseif i == 2 then
		pet_name = "rooster"
		description = "Rooster"
		lay_eggs = false
		mesh = 'petz_rooster.b3d'
		backface_culling = true
		scale_model = 1.4
		textures= {"petz_rooster.png"}
		p1 = {x= -0.1875, y = -0.5, z = -0.25}
		p2 = {x= 0.125, y = 0.125, z = 0.25}
		sounds = {
			misc = {"petz_rooster_crow", "petz_rooster_chirp"},
		}
		parents = nil
		aggressive = true
		is_baby = false
		is_male = true
	else
		pet_name = "chicken"
		description = "Chicken"
		lay_eggs = false
		mesh = 'petz_chicken.b3d'
		backface_culling = false
		scale_model = 1.0
		textures= {"petz_chicken.png"}
		p1 = {x= -0.125, y = -0.5, z = -0.1875}
		p2 = {x= 0.0625, y = 0, z = 0.0625}
		sounds = {
			misc = {"petz_chicken_chirp", "petz_chicken_chirp_2", "petz_chicken_chirp_3"},
		}
		parents = {"petz:hen", "petz:rooster"}
		aggressive = false
		is_baby = true
	end
	local collisionbox = petz.get_collisionbox(p1, p2, scale_model, nil)

	minetest.register_entity("petz:"..pet_name,{
		--Petz specifics
		type = pet_name,
		init_tamagochi_timer = false,
		is_pet = true,
		has_affinity = false,
		is_wild = false,
		is_male = is_male,
		is_baby = is_baby,
		parents = parents,
		aggressive = aggressive,
		backface_culling = backface_culling,
		give_orders = false,
		feathered = true,
		can_be_brushed = false,
		capture_item = "net",
		lay_eggs = lay_eggs,
		follow = petz.settings.hen_follow,
		drops = {
			{name = "petz:raw_chicken", chance = 3, min = 1, max = 1,},
			{name = "petz:bone", chance = 6, min = 1, max = 1,},
		},
		rotate = petz.settings.rotate,
		physical = true,
		stepheight = 0.1,	--EVIL!
		collide_with_objects = true,
		collisionbox = collisionbox,
		visual = petz.settings.visual,
		mesh = mesh,
		textures = textures,
		visual_size = {x=petz.settings.visual_size.x*scale_model, y=petz.settings.visual_size.y*scale_model},
		static_save = true,
		get_staticdata = kitz.statfunc,
		-- api props
		springiness= 0,
		buoyancy = 0.5, -- portion of hitbox submerged
		max_speed = 2,
		jump_height = 1.5,
		view_range = 10,
		lung_capacity = 10, -- seconds
		max_hp = 8,

		attack={range=0.5, damage_groups={fleshy=3}},
		animation = {
			walk={range={x=1, y=12}, speed=25, loop=true},
			run={range={x=13, y=25}, speed=25, loop=true},
			stand={
				{range={x=26, y=46}, speed=5, loop=true},
				{range={x=47, y=59}, speed=5, loop=true},
				{range={x=60, y=70}, speed=5, loop=true},
				{range={x=71, y=91}, speed=5, loop=true},
			},
		},
		sounds = sounds,

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

	petz:register_egg("petz:"..pet_name, S(description), "petz_spawnegg_"..pet_name..".png", false)

end

