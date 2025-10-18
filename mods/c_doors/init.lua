-- c_doors by TumeniNodes, Nathan.S, and Napiophelios Jan 2017
-- rewritten by Singularis, Oct 2025

local function gen_closed_tiles(side_tile, face_tile)
	return {side_tile, side_tile, side_tile, side_tile, face_tile, face_tile}
end

local function gen_open_tiles(side_tile, face_tile)
	return {side_tile, side_tile, face_tile, face_tile, side_tile, side_tile}
end

local function correct_large_open_fixed(lof)
	for i, aabb in ipairs(lof) do
		lof[i] = ch_core.rotate_aabb_by_facedir(aabb, 3)
	end
	return lof
end

local large_closed_node_box = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.027133, -0.4375, 1.5, 0.027133},
		{-0.5, -0.5, -0.027133, 0.5, -0.4375, 0.027133},
		{0.4375, -0.5, -0.027133, 0.5, 1.5, 0.027133},
		{-0.0625, -0.5, -0.027133, 0.0625, 1.5, 0.027133},
		{-0.5, 0.4375, -0.027133, 0.5, 0.5625, 0.027133},
		{-0.5, 1.4375, -0.027133, 0.5, 1.5, 0.027133},
		{-0.4375, 0.5625, -0.02, -0.0625, 1.4375, 0.02},
		{0.0625, 0.5625, -0.02, 0.4375, 1.4375, 0.02},
		{0.0625, -0.4375, -0.02, 0.4375, 0.4375, 0.02},
		{-0.4375, -0.4375, -0.02, -0.0625, 0.4375, 0.02},
	}
}

local large_open_node_box = {
	type = "fixed",
	fixed = correct_large_open_fixed{
		{0.472867, -0.5, -0.5, 0.5, 1.5, -0.4375},
		{0.472867, -0.5, -0.0625, 0.5, 1.5, 0},
		{-0.5, -0.5, -0.0625, -0.472867, 1.5, 0},
		{0.472867, 0.4375, -0.5, 0.5, 0.5625, 0},
		{-0.5, 0.4375, -0.5, -0.472867, 0.5625, 0},
		{-0.5, -0.5, -0.5, -0.472867, -0.4375, 0},
		{0.472867, -0.5, -0.5, 0.5, -0.4375, 0},
		{0.472867, 1.4375, -0.5, 0.5, 1.5, 0},
		{-0.5, 1.4375, -0.5, -0.472867, 1.5, -0.0625},
		{0.472867, 0.5625, -0.4375, 0.5, 1.4375, -0.0625},
		{0.472867, -0.4375, -0.4375, 0.5, 0.4375, -0.0625},
		{-0.472867, 0.5625, -0.4375, -0.5, 1.4375, -0.0625},
		{-0.472867, -0.4375, -0.4375, -0.5, 0.4375, -0.0625},
		{-0.5, -0.5, -0.5, -0.472867, 1.5, -0.4375},
	},
}

local large_closed_selection_box = {type = "fixed", fixed = {{-0.5, -0.5, -0.03, 0.5, 1.5, 0.03}}}

local large_open_selection_box = {type = "fixed", fixed = correct_large_open_fixed{
	{-0.5, -0.5, -0.5, -0.4375, 1.5, 0},
	{0.4375, -0.5, -0.5, 0.5, 1.5, 0},
}}

local large_open_collision_box = {type = "fixed", fixed = correct_large_open_fixed{
	{0.472867, -0.5, -0.5, 0.5, 1.5, 0},
	{-0.5, -0.5, -0.5, -0.472867, 1.5, 0},
}}

local small_closed_node_box = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.027133, -0.4375, 0.5, 0.027133},
		{-0.5, -0.5, -0.027133, 0.5, -0.4375, 0.027133},
		{0.4375, -0.5, -0.027133, 0.5, 0.5, 0.027133},
		{-0.0625, -0.5, -0.027133, 0.0625, 0.5, 0.027133},
		{-0.5, 0.4375, -0.027133, 0.5, 0.5, 0.027133},
		{-0.4375, -0.4375, -0.02, -0.0625, 0.4375, 0.02},
		{0.0625, -0.4375, -0.02, 0.4375, 0.4375, 0.02},
	},
}

