ch_base.open_mod(minetest.get_current_modname())
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
	assert(mode == "4dir")
	def.paramtype2 = "color4dir"
	def.palette = "unifieddyes_palette_color4dir.png"
	def.groups = def.groups and table.copy(def.groups) or {}
	def.groups.ud_param2_colorable = 1
	def.on_dig = unifieddyes.on_dig
	core.register_node(nodename, def)
end

local grating_border = 17/32

ch_core.register_nodes({
	description = S("TechPack Grating"),
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "color",
	palette = "unifieddyes_palette_extended.png",
	use_texture_alpha = CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	groups = ch_core.assembly_groups(stairway_groups, {not_in_creative_inventory = 1, ud_param2_colorable = 1}),
	sounds = default.node_sound_metal_defaults(),
	drop = {items = {{items = {"techpack_stairway:grating"}, inherit_color = true}}},
}, {
	["techpack_stairway:grating"] = { -- -Y
		tiles = {"techpack_stairway_bottom.png", "techpack_stairway_bottom.png", "techpack_stairway_side.png"},
		node_box = {type = "fixed", fixed = {-grating_border, -15/32, -grating_border,  grating_border, -14/32, grating_border}},
		selection_box = {type = "fixed", fixed = {-16/32, -16/32, -16/32,  16/32, -10/32, 16/32}},
		groups = ch_core.assembly_groups(stairway_groups, {not_in_creative_inventory = 0, ud_param2_colorable = 1}),
	},
	["techpack_stairway:grating_2"] = { -- -Z
		tiles = {"techpack_stairway_side.png",
			"techpack_stairway_side.png^[transformR180",
			"techpack_stairway_side.png^[transformR270",
			"techpack_stairway_side.png^[transformR90",
			"techpack_stairway_bottom.png",
			"techpack_stairway_bottom.png"},
		node_box = {type = "fixed", fixed = {-grating_border, -grating_border, -15/32,  grating_border, grating_border, -14/32}},
		selection_box = {type = "fixed", fixed = {-16/32, -16/32, -16/32,  16/32, 16/32, -10/32}},
	},
	["techpack_stairway:grating_3"] = { -- +Z
		tiles = {"techpack_stairway_side.png^[transformR180",
			"techpack_stairway_side.png",
			"techpack_stairway_side.png^[transformR90",
			"techpack_stairway_side.png^[transformR270",
			"techpack_stairway_bottom.png",
			"techpack_stairway_bottom.png"},
		node_box = {type = "fixed", fixed = {-grating_border, -grating_border, 14/32,  grating_border, grating_border, 15/32}},
		selection_box = {type = "fixed", fixed = {-16/32, -16/32, 10/32,  16/32, 16/32, 16/32}},
	},
	["techpack_stairway:grating_4"] = { -- -X
		tiles = {"techpack_stairway_side.png^[transformR270",
			"techpack_stairway_side.png^[transformR270",
			"techpack_stairway_bottom.png",
			"techpack_stairway_bottom.png",
			"techpack_stairway_side.png^[transformR90",
			"techpack_stairway_side.png^[transformR270"},
		node_box = {type = "fixed", fixed = {-15/32, -grating_border, -grating_border,  -14/32, grating_border, grating_border}},
		selection_box = {type = "fixed", fixed = {-16/32, -16/32, -16/32, -10/32, 16/32, 16/32}},
	},
	["techpack_stairway:grating_5"] = { -- +X
		tiles = {
			"techpack_stairway_side.png^[transformR90",
			"techpack_stairway_side.png^[transformR90",
			"techpack_stairway_bottom.png",
			"techpack_stairway_bottom.png",
			"techpack_stairway_side.png^[transformR270",
			"techpack_stairway_side.png^[transformR90"},
		node_box = {type = "fixed", fixed = {14/32, -grating_border, -grating_border,  15/32, grating_border, grating_border}},
		selection_box = {type = "fixed", fixed = {10/32, -16/32, -16/32, 16/32, 16/32, 16/32}},
	},
	["techpack_stairway:grating_6"] = { -- +Y
		tiles = {
			"techpack_stairway_bottom.png",
			"techpack_stairway_bottom.png",
			"techpack_stairway_side.png^[transformR180",
		},
		node_box = {type = "fixed", fixed = {-grating_border, 14/32, -grating_border,  grating_border, 15/32, grating_border}},
		selection_box = {type = "fixed", fixed = {-16/32, 10/32, -16/32,  16/32, 16/32, 16/32}},
	},
}, {
	{
		output = "techpack_stairway:grating 6",
		recipe = {
			{"", "", ""},
			{"dye:dark_grey", "", "default:coal_lump"},
			{"default:steel_ingot", "default:tin_ingot", "default:steel_ingot"},
		},
	}
})

