--[[
	## StreetsMod 2.0 ##
	Submod: roadmarkings
	Optional: true
	Category: Roads
]]

local S = minetest.get_translator("streets")

--These register the sections in the workshop that these will be placed into
streets.labels.sections = {
	{ name = "centerlines", friendlyname = "Center Lines" },
	{ name = "centerlinecorners", friendlyname = "Center Line Corners/Junctions" },
	{ name = "sidelines", friendlyname = "Side Lines" },
	{ name = "arrows", friendlyname = "Arrows" },
	{ name = "symbols", friendlyname = "Symbols" },
	{ name = "other", friendlyname = "Other" }
}


-- CENTER LINES

-- Normal Lines

streets.register_road_marking({
	name = "dashed_{color}_center_line",
	friendlyname = S("vystředěná čára přerušovaná"),
	tex = "streets_dashed_center_line.png",
	section = "centerlines",
	dye_needed = 1,
	rotation = { r90 = 1 },
	basic = true,
})

streets.register_road_marking({
	name = "solid_{color}_center_line",
	friendlyname = S("vystředěná čára souvislá"),
	tex = "streets_solid_center_line.png",
	section = "centerlines",
	dye_needed = 2,
	rotation = { r90 = 1 },
	basic = true,
})


-- Wide Lines

streets.register_road_marking({
	name = "dashed_{color}_center_line_wide",
	friendlyname = S("vystředěná čára přerušovaná široká"),
	tex = "streets_dashed_center_line_wide.png",
	section = "centerlines",
	dye_needed = 2,
	rotation = { r90 = 1 },
})

streets.register_road_marking({
	name = "solid_{color}_center_line_wide",
	friendlyname = S("vystředěná čára souvislá široká"),
	tex = "streets_solid_center_line_wide.png",
	section = "centerlines",
	dye_needed = 4,
	rotation = { r90 = 1 },
})


-- Double Lines

streets.register_road_marking({
	name = "double_dashed_{color}_center_line",
	friendlyname = S("dvojitá vystředěná čára přerušovaná"),
	tex = "streets_double_dashed_center_line.png",
	section = "centerlines",
	dye_needed = 2,
	rotation = { r90 = 1 },
})

streets.register_road_marking({
	name = "double_solid_{color}_center_line",
	friendlyname = S("dvojitá vystředěná čára souvislá"),
	tex = "streets_double_solid_center_line.png",
	section = "centerlines",
	dye_needed = 4,
	rotation = { r90 = 1 },
	basic = true,
})

streets.register_road_marking({
	name = "mixed_{color}_center_line",
	friendlyname = S("V 3 Podélná čára souvislá doplněná čárou přerušovanou"),
	tex = "streets_mixed_center_line.png",
	section = "centerlines",
	dye_needed = 3,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "solid_{color}_line_offset",
	friendlyname = S("posunutá souvislá čára"),
	tex = "streets_solid_line_offset.png",
	section = "centerlines",
	dye_needed = 2,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})


--CENTER LINE CORNERS

--Normal Lines

streets.register_road_marking({
	name = "solid_{color}_center_line_corner",
	friendlyname = S("souvislá čára: roh"),
	tex = "streets_solid_center_line_corner.png",
	section = "centerlinecorners",
	dye_needed = 2,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "solid_{color}_center_line_tjunction",
	friendlyname = S("křížení souvislých čar ve tvaru T"),
	tex = "streets_solid_center_line_tjunction.png",
	section = "centerlinecorners",
	dye_needed = 3,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "solid_{color}_center_line_crossing",
	friendlyname = S("křížení souvislých čár"),
	tex = "streets_solid_center_line_crossing.png",
	section = "centerlinecorners",
	dye_needed = 4,
})


--[[ Wide Lines

streets.register_road_marking({
	name = "solid_{color}_center_line_wide_corner",
	friendlyname = "Solid Center Line Wide Corner",
	tex = "streets_solid_center_line_wide_corner.png",
	section = "centerlinecorners",
	dye_needed = 4,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "solid_{color}_center_line_wide_tjunction",
	friendlyname = "Solid Center Line Wide T-Junction",
	tex = "streets_solid_center_line_wide_tjunction.png",
	section = "centerlinecorners",
	dye_needed = 6,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "solid_{color}_center_line_wide_crossing",
	friendlyname = "Solid Center Line Wide Crossing",
	tex = "streets_solid_center_line_wide_crossing.png",
	section = "centerlinecorners",
	dye_needed = 8,
})
]]

--[[ Double Lines

streets.register_road_marking({
	name = "double_solid_{color}_center_line_corner",
	friendlyname = "Double Solid Center Line Corner",
	tex = "streets_double_solid_center_line_corner.png",
	section = "centerlinecorners",
	dye_needed = 4,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "double_solid_{color}_center_line_tjunction",
	friendlyname = "Double Solid Center Line T-Junction",
	tex = "streets_double_solid_center_line_tjunction.png",
	section = "centerlinecorners",
	dye_needed = 6,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "double_solid_{color}_center_line_crossing",
	friendlyname = "Double Solid Center Line Crossing",
	tex = "streets_double_solid_center_line_crossing.png",
	section = "centerlinecorners",
	dye_needed = 8,
})
]] 
--SIDE LINES

--Normal Lines

streets.register_road_marking({
	name = "solid_{color}_side_line",
	friendlyname = S("okrajová čára souvislá"),
	tex = "streets_solid_side_line.png",
	section = "sidelines",
	dye_needed = 2,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
	basic = true,
	basic_rotation = { r180 = 1 },
})

