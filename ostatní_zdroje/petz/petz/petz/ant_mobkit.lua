local S = ...

for i=1, 3 do
	local pet_name
	local ant_type
	local scale_model
	local description
	local mesh
	local textures
	local attack_player
	local lay_eggs
	local drops
	if i == 1 then
		pet_name = "ant"
		ant_type = "worker"
		description = "Worker Ant"
		mesh = 'petz_ant.b3d'
		scale_model = 0.375
		textures= {"petz_ant.png"}
		attack_player = false
		lay_eggs = false
		drops = {}
	elseif i == 2 then
		pet_name = "warrior_ant"
		ant_type = "warrior"
		description = "Warrior Ant"
		mesh = 'petz_ant_warrior.b3d'
		scale_model = 0.575
		textures= {"petz_warrior_ant.png"}
		attack_player = true
		lay_eggs = false
		drops = {}
	else
		pet_name = "queen_ant"
		ant_type = "queen"
		description = "Queen Ant"
		mesh = 'petz_ant.b3d'
		scale_model = 0.875
		textures= {"petz_queen_ant.png"}
		attack_player = false
		lay_eggs = "node"
		drops = {
			{name = "petz:ant_head", chance = 3, min = 1, max = 1,},
			{name = "petz:ant_body", chance = 3, min = 1, max = 1,},
			{name = "petz:ant_leag", chance = 3, min = 1, max = 6,},
		}
	end
	local p1 = {x= -0.1875, y = -0.5, z = -0.3125}
	local p2 = {x= 0.25, y = 0.0625, z = 0.3125}
	local collisionbox = petz.get_collisionbox(p1, p2, scale_model, nil)

	minetest.register_entity("petz:"..pet_name, {
		--Petz specifics
		type = "ant",
		ant_type = ant_type,
		init_tamagochi_timer = false,
		is_pet = false,
		description = description,
		can_fly = false,
		max_height = 5,
		has_affinity = false,
		give_orders = false,
		can_be_brushed = false,
		capture_item = "net",
		is_wild = true,
		lay_eggs = lay_eggs,
		attack_player = attack_player,
		avoid_player = false,
		follow = petz.settings.ant_follow,
		--automatic_face_movement_dir = 0.0,
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
		springiness= 0,
		buoyancy = 0.5, -- portion of hitbox submerged
		max_speed = 3.5,
		jump_height = 2.0,
		view_range = 10,
		lung_capacity = 10, -- seconds
		max_hp = 2,

		attack={range=0.5, damage_groups={fleshy=3}},
		animation = {
			walk={range={x=1, y=12}, speed=20, loop=true},
			run={range={x=13, y=25}, speed=20, loop=true},
			stand={
				{range={x=26, y=46}, speed=5, loop=true},
				{range={x=47, y=59}, speed=5, loop=true},
				{range={x=60, y=70}, speed=5, loop=true},
				{range={x=71, y=91}, speed=5, loop=true},
			},
			fly={range={x=92, y=98}, speed=30, loop=true},
			stand_fly={range={x=92, y=98}, speed=30, loop=true},
		},

		drops = drops,

		logic = petz.ant_brain,

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
