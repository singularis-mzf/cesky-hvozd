--[[

	TechPack Stairway
	=================

	Copyright (C) 2019-2020 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information
	
	init.lua

]]--

local S = minetest.get_translator("techpack_stairway")
local CLIP = "clip"
local stairway_groups = {cracky = 2}

local function register_node(mode, nodename, def)
	if mode == "simple" then
		return minetest.register_node(nodename, def)
	elseif mode == "4dir" then
		def.paramtype2 = "color4dir"
		def.palette = "unifieddyes_palette_color4dir.png"
		def.groups = def.groups and table.copy(def.groups) or {}
		def.groups.ud_param2_colorable = 1
		def.on_dig = unifieddyes.on_dig
		minetest.register_node(nodename, def)
		return
	elseif mode == "split" then
		def.paramtype2 = "colorfacedir"
		def.palette = "unifieddyes_palette_greys.png"
		def.airbrush_replacement_node = nodename.."_grey"
		def.groups = def.groups and table.copy(def.groups) or {}
		def.groups.ud_param2_colorable = 1
		def.on_dig = unifieddyes.on_dig
		def.groups.not_in_creative_inventory = 1
		unifieddyes.generate_split_palette_nodes(nodename, def)
		minetest.register_alias(nodename, nodename.."_grey")
		def.groups.not_in_creative_inventory = nil
		minetest.override_item(nodename.."_grey", {groups = def.groups})
		return
	elseif mode == "extended" then
		def.paramtype2 = "color"
		def.palette = "unifieddyes_palette_extended.png"
		def.groups = def.groups and table.copy(def.groups) or {}
		def.groups.ud_param2_colorable = 1
		def.on_dig = unifieddyes.on_dig
		return minetest.register_node(nodename, def)
	else
		error("Unknown mode '"..mode.."'!")
	end
end

register_node("4dir", "techpack_stairway:grating", {
	description = S("TechPack Grating"),
	tiles = {
		'techpack_stairway_bottom.png',
		'techpack_stairway_bottom.png',
		'techpack_stairway_side.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-17/32, -15/32, -17/32,  17/32, -14/32, 17/32}
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {
			{-16/32, -16/32, -16/32,  16/32, -10/32, 16/32},
		},
	},
	
	--climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = stairway_groups,
	sounds = default.node_sound_metal_defaults(),
})

register_node("4dir", "techpack_stairway:handrail1", {
	description = S("TechPack Handrail 1"),
	tiles = {
		'techpack_stairway_bottom.png',
		'techpack_stairway_bottom.png',
		'techpack_stairway_side.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-17/32, -17/32, -17/32, -15/32,  17/32, 17/32},
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {
			{ -16/32, -16/32, -16/32, -12/32, -6/32, 16/32},
		},
	},
	
	--climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = stairway_groups,
	sounds = default.node_sound_metal_defaults(),
})

register_node("4dir", "techpack_stairway:handrail2", {
	description = S("TechPack Handrail 2"),
	tiles = {
		'techpack_stairway_bottom.png',
		'techpack_stairway_bottom.png',
		'techpack_stairway_side.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ 15/32, -17/32, -17/32,  17/32,  17/32, 17/32},
			{-17/32, -17/32, -17/32, -15/32,  17/32, 17/32},
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {
			{ 12/32, -16/32, -16/32,  16/32,  -6/32, 16/32},
			{-16/32, -16/32, -16/32, -12/32,  -6/32, 16/32},
		},
	},
	
	--climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = stairway_groups,
	sounds = default.node_sound_metal_defaults(),
})

register_node("4dir", "techpack_stairway:handrail3", {
	description = S("TechPack Handrail 3"),
	tiles = {
		'techpack_stairway_bottom.png',
		'techpack_stairway_bottom.png',
		'techpack_stairway_side.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-17/32, -17/32,  15/32,  17/32,  17/32, 17/32},
			{-17/32, -17/32, -17/32, -15/32,  17/32, 17/32},
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {
			{ -16/32, -16/32,  12/32,  16/32, -6/32, 16/32},
			{ -16/32, -16/32, -16/32, -12/32, -6/32, 16/32},
		},
	},
	
	--climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = stairway_groups,
	sounds = default.node_sound_metal_defaults(),
})

