local S = minetest.get_translator("streets")
local euprio = {
	{ "yield", S("P 4 Dej přednost v jízdě!"), { white = 2, red = 2 } },
	{ "stop", S("P 6 Stůj, dej přednost v jízdě!"), { white = 1, red = 3 } },
	{ "givewayoncoming", S("P 7 Přednost protijedoucích vozidel"), { white = 2, red = 2, black = 1 } },
	{ "priooveroncoming", S("P 8 Přednost před protijedoucími vozidly"), { white = 1, red = 1, blue = 2 } },
	{ "rightofway", S("P 1 Křižovatka s vedlejší pozemní komunikací"), { white = 2, red = 2, black = 1 } },
	{ "majorroad", S("P 2 Hlavní pozemní komunikace"), { white = 2, yellow = 2 } },
	{ "endmajorroad", S("P 3 Konec hlavní pozemní komunikace"), { white = 2, yellow = 2, black = 1 } },
	{ "greenarrow", S("zelená šipka"), { green = 2, black = 2 } },
}

for k, v in pairs(euprio) do
	streets.register_road_sign({
		name = "sign_eu_" .. v[1],
		friendlyname = S("dopravní značka: @1", v[2]),
		light_source = 3,
		tiles = {
			"streets_sign_eu_" .. v[1] .. ".png",
			"streets_sign_back.png",
		},
		type = "normal",
		section = "euprio",
		dye_needed = v[3]
	})
end

--[[
local euprio_big = {
	{ "standrews", "St. Andrews Cross", { white = 2, red = 1 } },
}

for k, v in pairs(euprio_big) do
	streets.register_road_sign({
		name = "sign_eu_" .. v[1],
		friendlyname = v[2] .. " Sign",
		light_source = 3,
		tiles = {
			"streets_sign_eu_" .. v[1] .. ".png",
			"streets_sign_back.png",
		},
		type = "big",
		section = "euprio",
		dye_needed = v[3],
		inventory_image = "streets_sign_eu_" .. v[1] .. "_inv.png",
	})
end
]]
