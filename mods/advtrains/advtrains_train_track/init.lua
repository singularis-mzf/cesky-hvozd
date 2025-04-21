ch_base.open_mod(minetest.get_current_modname())
-- Default tracks for advtrains
-- (c) orwell96 and contributors

local default_boxen = {
    ["st"] = {
        [""] = {
            selection_box = {
                type = "fixed",
                fixed = {-1/2-1/16, -1/2, -1/2, 1/2+1/16, -1/2+2/16, 1/2},
            }
        },
        ["_30"] = {
            selection_box = {
                type = "fixed",
                fixed = {
                    {-0.5000, -0.5000, -1.000, 0.5000, -0.3750, 1.000},
                    {-0.8750, -0.5000, -1.000, -0.5000, -0.3750, 0.2500},
                    {0.5000, -0.5000, -0.2500, 0.8750, -0.3750, 1.000},
                    {-0.1250, -0.5000, -1.375, 0.1875, -0.3750, -1.000}
                }
            }
        },
        ["_45"] = {
            selection_box = {
                type = "fixed",
                fixed = {
                    {-0.5000, -0.5000, -0.8750, 0.5000, -0.3750, 0.8750},
                    {0.5000, -0.5000, -0.5000, 0.8750, -0.3750, 0.5000},
                    {-0.8750, -0.5000, -0.5000, -0.5000, -0.3750, 0.5000}
                }
            }
        },
        ["_60"] = {
            selection_box = {
                type = "fixed",
                fixed = {
                    {-1.000, -0.5000, -0.5000, 1.000, -0.3750, 0.5000},
                    {-1.000, -0.5000, -0.8750, 0.2500, -0.3750, -0.5000},
                    {-0.2500, -0.5000, 0.5000, 1.000, -0.3750, 0.8750},
                    {-1.375, -0.5000, -0.1250, -1.000, -0.3750, 0.1875}
                }
            }
        },
    },

    ["cr"] = {
        [""] = {
            selection_box = {
                type = "fixed",
                fixed = {
                    {-0.5000, -0.5000, -0.5000, 0.6875, -0.3750, 0.5000},
                    {-0.3750, -0.5000, -1.000, 1.000, -0.3750, 0.000}
                }
            }
        },
        ["_30"] = {
            selection_box = {
                type = "fixed",
                fixed = {
                    {-0.5000, -0.5000, -0.5000, 0.7500, -0.3750, 0.8750},
                    {-0.3750, -0.5000, 0.8750, 0.2500, -0.3750, 1.188},
                    {0.7500, -0.5000, 0.2500, 1.063, -0.3750, 0.8750}
                }
            }
        },
        ["_45"] = {
            selection_box = {
                type = "fixed",
                fixed = {
                    {-0.5000, -0.5000, -1.125, 0.5000, -0.3750, 0.6875},
                    {-0.8750, -0.5000, -0.9375, -0.5000, -0.3750, 0.06250},
                    {0.5000, -0.5000, -0.5000, 0.8750, -0.3750, 0.5000}
                }
            }
        },
        ["_60"] = {
            selection_box = {
                type = "fixed",
                fixed = {
                    {-0.8125, -0.5000, -0.5000, 1.188, -0.3750, 0.5000},
                    {-0.1875, -0.5000, 0.5000, 0.8750, -0.3125, 0.8750},
                    {-0.2500, -0.5000, -0.9375, 0.3125, -0.3125, -0.5000}
                }
            }
        },
    },

    ["swlst"] = {
        [""] = {
            selection_box = {
                type = "fixed",
                fixed = {
                    {-0.5000, -0.5000, -0.5000, 0.6250, -0.3750, 0.5000},
                    {-0.3125, -0.5000, -1.000, 0.9375, -0.3125, -0.06250}
                }
            }
        },
        ["_30"] = {
            selection_box = {
                type = "fixed",
                fixed = {
                    {-0.5000, -0.5000, -1.000, 0.5000, -0.3750, 1.000},
                    {-0.8750, -0.5000, -1.000, -0.5000, -0.3750, 0.2500},
                    {0.5000, -0.5000, -0.2500, 0.8750, -0.3750, 1.000},
                    {-0.1250, -0.5000, -1.375, 0.1875, -0.3750, -1.000}
                }
            }
        },
        ["_45"] = {
            selection_box = {
                type = "fixed",
                fixed = {
                    {-0.5000, -0.5000, -1.1875, 0.5000, -0.3750, 0.8750},
                    {0.5000, -0.5000, -0.5000, 0.8750, -0.3750, 0.5000},
                    {-0.8750, -0.5000, -0.8125, -0.5000, -0.3750, 0.5000}
                }
            }
        },
        ["_60"] = {
            selection_box = {
                type = "fixed",
                fixed = {
                    {-1.000, -0.5000, -0.5000, 1.000, -0.3750, 0.5000},
                    {-1.000, -0.5000, -0.8750, 0.2500, -0.3750, -0.5000},
                    {-0.2500, -0.5000, 0.5000, 1.000, -0.3750, 0.8750},
                    {-1.375, -0.5000, -0.1250, -1.000, -0.3750, 0.1875}
                }
            }
        },
    },

    ["swrst"] = {
        [""] = {
            selection_box = {
                type = "fixed",
                fixed = {
                    {-0.5000, -0.5000, -0.5000, 0.6250, -0.3750, 0.5000},
                    {-0.8125, -0.5000, -1.000, 0.4375, -0.3125, -0.06250}
                }
            }
        },
        ["_30"] = {
            selection_box = {
                type = "fixed",
                fixed = {
                    {-0.5000, -0.5000, -1.000, 0.5000, -0.3750, 1.000},
                    {-0.8750, -0.5000, -1.000, -0.5000, -0.3750, 0.2500},
                    {0.5000, -0.5000, -0.2500, 0.8750, -0.3750, 1.000},
                    {-0.1250, -0.5000, -1.375, 0.1875, -0.3750, -1.000}
                }
            }
        },
        ["_45"] = {
            selection_box = {
                type = "fixed",
                fixed = {
                    {-1.1875, -0.5000, -0.5000, 0.8750, -0.3750, 0.5000},
                    {-0.5000, -0.5000, 0.5000, 0.5000, -0.3750, 0.8750},
                    {-0.8125, -0.5000, -0.8750, 0.5000, -0.3750, -0.5000}
                }
            }
        },
        ["_60"] = {
            selection_box = {
                type = "fixed",
                fixed = {
                    {-1.000, -0.5000, -0.5000, 1.000, -0.3750, 0.5000},
                    {-1.000, -0.5000, -0.8750, 0.2500, -0.3750, -0.5000},
                    {-0.2500, -0.5000, 0.5000, 1.000, -0.3750, 0.8750},
                    {-1.375, -0.5000, -0.1250, -1.000, -0.3750, 0.1875}
                }
            }
        },
    },
}

