local S = minetest.get_translator("streets")
local euother = {
	{ "guideboard_left", S("Z 4b Směrovací deska se šikmými pruhy se sklonem vpravo"), { white = 2, red = 2 } },
	{ "guideboard_right", S("Z 4a Směrovací deska se šikmými pruhy se sklonem vlevo"), { white = 2, red = 2 } },
	{ "bendright", S("Z 3 Vodicí tabule (vpravo)"), { white = 2, red = 2 } },
	{ "bendleft", S("Z 3 Vodicí tabule (vlevo)"), { white = 2, red = 2 } },
	-- { "pedestriansleft", "Pedestrians to the Left", { white = 2, black = 1 } },
	-- { "pedestriansright", "Pedestrians to the Right", { white = 2, black = 1 } },
	{ "arrowright", S("E 7b Směrová šipka pro odbočení (vpravo)"), { white = 2, black = 1 } },
	{ "arrowleft", S("E 7b Směrová šipka pro odbočení (vlevo)"), { white = 2, black = 1 } },
	{ "arrowturnright", S("šipka naznačující odbočení vpravo"), { white = 2, black = 1 } },
	{ "arrowturnleft", S("šipka naznačující odbočení vlevo"), { white = 2, black = 1 } },
	{ "arrowshorizontal", S("šipky oběma směry vodorovně"), { white = 2, black = 1 } },
	{ "arrowsvertical", S("šipky oběma směry svisle"), { white = 2, black = 1 } },
	{ "turningprioroad4", S("E 2b Tvar křižovatky (lze otáčet, varianta 1)"), { white = 2, black = 1 } },
	{ "turningprioroad3-1", S("E 2b Tvar křižovatky (lze otáčet, varianta 2)"), { white = 2, black = 1 } },
	{ "turningprioroad3-2", S("E 2b Tvar křižovatky (lze otáčet, varianta 3)"), { white = 2, black = 1 } },
}

for k, v in pairs(euother) do
	streets.register_road_sign({
		name = "sign_eu_" .. v[1],
		friendlyname = S("dopravní značka: @1", v[2]),
		light_source = 3,
		tiles = {
			"streets_sign_eu_" .. v[1] .. ".png",
			"streets_sign_back.png",
		},
		type = "normal",
		section = "euother",
		dye_needed = v[3]
	})
end


local euother_big = {
	-- { "additionallane", "Additional Lane", { white = 3, black = 1 } },
	-- { "mergelanes", "Merge Lanes", { white = 3, black = 1 } },
	{ "laneshift", S("IS 10a Návěst změny směru jízdy (varianta 1)"), { white = 3, black = 1 } },
	{ "transfertoothercarriageway1", S("IS 10a Návěst změny směru jízdy (varianta 2)"), { white = 3, black = 1 } },
	{ "transfertoothercarriageway2", S("IS 10a Návěst změny směru jízdy (varianta 3)"), { white = 3, black = 1 } },
}

for k, v in pairs(euother_big) do
	streets.register_road_sign({
		name = "sign_eu_" .. v[1],
		friendlyname = S("dopravní značka: @1", v[2]),
		light_source = 3,
		tiles = {
			"streets_sign_eu_" .. v[1] .. ".png",
			"streets_sign_back.png",
		},
		type = "big",
		section = "euother",
		dye_needed = v[3],
		inventory_image = "streets_sign_eu_" .. v[1] .. "_inv.png",
	})
end

minetest.register_alias("streets:sign_eu_guideboard", "streets:sign_eu_guideboard_right")
minetest.register_alias("streets:sign_eu_guideboard_center", "streets:sign_eu_guideboard_right_center")
minetest.register_alias("streets:sign_eu_guideboard_polemount", "streets:sign_eu_guideboard_right_polemount")
