local S = technic_cnc.getter

-- Define slope boxes for the various nodes
-------------------------------------------
technic_cnc.programs = {
	{
		suffix  = "technic_cnc_stick",
		model = {-0.15, -0.5, -0.15, 0.15, 0.5, 0.15},
		desc  = S("Stick")
	},

	{ suffix  = "technic_cnc_element_end_double",
		model = {-0.3, -0.5, -0.3, 0.3, 0.5, 0.5},
		desc  = S("Element End Double")
	},

	{ suffix  = "technic_cnc_element_cross_double",
		model = {
			{0.3, -0.5, -0.3, 0.5, 0.5, 0.3},
			{-0.3, -0.5, -0.5, 0.3, 0.5, 0.5},
			{-0.5, -0.5, -0.3, -0.3, 0.5, 0.3}},
		desc  = S("Element Cross Double")
	},

	{ suffix  = "technic_cnc_element_t_double",
		model = {
			{-0.3, -0.5, -0.5, 0.3, 0.5, 0.3},
			{-0.5, -0.5, -0.3, -0.3, 0.5, 0.3},
			{0.3, -0.5, -0.3, 0.5, 0.5, 0.3}},
		desc  = S("Element T Double")
	},

	{ suffix  = "technic_cnc_element_edge_double",
		model = {
			{-0.3, -0.5, -0.5, 0.3, 0.5, 0.3},
			{-0.5, -0.5, -0.3, -0.3, 0.5, 0.3}},
		desc  = S("Element Edge Double")
	},

	{ suffix  = "technic_cnc_element_straight_double",
		model = {-0.3, -0.5, -0.5, 0.3, 0.5, 0.5},
		desc  = S("Element Straight Double")
	},

	{ suffix  = "technic_cnc_element_end",
		model = {-0.3, -0.5, -0.3, 0.3, 0, 0.5},
		desc  = S("Element End")
	},

	{ suffix  = "technic_cnc_element_cross",
		model = {
			{0.3, -0.5, -0.3, 0.5, 0, 0.3},
			{-0.3, -0.5, -0.5, 0.3, 0, 0.5},
			{-0.5, -0.5, -0.3, -0.3, 0, 0.3}},
		desc  = S("Element Cross")
	},

	{ suffix  = "technic_cnc_element_t",
		model = {
			{-0.3, -0.5, -0.5, 0.3, 0, 0.3},
			{-0.5, -0.5, -0.3, -0.3, 0, 0.3},
			{0.3, -0.5, -0.3, 0.5, 0, 0.3}},
		desc  = S("Element T")
	},

	{ suffix  = "technic_cnc_element_edge",
		model = {
			{-0.3, -0.5, -0.5, 0.3, 0, 0.3},
			{-0.5, -0.5, -0.3, -0.3, 0, 0.3}},
		desc  = S("Element Edge")
	},

	{ suffix  = "technic_cnc_element_straight",
		model = {-0.3, -0.5, -0.5, 0.3, 0, 0.5},
		desc  = S("Element Straight")
	},

	{ suffix  = "technic_cnc_oblate_spheroid",
		model = "technic_cnc_oblate_spheroid.obj",
		desc  = S("Oblate spheroid"),
		cbox  = {
			type = "fixed",
			fixed = {
				{ -6/16,  4/16, -6/16, 6/16,  8/16, 6/16 },
				{ -8/16, -4/16, -8/16, 8/16,  4/16, 8/16 },
				{ -6/16, -8/16, -6/16, 6/16, -4/16, 6/16 }
			}
		}
	},

	{ suffix  = "technic_cnc_sphere",
		model = "technic_cnc_sphere.obj",
		desc  = S("Sphere")
	},

	{ suffix  = "technic_cnc_cylinder_horizontal",
		model = "technic_cnc_cylinder_horizontal.obj",
		desc  = S("Horizontal Cylinder")
	},

	{ suffix  = "technic_cnc_cylinder",
		model = "technic_cnc_cylinder.obj",
		desc  = S("Cylinder")
	},

	{ suffix  = "technic_cnc_twocurvededge",
		model = "technic_cnc_two_curved_edge.obj",
		desc  = S("Two Curved Edge/Corner Block")
	},

	{ suffix  = "technic_cnc_onecurvededge",
		model = "technic_cnc_one_curved_edge.obj",
		desc  = S("One Curved Edge Block")
	},

	{ suffix  = "technic_cnc_spike",
		model = "technic_cnc_pyramid_spike.obj",
		desc  = S("Spike"),
		cbox    = {
			type = "fixed",
			fixed = {
				{ -2/16,  4/16, -2/16, 2/16,  8/16, 2/16 },
				{ -4/16,     0, -4/16, 4/16,  4/16, 4/16 },
				{ -6/16, -4/16, -6/16, 6/16,     0, 6/16 },
				{ -8/16, -8/16, -8/16, 8/16, -4/16, 8/16 }
			}
		}
	},

	{ suffix  = "technic_cnc_pyramid",
		model = "technic_cnc_pyramid.obj",
		desc  = S("Pyramid"),
		cbox  = {
			type = "fixed",
			fixed = {
				{ -2/16, -2/16, -2/16, 2/16,     0, 2/16 },
				{ -4/16, -4/16, -4/16, 4/16, -2/16, 4/16 },
				{ -6/16, -6/16, -6/16, 6/16, -4/16, 6/16 },
				{ -8/16, -8/16, -8/16, 8/16, -6/16, 8/16 }
			}
		}
	},

	{ suffix  = "technic_cnc_arch216",
		model = "technic_arch_216.obj",
		desc  = S("2/16 Arch"),
		cbox  = {
			type = "fixed",
			fixed = {
				{0.4375, -0.5, -0.5, 0.5, -0.1875, 0.5},
				{-0.5, 0.4375, -0.5, -0.1875, 0.5, 0.5},
				{-0.1875, 0.25, -0.5, 0, 0.4375, 0.5},
				{0.25, -0.1875, -0.5, 0.4375, 0, 0.5},
				{-0.0625, 0.1875, -0.5, 0.125, 0.3125, 0.5},
				{0.1875, -0.0625, -0.5, 0.3125, 0.125, 0.5},
				{0.0625, 0.0625, -0.5, 0.25, 0.25, 0.5},
			}
		}
	},
	
	{ suffix  = "technic_cnc_arch216_flange",
		model = "technic_arch_216_flange.obj",
		desc  = S("2/16 Arch Flange"),
		cbox  = {
			type = "fixed",
			fixed = {
			{-0.5, 0.4375, -0.5, 0.5, 0.5, 0.5},
			{0.4375, -0.5, -0.5, 0.5, 0.5, 0.5},
			{0.0625, 0.0625, -0.5, 0.4375, 0.4375, 0.5},
			}
		}
	},

	{ suffix  = "technic_cnc_d45_slope_216",
		model = "technic_45_slope_216.obj",
		desc  = S("2/16 45° Slope"),
		cbox  = {
			type = "fixed",
			fixed = {
				{0.25, -0.5, -0.5, 0.5, -0.25, 0.5},
				{0, -0.25, -0.5, 0.25, 0, 0.5},
				{-0.25, 0, -0.5, 0, 0.25, 0.5},
				{-0.5, 0.25, -0.5, -0.25, 0.5, 0.5},
			}
		}
	},

	{ suffix  = "technic_cnc_sphere_half",
		model = "technic_sphere_half.obj",
		desc  = S("Half Sphere"),
		cbox  = {
			type = "fixed",
			fixed = {
				{ -0.5,  -0.5, -0.5, 0.5,  0, 0.5 },
			}
		}
	},

	{ suffix  = "technic_cnc_block_fluted",
		model = "technic_block_fluted.obj",
		desc  = S("Fluted Square Column")
	},

	{ suffix  = "technic_cnc_diagonal_truss",
		model = "technic_diagonal_truss.obj",
		desc  = S("Diagonal Truss"),
		cbox  = {
			type = "fixed",
			fixed = {
				{ -0.5,  -0.5, -0.25, 0.5,  0.5, 0.25 },
			}
		}
	},

	{ suffix  = "technic_cnc_diagonal_truss_cross",
		model = "technic_diagonal_truss_cross.obj",
		desc  = S("Diagonal Truss Cross"),
		cbox  = {
			type = "fixed",
			fixed = {
				{ -0.5,  -0.5, -0.25, 0.5,  0.5, 0.25 },
			}
		}
	},

	{ suffix  = "technic_cnc_opposedcurvededge",
		model = "technic_opposed_curved_edge.obj",
		desc  = S("Opposed Curved Edges Block")
	},

	{ suffix  = "technic_cnc_cylinder_half",
		model = "technic_cylinder_half.obj",
		desc  = S("Half Cylinder"),
		cbox  = {
			type = "fixed",
			fixed = {
				-- { -0.5,  -0.5, -0.5, 0.5,  0, 0.5 },
				{ -0.5,  -0.5, -0.5, 0.5, -0.3, 0.5 },
				{ -0.5,  -0.3, -0.4, 0.5, -0.1, 0.4 },
				{ -0.5,  -0.1, -0.2, 0.5,  0.0, 0.2 },
			}
		}
	},

	{ suffix  = "technic_cnc_cylinder_half_corner",
		model = "technic_cylinder_half_corner.obj",
		desc  = S("Half Cylinder Corner"),
		cbox  = {
			type = "fixed",
			fixed = {
				{ -0.5,  -0.5, -0.5, 0.5,  0, 0.5 },
			}
		}
	},

	{ suffix  = "technic_cnc_circle",
		model = "mymeshnodes_circle.obj",
		desc  = S("Circle"),
		cbox  = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5,  0.5, -7/16, 0.5},
			}
		},
		extra_groups = {not_blocking_trains = 1},
	},

	{ suffix  = "technic_cnc_oct",
		model = "mymeshnodes_oct.obj",
		desc  = S("Octagon"),
		--[[ cbox  = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5,  0.5, -0.25, 0.5},
			}
		} ]]
	},

	{ suffix  = "technic_cnc_peek",
		model = "mymeshnodes_peek.obj",
		desc  = S("Peek"),
		cbox  = {
			type = "fixed",
			fixed = {
				-- box from My Mesh Nodes mod, used under DWYWPL license
				{-0.5, -0.5, -0.4375, 0.5, -0.4375, 0.4375},
				{-0.5, -0.5, -0.375, 0.5, -0.375, 0.375},
				{-0.5, -0.5, -0.3125, 0.5, -0.3125, 0.3125},
				{-0.5, -0.5, -0.25, 0.5, -0.25, 0.25},
				{-0.5, -0.5, -0.1875, 0.5, -0.1875, 0.1875},
				{-0.5, -0.5, -0.125, 0.5, -0.125, 0.125},
				{-0.5, -0.5, -0.0625, 0.5, -0.0625, 0.0625},
			}
		},
	},

	{ suffix  = "technic_cnc_valley",
		model = "mymeshnodes_valley.obj",
		desc  = S("Valley"),
		cbox  = {
			type = "fixed",
			fixed = {
				-- box from My Mesh Nodes mod, used under DWYWPL license
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, -0.5, -0.5, -0.4375, 0.4375, 0.5},
				{-0.5, -0.5, -0.5, -0.375, 0.375, 0.5},
				{-0.5, -0.5, -0.5, -0.3125, 0.3125, 0.5},
				{-0.5, -0.5, -0.5, -0.25, 0.25, 0.5},
				{-0.5, -0.5, -0.5, -0.1875, 0.1875, 0.5},
				{-0.5, -0.5, -0.5, -0.125, 0.125, 0.5},
				{-0.5, -0.5, -0.5, -0.0625, 0.0625, 0.5},
				{0.4375, -0.5, -0.5, 0.5, 0.4375, 0.5},
				{0.375, -0.5, -0.5, 0.5, 0.375, 0.5},
				{0.3125, -0.5, -0.5, 0.5, 0.3125, 0.5},
				{0.25, -0.5, -0.5, 0.5, 0.25, 0.5},
				{0.1875, -0.5, -0.5, 0.5, 0.1875, 0.5},
				{0.125, -0.5, -0.5, 0.5, 0.125, 0.5},
				{0.0625, -0.5, -0.5, 0.5, 0.0625, 0.5},
			}
		}
	},
	{ suffix  = "technic_cnc_bannerstone",
		desc  = S("Bannerstone"),
		model = {
				-- box from Facade mod, used under LGPLv2.1+ license
				{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
				{-0.5625, 0.25, -0.5625, 0.5625, 0.375, 0.5625},
				{-0.5625, -0.375, -0.5625, 0.5625, -0.25, 0.5625},
		},
		tiles_overlay = {
			"",
			"",
			"^facade_bannerstone.png",
			"^facade_bannerstone.png",
			"^facade_bannerstone.png",
			"^facade_bannerstone.png",
		},
	},
}

