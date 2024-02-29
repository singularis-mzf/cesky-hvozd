
-- check available mods for default sound and sand node
local def = minetest.get_modpath("default")
local sand = "default:desert_sand"
local snd_l = def and default.node_sound_leaves_defaults()

if minetest.get_modpath("mcl_core") then
	sand = "mcl_core:sand"
	snd_l = mcl_sounds.node_sound_leaves_defaults()
end

local S = wine.S


-- blue agave
minetest.register_node("wine:blue_agave", {
	description = S("Blue Agave"),
	drawtype = "plantlike",
	visual_scale = 0.8,
	tiles = {"wine_blue_agave.png"},
	inventory_image = "wine_blue_agave.png",
	wield_image = "wine_blue_agave.png",
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, 0.3, 0.2}
	},
	groups = {snappy = 3, attached_node = 1, plant = 1, ch_food = 2},
	sounds = snd_l,

	on_use = ch_core.item_eat(),

	on_construct = function(pos)
		minetest.get_node_timer(pos):start(17)
	end,

	on_timer = function(pos)

		local light = minetest.get_node_light(pos)

		if not light or light < 13 or math.random() > 1/76 then
			return true -- go to next iteration
		end

		local n = minetest.find_nodes_in_area_under_air(
			{x = pos.x + 2, y = pos.y + 1, z = pos.z + 2},
			{x = pos.x - 2, y = pos.y - 1, z = pos.z - 2}, {"wine:blue_agave"})

		-- too crowded, we'll wait for another iteration
		if n and #n > 2 then
			return true
		end

		-- find desert sand with air above (grow across and down only)
		n = minetest.find_nodes_in_area_under_air(
			{x = pos.x + 1, y = pos.y - 1, z = pos.z + 1},
			{x = pos.x - 1, y = pos.y - 2, z = pos.z - 1}, {sand})

		-- place blue agave
		if n and #n > 0 then

			local new_pos = n[math.random(#n)]

			new_pos.y = new_pos.y + 1

			minetest.set_node(new_pos, {name = "wine:blue_agave"})
		end

		return true
	end
})


-- blue agave into cyan dye
minetest.register_craft( {
	output = "dye:cyan 4",
	recipe = {{"wine:blue_agave"}}
})

-- blue agave as fuel
minetest.register_craft({
	type = "fuel",
	recipe = "wine:blue_agave",
	burntime = 10
})

-- cook blue agave into a sugar syrup
minetest.register_craftitem("wine:agave_syrup", {
	description = "Agave Syrup",
	inventory_image = "wine_agave_syrup.png",
	groups = {food_sugar = 1, vessel = 1, flammable = 3}
})

minetest.register_craft({
	type = "cooking",
	cooktime = 7,
	output = "wine:agave_syrup 2",
	recipe = "wine:blue_agave"
})

-- blue agave into paper
minetest.register_craft( {
	output = "default:paper 3",
	recipe = {
		{"wine:blue_agave", "wine:blue_agave", "wine:blue_agave"}
	}
})


-- register blue agave on mapgen
minetest.register_decoration({
	deco_type = "simple",
	place_on = {sand},
	sidelen = 16,
	fill_ratio = 0.001,
	biomes = {"desert"},
	decoration = {"wine:blue_agave"},
	y_min = 15,
	y_max = 50,
	spawn_by = sand,
	num_spawn_by = 6
})


-- add lbm to start agave timers
minetest.register_lbm({
	name = "wine:agave_timer_init",
	nodenames = {"wine:blue_agave"},
	run_at_every_load = false,
	action = function(pos)
		minetest.get_node_timer(pos):start(17)
	end
})


-- add to bonemeal as decoration if available
if minetest.get_modpath("bonemeal") then

	bonemeal:add_deco({
		{sand, {}, {"default:dry_shrub", "wine:blue_agave", "", ""}}
	})
end