default_boxen["swlcr"] = default_boxen["swlst"]
default_boxen["swrcr"] = default_boxen["swrst"]

--flat
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack",
	texture_prefix="advtrains_dtrack",
	models_prefix="advtrains_dtrack",
	models_suffix=".b3d",
	shared_texture="advtrains_dtrack_shared.png",
	description=attrans("Track"),
	formats={},

    get_additional_definiton = function(def, preset, suffix, rotation)
        if default_boxen[suffix] ~= nil and default_boxen[suffix][rotation] ~= nil then
            return default_boxen[suffix][rotation]
        else
            return {}
        end
    end,
}, advtrains.ap.t_30deg_flat)

minetest.register_craft({
	output = 'advtrains:dtrack_placer 50',
	recipe = {
		{'default:steel_ingot', 'group:stick', 'default:steel_ingot'},
		{'default:steel_ingot', 'group:stick', 'default:steel_ingot'},
		{'default:steel_ingot', 'group:stick', 'default:steel_ingot'},
	},
})

local y3_boxen = {
    [""] = {
        selection_box = {
            type = "fixed",
            fixed = {
                {-0.8750, -0.5000, -1.125, 0.8750, -0.3750, 0.4375}
            }
        }
    },

    ["_30"] = {
        selection_box = {
            type = "fixed",
            fixed = {
                {-0.5000, -0.5000, -0.875, 0.5000, -0.3750, 1.000},
                {-0.8750, -0.5000, -0.4375, -0.5000, -0.3750, 0.5625},
                {0.5000, -0.5000, -0.2500, 0.8125, -0.3750, 1.000},
            }
        }
    },

    --UX FIXME: - 3way - have to place straight route before l and r or the 
    --nodebox overlaps too much and can't place the straight track node.
    ["_45"] = {
        selection_box = {
            type = "fixed",
            fixed = {
                {-0.5000, -0.5000, -1.1250, 0.5000, -0.3750, 0.8750},
                {0.5000, -0.5000, -0.5000, 0.8750, -0.3750, 0.5000},
                {-1.1250, -0.5000, -0.9375, -0.5000, -0.3750, 0.5000}
            }
        }
    },

    ["_60"] = {
        selection_box = {
            type = "fixed",
            fixed = {
                --{-0.5000, -0.5000, -0.875, 0.5000, -0.3750, 1.000},
                {-0.875, -0.5000, -0.5, 1.0, -0.3750, 0.5},
                --{-0.8750, -0.5000, -0.4375, -0.5000, -0.3750, 0.5625},
                {-0.4375, -0.5000, -0.8750, 0.5625, -0.3750, -0.5000},
                --{0.5000, -0.5000, -0.2500, 0.8125, -0.3750, 1.000},
                {-0.2500, -0.5000, -0.2500, 1.0000, -0.3750, 0.8125},
            }
        }
    },
}


local function y3_turnouts_addef(def, preset, suffix, rotation)
    return y3_boxen[rotation] or {}
end
-- y-turnout
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_sy",
	texture_prefix="advtrains_dtrack_sy",
	models_prefix="advtrains_dtrack_sy",
	models_suffix=".obj",
	shared_texture="advtrains_dtrack_shared.png",
	description=attrans("Y-turnout"),
	formats = {},
    get_additional_definiton = y3_turnouts_addef,
}, advtrains.ap.t_yturnout)
minetest.register_craft({
	output = 'advtrains:dtrack_sy_placer 2',
	recipe = {
		{'advtrains:dtrack_placer', '', 'advtrains:dtrack_placer'},
		{'', 'advtrains:dtrack_placer', ''},
		{'', 'advtrains:dtrack_placer', ''},
	},
})
--3-way turnout
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_s3",
	texture_prefix="advtrains_dtrack_s3",
	models_prefix="advtrains_dtrack_s3",
	models_suffix=".obj",
	shared_texture="advtrains_dtrack_shared.png",
	description=attrans("3-way turnout"),
	formats = {},
    get_additional_definiton = y3_turnouts_addef,
}, advtrains.ap.t_s3way)
minetest.register_craft({
	output = 'advtrains:dtrack_s3_placer 1',
	recipe = {
		{'advtrains:dtrack_placer', 'advtrains:dtrack_placer', 'advtrains:dtrack_placer'},
		{'', 'advtrains:dtrack_placer', ''},
		{'', '', ''},
	},
})

-- Diamond Crossings

local perp_boxen = {
    [""] = {}, --default size
    ["_30"] = {
        selection_box = {
            type = "fixed",
            fixed = {
                {-1.000, -0.5000, -1.000, 1.000, -0.3750, 1.000}
            }
        }
    },
    ["_45"] = {
        selection_box = {
            type = "fixed",
            fixed = {
                {-0.8125, -0.5000, -0.8125, 0.8125, -0.3750, 0.8125}
            }
        }
    },
    ["_60"] = {
        selection_box = {
            type = "fixed",
            fixed = {
                {-1.000, -0.5000, -1.000, 1.000, -0.3750, 1.000}
            }
        }
    },
}