local small_open_node_box = {
	type = "fixed",
	fixed = {
		{0.472867, -0.5, -0.5, 0.5, 0.5, -0.4375},
		{0.472867, -0.5, -0.0625, 0.5, 0.5, 0},
		{-0.5, -0.5, -0.5, -0.472867, 0.5, -0.4375},
		{-0.5, -0.5, -0.0625, -0.472867, 0.5, 0},
		{0.472867, 0.4375, -0.5, 0.5, 0.5, 0},
		{-0.5, 0.4375, -0.5, -0.472867, 0.5, 0},
		{-0.5, -0.5, -0.5, -0.472867, -0.4375, 0},
		{0.472867, -0.5, -0.5, 0.5, -0.4375, 0},
		{-0.472867, -0.4375, -0.4375, -0.5, 0.4375, -0.0625},
		{0.472867, -0.4375, -0.4375, 0.5, 0.4375, -0.0625},
	},
}

local small_closed_selection_box = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.03, 0.5, 0.5, 0.03},
	},
}

local small_open_selection_box = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.5, -0.4375, 0.5, 0},
		{0.4375, -0.5, -0.5, 0.5, 0.5, 0},
	},
}

local small_open_collision_box = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.5, -0.472867, 0.5, 0},
		{0.472867, -0.5, -0.5, 0.5, 0.5, 0},
	},
}

local mesecons_def = {
	effector = {
		action_on = function(pos)
			local door = doors.get(pos)
			if door then
				door:open()
			end
		end,
		action_off = function(pos)
			local door = doors.get(pos)
			if door then
				door:close()
			end
		end,
	},
}

local def

