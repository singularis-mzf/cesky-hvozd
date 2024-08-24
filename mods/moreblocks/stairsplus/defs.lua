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
			not_blocking_trains = true,
		},
		["_1"] = {
			description = "panel 1/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, 0.5, -0.4375, 0.5},
			},
			not_blocking_trains = true,
		},
		["_2"] = {
			description = "panel 2/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, 0.5, -0.375, 0.5},
			},
			not_blocking_trains = true,
		},
		["_4"] = {
			description = "panel 4/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, 0.5, -0.25, 0.5},
			},
			not_blocking_trains = true,
		},
		["_12"] = {
			description = "panel 12/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, 0.5, 0.25, 0.5},
			},
		},
		--[[ ["_14"] = {
			description = "panel 14/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, 0.5, 0.375, 0.5},
			},
		}, ]]
		["_15"] = {
			description = "panel 15/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0.25, 0.5, 0.4375, 0.5},
			},
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
		},
		["_wide"] = {
			description = "široký panel 8/16",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0, 0.5, 0, 0.5},
			},
		},
		["_wide_1"] = {
			description = "široký panel ultratenký",
			node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, 0, 0.5, -0.46875, 0.5},
			},
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
			description = "deska 1/16",
			node_box = {
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
			description = "trojitá deska",
			node_box = {
				type = "fixed",
				fixed = { -1.5, -0.5, -0.5, 1.5, -7/16, 0.5},
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
		},
	},
}

for type,a in pairs(stairsplus.defs) do
	for name,b in pairs(stairsplus.defs[type]) do
		table.insert(stairsplus.shapes_list, { type .. "_", name })
	end
end