-- perpendicular
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_xing",
	texture_prefix="advtrains_dtrack_xing",
	models_prefix="advtrains_dtrack_xing",
	models_suffix=".obj",
	shared_texture="advtrains_dtrack_shared.png",
	description=attrans("Perpendicular Diamond Crossing Track"),
	formats = {},
    get_additional_definiton = function(def, preset, suffix, rotation)
        return perp_boxen[rotation] or {}
    end
}, advtrains.ap.t_perpcrossing)

minetest.register_craft({
	output = 'advtrains:dtrack_xing_placer 3',
	recipe = {
		{'', 'advtrains:dtrack_placer', ''},
		{'advtrains:dtrack_placer', 'advtrains:dtrack_placer', 'advtrains:dtrack_placer'},
		{'', 'advtrains:dtrack_placer', ''}
	}
})

local ninety_plus_boxen = {
    ["30l"] = {
        selection_box = {
            type = "fixed",
            fixed = {
                {-0.5000, -0.5000, -1.000, 0.5000, -0.3750, 1.000},
                {-0.8750, -0.5000, -1.000, -0.5000, -0.3750, 0.2500},
                {0.5000, -0.5000, -0.2500, 0.8750, -0.3750, 1.000},
                {-0.1250, -0.5000, -1.375, 0.1875, -0.3750, -1.000}
            }
        }
    },
    ["30r"] = {
        selection_box = {
            type = "fixed",
            fixed = {
                {0.5000, -0.5000, -1.000, -0.5000, -0.3750, 1.000},
                {0.8750, -0.5000, -1.000, 0.5000, -0.3750, 0.2500},
                {-0.5000, -0.5000, -0.2500, -0.8750, -0.3750, 1.000},
                {0.1250, -0.5000, -1.375, -0.1875, -0.3750, -1.000}
            }
        }
    },
    ["45l"] = {
        selection_box = {
            type = "fixed",
            fixed = {
                {-0.5000, -0.5000, -0.8750, 0.5000, -0.3750, 0.8750},
                {0.5000, -0.5000, -0.5000, 0.8750, -0.3750, 0.5000},
                {-0.8750, -0.5000, -0.5000, -0.5000, -0.3750, 0.5000}
            }
        }
    },
    ["45r"] = {
        selection_box = {
            type = "fixed",
            fixed = {
                {-0.5000, -0.5000, -0.8750, 0.5000, -0.3750, 0.8750},
                {0.5000, -0.5000, -0.5000, 0.8750, -0.3750, 0.5000},
                {-0.8750, -0.5000, -0.5000, -0.5000, -0.3750, 0.5000}
            }
        }
    },
    ["60l"] = {
        selection_box = {
            type = "fixed",
            fixed = {
                {-1.000, -0.5000, -0.5000, 1.000, -0.3750, 0.5000},
                {-1.000, -0.5000, -0.8750, 0.2500, -0.3750, -0.5000},
                {-0.2500, -0.5000, 0.5000, 1.000, -0.3750, 0.8750},
                {-1.375, -0.5000, -0.1250, -1.000, -0.3750, 0.1875}
            }
        }
    },
    ["60r"] = {
        selection_box = {
            type = "fixed",
            fixed = {
                {1.000, -0.5000, -0.5000, -1.000, -0.3750, 0.5000},
                {1.000, -0.5000, -0.8750, -0.2500, -0.3750, -0.5000},
                {0.2500, -0.5000, 0.5000, -1.000, -0.3750, 0.8750},
                {1.375, -0.5000, -0.1250, 1.000, -0.3750, 0.1875}
            }
        }
    },
}

-- 90plusx
-- When you face east and param2=0, then this set of rails has a rail at 90
-- degrees to the viewer, plus another rail crossing at 30, 45 or 60 degrees.
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_xing90plusx",
	texture_prefix="advtrains_dtrack_xing4590",
	models_prefix="advtrains_dtrack_xing90plusx",
	models_suffix=".obj",
	shared_texture="advtrains_dtrack_shared.png",
	description=attrans("90+Angle Diamond Crossing Track"),
	formats = {},
    get_additional_definiton = function(def, preset, suffix, rotation)
        return ninety_plus_boxen[suffix] or {}
    end,
}, advtrains.ap.t_90plusx_crossing)
minetest.register_craft({
	output = 'advtrains:dtrack_xing90plusx_placer 2',
	recipe = {
		{'advtrains:dtrack_placer', '', ''},
		{'advtrains:dtrack_placer', 'advtrains:dtrack_placer', 'advtrains:dtrack_placer'},
		{'', '', 'advtrains:dtrack_placer'}
	}
})

-- Deprecate any rails using the old name scheme
minetest.register_lbm({
	label = "Upgrade legacy 4590 rails",
	name = "advtrains_train_track:replace_legacy_4590",
	nodenames = {"advtrains:dtrack_xing4590_st"},
	run_at_every_load = true,
	action = function(pos, node)
		minetest.log("actionPos!: " .. pos.x .. "," .. pos.y .. "," .. pos.z)
		minetest.log("node!: " .. node.name .. "," .. node.param1 .. "," .. node.param2)
		advtrains.ndb.swap_node(pos,
		{
			name="advtrains:dtrack_xing90plusx_45l",
			param1=node.param1,
			param2=node.param2,
		})
	end
})
-- This will replace any items left in the inventory
minetest.register_alias("advtrains:dtrack_xing4590_placer", "advtrains:dtrack_xing90plusx_placer")

