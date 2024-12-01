local mod_name = "classic_coaches"

local S = minetest.get_translator(mod_name)

local use_advtrains_livery_designer = minetest.get_modpath( "advtrains_livery_designer" ) and advtrains_livery_designer

----------------------------------------------------------------------------------------

local function get_materials_minetest_game()
	return {
		base_game	= "Minetest Game",

		door_steel	= minetest.get_modpath("doors") and "doors:trapdoor_steel" or "default:steel_ingot",
		dye_grey	= "dye:grey",
		glass		= "default:glass",
		goldblock	= "default:goldblock",
		steel_ingot	= "default:steel_ingot",
		steelblock	= "default:steelblock",
		wheel		= "advtrains:wheel",
		wool_blue	= minetest.get_modpath("wool") and "wool:blue" or "dye:blue",
		wool_cyan	= minetest.get_modpath("wool") and "wool:cyan" or "dye:cyan",
	}
end

local function get_materials_mineclonia()
	return {
		base_game	= "Mineclonia",

		door_steel	= minetest.get_modpath("mcl_doors") and "mcl_doors:iron_door" or "mcl_core:iron_ingot",
		dye_grey	= "mcl_dyes:grey",
		glass		= "mcl_core:glass",
		goldblock	= "mcl_core:goldblock",
		steel_ingot	= "mcl_core:iron_ingot",
		steelblock	= "mcl_core:ironblock",
		wheel		= "advtrains:wheel",
		wool_blue	= minetest.get_modpath("mcl_wool") and "mcl_wool:blue" or "mcl_dyes:blue",
		wool_cyan	= minetest.get_modpath("mcl_wool") and "mcl_wool:cyan" or "mcl_dyes:cyan",
	}
end

local function get_materials_voxelibre()
	return {
		base_game	= "VoxeLibre/MineClone2",

		door_steel	= minetest.get_modpath("mcl_doors") and "mcl_doors:iron_door" or "mcl_core:iron_ingot",
		dye_grey	= "mcl_dye:grey",
		glass		= "mcl_core:glass",
		goldblock	= "mcl_core:goldblock",
		steel_ingot	= "mcl_core:iron_ingot",
		steelblock	= "mcl_core:ironblock",
		wheel		= "advtrains:wheel",
		wool_blue	= minetest.get_modpath("mcl_wool") and "mcl_wool:blue" or "mcl_dye:blue",
		wool_cyan	= minetest.get_modpath("mcl_wool") and "mcl_wool:cyan" or "mcl_dye:cyan",
	}
end

local function get_materials_farlands_reloaded()
	return {
		base_game	= "Farlands Reloaded",

		door_steel	= minetest.get_modpath("fl_doors") and "fl_doors:steel_door_a" or "fl_ores:iron_ingot",
		dye_grey	= "fl_dyes:grey_dye",
		glass		= "fl_glass:framed_glass",
		goldblock	= "fl_ores:gold_block",
		steel_ingot	= "fl_ores:iron_ingot",
		steelblock	= "fl_ores:iron_block",
		wheel		= "advtrains:wheel",
		wool_blue	= "fl_dyes:blue_dye",	-- farlands handles wool color via param 2 so use dye instead.
		wool_cyan	= "fl_dyes:cyan_dye",	-- farlands handles wool color via param 2 so use dye instead.
	}
end

local function get_materials_hades_revisited()
	return {
		base_game	= "Hades Revisited",

		door_steel	= minetest.get_modpath("hades_doors") and "hades_doors:door_steel_a" or "hades_core:steel_ingot",
		dye_grey	= "hades_dye:grey",
		glass		= "hades_core:glass",
		goldblock	= "hades_core:goldblock",
		steel_ingot	= "hades_core:steel_ingot",
		steelblock	= "hades_core:steelblock",
		wheel		= "advtrains:wheel",
		wool_blue	= minetest.get_modpath("hades_cloth") and "hades_cloth:blue" or "hades_dye:blue",
		wool_cyan	= minetest.get_modpath("hades_cloth") and "hades_cloth:cyan" or "hades_dye:cyan",
	}
end

local function get_materials()
	if minetest.get_modpath("default") and minetest.get_modpath("dye") then
		return get_materials_minetest_game()
	end

	if minetest.get_modpath("mcl_core") and minetest.get_modpath("mcl_dyes") then
		return get_materials_mineclonia()
	end

	if minetest.get_modpath("mcl_core") and minetest.get_modpath("mcl_dye") then
		return get_materials_voxelibre()
	end

	if minetest.get_modpath("fl_dyes") and minetest.get_modpath("fl_glass") and minetest.get_modpath("fl_ores") then
		return get_materials_farlands_reloaded()
	end

	if minetest.get_modpath("hades_core") and minetest.get_modpath("hades_dye") then
		return get_materials_hades_revisited()
	end

	local unknown_material = "classic_coaches:unknown_material"
	return {
		door_steel	= unknown_material,
		dye_grey	= unknown_material,
		glass		= unknown_material,
		goldblock	= unknown_material,
		steel_ingot	= unknown_material,
		steelblock	= unknown_material,
		wheel		= unknown_material,
		wool_blue	= unknown_material,
		wool_cyan	= unknown_material,
	}
end

local materials = get_materials()

----------------------------------------------------------------------------------------

local default_roof_alpha = 230
local default_seat_alpha = 245
local default_wall_alpha = 253

