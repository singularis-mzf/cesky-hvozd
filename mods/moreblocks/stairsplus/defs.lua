--[[
More Blocks: registrations

Copyright © 2011-2020 Hugo Locurcio and contributors.
Licensed under the zlib license. See LICENSE.md for more information.
--]]

local box_beveled_slab = {
	type = "fixed",
	fixed = {-8/16, -8/16, -8/16, 8/16, -7/16, 8/16},
}

local box_diagfiller22 = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.5, 0.5, -0.5 + 1/16, 0},
		{-0.5, -0.5, 0, 0, -0.5 + 1/16, 1.5},
	},
}

local box_diagfiller22b =  {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.5, 0.5, -0.5 + 1/16, 0},
		{0, -0.5, 0, 0.5, -0.5 + 1/16, 1.5},
	},
}

local box_diagfiller45 = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.5, 0.5, -0.5 + 1/16, 0},
		{-0.5, -0.5, 0, 0, -0.5 + 1/16, 0.5},
		{-1.5, -0.5, 0.5, -0.5, -0.5 + 1/16, 1},
		{-1.5, -0.5, 1, -1, -0.5 + 1/16, 1.5},
	},
}

local box_slope = {
	type = "fixed",
	fixed = {
		{-0.5,  -0.5,  -0.5, 0.5, -0.25, 0.5},
		{-0.5, -0.25, -0.25, 0.5,     0, 0.5},
		{-0.5,     0,     0, 0.5,  0.25, 0.5},
		{-0.5,  0.25,  0.25, 0.5,   0.5, 0.5}
	}
}

local box_slope_half = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5,   -0.5,  0.5, -0.375, 0.5},
		{-0.5, -0.375, -0.25, 0.5, -0.25,  0.5},
		{-0.5, -0.25,  0,    0.5, -0.125, 0.5},
		{-0.5, -0.125, 0.25, 0.5,  0,     0.5},
	}
}

local box_slope_half_raised = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5,   -0.5,  0.5, 0.125, 0.5},
		{-0.5, 0.125, -0.25, 0.5, 0.25,  0.5},
		{-0.5, 0.25,  0,    0.5, 0.375, 0.5},
		{-0.5, 0.375, 0.25, 0.5,  0.5,     0.5},
	}
}

local box_slope_slab = {
	type = "fixed",
	fixed = {
		{0.437500,  -0.5,  -0.5, 0.5, -0.25, 0.5},
		{0.437500, -0.25, -0.25, 0.5,     0, 0.5},
		{0.437500,     0,     0, 0.5,  0.25, 0.5},
		{0.437500,  0.25,  0.25, 0.5,   0.5, 0.5}
	}
}

local box_slope_slab_half = {
	type = "fixed",
	fixed = {
		{0.437500, -0.5,   -0.5,  0.5, -0.375, 0.5},
		{0.437500, -0.375, -0.25, 0.5, -0.25,  0.5},
		{0.437500, -0.25,  0,    0.5, -0.125, 0.5},
		{0.437500, -0.125, 0.25, 0.5,  0,     0.5},
	}
}

local box_slope_slab_half_raised = {
	type = "fixed",
	fixed = {
		{0.437500, -0.5,   -0.5,  0.5, 0.125, 0.5},
		{0.437500, 0.125, -0.25, 0.5, 0.25,  0.5},
		{0.437500, 0.25,  0,    0.5, 0.375, 0.5},
		{0.437500, 0.375, 0.25, 0.5,  0.5,     0.5},
	}
}

--==============================================================

local box_slope_inner = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5},
		{-0.5, -0.5, -0.25, 0.5, 0, 0.5},
		{-0.5, -0.5, -0.5, 0.25, 0, 0.5},
		{-0.5, 0, -0.5, 0, 0.25, 0.5},
		{-0.5, 0, 0, 0.5, 0.25, 0.5},
		{-0.5, 0.25, 0.25, 0.5, 0.5, 0.5},
		{-0.5, 0.25, -0.5, -0.25, 0.5, 0.5},
	}
}

local box_slope_inner_half = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.5, 0.5, -0.375, 0.5},
		{-0.5, -0.375, -0.25, 0.5, -0.25, 0.5},
		{-0.5, -0.375, -0.5, 0.25, -0.25, 0.5},
		{-0.5, -0.25, -0.5, 0, -0.125, 0.5},
		{-0.5, -0.25, 0, 0.5, -0.125, 0.5},
		{-0.5, -0.125, 0.25, 0.5, 0, 0.5},
		{-0.5, -0.125, -0.5, -0.25, 0, 0.5},
	}
}

local box_slope_inner_half_raised = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.5, 0.5, 0.125, 0.5},
		{-0.5, 0.125, -0.25, 0.5, 0.25, 0.5},
		{-0.5, 0.125, -0.5, 0.25, 0.25, 0.5},
		{-0.5, 0.25, -0.5, 0, 0.375, 0.5},
		{-0.5, 0.25, 0, 0.5, 0.375, 0.5},
		{-0.5, 0.375, 0.25, 0.5, 0.5, 0.5},
		{-0.5, 0.375, -0.5, -0.25, 0.5, 0.5},
	}
}