local nodedir_group = {}
for i = 1, 6 do
	local name = "techpack_stairway:grating_"..i
	if i == 1 then name = "techpack_stairway:grating" end
	for j = (i - 1) * 4, (i * 4 - 1) do
		nodedir_group[j] = name
	end
end

ch_core.register_nodedir_group(nodedir_group)

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

local function generate_ladder_selection_box(sides)
	local s = sides -- front(-Z) back(+Z) left(-X) right(+X)
	local w = 2/16
	local result = {}
	-- horní a spodní traverzy:
	if s.front then
		table.insert(result, {-0.5, -0.5, -0.5, 0.5, -0.5 + w, -0.5 + w})
		table.insert(result, {-0.5, 0.5 - w, -0.5, 0.5, 0.5, -0.5 + w})
	end
	if s.back then
		table.insert(result, {-0.5, -0.5, 0.5 - w, 0.5, -0.5 + w, 0.5})
		table.insert(result, {-0.5, 0.5 - w, 0.5 - w, 0.5, 0.5, 0.5})
	end
	if s.left then
		table.insert(result, {-0.5, -0.5, -0.5, -0.5 + w, -0.5 + w, 0.5})
		table.insert(result, {-0.5, 0.5 - w, -0.5, -0.5 + w, 0.5, 0.5})
	end
	if s.right then
		table.insert(result, {0.5 - w, -0.5, -0.5, 0.5, -0.5 + w, 0.5})
		table.insert(result, {0.5 - w, 0.5 - w, -0.5, 0.5, 0.5, 0.5})
	end
	-- svislé tyče:
	if s.front or s.left then -- -Z -X
		table.insert(result, {-0.5, -0.5, -0.5, -0.5 + w, 0.5, -0.5 + w})
	end
	if s.front or s.right then -- -Z +X
		table.insert(result, {0.5 - w, -0.5, -0.5, 0.5, 0.5, -0.5 + w})
	end
	if s.back or s.left then -- +Z -X
		table.insert(result, {-0.5, -0.5, 0.5 - w, -0.5 + w, 0.5, 0.5})
	end
	if s.back or s.right then -- +Z +X
		table.insert(result, {0.5 - w, -0.5, 0.5 - w, 0.5, 0.5, 0.5})
	end
	assert(#result > 0)
	return {type = "fixed", fixed = result}
end

local collision_box_sides = {
	front = {-16/32, -16/32, -16/32, 16/32, 16/32,-15/32}, -- -Z
	back = {-16/32, -16/32,  15/32, 16/32, 16/32, 16/32}, -- +Z
	left = {-16/32, -16/32, -16/32,-15/32, 16/32, 16/32}, -- -X
	right = { 15/32, -16/32, -16/32, 16/32, 16/32, 16/32}, -- +X
}

local function generate_ladder_collision_box(sides)
	local result = {}
	for side, _ in pairs(sides) do
		local box = collision_box_sides[side]
		if box ~= nil then
			table.insert(result, box)
		end
	end
	assert(#result > 0)
	return {type = "fixed", fixed = result}
end

ch_core.register_nodes({
	drawtype = "nodebox",
	tiles = {
		'techpack_stairway_steps.png',
		'techpack_stairway_steps.png',
		'techpack_stairway_ladder.png',
	},
	use_texture_alpha = CLIP,
	paramtype = "light",
	paramtype2 = "color4dir",
	palette = "unifieddyes_palette_color4dir.png",
	sunlight_propagates = true,
	is_ground_content = false,
	climbable = true,
	groups = ch_core.assembly_groups(stairway_groups, {ud_param2_colorable = 1}),
	sounds = default.node_sound_metal_defaults(),
	on_dig = unifieddyes.on_dig,
}, {
	["techpack_stairway:ladder1"] = {
		description = S("TechPack Ladder 1"),
		collision_box = generate_ladder_collision_box({left = true, right = true, front = true, back = true}),
		selection_box = generate_ladder_selection_box({left = true, right = true, front = true, back = true}),
		node_box = {
			type = "fixed",
			fixed = {
				{-17/32, -17/32,  15/32,  17/32,  17/32,  17/32},
				{-17/32, -17/32, -17/32, -15/32,  17/32,  17/32},
				{-17/32, -17/32, -17/32,  17/32,  17/32, -15/32},
				{ 15/32, -17/32, -17/32,  17/32,  17/32,  17/32},
			},
		},
	},
	["techpack_stairway:ladder2"] = {
		description = S("TechPack Ladder 2"),
		collision_box = generate_ladder_collision_box({left = true, right = true, back = true}),
		selection_box = generate_ladder_selection_box({left = true, right = true, back = true}),
		node_box = {
			type = "fixed",
			fixed = {
				{-17/32, -17/32,  15/32,  17/32,  17/32,  17/32},
				{-17/32, -17/32, -17/32, -15/32,  17/32,  17/32},
				--{-17/32, -17/32, -17/32,  17/32,  17/32, -15/32},
				{ 15/32, -17/32, -17/32,  17/32,  17/32,  17/32},
			},
		},
	},
	["techpack_stairway:ladder3"] = {
		description = S("TechPack Ladder 3"),
		collision_box = generate_ladder_collision_box({right = true, back = true}),
		selection_box = generate_ladder_selection_box({right = true, back = true}),
		node_box = {
			type = "fixed",
			fixed = {
				{-17/32, -17/32,  15/32,  17/32,  17/32,  17/32},
				--{-17/32, -17/32, -17/32, -15/32,  17/32,  17/32},
				--{-17/32, -17/32, -17/32,  17/32,  17/32, -15/32},
				{ 15/32, -17/32, -17/32,  17/32,  17/32,  17/32},
			},
		},
	},
	["techpack_stairway:ladder4"] = {
		description = S("TechPack Ladder 4"),
		tiles = {'techpack_stairway_ladder.png'},
		collision_box = generate_ladder_collision_box({back = true}),
		selection_box = generate_ladder_selection_box({back = true}),
		node_box = {
			type = "fixed",
			fixed = {
				{-17/32, -17/32,  15/32,  17/32,  17/32,  17/32},
				--{-17/32, -17/32, -17/32, -15/32,  17/32,  17/32},
				--{-17/32, -17/32, -17/32,  17/32,  17/32, -15/32},
				--{ 15/32, -17/32, -17/32,  17/32,  17/32,  17/32},
			},
		},
		--[[
		selection_box = {
			type = "fixed",
			fixed = {-8/16, -8/16, 6/16,  8/16, 8/16, 8/16},
		}, ]]
	},
}, {
	{
		output = "techpack_stairway:ladder1 3",
		recipe = {
			{"", "default:steel_ingot", ""},
			{"dye:dark_grey", "default:tin_ingot", "default:coal_lump"},
			{"", "default:steel_ingot", ""},
		},
	}, {
		output = "techpack_stairway:ladder2",
		recipe = {{"techpack_stairway:ladder1"}},
	}, {
		output = "techpack_stairway:ladder3 6",
		recipe = {
			{"", "", "default:steel_ingot"},
			{"dye:dark_grey", "default:tin_ingot", "default:coal_lump"},
			{"", "", "default:steel_ingot"},
		},
	}, {
		output = "techpack_stairway:ladder4 12",
		recipe = {
			{"dye:dark_grey", "default:tin_ingot", "default:coal_lump"},
			{"", "default:steel_ingot", ""},
			{"", "default:steel_ingot", ""},
		},
	}
})

core.register_node("techpack_stairway:lattice", {
	description = S("TechPack Lattice"),
	tiles = {
		'techpack_stairway_lattice_colorable.png',
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

	paramtype = "light",
	paramtype2 = "color",
	palette  = "unifieddyes_palette_extended.png",
	groups = ch_core.assembly_groups(stairway_groups, {ud_param2_colorable = 1}),
	use_texture_alpha = CLIP,
	sunlight_propagates = true,
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),
	on_dig = unifieddyes.on_dig,
})


local function rot(fixed, facedir)
	if type(fixed[1]) == "table" then
		local result = {}
		for i, aabb in ipairs(fixed) do
			result[i] = ch_core.rotate_aabb_by_facedir(aabb, facedir)
		end
		return {type = "fixed", fixed = result}
	else
		return {type = "fixed", fixed = ch_core.rotate_aabb_by_facedir(fixed, facedir)}
	end
end

local slope_box_0 = { -- 0, 10
	type = "fixed",
	fixed = {
		{-8/16,  4/16,  4/16,  8/16,  8/16, 8/16},
		{-8/16,  0/16,  0/16,  8/16,  4/16, 8/16},
		{-8/16, -4/16, -4/16,  8/16,  0/16, 8/16},
		{-8/16, -8/16, -8/16,  8/16, -4/16, 8/16},
	},
}
local slope_box_1 = rot(slope_box_0.fixed, 1) -- 1, 19
local slope_box_2 = rot(slope_box_0.fixed, 2) -- 2, 4
local slope_box_3 = rot(slope_box_0.fixed, 3) -- 3, 13
local slope_box_5 = rot(slope_box_0.fixed, 5) -- 5, 18
local slope_box_6 = rot(slope_box_0.fixed, 6) -- 6, 22
local slope_box_7 = rot(slope_box_0.fixed, 7) -- 7, 14
local slope_box_8 = rot(slope_box_0.fixed, 8) -- 8, 20
local slope_box_9 = rot(slope_box_0.fixed, 9) -- 9, 16
local slope_box_11 = rot(slope_box_0.fixed, 11) -- 11, 12
local slope_box_15 = rot(slope_box_0.fixed, 15) -- 15, 21
local slope_box_17 = rot(slope_box_0.fixed, 17) -- 17, 23

--[[
local slope_box_20 = rot(slope_box_0.fixed, 20)
local slope_box_21 = rot(slope_box_0.fixed, 21)
local slope_box_22 = rot(slope_box_0.fixed, 22)
local slope_box_23 = rot(slope_box_0.fixed, 23)
]]

local slope_groups = ch_core.assembly_groups(stairway_groups, {
	ud_param2_colorable = 1,
	not_in_creative_inventory = 1,
	not_blocking_trains = 1,
})

ch_core.register_nodes({
	description = S("TechPack Lattice Slope"),
	tiles = {{name = "techpack_stairway_lattice_colorable.png"}},
	use_texture_alpha = CLIP,
	drawtype = "mesh",
	paramtype = "light",
	paramtype2 = "color",
	palette = "unifieddyes_palette_extended.png",

	sunlight_propagates = true,
	is_ground_content = false,
	groups = slope_groups,
	sounds = default.node_sound_metal_defaults(),
	drop = {items = {{items = {"techpack_stairway:lattice_slope_0"}, inherit_color = true}}},
	on_dig = unifieddyes.on_dig,
}, {
	["techpack_stairway:lattice_slope_0_10"] = {
		mesh = "techpack_stairway_slope_0_10.obj",
		selection_box = slope_box_0,
		collision_box = slope_box_0,
		groups = ch_core.assembly_groups(slope_groups, {not_in_creative_inventory = 0})
	},
	["techpack_stairway:lattice_slope_1_19"] = {
		mesh = "techpack_stairway_slope_1_19.obj",
		selection_box = slope_box_1,
		collision_box = slope_box_1,
	},
	["techpack_stairway:lattice_slope_2_4"] = {
		mesh = "techpack_stairway_slope_2_4.obj",
		selection_box = slope_box_2,
		collision_box = slope_box_2,
	},
	["techpack_stairway:lattice_slope_3_13"] = {
		mesh = "techpack_stairway_slope_3_13.obj",
		selection_box = slope_box_3,
		collision_box = slope_box_3,
	},
	["techpack_stairway:lattice_slope_5_18"] = {
		mesh = "techpack_stairway_slope_5_18.obj",
		selection_box = slope_box_5,
		collision_box = slope_box_5,
	},
	["techpack_stairway:lattice_slope_6_22"] = {
		mesh = "techpack_stairway_slope_6_22.obj",
		selection_box = slope_box_6,
		collision_box = slope_box_6,
	},
	["techpack_stairway:lattice_slope_7_14"] = {
		mesh = "techpack_stairway_slope_7_14.obj",
		selection_box = slope_box_7,
		collision_box = slope_box_7,
	},
	["techpack_stairway:lattice_slope_8_20"] = {
		mesh = "techpack_stairway_slope_8_20.obj",
		selection_box = slope_box_8,
		collision_box = slope_box_8,
	},
	["techpack_stairway:lattice_slope_9_16"] = {
		mesh = "techpack_stairway_slope_9_16.obj",
		selection_box = slope_box_9,
		collision_box = slope_box_9,
	},
	["techpack_stairway:lattice_slope_11_12"] = {
		mesh = "techpack_stairway_slope_11_12.obj",
		selection_box = slope_box_11,
		collision_box = slope_box_11,
	},
	["techpack_stairway:lattice_slope_15_21"] = {
		mesh = "techpack_stairway_slope_15_21.obj",
		selection_box = slope_box_15,
		collision_box = slope_box_15,
	},
	["techpack_stairway:lattice_slope_17_23"] = {
		mesh = "techpack_stairway_slope_17_23.obj",
		selection_box = slope_box_17,
		collision_box = slope_box_17,
	},
}, {
	{
		output = "techpack_stairway:handrail1 6",
		recipe = {
			{"default:steel_ingot", "default:coal_lump", ""},
			{"default:tin_ingot", "", ""},
			{"default:steel_ingot", "dye:dark_grey", ""},
		},
	}, {
		output = "techpack_stairway:stairway 3",
		recipe = {
			{"", "", "default:steel_ingot"},
			{"dye:dark_grey", "default:tin_ingot", "default:coal_lump"},
			{"default:steel_ingot", "", ""},
		},
	}, {
		output = "techpack_stairway:lattice 4",
		recipe = {
			{"default:steel_ingot", "", "default:steel_ingot"},
			{"dye:dark_grey", "default:tin_ingot", "default:coal_lump"},
			{"default:steel_ingot", "", "default:steel_ingot"},
		},
	}, {
		output = "techpack_stairway:lattice_slope_0 2",
		recipe = {{"techpack_stairway:lattice"}},
	}, {
		output = "techpack_stairway:handrail2",
		recipe = {
			{"", "", ""},
			{"techpack_stairway:handrail1", "", "techpack_stairway:handrail1"},
			{"", "", ""},
		},
	}, {
		output = "techpack_stairway:handrail3",
		recipe = {
			{"", "techpack_stairway:handrail1", ""},
			{"techpack_stairway:handrail1", "", ""},
			{"", "", ""},
		},
	}, {
		output = "techpack_stairway:handrail4",
		recipe = {
			{"", "techpack_stairway:handrail1", ""},
			{"techpack_stairway:handrail1", "", "techpack_stairway:handrail1"},
			{"", "", ""},
		},
	}, {
		output = "techpack_stairway:bridge1",
		recipe = {
			{"", "", ""},
			{"techpack_stairway:handrail1", "techpack_stairway:grating", ""},
			{"", "", ""},
		},
	}, {
		output = "techpack_stairway:bridge2",
		recipe = {
			{"", "", ""},
			{"techpack_stairway:handrail1", "techpack_stairway:grating", "techpack_stairway:handrail1"},
			{"", "", ""},
		},
	}, {
		output = "techpack_stairway:bridge3",
		recipe = {
			{"", "techpack_stairway:handrail1", ""},
			{"techpack_stairway:handrail1", "techpack_stairway:grating", ""},
			{"", "", ""},
		},
	}, {
		output = "techpack_stairway:bridge4",
		recipe = {
			{"", "techpack_stairway:handrail1", ""},
			{"techpack_stairway:handrail1", "techpack_stairway:grating", "techpack_stairway:handrail1"},
			{"", "", ""},
		},
	}, {
		output = "techpack_stairway:lattice_slope_0_10 2",
		recipe = {{"techpack_stairway:lattice"}},
	}, {
		output = "techpack_stairway:lattice",
		type = "shapeless",
		recipe = {"techpack_stairway:lattice_slope_0_10", "techpack_stairway:lattice_slope_0_10"},
	}
})

ch_core.register_nodedir_group({
	[0] = "techpack_stairway:lattice_slope_0_10",
	[1] = "techpack_stairway:lattice_slope_1_19",
	[2] = "techpack_stairway:lattice_slope_2_4",
	[3] = "techpack_stairway:lattice_slope_3_13",
	[4] = "techpack_stairway:lattice_slope_2_4",
	[5] = "techpack_stairway:lattice_slope_5_18",
	[6] = "techpack_stairway:lattice_slope_6_22",
	[7] = "techpack_stairway:lattice_slope_7_14",
	[8] = "techpack_stairway:lattice_slope_8_20",
	[9] = "techpack_stairway:lattice_slope_9_16",
	[10] = "techpack_stairway:lattice_slope_0_10",
	[11] = "techpack_stairway:lattice_slope_11_12",
	[12] = "techpack_stairway:lattice_slope_11_12",
	[13] = "techpack_stairway:lattice_slope_3_13",
	[14] = "techpack_stairway:lattice_slope_7_14",
	[15] = "techpack_stairway:lattice_slope_15_21",
	[16] = "techpack_stairway:lattice_slope_9_16",
	[17] = "techpack_stairway:lattice_slope_17_23",
	[18] = "techpack_stairway:lattice_slope_5_18",
	[19] = "techpack_stairway:lattice_slope_1_19",
	[20] = "techpack_stairway:lattice_slope_8_20",
	[21] = "techpack_stairway:lattice_slope_15_21",
	[22] = "techpack_stairway:lattice_slope_6_22",
	[23] = "techpack_stairway:lattice_slope_17_23",
})

-- dofile(minetest.get_modpath("techpack_stairway").."/upgrade_lbm.lua")
ch_base.close_mod(minetest.get_current_modname())
