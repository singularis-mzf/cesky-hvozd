local depends, default_sounds =  ...
local S = minetest.get_translator("christmas_decor")

minetest.register_craftitem("christmas_decor:led_red", {
	description = S("Red Led Light"),
	inventory_image = "christmas_decor_led_red.png",
	groups = {led_light_red = 1, led_light = 1, led_light_rgb = 1},
})

minetest.register_craftitem("christmas_decor:led_green", {
	description = S("Green Led Light"),
	inventory_image = "christmas_decor_led_green.png",
	groups = {led_light = 1, led_light_green = 1, led_light_rgb = 1},
})

minetest.register_craftitem("christmas_decor:led_blue", {
	description = S("Blue Led Light"),
	inventory_image = "christmas_decor_led_blue.png",
	groups = {led_light = 1, led_light_blue = 1, led_light_rgb = 1},
})

minetest.register_craftitem("christmas_decor:led_white", {
	description = S("White Led Light"),
	inventory_image = "christmas_decor_led_white.png",
	groups = {led_light = 1, led_light_white = 1},
})

minetest.register_craft({
	output = "christmas_decor:led_white",
	type = "shapeless",
	recipe = {"christmas_decor:led_red", "christmas_decor:led_green", "christmas_decor:led_blue"},
})

minetest.register_craftitem("christmas_decor:wire", {
	description = S("Wire"),
	inventory_image = "christmas_decor_wire.png",
})

if depends.basic_materials and depends.dye and depends.default then
	for i, color in ipairs({"red", "green", "blue"}) do
		minetest.register_craft({
			output = "christmas_decor:led_"..color.." 8",
			recipe = {
				{"default:glass", "dye:"..color, ""},
				{"basic_materials:energy_crystal_simple", "", ""},
				{"basic_materials:plastic_sheet", "", ""},
			},
		})
	end

	minetest.register_craft({
		output = "christmas_decor:wire 16",
		recipe = {
			{"basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet"},
			{"basic_materials:copper_strip", "basic_materials:copper_strip", "basic_materials:copper_strip"},
			{"basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet"},
		},
	})
end

local function register_lights(desc, nodename, aspect, length)
	minetest.register_node("christmas_decor:lights_" .. nodename, {
		description = S(desc .. " Christmas Lights"),
		tiles = {
			{
				name = "christmas_decor_lights_" .. nodename .. "_inv.png",
				backface_culling = false,
			}
		},
		inventory_image = "christmas_decor_lights_" .. nodename .. "_inv.png",
		wield_image = "christmas_decor_lights_" .. nodename .. "_inv.png",
		sunlight_propagates = true,
		walkable = false,
		climbable = false,
		is_ground_content = false,
		selection_box = {
			type = "wallmounted",
		},
		legacy_wallmounted = true,
		use_texture_alpha = "blend",
		drawtype = "signlike",
		paramtype = "light",
		light_source = 10,
		paramtype2 = "wallmounted",
		connects_to = {"group:christmas_lights"},
		groups = {snappy = 3, christmas_lights = 1},
		sounds = default_sounds("node_sound_leaves_defaults"),
	})

	if not depends.xpanes then return end
	local tileFX = {
		name = "christmas_decor_lights_" .. nodename .. "_inv.png^[transformFX",
		backface_culling = false,
	}

	local tile = {
		name = "christmas_decor_lights_" .. nodename .. "_inv.png",
		backface_culling = false,
	}

	xpanes.register_pane("lights_" .. nodename .. "_pane", {
		description = S(desc .. " Christmas Lights (pane)"),
		textures = {},
		use_texture_alpha = "blend",
		groups = {snappy = 3},
		sounds = default_sounds("node_sound_leaves_defaults"),
		recipe = {
			{"christmas_decor:lights_" .. nodename, "christmas_decor:lights_" .. nodename, "christmas_decor:lights_" .. nodename},
			{"christmas_decor:lights_" .. nodename, "christmas_decor:lights_" .. nodename, "christmas_decor:lights_" .. nodename},
			{"christmas_decor:lights_" .. nodename, "christmas_decor:lights_" .. nodename, "christmas_decor:lights_" .. nodename},
		}
	})

	minetest.override_item("xpanes:lights_" .. nodename .. "_pane", {
		tiles = {"blank.png", "blank.png", tile, tileFX, tileFX, tile},
		walkable = false,
		light_source = 10,
	})

	minetest.override_item("xpanes:lights_" .. nodename .. "_pane_flat", {
		tiles = {"blank.png", "blank.png", tile, tile, tileFX, tile},
		walkable = false,
		light_source = 10,
	})

	--[[
	minetest.register_craft({
		output = "xpanes:lights_" .. nodename .. "_pane_flat 6",
		recipe = {
			{"christmas_decor:lights_" .. nodename, "christmas_decor:lights_" .. nodename, "christmas_decor:lights_" .. nodename},
			{"christmas_decor:lights_" .. nodename, "christmas_decor:lights_" .. nodename, "christmas_decor:lights_" .. nodename}
		}
	}) ]]
