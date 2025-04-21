ch_base.open_mod(minetest.get_current_modname())
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
	formats=advtrains.default_slope_formats.t_30deg_slope,
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
	second_texture="ch_extras_gravel.png",
	description=attrans("Track with Railway Gravel").." "..attrans("(Tieless)"),
	formats=advtrains.default_slope_formats.t_30deg_slope,
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

-- Concrete track
-- ##################################################################################################################################

--flat
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_concrete",
	texture_prefix="advtrains_ctrack",
	models_prefix="advtrains_dtrack",
	models_suffix=".b3d",
	shared_texture="advtrains_ctrack_shared.png",
	description=attrans("Track").." (betonové pražce)",
	formats={},
}, advtrains.ap.t_30deg_flat)

minetest.register_craft({
	output = 'advtrains:dtrack_concrete_placer 50',
	recipe = {
		{'default:steel_ingot', 'technic:panel_concrete_1', 'default:steel_ingot'},
		{'default:steel_ingot', 'technic:panel_concrete_1', 'default:steel_ingot'},
		{'default:steel_ingot', 'technic:panel_concrete_1', 'default:steel_ingot'},
	},
})

minetest.register_craft({
	output = 'advtrains:dtrack_concrete_placer 50',
	recipe = {
		{'default:steel_ingot', 'technic:panel_concrete_2', 'default:steel_ingot'},
		{'default:steel_ingot', 'technic:panel_concrete_2', 'default:steel_ingot'},
		{'default:steel_ingot', 'technic:panel_concrete_2', 'default:steel_ingot'},
	},
})

-- y-turnout
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_sy_concrete",
	texture_prefix="advtrains_ctrack_sy",
	models_prefix="advtrains_dtrack_sy",
	models_suffix=".obj",
	shared_texture="advtrains_ctrack_shared.png",
	description=attrans("Y-turnout").." (betonové pražce)",
	formats = {},
}, advtrains.ap.t_yturnout)
minetest.register_craft({
	output = 'advtrains:dtrack_sy_concrete_placer 2',
	recipe = {
		{'advtrains:dtrack_concrete_placer', '', 'advtrains:dtrack_concrete_placer'},
		{'', 'advtrains:dtrack_concrete_placer', ''},
		{'', 'advtrains:dtrack_concrete_placer', ''},
	},
})
--3-way turnout
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_s3_concrete",
	texture_prefix="advtrains_ctrack_s3",
	models_prefix="advtrains_dtrack_s3",
	models_suffix=".obj",
	shared_texture="advtrains_ctrack_shared.png",
	description=attrans("3-way turnout").." (betonové pražce)",
	formats = {},
}, advtrains.ap.t_s3way)
minetest.register_craft({
	output = 'advtrains:dtrack_s3_concrete_placer 1',
	recipe = {
		{'advtrains:dtrack_concrete_placer', 'advtrains:dtrack_concrete_placer', 'advtrains:dtrack_concrete_placer'},
		{'', 'advtrains:dtrack_concrete_placer', ''},
		{'', '', ''},
	},
})

-- Diamond Crossings
-- perpendicular
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_xing_concrete",
	texture_prefix="advtrains_ctrack_xing",
	models_prefix="advtrains_dtrack_xing",
	models_suffix=".obj",
	shared_texture="advtrains_ctrack_shared.png",
	description=attrans("Perpendicular Diamond Crossing Track").." (betonové pražce)",
	formats = {}
}, advtrains.ap.t_perpcrossing)

minetest.register_craft({
	output = 'advtrains:dtrack_xing_concrete_placer 3',
	recipe = {
		{'', 'advtrains:dtrack_concrete_placer', ''},
		{'advtrains:dtrack_concrete_placer', 'advtrains:dtrack_concrete_placer', 'advtrains:dtrack_concrete_placer'},
		{'', 'advtrains:dtrack_concrete_placer', ''}
	}
})

-- 90plusx
-- When you face east and param2=0, then this set of rails has a rail at 90
-- degrees to the viewer, plus another rail crossing at 30, 45 or 60 degrees.
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_xing90plusx_concrete",
	texture_prefix="advtrains_ctrack_xing4590",
	models_prefix="advtrains_dtrack_xing90plusx",
	models_suffix=".obj",
	shared_texture="advtrains_ctrack_shared.png",
	description=attrans("90+Angle Diamond Crossing Track").." (betonové pražce)",
	formats = {}
}, advtrains.ap.t_90plusx_crossing)
minetest.register_craft({
	output = 'advtrains:dtrack_xing90plusx_concrete_placer 2',
	recipe = {
		{'advtrains:dtrack_concrete_placer', '', ''},
		{'advtrains:dtrack_concrete_placer', 'advtrains:dtrack_concrete_placer', 'advtrains:dtrack_concrete_placer'},
		{'', '', 'advtrains:dtrack_concrete_placer'}
	}
})

