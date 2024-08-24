local S = moreblocks.S
local F = minetest.formspec_escape

local custom_subset = {
	{"panel", "_double_1"},
	{"panel", "_double_2"},
	{"panel", "_double_4"},
	{"panel", "_double_12"},
	{"panel", "_double_14"},
	{"panel", "_double_15"},
	{"panel", "_double_16"},
	{"panel", "_16"},
	{"panel", "_pillar"},
	{"panel", "_pcend"},

	{"slab", "_two_sides_half"},
	{"slab", "_two_sides_half_2"},
	{"slab", "_two_sides_half_3"},
	{"slab", "_two_sides_half_4"},
	{"slab", "_two_sides_half_5"},
	{"slab", "_two_sides_half_6"},
	{"slab", "_three_sides_half"},
	{"slab", "_three_sides_half_2"},
	{"slab", "_three_sides_half_3"},
	{"slab", "_four_sides"},
	{"slab", "_hole"},
	{"slab", "_two_opposite"},
	{"slab", "_pit"},
	{"slab", "_pit_half"},
	{"slab", "_hole_half"},
	{"slab", "_two_sides_2"},
	{"slab", "_two_sides_3"},
	{"slab", "_three_sides_2"},
	{"slab", "_three_sides_3"},

	{"slope", "_half_lh"},
	{"slope", "_half_rh"},
	{"slope", "_half_raised_lh"},
	{"slope", "_half_raised_rh"},
	{"slope", "_astair_1"},
	{"slope", "_astair_2"},
	{"slope", "_astair_3"},
	{"slope", "_astair_4"},
	{"slope", "_inner_cut2"},
	{"slope", "_inner_cut3"},
	{"slope", "_inner_cut4"},
	{"slope", "_inner_cut5"},
	{"slope", "_inner_cut6"},
	{"slope", "_inner_cut7"},
	{"slope", "_inner_cut8"},
	{"slope", "_cut2"},
	{"slope", "_lh"},
	{"slope", "_rh"},
	{"slope", "_peak_half_lh"},
	{"slope", "_peak_half"},
	{"slope", "_peak_lh"},
	{"slope", "_peak"},
	{"slope", "_quarter"},
	{"slope", "_quarter2"},
	{"slope", "_slope_lh"},
	{"slope", "_slope_rh"},
	{"slope", "_slope"},
	{"slope", "_three_quarter_half"},
	{"slope", "_three_quarter"},
	{"slope", "_sloped_slat"},
	{"slope", "_vertical_slat"},
	{"slope", "_vertical_inclined_slat"},
	{"slope", "_horizontal_slat"},
	{"slope", "_horizontal_corner_slat"},
	{"slope", "_horizontal_folded_slat"},
	{"slope", "_inclined_folded_slat"},
	{"slope", "_inclined_slat_lh"},
	{"slope", "_inclined_slat_rh"},

	{"stair", "_half_1"},
	{"stair", "_right_half_1"},
	{"stair", "_alt_5"},
	{"stair", "_alt_6"}
}

local function node_box(boxes)
	return {
		node_box = {
			type = "fixed",
			fixed = boxes
		},
	}
end

local function mesh_def(mesh, boxes)
	return {
		mesh = mesh,
		collision_box = {
			type = "fixed",
			fixed = boxes,
		},
		selection_box = {
			type = "fixed",
			fixed = boxes
		},
	}
end

local function pixel_box(x1, y1, z1, x2, y2, z2)
	return {
		x1 / 16 - 0.5,
		y1 / 16 - 0.5,
		z1 / 16 - 0.5,
		x2 / 16 - 0.5,
		y2 / 16 - 0.5,
		z2 / 16 - 0.5,
	}
end


-- Panels boxes
stairsplus.defs.panel._double_1 = node_box({
	{-0.5, -0.5, -0.5, 0, -0.4375, 0},
	{0, -0.5, 0, 0.5, -0.4375, 0.5}
})

stairsplus.defs.panel._double_2 = node_box({
	{-0.5, -0.5, -0.5, 0, -0.375, 0},
	{0, -0.5, 0, 0.5, -0.375, 0.5}
})

stairsplus.defs.panel._double_4 = node_box({
	{-0.5, -0.5, -0.5, 0, -0.25, 0},
	{0, -0.5, 0, 0.5, -0.25, 0.5}
})

stairsplus.defs.panel._double_12 = node_box({
	{-0.5, -0.5, -0.5, 0, 0.25, 0},
	{0, -0.5, 0, 0.5, 0.25, 0.5}
})