end

register_lights("White", "white", 16, 6)
register_lights("White Icicle", "white_icicle", 16, 6)
register_lights("Multicolor", "multicolor", 16, 6)
register_lights("Multicolor Bulb", "multicolor_bulb", 8, 3)

minetest.register_craft({
	output = "christmas_decor:lights_white 6",
	recipe = {
		{"christmas_decor:led_white", "christmas_decor:led_white", "christmas_decor:led_white"},
		{"christmas_decor:wire", "christmas_decor:wire", "christmas_decor:wire"},
		{"christmas_decor:led_white", "christmas_decor:led_white", "christmas_decor:led_white"},
	},
})

minetest.register_craft({
	output = "christmas_decor:lights_white_icicle 6",
	recipe = {
		{"christmas_decor:wire", "christmas_decor:wire", "christmas_decor:wire"},
		{"christmas_decor:led_white", "christmas_decor:led_white", "christmas_decor:led_white"},
		{"", "", ""},
	},
})

minetest.register_craft({
	output = "christmas_decor:lights_multicolor 6",
	recipe = {
		{"christmas_decor:led_red", "christmas_decor:led_green", "christmas_decor:led_blue"},
		{"christmas_decor:wire", "christmas_decor:wire", "christmas_decor:wire"},
		{"christmas_decor:led_blue", "christmas_decor:led_green", "christmas_decor:led_red"},
	},
})

minetest.register_craft({
	output = "christmas_decor:lights_multicolor_bulb 6",
	recipe = {
		{"group:led_light_rgb", "default:glass", "group:led_light_rgb"},
		{"christmas_decor:wire", "christmas_decor:wire", "christmas_decor:wire"},
		{"group:led_light_rgb", "default:glass", "group:led_light_rgb"},
	},
})

minetest.register_node("christmas_decor:garland", {
	description = S("Garland"),
	tiles = {"christmas_decor_garland.png"},
	inventory_image = "christmas_decor_garland.png",
	wield_image = "christmas_decor_garland.png",
	sunlight_propagates = true,
	walkable = false,
	climbable = false,
	is_ground_content = false,
	selection_box = {
		type = "wallmounted",
	},
	legacy_wallmounted = true,
	use_texture_alpha = "blend",
	drawtype = "signlike",
	paramtype = "light",
	paramtype2 = "wallmounted",
	groups = {snappy = 3},
	sounds = default_sounds("node_sound_leaves_defaults"),
})

minetest.register_node("christmas_decor:garland_lights", {
	description = S("Garland with Lights"),
	tiles = {
		{
			name = "christmas_decor_garland_lights.png",
			backface_culling = false,
		}
	},
	inventory_image = "christmas_decor_garland_lights_inv.png",
	wield_image = "christmas_decor_garland_lights_inv.png",
	sunlight_propagates = true,
	walkable = false,
	climbable = false,
	is_ground_content = false,
	selection_box = {
		type = "wallmounted",
	},
	legacy_wallmounted = true,
	use_texture_alpha = "blend",
	drawtype = "signlike",
	paramtype = "light",
	light_source = 8,
	paramtype2 = "wallmounted",
	groups = {snappy = 3},
	sounds = default_sounds("node_sound_leaves_defaults"),
})

if depends.default then
	minetest.register_craft({
		output = "christmas_decor:garland 3",
		recipe = {
			{"default:pine_needles", "default:pine_needles", "default:pine_needles"},
		},
	})
end

minetest.register_craft({
	output = "christmas_decor:garland_lights",
	type = "shapeless",
	recipe = {"christmas_decor:garland", "christmas_decor:led_white", "christmas_decor:led_white", "christmas_decor:led_white"},
})