local diagonal_boxen = {
    ["30r45l"] = {
        selection_box = {
            type = "fixed",
            fixed = {
                {0.5000, -0.5000, -1.000, -0.5000, -0.3750, 1.000},
                {0.8750, -0.5000, -1.000, 0.5000, -0.3750, 0.2500},
                {-0.5000, -0.5000, -0.2500, -0.8750, -0.3750, 1.000},
                {0.1250, -0.5000, -1.375, -0.1875, -0.3750, -1.000}
            }
        }
    },
    ["60l30l"] = {
        selection_box = {
            type = "fixed",
            fixed = {
                {-1.000, -0.5000, -0.5000, 1.000, -0.3750, 0.5000},
                {-1.000, -0.5000, -0.8750, 0.2500, -0.3750, -0.5000},
                {-0.2500, -0.5000, 0.5000, 1.000, -0.3750, 0.8750},
                {-1.375, -0.5000, -0.1250, -1.000, -0.3750, 0.1875}
            }
        }
    },
    ["60l60r"] = {
        selection_box = {
            type = "fixed",
            fixed = {
                {-1.000, -0.5000, -1.000, 1.000, -0.3750, 1.000}
            }
        }
    },
    ["60r30r"] = {
        selection_box = {
            type = "fixed",
            fixed = {
                {1.000, -0.5000, -0.5000, -1.000, -0.3750, 0.5000},
                {1.000, -0.5000, -0.8750, -0.2500, -0.3750, -0.5000},
                {0.2500, -0.5000, 0.5000, -1.000, -0.3750, 0.8750},
                {1.375, -0.5000, -0.1250, 1.000, -0.3750, 0.1875}
            }
        }
    },
    ["30l45r"] = {
        selection_box = {
            type = "fixed",
            fixed = {
                {-0.5000, -0.5000, -1.000, 0.5000, -0.3750, 1.000},
                {-0.8750, -0.5000, -1.000, -0.5000, -0.3750, 0.2500},
                {0.5000, -0.5000, -0.2500, 0.8750, -0.3750, 1.000},
                {-0.1250, -0.5000, -1.375, 0.1875, -0.3750, -1.000}
            }
        }
    },
    ["60l45r"] = {
        selection_box = {
            type = "fixed",
            fixed = {
                {-1.000, -0.5000, -0.5000, 1.000, -0.3750, 0.5000},
                {-1.000, -0.5000, -0.8750, 0.2500, -0.3750, -0.5000},
                {-0.2500, -0.5000, 0.5000, 1.000, -0.3750, 0.8750},
                {-1.375, -0.5000, -0.1250, -1.000, -0.3750, 0.1875}
            }
        }
    },
    ["60r45l"] = {
        selection_box = {
            type = "fixed",
            fixed = {
                {1.000, -0.5000, -0.5000, -1.000, -0.3750, 0.5000},
                {1.000, -0.5000, -0.8750, -0.2500, -0.3750, -0.5000},
                {0.2500, -0.5000, 0.5000, -1.000, -0.3750, 0.8750},
                {1.375, -0.5000, -0.1250, 1.000, -0.3750, 0.1875}
            }
        }
    },
}

-- Diagonal
-- This set of rail crossings is named based on the angle of each intersecting
-- direction when facing east and param2=0. Rails with l/r swapped are mirror
-- images. For example, 30r45l is the mirror image of 30l45r.
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_xingdiag",
	texture_prefix="advtrains_dtrack_xingdiag",
	models_prefix="advtrains_dtrack_xingdiag",
	models_suffix=".obj",
	shared_texture="advtrains_dtrack_shared.png",
	description=attrans("Diagonal Diamond Crossing Track"),
	formats = {},
    get_additional_definiton = function(def, preset, suffix, rotation)
        return diagonal_boxen[suffix] or {}
    end,
}, advtrains.ap.t_diagonalcrossing)
minetest.register_craft({
	output = 'advtrains:dtrack_xingdiag_placer 2',
	recipe = {
		{'advtrains:dtrack_placer', '', 'advtrains:dtrack_placer'},
		{'', 'advtrains:dtrack_placer', ''},
		{'advtrains:dtrack_placer', '', 'advtrains:dtrack_placer'}
	}
})
---- Not included: very shallow crossings like (30/60)+45.
---- At an angle of only 18.4 degrees, the models would not
---- translate well to a block game.
-- END crossings

advtrains.default_slope_formats = {t_30deg_slope = {
	vst1={true, false, true},
	vst2={true, false, true},
	vst31={true}, vst32={true}, vst33={true},
	vst41={true}, vst42={true}, vst43={true}, vst44={true},
	vst51={true}, vst52={true}, vst53={true}, vst54={true}, vst55={true}, 
	vst61={true}, vst62={true}, vst63={true}, vst64={true}, vst65={true}, vst66={true}, 
	vst71={true}, vst72={true}, vst73={true}, vst74={true}, vst75={true}, vst76={true}, vst77={true}, 
	vst81={true}, vst82={true}, vst83={true}, vst84={true}, vst85={true}, vst86={true}, vst87={true}, vst88={true},
}}

--slopes
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack",
	texture_prefix="advtrains_dtrack",
	models_prefix="advtrains_dtrack",
	models_suffix=".obj",
	shared_texture="advtrains_dtrack_shared.png",
	second_texture="default_gravel.png",
	description=attrans("Track"),
	formats=advtrains.default_slope_formats.t_30deg_slope,
}, advtrains.ap.t_30deg_slope)

minetest.register_craft({
	type = "shapeless",
	output = 'advtrains:dtrack_slopeplacer 2',
	recipe = {
		"advtrains:dtrack_placer",
		"advtrains:dtrack_placer",
		"default:gravel",
	},
})

advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_rg",
	texture_prefix="advtrains_dtrack_rg",
	models_prefix="advtrains_dtrack",
	models_suffix=".obj",
	shared_texture="advtrains_dtrack_shared.png",
	second_texture="ch_extras_gravel.png",
	description=attrans("Track with Railway Gravel"),
	formats=advtrains.default_slope_formats.t_30deg_slope,
}, advtrains.ap.t_30deg_slope)