stairsplus.defs.panel._double_14 = node_box({
	{-0.5, -0.5, -0.5, 0, 0.375, 0},
	{0, -0.5, 0, 0.5, 0.375, 0.5}
})

stairsplus.defs.panel._double_15 = node_box({
	{-0.5, -0.5, -0.5, 0, 0.4375, 0},
	{0, -0.5, 0, 0.5, 0.4375, 0.5}
})

stairsplus.defs.panel._double_16 = node_box({
	{-0.5, -0.5, -0.5, 0, 0.5, 0},
	{0, -0.5, 0, 0.5, 0.5, 0.5}
})

stairsplus.defs.panel["_16"] = node_box({-0.5, -0.5, 0, 0.5, 0.5, 0.5})

stairsplus.defs.panel._pillar = node_box({
	pixel_box(2, 0, 5, 14, 16, 11),
	pixel_box(3, 0, 3, 13, 16, 13),
	pixel_box(5, 0, 2, 11, 16, 14)
})

stairsplus.defs.panel._pcend = node_box({
	pixel_box(2, 0, 5, 14, 16, 11),
	pixel_box(3, 0, 3, 13, 16, 13),
	pixel_box(5, 0, 2, 11, 16, 14),
	pixel_box(0, 0, 0, 16, 3, 16),
	pixel_box(1, 3, 1, 15, 5, 15),
	pixel_box(2, 5, 2, 14, 7, 14),
})


-- Slabs boxes
stairsplus.defs.slab._two_sides_half = {
	{-0.5, -0.5, -0.5, 0, -7/16, 7/16},
	{-0.5, -0.5, 7/16, 0, 0.5, 0.5}
}

stairsplus.defs.slab._two_sides_half_2 = {
	{-0.5, -0.5, -0.5, 0, -0.375, 0.375},
	{-0.5, -0.5, 0.375, 0, 0.5, 0.5}
}

stairsplus.defs.slab._two_sides_half_3 = {
	{-0.5, -0.5, -0.5, 0, -0.25, 0.25},
	{-0.5, -0.5, 0.25, 0, 0.5, 0.5}
}

stairsplus.defs.slab._two_sides_half_4 = {
	{ -0.5, -0.5, -0.5, 0.5, -7/16, 7/16 },
	{ -0.5, -0.5, 7/16, 0.5, 0, 0.5 }
}

stairsplus.defs.slab._two_sides_half_5 = {
	{ -0.5, -0.5, -0.5, 0.5, -0.375, 0.375 },
	{ -0.5, -0.5, 0.375, 0.5, 0, 0.5 }
}

stairsplus.defs.slab._two_sides_half_6 = {
	{ -0.5, -0.5, -0.5, 0.5, -0.25, 0.25 },
	{ -0.5, -0.5, 0.25, 0.5, 0, 0.5 }
}

stairsplus.defs.slab._three_sides_half = {
	{ -7/16, -0.5, -0.5, 0.5, -7/16, 7/16 },
	{ -7/16, -0.5, 7/16, 0.5, 0, 0.5 },
	{ -0.5, -0.5, -0.5, -7/16, 0, 0.5 }
}

stairsplus.defs.slab._three_sides_half_2 = {
	{ -0.375, -0.5, -0.5, 0.5, -0.375, 0.375 },
	{ -0.375, -0.5, 0.375, 0.5, 0, 0.5 },
	{ -0.5, -0.5, -0.5, -0.375, 0, 0.5 }
}

stairsplus.defs.slab._three_sides_half_3 = {
	{ -0.25, -0.5, -0.5, 0.5, -0.25, 0.25 },
	{ -0.25, -0.5, 0.25, 0.5, 0, 0.5 },
	{ -0.5, -0.5, -0.5, -0.25, 0, 0.5 }
}

stairsplus.defs.slab._four_sides = {
	{ -0.5, -0.5, -0.5, 0.5, 0.5, -7/16 },
	{ -0.5, -0.5, -7/16, 0.5, -7/16, 7/16 },
	{ -0.5, -0.5, 7/16, 0.5, 0.5, 0.5 },
	{ -0.5, -7/16, -7/16, -7/16, 0.5, 7/16 },
}