-- Diagonal
-- This set of rail crossings is named based on the angle of each intersecting
-- direction when facing east and param2=0. Rails with l/r swapped are mirror
-- images. For example, 30r45l is the mirror image of 30l45r.
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_xingdiag_concrete",
	texture_prefix="advtrains_ctrack_xingdiag",
	models_prefix="advtrains_dtrack_xingdiag",
	models_suffix=".obj",
	shared_texture="advtrains_ctrack_shared.png",
	description=attrans("Diagonal Diamond Crossing Track").." (betonové pražce)",
	formats = {},
}, advtrains.ap.t_diagonalcrossing)
minetest.register_craft({
	output = 'advtrains:dtrack_xingdiag_concrete_placer 2',
	recipe = {
		{'advtrains:dtrack_concrete_placer', '', 'advtrains:dtrack_concrete_placer'},
		{'', 'advtrains:dtrack_concrete_placer', ''},
		{'advtrains:dtrack_concrete_placer', '', 'advtrains:dtrack_concrete_placer'}
	}
})
---- Not included: very shallow crossings like (30/60)+45.
---- At an angle of only 18.4 degrees, the models would not
---- translate well to a block game.
-- END crossings

--slopes
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_concrete",
	texture_prefix="advtrains_ctrack",
	models_prefix="advtrains_dtrack",
	models_suffix=".obj",
	shared_texture="advtrains_ctrack_shared.png",
	second_texture="default_gravel.png",
	description=attrans("Track").." (betonové pražce)",
	formats=advtrains.default_slope_formats.t_30deg_slope,
}, advtrains.ap.t_30deg_slope)

minetest.register_craft({
	type = "shapeless",
	output = 'advtrains:dtrack_concrete_slopeplacer 2',
	recipe = {
		"advtrains:dtrack_concrete_placer",
		"advtrains:dtrack_concrete_placer",
		"default:gravel",
	},
})

advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_rg_concrete",
	texture_prefix="advtrains_ctrack_rg",
	models_prefix="advtrains_dtrack",
	models_suffix=".obj",
	shared_texture="advtrains_ctrack_shared.png",
	second_texture="ch_extras_gravel.png",
	description=attrans("Track with Railway Gravel").." (betonové pražce)",
	formats=advtrains.default_slope_formats.t_30deg_slope,
}, advtrains.ap.t_30deg_slope)

minetest.register_craft({
	type = "shapeless",
	output = 'advtrains:dtrack_rg_concrete_slopeplacer 2',
	recipe = {
		"advtrains:dtrack_concrete_placer",
		"advtrains:dtrack_concrete_placer",
		"ch_extras:railway_gravel",
	},
})


--bumpers
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_bumper_concrete",
	texture_prefix="advtrains_ctrack_bumper",
	models_prefix="advtrains_dtrack_bumper",
	models_suffix=".b3d",
	shared_texture="advtrains_ctrack_rail.png",
	--bumpers still use the old texture until the models are redone.
	description=attrans("Bumper").." (betonové pražce)",
	formats={},
}, advtrains.ap.t_30deg_straightonly)
minetest.register_craft({
	output = 'advtrains:dtrack_bumper_concrete_placer 2',
	recipe = {
		{'group:wood', 'dye:red'},
		{'default:steel_ingot', 'default:steel_ingot'},
		{'advtrains:dtrack_concrete_placer', 'advtrains:dtrack_concrete_placer'},
	},
})

-- atc track
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_atc_concrete",
	texture_prefix="advtrains_ctrack_atc",
	models_prefix="advtrains_dtrack",
	models_suffix=".b3d",
	shared_texture="advtrains_ctrack_shared_atc.png",
	description=attrans("ATC controller").." (betonové pražce)",
	formats={},
	get_additional_definiton = advtrains.atc_function
}, advtrains.trackpresets.t_30deg_straightonly)

minetest.register_craft({
	output = "advtrains:dtrack_atc_concrete_placer",
	recipe = {
		{"mesecons_microcontroller:microcontroller0000", ""},
		{"advtrains:dtrack_concrete_placer", ""},
	},
})

-- Tracks for loading and unloading trains
-- Copyright (C) 2017 Gabriel Pérez-Cerezo <gabriel@gpcf.eu>

