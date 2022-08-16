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
local stairway_groups = {cracky = 2, ud_param2_colorable = 1}

local function enhance(def)
	def.paramtype2 = "colorwallmounted"
	def.palette = "unifieddyes_palette_colorwallmounted.png"
	def.on_dig = unifieddyes.on_dig
	return def
end

local function enhance_extended(def)
	def.paramtype2 = "color"
	def.palette = "unifieddyes_palette_extended.png"
	def.on_dig = unifieddyes.on_dig
	return def
end

minetest.register_node("techpack_stairway:grating", enhance({
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
}))

minetest.register_node("techpack_stairway:handrail1", enhance({
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
}))

minetest.register_node("techpack_stairway:handrail2", enhance({
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
}))

minetest.register_node("techpack_stairway:handrail3", enhance({
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
}))

minetest.register_node("techpack_stairway:handrail4", enhance({
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
}))

minetest.register_node("techpack_stairway:bridge1", enhance({
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
}))

minetest.register_node("techpack_stairway:bridge2", enhance({
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
}))

minetest.register_node("techpack_stairway:bridge3", enhance({
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
}))

minetest.register_node("techpack_stairway:bridge4", enhance({
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
}))

minetest.register_node("techpack_stairway:stairway", {
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

minetest.register_node("techpack_stairway:ladder1", enhance({
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
}))

minetest.register_node("techpack_stairway:ladder2", enhance({
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
}))

minetest.register_node("techpack_stairway:ladder3", enhance({
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
}))

minetest.register_node("techpack_stairway:ladder4", enhance({
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
}))


minetest.register_node("techpack_stairway:lattice", enhance_extended({
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
}))

local def = {
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
	paramtype2 = "colorfacedir",
	palette = "unifieddyes_palette_greys.png",
	airbrush_replacement_node = "techpack_stairway:lattice_slop_grey",
	on_dig = unifieddyes.on_dig,

	sunlight_propagates = true,
	is_ground_content = false,
	groups = stairway_groups,
	sounds = default.node_sound_metal_defaults(),
}
minetest.register_node("techpack_stairway:lattice_slop_grey", def)
def = table.copy(def)
def.groups = table.copy(def.groups)
def.groups.not_in_creative_inventory = 1
unifieddyes.generate_split_palette_nodes("techpack_stairway:lattice_slop", table.copy(def), nil)


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