stairsplus.defs.slab._hole = {
	{-0.5, -0.5, -0.5, 0.5, 0.5, -7/16},
	{-0.5, -0.5, 0.5, 0.5, 0.5, 7/16},
	{-0.5, -0.5, -7/16, -7/16, 0.5, 7/16},
	{0.5, -0.5, -7/16, 7/16, 0.5, 7/16},
}

stairsplus.defs.slab._two_opposite = {
	{-0.5, -0.5, -0.5, 0.5, 0.5, -7/16},
	{-0.5, -0.5, 0.5, 0.5, 0.5, 7/16},
}

stairsplus.defs.slab._pit = {
	{ -0.5, -0.5, -0.5, 0.5, 0.5, -7/16 },
	{ -0.5, -0.5, -7/16, 0.5, -7/16, 7/16 },
	{ -0.5, -0.5, 7/16, 0.5, 0.5, 0.5 },
	{ -0.5, -7/16, -7/16, -7/16, 0.5, 7/16 },
	{ -7/16, 0.5, -7/16, 0.5, 7/16, 7/16 },
}
stairsplus.defs.slab._pit_half = {
	{ -0.5, -0.5, -0.5, 0.0, 0.5, -7/16 },
	{ -0.5, -0.5, -7/16, 0.0, -7/16, 7/16 },
	{ -0.5, -0.5, 7/16, 0.0, 0.5, 0.5 },
	{ -0.5, -7/16, -7/16, -7/16, 0.5, 7/16 },
	{ -7/16, 0.5, -7/16, 0.0, 7/16, 7/16 },
}

stairsplus.defs.slab._hole_half = {
	{-0.5, -0.5, -0.5,  0.5,   0, -7/16},
	{-0.5, -0.5, 0.5,   0.5,   0, 7/16},
	{-0.5, -0.5, -7/16, -7/16, 0, 7/16},
	{0.5, -0.5, -7/16,  7/16,  0, 7/16},
}

stairsplus.defs.slab._two_sides_2 = {
	{ -0.5, -0.5, -0.5, 0.5, -0.375, 0.375 },
	{ -0.5, -0.5, 0.375, 0.5, 0.5, 0.5 }
}

stairsplus.defs.slab._two_sides_3 = {
	{ -0.5, -0.5, -0.5, 0.5, -0.25, 0.25 },
	{ -0.5, -0.5, 0.25, 0.5, 0.5, 0.5 }
}

stairsplus.defs.slab._three_sides_2 = {
	{ -0.375, -0.5, -0.5, 0.5, -0.375, 0.375 },
	{ -0.375, -0.5, 0.375, 0.5, 0.5, 0.5 },
	{ -0.5, -0.5, -0.5, -0.375, 0.5, 0.5 }
}

stairsplus.defs.slab._three_sides_3 = {
	{ -0.25, -0.5, -0.5, 0.5, -0.25, 0.25 },
	{ -0.25, -0.5, 0.25, 0.5, 0.5, 0.5 },
	{ -0.5, -0.5, -0.5, -0.25, 0.5, 0.5 }
}


-- Slopes boxes
stairsplus.defs.slope._half_lh = mesh_def("moreblocks_slope_half_lh.obj", {
	{-0.5, -0.5,   -0.5,  0, -0.375, 0.5},
	{-0.5, -0.375, -0.25, 0, -0.25,  0.5},
	{-0.5, -0.25,  0,    0, -0.125, 0.5},
	{-0.5, -0.125, 0.25, 0,  0,     0.5},
})

stairsplus.defs.slope._half_rh = mesh_def("moreblocks_slope_half_rh.obj", {
	{0, -0.5,   -0.5,  0.5, -0.375, 0.5},
	{0, -0.375, -0.25, 0.5, -0.25,  0.5},
	{0, -0.25,  0,    0.5, -0.125, 0.5},
	{0, -0.125, 0.25, 0.5,  0,     0.5},
})

stairsplus.defs.slope._half_raised_lh = mesh_def("moreblocks_slope_half_raised_lh.obj", {
	{-0.5, -0.5,   -0.5,  0, 0.125, 0.5},
	{-0.5, 0.125, -0.25, 0, 0.25,  0.5},
	{-0.5, 0.25,  0,    0, 0.375, 0.5},
	{-0.5, 0.375, 0.25, 0,  0.5,     0.5},
})

stairsplus.defs.slope._half_raised_rh = mesh_def("moreblocks_slope_half_raised_rh.obj", {
	{0, -0.5,   -0.5,  0.5, 0.125, 0.5},
	{0, 0.125, -0.25, 0.5, 0.25,  0.5},
	{0, 0.25,  0,    0.5, 0.375, 0.5},
	{0, 0.375, 0.25, 0.5,  0.5,     0.5},
})