minetest.register_craft({
	type = "shapeless",
	output = 'advtrains:dtrack_rg_slopeplacer 2',
	recipe = {
		"advtrains:dtrack_placer",
		"advtrains:dtrack_placer",
		"ch_core:railway_gravel",
	},
})


--bumpers
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_bumper",
	texture_prefix="advtrains_dtrack_bumper",
	models_prefix="advtrains_dtrack_bumper",
	models_suffix=".b3d",
	shared_texture="advtrains_dtrack_rail.png",
	--bumpers still use the old texture until the models are redone.
	description=attrans("Bumper"),
	formats={},
	get_additional_definiton = function(def, preset, suffix, rotation)
		-- 2024-11-25: Bumpers get the additional feature of being both a signal and a self-contained TCB, when interlocking is used.
		if advtrains.interlocking then
			return {
				-- use the special callbacks for self_tcb (see tcb_ts_ui.lua)
				can_dig = advtrains.interlocking.self_tcb_make_can_dig_callback(true),
				after_dig_node = advtrains.interlocking.self_tcb_make_after_dig_callback(true),
				after_place_node = advtrains.interlocking.self_tcb_make_after_place_callback(true, true),
				on_rightclick = advtrains.interlocking.self_tcb_make_on_rightclick_callback(false, true),
				advtrains = {
					main_aspects = {
						-- No main aspects, it always shows Stop.
						-- But we need to define the table so that signal caplevel is 3
					},
					apply_aspect = function(pos, node, main_aspect, rem_aspect, rem_aspinfo)
						-- is a no-op for bumpers, it always shows Stop
					end,
					get_aspect_info = function(pos, main_aspect)
						-- it always shows Stop
						return advtrains.interlocking.signal.ASPI_HALT
					end,
					distant_support = false, -- not a distant
					route_role = "end", -- the end is nigh!
				}
			}
		else
			return {} -- no additional defs when interlocking is not used
		end
	end,
}, advtrains.ap.t_30deg_straightonly)
minetest.register_craft({
	output = 'advtrains:dtrack_bumper_placer 2',
	recipe = {
		{'group:wood', 'dye:red'},
		{'default:steel_ingot', 'default:steel_ingot'},
		{'advtrains:dtrack_placer', 'advtrains:dtrack_placer'},
	},
})
--legacy bumpers
for _,rot in ipairs({"", "_30", "_45", "_60"}) do
	minetest.register_alias("advtrains:dtrack_bumper"..rot, "advtrains:dtrack_bumper_st"..rot)
end
-- atc track
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_atc",
	texture_prefix="advtrains_dtrack_atc",
	models_prefix="advtrains_dtrack",
	models_suffix=".b3d",
	shared_texture="advtrains_dtrack_shared_atc.png",
	description=attrans("ATC controller"),
	formats={},
	get_additional_definiton = advtrains.atc_function
}, advtrains.trackpresets.t_30deg_straightonly)

minetest.register_craft({
	output = "advtrains:dtrack_atc_placer",
	recipe = {
		{"mesecons_microcontroller:microcontroller0000", ""},
		{"advtrains:dtrack_placer", ""},
	},
})

-- Tracks for loading and unloading trains
-- Copyright (C) 2017 Gabriel Pérez-Cerezo <gabriel@gpcf.eu>

local function get_far_node(pos)
	local node = minetest.get_node(pos)
	if node.name == "ignore" then
		minetest.get_voxel_manip():read_from_map(pos, pos)
		node = minetest.get_node(pos)
	end
	return node
end


local function show_fc_formspec(pos,player)
	local pname = player:get_player_name()
	if minetest.is_protected(pos,pname) then
		minetest.chat_send_player(pname, "Position is protected!")
		return
	end
	
	local meta = minetest.get_meta(pos)
	local fc = meta:get_string("fc") or ""
	
	local form = 'formspec_version[4]'..
		'size[10,5]'..
		'label[0.5,0.4;kolej nakládání/vykládání]'..
		'label[0.5,1.1;Nastavte nákladní kód. Vagony se zadaným kódem budou naloženy/vyloženy.]'..
		'label[0.5,1.6;Prázdné pole znamená všechny vagony.]'..
		'label[0.5,2.1;Pro vypnutí zadejte kód #.]'..
		'field[0.5,3;5.5,1;fc;kód:;'..minetest.formspec_escape(fc)..']'..
		'button[6.5,3;3,1;save;Uložit]'
	minetest.show_formspec(pname, "at_load_unload_"..advtrains.encode_pos(pos), form)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pname = player:get_player_name()
	local pe = string.match(formname, "^at_load_unload_(............)$")
	local pos = advtrains.decode_pos(pe)
	if pos then
		if minetest.is_protected(pos, pname) then
			minetest.chat_send_player(pname, "Pozice je zastřežená!")
			return
		end
		
		if fields.save then
			minetest.get_meta(pos):set_string("fc",tostring(fields.fc))
			minetest.chat_send_player(pname,"Nákladní kód nastaven: "..tostring(fields.fc))
			show_fc_formspec(pos,player)
		end
	end
end)

local function load_wagon(wagon_id, node_inv, node_fc, unload)
	local inv_modified = false
	local w_inv=minetest.get_inventory({type="detached", name="advtrains_wgn_"..wagon_id})
	if w_inv and w_inv:get_list("box") then
	
		local wagon_data = advtrains.wagons[wagon_id]
		local wagon_fc
		if wagon_data.fc then
			if not wagon_data.fcind then wagon_data.fcind = 1 end
			wagon_fc = tostring(wagon_data.fc[wagon_data.fcind]) or ""
		end
		
		if node_fc == "" or wagon_fc == node_fc then
			if not unload then
				for _, item in ipairs(node_inv:get_list("main")) do
					if w_inv:get_list("box") and w_inv:room_for_item("box", item)  then
						w_inv:add_item("box", item)
						node_inv:remove_item("main", item)
						if item.name ~= "" then inv_modified = true end
					end
				end
			else
				for _, item in ipairs(w_inv:get_list("box")) do
					if node_inv:get_list("main") and node_inv:room_for_item("main", item)  then
						w_inv:remove_item("box", item)
						node_inv:add_item("main", item)
						if item.name ~= "" then inv_modified = true end
					end
				end
			end
		end
	end
	return inv_modified
