-- Classic

minetest.register_node("underch:mossy_gravel", {
	description = "Mossy Gravel",
	tiles = {"underch_mossy_gravel.png"},
	groups = {crumbly = 2, falling_node = 1},
	is_ground_content = true,
	sounds = default.node_sound_gravel_defaults(),
})

minetest.register_node("underch:mossy_dirt", {
	description = "Mossy Dirt",
	tiles = {"underch_mossy_dirt.png"},
	groups = {crumbly = 3, soil = 1, jit_shadow = 1},
	after_dig_node = underch.jit.dig_shadow,
	is_ground_content = true,
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("underch:leafstone", {
	description = "Leafstone",
	tiles = {"underch_leafstone.png"},
	groups = {cracky = 3, stone = 1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("underch:light_leafstone", {
	description = "Light Leafstone",
	tiles = {"underch_light_leafstone.png"},
	groups = {cracky = 3, stone = 1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("underch:goldstone", {
	description = "Goldstone",
	tiles = {"underch_goldstone.png"},
	groups = {cracky = 3, stone = 1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

-- Sichamine

--[[minetest.register_node("underch:sichamine", {
	description = "Sichamine",
	tiles = {"underch_sichamine.png"},
	groups = {cracky = 3, stone = 1},
	is_ground_content = true,
	sounds = default.node_sound_stone_defaults(),
})--]]

minetest.register_node("underch:dark_sichamine", {
	description = "Dark Sichamine",
	tiles = {"underch_dark_sichamine.png"},
	groups = {cracky = 3, stone = 1, jit_shadow = 1},
	after_dig_node = underch.jit.dig_shadow,
	is_ground_content = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("underch:weedy_sichamine", {
	description = "Weedy Sichamine",
	tiles = {"underch_weedy_sichamine.png"},
	groups = {cracky = 3, stone = 1, jit_shadow = 1},
	after_dig_node = underch.jit.dig_shadow,
	is_ground_content = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("underch:sichamine_lamp", {
	description = "Sichamine Lamp",
	tiles = {"underch_sichamine_lamp.png"},
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = true,
	groups = {cracky = 3, oddly_breakable_by_hand = 3, jit_shadow = 1},
	after_dig_node = underch.jit.dig_shadow,
	sounds = default.node_sound_glass_defaults(),
	light_source = default.LIGHT_MAX,
})

-- Hektorite

--[[minetest.register_node("underch:hektorite", {
	description = "Hektorite",
	tiles = {"underch_hektorite.png"},
	groups = {cracky = 3, stone = 1},
	is_ground_content = true,
	sounds = default.node_sound_stone_defaults(),
})--]]

-- Deep underground

--[[minetest.register_node("underch:basalt", {
	description = "Basalt",
	tiles = {"underch_basalt.png"},
	groups = {cracky = 3, stone = 1},
	legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})--]]

minetest.register_node("underch:malachite", {
	description = "Malachite",
	tiles = {"underch_malachite.png"},
	groups = {cracky = 3, jit_shadow = 1},
	after_dig_node = underch.jit.dig_shadow,
	legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("underch:obscurite", {
	description = "Obscurite",
	tiles = {"underch_obscurite.png"},
	groups = {jit_shadow = 1},
	after_dig_node = underch.jit.dig_shadow,
	legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("underch:shinestone", {
	description = "Shinestone",
	tiles = {"underch_shinestone.png"},
	groups = {cracky = 3, jit_shadow = 1},
	after_dig_node = underch.jit.dig_shadow,
	legacy_mineral = true,
	light_source = default.LIGHT_MAX,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("underch:lava_crack", {
	description = "Lava Crack",
	tiles = {"underch_omphyrite.png^underch_lava_crack.png"},
	groups = {cracky = 3, jit_shadow = 1},
	drop = 'underch:omphyrite_cobble',
	legacy_mineral = true,
	light_source = 12,
	sounds = default.node_sound_stone_defaults(),
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		minetest.place_node(pos, {name="default:lava_source"}, digger)
		underch.jit.dig_shadow(pos, oldnode, oldmetadata, digger)
	end,
})

-- Vindesite

--[[minetest.register_node("underch:vindesite", {
	description = "Vindesite",
	tiles = {"underch_vindesite.png"},
	groups = {cracky = 3, stone = 1, vindesite = 1},
	legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("underch:dark_vindesite", {
	description = "Dark Vindesite",
	tiles = {"underch_dark_vindesite.png"},
	groups = {cracky = 3, stone = 1, vindesite = 1},
	legacy_mineral = true,
	sounds = default.node_sound_stone_defaults(),
})--]]

minetest.register_node("underch:burner", {
	description = "Burner",
	tiles = {"underch_burner.png"},
	groups = {cracky = 3, igniter = 4, jit_shadow = 1},
	legacy_mineral = true,
	after_destruct = underch.functions.remove_permanent_fire,
	after_dig_node = underch.jit.dig_shadow,
	on_ignite = underch.functions.make_permanent_fire,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("underch:vindesite_quartz_ore", {
	description = "Vindesite Quartz Ore",
	tiles = {"underch_vindesite.png^underch_quartz_ore.png"},
	groups = {cracky=2, jit_shadow = 1},
	after_dig_node = underch.jit.dig_shadow,
	drop = "underch:quartz",
	sounds = default.node_sound_stone_defaults(),
})

-- Foliage

minetest.register_node("underch:fiery_vine", {
	description = "Fiery Vine",
	drawtype = "signlike",
	tiles = {"underch_fiery_vine.png"},
	inventory_image = "underch_fiery_vine.png",
	wield_image = "underch_fiery_vine.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	climbable = true,
	is_ground_content = false,
	selection_box = {
		type = "wallmounted",
	},
	groups = {choppy = 3, oddly_breakable_by_hand = 1, hot = 1},
	legacy_wallmounted = true,
	light_source = 8,
	sounds = default.node_sound_leaves_defaults(),
	damage_per_second = 1 * underch.damage_scaling_factor,
})

minetest.register_node("underch:underground_vine", {
	description = "Underground Vine",
	drawtype = "signlike",
	tiles = {"underch_underground_vine.png"},
	inventory_image = "underch_underground_vine.png",
	wield_image = "underch_underground_vine.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	climbable = true,
	is_ground_content = false,
	selection_box = {
		type = "wallmounted",
	},
	groups = {choppy = 3, oddly_breakable_by_hand = 1},
	legacy_wallmounted = true,
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("underch:mould", {
	description = "Mould",
	drawtype = "signlike",
	tiles = {"underch_mould.png"},
	inventory_image = "underch_mould.png",
	wield_image = "underch_mould.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	is_ground_content = false,
	buildable_to = true,
	selection_box = {
		type = "wallmounted",
	},
	groups = {oddly_breakable_by_hand = 3},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("underch:moss", {
	description = "Moss",
	drawtype = "signlike",
	tiles = {"underch_moss.png"},
	inventory_image = "underch_moss.png",
	wield_image = "underch_moss.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	is_ground_content = false,
	buildable_to = true,
	selection_box = {
		type = "wallmounted",
	},
	groups = {oddly_breakable_by_hand = 3},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("underch:dry_moss", {
	description = "Dry Moss",
	drawtype = "signlike",
	tiles = {"underch_dry_moss.png"},
	inventory_image = "underch_dry_moss.png",
	wield_image = "underch_dry_moss.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	is_ground_content = false,
	buildable_to = true,
	selection_box = {
		type = "wallmounted",
	},
	groups = {oddly_breakable_by_hand = 3},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("underch:dead_bush", {
	description = "Underground Dead Bush",
	tiles = {"underch_underground_dead_bush.png"},
	inventory_image = "underch_underground_dead_bush.png",
	wield_image = "underch_underground_dead_bush.png",
	drawtype = "plantlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	groups = {snappy = 3, attached_node = 1, flammable = 1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, 5 / 16, 6 / 16},
	}
})

minetest.register_node("underch:torchberries", {
	description = "Torchberries",
	tiles = {"underch_torchberries.png"},
	inventory_image = "underch_torchberries.png",
	wield_image = "underch_torchberries.png",
	drawtype = "plantlike",
	paramtype = "light",
	paramtype2 = "wallmounted",
	legacy_wallmounted = true,
	sunlight_propagates = true,
	walkable = false,
	groups = {snappy = 3, flammable = 1},
	sounds = default.node_sound_leaves_defaults(),
	light_source = 8,
	selection_box = {
		type = "fixed",
		fixed = {-6 / 16, -5 / 16, -6 / 16, 6 / 16, 0.5, 6 / 16},
	}
})

minetest.register_node("underch:underground_bush", {
	description = "Underground Bush",
	drawtype = "allfaces",
	waving = 1,
	tiles = {"underch_underground_bush.png"},
	special_tiles = {"underch_underground_bush.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {snappy = 3, flammable = 2},
	sounds = default.node_sound_leaves_defaults(),
})

-- Other

minetest.register_node("underch:dust", {
	description = "Dust",
	tiles = {"underch_dust.png"},
	groups = {crumbly = 2, falling_node = 1},
	is_ground_content = true,
	sounds = default.node_sound_sand_defaults(),
})

minetest.register_node("underch:fiery_dust", {
	description = "Fiery Dust",
	tiles = {"underch_fiery_dust.png"},
	groups = {crumbly = 2, hot = 1, falling_node = 1},
	is_ground_content = true,
	after_destruct = underch.functions.remove_permanent_fire,
	on_ignite = underch.functions.make_permanent_fire,
	light_source = 10,
	sounds = default.node_sound_sand_defaults(),
})

minetest.register_node("underch:coal_dust", {
	description = "Coal Dust",
	tiles = {"underch_coal_dust.png"},
	groups = {crumbly = 2, falling_node = 1, flammable = 1},
	is_ground_content = false,
	sounds = default.node_sound_sand_defaults(),
})

minetest.register_node("underch:coal_diamond", {
	description = "Diamond Ore in Coal Block",
	tiles = {"default_coal_block.png^default_mineral_diamond.png"},
	is_ground_content = false,
	groups = {cracky = 1, jit_shadow = 1},
	after_destruct = underch.functions.remove_permanent_fire,
	after_dig_node = underch.jit.dig_shadow,
	on_ignite = underch.functions.make_permanent_fire,
	drop = {
		items = {{items = {"default:coal_lump 8", "default:diamond"}}}
	},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("underch:ruby_dust", {
	description = "Ruby Dust",
	tiles = {"underch_ruby_dust.png"},
	groups = {crumbly = 2, falling_node = 1},
	is_ground_content = false,
	sounds = default.node_sound_sand_defaults(),
})
