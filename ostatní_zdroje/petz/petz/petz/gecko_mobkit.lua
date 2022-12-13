petz.register("gecko", {
	description = "Gecko",
	scale_model = 1.0,
	backface_culling = false,
	skin_colors = {"green", "yellow", "orange", "blue"},
	collisionbox = {
		p1 = {x= -0.1875, y = -0.5, z = -0.125},
		p2 = {x= 0.1875, y = -0.25, z = 0.1875}
	},
	is_pet = false,
	lay_eggs = "node",
	egg = {
		drawtype = "nodebox",
		nodebox = {
			type = "fixed",
			fixed = {
				{-0.0625, -0.5, -0.0625, 0.0625, -0.375, 0.0625},
			},
		},
	},
	max_speed = 2,
	capture_item = "net",
	logic = petz.herbivore_brain,
	animation = {
		idle = {range={x=0, y=0}, speed=25, loop=false},
		walk={range={x=1, y=12}, speed=25, loop=true},
		run={range={x=13, y=25}, speed=25, loop=true},
		stand={
			{range={x=26, y=46}, speed=5, loop=true},
			{range={x=47, y=59}, speed=5, loop=true},
		},
		sleep = {range={x=62, y=70}, speed=10, loop=false},
	},
})
