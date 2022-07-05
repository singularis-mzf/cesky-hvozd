
-- local variables
local l_spawn_chance = 60000

-- load settings
local ENABLE_WALKERS = minetest.settings:get_bool("mobs_crocs.enable_walkers", true)
local ENABLE_FLOATERS = minetest.settings:get_bool("mobs_crocs.enable_floaters", true)
local ENABLE_SWIMMERS = minetest.settings:get_bool("mobs_crocs.enable_swimmers", true)

if not ENABLE_WALKERS then
	l_spawn_chance = l_spawn_chance - 20000
end

if not ENABLE_FLOATERS then
	l_spawn_chance = l_spawn_chance - 20000
end

if not ENABLE_SWIMMERS then
	l_spawn_chance = l_spawn_chance - 20000
end

-- no float
if ENABLE_WALKERS then

	mobs:register_mob("mobs_crocs:crocodile", {
		type = "monster",
		attack_type = "dogfight",
		damage = 8,
		reach = 3,
		hp_min = 20,
		hp_max = 25,
		armor = 200,
		collisionbox = {-0.85, -0.30, -0.85, 0.85, 1.5, 0.85},
		drawtype = "front",
		visual = "mesh",
		mesh = "crocodile.x",
		textures = {
			{"croco.png"},
			{"croco2.png"}
		},
		visual_size = {x = 4, y = 4},
		sounds = {random = "croco"},
		fly = false,
		floats = 0,
		stepheight = 1,
		view_range = 10,
		water_damage = 0,
		lava_damage = 10,
		light_damage = 0,
		animation = {
			speed_normal = 24,	speed_run = 24,
			stand_start = 0,	stand_end = 80,
			walk_start = 81,	walk_end = 170,
			run_start = 81,		run_end = 170,
			punch_start = 205,	punch_end = 220
		},
		drops = {
			{name = "mobs:meat_raw", chance = 1, min = 1, max = 3},
			{name = "mobs:leather", chance = 1, min = 0, max = 2},
		},
	})

	mobs:spawn({
		name = "mobs_crocs:crocodile",
		nodes = {
			"default:dirt_with_grass", "default:dirt",
			"default:jungle_grass", "default:sand"
		},
		neighbors = {
			"default:water_flowing", "default:water_source",
			"default:papyrus", "dryplants:juncus", "dryplants:reedmace"
		},
		interval = 30,
		chance = l_spawn_chance,
		min_height = 0,
		max_height = 10,
	})

	mobs:register_egg("mobs_crocs:crocodile", "Crocodile", "default_grass.png", 1)
end

-- float
if ENABLE_FLOATERS then

	mobs:register_mob("mobs_crocs:crocodile_float", {
		type = "monster",
		attack_type = "dogfight",
		damage = 8,
		reach = 2,
		hp_min = 20,
		hp_max = 25,
		armor = 200,
		collisionbox = {-0.638, -0.23, -0.638, 0.638, 1.13, 0.638},
		drawtype = "front",
		visual = "mesh",
		mesh = "crocodile.x",
		textures = {
			{"croco.png"},
			{"croco2.png"}
		},
		visual_size = {x = 3, y = 3},
		sounds = {random = "croco"},
		fly = false,
		stepheight = 1,
		view_range = 10,
		water_damage = 0,
		lava_damage = 10,
		light_damage = 0,
		animation = {
			speed_normal = 24,	speed_run = 24,
			stand_start = 0,	stand_end = 80,
			walk_start = 81,	walk_end = 170,
			run_start = 81,		run_end = 170,
			punch_start = 205,	punch_end = 220
		},
		drops = {
			{name = "mobs:meat_raw", chance = 1, min = 1, max = 3},
			{name = "mobs:leather", chance = 1, min = 0, max = 2},
		},
	})

	mobs:spawn({
		name = "mobs_crocs:crocodile_float",
		nodes = {"default:water_flowing","default:water_source"},
		neighbors = {
			"default:dirt_with_grass", "default:jungle_grass", "default:sand",
			"default:dirt", "default:papyrus", "group:seaplants",
			"dryplants:juncus", "dryplants:reedmace"
		},
		interval = 30,
		chance = l_spawn_chance,
		min_height = -3,
		max_height = 10,
	})

	mobs:register_egg("mobs_crocs:crocodile_float", "Crocodile (floater)",
		"default_grass.png", 1)
end

-- swim
if ENABLE_SWIMMERS then

	mobs:register_mob("mobs_crocs:crocodile_swim", {
		type = "monster",
		attack_type = "dogfight",
		damage = 8,
		reach = 1,
		hp_min = 20,
		hp_max = 25,
		armor = 200,
		collisionbox = {-0.425, -0.15, -0.425, 0.425, 0.75, 0.425},
		drawtype = "front",
		visual = "mesh",
		mesh = "crocodile.x",
		textures = {
			{"croco.png"},
			{"croco2.png"}
		},
		visual_size = {x = 2, y = 2},
		sounds = {random = "croco"},
		fly = true,
		fly_in = "default:water_source",
		fall_speed = -1,
		floats = 0,
		view_range = 10,
		water_damage = 0,
		lava_damage = 10,
		light_damage = 0,
		animation = {
			speed_normal = 24,	speed_run = 24,
			stand_start = 0,	stand_end = 80,
			walk_start = 81,	walk_end = 170,
			fly_start = 81,		fly_end = 170,
			run_start = 81,		run_end = 170,
			punch_start = 205,	punch_end = 220
		},
		drops = {
			{name = "mobs:meat_raw", chance = 1, min = 1, max = 3},
			{name = "mobs:leather", chance = 1, min = 0, max = 2},
		},
	})

	mobs:spawn({
		name = "mobs_crocs:crocodile_swim",
		nodes = {"default:water_flowing","default:water_source"},
		neighbors = {"default:sand","default:dirt","group:seaplants"},
		interval = 30,
		chance = l_spawn_chance,
		min_height = -8,
		max_height = 10,
	})

	mobs:register_egg("mobs_crocs:crocodile_swim", "Crocodile (swimmer)",
		"default_grass.png", 1)
end