streets.register_road_marking({
	name = "solid_{color}_side_line_corner",
	friendlyname = S("okrajová čára souvislá: roh"),
	tex = "streets_solid_side_line_corner.png",
	section = "sidelines",
	dye_needed = 4,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "dashed_{color}_side_line",
	friendlyname = S("okrajová čára přerušovaná"),
	tex = "streets_dashed_side_line.png",
	section = "sidelines",
	dye_needed = 1,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})


--Wide Lines

streets.register_road_marking({
	name = "solid_{color}_side_line_wide",
	friendlyname = S("okrajová čára souvislá široká"),
	tex = "streets_solid_side_line_wide.png",
	section = "sidelines",
	dye_needed = 4,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
	basic = true,
	basic_rotation = { r180 = 1 },
})

streets.register_road_marking({
	name = "solid_{color}_side_line_wide_corner",
	friendlyname = S("okrajová čára souvislá široká: roh"),
	tex = "streets_solid_side_line_wide_corner.png",
	section = "sidelines",
	dye_needed = 8,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

--[[
streets.register_road_marking({
	name = "dashed_{color}_side_line_wide",
	friendlyname = S("okrajová čára přerušovaná široká"),
	tex = "streets_dashed_side_line_wide.png",
	section = "sidelines",
	dye_needed = 2,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})
]]

--Special

--[[
streets.register_road_marking({
	name = "solid_{color}_side_line_combinated_corner",
	friendlyname = S("V 5 Příčná čára souvislá"),
	tex = "streets_solid_side_line_combinated_corner.png",
	section = "sidelines",
	dye_needed = 6,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "solid_{color}_side_line_combinated_corner_flipped",
	friendlyname = S("V 5 Příčná čára souvislá (opačná)"),
	tex = "streets_solid_side_line_combinated_corner.png^[transformFX",
	section = "sidelines",
	dye_needed = 6,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})
]]


--ARROWS

streets.register_road_marking({
	name = "{color}_arrow_straight",
	friendlyname = S("V 9a Směrové šipky: rovně"),
	tex = "streets_arrow_straight.png",
	section = "arrows",
	dye_needed = 2,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "{color}_arrow_left",
	friendlyname = S("V 9a Směrové šipky: vlevo"),
	tex = "streets_arrow_right.png^[transformFX",
	section = "arrows",
	dye_needed = 2,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "{color}_arrow_right",
	friendlyname = S("V 9a Směrové šipky: vpravo"),
	tex = "streets_arrow_right.png",
	section = "arrows",
	dye_needed = 2,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "{color}_arrow_left_straight",
	friendlyname = S("V 9a Směrové šipky: vlevo a rovně"),
	tex = "streets_arrow_right_straight.png^[transformFX",
	section = "arrows",
	dye_needed = 2,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "{color}_arrow_right_straight",
	friendlyname = S("V 9a Směrové šipky: rovně a vpravo"),
	tex = "streets_arrow_right_straight.png",
	section = "arrows",
	dye_needed = 2,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "{color}_arrow_left_right_straight",
	friendlyname = S("V 9a Směrové šipky: vlevo, rovně a vpravo"),
	tex = "streets_arrow_right_straight.png^[transformFX^streets_arrow_right_straight.png",
	section = "arrows",
	dye_needed = 2,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

streets.register_road_marking({
	name = "{color}_arrow_left_right",
	friendlyname = S("V 9a Směrové šipky: vlevo a vpravo"),
	tex = "streets_arrow_left_right.png",
	section = "arrows",
	dye_needed = 2,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})


--SYMBOLS

--[[
streets.register_road_marking({
	name = "{color}_parking",
	friendlyname = "Parking",
	tex = "streets_parking.png",
	section = "symbols",
	dye_needed = 3,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})
]]

streets.register_road_marking({
	name = "{color}_cross",
	friendlyname = S("V 12b Žluté zkřížené čáry"),
	tex = "streets_cross.png",
	section = "symbols",
	dye_needed = 4,
})

--OTHER

streets.register_road_marking({
	name = "solid_{color}_stripe",
	friendlyname = S("barevný pruh"),
	tex = "streets_solid_stripe.png",
	section = "other",
	dye_needed = 4,
	rotation = { r90 = 1 },
})

streets.register_road_marking({
	name = "solid_{color}_diagonal_line",
	friendlyname = S("příčná čára"),
	tex = "streets_solid_diagonal_line.png",
	section = "other",
	dye_needed = 2,
	rotation = { r90 = 1 },
})

streets.register_road_marking({
	name = "double_solid_{color}_diagonal_line",
	friendlyname = S("V 13a Šikmé rovnoběžné čáry"),
	tex = "streets_double_solid_diagonal_line.png",
	section = "other",
	dye_needed = 4,
	rotation = { r90 = 1 },
})

streets.register_road_marking({
	name = "{color}_halt_line_center_corner",
	friendlyname = S("V 5 Příčná čára souvislá"),
	tex = "streets_halt_line_center_corner.png",
	section = "other",
	dye_needed = 4,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})

--[[
streets.register_road_marking({
	name = "{color}_halt_line_center_corner_wide",
	friendlyname = "Halt Line Center Corner Wide",
	tex = "streets_halt_line_center_corner_wide.png",
	section = "other",
	dye_needed = 6,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})
]]

streets.register_road_marking({
	name = "{color}_halt_line_center_corner_flipped",
	friendlyname = S("V 5 Příčná čára souvislá (opačná)"),
	tex = "streets_halt_line_center_corner.png^[transformFX",
	section = "other",
	dye_needed = 4,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})
--[[

streets.register_road_marking({
	name = "{color}_halt_line_center_corner_wide_flipped",
	friendlyname = "Halt Line Center Corner Wide (Flipped)",
	tex = "streets_halt_line_center_corner_wide.png^[transformFX",
	section = "other",
	dye_needed = 6,
	rotation = { r90 = 1, r180 = 1, r270 = 1 },
})
]]