local wagons = {
	{
		wagon_type = "classic_coaches:corridor_coach_class1",
		mesh = "classic_coaches_corridor_coach_class1.b3d",
		textures = {"classic_coaches_corridor_coach_class1_001.png"},
		name = S("Intercity Corridor Coach Class 1"),
		inventory_image = "classic_coaches_corridor_coach_class1_inv.png",
		recipe = {
			{materials.goldblock},
			{'classic_coaches:corridor_coach_class2'},
		},
	},
	{
		wagon_type = "classic_coaches:corridor_coach_class2",
		mesh = "classic_coaches_corridor_coach_class2.b3d",
		textures = {"classic_coaches_corridor_coach_class2_001.png"},
		name = S("Intercity Corridor Coach Class 2"),
		inventory_image = "classic_coaches_corridor_coach_class2_inv.png",
		recipe = {
			{materials.steelblock, materials.dye_grey, materials.steelblock},
			{materials.glass, materials.wool_blue, materials.door_steel},
			{materials.wheel, materials.steelblock, materials.wheel},
		},
	},
	{
		wagon_type = "classic_coaches:open_coach_class1",
		mesh = "classic_coaches_open_coach_class1.b3d",
		textures = {"classic_coaches_open_coach_class1_001.png"},
		name = S("Intercity Open Coach Class 1"),
		inventory_image = "classic_coaches_open_coach_class1_inv.png",
		recipe = {
			{materials.goldblock},
			{'classic_coaches:open_coach_class2'},
		},
	},
	{
		wagon_type = "classic_coaches:open_coach_class2",
		mesh = "classic_coaches_open_coach_class2.b3d",
		textures = {"classic_coaches_open_coach_class2_001.png"},
		name = S("Intercity Open Coach Class 2"),
		inventory_image = "classic_coaches_open_coach_class2_inv.png",
		recipe = {
			{materials.steelblock, materials.dye_grey, materials.steelblock},
			{materials.glass, materials.wool_cyan, materials.door_steel},
			{materials.wheel, materials.steelblock, materials.wheel},
		},
	},
}

local livery_template_names = {
	[1] =	{name = S("CC Stripe"),				notes = "The livery features a medium width stripe with embedded logo.  A narrow divider stripe can be added."},
	[2] =	{name = S("CC Intercity Stripe"),	notes = "The livery features a medium width stripe with embedded logo and the word, 'intercity'.  The side doors are colored differently by default."},
	[3] =	{name = S("CC Edged Stripe"),		notes = "The livery features a medium width stripe with embedded logo.  The stripe's edges are colored differently by default."},
	[4] =	{name = S("CC Window Band"),		notes = "A wide band of color spans the widow area for the length of the wagon."},
	[5] =	{name = S("CC Solid Color"),		notes = "The wagon sides are a solid color without stripes or other decoration."},
	[6] =	{name = S("CC Colored Roof"),		notes = "The roof and the lower edge of the wagon sides are colored.  A wide light grey band spans the widow area for the length of the wagon."},
	[7] =	{name = S("CC Express"),			notes = "Thin stripes and the word, 'Express' are shown on both sides of the wagon."},
}

