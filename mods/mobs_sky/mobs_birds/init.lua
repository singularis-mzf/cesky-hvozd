
-- local variables
local l_spawn_chance_gull	= 24000
local l_spawn_chance_bird	= 36000

-- settings
local ENABLE_GULLS = true
local ENABLE_LARGE_BIRDS = true
local ENABLE_SMALL_BIRDS = true

if not ENABLE_LARGE_BIRDS then
	l_spawn_chance_bird = l_spawn_chance_bird - 18000
end

if not ENABLE_SMALL_BIRDS then
	l_spawn_chance_bird = l_spawn_chance_bird - 18000
end


-- gulls
if ENABLE_GULLS then

	local gulls = {
		{"default", "racek obecný", {"animal_gull_mesh.png"}, false, "default_cloud.png"},
		{"black", "racek černý", {"gull_black.png"}, false, "default_cloud.png^[colorize:#000000:240"},
		{"gray", "racek šedý", {"gull_gray.png"}, false, "default_cloud.png^[colorize:#999999:240"},
		{"grayblue", "racek modrošedý", {"gull_grayblue.png"}, false, "default_cloud.png^[colorize:#73778a:240"},
	}
	
	local gull_template = {
		type = "animal",
		passive = true,
		hp_min = 5,
		hp_max = 10,
		armor = 100,
		collisionbox = {-1, -0.3, -1, 1, 0.3, 1},
		visual = "mesh",
		mesh = "animal_gull.b3d",
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
			run_start = 1,		run_end = 95,
		},
		on_rightclick = function(self, clicker)
			mobs:capture_mob(self, clicker, 5, 60, 0, true, nil)
		end,
	}

	for _, info in ipairs(gulls) do
		local def = table.copy(gull_template)
		def.textures = info[3]
		mobs:register_mob("mobs_birds:gull_" .. info[1], def)

		mobs:spawn({
			name = "mobs_birds:gull_" .. info[1],
			nodes = {"air"},
			neighbors = {"default:water_source", "default:water_flowing"},
			max_light = 5,
			interval = 30,
			chance = l_spawn_chance_gull,
			min_height = 0,
			max_height = 200,
			cesky_hvozd_allowed = info[4],
		})

		mobs:register_egg("mobs_birds:gull_" .. info[1], info[2], info[5], 1)
	end
end

local birds = {
	{"blueish", "modrý pták", {"bird_blueish.png"}, true, "default_cloud.png^[colorize:#2e00d9:240"},
	{"brown", "hnědý pták", {"bird_brown.png"}, true, "default_cloud.png^[colorize:#603431:240"},
	{"gray", "šedý pták", {"bird_gray.png"}, true, "default_cloud.png^[colorize:#4c4c4c:240"},
	{"grayblue", "modrošedý pták", {"bird_grayblue.png"}, true, "default_cloud.png^[colorize:#626a8e:240"},
	{"red", "červený pták", {"bird_red.png"}, true, "default_cloud.png^[colorize:#8d1112:240"},
	{"redish", "pestrý pták", {"bird_redish.png"}, true, "default_cloud.png^[colorize:#892056:240"},
}

local large_bird_template = {
	type = "animal",
	passive = true,
	hp_min = 5,
	hp_max = 10,
	armor = 100,
	collisionbox = {-0.5, -0.3, -0.5, 0.5, 0.3, 0.5},
	visual = "mesh",
	mesh = "animal_gull.b3d",
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
}

local small_bird_template = table.copy(large_bird_template)
small_bird_template.hp_min = 2
small_bird_template.hp_max = 5
small_bird_template.collisionbox = {-0.25, -0.3, -0.25, 0.25, 0.3, 0.25}
small_bird_template.visual_size = {x = .25, y = .25}
small_bird_template.view_range = 10

-- large birds
if ENABLE_LARGE_BIRDS then

	for _, info in ipairs(birds) do
		local mobname = "mobs_birds:bird_lg_" .. info[1]
		local def = table.copy(large_bird_template)
		def.textures = {info[3]}
		mobs:register_mob(mobname, def)

		mobs:spawn({
			name = mobname,
			nodes = {"air"},
			neighbors = {
				"default:leaves", "default:pine_needles",
				"default:jungleleaves", "default:cactus"
			},
			max_light = 5,
			interval = 30,
			chance = l_spawn_chance_bird,
			min_height = 0,
			max_height = 200,
			cesky_hvozd_allowed = info[4],
		})

		mobs:register_egg(mobname, "velký "..info[2], info[5], 1)
	end
end

-- small birds
if ENABLE_SMALL_BIRDS then

	for _, info in ipairs(birds) do
		local mobname = "mobs_birds:bird_sm_" .. info[1]
		local def = table.copy(small_bird_template)
		def.textures = {info[3]}
		mobs:register_mob(mobname, def)

		mobs:spawn({
			name = mobname,
			nodes = {"air"},
			neighbors = {
				"default:leaves", "default:pine_needles",
				"default:jungleleaves", "default:cactus"
			},
			max_light = 5,
			interval = 30,
			chance = l_spawn_chance_bird,
			min_height = 0,
			max_height = 200,
			cesky_hvozd_allowed = info[4],
		})

		mobs:register_egg(mobname, "malý "..info[2], info[5], 1)
	end
end