local dtrack_load_st = core.registered_nodes["advtrains:dtrack_load_st"]
local dtrack_unload_st = core.registered_nodes["advtrains:dtrack_unload_st"]

if dtrack_load_st ~= nil and dtrack_unload_st ~= nil then
	advtrains.register_tracks("default", {
		nodename_prefix="advtrains:dtrack_unload_concrete",
		texture_prefix="advtrains_ctrack_unload",
		models_prefix="advtrains_dtrack",
		models_suffix=".b3d",
		shared_texture="advtrains_ctrack_shared_unload.png",
		description=attrans("Unloading Track").." (betonové pražce)",
		formats={},
		get_additional_definiton = function(def, preset, suffix, rotation)
			return {
				after_dig_node = dtrack_unload_st.after_dig_node,
				on_rightclick = dtrack_unload_st.on_rightclick,
				advtrains = dtrack_unload_st.advtrains,
			}
		end
	}, advtrains.trackpresets.t_30deg_straightonly)

	advtrains.register_tracks("default", {
		nodename_prefix="advtrains:dtrack_load_concrete",
		texture_prefix="advtrains_ctrack_load",
		models_prefix="advtrains_dtrack",
		models_suffix=".b3d",
		shared_texture="advtrains_ctrack_shared_load.png",
		description=attrans("Loading Track").." (betonové pražce)",
		formats={},
		get_additional_definiton = function(def, preset, suffix, rotation)
			return {
				after_dig_node = dtrack_load_st.after_dig_node,
				on_rightclick = dtrack_load_st.on_rightclick,
				advtrains = dtrack_load_st.advtrains,
			}
		end
	}, advtrains.trackpresets.t_30deg_straightonly)
end

-- mod-dependent crafts
local loader_core = "default:mese_crystal"  --fallback
if minetest.get_modpath("basic_materials") then
	loader_core = "basic_materials:ic"
elseif minetest.get_modpath("technic") then
	loader_core = "technic:control_logic_unit"
end
--print("Loader Core: "..loader_core)

minetest.register_craft({
	type="shapeless",
	output = 'advtrains:dtrack_load_concrete_placer',
	recipe = {
		"advtrains:dtrack_concrete_placer",
		loader_core,
		"default:chest"
	},
})
loader_core = nil --nil the crafting variable

--craft between load/unload tracks
minetest.register_craft({
	type="shapeless",
	output = 'advtrains:dtrack_unload_concrete_placer',
	recipe = {
		"advtrains:dtrack_load_concrete_placer",
	},
})
minetest.register_craft({
	type="shapeless",
	output = 'advtrains:dtrack_load_concrete_placer',
	recipe = {
		"advtrains:dtrack_unload_concrete_placer",
	},
})

if core.registered_nodes["advtrains:dtrack_detector_off_st"] ~= nil then
	advtrains.register_tracks("default", {
		nodename_prefix="advtrains:dtrack_detector_concrete_off",
		texture_prefix="advtrains_ctrack_detector",
		models_prefix="advtrains_dtrack",
		models_suffix=".b3d",
		shared_texture="advtrains_ctrack_shared_detector_off.png",
		description=attrans("Detector Rail").." (betonové pražce)",
		formats={},
		get_additional_definiton = function(def, preset, suffix, rotation)
			local old_def = core.registered_nodes["advtrains:dtrack_detector_off_"..suffix..rotation]
			if old_def == nil then
				return {}
			else
				return {
					mesecons = old_def.mesecons,
					advtrains = {
						on_updated_from_nodedb = old_def.advtrains.on_updated_from_nodedb,
						on_train_enter = function(pos, train_id)
							advtrains.ndb.swap_node(pos, {name="advtrains:dtrack_detector_concrete_on".."_"..suffix..rotation, param2=advtrains.ndb.get_node(pos).param2})
							if advtrains.is_node_loaded(pos) then
								mesecon.receptor_on(pos, advtrains.meseconrules)
							end
						end
					}
				}
			end
		end
	}, advtrains.ap.t_30deg_straightonly)
end

