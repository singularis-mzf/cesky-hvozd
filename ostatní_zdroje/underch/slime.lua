underch.slime = {}
--{a = 103, r = 30, g = 60, b = 90}
function underch.slime.regiser_slime(name, id, colour, found_in)
	local eye = "underch:" .. id .. "eye_item"
	local eye_block = "underch:" .. id .. "eye_block"
	local source = "underch:" .. id .. "_slime_source"
	local flowing = "underch:" .. id .. "_slime_flowing"

	minetest.register_craftitem(eye, {
		description = name .. " Eye",
		inventory_image = "underch_" .. id .. "_eye_item.png"
	})

	minetest.register_node(eye_block, {
		description = name .. " Eye Block",
		tiles = {"underch_" .. id .. "_eye_block.png"},
		groups = {oddly_breakable_by_hand = 2},
		is_ground_content = false,
		sounds = default.node_sound_dirt_defaults(),
	})

	minetest.register_node("underch:" .. id .. "_slimy_block", {
		description = name .. " Slimy Block",
		tiles = {"underch_" .. id .. "_slimy_block.png"},
		groups = {crumbly = 1, cracky = 2, jit_shadow = 1},
		after_dig_node = underch.jit.dig_shadow,
		sounds = default.node_sound_dirt_defaults(),
	})

	minetest.register_node("underch:" .. id .. "_eye_ore", {
		description = name .. " Eye Ore",
		tiles = {"underch_" .. id .. "_slimy_eye.png"},
		groups = {crumbly = 1, cracky = 2, jit_shadow = 1},
		after_dig_node = underch.jit.dig_shadow,
		sounds = default.node_sound_dirt_defaults(),
		drop = eye
	})

	minetest.register_craft({
		output = eye_block,
		recipe = {
			{eye, eye, eye},
			{eye, eye, eye},
			{eye, eye, eye},
		}
	})

	minetest.register_craft({
		output = eye .. " 9",
		type = "shapeless",
		recipe = {eye_block}
	})

--[[	minetest.register_craft({
		output = "underch:" .. id .. "_slime_brick",
		type = "cooking",
		recipe = "underch:" .. id .. "_slimy_block"
	})--]]
	
	minetest.register_node(source, {
		description = name .. " Slime Source",
		drawtype = "liquid",
		tiles = {"underch_" .. id .. "_slime.png"},
		special_tiles = {"underch_" .. id .. "_slime.png"},
		paramtype = "light",
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = true,
		is_ground_content = false,
		drop = "",
		drowning = 1,
		liquidtype = "source",
		liquid_alternative_flowing = flowing,
		liquid_alternative_source = source,
		liquid_viscosity = 12,
		liquid_renewable = false,
		post_effect_color = colour,
		groups = {not_in_creative_inventory = 1, water = 3, liquid = 3, puts_out_fire = 1, cools_lava = 1},
		sounds = default.node_sound_sand_defaults(),
	})
	
	minetest.register_node(flowing, {
		description = name .. " Flowing Slime",
		drawtype = "flowingliquid",
		tiles = {"underch_" .. id .. "_slime.png"},
		special_tiles = {
			{
				name = "underch_" .. id .. "_slime_flowing.png",
				backface_culling = false,
				animation = {
					type = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					length = 6.0,
				},
			},
			{
				name = "underch_" .. id .. "_slime_flowing.png",
				backface_culling = true,
				animation = {
					type = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					length = 6.0,
				},
			},
		},
		paramtype = "light",
		paramtype2 = "flowingliquid",
		walkable = false,
		pointable = false,
		diggable = false,
		buildable_to = true,
		is_ground_content = false,
		liquid_renewable = false,
		drop = "",
		drowning = 12,
		liquidtype = "flowing",
		liquid_alternative_flowing = flowing,
		liquid_alternative_source = source,
		liquid_viscosity = 17,
		post_effect_color = colour,
		groups = {water = 3, liquid = 3, puts_out_fire = 1, not_in_creative_inventory = 1, cools_lava = 1},
		sounds = default.node_sound_sand_defaults(),
	})

	if underch.have_bucket then
		bucket.register_liquid(
			source,
			flowing,
			"underch:" .. id .. "_bucket",
			"underch_" .. id .. "_bucket.png",
			name .. " Slime Bucket"
		)
	end

	underch.functions.register_stairs(
		id .. "_slimy_block", 
		{crumbly = 1, cracky = 2},
		{"underch_" .. id .. "_slimy_block.png"},
		name .. " Slimy Block",
		default.node_sound_dirt_defaults())

	underch.dynamic.register_flooder(id .. "_slime", found_in, source,
		underch.dynamic.all_sides, 100)

	underch.dynamic.register_flooder(id .. "_slimy_block", found_in,
		"underch:" .. id .. "_slimy_block", underch.dynamic.all_sides, 100,
		{{block = "underch:" .. id .. "_eye_ore", chance = 1/10}})
end

underch.slime.regiser_slime("Black", "black", {a = 210, r = 0, g = 0, b = 0}, "underch:slate")
underch.slime.regiser_slime("Green", "green", {a = 210, r = 20, g = 160, b = 0}, "underch:green_slimestone")
underch.slime.regiser_slime("Purple", "purple", {a = 210, r = 160, g = 0, b = 200}, "underch:purple_slimestone")
underch.slime.regiser_slime("Red", "red", {a = 210, r = 160, g = 0, b = 30}, "underch:red_slimestone")

minetest.register_craft({
	recipe = "underch:green_slimy_block",
	type = "cooking",
	output = "underch:green_slimestone"
})

minetest.register_craft({
	recipe = "underch:purple_slimy_block",
	type = "cooking",
	output = "underch:purple_slimestone"
})

minetest.register_craft({
	recipe = "underch:red_slimy_block",
	type = "cooking",
	output = "underch:red_slimestone"
})

minetest.register_craft({
	recipe = "underch:black_slimy_block",
	type = "cooking",
	output = "underch:slate"
})
