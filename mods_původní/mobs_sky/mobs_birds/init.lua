
-- local variables
local l_spawn_chance_gull	= 24000
local l_spawn_chance_bird	= 36000

-- load settings
dofile(minetest.get_modpath("mobs_birds").."/SETTINGS.txt")

if not ENABLE_LARGE_BIRDS then
	l_spawn_chance_bird = l_spawn_chance_bird - 18000
end

if not ENABLE_SMALL_BIRDS then
	l_spawn_chance_bird = l_spawn_chance_bird - 18000
end


-- gulls
if ENABLE_GULLS then

	mobs:register_mob("mobs_birds:gull", {
		type = "animal",
		passive = true,
		hp_min = 5,
		hp_max = 10,
		armor = 100,
		collisionbox = {-1, -0.3, -1, 1, 0.3, 1},
		visual = "mesh",
		mesh = "animal_gull.b3d",
		textures = {
			{"animal_gull_mesh.png"},
			{"gull_black.png"},
			{"gull_gray.png"},
			{"gull_grayblue.png"}
		},
		rotate = 270,
		walk_velocity = 4,
		run_velocity = 6,
		fall_speed = 0,
		stepheight = 3,
		fly = true,
		keep_flying = true,
		water_damage = 0,
		lava_damage = 10,
		light_damage = 0,
		view_range = 14,
		animation = {
			speed_normal = 24,	speed_run = 24,
			stand_start = 1,	stand_end = 95,
			walk_start = 1,		walk_end = 95,
			fly_start = 1,		fly_end = 95,
			run_start = 1,		run_end = 95
		},
		on_rightclick = function(self, clicker)
			mobs:capture_mob(self, clicker, 5, 60, 0, true, nil)
		end
	})

	mobs:spawn({
		name = "mobs_birds:gull",
		nodes = {"air"},
		neighbors = {"default:water_source", "default:water_flowing"},
		max_light = 5,
		interval = 30,
		chance = l_spawn_chance_gull,
		min_height = 0,
		max_height = 200
	})

	mobs:register_egg("mobs_birds:gull", "Gull", "default_cloud.png", 1)
end

-- large birds
if ENABLE_LARGE_BIRDS then

	mobs:register_mob("mobs_birds:bird_lg", {
		type = "animal",
		passive = true,
		hp_min = 5,
		hp_max = 10,
		armor = 100,
		collisionbox = {-0.5, -0.3, -0.5, 0.5, 0.3, 0.5},
		visual = "mesh",
		mesh = "animal_gull.b3d",
		textures = {
			{"bird_blueish.png"},
			{"bird_brown.png"},
			{"bird_gray.png"},
			{"bird_grayblue.png"},
			{"bird_red.png"},
			{"bird_redish.png"}
		},
		visual_size = {x = .5, y = .5},
		rotate = 270,
		walk_velocity = 4,
		run_velocity = 6,
		fall_speed = 0,
		stepheight = 3,
		fly = true,
		keep_flying = true,
		water_damage = 0,
		lava_damage = 10,
		light_damage = 0,
		view_range = 12,
		animation = {
			speed_normal = 24,	speed_run = 24,
			stand_start = 1,	stand_end = 95,
			walk_start = 1,		walk_end = 95,
			run_start = 1,		run_end = 95
		},
		on_rightclick = function(self, clicker)
			mobs:capture_mob(self, clicker, 5, 60, 0, true, nil)
		end
	})

	mobs:spawn({
		name = "mobs_birds:bird_lg",
		nodes = {"air"},
		neighbors = {
			"default:leaves", "default:pine_needles",
			"default:jungleleaves", "default:cactus"
		},
		max_light = 5,
		interval = 30,
		chance = l_spawn_chance_bird,
		min_height = 0,
		max_height = 200
	})

	mobs:register_egg("mobs_birds:bird_lg", "Large bird", "default_cloud.png", 1)
end

-- small birds
if ENABLE_SMALL_BIRDS then

	mobs:register_mob("mobs_birds:bird_sm", {
		type = "animal",
		passive = true,
		hp_min = 2,
		hp_max = 5,
		armor = 100,
		collisionbox = {-0.25, -0.3, -0.25, 0.25, 0.3, 0.25},
		visual = "mesh",
		mesh = "animal_gull.b3d",
		textures = {
			{"bird_blueish.png"},
			{"bird_brown.png"},
			{"bird_gray.png"},
			{"bird_grayblue.png"},
			{"bird_red.png"},
			{"bird_redish.png"}
		},
		visual_size = {x = .25, y = .25},
		rotate = 270,
		walk_velocity = 4,
		run_velocity = 6,
		fall_speed = 0,
		stepheight = 3,
		fly = true,
		keep_flying = true,
		water_damage = 0,
		lava_damage = 10,
		light_damage = 0,
		view_range = 10,
		animation = {
			speed_normal = 24,	speed_run = 24,
			stand_start = 1,	stand_end = 95,
			walk_start = 1,		walk_end = 95,
			run_start = 1,		run_end = 95
		},
		on_rightclick = function(self, clicker)
			mobs:capture_mob(self, clicker, 5, 60, 0, true, nil)
		end
	})

	mobs:spawn({
		name = "mobs_birds:bird_sm",
		nodes = {"air"},
		neighbors = {
			"default:leaves", "default:pine_needles",
			"default:jungleleaves", "default:cactus"
		},
		max_light = 5,
		interval = 30,
		chance = l_spawn_chance_bird,
		min_height = 0,
		max_height = 200
	})

	mobs:register_egg("mobs_birds:bird_sm", "Small bird", "default_cloud.png", 1)
end