doors.register("door_cdoors_wood", {
	description = "vysoké dřevěné okno",
	closed_tiles = gen_closed_tiles("c_doors_dble_wood_sides.png", "c_doors_dble_wood.png"),
	open_tiles = gen_closed_tiles("c_doors_dble_wood_sides.png", "c_doors_dble_wood.png"),
	use_texture_alpha = "blend",
	closed_node_box = large_closed_node_box,
	open_node_box = large_open_node_box,
	closed_selection_box = large_closed_selection_box,
	open_selection_box = large_open_selection_box,
	open_collision_box = large_open_collision_box,
	inventory_image = "c_doors_dble_wood_inv.png",
	groups = {node = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	sounds = default.node_sound_glass_defaults(),
	sound_open = "doors_glass_door_open",
	sound_close = "doors_glass_door_close",
	gain_open = 0.3,
	gain_close = 0.25,
	recipe = {
		{"group:wood", "", "group:wood"},
		{"group:wood", "", "group:wood"},
		{"group:wood", "", "group:wood"},
	},
	mesecons = mesecons_def,
})

doors.register("door_cdoors_obsidian", {
	description = "vysoké obsidiánové okno",
	closed_tiles = gen_closed_tiles("c_doors_dble_obsidian_glass_sides.png", "c_doors_dble_obsidian_glass.png"),
	open_tiles = gen_closed_tiles("c_doors_dble_obsidian_glass_sides.png", "c_doors_dble_obsidian_glass.png"),
	use_texture_alpha = "blend",
	closed_node_box = large_closed_node_box,
	open_node_box = large_open_node_box,
	closed_selection_box = large_closed_selection_box,
	open_selection_box = large_open_selection_box,
	open_collision_box = large_open_collision_box,
	inventory_image = "c_doors_dble_obsidian_glass_inv.png",
	groups = {node = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	sounds = default.node_sound_glass_defaults(),
	sound_open = "doors_glass_door_open",
	sound_close = "doors_glass_door_close",
	gain_open = 0.3,
	gain_close = 0.25,
	recipe = {
		{"default:obsidian", "", "default:obsidian"},
		{"default:obsidian", "default:obsidian_glass", "default:obsidian"},
		{"default:obsidian", "", "default:obsidian"},
	},
	mesecons = mesecons_def,
})

def = {
	description = "vysoké plastové okno (lakované)",
	closed_tiles = gen_closed_tiles("c_doors_dble_steel_sides.png", "c_doors_dble_steel.png"),
	open_tiles = gen_closed_tiles("c_doors_dble_steel_sides.png", "c_doors_dble_steel.png"),
	use_texture_alpha = "blend",
	closed_node_box = large_closed_node_box,
	open_node_box = large_open_node_box,
	closed_selection_box = large_closed_selection_box,
	open_selection_box = large_open_selection_box,
	open_collision_box = large_open_collision_box,
	inventory_image = "c_doors_dble_steel_inv.png",
	groups = {node = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	sounds = default.node_sound_glass_defaults(),
	sound_open = "doors_glass_door_open",
	sound_close = "doors_glass_door_close",
	gain_open = 0.3,
	gain_close = 0.25,
	recipe = {
		{"basic_materials:plastic_sheet", "", "basic_materials:plastic_sheet"},
		{"basic_materials:plastic_sheet", "default:glass", "basic_materials:plastic_sheet"},
		{"basic_materials:plastic_sheet", "", "basic_materials:plastic_sheet"},
	},
	mesecons = mesecons_def,
}
if core.get_modpath("unifieddyes") then
	def.paramtype2 = "color4dir"
	def.palette = "unifieddyes_palette_color4dir.png"
	def.groups.ud_param2_colorable = 1
end
doors.register("door_cdoors_plastic", def)

doors.register_fencegate("doors:cdoors_wood_half", {
	description = "nízké dřevěné okno",
	use_custom_description = true,
	-- texture = "default_wood.png",
	material = "default:wood",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	sounds = default.node_sound_glass_defaults(),
	closed_tiles = gen_closed_tiles("c_doors_dble_wood_sides.png", "c_doors_dble_wood.png"),
	open_tiles = gen_open_tiles("c_doors_dble_wood_sides.png", "c_doors_dble_wood.png"),
	use_texture_alpha = "blend",
	closed_node_box = small_closed_node_box,
	open_node_box = small_open_node_box,
	closed_selection_box = small_closed_selection_box,
	open_selection_box = small_closed_selection_box,
	open_collision_box = small_open_collision_box,
})

doors.register_fencegate("doors:cdoors_obsidian_half", {
	description = "nízké obsidiánové okno",
	use_custom_description = true,
	material = "default:obsidian_glass",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	closed_tiles = gen_closed_tiles("c_doors_dble_obsidian_glass_sides.png", "c_doors_dble_obsidian_glass.png"),
	open_tiles = gen_open_tiles("c_doors_dble_obsidian_glass_sides.png", "c_doors_dble_obsidian_glass.png"),
	use_texture_alpha = "blend",
	closed_node_box = small_closed_node_box,
	open_node_box = small_open_node_box,
	closed_selection_box = small_closed_selection_box,
	open_selection_box = small_closed_selection_box,
	open_collision_box = small_open_collision_box,
})

doors.register_fencegate("doors:cdoors_plastic_half", {
	description = "nízké plastové okno (lakované)",
	use_custom_description = true,
	-- texture = "default_wood.png",
	material = "basic_materials:plastic_sheet",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, ud_param2_colorable = 1},
	closed_tiles = gen_closed_tiles("c_doors_dble_steel_sides.png", "c_doors_dble_steel.png"),
	open_tiles = gen_open_tiles("c_doors_dble_steel_sides.png", "c_doors_dble_steel.png"),
	use_texture_alpha = "blend",
	closed_node_box = small_closed_node_box,
	open_node_box = small_open_node_box,
	closed_selection_box = small_closed_selection_box,
	open_selection_box = small_closed_selection_box,
	open_collision_box = small_open_collision_box,
})

if core.get_modpath("unifieddyes") then
	core.override_item("doors:cdoors_plastic_half_open", {
		paramtype2 = "color4dir",
		palette = "unifieddyes_palette_color4dir.png"
	})
	core.override_item("doors:cdoors_plastic_half_closed", {
		paramtype2 = "color4dir",
		palette = "unifieddyes_palette_color4dir.png"
	})
end

def = {
	sounds = default.node_sound_glass_defaults(),
	_gate_sound = "doors_glass_door_open",
	mesecons = mesecons_def,
}

for _, n in ipairs({"doors:cdoors_wood_half", "doors:cdoors_obsidian_half", "doors:cdoors_plastic_half"}) do
	core.override_item(n.."_open", def)
	core.override_item(n.."_closed", def)
end