local livery_templates = {
	["classic_coaches:corridor_coach_class1"] = {
		[1] = {
			base_texture = "classic_coaches_corridor_coach_class1_001.png",
			overlays = {
				[1] = {name = S("Side Walls"),		texture = "classic_coaches_overlay_001_class1_side_walls.png",		alpha = default_wall_alpha},
				[2] = {name = S("Stripe"),			texture = "classic_coaches_overlay_001_stripe.png",					alpha = default_wall_alpha},
				[3] = {name = S("Stripe Divider"),	texture = "classic_coaches_overlay_001_stripe_divider.png"},
				[4] = {name = S("Side Doors"),		texture = "classic_coaches_overlay_side_doors.png",					alpha = default_wall_alpha},
				[5] = {name = S("Class Number"),	texture = "classic_coaches_overlay_class1_class_number.png"},
			},
		},
		[2] = {
			base_texture = "classic_coaches_corridor_coach_class1_002.png",
			overlays = {
				[1] = {name = S("Exterior Walls"),	texture = "classic_coaches_overlay_002_class1_exterior_walls.png",	alpha = default_wall_alpha},
				[2] = {name = S("Stripe"),			texture = "classic_coaches_overlay_002_stripe.png",					alpha = default_wall_alpha},
				[3] = {name = S("Service Stripe"),	texture = "classic_coaches_overlay_service_stripe.png"},
				[4] = {name = S("Side Doors"),		texture = "classic_coaches_overlay_side_doors.png",					alpha = default_wall_alpha},
				[5] = {name = S("Class Number"),	texture = "classic_coaches_overlay_class1_class_number.png"},
			},
		},
		[3] = {
			base_texture = "classic_coaches_corridor_coach_class1_003.png",
			overlays = {
				[1] = {name = S("Side Walls"),		texture = "classic_coaches_overlay_003_side_walls.png",				alpha = default_wall_alpha},
				[2] = {name = S("Stripe"),			texture = "classic_coaches_overlay_003_stripe.png",					alpha = default_wall_alpha},
				[3] = {name = S("Stripe Edges"),	texture = "classic_coaches_overlay_003_stripe_edges.png"},
				[4] = {name = S("Logo"),			texture = "classic_coaches_overlay_cc_logo_1.png"},
				[5] = {name = S("End Doors"),		texture = "classic_coaches_overlay_end_doors.png",					alpha = default_wall_alpha},
			},
		},
		[4] = {
			base_texture = "classic_coaches_corridor_coach_class1_004.png",
			overlays = {
				[1] = {name = S("Side Walls"),		texture = "classic_coaches_overlay_004_side_walls.png",				alpha = default_wall_alpha},
				[2] = {name = S("Window Band"),		texture = "classic_coaches_overlay_004_class1_window_band.png",		alpha = default_wall_alpha},
				[3] = {name = S("Decoration"),		texture = "classic_coaches_overlay_004_decoration.png"},
				[4] = {name = S("Logo"),			texture = "classic_coaches_overlay_cc_logo_2.png"},
				[5] = {name = S("Class Number"),	texture = "classic_coaches_overlay_class1_class_number.png"},
			},
		},
		[5] = {
			base_texture = "classic_coaches_corridor_coach_class1_005.png",
			overlays = {
				[1] = {name = S("Side Walls"),		texture = "classic_coaches_overlay_005_class1_side_walls.png",		alpha = default_wall_alpha},
				[2] = {name = S("Seats"),			texture = "classic_coaches_overlay_seats.png",						alpha = default_seat_alpha},
				[3] = {name = S("Service Stripe"),	texture = "classic_coaches_overlay_service_stripe.png"},
				[4] = {name = S("Logo"),			texture = "classic_coaches_overlay_cc_logo_2.png"},
				[5] = {name = S("Class Number"),	texture = "classic_coaches_overlay_class1_class_number.png"},
			},
		},
		[6] = {
			base_texture = "classic_coaches_corridor_coach_class1_006.png",
			overlays = {
				[1] = {name = S("Side Walls"),		texture = "classic_coaches_overlay_006_side_walls.png",				alpha = default_wall_alpha},
				[2] = {name = S("Roof"),			texture = "classic_coaches_overlay_006_roof.png",					alpha = default_roof_alpha},
				[3] = {name = S("Trim"),			texture = "classic_coaches_overlay_006_trim.png"},
				[4] = {name = S("Logo"),			texture = "classic_coaches_overlay_cc_logo_2.png"},
				[5] = {name = S("End Doors"),		texture = "classic_coaches_overlay_end_doors.png",					alpha = default_wall_alpha},
			},
		},
		[7] = {
			base_texture = "classic_coaches_corridor_coach_class1_007.png",
			overlays = {
				[1] = {name = S("Exterior Walls"),	texture = "classic_coaches_overlay_007_class1_exterior_walls.png",	alpha = default_wall_alpha},
				[2] = {name = S("Seats"),			texture = "classic_coaches_overlay_seats.png",						alpha = default_seat_alpha},
				[3] = {name = S("Decoration"),		texture = "classic_coaches_overlay_007_decoration.png"},
				[4] = {name = S("Label"),			texture = "classic_coaches_overlay_007_label.png"},
				[5] = {name = S("Class Number"),	texture = "classic_coaches_overlay_class1_class_number.png"},
				[6] = {name = S("Logo and Text"),	texture = "classic_coaches_overlay_007_logo_text.png"},
			},
		},
	},
	["classic_coaches:corridor_coach_class2"] = {
		[1] = {
			base_texture = "classic_coaches_corridor_coach_class2_001.png",
			overlays = {
				[1] = {name = S("Side Walls"),		texture = "classic_coaches_overlay_001_class2_side_walls.png",		alpha = default_wall_alpha},
				[2] = {name = S("Stripe"),			texture = "classic_coaches_overlay_001_stripe.png",					alpha = default_wall_alpha},
				[3] = {name = S("Stripe Divider"),	texture = "classic_coaches_overlay_001_stripe_divider.png"},
				[4] = {name = S("Side Doors"),		texture = "classic_coaches_overlay_side_doors.png",					alpha = default_wall_alpha},
				[5] = {name = S("Class Number"),	texture = "classic_coaches_overlay_class2_class_number.png"},
			},
		},
		[2] = {
			base_texture = "classic_coaches_corridor_coach_class2_002.png",
			overlays = {
				[1] = {name = S("Exterior Walls"),	texture = "classic_coaches_overlay_002_class2_exterior_walls.png",	alpha = default_wall_alpha},
				[2] = {name = S("Stripe"),			texture = "classic_coaches_overlay_002_stripe.png",					alpha = default_wall_alpha},
				[3] = {name = S("Service Stripe"),	texture = "classic_coaches_overlay_service_stripe.png"},
				[4] = {name = S("Side Doors"),		texture = "classic_coaches_overlay_side_doors.png",					alpha = default_wall_alpha},
				[5] = {name = S("Class Number"),	texture = "classic_coaches_overlay_class2_class_number.png"},
			},
		},
		[3] = {
			base_texture = "classic_coaches_corridor_coach_class2_003.png",
			overlays = {
				[1] = {name = S("Side Walls"),		texture = "classic_coaches_overlay_003_side_walls.png",				alpha = default_wall_alpha},
				[2] = {name = S("Stripe"),			texture = "classic_coaches_overlay_003_stripe.png",					alpha = default_wall_alpha},
				[3] = {name = S("Stripe Edges"),	texture = "classic_coaches_overlay_003_stripe_edges.png"},
				[4] = {name = S("Logo"),			texture = "classic_coaches_overlay_cc_logo_1.png"},
				[5] = {name = S("End Doors"),		texture = "classic_coaches_overlay_end_doors.png",					alpha = default_wall_alpha},
			},
		},
		[4] = {
			base_texture = "classic_coaches_corridor_coach_class2_004.png",
			overlays = {
				[1] = {name = S("Side Walls"),		texture = "classic_coaches_overlay_004_side_walls.png",				alpha = default_wall_alpha},
				[2] = {name = S("Window Band"),		texture = "classic_coaches_overlay_004_class2_window_band.png",		alpha = default_wall_alpha},
				[3] = {name = S("Decoration"),		texture = "classic_coaches_overlay_004_decoration.png"},
				[4] = {name = S("Logo"),			texture = "classic_coaches_overlay_cc_logo_2.png"},
				[5] = {name = S("Class Number"),	texture = "classic_coaches_overlay_class2_class_number.png"},
			},
		},
		[5] = {
			base_texture = "classic_coaches_corridor_coach_class2_005.png",
			overlays = {
				[1] = {name = S("Side Walls"),		texture = "classic_coaches_overlay_005_class2_side_walls.png",		alpha = default_wall_alpha},
				[2] = {name = S("Seats"),			texture = "classic_coaches_overlay_seats.png",						alpha = default_seat_alpha},
				[3] = {name = S("Service Stripe"),	texture = "classic_coaches_overlay_service_stripe.png"},
				[4] = {name = S("Logo"),			texture = "classic_coaches_overlay_cc_logo_2.png"},
				[5] = {name = S("Class Number"),	texture = "classic_coaches_overlay_class2_class_number.png"},
			},
		},
		[6] = {
			base_texture = "classic_coaches_corridor_coach_class2_006.png",
			overlays = {
				[1] = {name = S("Side Walls"),		texture = "classic_coaches_overlay_006_side_walls.png",				alpha = default_wall_alpha},
				[2] = {name = S("Roof"),			texture = "classic_coaches_overlay_006_roof.png",					alpha = default_roof_alpha},
				[3] = {name = S("Trim"),			texture = "classic_coaches_overlay_006_trim.png"},
				[4] = {name = S("Logo"),			texture = "classic_coaches_overlay_cc_logo_2.png"},
				[5] = {name = S("End Doors"),		texture = "classic_coaches_overlay_end_doors.png",					alpha = default_wall_alpha},
			},
		},
		[7] = {
			base_texture = "classic_coaches_corridor_coach_class2_007.png",
			overlays = {
				[1] = {name = S("Exterior Walls"),	texture = "classic_coaches_overlay_007_class2_exterior_walls.png",	alpha = default_wall_alpha},
				[2] = {name = S("Seats"),			texture = "classic_coaches_overlay_seats.png",						alpha = default_seat_alpha},
				[3] = {name = S("Decoration"),		texture = "classic_coaches_overlay_007_decoration.png"},
				[4] = {name = S("Label"),			texture = "classic_coaches_overlay_007_label.png"},
				[5] = {name = S("Class Number"),	texture = "classic_coaches_overlay_class2_class_number.png"},
				[6] = {name = S("Logo and Text"),	texture = "classic_coaches_overlay_007_logo_text.png"},
			},
		},
	},
	["classic_coaches:open_coach_class1"] = {
		[1] = {
			base_texture = "classic_coaches_open_coach_class1_001.png",
			overlays = {
				[1] = {name = S("Side Walls"),		texture = "classic_coaches_overlay_001_class1_side_walls.png",		alpha = default_wall_alpha},
				[2] = {name = S("Stripe"),			texture = "classic_coaches_overlay_001_stripe.png",					alpha = default_wall_alpha},
				[3] = {name = S("Stripe Divider"),	texture = "classic_coaches_overlay_001_stripe_divider.png"},
				[4] = {name = S("Side Doors"),		texture = "classic_coaches_overlay_side_doors.png",					alpha = default_wall_alpha},
				[5] = {name = S("Class Number"),	texture = "classic_coaches_overlay_class1_class_number.png"},
			},
			},
		[2] = {
			base_texture = "classic_coaches_open_coach_class1_002.png",
			overlays = {
				[1] = {name = S("Exterior Walls"),	texture = "classic_coaches_overlay_002_class1_exterior_walls.png",	alpha = default_wall_alpha},
				[2] = {name = S("Stripe"),			texture = "classic_coaches_overlay_002_stripe.png",					alpha = default_wall_alpha},
				[3] = {name = S("Service Stripe"),	texture = "classic_coaches_overlay_service_stripe.png"},
				[4] = {name = S("Side Doors"),		texture = "classic_coaches_overlay_side_doors.png",					alpha = default_wall_alpha},
				[5] = {name = S("Class Number"),	texture = "classic_coaches_overlay_class1_class_number.png"},
			},
		},
		[3] = {
			base_texture = "classic_coaches_open_coach_class1_003.png",
			overlays = {
				[1] = {name = S("Side Walls"),		texture = "classic_coaches_overlay_003_side_walls.png",				alpha = default_wall_alpha},
				[2] = {name = S("Stripe"),			texture = "classic_coaches_overlay_003_stripe.png",					alpha = default_wall_alpha},
				[3] = {name = S("Stripe Edges"),	texture = "classic_coaches_overlay_003_stripe_edges.png"},
				[4] = {name = S("Logo"),			texture = "classic_coaches_overlay_cc_logo_1.png"},
				[5] = {name = S("End Doors"),		texture = "classic_coaches_overlay_end_doors.png",					alpha = default_wall_alpha},
			},
		},
		[4] = {
			base_texture = "classic_coaches_open_coach_class1_004.png",
			overlays = {
				[1] = {name = S("Side Walls"),		texture = "classic_coaches_overlay_004_side_walls.png",				alpha = default_wall_alpha},
				[2] = {name = S("Window Band"),		texture = "classic_coaches_overlay_004_class1_window_band.png",		alpha = default_wall_alpha},
				[3] = {name = S("Decoration"),		texture = "classic_coaches_overlay_004_decoration.png"},
				[4] = {name = S("Logo"),			texture = "classic_coaches_overlay_cc_logo_2.png"},
				[5] = {name = S("Class Number"),	texture = "classic_coaches_overlay_class1_class_number.png"},
			},
		},
		[5] = {
			base_texture = "classic_coaches_open_coach_class1_005.png",
			overlays = {
				[1] = {name = S("Side Walls"),		texture = "classic_coaches_overlay_005_class1_side_walls.png",		alpha = default_wall_alpha},
				[2] = {name = S("Seats"),			texture = "classic_coaches_overlay_seats.png",						alpha = default_seat_alpha},
				[3] = {name = S("Service Stripe"),	texture = "classic_coaches_overlay_service_stripe.png"},
				[4] = {name = S("Logo"),			texture = "classic_coaches_overlay_cc_logo_2.png"},
				[5] = {name = S("Class Number"),	texture = "classic_coaches_overlay_class1_class_number.png"},
			},
		},
		[6] = {
			base_texture = "classic_coaches_open_coach_class1_006.png",
			overlays = {
				[1] = {name = S("Side Walls"),		texture = "classic_coaches_overlay_006_side_walls.png",				alpha = default_wall_alpha},
				[2] = {name = S("Roof"),			texture = "classic_coaches_overlay_006_roof.png",					alpha = default_roof_alpha},
				[3] = {name = S("Trim"),			texture = "classic_coaches_overlay_006_trim.png"},
				[4] = {name = S("Logo"),			texture = "classic_coaches_overlay_cc_logo_2.png"},
				[5] = {name = S("End Doors"),		texture = "classic_coaches_overlay_end_doors.png",					alpha = default_wall_alpha},
			},
		},
		[7] = {
			base_texture = "classic_coaches_open_coach_class1_007.png",
			overlays = {
				[1] = {name = S("Exterior Walls"),	texture = "classic_coaches_overlay_007_class1_exterior_walls.png",	alpha = default_wall_alpha},
				[2] = {name = S("Seats"),			texture = "classic_coaches_overlay_seats.png",						alpha = default_seat_alpha},
				[3] = {name = S("Decoration"),		texture = "classic_coaches_overlay_007_decoration.png"},
				[4] = {name = S("Label"),			texture = "classic_coaches_overlay_007_label.png"},
				[5] = {name = S("Class Number"),	texture = "classic_coaches_overlay_class1_class_number.png"},
				[6] = {name = S("Logo and Text"),	texture = "classic_coaches_overlay_007_logo_text.png"},
			},
		},
	},
	["classic_coaches:open_coach_class2"] = {
		[1] = {
			base_texture = "classic_coaches_open_coach_class2_001.png",
			overlays = {
				[1] = {name = S("Side Walls"),		texture = "classic_coaches_overlay_001_class2_side_walls.png",		alpha = default_wall_alpha},
				[2] = {name = S("Stripe"),			texture = "classic_coaches_overlay_001_stripe.png",					alpha = default_wall_alpha},
				[3] = {name = S("Stripe Divider"),	texture = "classic_coaches_overlay_001_stripe_divider.png"},
				[4] = {name = S("Side Doors"),		texture = "classic_coaches_overlay_side_doors.png",					alpha = default_wall_alpha},
				[5] = {name = S("Class Number"),	texture = "classic_coaches_overlay_class2_class_number.png"},
			},
		},
		[2] = {
			base_texture = "classic_coaches_open_coach_class2_002.png",
			overlays = {
				[1] = {name = S("Exterior Walls"),	texture = "classic_coaches_overlay_002_class2_exterior_walls.png",	alpha = default_wall_alpha},
				[2] = {name = S("Stripe"),			texture = "classic_coaches_overlay_002_stripe.png",					alpha = default_wall_alpha},
				[3] = {name = S("Service Stripe"),	texture = "classic_coaches_overlay_service_stripe.png"},
				[4] = {name = S("Side Doors"),		texture = "classic_coaches_overlay_side_doors.png",					alpha = default_wall_alpha},
				[5] = {name = S("Class Number"),	texture = "classic_coaches_overlay_class2_class_number.png"},
			},
		},
		[3] = {
			base_texture = "classic_coaches_open_coach_class2_003.png",
			overlays = {
				[1] = {name = S("Side Walls"),		texture = "classic_coaches_overlay_003_side_walls.png",				alpha = default_wall_alpha},
				[2] = {name = S("Stripe"),			texture = "classic_coaches_overlay_003_stripe.png",					alpha = default_wall_alpha},
				[3] = {name = S("Stripe Edges"),	texture = "classic_coaches_overlay_003_stripe_edges.png"},
				[4] = {name = S("Logo"),			texture = "classic_coaches_overlay_cc_logo_1.png"},
				[5] = {name = S("End Doors"),		texture = "classic_coaches_overlay_end_doors.png",					alpha = default_wall_alpha},
			},
		},
		[4] = {
			base_texture = "classic_coaches_open_coach_class2_004.png",
			overlays = {
				[1] = {name = S("Side Walls"),		texture = "classic_coaches_overlay_004_side_walls.png",				alpha = default_wall_alpha},
				[2] = {name = S("Window Band"),		texture = "classic_coaches_overlay_004_class2_window_band.png",		alpha = default_wall_alpha},
				[3] = {name = S("Decoration"),		texture = "classic_coaches_overlay_004_decoration.png"},
				[4] = {name = S("Logo"),			texture = "classic_coaches_overlay_cc_logo_2.png"},
				[5] = {name = S("Class Number"),	texture = "classic_coaches_overlay_class2_class_number.png"},
			},
		},
		[5] = {
			base_texture = "classic_coaches_open_coach_class2_005.png",
			overlays = {
				[1] = {name = S("Side Walls"),		texture = "classic_coaches_overlay_005_class2_side_walls.png",		alpha = default_wall_alpha},
				[2] = {name = S("Seats"),			texture = "classic_coaches_overlay_seats.png",						alpha = default_seat_alpha},
				[3] = {name = S("Service Stripe"),	texture = "classic_coaches_overlay_service_stripe.png"},
				[4] = {name = S("Logo"),			texture = "classic_coaches_overlay_cc_logo_2.png"},
				[5] = {name = S("Class Number"),	texture = "classic_coaches_overlay_class2_class_number.png"},
			},
		},
		[6] = {
			base_texture = "classic_coaches_open_coach_class2_006.png",
			overlays = {
				[1] = {name = S("Side Walls"),		texture = "classic_coaches_overlay_006_side_walls.png",				alpha = default_wall_alpha},
				[2] = {name = S("Roof"),			texture = "classic_coaches_overlay_006_roof.png",					alpha = default_roof_alpha},
				[3] = {name = S("Trim"),			texture = "classic_coaches_overlay_006_trim.png"},
				[4] = {name = S("Logo"),			texture = "classic_coaches_overlay_cc_logo_2.png"},
				[5] = {name = S("End Doors"),		texture = "classic_coaches_overlay_end_doors.png",					alpha = default_wall_alpha},
			},
		},
		[7] = {
			base_texture = "classic_coaches_open_coach_class2_007.png",
			overlays = {
				[1] = {name = S("Exterior Walls"),	texture = "classic_coaches_overlay_007_class2_exterior_walls.png",	alpha = default_wall_alpha},
				[2] = {name = S("Seats"),			texture = "classic_coaches_overlay_seats.png",						alpha = default_seat_alpha},
				[3] = {name = S("Decoration"),		texture = "classic_coaches_overlay_007_decoration.png"},
				[4] = {name = S("Label"),			texture = "classic_coaches_overlay_007_label.png"},
				[5] = {name = S("Class Number"),	texture = "classic_coaches_overlay_class2_class_number.png"},
				[6] = {name = S("Logo and Text"),	texture = "classic_coaches_overlay_007_logo_text.png"},
			},
		},
	},
}

