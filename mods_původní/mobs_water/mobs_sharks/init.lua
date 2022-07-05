-- local variables
local l_skins = {
	{
		"(shark_first.png^[colorize:#404040:150" -- dark grey
		.. ")^(shark_second.png^[colorize:#a0a0a0:150" -- grey
		.. ")^shark_third.png"
	},
	{
		"(shark_first.png^[colorize:#604000:175" -- brown
		.. ")^(shark_second.png^[colorize:#ffffff:150" -- white
		..")^shark_third.png"
	},
	{
		"(shark_first.png^[colorize:#a0a0a0:150" -- grey
		.. ")^(shark_second.png^[colorize:#ffffff:150" -- white
		.. ")^shark_third.png"
	}
}


local l_spawn_chance = 60000

-- load settings
dofile(minetest.get_modpath("mobs_sharks") .. "/SETTINGS.txt")

if not ENABLE_SHARK_LARGE then
	l_spawn_chance = l_spawn_chance - 20000
end

if not ENABLE_SHARK_MEDIUM then
	l_spawn_chance = l_spawn_chance - 20000
end

if not ENABLE_SHARK_SMALL then
	l_spawn_chance = l_spawn_chance - 20000
end


-- large
if ENABLE_SHARK_LARGE then

	mobs:register_mob("mobs_sharks:shark_lg", {
		type = "monster",
		attack_type = "dogfight",
		damage = 10,
		reach = 3,
		hp_min = 20,
		hp_max = 25,
		armor = 150,
		collisionbox = {-0.75, -0.5, -0.75, 0.75, 0.5, 0.75},
		visual = "mesh",
		mesh = "mob_shark.b3d",
		textures = l_skins,
		makes_footstep_sound = false,
		walk_velocity = 4,
		run_velocity = 6,
		fly = true,
		fly_in = "default:water_source",
		fall_speed = 0,
		rotate = 270,
		view_range = 10,
		water_damage = 0,
		lava_damage = 10,
		light_damage = 0,
		animation = {
			speed_normal = 24,
			speed_run = 24,
			stand_start = 1,
			stand_end = 80,
			walk_start = 80,
			walk_end = 160,
			fly_start = 80,
			fly_end = 160,
			run_start = 80,
			run_end = 160
		},
		jump = false,
		stepheight = 0,
		drops = {
			{name = "mobs:meat_raw", chance = 1, min = 1, max = 3},
		},
	})

	mobs:spawn({
		name = "mobs_sharks:shark_lg",
		nodes = {"default:water_flowing","default:water_source"},
		neighbors = {
			"default:water_flowing", "default:water_source",
			"seawrecks:woodship", "seawrecks:uboot"
		},
		interval = 30,
		chance = l_spawn_chance,
		max_height = 0,
	})

	mobs:register_egg("mobs_sharks:shark_lg", "Shark (large)",
			"mob_shark_shark_item.png", 0)
end

-- medium
if ENABLE_SHARK_MEDIUM then

	mobs:register_mob("mobs_sharks:shark_md", {
		type = "monster",
		attack_type = "dogfight",
		damage = 8,
		reach = 2,
		hp_min = 15,
		hp_max = 20,
		armor = 125,
		collisionbox = {-0.57, -0.38, -0.57, 0.57, 0.38, 0.57},
		visual = "mesh",
		visual_size = {x = 0.75, y = 0.75},
		mesh = "mob_shark.b3d",
		textures = l_skins,
		makes_footstep_sound = false,
		walk_velocity = 2,
		run_velocity = 4,
		fly = true,
		fly_in = "default:water_source",
		fall_speed = -1,
		rotate = 270,
		view_range = 10,
		water_damage = 0,
		lava_damage = 10,
		light_damage = 0,
		animation = {
			speed_normal = 24,
			speed_run = 24,
			stand_start = 1,
			stand_end = 80,
			walk_start = 80,
			walk_end = 160,
			run_start = 80,
			run_end = 160
		},
		jump = false,
		stepheight = 0,
		drops = {
			{name = "mobs:meat_raw", chance = 1, min = 1, max = 3},
		},
	})

	mobs:spawn({
		name = "mobs_sharks:shark_md",
		nodes = {"default:water_flowing","default:water_source"},
		neighbors = {
			"default:water_flowing", "default:water_source",
			"seawrecks:woodship", "seawrecks:uboot"
		},
		interval = 30,
		chance = l_spawn_chance,
		max_height = 0,
	})

	mobs:register_egg("mobs_sharks:shark_md", "Shark (medium)",
			"mob_shark_shark_item.png", 0)
end

-- small
if ENABLE_SHARK_SMALL then

	mobs:register_mob("mobs_sharks:shark_sm", {
		type = "monster",
		attack_type = "dogfight",
		damage = 6,
		reach = 1,
		hp_min = 10,
		hp_max = 15,
		armor = 100,
		collisionbox = {-0.38, -0.25, -0.38, 0.38, 0.25, 0.38},
		visual = "mesh",
		visual_size = {x = 0.5, y = 0.5},
		mesh = "mob_shark.b3d",
		textures = l_skins,
		makes_footstep_sound = false,
		walk_velocity = 2,
		run_velocity = 4,
		fly = true,
		fly_in = "default:water_source",
		fall_speed = -1,
		rotate = 270,
		view_range = 10,
		water_damage = 0,
		lava_damage = 10,
		light_damage = 0,
		animation = {
			speed_normal = 24,
			speed_run = 24,
			stand_start = 1,
			stand_end = 80,
			walk_start = 80,
			walk_end = 160,
			run_start = 80,
			run_end = 160
		},
		jump = false,
		stepheight = 0,
		drops = {
			{name = "mobs:meat_raw", chance = 1, min = 1, max = 3},
		},
	})

	mobs:spawn({
		name = "mobs_sharks:shark_sm",
		nodes = {"default:water_flowing","default:water_source"},
		neighbors = {
			"default:water_flowing", "default:water_source",
			"seawrecks:woodship", "seawrecks:uboot"
		},
		interval = 30,
		chance = l_spawn_chance,
		max_height = 0,
	})

	mobs:register_egg("mobs_sharks:shark_sm", "Shark (small)",
			"mob_shark_shark_item.png", 0)
end