end

local function load_entire_train(pos, train_id, unload) -- flood load when not in an active area
	if advtrains.is_node_loaded(pos) then -- leave the loading to the nodetimer if area is loaded
		return 
	end
	local train=advtrains.trains[train_id]
	local below = get_far_node({x=pos.x, y=pos.y-1, z=pos.z})
	if not string.match(below.name, "chest") then
		atprint("this is not a chest! at "..minetest.pos_to_string(pos))
		return
	end
	
	local node_fc = minetest.get_meta(pos):get_string("fc") or ""
	if node_fc == "#" then
		--track section is disabled
		return
	end
	local node_inv = minetest.get_inventory({type="node", pos={x=pos.x, y=pos.y-1, z=pos.z}})
	if node_inv and train.velocity <= 2 then
		for _, wagon_id in ipairs(train.trainparts) do
			load_wagon(wagon_id, node_inv, node_fc, unload)
		end
	end
end

local function load_wagon_on_timer(pos, unload) -- loading ramp when in an active area
	if not advtrains.is_node_loaded(pos) then -- leave the loading for the flood load function. we're out of area
		return true -- reset the nodetimer until the node is loaded again
	end
	local tid, tidx = advtrains.get_train_at_pos(pos)
	if not tid or tid == "" then
		return true
	end -- no train to load.

	local train = advtrains.trains[tid]
	local below = get_far_node({x=pos.x, y=pos.y-1, z=pos.z})
	if not string.match(below.name, "chest") then
		atprint("this is not a chest! at "..minetest.pos_to_string(pos))
		return true
	end
	local node_fc = minetest.get_meta(pos):get_string("fc") or ""
	if node_fc == "#" then
		--track section is disabled
		return true
	end
	local node_inv = minetest.get_inventory({type="node", pos={x=pos.x, y=pos.y-1, z=pos.z}})
	if node_inv and train.velocity <= 2 then
		local _, wagon_id, wagon_data = advtrains.get_wagon_at_index(tid, tidx)
		if wagon_id then
			local inv_modified = load_wagon(wagon_id, node_inv, node_fc, unload)
			if inv_modified then
				if advtrains.wagon_prototypes[advtrains.get_wagon_prototype(wagon_data)].set_textures then
					local wagon_object = advtrains.wagon_objects[wagon_id]
					if wagon_object and wagon_data then
						local ent = wagon_object:get_luaentity()
						if ent and ent.set_textures then
							ent:set_textures(wagon_data)
						end
					end
				end
			end
		end
	end
	return true
end

local nodetimer_interval = minetest.settings:get("advtrains_loading_track_timer") or 1
local function start_nodetimer(pos)
	local timer = minetest.get_node_timer(pos)
	timer:start(nodetimer_interval)
end

advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_unload",
	texture_prefix="advtrains_dtrack_unload",
	models_prefix="advtrains_dtrack",
	models_suffix=".b3d",
	shared_texture="advtrains_dtrack_shared_unload.png",
	description=attrans("Unloading Track"),
	formats={},
	get_additional_definiton = function(def, preset, suffix, rotation)
		return {
			after_dig_node=function(pos)
				advtrains.invalidate_all_paths()
				advtrains.ndb.clear(pos)
			end,
			on_rightclick = function(pos, node, player)
				show_fc_formspec(pos, player)
			end,
			after_place_node = function(pos)
				advtrains.ndb.update(pos)
				start_nodetimer(pos)
			end,
			on_timer = function(pos)
				return load_wagon_on_timer(pos, true)
			end,
			advtrains = {
				on_train_enter = function(pos, train_id)
					load_entire_train(pos, train_id, true)
				end,
			},
		}
	end
				     }, advtrains.trackpresets.t_30deg_straightonly)
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_load",
	texture_prefix="advtrains_dtrack_load",
	models_prefix="advtrains_dtrack",
	models_suffix=".b3d",
	shared_texture="advtrains_dtrack_shared_load.png",
	description=attrans("Loading Track"),
	formats={},
	get_additional_definiton = function(def, preset, suffix, rotation)
		return {
			after_dig_node=function(pos)
				advtrains.invalidate_all_paths()
				advtrains.ndb.clear(pos)
			end,
			on_rightclick = function(pos, node, player)
				show_fc_formspec(pos, player)
			end,
			after_place_node = function(pos)
				advtrains.ndb.update(pos)
				start_nodetimer(pos)
			end,
			on_timer = function(pos)
				return load_wagon_on_timer(pos, false)
			end,
			advtrains = {
				on_train_enter = function(pos, train_id)
					load_entire_train(pos, train_id, false)
				end,
			},
		}
	end
				     }, advtrains.trackpresets.t_30deg_straightonly)

-- mod-dependent crafts
local loader_core = "default:mese_crystal"  --fallback
if minetest.get_modpath("basic_materials") then
	loader_core = "basic_materials:ic"
elseif minetest.get_modpath("technic") then
	loader_core = "technic:control_logic_unit"
end

minetest.register_craft({
	type="shapeless",
	output = 'advtrains:dtrack_load_placer',
	recipe = {
		"advtrains:dtrack_placer",
		loader_core,
		"default:chest"
	},
})
loader_core = nil --nil the crafting variable