--==============================================================

local box_slope_outer = {
	type = "fixed",
	fixed = {
		{-0.5,  -0.5,  -0.5,   0.5, -0.25, 0.5},
		{-0.5, -0.25, -0.25,  0.25,     0, 0.5},
		{-0.5,     0,     0,     0,  0.25, 0.5},
		{-0.5,  0.25,  0.25, -0.25,   0.5, 0.5}
	}
}

local function f()
	local result = {}

	for i, data in ipairs(box_slope_outer.fixed) do
		-- local a, b, c = table.copy(data), table.copy(data), table.copy(data)

		table.insert(result, {
			data[1],
			(data[2] + 0.5) * 0.9 - 0.5,
			data[3],
			(data[4] + 0.5) / 3 - 0.5,
			(data[5] + 0.5) * 0.9 - 0.5,
			data[6],
		})

		table.insert(result, {
			(data[4] + 0.5) / 3 - 0.5,
			(data[2] + 0.5) * 0.9 - 0.5,
			0.5 - (0.5 - data[3]) / 30 * 6 * 2,
			(data[4] + 0.5) / 3 * 2 - 0.5,
			(data[5] + 0.5) * 0.9 - 0.5,
			data[6],
		})

		table.insert(result, {
			(data[4] + 0.5) / 3 * 2 - 0.5,
			(data[2] + 0.5) * 0.9 - 0.5,
			0.5 - (0.5 - data[3]) / 30 * 6,
			data[4],
			(data[5] + 0.5) * 0.9 - 0.5,
			data[6],
		})
	end
	return {type = "fixed", fixed = result}
end


local box_slope_outer_cut = f()

local function f()
	local result = {}

	for i, data in ipairs(box_slope_outer_cut.fixed) do
		local new_data = table.copy(data)
		result[i] = new_data
		new_data[2] = (data[2] - 0.5) / 2
		new_data[5] = (data[5] - 0.5) / 2
	end
	return {type = "fixed", fixed = result}
end

local box_slope_outer_half_cut = f()

local box_slope_outer_half = {
	type = "fixed",
	fixed = {
		{-0.5,  -0.5,  -0.5,   0.5, -0.375, 0.5},
		{-0.5, -0.375, -0.25,  0.25, -0.25, 0.5},
		{-0.5,  -0.25,     0,     0, -0.125, 0.5},
		{-0.5,  -0.125,  0.25, -0.25, 0, 0.5}
	}
}

local box_slope_outer_half_raised = {
	type = "fixed",
	fixed = {
		{-0.5,  -0.5,  -0.5,   0.5, 0.125, 0.5},
		{-0.5, 0.125, -0.25,  0.25, 0.25, 0.5},
		{-0.5,  0.25,     0,     0, 0.375, 0.5},
		{-0.5,  0.375,  0.25, -0.25, 0.5, 0.5}
	}
}

--==============================================================

local box_slope_triple = {
	type = "fixed",
	fixed = {
		{-0.5,  -0.5,  -1.5, 		0.5, -0.375, 1.5},
		{-0.5,  -0.375,  -1.125,	0.5, -0.25, 1.5},

		{-0.5, -0.25, -0.75, 		0.5, -0.125, 1.5},
		{-0.5, -0.125, -0.375, 		0.5,     0, 1.5},

		{-0.5,     0,     0, 		0.5,  0.125, 1.5},
		{-0.5, 0.125, 0.375, 		0.5,  0.25, 1.5},

		{-0.5,  0.25,  0.75, 		0.5, 0.375, 1.5},
		{-0.5,  0.375,  1.125, 		0.5, 0.5, 1.5},
	}
}

--==============================================================

local box_slope_cut2 = {
	-- box from Extended Circular Saw mod
	type = "fixed",
	fixed = {
		{-0.5,     -0.5,     0, 0.5,  0.25, 0.5},
		{-0.5,  0.25,  0.25, 0.5,   0.5, 0.5},
	},
}

--[[
local box_slab_two_sides_half = {
	type = "fixed",
	fixed = {
		{ -0.5, -0.5, -0.5, 0.5, -7/16, 7/16 },
		{ -0.5, -0.5, 7/16, 0.5, 0.0, 0.5 },
	},
}

local box_slab_three_sides_half = {
	type = "fixed",
	fixed = {
		{ -7/16, -0.5, -0.5, 0.5, -7/16, 7/16 },
		{ -7/16, -0.5, 7/16, 0.5, 0.0, 0.5 },
		{ -0.5, -0.5, -0.5, -7/16, 0.0, 0.5 }
	},
}
]]

--==============================================================
local t = 16/16