register_node("4dir", "techpack_stairway:handrail4", {
	description = S("TechPack Handrail 4"),
	tiles = {
		'techpack_stairway_bottom.png',
		'techpack_stairway_bottom.png',
		'techpack_stairway_side.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-17/32, -17/32,  15/32,  17/32,  17/32, 17/32},
			{ 15/32, -17/32, -17/32,  17/32,  17/32, 17/32},
			{-17/32, -17/32, -17/32, -15/32,  17/32, 17/32},
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {
			{ 12/32, -16/32, -16/32,  16/32, -6/32, 16/32},
			{-16/32, -16/32, -16/32, -12/32, -6/32, 16/32},
			{-16/32, -16/32,  12/32,  16/32, -6/32, 16/32},
		},
	},
	
	--climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = stairway_groups,
	sounds = default.node_sound_metal_defaults(),
})

register_node("4dir", "techpack_stairway:bridge1", {
	description = S("TechPack Bridge 1"),
	tiles = {
		'techpack_stairway_bottom.png',
		'techpack_stairway_bottom.png',
		'techpack_stairway_side.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-17/32, -17/32, -17/32, -15/32,  17/32, 17/32},
			{-17/32, -15/32, -17/32,  17/32, -14/32, 17/32}
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {
			{-16/32, -16/32, -16/32,  16/32, -10/32, 16/32},
		},
	},

	--climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = stairway_groups,
	sounds = default.node_sound_metal_defaults(),
})

register_node("4dir", "techpack_stairway:bridge2", {
	description = S("TechPack Bridge 2"),
	tiles = {
		'techpack_stairway_bottom.png',
		'techpack_stairway_bottom.png',
		'techpack_stairway_side.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ 15/32, -17/32, -17/32,  17/32,  17/32, 17/32},
			{-17/32, -17/32, -17/32, -15/32,  17/32, 17/32},
			{-17/32, -15/32, -17/32,  17/32, -14/32, 17/32}
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {
			{-16/32, -16/32, -16/32,  16/32, -10/32, 16/32},
		},
	},

	--climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = stairway_groups,
	sounds = default.node_sound_metal_defaults(),
})

register_node("4dir", "techpack_stairway:bridge3", {
	description = S("TechPack Bridge 3"),
	tiles = {
		'techpack_stairway_bottom.png',
		'techpack_stairway_bottom.png',
		'techpack_stairway_side.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-17/32, -17/32,  15/32,  17/32,  17/32, 17/32},
			{-17/32, -17/32, -17/32, -15/32,  17/32, 17/32},
			{-17/32, -15/32, -17/32,  17/32, -14/32, 17/32}
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {
			{-16/32, -16/32, -16/32,  16/32, -10/32, 16/32},
		},
	},
	
	--climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = stairway_groups,
	sounds = default.node_sound_metal_defaults(),
})

register_node("4dir", "techpack_stairway:bridge4", {
	description = S("TechPack Bridge 4"),
	tiles = {
		'techpack_stairway_bottom.png',
		'techpack_stairway_bottom.png',
		'techpack_stairway_side.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-17/32, -17/32,  15/32,  17/32,  17/32, 17/32},
			{ 15/32, -17/32, -17/32,  17/32,  17/32, 17/32},
			{-17/32, -17/32, -17/32, -15/32,  17/32, 17/32},
			{-17/32, -15/32, -17/32,  17/32, -14/32, 17/32}
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {
			{-16/32, -16/32, -16/32,  16/32, -10/32, 16/32},
		},
	},
	
	--climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = stairway_groups,
	sounds = default.node_sound_metal_defaults(),
})

register_node("4dir", "techpack_stairway:stairway", {
	description = S("TechPack Stairway"),
	tiles = {
		'techpack_stairway_steps.png',
		'techpack_stairway_steps.png',
		'techpack_stairway_side.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ 15/32, -1/32,  -1/32,  17/32,  49/32, 17/32},
			{-17/32, -1/32,  -1/32, -15/32,  49/32, 17/32},
			{-17/32, -1/32,  -1/32,  17/32,   1/32, 17/32},
			
			{ 15/32, -17/32, -17/32,  17/32,  33/32, 1/32},
			{-17/32, -17/32, -17/32, -15/32,  33/32, 1/32},
			{-17/32, -17/32, -17/32,  17/32, -15/32, 1/32},
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {
			{-16/32, -16/32, -16/32,  16/32, -10/32,  0/32},
			{-16/32, -16/32,   0/32,  16/32,   2/32, 16/32},
		},
	},
		
	--climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = stairway_groups,
	sounds = default.node_sound_metal_defaults(),
})

