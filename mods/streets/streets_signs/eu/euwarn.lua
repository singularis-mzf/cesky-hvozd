local S = minetest.get_translator("streets")
local euwarn = {
	{ "danger", S("A 22 Jiné nebezpečí"), { red = 2, white = 2, black = 1 } },
	{ "twowaytraffic", S("A 9 Provoz v obou směrech"), { red = 2, white = 2, black = 1 } },
	{ "trafficlightahead", S("A 10 Světelné signály"), { red = 3, white = 2, yellow = 1, green = 1 } },
	{ "farmanimals", S("A 13 Zvířata"), { red = 2, white = 2, black = 1 } },
	{ "intersectionrightofwayright", S("A 3 Křižovatka"), { red = 2, white = 2, black = 1 } },
	{ "curveleft", S("A 1b Zatáčka vlevo"), { red = 2, white = 2, black = 1 } },
	{ "curveright", S("A 1a Zatáčka vpravo"), { red = 2, white = 2, black = 1 } },
	{ "doublecurveleft", S("A 2b Dvojitá zatáčka, první vlevo"), { red = 2, white = 2, black = 1 } },
	{ "doublecurveright", S("A 2a Dvojitá zatáčka, první vpravo"), { red = 2, white = 2, black = 1 } },
	{ "downhillgrade", S("A 5a Nebezpečné klesání"), { red = 2, white = 2, black = 2 } },
	{ "uphillgrade", S("A 5b Nebezpečné stoupání"), { red = 2, white = 2, black = 2 } },
	{ "bumpyroad", S("A 7a Nerovnost vozovky"), { red = 2, white = 2, black = 1 } },
	{ "slipdanger", S("A 8 Nebezpečí smyku"), { red = 2, white = 2, black = 1 } },
	{ "roadnarrowsboth", S("A 6a Zúžená vozovka (z obou stran)"), { red = 2, white = 2, black = 1 } },
	{ "roadnarrowsleft", S("A 6b Zúžená vozovka (z jedné strany) (vlevo)"), { red = 2, white = 2, black = 1 } },
	{ "roadnarrowsright", S("A 6b Zúžená vozovka (z jedné strany) (vpravo)"), { red = 2, white = 2, black = 1 } },
	{ "roadworks", S("A 15 Práce na silnici"), { red = 2, white = 2, black = 1 } },
	{ "jam", S("A 23 Kolona"), { red = 2, white = 2, black = 1 } },
	{ "pedestrians", S("A 12a Chodci"), { red = 2, white = 2, black = 1 } },
	{ "children", S("A 12b Děti"), { red = 2, white = 2, black = 1 } },
	{ "bikes", S("A 19 Cyklisté"), { red = 2, white = 2, black = 1 } },
	{ "deercrossing", S("A 14 Zvěř"), { red = 2, white = 2, black = 1 } },
	-- { "busses", S(""), { red = 2, white = 2, black = 1 } },
	-- { "railroadcrossing", "Railroad Crossing", { red = 2, white = 2, black = 1 } },
	{ "cross1", S("A 32a Výstražný kříž pro železniční přejezd jednokolejný"), {white = 1, red = 2 }},
	{ "cross2", S("A 32b Výstražný kříž pro železniční přejezd vícekolejný"), {white = 2, red = 3 }},
}

for k, v in pairs(euwarn) do
	streets.register_road_sign({
		name = "sign_eu_" .. v[1],
		friendlyname = S("dopravní značka: @1", v[2]),
		light_source = 3,
		tiles = {
			"streets_sign_eu_" .. v[1] .. ".png",
			"streets_sign_back.png",
		},
		type = "normal",
		section = "euwarn",
		dye_needed = v[3]
	})
end