local box_roof22 = {
      type = "fixed",
      fixed = {
		{-0.5, -0.5,   -0.5,  0.5, -0.375, -0.2},
		{-0.5, -0.375, -0.25, 0.5, -0.25,  0.05},
		{-0.5, -0.25,  0,    0.5, -0.125, 0.3},
		{-0.5, -0.125, 0.25, 0.5,  0,     0.5},
      },
}

local function f()
	local result = {}
	for i, box in ipairs(box_roof22.fixed) do
		result[i] = {box[1], box[2] + 0.5, box[3], box[4], box[5] + 0.5, box[6]}
	end
	return {type = "fixed", fixed = result}
end

local box_roof22_raised = f()

local function f(b)
	local result = {}
	for i, box in ipairs(b.fixed) do
		result[i] = {-1.5, box[2], box[3], 1.5, box[5], box[6]}
	end
	 return {type = "fixed", fixed = result}
end

local box_roof22_3 = f(box_roof22)
local box_roof22_raised_3 = f(box_roof22_raised)

local box_roof45 = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.5, 0.5, -0.25, -0.25},
		{-0.5, -0.25, -0.25, 0.5, 0, 0},
		{-0.5, 0, 0, 0.5, 0.25, 0.25},
		{-0.5, 0.25, 0.25, 0.5, 0.5, 0.5},
	}
}

local box_roof45_3 = f(box_roof45)

