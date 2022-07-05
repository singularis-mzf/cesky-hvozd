
if minetest.get_modpath("mobs") and not mobs.mod and mobs.mod ~= "redo" then
	minetest.log("error", "[mobs_bat] mobs redo API not found!")
	return
end

-- local variables
local l_skins = {
	{"animal_bat.png"},
	{"animal_bat.png^[colorize:black:150"}
}
local l_spawnnear	= {"default:stone"}
local l_spawnchance	= 30000

mobs:register_mob("mobs_bat:bat", {
	type = "animal",
	passive = false,
	damage = 1,
	reach = 2,
	attack_type = "dogfight",
	hp_min = 7,
	hp_max = 12,
	armor = 130,
	collisionbox = {-0.4,-0.4,-0.4, 0.4,0.4,0.4},
	visual = "mesh",
	mesh = "animal_bat.b3d",
	textures = l_skins,
	rotate = 270,
	walk_velocity = 3,--10,
	run_velocity = 5,--23,
	fall_speed = 0,
	stepheight = 3,
	sounds = {
		random = "animal_bat",
		war_cry = "animal_bat",
		damage = "animal_bat",
		attack = "animal_bat",
	},
	fly = true,
	water_damage = 2,
	lava_damage = 10,
	light_damage = 0,
	view_range = 10,
	animation = {
		speed_normal = 24,		speed_run = 24,
		stand_start = 30,		stand_end = 59,
		fly_start = 30,			fly_end = 59,
		walk_start = 30,		walk_end = 59,
		run_start = 30,			run_end = 59,
		punch_start = 60,		punch_end = 89
	},
	on_rightclick = function(self, clicker)
		mobs:capture_mob(self, clicker, 5, 60, 0, true, nil)
	end
})

mobs:spawn({
	name = "mobs_bat:bat",
	nodes = {"air"},
	neighbors = l_spawnnear,
	max_light = 6,
	interval = 30,
	chance = l_spawnchance,
	active_object_count = 2,
	min_height = -100,
	max_height = 150,
})

mobs:register_egg("mobs_bat:bat", "Bat", "animal_bat_inv.png", 0)
