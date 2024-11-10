-- NOTICE: This code borrows from the `advtrains_train_track` mod
-- maintained by orwell (https://content.minetest.net/users/orwell/)
-- and other users. See the Advtrains git repo (https://git.bananach.space/advtrains.git)
-- and their website (https://advtrains.de) for more information.

-- Flat
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_tieless",
	texture_prefix="advtrains_dtrack_tieless",
	models_prefix="advtrains_dtrack_tieless",
	models_suffix=".b3d",
	shared_texture="advtrains_dtrack_tieless_shared.png",
	description=attrans("Track").." "..attrans("(Tieless)"),
	formats={},
}, advtrains.ap.t_30deg_flat)

minetest.register_craft({
	output = 'advtrains:dtrack_tieless_placer 50',
	recipe = {
		{'default:steel_ingot', '', 'default:steel_ingot'},
		{'default:steel_ingot', '', 'default:steel_ingot'},
		{'default:steel_ingot', '', 'default:steel_ingot'},
	},
})

-- Y-turnout
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_sy_tieless",
	texture_prefix="advtrains_dtrack_sy_tieless",
	models_prefix="advtrains_dtrack_sy_tieless",
	models_suffix=".obj",
	shared_texture="advtrains_dtrack_tieless_shared.png",
	description=attrans("Y-turnout").." "..attrans("(Tieless)"),
	formats = {},
}, advtrains.ap.t_yturnout)

minetest.register_craft({
	output = 'advtrains:dtrack_sy_tieless_placer 2',
	recipe = {
		{'advtrains:dtrack_tieless_placer', '', 'advtrains:dtrack_tieless_placer'},
		{'', 'advtrains:dtrack_tieless_placer', ''},
		{'', 'advtrains:dtrack_tieless_placer', ''},
	},
})

-- 3-way turnout
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_s3_tieless",
	texture_prefix="advtrains_dtrack_s3_tieless",
	models_prefix="advtrains_dtrack_s3_tieless",
	models_suffix=".obj",
	shared_texture="advtrains_dtrack_tieless_shared.png",
	description=attrans("3-way turnout").." "..attrans("(Tieless)"),
	formats = {},
}, advtrains.ap.t_s3way)

minetest.register_craft({
	output = 'advtrains:dtrack_s3_tieless_placer 1',
	recipe = {
		{'advtrains:dtrack_tieless_placer', 'advtrains:dtrack_tieless_placer', 'advtrains:dtrack_tieless_placer'},
		{'', 'advtrains:dtrack_tieless_placer', ''},
		{'', '', ''},
	},
})

-- Perpendicular Crossing
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_xing_tieless",
	texture_prefix="advtrains_dtrack_xing_tieless",
	models_prefix="advtrains_dtrack_xing_tieless",
	models_suffix=".obj",
	shared_texture="advtrains_dtrack_tieless_shared.png",
	description=attrans("Perpendicular Diamond Crossing Track").." "..attrans("(Tieless)"),
	formats = {}
}, advtrains.ap.t_perpcrossing)

minetest.register_craft({
	output = 'advtrains:dtrack_xing_tieless_placer 3',
	recipe = {
		{'', 'advtrains:dtrack_tieless_placer', ''},
		{'advtrains:dtrack_tieless_placer', 'advtrains:dtrack_tieless_placer', 'advtrains:dtrack_tieless_placer'},
		{'', 'advtrains:dtrack_tieless_placer', ''}
	}
})

-- 90plusx
-- When you face east and param2=0, then this set of rails has a rail at 90
-- degrees to the viewer, plus another rail crossing at 30, 45 or 60 degrees.
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_xing90plusx_tieless",
	texture_prefix="advtrains_dtrack_xing4590_tieless",
	models_prefix="advtrains_dtrack_xing90plusx_tieless",
	models_suffix=".obj",
	shared_texture="advtrains_dtrack_tieless_shared.png",
	description=attrans("90+Angle Diamond Crossing Track").." "..attrans("(Tieless)"),
	formats = {}
}, advtrains.ap.t_90plusx_crossing)

minetest.register_craft({
	output = 'advtrains:dtrack_xing90plusx_tieless_placer 2',
	recipe = {
		{'advtrains:dtrack_tieless_placer', '', ''},
		{'advtrains:dtrack_tieless_placer', 'advtrains:dtrack_tieless_placer', 'advtrains:dtrack_tieless_placer'},
		{'', '', 'advtrains:dtrack_tieless_placer'}
	}
})

-- Slopes
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_tieless",
	texture_prefix="advtrains_dtrack_tieless",
	models_prefix="advtrains_dtrack",
	models_suffix=".obj",
	shared_texture="advtrains_dtrack_tieless_shared.png",
	second_texture="default_gravel.png",
	description=attrans("Track").." "..attrans("(Tieless)"),
	formats={vst1={true, false, true}, vst2={true, false, true}, vst31={true}, vst32={true}, vst33={true}},
}, advtrains.ap.t_30deg_slope)

minetest.register_craft({
	type = "shapeless",
	output = 'advtrains:dtrack_tieless_slopeplacer 2',
	recipe = {
		"advtrains:dtrack_tieless_placer",
		"advtrains:dtrack_tieless_placer",
		"default:gravel",
	},
})

advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_tieless_rg",
	texture_prefix="advtrains_dtrack_tieless_rg",
	models_prefix="advtrains_dtrack",
	models_suffix=".obj",
	shared_texture="advtrains_dtrack_tieless_shared.png",
	second_texture="default_gravel.png^[multiply:#956338",
	description=attrans("Track with Railway Gravel").." "..attrans("(Tieless)"),
	formats={vst1={true, false, true}, vst2={true, false, true}, vst31={true}, vst32={true}, vst33={true}},
}, advtrains.ap.t_30deg_slope)

minetest.register_craft({
	type = "shapeless",
	output = 'advtrains:dtrack_tieless_rg_slopeplacer 2',
	recipe = {
		"advtrains:dtrack_tieless_placer",
		"advtrains:dtrack_tieless_placer",
		"ch_core:railway_gravel",
	},
})

-- Station/stop rail
-- ##################################################################################################################################
if advtrains.station_stop_rail_additional_definition ~= nil and minetest.get_modpath("advtrains_train_track") ~= nil then
	advtrains.register_tracks("default", {
		nodename_prefix="advtrains_line_automation:dtrack_stop_tieless",
		texture_prefix="advtrains_dtrack_stop_tieless",
		models_prefix="advtrains_dtrack_tieless",
		models_suffix=".b3d",
		shared_texture="advtrains_dtrack_shared_stop_tieless.png",
		description=attrans("Station/Stop Rail").." "..attrans("(Tieless)"),
		formats={},
		get_additional_definiton = advtrains.station_stop_rail_additional_definition,
	}, advtrains.trackpresets.t_30deg_straightonly)

	minetest.register_craft({
		output = "advtrains_line_automation:dtrack_stop_tieless_placer 2",
		recipe = {
			{"default:coal_lump", ""},
			{"advtrains:dtrack_tieless_placer", "advtrains:dtrack_tieless_placer"},
		},
	})
end