local box_valley = {
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

--==============================================================

local sides_xy = {"front", "back", "left", "right"}
local sides_xyz = {"front", "back", "left", "right", "top", "bottom"}

--==============================================================

stairsplus.defs = {
	["micro"] = {
		[""] = {
			description = "mikroblok 8/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, -0.25, 0, 0.5},
			},
			not_blocking_trains = true,
		},
		["_1"] = {
			description = "mikroblok 1/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, -0.25, -0.4375, 0.5},
			},
			not_blocking_trains = true,
		},
		["_2"] = {
			description = "mikroblok 2/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, -0.25, -0.375, 0.5},
			},
			not_blocking_trains = true,
		},
		["_4"] = {
			description = "mikroblok 4/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, -0.25, -0.25, 0.5},
			},
			not_blocking_trains = true,
		},
		["_12"] = {
			description = "mikroblok 12/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, -0.25, 0.25, 0.5},
			},
		},
		--[[ ["_14"] = {
			description = "mikroblok 14/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, -0.25, 0.375, 0.5},
			},
		}, ]]
		["_15"] = {
			description = "mikroblok 15/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, -0.25, 0.4375, 0.5},
			},
		}
	},
	["panel"] = {
		[""] = {
			description = "panel 8/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, 0.5, 0, 0.5},
			},
			align_style = "world",
			not_blocking_trains = true,
		},
		["_1"] = {
			description = "panel 1/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, 0.5, -0.4375, 0.5},
			},
			align_style = "world",
			not_blocking_trains = true,
		},
		["_2"] = {
			description = "panel 2/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, 0.5, -0.375, 0.5},
			},
			align_style = "world",
			not_blocking_trains = true,
		},
		["_4"] = {
			description = "panel 4/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, 0.5, -0.25, 0.5},
			},
			align_style = "world",
			not_blocking_trains = true,
		},
		["_12"] = {
			description = "panel 12/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, 0.5, 0.25, 0.5},
			},
			align_style = "world",
		},
		--[[ ["_14"] = {
			description = "panel 14/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, 0.5, 0.375, 0.5},
			},
			align_style = "world",
		}, ]]
		["_15"] = {
			description = "panel 15/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, 0.5, 0.4375, 0.5},
			},
			align_style = "world",
		},
		["_special"] = {
			description = "vychýlená tyč I",
			node_box = {
				type = "fixed",
				fixed = {-17/32, -17/32, -17/32, -15/32, 17/32, -15/32},
			},
			selection_box = {
				type = "fixed",
				fixed = {-16/32, -16/32, -16/32, -9/32, 16/32, -9/32},
			},
			align_style = "world",
			not_blocking_trains = true,
		},
		["_l"] = {
			description = "vychýlená tyč L",
			node_box = {
				type = "fixed",
				fixed = {
					{-17/32, -17/32, -17/32, -15/32, 17/32, -15/32},
					{-17/32, -17/32, -17/32, 17/32, -15/32, -15/32},
				},
			},
			selection_box = {
				type = "fixed",
				fixed = {
					{-16/32, -16/32, -16/32, -9/32, 16/32, -9/32},
					{-16/32, -16/32, -16/32, 16/32, -9/32, -9/32},
				},
			},
			align_style = "world",
			not_blocking_trains = true,
		},
		["_l1"] = {
			description = "rohový panel do tvaru L",
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.5, 0.25, 0.5, -0.4375, 0.5},
					{-0.5, -0.5, -0.5, -0.25, -0.4375, 0.25},
				},
			},
			align_style = "world",
		},
		["_wide"] = {
			description = "široký panel 8/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0, 0.5, 0, 0.5},
			},
			align_style = "world",
		},
		["_wide_1"] = {
			description = "široký panel ultratenký",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0, 0.5, -0.46875, 0.5},
			},
			align_style = "world",
			not_blocking_trains = true,
		},
		["_wall"] = {
			description = "zeď (spojující se)",
			node_box = {
				type = "connected",
				fixed = {-0.125, -0.5, -0.125, 0.125, 0.5005, 0.125},
				connect_front = {-0.125, -0.5, -0.5, 0.125, 0.5005, -0.125}, -- -Z
				connect_left = {-0.5, -0.5, -0.125, -0.125, 0.5005, 0.125}, -- -X
				connect_back = {-0.125, -0.5, 0.125, 0.125, 0.5005, 0.5}, -- +Z
				connect_right = {0.125, -0.5, -0.125, 0.5, 0.5005, 0.125}, -- +X
			},
			extra_groups = {wall = 1},
			align_style = "world",
			connects_to = {"group:wall"},
			connect_sides = sides_xy,
		},
		["_wall_flat"] = {
			description = "zeď (přímá)",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, -0.125, 0.5, 0.5005, 0.125},
			},
			align_style = "world",
			extra_groups = {wall = 1},
		},
		["_element"] = {
			description = "nízká zeď (spojující se)",
			node_box = {
				type = "connected",
				fixed = {-0.125, -0.5, -0.125, 0.125, 0.0, 0.125},
				connect_front = {-0.125, -0.5, -0.5, 0.125, 0.0, -0.125}, -- -Z
				connect_left = {-0.5, -0.5, -0.125, -0.125, 0.0, 0.125}, -- -X
				connect_back = {-0.125, -0.5, 0.125, 0.125, 0.0, 0.5}, -- +Z
				connect_right = {0.125, -0.5, -0.125, 0.5, 0.0, 0.125}, -- +X
			},
			connect_sides = sides_xy,
			connects_to = {"group:short_wall"},
			align_style = "world",
			extra_groups = {short_wall = 1},
		},
		["_element_flat"] = {
			description = "nízká zeď (přímá)",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, -0.125, 0.5, 0.0, 0.125},
			},
			align_style = "world",
			extra_groups = {short_wall = 1},
		},
		["_pole"] = {
			description = "tyč (spojující se)",
			node_box = {
				type = "connected",
				fixed = {-0.125, -0.125, -0.125, 0.125, 0.125, 0.125},
				connect_top = {-0.125, 0.125, -0.125, 0.125, 0.5, 0.125}, -- +Y
				connect_bottom = {-0.125, -0.5, -0.125, 0.125, -0.125, 0.125}, -- -Y
				connect_front = {-0.125, -0.125, -0.5, 0.125, 0.125, -0.125}, -- -Z
				connect_left = {-0.5, -0.125, -0.125, -0.125, 0.125, 0.125}, -- -X
				connect_back = {-0.125, -0.125, 0.125, 0.125, 0.125, 0.5}, -- +Z
				connect_right = {0.125, -0.125, -0.125, 0.5, 0.125, 0.125}, -- +X
			},
			connect_sides = sides_xyz,
			connects_to = {"group:panel_pole", "group:full_cube_node", "group:attracts_poles"}, -- no fence, no wall
			extra_groups = {panel_pole = 1},
			align_style = "world",
			check_for_pole = true,
			not_blocking_trains = true,
		},
		["_pole_flat"] = {
			description = "tyč (přímá)",
			node_box = {
				type = "fixed",
				fixed = {-0.125, -0.5, -0.125, 0.125, 0.5, 0.125},
			},
			extra_groups = {panel_pole = 1},
			align_style = "world",
			check_for_pole = true,
			not_blocking_trains = true,
		},
		["_pole_thin"] = {
			description = "tenká tyč (spojující se)",
			node_box = {
				type = "connected",
				fixed = {-0.0625, -0.0625, -0.0625, 0.0625, 0.0625, 0.0625},
				connect_top = {-0.0625, 0.0625, -0.0625, 0.0625, 0.5, 0.0625}, -- +Y
				connect_bottom = {-0.0625, -0.5, -0.0625, 0.0625, -0.0625, 0.0625}, -- -Y
				connect_front = {-0.0625, -0.0625, -0.5, 0.0625, 0.0625, -0.0625}, -- -Z
				connect_left = {-0.5, -0.0625, -0.0625, -0.0625, 0.0625, 0.0625}, -- -X
				connect_back = {-0.0625, -0.0625, 0.0625, 0.0625, 0.0625, 0.5}, -- +Z
				connect_right = {0.0625, -0.0625, -0.0625, 0.5, 0.0625, 0.0625}, -- +X
			},
			connect_sides = sides_xyz,
			connects_to = {"group:panel_pole_thin", "group:wall", "group:full_cube_node", "group:attracts_poles"}, -- no fence, no wall
			extra_groups = {panel_pole_thin = 1},
			align_style = "world",
			not_blocking_trains = true,
		},
		["_pole_thin_flat"] = {
			description = "tenká tyč (přímá)",
			node_box = {
				type = "fixed",
				fixed = {-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625},
			},
			extra_groups = {panel_pole_thin = 1},
			align_style = "world",
			not_blocking_trains = true,
		},
		["_banister"] = {
			description = "zábradlí",
			node_box = {
				type = "fixed",
				fixed = {
					{-8/16, 7/16, 5/16, 8/16, 8/16, 8/16}, -- horní deska
					{-9/32, -8/16, 6/16, -7/32, 7/16, 7/16}, -- levá tyč
					{9/32, -8/16, 6/16, 7/32, 7/16, 7/16}, -- pravá tyč
				},
			},
			not_blocking_trains = true,
		},
	},
	["slab"] = {
		[""] = {
			description = "deska 8/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, -0.5, 0.5, 8/16 - 0.5, 0.5},
			},
			not_blocking_trains = true,
		},
		["_quarter"] = {
			description = "deska 4/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, -0.5, 0.5, 4/16 - 0.5, 0.5},
			},
			not_blocking_trains = true,
		},
		["_three_quarter"] = {
			description = "deska 12/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, -0.5, 0.5, 12/16 - 0.5, 0.5},
			},
		},
		["_1"] = {
			description = "deska 1/64",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, -0.5, 0.5, 1/64 - 0.5, 0.5},
			},
			selection_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, -0.5, 0.5, 1/16 - 0.5, 0.5},
			},
			not_blocking_trains = true,
		},
		["_2"] = {
			description = "deska 2/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, -0.5, 0.5, 2/16 - 0.5, 0.5},
			},
			not_blocking_trains = true,
		},
		["_14"] = {
			description = "deska 14/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, -0.5, 0.5, 14/16 - 0.5, 0.5},
			},
		},
		["_15"] = {
			description = "deska 15/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, -0.5, 0.5, 15/16 - 0.5, 0.5},
			},
		},
		["_two_sides"] = {
			description = "deska L (dvě strany)",
			node_box = {
				type = "fixed",
				fixed = {
					{ -0.5, -0.5, -0.5, 0.5, -7/16, 7/16 },
					{ -0.5, -0.5, 7/16, 0.5, 0.5, 0.5 }
				},
			},
			not_blocking_trains = true,
		},
		["_three_sides"] = {
			description = "deska rohová (tři strany)",
			node_box = {
				type = "fixed",
				fixed = {
					{ -7/16, -0.5, -0.5, 0.5, -7/16, 7/16 },
					{ -7/16, -0.5, 7/16, 0.5, 0.5, 0.5 },
					{ -0.5, -0.5, -0.5, -7/16, 0.5, 0.5 }
				},
			},
		},
		["_three_sides_u"] = {
			description = "deska U (tři strany)",
			node_box = {
				type = "fixed",
				fixed = {
					{ -0.5, -0.5, -0.5, 0.5, 0.5, -7/16 },
					{ -0.5, -0.5, -7/16, 0.5, -7/16, 7/16 },
					{ -0.5, -0.5, 7/16, 0.5, 0.5, 0.5 }
				},
			},
		},
		["_triplet"] = {
			description = "trojitá deska 1/64",
			node_box = {
				type = "fixed",
				fixed = { -1.5, -0.5, -0.5, 1.5, -0.5 + 1/64, 0.5},
			},
			selection_box = {
				type = "fixed",
				fixed = { -1.5, -0.5, -0.5, 1.5, -0.5 + 1/16, 0.5},
			},
			not_blocking_trains = true,
		},
		["_cube"] = {
			description = "kvádr",
			node_box = {
				type = "fixed",
				fixed = {
					{-6/16, -8/16, -6/16, 6/16, 6/16, 6/16},
				},
			},
		},
		--[[
		["_pit_half"] = {
			description = "nádoba nízká",
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.5, -0.5, 0.5, -0.5 + 1/16, 0.5}, -- bottom
					{-0.5, -0.5 + 1/16, -0.5, -0.5 + 1/16, -1/4, 0.5}, -- -x
					{0.5 - 1/16, -0.5 + 1/16, -0.5, 0.5, -1/4, 0.5}, -- +x
					{-0.5 + 1/16, -0.5 + 1/16, -0.5, 0.5 - 1/16, -1/4, -0.5 + 1/16}, -- -z
					{-0.5 + 1/16, -0.5 + 1/16, 0.5 - 1/16, 0.5 - 1/16, -1/4, 0.5}, -- -z
				},
			},
		},
		["_pit"] = {
			description = "nádoba vysoká",
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.5, -0.5, 0.5, -0.5 + 1/16, 0.5}, -- bottom
					{-0.5, -0.5 + 1/16, -0.5, -0.5 + 1/16, 0.5, 0.5}, -- -x
					{0.5 - 1/16, -0.5 + 1/16, -0.5, 0.5, 0.5, 0.5}, -- +x
					{-0.5 + 1/16, -0.5 + 1/16, -0.5, 0.5 - 1/16, 0.5, -0.5 + 1/16}, -- -z
					{-0.5 + 1/16, -0.5 + 1/16, 0.5 - 1/16, 0.5 - 1/16, 0.5, 0.5}, -- -z
				},
			},
		},
		]]
		["_two_sides_half"] = {
			description = "deska L (dvě strany, seříznutá)",
			node_box = {
				type = "fixed",
				fixed = {
					{ -0.5, -0.5, -0.5, 0.5, -7/16, 7/16 },
					{ -0.5, -0.5, 7/16, 0.5, 0.0, 0.5 }
				},
			},
			not_blocking_trains = true,
		},
		["_three_sides_half"] = {
			description = "deska rohová (tři strany, seříznutá)",
			node_box = {
				type = "fixed",
				fixed = {
					{ -7/16, -0.5, -0.5, 0.5, -7/16, 7/16 },
					{ -7/16, -0.5, 7/16, 0.5, 0.0, 0.5 },
					{ -0.5, -0.5, -0.5, -7/16, 0.0, 0.5 }
				},
			},
		},
		["_rcover"] = {
			description = "kryt na koleje",
			node_box = {
				type = "fixed",
				fixed = { -0.5, -0.5, -0.5, 1.5, -0.5 + 1/16, 0.5},
			},
			align_style = "world",
			not_blocking_trains = true,
		},
		["_arcade"] = {
			description = "překlad přes zeď (spojující se)",
			node_box = {
				type = "connected",
				fixed = {-3/16, -17/32, -3/16, 3/16, -13/32, 3/16},
				connect_front = {-3/16, -17/32, -1/2, 3/16, -13/32, 3/16},
				connect_left = {-1/2, -17/32, -3/16, -3/16, -13/32, 3/16},
				connect_back = {-3/16, -17/32, 3/16, 3/16, -13/32, 1/2},
				connect_right = {3/16, -17/32, -3/16, 1/2, -13/32, 3/16},
			},
			align_style = "world",
			connect_sides = sides_xy,
			connects_to = {"group:arcade"},
			extra_groups = {arcade = 1},
		},
		["_arcade_flat"] = {
			description = "překlad přes zeď (přímý)",
			node_box = {
				type = "fixed",
				fixed = {-8/16, -17/32, -3/16, 8/16, -13/32, 3/16},
			},
			align_style = "world",
			extra_groups = {arcade = 1},
		},
		["_table"] = {
			description = "stůl",
			node_box = {
				type = "fixed",
				fixed = {
					{-8/16, 7/16, -8/16, 8/16, 8/16, 8/16}, -- horní deska
					{-4/16, -8/16, -4/16, 4/16, -7/16, 4/16}, -- podstavec
					{-1/16, -7/16, -1/16, 1/16, 7/16, 1/16}, -- tyč
				},
			},
		},
		["_bars"] = {
			description = "zábradlí či mříž",
			node_box = {
				type = "fixed",
				fixed = {
					{-17/32, -16/32, 15/32, -15/32, 16/32, 17/32}, -- levá tyč
					{15/32, -16/32, 15/32, 17/32, 16/32, 17/32}, -- pravá tyč
					{-15/32, 2/6, 15/32, 15/32, 3/6, 17/32}, -- horní pruh
					{-15/32, 0/6, 15/32, 15/32, 1/6, 17/32}, -- druhý pruh
					{-15/32, -2/6, 15/32, 15/32, -1/6, 17/32}, -- třetí pruh
				},
			},
			align_style = "world",
			not_blocking_trains = true,
		}
	},
	["slope"] = {
		[""] = {
			description = "svah 45°",
			mesh = "moreblocks_slope.obj",
			collision_box = box_slope,
			selection_box = box_slope,
			not_blocking_trains = true,
		},
		["_half"] = {
			description = "svah 30°, spodní díl",
			mesh = "moreblocks_slope_half.obj",
			collision_box = box_slope_half,
			selection_box = box_slope_half,
			not_blocking_trains = true,
		},
		["_half_raised"] = {
			description = "svah 30°, horní díl",
			mesh = "moreblocks_slope_half_raised.obj",
			collision_box = box_slope_half_raised,
			selection_box = box_slope_half_raised,
			not_blocking_trains = true,
		},

		--==============================================================

		["_inner"] = {
			description = "svah 45°, vnitřní roh",
			mesh = "moreblocks_slope_inner.obj",
			collision_box = box_slope_inner,
			selection_box = box_slope_inner,
		},
		["_inner_half"] = {
			description = "svah 30°, vnitřní roh, spodní díl",
			mesh = "moreblocks_slope_inner_half.obj",
			collision_box = box_slope_inner_half,
			selection_box = box_slope_inner_half,
		},
		["_inner_half_raised"] = {
			description = "svah 30°, vnitřní roh, horní díl",
			mesh = "moreblocks_slope_inner_half_raised.obj",
			collision_box = box_slope_inner_half_raised,
			selection_box = box_slope_inner_half_raised,
		},

		--==============================================================

		["_inner_cut"] = {
			description = "svah 45°, vnitřní roh, úhlopříčný, spodní díl",
			mesh = "moreblocks_slope_inner_cut.obj",
			collision_box = box_slope_inner,
			selection_box = box_slope_inner,
		},
		["_inner_cut_half"] = {
			description = "svah 30°, vnitřní roh, úhlopříčný zespodu do poloviční výšky",
			mesh = "moreblocks_slope_inner_cut_half.obj",
			collision_box = box_slope_inner_half,
			selection_box = box_slope_inner_half,
		},
		["_inner_cut_half_raised"] = {
			description = "svah 30°, vnitřní roh, úhlopříčný z poloviční výšky nahoru",
			mesh = "moreblocks_slope_inner_cut_half_raised.obj",
			collision_box = box_slope_inner_half_raised,
			selection_box = box_slope_inner_half_raised,
		},

		--==============================================================

		["_outer"] = {
			description = "svah 45°, vnější roh",
			mesh = "moreblocks_slope_outer.obj",
			collision_box = box_slope_outer,
			selection_box = box_slope_outer,
		},
		["_outer_half"] = {
			description = "svah 30°, vnější roh, spodní díl",
			mesh = "moreblocks_slope_outer_half.obj",
			collision_box = box_slope_outer_half,
			selection_box = box_slope_outer_half,
		},
		["_outer_half_raised"] = {
			description = "svah 30°, vnější roh, horní díl",
			mesh = "moreblocks_slope_outer_half_raised.obj",
			collision_box = box_slope_outer_half_raised,
			selection_box = box_slope_outer_half_raised,
		},

		--==============================================================

		["_outer_cut"] = {
			description = "svah 45°, vnitřní roh, úhlopříčný, horní díl",
			mesh = "moreblocks_slope_outer_cut.obj",
			collision_box = box_slope_outer_cut,
			selection_box = box_slope_outer_cut,
		},
		["_outer_cut_half"] = {
			description = "svah 30°, vnější roh, úhlopříčný zespodu do poloviční výšky",
			mesh = "moreblocks_slope_outer_cut_half.obj",
			collision_box = box_slope_outer_half_cut,
			selection_box = box_slope_outer_half_cut,
		},
                 --[[
		["_outer_cut_half_raised"] = {
			description = "seříznutý úhlopříčný svah poloviční",
			mesh = "moreblocks_slope_outer_cut_half_raised.obj",
			collision_box = box_slope_outer_half_raised,
			selection_box = box_slope_outer_half_raised,
		}, ]]
		["_cut"] = {
			description = "úhlopříčný svah prudký", -- [ ] ?
			mesh = "moreblocks_slope_cut.obj",
			collision_box = box_slope_outer,
			selection_box = box_slope_outer,
		},

		--==============================================================

		["_slab"] = {
			description = "trojúhelník",
			mesh = "moreblocks_slope_slab.obj",
			collision_box = box_slope_slab,
			selection_box = box_slope_slab,
			not_blocking_trains = true,
		},

		--[[
		["_slab_half"] = {
			description
			mesh = "moreblocks_slope_slab_half.obj",
			collision_box = box_slope_slab_half,
			selection_box = box_slope_slab_half,
		},

		["_slab_half_raised"] = {
			description
			mesh = "moreblocks_slope_slab_half_raised.obj",
			collision_box = box_slope_slab_half_raised,
			selection_box = box_slope_slab_half_raised,
		}, ]]

		--==============================================================

		["_tripleslope"] = {
			description = "svah 20°",
			mesh = "moreblocks_slope_triple.obj",
			collision_box = box_slope_triple,
			selection_box = box_slope_triple,
			not_blocking_trains = true,
		},

		["_cut2"] = {
			description = "šikmá hradba",
			mesh = "moreblocks_xslopes_cut.obj",
			collision_box = box_slope_cut2,
			selection_box = box_slope_cut2,
		},

		["_roof22"] = {
			description = "střecha 22°, spodní díl",
			mesh = "moreblocks_roof22.obj",
			collision_box = box_roof22,
			selection_box = box_roof22,
		},

		["_roof22_raised"] = {
			description = "střecha 22°, horní díl",
			mesh = "moreblocks_roof22_raised.obj",
			collision_box = box_roof22_raised,
			selection_box = box_roof22_raised,
		},

		["_roof22_3"] = {
			description = "střecha 22°, spodní díl trojitý",
			mesh = "moreblocks_roof22_3.obj",
			collision_box = box_roof22_3,
			selection_box = box_roof22_3,
		},

		["_roof22_raised_3"] = {
			description = "střecha 22°, horní díl trojitý",
			mesh = "moreblocks_roof22_raised_3.obj",
			collision_box = box_roof22_raised_3,
			selection_box = box_roof22_raised_3,
		},

		["_roof45"] = {
			description = "střecha 45°",
			mesh = "moreblocks_roof45.obj",
			collision_box = box_roof45,
			selection_box = box_roof45,
		},

		["_roof45_3"] = {
			description = "střecha 45°, trojitý díl",
			mesh = "moreblocks_roof45_3.obj",
			collision_box = box_roof45_3,
			selection_box = box_roof45_3,
		},
		["_beveled"] = {
			description = "zkosená deska",
			mesh = "moreblocks_beveled_tile.obj",
			collision_box = box_beveled_slab,
			selection_box = box_beveled_slab,
		},
		["_diagfiller22a"] = {
			description = "diagonální výplň 22° A",
			mesh = "ch_core_diagfiller_22a.obj",
			selection_box = box_diagfiller22,
			paramtype2 = "4dir",
			backface_culling = false,
			not_blocking_trains = true,
			walkable = false,
		},
		["_diagfiller22b"] = {
			description = "diagonální výplň 22° B",
			mesh = "ch_core_diagfiller_22b.obj",
			selection_box = box_diagfiller22b,
			paramtype2 = "4dir",
			backface_culling = false,
			not_blocking_trains = true,
			walkable = false,
		},
		["_diagfiller45"] = {
			description = "diagonální výplň 45° dvojitá",
			mesh = "ch_core_diagfiller_45.obj",
			selection_box = box_diagfiller45,
			paramtype2 = "4dir",
			backface_culling = false,
			not_blocking_trains = true,
			walkable = false,
		},
		["_valley"] = {
			description = "zářez",
			mesh = "mymeshnodes_valley.obj",
			selection_box = box_valley,
		},
	},
	["stair"] = {
		[""] = {
			description = "schod 8/16",
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
					{-0.5, 0, 0, 0.5, 0.5, 0.5},
				},
			},
			align_style = "world",
			extra_groups = {stair = 1},
		},
		["_inner"] = {
			description = "schod, vnitřní roh",
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
					{-0.5, 0, 0, 0.5, 0.5, 0.5},
					{-0.5, 0, -0.5, 0, 0.5, 0},
				},
			},
			align_style = "world",
		},
		["_outer"] = {
			description = "schod, vnější roh",
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
					{-0.5, 0, 0, 0, 0.5, 0.5},
				},
			},
			align_style = "world",
		},
		["_alt"] = {
			description = "schody samostatné 8/16",
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.5, -0.5, 0.5, 0, 0},
					{-0.5, 0, 0, 0.5, 0.5, 0.5},
				},
			},
			align_style = "world",
		},
		["_alt_1"] = {
			description = "schody samostatné 1/16",
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.0625, -0.5, 0.5, 0, 0},
					{-0.5, 0.4375, 0, 0.5, 0.5, 0.5},
				},
			},
			align_style = "world",
		},
		["_alt_2"] = {
			description = "schody samostatné 2/16",
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.125, -0.5, 0.5, 0, 0},
					{-0.5, 0.375, 0, 0.5, 0.5, 0.5},
				},
			},
			align_style = "world",
		},
		["_alt_4"] = {
			description = "schody samostatné 4/16",
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.25, -0.5, 0.5, 0, 0},
					{-0.5, 0.25, 0, 0.5, 0.5, 0.5},
				},
			},
			align_style = "world",
		},
		["_triple"] = {
			description = "schody třetinové",
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.5, -0.5, 							0.5, -0.166666666667, 0.5},
					{-0.5, -0.166666666667, -0.166666666667,	0.5, 0.166666666667, 0.5},
					{-0.5, 0.166666666667, 0.166666666667,		0.5, 0.5, 0.5},
				},
			},
			align_style = "world",
		},
		["_chimney"] = {
			description = "úzký komín",
			node_box = {
				type = "fixed",
				fixed = {
					{-4/16, -10/16, -4/16, -2.5/16, 8/16, 4/16},
					{2.5/16, -10/16, -4/16, 4/16, 8/16, 4/16},
					{-2.5/16, -10/16, -4/16, 2.5/16, 8/16, -2.5/16},
					{-2.5/16, -10/16, 2.5/16, 2.5/16, 8/16, 4/16},
				},
			},
		},
		["_wchimney"] = {
			description = "široký komín",
			node_box = {
				type = "fixed",
				fixed = {
					{-8/16, -8/16, -8/16, -6/16, 8/16, 8/16},
					{6/16, -8/16, -8/16, 8/16, 8/16, 8/16},
					{-6/16, -8/16, -8/16, 6/16, 8/16, -6/16},
					{-6/16, -8/16, 6/16, 6/16, 8/16, 8/16},
				},
			},
			climbable = true,
		},
	},
}

for type,a in pairs(stairsplus.defs) do
	for name,b in pairs(stairsplus.defs[type]) do
		table.insert(stairsplus.shapes_list, { type .. "_", name })
	end
end
