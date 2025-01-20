underch.gems = {}

function underch.gems.register_gem(name, id)
	local block = "underch:" .. id .. "_block"
	local item = "underch:" .. id

	minetest.register_craftitem(item, {
		description = name,
		inventory_image = "underch_" .. id .. ".png"
	})

	minetest.register_node(block, {
		description = name .. " Block",
		tiles = {"underch_" .. id .. "_block.png"},
		groups = {cracky = 3, jit_shadow = 1},
		after_dig_node = underch.jit.dig_shadow,
		is_ground_content = false,
		sounds = default.node_sound_glass_defaults(),
	})

	minetest.register_node("underch:" .. id .. "_ore", {
		description = name .. " Ore",
		tiles = {"default_stone.png^underch_" .. id .."_ore.png"},
		groups = {cracky=2},
		drop = item,
		sounds = default.node_sound_stone_defaults(),
	})

	minetest.register_node("underch:" .. id .. "_crystal", {
		description = name .. " Crystal",
		tiles = {"underch_" .. id .. "_crystal.png"},
		groups = {cracky = 2},
		paramtype = "light",
		paramtype2 = "facedir",
		drawtype = "mesh",
		mesh = "underch_crystal.obj",
		light_source = 4,
		is_ground_content = false,
		sounds = default.node_sound_glass_defaults(),
	})

	minetest.register_craft({
		output = block,
		recipe = {
			{item, item, item},
			{item, item, item},
			{item, item, item}
		}
	})

	minetest.register_craft({
		output = item .. " 9",
		type = "shapeless",
		recipe = {block}
	})

	minetest.register_craft({
		output = item .. " 2",
		type = "shapeless",
		recipe = {"underch:" .. id .. "_crystal"}
	})

	underch.functions.register_stairs(
		id .. "_block", 
		{cracky = 3},
		{"underch_" .. id .. "_block.png"},
		name .. " Block",
		default.node_sound_glass_defaults())
end

underch.gems.register_gem("Amethyst", "amethyst");
underch.gems.register_gem("Ruby", "ruby");
underch.gems.register_gem("Emerald", "emerald");
underch.gems.register_gem("Saphire", "saphire");
underch.gems.register_gem("Quartz", "quartz");
underch.gems.register_gem("Aquamarine", "aquamarine");

minetest.register_node("underch:mese_crystal", {
	description = "Mese Crystal",
	tiles = {"underch_mese_crystal.png"},
	groups = {cracky = 2},
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "mesh",
	mesh = "underch_crystal.obj",
	light_source = 4,
	is_ground_content = false,
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_craft({
	output = "default:mese_crystal 2",
	type = "shapeless",
	recipe = {"underch:mese_crystal"}
})

