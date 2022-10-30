local S = minetest.get_translator("streets")
local eumandat = {
	{ "rightonly", S("C 2b Přikázaný směr jízdy vpravo"), { blue = 2, white = 1 } },
	{ "rightonly_", S("C 3a Přikázaný směr jízdy zde vpravo"), { blue = 2, white = 1 } },
	{ "leftonly", S("C 2c Přikázaný směr jízdy vlevo"), { blue = 2, white = 1 } },
	{ "leftonly_", S("C 3b Přikázaný směr jízdy zde vlevo"), { blue = 2, white = 1 } },
	{ "straightonly", S("C 2a Přikázaný směr jízdy přímo"), { blue = 2, white = 1 } },
	{ "straightrightonly", S("C 2d Přikázaný směr jízdy přímo a vpravo"), { blue = 2, white = 1 } },
	{ "straightleftonly", S("C 2e Přikázaný směr jízdy přímo a vlevo"), { blue = 2, white = 1 } },
	{ "roundabout", S("C 1 Kruhový objezd"), { blue = 2, white = 1 } },
	{ "passingright", S("C 4a Přikázaný směr objíždění vpravo"), { blue = 2, white = 1 } },
	{ "passingleft", S("C 4b Přikázaný směr objíždění vlevo"), { blue = 2, white = 1 } },
	-- { "busstation", "Busstation", { green = 2, yellow = 2 } },
	{ "cyclepath", S("C 8a Stezka pro cyklisty"), { blue = 2, white = 1 } },
	{ "bridlepath", S("C 11a Stezka pro jezdce na zvířeti"), { blue = 2, white = 1 } },
	{ "walkway", S("C 7a Stezka pro chodce"), { blue = 2, white = 1 } },
	{ "sharedpedestriansbicyclists", S("C 9a Stezka pro chodce a cyklisty společná"), { blue = 2, white = 1 } },
	{ "seperatedpedestriansbicyclists", S("C 10a Stezka pro chodce a cyklisty dělená"), { blue = 2, white = 1 } },
	{ "pedestrianszone", S("IZ 6a Pěší zóna"), { blue = 2, white = 2, black = 1 } },
	{ "pedestrianszoneend", S("IZ 6b Konec pěší zóny"), { grey = 2, white = 2, black = 1 } },
}

for k, v in pairs(eumandat) do
	streets.register_road_sign({
		name = "sign_eu_" .. v[1],
		friendlyname = S("dopravní značka: @1", v[2]),
		light_source = 3,
		tiles = {
			"streets_sign_eu_" .. v[1] .. ".png",
			"streets_sign_back.png",
		},
		type = "normal",
		section = "eumandat",
		dye_needed = v[3]
	})
end


local eumandat_big = {
	{ "onewayright", S("IP 4a Jednosměrný provoz (vpravo)"), { blue = 2, white = 1, black = 1 } },
	{ "onewayleft", S("IP 4a Jednosměrný provoz (vlevo)"), { blue = 2, white = 1, black = 1 } },
}

for k, v in pairs(eumandat_big) do
	streets.register_road_sign({
		name = "sign_eu_" .. v[1],
		friendlyname = S("dopravní značka: @1", v[2]),
		light_source = 3,
		tiles = {
			"streets_sign_eu_" .. v[1] .. ".png",
			"streets_sign_back.png",
		},
		type = "big",
		section = "eumandat",
		dye_needed = v[3],
		inventory_image = "streets_sign_eu_" .. v[1] .. "_inv.png",
	})
end
