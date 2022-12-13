petz.register("parrot", {
	description = "Parrot",
	scale_model = 1.0,
	skin_colors = {"scarlet", "blue-and-yellow", "military", "hyacinth", "gray"},
	collisionbox = {
		p1 = {x= -0.125, y = -0.5, z = -0.125},
		p2 = {x= 0.0625, y = 0.125, z = 0.1875}
	},
	can_fly = true,
	is_pet = true,
	max_hp = 8,
	can_alight = false,
	give_orders = true,
	can_be_brushed = true,
	can_perch = true,
	max_height = 5,
	backface_culling = false,
	init_tamagochi_timer = true,
	max_speed = 2.5,
	view_range = 12,
	capture_item = "net",
	jump_height = 2.0,
	logic = petz.flying_brain,
	drops = {
		{name = "petz:raw_parrot", chance = 3, min = 1, max = 1,},
	},
	animation = {
		walk = {range = {x=1, y=12}, speed=25, loop=true},
		run = {range = {x=13, y=25}, speed=25, loop=true},
		stand = {
			{range = {x=26, y=46}, speed=5, loop=true},
			{range = {x=47, y=59}, speed=5, loop=true},
			{range = {x=60, y=70}, speed=5, loop=true},
			{range = {x=71, y=91}, speed=5, loop=true},
		},
		fly = {range= {x=92, y=98}, speed=25, loop=true},
		stand_fly = {range = {x=92, y=98}, speed=25, loop=true},
	},
	sounds = {
		misc = "petz_parrot_chirp",
		moaning = "petz_parrot_moaning",
	},
})
