local S = minetest.get_translator("streets")
local euprohib = {
	{ "novehicles", S("B 1 Zákaz vjezdu všech vozidel (v obou směrech)"), { red = 2, white = 2 } },
	{ "nomotorcars", S("B 3a Zákaz vjezdu všech motorových vozidel s výjimkou motocyklů bez postranního vozíku"), { red = 2, white = 1, black = 1 } },
	{ "notrucks", S("B 4 Zákaz vjezdu nákladních automobilů"), { red = 2, white = 1, black = 1 } },
	{ "nobikes", S("B 8 Zákaz vjezdu jízdních kol"), { red = 2, white = 1, black = 1 } },
	{ "nopedestrians", S("B 30 Zákaz vstupu chodců"), { red = 2, white = 1, black = 1 } },
	{ "nohorsebackriding", S("B 31 Zákaz vjezdu pro jezdce na zvířeti"), { red = 2, white = 1, black = 1 } },
	{ "nomotorvehicles", S("B 11 Zákaz vjezdu všech motorových vozidel"), { red = 2, white = 1, black = 1 } },
	{ "noentry", S("B 2 Zákaz vjezdu všech vozidel"), { red = 3, white = 1 } },
	{ "nouturns", S("B 25 Zákaz otáčení"), { red = 2, white = 1, black = 1 } },
	{ "30zone", S("IZ 8a Zóna s dopravním omezením (30 km/h)"), { red = 2, white = 1, black = 1 } },
	{ "30zoneend", S("IZ 8b Konec zóny s dopravním omezením (30 km/h)"), { grey = 2, white = 1, black = 1 } },
	{ "noovertaking", S("B 21a Zákaz předjíždění"), { red = 2, white = 1, black = 1 } },
	{ "endnoovertaking", S("B 21b Konec zákazu předjíždění"), { grey = 2, white = 1, black = 1 } },
	{ "end", S("B 26 Konec všech zákazů"), { white = 2, black = 1 } },
	{ "noparking", S("B 29 Zákaz stání"), { red = 2, blue = 2 } },
	{ "nostopping", S("B 28 Zákaz zastavení"), { red = 2, blue = 2 } },
	{ "10", S("B 20a Nejvyšší dovolená rychlost (10 km/h)"), { red = 2, white = 1, black = 1 } },
	{ "30", S("B 20a Nejvyšší dovolená rychlost (30 km/h)"), { red = 2, white = 1, black = 1 } },
	{ "50", S("B 20a Nejvyšší dovolená rychlost (50 km/h)"), { red = 2, white = 1, black = 1 } },
	{ "70", S("B 20a Nejvyšší dovolená rychlost (70 km/h)"), { red = 2, white = 1, black = 1 } },
	{ "100", S("B 20a Nejvyšší dovolená rychlost (100 km/h)"), { red = 2, white = 1, black = 1 } },
	{ "120", S("B 20a Nejvyšší dovolená rychlost (120 km/h)"), { red = 2, white = 1, black = 1 } },
}

for k, v in pairs(euprohib) do
	streets.register_road_sign({
		name = "sign_eu_" .. v[1],
		friendlyname = S("dopravní značka: @1", v[2]),
		light_source = 3,
		tiles = {
			"streets_sign_eu_" .. v[1] .. ".png",
			"streets_sign_back.png",
		},
		type = "normal",
		section = "euprohib",
		dye_needed = v[3]
	})
end
