

-- Rat by PilzAdam, then Krupnov Pavel, then TenPlus1. Guinea pig by DrPlamsa

mobs:register_mob("guinea_pig:guinea_pig", {
	stepheight = 0.6,
	type = "animal",
	passive = true,
	reach = 1,
	hp_min = 5,
	hp_max = 20,
	armor = 200,
	collisionbox = {-0.2, -1, -0.2, 0.2, -0.8, 0.2},
	visual = "mesh",
	mesh = "mobs_rat.b3d",
	textures = {
		{"guinea_pig.png"},
		{"guinea_pig2.png"},
		{"guinea_pig3.png"},
	},
	makes_footstep_sound = false,
	sounds = {
--		random = {"guinea_pig_burble","guinea_pig_wheek"},
		random = "guinea_pig_burble",
		distance = 5,
--		jump = "guinea_pig_wheek",
	},
	walk_velocity = 1,
	run_velocity = 2,
        --runaway = true,
	jump = true,
	pushable = true,
	drops = {
		{name = "mobs:rabbit_raw", chance = 1, min = 1, max = 1},
	},
	water_damage = 0,
	light_damage = 0,
	lava_damage = 5,
	follow = {
		"default:grass_1", "dryplants:hay"
	},
	view_range = 8,
	replace_rate = 80,
	replace_what = {
		{"group:flora", "air", -1},
		{"dryplants:hay", "air", -1},
		{"air", "guinea_pig:pellets", -1},
		{"default:dirt_with_grass", "default:dirt", -2},
	},
	stay_near = {{"farming:jackolantern_on"}, 10},
	fear_height = 2,
	on_rightclick = function(self, clicker)

		-- feed or tame
		if mobs:feed_tame(self, clicker, 4, true, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 90, 90, 0, true) then return end


	end,

	on_replace = function(self, pos, oldnode, newnode)

		-- Prevent a guinea pig from producing pellets on top of air (floating). Gotta be on top of dirt or dirt with grass.
		local myPos = self.object:get_pos()
		myPos.y = myPos.y - 2.0
		local myNode = minetest.get_node(myPos)
		return (myNode.name == "default:dirt_with_grass") or (myNode.name == "default:dirt")
	end,


})


if not mobs.custom_spawn_animal then
mobs:spawn({
	name = "guinea_pig:guinea_pig",
	nodes = {"default:dirt_with_grass", "ethereal:green_dirt"},
	neighbors = {"group:grass"},
	min_light = 14,
	interval = 60,
	chance = 8000, -- 15000
	min_height = 5,
	max_height = 200,
	day_toggle = true,
})
end

-- Craft the guinea pig from a rat and grass
minetest.register_craft({
	type = "shapeless",
	output = "guinea_pig:guinea_pig",
	recipe = {"group:grass", "mobs_animal:rat"}
})

-- Craft the guinea pig from a tamed rat and grass
minetest.register_craft({
	type = "shapeless",
	output = "guinea_pig:guinea_pig",
	recipe = {"group:grass", "mobs_animal:rat_set"}
})


mobs:register_egg("guinea_pig:guinea_pig", "Guinea pig", "guinea_pig_inv.png")

minetest.register_node("guinea_pig:pellets", {
	description = "Guinea pig pellets",
	inventory_image = "farming_cotton_seed.png",
	wield_image = "farming_cotton_seed.png",
	paramtype = "light",
	sunlight_propagates = true,
	tiles = {"farming_cotton_seed.png"},
	drawtype = "nodebox",
	node_box = {
	    type = "fixed",
        fixed = {-0.5   , -0.5   , -0.5   ,   0.5   , -0.4375,  0.5   },
    },
	groups = {snappy=3, flammable=2},
})

-- mulch
minetest.register_craft({
	type = "shapeless",
	output = "bonemeal:mulch 4",
	recipe = {
		"guinea_pig:pellets", "guinea_pig:pellets", "guinea_pig:pellets", 
		"guinea_pig:pellets", "guinea_pig:pellets", "guinea_pig:pellets", 
		"guinea_pig:pellets", "guinea_pig:pellets", "guinea_pig:pellets", 
	}
})