stairsplus.defs.slope._astair_1 = mesh_def("moreblocks_astair_1.obj", {
	{-0.5, -0.5, -0.5, -0.25, 0, 0.5},
	{-0.25, -0.5, -0.25, 0, 0, 0.5},
	{0, -0.5, 0, 0.25, 0, 0.5},
	{0.25, -0.5, 0.25, 0.5, 0, 0.5},
	{-0.5, 0, 0, -0.25, 0.5, 0.5},
	{-0.25, 0, 0.25, 0, 0.5, 0.5}
})

stairsplus.defs.slope._astair_2 = mesh_def("moreblocks_astair_2.obj", {
	{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
	{-0.5, 0, -0.5, -0.25, 0.5, 0.5},
	{-0.25, 0, -0.25, 0, 0.5, 0.5},
	{0, 0, 0, 0.25, 0.5, 0.5},
	{0.25, 0, 0.25, 0.5, 0.5, 0.5},
})

stairsplus.defs.slope._astair_3 = mesh_def("moreblocks_astair_3.obj", {
	{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
	{-0.5, 0, 0, -0.25, 0.5, 0.5},
	{-0.25, 0, 0.25, 0, 0.5, 0.5}
})

stairsplus.defs.slope._astair_4 = mesh_def("moreblocks_astair_4.obj", {
	{-0.5, -0.5, -0.5, 0, 0, 0.5},
	{0, -0.5, -0.25, 0.25, 0, 0.5},
	{0.25, -0.5, 0, 0.5, 0, 0.5},
	{-0.5, 0, 0, -0.25, 0.5, 0.5},
	{-0.25, 0, 0.25, 0, 0.5, 0.5}
})

stairsplus.defs.slope._inner_cut2 = mesh_def("moreblocks_slope_inner_cut2.obj", {
	{-0.5,  -0.5,  -0.5, 0.5,   0, 0.5},
	{-0.5,  0,  -0.5, 0.25,   0.25,  0.5},
	{-0.5, 0.25, -0.5, 0, 0.5, 0.5},
	{0.25, 0, -0.25, 0.5, 0.25, 0.5},
	{0, 0.25, 0, 0.5, 0.5, 0.5}
})

stairsplus.defs.slope._inner_cut3 = mesh_def("moreblocks_slope_inner_cut3.obj", {
	{-0.5,  -0.5,  -0.5, 0.5,   0, 0.5},
	{-0.5, 0, -0.5, 0, 0.5, 0.5},
	{0, 0, 0, 0.5, 0.5, 0.5}
})

stairsplus.defs.slope._inner_cut4 = mesh_def("moreblocks_slope_inner_cut4.obj", {
	{-0.5, -0.5, -0.5, 0, 0, 0.5},
	{0, -0.5, 0, 0.5, 0, 0.5},
	{-0.5, 0, -0.5, -0.25, 0.5, 0.5},
	{-0.25, 0, 0.25, 0.5, 0.5, 0.5}
})

stairsplus.defs.slope._inner_cut5 = mesh_def("moreblocks_slope_inner_cut5.obj", {
	{-0.5, -0.5, -0.5, 0, 0, 0.5},
	{0, -0.5, 0, 0.5, 0, 0.5},
	{-0.5, 0, -0.5, -0.25, 0.5, 0.5},
	{-0.25, 0, 0.25, 0.5, 0.5, 0.5}
})

stairsplus.defs.slope._inner_cut6 = mesh_def("moreblocks_slope_inner_cut6.obj", {
	{-0.5,  -0.5,  -0.5, 0.5,   0, 0.5},
	{-0.5,  0,  -0.5, 0.25,   0.25,  0.5},
	{-0.5, 0.25, -0.5, 0, 0.5, 0.5},
	{0.25, 0, -0.25, 0.5, 0.25, 0.5},
	{0, 0.25, 0, 0.5, 0.5, 0.5}
})

stairsplus.defs.slope._inner_cut7 = mesh_def("moreblocks_slope_inner_cut7.obj", {
	{-0.5,  -0.5,  -0.5, 0.5,   0, 0.5},
	{-0.5, 0, -0.5, 0, 0.5, 0.5},
	{0, 0, 0, 0.5, 0.5, 0.5}
})

stairsplus.defs.slope._inner_cut8 = mesh_def("moreblocks_slope_inner_cut8.obj", {
	{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
	{-0.5, 0, -0.5, 0, 0.5, 0.5},
	{-0.5, 0, 0, 0.5, 0.5, 0.5},
	{0, 0, -0.25, 0.25, 0.5, 0}
})

stairsplus.defs.slope._cut2 = mesh_def("moreblocks_xslopes_cut.obj", {
	{-0.5,     -0.5,     0, 0.5,  0.25, 0.5},
	{-0.5,  0.25,  0.25, 0.5,   0.5, 0.5}
})

stairsplus.defs.slope._lh = mesh_def("moreblocks_slope_lh.obj", {
	{-0.5,  -0.5,  -0.5, 0, -0.25, 0.5},
	{-0.5, -0.25, -0.25, 0,     0, 0.5},
	{-0.5,     0,     0, 0,  0.25, 0.5},
	{-0.5,  0.25,  0.25, 0,   0.5, 0.5}
})

stairsplus.defs.slope._rh = mesh_def("moreblocks_slope_rh.obj", {
	{0,  -0.5,  -0.5, 0.5, -0.25, 0.5},
	{0, -0.25, -0.25, 0.5,     0, 0.5},
	{0,     0,     0, 0.5,  0.25, 0.5},
	{0,  0.25,  0.25, 0.5,   0.5, 0.5}
})

stairsplus.defs.slope._peak_half_lh = mesh_def("moreblocks_xslopes_peak_half_lh.obj", {
	{-0.5,  -0.5,  -0.5, 0, -0.25, -0.25},
	{-0.5, -0.5, -0.25, 0,     0, 0},
	{-0.5,  -0.5,     0, 0,  0, 0.25},
	{-0.5,  -0.5,  0.25, 0,   -0.25, 0.5}
})

stairsplus.defs.slope._peak_half = mesh_def("moreblocks_xslopes_peak_half.obj", {
	{-0.5,  -0.5,  -0.5, 0.5, -0.25, -0.25},
	{-0.5, -0.5, -0.25, 0.5,     0, 0},
	{-0.5,  -0.5,     0, 0.5,  0, 0.25},
	{-0.5,  -0.5,  0.25, 0.5,   -0.25, 0.5}
})

stairsplus.defs.slope._peak_lh = mesh_def("moreblocks_xslopes_peak_lh.obj", {
	{-0.5,  -0.5,  -0.5, 0, 0, -0.25},
	{-0.5, -0.5, -0.25, 0,     0.5, 0},
	{-0.5,  -0.5,     0, 0,  0.5, 0.25},
	{-0.5,  -0.5,  0.25, 0,   0, 0.5}
})

stairsplus.defs.slope._peak = mesh_def("moreblocks_xslopes_peak.obj", {
	{-0.5,  -0.5,  -0.5, 0.5, 0, -0.25},
	{-0.5, -0.5, -0.25, 0.5,     0.5, 0},
	{-0.5,  -0.5,     0, 0.5,  0.5, 0.25},
	{-0.5,  -0.5,  0.25, 0.5,   0, 0.5}
})

stairsplus.defs.slope._quarter = mesh_def("moreblocks_xslopes_quarter.obj", {
	{-0.5, -0.5, -0.5, -0.25, -0.25, 0},
	{-0.5, -0.5, 0, 0, 0, 0.5}
})

stairsplus.defs.slope._quarter2 = mesh_def("moreblocks_xslopes_quarter2.obj", {
	{0.25, -0.5, -0.5, 0.5, -0.25, 0},
	{0, -0.5, 0, 0.25, 0, 0.5}
})

stairsplus.defs.slope._slope_lh = mesh_def("moreblocks_xslopes_slope_lh.obj", {
	{-0.5, -0.5, 0, 0, -0.25, 0.5},
	{-0.5, -0.25, 0.25, 0, 0, 0.5}
})

stairsplus.defs.slope._slope_rh = mesh_def("moreblocks_xslopes_slope_rh.obj", {
	{0, -0.5, 0, 0.5, -0.25, 0.5},
	{0, -0.25, 0.25, 0.5, 0, 0.5}
})

stairsplus.defs.slope._slope = mesh_def("moreblocks_xslopes_slope.obj", {
	{-0.5, -0.5, 0, 0.5, -0.25, 0.5},
	{-0.5, -0.25, 0.25, 0.5, 0, 0.5}
})

stairsplus.defs.slope._three_quarter_half = mesh_def("moreblocks_xslopes_three_quarter_half.obj", {
	{-0.5, -0.5, 0, 0.25, 0.25, 0.5},
	{-0.5, 0.25, 0.25, 0.5, 0.5, 0.5},
	{0.25, -0.5, 0.25, 0.5, 0.5, 0.5}
})

stairsplus.defs.slope._three_quarter = mesh_def("moreblocks_xslopes_three_quarter.obj", {
	{-0.5, -0.5, -0.5, 0, 0, -0.25},
	{-0.5, -0.5, -0.25, 0.25, 0.25, 0.25},
	{-0.5, -0.5, 0.25, 0.5, 0.5, 0.5}
})

stairsplus.defs.slope._sloped_slat = mesh_def("moreblocks_sloped_slat.obj", {
	{-0.5, -0.5, -0.15, -0.25, -0.25, 0.15},
	{-0.25, -0.25, -0.15, 0, 0, 0.15},
	{0, 0, -0.15, 0.25, 0.25, 0.15},
	{0.25, 0.25, -0.15, 0.5, 0.5, 0.15}
})

stairsplus.defs.slope._vertical_slat = mesh_def("moreblocks_vertical_inclined_slat.obj", {-0.15, -0.5, -0.15, 0.15, 0.5, 0.15})

stairsplus.defs.slope._vertical_inclined_slat = mesh_def("moreblocks_vertical_slat.obj", {-0.15, -0.5, -0.15, 0.15, 0.9, 0.15})

stairsplus.defs.slope._horizontal_slat = mesh_def("moreblocks_horizontal_slat.obj", {-0.5, -0.5, -0.15, 0.5, -0.2, 0.15})

stairsplus.defs.slope._horizontal_corner_slat = mesh_def("moreblocks_horizontal_corner_slat.obj", {
	{-0.5, -0.5, -0.15, 0.15, -0.2, 0.15},
	{-0.15, -0.5, -0.5, 0.15, -0.2, 0.15}
})

stairsplus.defs.slope._horizontal_folded_slat = mesh_def("moreblocks_horizontal_folded_slat.obj", {-0.5, -0.5, -0.15, 0.5, -0.2, 0.15})

stairsplus.defs.slope._inclined_folded_slat = mesh_def("moreblocks_inclined_folded_slat.obj", {
	{-0.5, -0.5, -0.15, -0.25, -0.25, 0.15},
	{-0.25, -0.25, -0.15, 0, 0, 0.15},
	{0, 0, -0.15, 0.25, 0.25, 0.15},
	{0.25, 0.25, -0.15, 0.5, 0.5, 0.15}
})

stairsplus.defs.slope._inclined_slat_lh = mesh_def("moreblocks_inclined_slat_lh.obj", {
	{-0.15, -0.5, -0.5, 0.15, 0, -0.15},
	{-0.15, -0.25, -0.15, 0.15, 0.25, 0.15},
	{0.15, 0.25, -0.15, 0.5, 0.5, 0.15}
})

stairsplus.defs.slope._inclined_slat_rh = mesh_def("moreblocks_inclined_slat_rh.obj", {
	{-0.15, -0.5, 0.5, 0.15, 0, 0.15},
	{-0.15, -0.25, -0.15, 0.15, 0.25, 0.15},
	{0.15, 0.25, -0.15, 0.5, 0.5, 0.15}
})


-- Stairs boxes
stairsplus.defs.stair._half_1 = node_box({
	{-0.5, -0.5, -0.5, -7/16, 0, 0.5},
	{-0.5, 0, 0, -7/16, 0.5, 0.5},
})

stairsplus.defs.stair._right_half_1 = node_box({
	{7/16, -0.5, -0.5, 0.5, 0, 0.5},
	{7/16, 0, 0, 0.5, 0.5, 0.5},
})

stairsplus.defs.stair._alt_5 = node_box({
	{-0.5, -0.0625, 0.0, 0.5, 0, 0.5},
	{-0.5, 0.4375, 0, 0.5, 0.5, 0.5},
})

stairsplus.defs.stair._alt_6 = node_box({
	{-0.5, -0.0625, -0.5, 0.5, 0, 0.5},
	{-0.5, 0.4375, -0.5, 0.5, 0.5, 0.5},
})


-- Register all missing microblocks nodes of the materials for which the microblocks were already registered before
--minetest.debug("registered materials: " .. dump(circular_saw.known_nodes))
for material_name, material_data in pairs(circular_saw.known_nodes) do
	local def = minetest.registered_nodes[material_name]

	stairsplus:register_custom_subset(custom_subset, material_data[1], material_data[2], material_name, def)
end


-- Redefinitions of some globals defined in the original moreblocks mod circular_saw.lua

-- How many microblocks does this shape at the output inventory cost:
-- It may cause slight loss, but no gain.
circular_saw.cost_in_microblocks = {
	1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 2, 2, 4, 4, 2, 4,
	3, 2, 4, 4, 4, 4, 8, 8,
	4, 4, 8, 1, 1, 2, 4, 5,
	5, 5, 1, 1, 2, 1, 2, 2,
	1, 2, 3, 1, 2, 2, 3, 3,
	4, 2, 2, 2, 2, 2, 2, 2,
	4, 4, 1, 1, 2, 2, 3, 2,
	2, 4, 4, 2, 2, 2, 4, 4,
	6, 4, 6, 4, 4, 4, 3, 5,
	6, 6, 6, 4, 3, 6, 6, 6,
	2, 6, 4, 2, 4, 2, 1, 2,
	3, 4, 4, 4, 1, 3, 2, 4,
	1, 1, 1, 1, 2, 5, 6, 2,
	2, 2, 2, 2, 2, 2, 2, 2
}

circular_saw.names = {
	{"micro", "_1"},
	{"panel", "_double_1"},
	{"panel", "_1"},
	{"micro", "_2"},
	{"panel", "_double_2"},
	{"panel", "_2"},
	{"micro", "_4"},
	{"panel", "_double_4"},
	{"panel", "_4"},
	{"micro", ""},
	{"panel", ""},

	{"micro", "_12"},
	{"panel", "_double_12"},
	{"panel", "_12"},
	{"micro", "_14"},
	{"panel", "_double_14"},
	{"panel", "_14"},
	{"micro", "_15"},
	{"panel", "_double_15"},
	{"panel", "_15"},
	{"panel", "_double_16"},
	{"panel", "_16"},
	{"panel", "_pillar"},
	{"panel", "_pcend"},
	{"stair", "_outer"},
	{"stair", ""},

	{"stair", "_inner"},
	{"slab", "_1"},
	{"slab", "_2"},
	{"slab", "_quarter"},
	{"slab", ""},
	{"slab", "_three_quarter"},
	{"slab", "_14"},
	{"slab", "_15"},

	{"slab", "_two_sides_half"},
	{"slab", "_two_sides_half_2"},
	{"slab", "_two_sides_half_3"},
	{"slab", "_two_sides_half_4"},
	{"slab", "_two_sides_half_5"},
	{"slab", "_two_sides_half_6"},
	{"slab", "_two_sides"},
	{"slab", "_two_sides_2"},
	{"slab", "_two_sides_3"},
	{"slab", "_three_sides_half"},
	{"slab", "_three_sides_half_2"},
	{"slab", "_three_sides_half_3"},
	{"slab", "_three_sides"},
	{"slab", "_three_sides_2"},
	{"slab", "_three_sides_3"},
	{"slab", "_three_sides_u"},
	{"slab", "_four_sides"},
	{"slab", "_hole"},
	{"slab", "_two_opposite"},
	{"slab", "_pit"},
	{"slab", "_pit_half"},
	{"slab", "_hole_half"},
	{"stair", "_half"},
	{"stair", "_right_half"},
	{"stair", "_half_1"},
	{"stair", "_right_half_1"},
	{"stair", "_alt_1"},
	{"stair", "_alt_2"},
	{"stair", "_alt_4"},
	{"stair", "_alt_5"},
	{"stair", "_alt_6"},
	{"stair", "_alt"},

	{"slope", ""},
	{"slope", "_half"},
	{"slope", "_half_lh"},
	{"slope", "_half_rh"},
	{"slope", "_half_raised_lh"},
	{"slope", "_half_raised_rh"},
	{"slope", "_half_raised"},
	{"slope", "_astair_1"},
	{"slope", "_astair_2"},
	{"slope", "_astair_3"},
	{"slope", "_astair_4"},
	{"slope", "_inner"},
	{"slope", "_inner_half"},
	{"slope", "_inner_half_raised"},
	{"slope", "_inner_cut"},
	{"slope", "_inner_cut2"},
	{"slope", "_inner_cut3"},
	{"slope", "_inner_cut4"},
	{"slope", "_inner_cut5"},
	{"slope", "_inner_cut6"},
	{"slope", "_inner_cut7"},
	{"slope", "_inner_cut8"},
	{"slope", "_inner_cut_half"},

	{"slope", "_inner_cut_half_raised"},
	{"slope", "_outer"},
	{"slope", "_outer_half"},
	{"slope", "_outer_half_raised"},
	{"slope", "_outer_cut"},
	{"slope", "_outer_cut_half"},
	{"slope", "_outer_cut_half_raised"},
	{"slope", "_cut"},
	{"slope", "_cut2"},
	{"slope", "_lh"},
	{"slope", "_rh"},
	{"slope", "_peak_half_lh"},
	{"slope", "_peak_half"},
	{"slope", "_peak_lh"},
	{"slope", "_peak"},
	{"slope", "_quarter"},
	{"slope", "_quarter2"},
	{"slope", "_slope_lh"},
	{"slope", "_slope_rh"},
	{"slope", "_slope"},
	{"slope", "_three_quarter_half"},
	{"slope", "_three_quarter"},
	{"slope", "_sloped_slat"},
	{"slope", "_vertical_slat"},
	{"slope", "_vertical_inclined_slat"},
	{"slope", "_horizontal_slat"},
	{"slope", "_horizontal_corner_slat"},
	{"slope", "_horizontal_folded_slat"},
	{"slope", "_inclined_folded_slat"},
	{"slope", "_inclined_slat_lh"},
	{"slope", "_inclined_slat_rh"}
}

function circular_saw.on_construct(pos)
	local meta = minetest.get_meta(pos)
	local fancy_inv = ""
	if has_default_mod then
		-- prepend background and slot styles from default if available
		fancy_inv = default.gui_bg..default.gui_bg_img..default.gui_slots
	end

	local scroll_factor = 0.1
	local scrl_cont_height = 7
	local output_list_height = math.ceil(#circular_saw.names / 8)

	local area_height = math.max(scrl_cont_height, output_list_height+0.2*(output_list_height))
	local max = area_height - scrl_cont_height
	local thumb_size = (scrl_cont_height / area_height) * max


	meta:set_string(
		--FIXME Not work with @n in this part bug in minetest/minetest#7450.
		"formspec", "size[11,10]"..fancy_inv..
		"label[0,0;" ..S("Input material").. "]" ..
		"list[current_name;input;1.7,0;1,1;]" ..
		"label[0,1;" ..F(S("Left-over")).. "]" ..
		"list[current_name;micro;1.7,1;1,1;]" ..
		"label[0,2;" ..F(S("Recycle output")).. "]" ..
		"list[current_name;recycle;1.7,2;1,1;]" ..
		"field[0.3,3.5;1,1;max_offered;" ..F(S("Max")).. ":;${max_offered}]" ..
		"button[1,3.2;1.7,1;Set;" ..F(S("Set")).. "]" ..
		("scrollbaroptions[min=0;max=%f;thumbsize=%f]"):format(max / scroll_factor, thumb_size / scroll_factor) ..
		"scrollbar[10.8,0;0.2,6;vertical;output_scrlbar;]" ..
		"scroll_container[3.7,0;10.2," .. scrl_cont_height .. ";output_scrlbar;vertical;0.1]" ..
			"list[current_name;output;0,0;8," .. output_list_height .. ";]" ..
		"scroll_container_end[]" ..
		"list[current_player;main;1.5,6.25;8,4;]" ..
		"listring[current_name;output]" ..
		"listring[current_player;main]" ..
		"listring[current_name;input]" ..
		"listring[current_player;main]" ..
		"listring[current_name;micro]" ..
		"listring[current_player;main]" ..
		"listring[current_name;recycle]" ..
		"listring[current_player;main]"
	)

	meta:set_int("anz", 0) -- No microblocks inside yet.
	meta:set_string("max_offered", 99) -- How many items of this kind are offered by default?
	meta:set_string("infotext", S("Circular Saw is empty"))

	local inv = meta:get_inventory()
	inv:set_size("input", 1)    -- Input slot for full blocks of material x.
	inv:set_size("micro", 1)    -- Storage for 1-7 surplus microblocks.
	inv:set_size("recycle", 1)  -- Surplus partial blocks can be placed here.
	inv:set_size("output", 8 * output_list_height) -- 6x8 versions of stair-parts of material x.

	circular_saw:reset(pos)
end

minetest.override_item("moreblocks:circular_saw", {
	on_construct = circular_saw.on_construct
})