-- Allow disabling certain programs for some node. Default is allowing all types for all nodes
technic_cnc.programs_disable = {
	-- ["default:brick"] = {"technic_cnc_stick"}, -- Example: Disallow the stick for brick
	["default:dirt"] = {
		"technic_cnc_oblate_spheroid",
		"technic_cnc_slope_upsdown",
		"technic_cnc_edge", "technic_cnc_inner_edge",
		"technic_cnc_slope_edge_upsdown",
		"technic_cnc_slope_inner_edge_upsdown",
		"technic_cnc_stick",
		"technic_cnc_cylinder_horizontal"
	}
}

-- TODO: These should be collected automatically through program registration function
-- Also technic_cnc.programs could be parsed and product lists created based on programs.
technic_cnc.onesize_products = {
	arch216                  = 1,
	arch216_flange           = 1,
	bannerstone              = 1,
	block_fluted             = 1,
	circle                   = 8,
	cylinder                 = 2,
	cylinder_horizontal      = 2,
	cylinder_half            = 2,
	cylinder_half_corner     = 2,
	d45_slope_216            = 2,
	diagonal_truss           = 2,
	diagonal_truss_cross     = 1,
	oblate_spheroid          = 1,
	oct                      = 1,
	onecurvededge            = 1,
	opposedcurvededge        = 1,
	peek                     = 2,
	pyramid                  = 2,
	sphere                   = 1,
	sphere_half              = 2,
	spike                    = 1,
	stick                    = 8,
	twocurvededge            = 1,
	valley                   = 1,
}

technic_cnc.twosize_products = {
	element_straight         = 2,
	element_end              = 2,
	element_cross            = 1,
	element_t                = 1,
	element_edge             = 2,
}

-- Lookup tables for all available programs, main use is to verify that requested product is available
technic_cnc.products = {}
for key, size in pairs(technic_cnc.onesize_products) do technic_cnc.products[key] = size end
for key, size in pairs(technic_cnc.twosize_products) do technic_cnc.products[key] = size end

