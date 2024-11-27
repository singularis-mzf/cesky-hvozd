ch_base.open_mod(minetest.get_current_modname())

mobs:register_mob("mobs_jellyfish:jellyfish", {
	type = "animal",
	attack_type = "dogfight",
	passive = false,
	damage = 5,
	reach = 1,
	hp_min = 5,
	hp_max = 10,
	armor = 100,
	collisionbox = {-0.1, -0.25, -0.1, 0.1, 0.25, 0.1},
	visual = "mesh",
	mesh = "jellyfish.b3d",
	textures = {
		{"jellyfish.png"}
	},
	makes_footstep_sound = false,
	walk_velocity = 0.1,
	run_velocity = 0.1,
	fly = true,
	fly_in = "default:water_source",
	fall_speed = 0,
	view_range = 10,
	water_damage = 0,
	lava_damage = 5,
	light_damage = 0,

	on_rightclick = function(self, clicker)
		mobs:capture_mob(self, clicker, 80, 100, 0,
				true, "mobs_jellyfish:jellyfish")
	end
})

mobs:spawn({
	name = "mobs_jellyfish:jellyfish",
	nodes = {"default:water_source"},
	neighbors = {"default:water_flowing", "default:water_source"},
	min_light = 5,
	interval = 30,
	chance = 10000,
	max_height = 0,
})

mobs:register_egg("mobs_jellyfish:jellyfish", "medúza", "jellyfish_inv.png", 0)
ch_base.close_mod(minetest.get_current_modname())