if core.registered_nodes["advtrains:dtrack_detector_on_st"] ~= nil then
	advtrains.register_tracks("default", {
		nodename_prefix="advtrains:dtrack_detector_concrete_on",
		texture_prefix="advtrains_ctrack",
		models_prefix="advtrains_dtrack",
		models_suffix=".b3d",
		shared_texture="advtrains_ctrack_shared_detector_on.png",
		description="Detector(on)(you hacker you)",
		formats={},
		get_additional_definiton = function(def, preset, suffix, rotation)
			local old_def = core.registered_nodes["advtrains:dtrack_detector_on_"..suffix..rotation]
			if old_def == nil then
				return {}
			else
				return {
					mesecons = old_def.mesecons,
					advtrains = {
						on_updated_from_nodedb = old_def.advtrains.on_updated_from_nodedb,
						on_train_leave=function(pos, train_id)
							advtrains.ndb.swap_node(pos, {name="advtrains:dtrack_detector_concrete_off".."_"..suffix..rotation, param2=advtrains.ndb.get_node(pos).param2})
							if advtrains.is_node_loaded(pos) then
								mesecon.receptor_off(pos, advtrains.meseconrules)
							end
						end
					}
				}
			end
		end
	}, advtrains.ap.t_30deg_straightonly_noplacer)
	minetest.register_craft({
		type="shapeless",
		output = 'advtrains:dtrack_detector_concrete_off_placer',
		recipe = {
			"advtrains:dtrack_concrete_placer",
			"mesecons:wire_00000000_off"
		},
	})
end

if core.registered_nodes["advtrains:dtrack_rdetector_off_st"] ~= nil then
	advtrains.register_tracks("default", {
		nodename_prefix="advtrains:dtrack_rdetector_concrete_off",
		texture_prefix="advtrains_ctrack_detector",
		models_prefix="advtrains_dtrack",
		models_suffix=".b3d",
		shared_texture="advtrains_ctrack_shared_rdetector_off.png",
		description=attrans("Remote Detector Rail").." (betonové pražce)",
		formats={},
		get_additional_definiton = function(def, preset, suffix, rotation)
			local old_def = core.registered_nodes["advtrains:dtrack_detector_off_"..suffix..rotation]
			if old_def == nil then
				return {}
			else
				return {
					mesecons = old_def.mesecons,
					after_dig_node = old_def.after_dig_node,
					drop = "advtrains:dtrack_rdetector_concrete_off_placer",
					advtrains = old_def.advtrains,
				}
			end	
		end
	}, advtrains.ap.t_30deg_straightonly)

	core.register_craft({
		output = "advtrains:dtrack_rdetector_concrete_off_placer",
		recipe = {
			{"advtrains:dtrack_detector_concrete_off_placer", "default:mese_crystal"},
			{"", ""},
		},
	})
	core.register_alias("advtrains:dtrack_rdetector_off_concrete_placer", "advtrains:dtrack_rdetector_concrete_off_placer")
end

if core.registered_nodes["advtrains:dtrack_rdetector_on_st"] ~= nil then
	advtrains.register_tracks("default", {
		nodename_prefix="advtrains:dtrack_rdetector_on_concrete",
		texture_prefix="advtrains_ctrack",
		models_prefix="advtrains_dtrack",
		models_suffix=".b3d",
		shared_texture="advtrains_ctrack_shared_rdetector_on.png",
		description=attrans("Remote Detector Rail").." (betonové pražce)",
		formats={},
		get_additional_definiton = function(def, preset, suffix, rotation)
			local old_def = core.registered_nodes["advtrains:dtrack_detector_om_"..suffix..rotation]
			if old_def == nil then
				return {}
			else
				return {
					mesecons = old_def.mesecons,
					after_dig_node = old_def.after_dig_node,
					drop = "advtrains:dtrack_rdetector_concrete_off_placer",
					advtrains = old_def.advtrains,
				}
			end
		end
	}, advtrains.ap.t_30deg_straightonly_noplacer)
	minetest.register_craft({
	type="shapeless",
	output = 'advtrains:dtrack_rdetector_concrete_off_placer',
	recipe = {
		"advtrains:dtrack_detector_off_concrete_placer",
		"default:mese_crystal",
	},
	})
end

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

	advtrains.register_tracks("default", {
		nodename_prefix="advtrains_line_automation:dtrack_stop_concrete",
		texture_prefix="advtrains_dtrack_stop",
		models_prefix="advtrains_dtrack",
		models_suffix=".b3d",
		shared_texture="advtrains_ctrack_shared_stop.png",
		description=attrans("Station/Stop Rail").." (betonové pražce)",
		formats={},
		get_additional_definiton = advtrains.station_stop_rail_additional_definition,
	}, advtrains.trackpresets.t_30deg_straightonly)

	minetest.register_craft({
		output = "advtrains_line_automation:dtrack_stop_concrete_placer 2",
		recipe = {
			{"default:coal_lump", ""},
			{"advtrains:dtrack_concrete_placer", "advtrains:dtrack_concrete_placer"},
		},
	})
end

ch_base.close_mod(minetest.get_current_modname())