--craft between load/unload tracks
minetest.register_craft({
	type="shapeless",
	output = 'advtrains:dtrack_unload_placer',
	recipe = {
		"advtrains:dtrack_load_placer",
	},
})
minetest.register_craft({
	type="shapeless",
	output = 'advtrains:dtrack_load_placer',
	recipe = {
		"advtrains:dtrack_unload_placer",
	},
})


if minetest.get_modpath("mesecons") then
	advtrains.register_tracks("default", {
		nodename_prefix="advtrains:dtrack_detector_off",
		texture_prefix="advtrains_dtrack_detector",
		models_prefix="advtrains_dtrack",
		models_suffix=".b3d",
		shared_texture="advtrains_dtrack_shared_detector_off.png",
		description=attrans("Detector Rail"),
		formats={},
		get_additional_definiton = function(def, preset, suffix, rotation)
			return {
				mesecons = {
					receptor = {
						state = mesecon.state.off,
						rules = advtrains.meseconrules
					}
				},
				advtrains = {
					on_updated_from_nodedb = function(pos, node)
						mesecon.receptor_off(pos, advtrains.meseconrules)
					end,
					on_train_enter=function(pos, train_id)
						advtrains.ndb.swap_node(pos, {name="advtrains:dtrack_detector_on".."_"..suffix..rotation, param2=advtrains.ndb.get_node(pos).param2})
						if advtrains.is_node_loaded(pos) then
							mesecon.receptor_on(pos, advtrains.meseconrules)
						end
					end
				}
			}
		end
	}, advtrains.ap.t_30deg_straightonly)
	advtrains.register_tracks("default", {
		nodename_prefix="advtrains:dtrack_detector_on",
		texture_prefix="advtrains_dtrack",
		models_prefix="advtrains_dtrack",
		models_suffix=".b3d",
		shared_texture="advtrains_dtrack_shared_detector_on.png",
		description="Detector(on)(you hacker you)",
		formats={},
		get_additional_definiton = function(def, preset, suffix, rotation)
			return {
				mesecons = {
					receptor = {
						state = mesecon.state.on,
						rules = advtrains.meseconrules
					}
				},
				advtrains = {
					on_updated_from_nodedb = function(pos, node)
						mesecon.receptor_on(pos, advtrains.meseconrules)
					end,
					on_train_leave=function(pos, train_id)
						advtrains.ndb.swap_node(pos, {name="advtrains:dtrack_detector_off".."_"..suffix..rotation, param2=advtrains.ndb.get_node(pos).param2})
						if advtrains.is_node_loaded(pos) then
							mesecon.receptor_off(pos, advtrains.meseconrules)
						end
					end
				}
			}
		end
	}, advtrains.ap.t_30deg_straightonly_noplacer)
minetest.register_craft({
	type="shapeless",
	output = 'advtrains:dtrack_detector_off_placer',
	recipe = {
		"advtrains:dtrack_placer",
		"mesecons:wire_00000000_off"
	},
})

local function swap_to_off(pos)
	local node = advtrains.ndb.get_node(pos)
	if node == nil then
		minetest.log("error", "Advtrains node at "..minetest.pos_to_string(pos).." expected, but not found!")
	else
		local old_node_name = node.name
		node.name = old_node_name:gsub("rdetector_on", "rdetector_off")
		assert(node.name)
		if node.name ~= old_node_name then
			advtrains.ndb.swap_node(pos, node)
			if advtrains.is_node_loaded(pos) then
				mesecon.receptor_off(pos, advtrains.meseconrules)
			end
		end
	end
end

local function swap_to_on(pos)
	local node = advtrains.ndb.get_node(pos)
	if node == nil then
		minetest.log("error", "Advtrains node at "..minetest.pos_to_string(pos).." expected, but not found!")
	else
		local old_node_name = node.name
		node.name = old_node_name:gsub("rdetector_off", "rdetector_on")
		assert(node.name)
		if node.name ~= old_node_name then
			advtrains.ndb.swap_node(pos, node)
			if advtrains.is_node_loaded(pos) then
				mesecon.receptor_on(pos, advtrains.meseconrules)
			end
		end
	end
end

local rdetector_data = {
	--[[
		[pos_hash] = {
			pos = pos,
			created = ...,
			trains = {
				[train_id] = {expiration = timestamp}}}
	]]
}

local function watch_trains(pos_hash, created)
	assert(pos_hash)
	assert(created)
	local data = rdetector_data[pos_hash]
	if data == nil then
		return
	elseif created ~= data.created then
		return -- not my data
	else
		minetest.after(1, watch_trains, pos_hash, created)
	end
	local kept = 0
	local to_delete = {}
	local now = minetest.get_us_time()
	for train_id, traindata in pairs(data.trains) do
		local train = advtrains.trains[train_id]
		if train == nil or not train.last_pos then
			table.insert(to_delete, train_id) -- train does not exist
		elseif traindata.expiration ~= nil and traindata.expiration <= now then
			table.insert(to_delete, train_id) -- train expired
		else
			kept = kept + 1
		end
	end
	if kept == 0 then
		-- no kept trains => disable the node
		swap_to_off(data.pos)
		rdetector_data[pos_hash] = nil -- no trains remain, delete data
	elseif #to_delete > 0 then
		for _, train_id in ipairs(to_delete) do
			data.trains[train_id] = nil
		end
	end
end

local function on_train_approach(pos, train_id)
	local pos_hash = advtrains.encode_pos(pos)
	local data = rdetector_data[pos_hash]
	local now = minetest.get_us_time()
	local expiration = now + 30000000
	if data == nil then
		rdetector_data[pos_hash] = {
			pos = pos,
			created = now,
			trains = {[train_id] = {expiration = expiration}},
		}
		minetest.after(0.1, swap_to_on, pos)
		minetest.after(1, watch_trains, pos_hash, now)
	else
		data.trains[train_id] = {expiration = expiration}
	end
end

