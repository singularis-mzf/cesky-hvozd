local S = minetest.get_translator("streets")
local euinfo = {
	{ "tunnel", S("IZ 3a Tunel"), { blue = 2, white = 1, black = 1 } },
	{ "breakdownbay", S("IP 9 Nouzové stání"), { blue = 2, white = 1, black = 1 } },
	{ "highway", S("IP 14a Dálnice"), { blue = 2, white = 1 } },
	{ "highwayend", S("IP 14b Konec dálnice"), { blue = 2, white = 1, red = 1 } },
	{ "motorroad", S("IP 15a Silnice pro motorová vozidla"), { blue = 2, white = 1 } },
	{ "motorroadend", S("IP 15b Konec silnice pro motorová vozidla"), { blue = 2, white = 1, red = 1 } },
	{ "pedestriancrossing", S("IP 6 Přechod pro chodce"), { blue = 2, white = 1, black = 1 } },
	{ "deadendstreet", S("IP 10a Slepá pozemní komunikace"), { blue = 2, white = 1, red = 1 } },
	{ "firstaid", S("IJ 3 První pomoc"), { blue = 2, white = 1, red = 1 } },
	{ "info", S("IJ 5 Informace"), { blue = 2, white = 1, black = 1 } },
	{ "wc", S("IJ 12 WC"), { blue = 2, white = 1, black = 1 } },
	{ "parkingsite", S("IP 11a Parkoviště"), { blue = 2, white = 1 } },
}

for k, v in pairs(euinfo) do
	streets.register_road_sign({
		name = "sign_eu_" .. v[1],
		friendlyname = S("dopravní značka: @1", v[2]),
		light_source = 3,
		tiles = {
			"streets_sign_eu_" .. v[1] .. ".png",
			"streets_sign_back.png",
		},
		type = "normal",
		section = "euinfo",
		dye_needed = v[3],
	})
end


local euinfo_big = {
	{ "trafficcalmingarea", S("IP 26a Obytná zóna"), { blue = 3, white = 1 } },
	{ "trafficcalmingareaend", S("IP 26b Konec obytné zóny"), { blue = 3, white = 1, red = 1 } },
	-- { "exit", "Exit", { blue = 2, white = 1 } },
	-- { "detourright", "Detour Right", { yellow = 2, black = 1 } },
	-- { "detourleft", "Detour Left", { yellow = 2, black = 1 } },
	-- { "detour", "Detour", { yellow = 2, black = 1 } },
	-- { "detourend", "End of Detour", { yellow = 2, black = 1, red = 1 } },
}

for k, v in pairs(euinfo_big) do
	streets.register_road_sign({
		name = "sign_eu_" .. v[1],
		friendlyname = S("dopravní značka: @1", v[2]),
		light_source = 3,
		tiles = {
			"streets_sign_eu_" .. v[1] .. ".png",
			"streets_sign_back.png",
		},
		type = "big",
		section = "euinfo",
		dye_needed = v[3],
		inventory_image = "streets_sign_eu_" .. v[1] .. "_inv.png",
	})
end