-- Note: While all of the following predefined liveries will be registered
-- for all of the wagon types defined in this mod, it is not required and
-- might not be true if new wagons are added in the future.

local predefined_liveries = {
	{
		name = S("CC Classic"),
		notes = "",
		livery_design = {
			livery_template_name = S("CC Window Band"),
			overlays = {
				[1] = {id = 1,	color = "#FAF0E6"},	-- "Side Walls",
				[2] = {id = 2,	color = "#202020"},	-- "Window Band",
				[3] = {id = 3,	color = "#800000"},	-- "Decoration",
--				[4] = {id = 4,	color = "#000000"},	-- "Logo",
				[5] = {id = 5,	color = "#FAF0E6"},	-- "Class Number",
			},
		},
	},
	{
		name = S("CC Classic Double Stripe"),
		notes = "",
		livery_design = {
			livery_template_name = S("CC Edged Stripe"),
			overlays = {
				[1] = {id = 1,	color = "#FAF0E6"},	-- "Side Walls",
				[2] = {id = 2,	color = "#FAF0E6"},	-- "Stripe",
				[3] = {id = 3,	color = "#800000"},	-- "Stripe Edges",
--				[4] = {id = 4,	color = "#000000"},	-- "Logo",
--				[5] = {id = 5,	color = "#000000"},	-- "End Doors",
			},
		},
	},
	{
		name = S("CC Intercity Urban"),
		notes = "",
		livery_design = {
			livery_template_name = S("CC Intercity Stripe"),
			overlays = {
				[1] = {id = 1,	color = "#808080"},	-- "Exterior Walls",
				[2] = {id = 2,	color = "#006400"},	-- "Stripe",
--				[3] = {id = 3,	color = "#000000"},	-- "Service Stripe",
				[4] = {id = 4,	color = "#808080"},	-- "Side Doors",
--				[5] = {id = 5,	color = "#000000"},	-- "Class Number",
			},
		},
	},
	{
		name = S("CC Intercity Dark Olive"),
		notes = "",
		livery_design = {
			livery_template_name = S("CC Intercity Stripe"),
			overlays = {
				[1] = {id = 1,	color = "#516200"},	-- "Exterior Walls",
--				[2] = {id = 2,	color = "#000000"},	-- "Stripe",
--				[3] = {id = 3,	color = "#000000"},	-- "Service Stripe",
--				[4] = {id = 4,	color = "#000000"},	-- "Side Doors",
--				[5] = {id = 5,	color = "#000000"},	-- "Class Number",
			},
		},
	},
	{
		name = S("CC Legacy Solid Red"),
		notes = "",
		livery_design = {
			livery_template_name = S("CC Solid Color"),
			overlays = {
				[1] = {id = 1,	color = "#800000"},	-- "Side Walls",
				[2] = {id = 2,	color = "#2E8B57"},	-- "Seats",
				[3] = {id = 3,	color = "#DAA520"},	-- "Service Stripe",
				[4] = {id = 4,	color = "#FAF0E6"},	-- "Logo",
--				[5] = {id = 5,	color = "#FAF0E6"},	-- "Class Number",
			},
		},
	},
	{
		name = S("CC Modern Brown Stripe"),
		notes = "",
		livery_design = {
			livery_template_name = S("CC Stripe"),
			overlays = {
--				[1] = {id = 1,	color = "#000000"},	-- "Side Walls",
				[2] = {id = 2,	color = "#8B4513"},	-- "Stripe",
				[3] = {id = 3,	color = "#DAA520"},	-- "Stripe Divider",
--				[4] = {id = 4,	color = "#000000"},	-- "Side Doors",
--				[5] = {id = 5,	color = "#000000"},	-- "Class Number",
			},
		},
	},
	{
		name = S("CC Slate Roof"),
		notes = "",
		livery_design = {
			livery_template_name = S("CC Colored Roof"),
			overlays = {
				[1] = {id = 1,	color = "#708090"},	-- "Side Walls",
				[2] = {id = 2,	color = "#2F4F4F"},	-- "Roof",
				[3] = {id = 3,	color = "#2F4F4F"},	-- "Trim",
				[4] = {id = 4,	color = "#2F4F4F"},	-- "Logo",
				[5] = {id = 5,	color = "#708090"},	-- "End Doors",
			},
		},
	},
	{
		name = S("CC Legacy Express"),
		notes = "",
		livery_design = {
			livery_template_name = S("CC Express"),
			overlays = {
				[1] = {id = 1,	color = "#400000"},	-- "Exterior Walls",
				[2] = {id = 2,	color = "#000030"},	-- "Seats",
--				[3] = {id = 3,	color = "#000000"},	-- "Decoration",
--				[4] = {id = 4,	color = "#000000"},	-- "Label",
--				[5] = {id = 5,	color = "#000000"},	-- "Class Number",
--				[6] = {id = 6,	color = "#000000"},	-- "Logo",
			},
		},
	},
	{
		name = S("No Logo Solid Green"),
		notes = "",
		livery_design = {
			livery_template_name = S("CC Solid Color"),
			overlays = {
				[1] = {id = 1,	color = "#004000"},	-- "Side Walls",
--				[2] = {id = 2,	color = "#000000"},	-- "Seats",
--				[3] = {id = 3,	color = "#000000"},	-- "Service Stripe",
				[4] = {id = 4,	color = "#004000"},	-- "Logo",
--				[5] = {id = 5,	color = "#000000"},	-- "Class Number",
			},
		},
	},
	{
		name = S("No Logo Retro Mojo"),
		notes = "",
		livery_design = {
			livery_template_name = S("CC Window Band"),
			overlays = {
				[1] = {id = 1,	color = "#008080"},	-- "Side Walls",
				[2] = {id = 2,	color = "#FAF0E6"},	-- "Window Band",
				[3] = {id = 3,	color = "#FAF0E6"},	-- "Decoration",
				[4] = {id = 4,	color = "#008080"},	-- "Logo",
--				[5] = {id = 5,	color = "#000000"},	-- "Class Number",
			},
		},
	},
	{
		name = S("No Logo Classic Express"),
		notes = "",
		livery_design = {
			livery_template_name = S("CC Express"),
			overlays = {
--				[1] = {id = 1,	color = "#000000"},	-- "Exterior Walls",
--				[2] = {id = 2,	color = "#000000"},	-- "Seats",
--				[3] = {id = 3,	color = "#000000"},	-- "Decoration",
--				[4] = {id = 4,	color = "#000000"},	-- "Label",
--				[5] = {id = 5,	color = "#000000"},	-- "Class Number",
				[6] = {id = 6,	color = "#000030"},	-- "Logo",
			},
		},
	},
	{
		name = S("No Logo Evergreen Express"),
		notes = "",
		livery_design = {
			livery_template_name = S("CC Express"),
			overlays = {
				[1] = {id = 1,	color = "#003B00"},	-- "Exterior Walls",
				[2] = {id = 2,	color = "#2E8B57"},	-- "Seats",
				[3] = {id = 3,	color = "#008000"},	-- "Decoration",
--				[4] = {id = 4,	color = "#000000"},	-- "Label",
--				[5] = {id = 5,	color = "#000000"},	-- "Class Number",
				[6] = {id = 6,	color = "#003B00"},	-- "Logo",
			},
		},
	},
	{
		name = S("No Logo Expresso Express"),
		notes = "",
		livery_design = {
			livery_template_name = S("CC Express"),
			overlays = {
				[1] = {id = 1,	color = "#703000"},	-- "Exterior Walls",
				[2] = {id = 2,	color = "#D2B48C"},	-- "Seats",
				[3] = {id = 3,	color = "#FFA500"},	-- "Decoration",
				[4] = {id = 4,	color = "#FF8C00"},	-- "Label",
--				[5] = {id = 5,	color = "#000000"},	-- "Class Number",
				[6] = {id = 6,	color = "#703000"},	-- "Logo",
			},
		},
	},
}