local function on_train_enter(pos, train_id)
	local pos_hash = advtrains.encode_pos(pos)
	local data = rdetector_data[pos_hash]
	local now = minetest.get_us_time()
	if data == nil then
		rdetector_data[pos_hash] = {
			pos = pos,
			created = now,
			trains = {[train_id] = {}},
		}
		minetest.after(0.1, swap_to_on, pos)
		minetest.after(1, watch_trains, pos_hash, now)
	else
		data.trains[train_id] = {}
	end
end

local function on_train_leave(pos, train_id)
	local pos_hash = advtrains.encode_pos(pos)
	local data = rdetector_data[pos_hash]
	if data ~= nil then
		data.trains[train_id] = {expiration = minetest.get_us_time() - 1000000}
	end
end

local function after_dig_node(pos)
	rdetector_data[advtrains.encode_pos(pos)] = nil
end

advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_rdetector_off",
	texture_prefix="advtrains_dtrack_detector",
	models_prefix="advtrains_dtrack",
	models_suffix=".b3d",
	shared_texture="advtrains_dtrack_shared_rdetector_off.png",
	description=attrans("Remote Detector Rail"),
	formats={},
	get_additional_definiton = function(def, preset, suffix, rotation)
		return {
			mesecons = {
				receptor = {
					state = mesecon.state.off,
					rules = advtrains.meseconrules
				}
			},
			after_dig_node = after_dig_node,
			drop = "advtrains:dtrack_rdetector_off_placer",
			advtrains = {
				on_updated_from_nodedb = function(pos, node)
					mesecon.receptor_off(pos, advtrains.meseconrules)
				end,
				on_train_approach = function(pos, train_id, train, index, has_entered)
					if has_entered then
						on_train_enter(pos, train_id)
					else
						on_train_approach(pos, train_id)
					end
				end,
				on_train_enter = on_train_enter,
				on_train_leave = on_train_leave,
			}
		}
	end
}, advtrains.ap.t_30deg_straightonly)
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_rdetector_on",
	texture_prefix="advtrains_dtrack",
	models_prefix="advtrains_dtrack",
	models_suffix=".b3d",
	shared_texture="advtrains_dtrack_shared_rdetector_on.png",
	description=attrans("Remote Detector Rail"),
	formats={},
	get_additional_definiton = function(def, preset, suffix, rotation)
		return {
			after_dig_node = after_dig_node,
			drop = "advtrains:dtrack_rdetector_off_placer",
			mesecons = {
				receptor = {
					state = mesecon.state.on,
					rules = advtrains.meseconrules
				}
			},
			advtrains = {
				on_updated_from_nodedb = function(pos, node)
					mesecon.receptor_on(pos, advtrains.meseconrules)
				end,
				on_train_approach = function(pos, train_id, train, index, has_entered)
					if has_entered then
						on_train_enter(pos, train_id)
					else
						on_train_approach(pos, train_id)
					end
				end,
				on_train_enter = on_train_enter,
				on_train_leave = on_train_leave,
			}
		}
	end
}, advtrains.ap.t_30deg_straightonly_noplacer)
minetest.register_craft({
type="shapeless",
output = 'advtrains:dtrack_rdetector_off_placer',
recipe = {
	"advtrains:dtrack_detector_off_placer",
	"default:mese_crystal",
},
})

end


--TODO legacy
--I know lbms are better for this purpose
for name,rep in pairs({swl_st="swlst", swr_st="swrst", swl_cr="swlcr", swr_cr="swrcr", }) do
	minetest.register_abm({
    --  In the following two fields, also group:groupname will work.
        nodenames = {"advtrains:track_"..name},
       interval = 1.0, -- Operation interval in seconds
       chance = 1, -- Chance of trigger per-node per-interval is 1.0 / this
       action = function(pos, node, active_object_count, active_object_count_wider) minetest.set_node(pos, {name="advtrains:track_"..rep, param2=node.param2}) end,
    })
    minetest.register_abm({
    --  In the following two fields, also group:groupname will work.
        nodenames = {"advtrains:track_"..name.."_45"},
       interval = 1.0, -- Operation interval in seconds
       chance = 1, -- Chance of trigger per-node per-interval is 1.0 / this
       action = function(pos, node, active_object_count, active_object_count_wider) minetest.set_node(pos, {name="advtrains:track_"..rep.."_45", param2=node.param2}) end,
    })
end

if advtrains.register_replacement_lbms then
minetest.register_lbm({
	name = "advtrains:ramp_replacement_1",
--  In the following two fields, also group:groupname will work.
	nodenames = {"advtrains:track_vert1"},
	action = function(pos, node, active_object_count, active_object_count_wider) minetest.set_node(pos, {name="advtrains:dtrack_vst1", param2=(node.param2+2)%4}) end,
})
minetest.register_lbm({
	name = "advtrains:ramp_replacement_1",
--  --  In the following two fields, also group:groupname will work.
	nodenames = {"advtrains:track_vert2"},
	action = function(pos, node, active_object_count, active_object_count_wider) minetest.set_node(pos, {name="advtrains:dtrack_vst2", param2=(node.param2+2)%4}) end,
})
	minetest.register_abm({
		name = "advtrains:st_rep_1",
	--  In the following two fields, also group:groupname will work.
		nodenames = {"advtrains:track_st"},
		interval=1,
		chance=1,
		action = function(pos, node, active_object_count, active_object_count_wider) minetest.set_node(pos, {name="advtrains:dtrack_st", param2=node.param2}) end,
	})
	minetest.register_lbm({
		name = "advtrains:st_rep_1",
	--  --  In the following two fields, also group:groupname will work.
		nodenames = {"advtrains:track_st_45"},
		action = function(pos, node, active_object_count, active_object_count_wider) minetest.set_node(pos, {name="advtrains:dtrack_st_45", param2=node.param2}) end,
	})
end

ch_base.close_mod(minetest.get_current_modname())