register_node("4dir", "techpack_stairway:ladder1", {
	description = S("TechPack Ladder 1"),
	tiles = {
		'techpack_stairway_steps.png',
		'techpack_stairway_steps.png',
		'techpack_stairway_ladder.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-17/32, -17/32,  15/32,  17/32,  17/32,  17/32},
			{-17/32, -17/32, -17/32, -15/32,  17/32,  17/32},
			{-17/32, -17/32, -17/32,  17/32,  17/32, -15/32},
			{ 15/32, -17/32, -17/32,  17/32,  17/32,  17/32},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {-8/16, -8/16, -8/16,  8/16, 8/16, 8/16},
	},

	climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = stairway_groups,
	sounds = default.node_sound_metal_defaults(),
})

register_node("4dir", "techpack_stairway:ladder2", {
	description = S("TechPack Ladder 2"),
	tiles = {
		'techpack_stairway_steps.png',
		'techpack_stairway_steps.png',
		'techpack_stairway_ladder.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-17/32, -17/32,  15/32,  17/32,  17/32,  17/32},
			{-17/32, -17/32, -17/32, -15/32,  17/32,  17/32},
			--{-17/32, -17/32, -17/32,  17/32,  17/32, -15/32},
			{ 15/32, -17/32, -17/32,  17/32,  17/32,  17/32},
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {-8/16, -8/16, -8/16,  8/16, 8/16, 8/16},
	},

	climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = stairway_groups,
	sounds = default.node_sound_metal_defaults(),
})

register_node("4dir", "techpack_stairway:ladder3", {
    description = S("TechPack Ladder 3"),
    tiles = {
        'techpack_stairway_steps.png',
        'techpack_stairway_steps.png',
        'techpack_stairway_ladder.png',
    },
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {
            {-17/32, -17/32,  15/32,  17/32,  17/32,  17/32},
            --{-17/32, -17/32, -17/32, -15/32,  17/32,  17/32},
            --{-17/32, -17/32, -17/32,  17/32,  17/32, -15/32},
            { 15/32, -17/32, -17/32,  17/32,  17/32,  17/32},
        },
    },

    selection_box = {
        type = "fixed",
        fixed = {-8/16, -8/16, -8/16,  8/16, 8/16, 8/16},
    },

    climbable = true,
    paramtype2 = "facedir",
    paramtype = "light",
	use_texture_alpha = CLIP,
    sunlight_propagates = true,
    is_ground_content = false,
    groups = stairway_groups,
    sounds = default.node_sound_metal_defaults(),
})

register_node("4dir", "techpack_stairway:ladder4", {
	description = S("TechPack Ladder 4"),
	tiles = {
		'techpack_stairway_ladder.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
            {-17/32, -17/32,  15/32,  17/32,  17/32,  17/32},
            --{-17/32, -17/32, -17/32, -15/32,  17/32,  17/32},
            --{-17/32, -17/32, -17/32,  17/32,  17/32, -15/32},
            --{ 15/32, -17/32, -17/32,  17/32,  17/32,  17/32},
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {-8/16, -8/16, 6/16,  8/16, 8/16, 8/16},
	},
	
	climbable = true,
	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = stairway_groups,
	sounds = default.node_sound_metal_defaults(),
})

register_node("extended", "techpack_stairway:lattice", {
	description = S("TechPack Lattice"),
	tiles = {
		'techpack_stairway_lattice.png',
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, -7/16,  8/16,  8/16},
			{ 7/16, -8/16, -8/16,  8/16,  8/16,  8/16},
			{-8/16, -8/16, -8/16,  8/16, -7/16,  8/16},
			{-8/16,  7/16, -8/16,  8/16,  8/16,  8/16},
			{-8/16, -8/16, -8/16,  8/16,  8/16, -7/16},
			{-8/16, -8/16,  7/16,  8/16,  8/16,  8/16},
		},
	},

	selection_box = {
		type = "fixed",
		fixed = {-8/16, -8/16, -8/16,  8/16, 8/16, 8/16},
	},

	paramtype2 = "facedir",
	paramtype = "light",
	use_texture_alpha = CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = stairway_groups,
	sounds = default.node_sound_metal_defaults(),
})