-- ===============================================================================================================================================

if use_advtrains_livery_designer then
	-- Notify player if a newer version of AdvTrains Livery Tools is available or needed.
	if not advtrains_livery_designer.is_compatible_mod_version or
	   not advtrains_livery_designer.is_compatible_mod_version({major = 0, minor = 8, patch = 4}) then
		minetest.log("info", "["..mod_name.."] An old version of AdvTrains Livery Tools was detected. Consider updating to the latest version.")
		-- Version 0.8.4 is not currently required so just log an informational message.
	end

	-- This function is called by the advtrains_livery_designer tool whenever the player
	-- activates the "Apply" button. The texture and/or the mesh could optionally be
	-- modified here, if needed.
	local function apply_wagon_livery_textures(player, wagon, textures)
		if wagon and textures and textures[1] then
			local data = advtrains.wagons[wagon.id]
			data.livery = textures[1]
			wagon:set_textures(data)
		end
	end

	-- Register this mod and its livery functions with the advtrains_livery_designer tool.
	advtrains_livery_designer.register_mod(mod_name, apply_wagon_livery_textures)

	-- Register this mod's wagons.
	for _, wagon in ipairs(wagons) do
		advtrains_livery_database.register_wagon(wagon.wagon_type)
	end

	-- Register this mod's livery templates with the advtrains_livery_designer tool.
	for wagon_type, wagon_livery_templates in pairs(livery_templates) do
		for livery_template_id, livery_template in pairs(wagon_livery_templates) do
			local livery_template_name = livery_template_names[livery_template_id].name
			if livery_template_name then
				advtrains_livery_database.add_livery_template(
					wagon_type,
					livery_template_name,
					{livery_template.base_texture},
					mod_name,
					(livery_template.overlays and #livery_template.overlays) or 0,
					"Marnack",		-- Template designer
					"CC-BY-SA-3.0",	-- Texture license
					"Marnack",		-- Texture creator(s)
					livery_template_names[livery_template_id].notes
				)
				if livery_template.overlays then
					for overlay_id, overlay in ipairs(livery_template.overlays) do
						advtrains_livery_database.add_livery_template_overlay(
							wagon_type,
							livery_template_name,
							overlay_id,
							overlay.name,
							1,
							overlay.texture,
							overlay.alpha
						)
					end
				end
			end
		end
	end

	-- Register this mod's predefined wagon liveries with the advtrains_livery_designer tool.
	for _, predefined_livery in pairs(predefined_liveries) do
		-- Each predefined livery will be defined for each wagon type.  This may not be true in the future.
		for _, wagon in pairs(wagons) do
			local livery_design = predefined_livery.livery_design
			livery_design.wagon_type = wagon.wagon_type
			advtrains_livery_database.add_predefined_livery(predefined_livery.name, livery_design, mod_name, predefined_livery.notes)
		end
	end
end

-- ===============================================================================================================================================

-- This function is used when updating the wagon's livery with the bike painter tool.
-- Although the bike painter can currently only paint the first overlay, this implementation
-- will handle multiple overlays if that restriction changes.
local function get_wagon_texture(wagon_type, livery_template_id, overlays)

	-- Get and then verify that the base texture is valid
	local wagon_texture = livery_templates[wagon_type][livery_template_id].base_texture
	if not wagon_texture then
		return nil
	end

	-- Append overlay clause(s) to the wagon texture based on the given overlays.
	-- Note that any of the given overlays that are not valid for the specified
	-- wagon type will be ignored.
	if overlays and livery_templates[wagon_type][livery_template_id].overlays then
		for _, overlay in ipairs(overlays) do
			if overlay.id and overlay.color and
			   livery_templates[wagon_type][livery_template_id].overlays[overlay.id] and
			   livery_templates[wagon_type][livery_template_id].overlays[overlay.id].texture then
				local alpha = livery_templates[wagon_type][livery_template_id].overlays[overlay.id].alpha or 255
				if alpha < 0 then alpha = 0 end
				if alpha > 255 then alpha = 255 end
				local overlay_texture = "^("..
						livery_templates[wagon_type][livery_template_id].overlays[overlay.id].texture..
						"^[colorize:"..overlay.color..":"..alpha..
						")"
				wagon_texture = wagon_texture..overlay_texture
			end
		end
	end

	return wagon_texture
end

-- The following enables the bike painter to colorize the first overlay.
local function set_livery(wagon, puncher, itemstack, data)
	local meta = itemstack:get_meta()
	local color = meta:get_string("paint_color")
	if not color or not color:find("^#%x%x%x%x%x%x$") then
		return
	end

	local alpha = tonumber(meta:get_string("alpha"))
	if not alpha then
		return
	end

	-- The alpha value is used to select the livery template. Note that the alpha
	-- values can range from 0 to 255. Livery template ids start with 1. Livery
	-- template ids greater than the number of defined livery tempaltes will cause
	-- the painter to have no effect.
	local livery_template_id = alpha + 1
	if not livery_template_names[livery_template_id] then
		return
	end

	-- It is possible that a given livery template may not be defined for all
	-- wagon types.
	local wagon_type = data.type
	if not livery_templates[wagon_type] or
	   not livery_templates[wagon_type][livery_template_id] or
	   not livery_templates[wagon_type][livery_template_id].base_texture then
		return
	end

	-- Using the bike painter only allows for the first overlay to be
	-- colorized. Also, the color "#000000" is reserved and used to
	-- force the livery tempalte to be displayed without any color overrides.
	-- This is only true when using the painter.
	local overlays = {}
	if color ~= "#000000" and livery_templates[wagon_type][livery_template_id].overlays then
		overlays = {[1] = {id = 1, color = color}}
	end

	local wagon_texture = get_wagon_texture(wagon_type, livery_template_id, overlays)
	if not wagon_texture then
		return
	end

	data.livery = wagon_texture
	wagon:set_textures(data)
end

local function set_textures(wagon, data)
	if data.livery then
		wagon.object:set_properties({textures={data.livery}})
	end
end

local function update_livery(wagon, puncher)
	local itemstack = puncher:get_wielded_item()
	local item_name = itemstack:get_name()
	if use_advtrains_livery_designer and item_name == advtrains_livery_designer.tool_name then
		advtrains_livery_designer.activate_tool(puncher, wagon, mod_name)
		return true
	end
	return false
end

----------------------------------------------------------------------------------------

for _, wagon in pairs(wagons) do
	advtrains.register_wagon(wagon.wagon_type, {
		mesh = wagon.mesh,
		textures = wagon.textures,
		set_textures = set_textures,
		set_livery = set_livery,
		custom_may_destroy = function(wgn, puncher, time_from_last_punch, tool_capabilities, direction)
			return not update_livery(wgn, puncher)
		end,
		drives_on={default=true},
		max_speed=20,
		seats = {
			{
				name="1",
				attach_offset={x=0, y=-2, z=17},
				view_offset={x=0, y=-1.7, z=0},
				group="pass",
			},
			{
				name="2",
				attach_offset={x=0, y=-2, z=6},
				view_offset={x=0, y=-1.7, z=0},
				group="pass",
			},
			{
				name="3",
				attach_offset={x=0, y=-2, z=-6},
				view_offset={x=0, y=-1.7, z=0},
				group="pass",
			},
			{
				name="4",
				attach_offset={x=0, y=-2, z=-17},
				view_offset={x=0, y=-1.7, z=0},
				group="pass",
			},
		},
		seat_groups = {
			pass={
				name = "Passenger area",
				access_to = {},
				require_doors_open=true,
			},
		},
		doors={
			open={
				[-1]={frames={x=21, y=30}, time=1},
				[1]={frames={x=1, y=10}, time=1}
			},
			close={
				[-1]={frames={x=30, y=41}, time=1},
				[1]={frames={x=10, y=20}, time=1}
			}
		},
		door_entry={-2, 2},
		assign_to_seat_group = {"pass"},
		visual_size = {x=1, y=1},
		wagon_span=3,
		wheel_positions = {1.9, -1.9},
		collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
		coupler_types_front = {chain=true},
		coupler_types_back = {chain=true},
		drops={materials.steelblock},
	}, wagon.name, wagon.inventory_image)

	-- Only register crafting recipes for the wagon if the needed mods are available.
	if materials.base_game then
		minetest.register_craft({
			output = wagon.wagon_type,
			recipe = wagon.recipe,
		})
	end
end
