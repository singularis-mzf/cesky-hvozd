--[[
More Blocks: registrations

Copyright © 2011-2020 Hugo Locurcio and contributors.
Licensed under the zlib license. See LICENSE.md for more information.
--]]


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

local function generate_box_slope_outer_cut()
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
	return result
end


local box_slope_outer_cut = {
	type = "fixed",
	fixed = generate_box_slope_outer_cut(),
}

local function generate_box_slope_outer_cut_half()
	local result = {}

	for i, data in ipairs(box_slope_outer_cut.fixed) do
		local new_data = table.copy(data)
		result[i] = new_data
		new_data[2] = (data[2] - 0.5) / 2
		new_data[5] = (data[5] - 0.5) / 2
	end
	return result
end

local box_slope_outer_half_cut = {
	type = "fixed",
	fixed = generate_box_slope_outer_cut_half(),
}

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


stairsplus.defs = {
	["micro"] = {
		[""] = {
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, -0.25, 0, 0.5},
			},
		},
		["_1"] = {
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, -0.25, -0.4375, 0.5},
			},
		},
		["_2"] = {
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, -0.25, -0.375, 0.5},
			},
		},
		["_4"] = {
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, -0.25, -0.25, 0.5},
			},
		},
		["_12"] = {
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, -0.25, 0.25, 0.5},
			},
		},
		--[[ ["_14"] = {
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, -0.25, 0.375, 0.5},
			},
		}, ]]
		["_15"] = {
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, -0.25, 0.4375, 0.5},
			},
		}
	},
	["panel"] = {
		[""] = {
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, 0.5, 0, 0.5},
			},
		},
		["_1"] = {
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, 0.5, -0.4375, 0.5},
			},
		},
		["_2"] = {
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, 0.5, -0.375, 0.5},
			},
		},
		["_4"] = {
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, 0.5, -0.25, 0.5},
			},
		},
		["_12"] = {
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, 0.5, 0.25, 0.5},
			},
		},
		--[[ ["_14"] = {
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, 0.5, 0.375, 0.5},
			},
		}, ]]
		["_15"] = {
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, 0.5, 0.4375, 0.5},
			},
		},
		["_special"] = {
			node_box = {
				type = "fixed",
				fixed = {-17/32, -17/32, -17/32, -15/32, 17/32, -15/32},
			},
			selection_box = {
				type = "fixed",
				fixed = {-16/32, -16/32, -16/32, -9/32, 16/32, -9/32},
			},
		},
		["_l"] = {
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
		},
		["_l1"] = {
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.5, 0.25, 0.5, -0.4375, 0.5},
					{-0.5, -0.5, -0.5, -0.25, -0.4375, 0.25},
				},
			},
		},
		["_wide"] = {
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0, 0.5, 0, 0.5},
			},
		},
		["_wide_1"] = {
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0, 0.5, -0.46875, 0.5},
			},
		},
	},
	["slab"] = {
		[""] = 8,
		["_quarter"] = 4,
		["_three_quarter"] = 12,
		["_1"] = 1,
		["_2"] = 2,
		["_14"] = 14,
		["_15"] = 15,
		["_two_sides"] = {
			{ -0.5, -0.5, -0.5, 0.5, -7/16, 7/16 },
			{ -0.5, -0.5, 7/16, 0.5, 0.5, 0.5 }
		},
		["_three_sides"] = {
			{ -7/16, -0.5, -0.5, 0.5, -7/16, 7/16 },
			{ -7/16, -0.5, 7/16, 0.5, 0.5, 0.5 },
			{ -0.5, -0.5, -0.5, -7/16, 0.5, 0.5 }
		},
		["_three_sides_u"] = {
			{ -0.5, -0.5, -0.5, 0.5, 0.5, -7/16 },
			{ -0.5, -0.5, -7/16, 0.5, -7/16, 7/16 },
			{ -0.5, -0.5, 7/16, 0.5, 0.5, 0.5 }
		},
		["_triplet"] = {
			{ -1.5, -0.5, -0.5, 1.5, -7/16, 0.5},
		},
	},
	["slope"] = {
		[""] = {
			mesh = "moreblocks_slope.obj",
			collision_box = box_slope,
			selection_box = box_slope,

		},
		["_half"] = {
			mesh = "moreblocks_slope_half.obj",
			collision_box = box_slope_half,
			selection_box = box_slope_half,
		},
		["_half_raised"] = {
			mesh = "moreblocks_slope_half_raised.obj",
			collision_box = box_slope_half_raised,
			selection_box = box_slope_half_raised,
		},

		--==============================================================

		["_inner"] = {
			mesh = "moreblocks_slope_inner.obj",
			collision_box = box_slope_inner,
			selection_box = box_slope_inner,
		},
		["_inner_half"] = {
			mesh = "moreblocks_slope_inner_half.obj",
			collision_box = box_slope_inner_half,
			selection_box = box_slope_inner_half,
		},
		["_inner_half_raised"] = {
			mesh = "moreblocks_slope_inner_half_raised.obj",
			collision_box = box_slope_inner_half_raised,
			selection_box = box_slope_inner_half_raised,
		},

		--==============================================================

		["_inner_cut"] = {
			mesh = "moreblocks_slope_inner_cut.obj",
			collision_box = box_slope_inner,
			selection_box = box_slope_inner,
		},
		["_inner_cut_half"] = {
			mesh = "moreblocks_slope_inner_cut_half.obj",
			collision_box = box_slope_inner_half,
			selection_box = box_slope_inner_half,
		},
		["_inner_cut_half_raised"] = {
			mesh = "moreblocks_slope_inner_cut_half_raised.obj",
			collision_box = box_slope_inner_half_raised,
			selection_box = box_slope_inner_half_raised,
		},

		--==============================================================

		["_outer"] = {
			mesh = "moreblocks_slope_outer.obj",
			collision_box = box_slope_outer,
			selection_box = box_slope_outer,
		},
		["_outer_half"] = {
			mesh = "moreblocks_slope_outer_half.obj",
			collision_box = box_slope_outer_half,
			selection_box = box_slope_outer_half,
		},
		["_outer_half_raised"] = {
			mesh = "moreblocks_slope_outer_half_raised.obj",
			collision_box = box_slope_outer_half_raised,
			selection_box = box_slope_outer_half_raised,
		},

		--==============================================================

		["_outer_cut"] = {
			mesh = "moreblocks_slope_outer_cut.obj",
			collision_box = box_slope_outer_cut,
			selection_box = box_slope_outer_cut,
		},
		["_outer_cut_half"] = {
			mesh = "moreblocks_slope_outer_cut_half.obj",
			collision_box = box_slope_outer_half_cut,
			selection_box = box_slope_outer_half_cut,
		},
		["_outer_cut_half_raised"] = {
			mesh = "moreblocks_slope_outer_cut_half_raised.obj",
			collision_box = box_slope_outer_half_raised,
			selection_box = box_slope_outer_half_raised,
		},
		["_cut"] = {
			mesh = "moreblocks_slope_cut.obj",
			collision_box = box_slope_outer,
			selection_box = box_slope_outer,
		},

		--==============================================================

		["_slab"] = {
			mesh = "moreblocks_slope_slab.obj",
			collision_box = box_slope_slab,
			selection_box = box_slope_slab,
		},

		--[[
		["_slab_half"] = {
			mesh = "moreblocks_slope_slab_half.obj",
			collision_box = box_slope_slab_half,
			selection_box = box_slope_slab_half,
		},

		["_slab_half_raised"] = {
			mesh = "moreblocks_slope_slab_half_raised.obj",
			collision_box = box_slope_slab_half_raised,
			selection_box = box_slope_slab_half_raised,
		}, ]]

		--==============================================================

		["_tripleslope"] = {
			mesh = "moreblocks_slope_triple.obj",
			collision_box = box_slope_triple,
			selection_box = box_slope_triple,
		},
	},
	["stair"] = {
		[""] = {
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
					{-0.5, 0, 0, 0.5, 0.5, 0.5},
				},
			},
		},
		["_inner"] = {
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
					{-0.5, 0, 0, 0.5, 0.5, 0.5},
					{-0.5, 0, -0.5, 0, 0.5, 0},
				},
			},
		},
		["_outer"] = {
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
					{-0.5, 0, 0, 0, 0.5, 0.5},
				},
			},
		},
		["_alt"] = {
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.5, -0.5, 0.5, 0, 0},
					{-0.5, 0, 0, 0.5, 0.5, 0.5},
				},
			},
		},
		["_alt_1"] = {
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.0625, -0.5, 0.5, 0, 0},
					{-0.5, 0.4375, 0, 0.5, 0.5, 0.5},
				},
			},
		},
		["_alt_2"] = {
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.125, -0.5, 0.5, 0, 0},
					{-0.5, 0.375, 0, 0.5, 0.5, 0.5},
				},
			},
		},
		["_alt_4"] = {
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.25, -0.5, 0.5, 0, 0},
					{-0.5, 0.25, 0, 0.5, 0.5, 0.5},
				},
			},
		},
		["_triple"] = {
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.5, -0.5, 							0.5, -0.166666666667, 0.5},
					{-0.5, -0.166666666667, -0.166666666667,	0.5, 0.166666666667, 0.5},
					{-0.5, 0.166666666667, 0.166666666667,		0.5, 0.5, 0.5},
				},
			},
		},
	},
}

for type,a in pairs(stairsplus.defs) do
	for name,b in pairs(stairsplus.defs[type]) do
		table.insert(stairsplus.shapes_list, { type .. "_", name })
	end
end
