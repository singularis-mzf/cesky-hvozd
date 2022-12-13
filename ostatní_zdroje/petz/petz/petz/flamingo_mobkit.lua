petz.register("flamingo", {
	description = "Flamingo",
	scale_model = 1.0,
	skin_colors = {"pink"},
	collisionbox = {
		p1 = {x= -0.1875, y = -0.5, z = -0.125},
		p2 = {x= 0.1875, y = 0.125, z = 0.1875}
	},
	can_fly = true,
	feathered = true,
	fly_rate = 60,
	can_alight = true,
	max_height = 8,
	is_pet = false,
	max_speed = 2,
	capture_item = "lasso",
	logic = petz.flying_brain,
	animation = {
		walk={range={x=1, y=12}, speed=25, loop=true},
		run={range={x=13, y=25}, speed=25, loop=true},
		stand={
			{range={x=26, y=46}, speed=5, loop=true},
			{range={x=47, y=59}, speed=5, loop=true},
			{range={x=60, y=70}, speed=5, loop=true},
			{range={x=71, y=91}, speed=5, loop=true},
		},
		fly={range={x=92, y=98}, speed=25, loop=true},
		stand_fly={range={x=92, y=98}, speed=25, loop=true},
	},
	sounds = {
		misc = {"petz_flamingo_chirp", "petz_flamingo_chirp_02"},
	},
})