register_node("split", "techpack_stairway:lattice_slop", {
	description = S("TechPack Lattice Slope"),
	tiles = {'techpack_stairway_lattice.png'},
	use_texture_alpha = CLIP,
	drawtype = "mesh",
	mesh="techpack_stairway_slope.obj",
	selection_box = {
		type = "fixed",
		fixed = {
			{-8/16,  4/16,  4/16,  8/16,  8/16, 8/16},
		    {-8/16,  0/16,  0/16,  8/16,  4/16, 8/16},
		    {-8/16, -4/16, -4/16,  8/16,  0/16, 8/16},
		    {-8/16, -8/16, -8/16,  8/16, -4/16, 8/16},
		},
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-8/16,  4/16,  4/16,  8/16,  8/16, 8/16},
		    {-8/16,  0/16,  0/16,  8/16,  4/16, 8/16},
		    {-8/16, -4/16, -4/16,  8/16,  0/16, 8/16},
		    {-8/16, -8/16, -8/16,  8/16, -4/16, 8/16},
		},
	},
	paramtype = "light",
	-- paramtype2 = "colorfacedir",

	sunlight_propagates = true,
	is_ground_content = false,
	groups = stairway_groups,
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_craft({
	output = "techpack_stairway:grating 6",
	recipe = {
		{"", "", ""},
		{"dye:dark_grey", "", "default:coal_lump"},
		{"default:steel_ingot", "default:tin_ingot", "default:steel_ingot"},
	},
})

minetest.register_craft({
	output = "techpack_stairway:handrail1 6",
	recipe = {
		{"default:steel_ingot", "default:coal_lump", ""},
		{"default:tin_ingot", "", ""},
		{"default:steel_ingot", "dye:dark_grey", ""},
	},
})

minetest.register_craft({
	output = "techpack_stairway:stairway 3",
	recipe = {
		{"", "", "default:steel_ingot"},
		{"dye:dark_grey", "default:tin_ingot", "default:coal_lump"},
		{"default:steel_ingot", "", ""},
	},
})

minetest.register_craft({
	output = "techpack_stairway:ladder1 3",
	recipe = {
		{"", "default:steel_ingot", ""},
		{"dye:dark_grey", "default:tin_ingot", "default:coal_lump"},
		{"", "default:steel_ingot", ""},
	},
})

minetest.register_craft({
	output = "techpack_stairway:ladder3 6",
	recipe = {
		{"", "", "default:steel_ingot"},
		{"dye:dark_grey", "default:tin_ingot", "default:coal_lump"},
		{"", "", "default:steel_ingot"},
	},
})

minetest.register_craft({
	output = "techpack_stairway:ladder4 12",
	recipe = {
		{"dye:dark_grey", "default:tin_ingot", "default:coal_lump"},
		{"", "default:steel_ingot", ""},
		{"", "default:steel_ingot", ""},
	},
})

minetest.register_craft({
	output = "techpack_stairway:lattice 4",
	recipe = {
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"dye:dark_grey", "default:tin_ingot", "default:coal_lump"},
		{"default:steel_ingot", "", "default:steel_ingot"},
	},
})

minetest.register_craft({
	output = "techpack_stairway:lattice_slop_grey 2",
	recipe = {{"techpack_stairway:lattice"}},
})

minetest.register_craft({
	output = "techpack_stairway:handrail2",
	recipe = {
		{"", "", ""},
		{"techpack_stairway:handrail1", "", "techpack_stairway:handrail1"},
		{"", "", ""},
	},
})

minetest.register_craft({
	output = "techpack_stairway:handrail3",
	recipe = {
		{"", "techpack_stairway:handrail1", ""},
		{"techpack_stairway:handrail1", "", ""},
		{"", "", ""},
	},
})

minetest.register_craft({
	output = "techpack_stairway:handrail4",
	recipe = {
		{"", "techpack_stairway:handrail1", ""},
		{"techpack_stairway:handrail1", "", "techpack_stairway:handrail1"},
		{"", "", ""},
	},
})

minetest.register_craft({
	output = "techpack_stairway:bridge1",
	recipe = {
		{"", "", ""},
		{"techpack_stairway:handrail1", "techpack_stairway:grating", ""},
		{"", "", ""},
	},
})

minetest.register_craft({
	output = "techpack_stairway:bridge2",
	recipe = {
		{"", "", ""},
		{"techpack_stairway:handrail1", "techpack_stairway:grating", "techpack_stairway:handrail1"},
		{"", "", ""},
	},
})

minetest.register_craft({
	output = "techpack_stairway:bridge3",
	recipe = {
		{"", "techpack_stairway:handrail1", ""},
		{"techpack_stairway:handrail1", "techpack_stairway:grating", ""},
		{"", "", ""},
	},
})

minetest.register_craft({
	output = "techpack_stairway:bridge4",
	recipe = {
		{"", "techpack_stairway:handrail1", ""},
		{"techpack_stairway:handrail1", "techpack_stairway:grating", "techpack_stairway:handrail1"},
		{"", "", ""},
	},
})

minetest.register_craft({
	output = "techpack_stairway:ladder2",
	recipe = {{"techpack_stairway:ladder1"}},
})

dofile(minetest.get_modpath("techpack_stairway").."/upgrade_lbm.lua")
