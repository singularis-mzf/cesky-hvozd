--[[
	## StreetsMod 2.0 ##
	Submod: signs
	Optional: true
]]

local S = minetest.get_translator("streets")

--These register the sections in the workshop that these will be placed into
streets.signs.sections = {
	{ name = "warn", friendlyname = "MT Warning" },
	{ name = "reg", friendlyname = "MT Regulatory" },
	{ name = "info", friendlyname = "MT Information" },
	{ name = "euprio", friendlyname = "EU Priority" },
	{ name = "euwarn", friendlyname = "EU Warning" },
	{ name = "euprohib", friendlyname = "EU Prohibitory" },
	{ name = "eumandat", friendlyname = "EU Mandatory" },
	{ name = "euinfo", friendlyname = "EU Info" },
	{ name = "euother", friendlyname = "EU Other" }
}

minetest.register_alias("streets:sign_blank", "default:sign_wall_steel")

local all_signs = {
	-- EU Info
	{ "euinfo", "sign_eu_tunnel", S("IZ 3a Tunel"), { blue = 2, white = 1, black = 1 } },
	{ "euinfo", "sign_eu_breakdownbay", S("IP 9 Nouzové stání"), { blue = 2, white = 1, black = 1 }, "small" },
	{ "euinfo", "sign_eu_highway", S("IP 14a Dálnice"), { blue = 2, white = 1 }, "larger" },
	{ "euinfo", "sign_eu_highwayend", S("IP 14b Konec dálnice"), { blue = 2, white = 1, red = 1 }, "larger" },
	{ "euinfo", "sign_eu_motorroad", S("IP 15a Silnice pro motorová vozidla"), { blue = 2, white = 1 }, "larger" },
	{ "euinfo", "sign_eu_motorroadend", S("IP 15b Konec silnice pro motorová vozidla"), { blue = 2, white = 1, red = 1 }, "larger" },
	{ "euinfo", "sign_eu_pedestriancrossing", S("IP 6 Přechod pro chodce"), { blue = 2, white = 1, black = 1 }, "small" },
	{ "euinfo", "sign_eu_deadendstreet", S("IP 10a Slepá pozemní komunikace"), { blue = 2, white = 1, red = 1 }, "small" },
	{ "euinfo", "sign_eu_firstaid", S("IJ 3 První pomoc"), { blue = 2, white = 1, red = 1 } },
	{ "euinfo", "sign_eu_info", S("IJ 5 Informace"), { blue = 2, white = 1, black = 1 } },
	{ "euinfo", "sign_eu_wc", S("IJ 12 WC"), { blue = 2, white = 1, black = 1 } },
	{ "euinfo", "sign_eu_parkingsite", S("IP 11a Parkoviště"), { blue = 2, white = 1 } },
	{ "euinfo", "sign_eu_trafficcalmingarea", S("IP 26a Obytná zóna"), { blue = 3, white = 1 }, "big" },
	{ "euinfo", "sign_eu_trafficcalmingareaend", S("IP 26b Konec obytné zóny"), { blue = 3, white = 1, red = 1 }, "big" },
	-- { "euinfo", "sign_eu_exit", "Exit", { blue = 2, white = 1 }, "big" },
	-- { "euinfo", "sign_eu_detourright", "Detour Right", { yellow = 2, black = 1 }, "big" },
	-- { "euinfo", "sign_eu_detourleft", "Detour Left", { yellow = 2, black = 1 }, "big" },
	-- { "euinfo", "sign_eu_detour", "Detour", { yellow = 2, black = 1 }, "big" },
	-- { "euinfo", "sign_eu_detourend", "End of Detour", { yellow = 2, black = 1, red = 1 }, "big" },

	-- EU Mandatory
	{ "eumandat", "sign_eu_rightonly", S("C 2b Přikázaný směr jízdy vpravo"), { blue = 2, white = 1 } },
	{ "eumandat", "sign_eu_rightonly_", S("C 3a Přikázaný směr jízdy zde vpravo"), { blue = 2, white = 1 } },
	{ "eumandat", "sign_eu_leftonly", S("C 2c Přikázaný směr jízdy vlevo"), { blue = 2, white = 1 } },
	{ "eumandat", "sign_eu_leftonly_", S("C 3b Přikázaný směr jízdy zde vlevo"), { blue = 2, white = 1 } },
	{ "eumandat", "sign_eu_straightonly", S("C 2a Přikázaný směr jízdy přímo"), { blue = 2, white = 1 } },
	{ "eumandat", "sign_eu_straightrightonly", S("C 2d Přikázaný směr jízdy přímo a vpravo"), { blue = 2, white = 1 } },
	{ "eumandat", "sign_eu_straightleftonly", S("C 2e Přikázaný směr jízdy přímo a vlevo"), { blue = 2, white = 1 } },
	{ "eumandat", "sign_eu_roundabout", S("C 1 Kruhový objezd"), { blue = 2, white = 1 } },
	{ "eumandat", "sign_eu_passingright", S("C 4a Přikázaný směr objíždění vpravo"), { blue = 2, white = 1 } },
	{ "eumandat", "sign_eu_passingleft", S("C 4b Přikázaný směr objíždění vlevo"), { blue = 2, white = 1 } },
	-- { "eumandat", "sign_eu_busstation", "Busstation", { green = 2, yellow = 2 } },
	{ "eumandat", "sign_eu_cyclepath", S("C 8a Stezka pro cyklisty"), { blue = 2, white = 1 } },
	{ "eumandat", "sign_eu_bridlepath", S("C 11a Stezka pro jezdce na zvířeti"), { blue = 2, white = 1 } },
	{ "eumandat", "sign_eu_walkway", S("C 7a Stezka pro chodce"), { blue = 2, white = 1 } },
	{ "eumandat", "sign_eu_sharedpedestriansbicyclists", S("C 9a Stezka pro chodce a cyklisty společná"), { blue = 2, white = 1 } },
	{ "eumandat", "sign_eu_seperatedpedestriansbicyclists", S("C 10a Stezka pro chodce a cyklisty dělená"), { blue = 2, white = 1 } },
	{ "eumandat", "sign_eu_pedestrianszone", S("IZ 6a Pěší zóna"), { blue = 2, white = 2, black = 1 } },
	{ "eumandat", "sign_eu_pedestrianszoneend", S("IZ 6b Konec pěší zóny"), { grey = 2, white = 2, black = 1 } },
	{ "eumandat", "sign_eu_oneway", S("IP 4b Jednosměrný provoz"), { blue = 2, white = 1, black = 1 }, "small" },
	{ "eumandat", "sign_eu_onewayright", S("IP 4a Jednosměrný provoz (vpravo)"), { blue = 2, white = 1, black = 1 }, "wide" },
	{ "eumandat", "sign_eu_onewayleft", S("IP 4a Jednosměrný provoz (vlevo)"), { blue = 2, white = 1, black = 1 }, "wide" },

	-- EU Other
	{ "euother", "sign_eu_guideboard_left", S("Z 4b Směrovací deska se šikmými pruhy se sklonem vpravo"), { white = 2, red = 2 } },
	{ "euother", "sign_eu_guideboard_right", S("Z 4a Směrovací deska se šikmými pruhy se sklonem vlevo"), { white = 2, red = 2 } },
	{ "euother", "sign_eu_bendright", S("Z 3 Vodicí tabule (vpravo)"), { white = 2, red = 2 } },
	{ "euother", "sign_eu_bendleft", S("Z 3 Vodicí tabule (vlevo)"), { white = 2, red = 2 } },
	-- { "euother", "sign_eu_pedestriansleft", "Pedestrians to the Left", { white = 2, black = 1 } },
	-- { "euother", "sign_eu_pedestriansright", "Pedestrians to the Right", { white = 2, black = 1 } },
	{ "euother", "sign_eu_arrowright", S("E 7b Směrová šipka pro odbočení (vpravo)"), { white = 2, black = 1 } },
	{ "euother", "sign_eu_arrowleft", S("E 7b Směrová šipka pro odbočení (vlevo)"), { white = 2, black = 1 } },
	{ "euother", "sign_eu_arrowturnright", S("šipka naznačující odbočení vpravo"), { white = 2, black = 1 } },
	{ "euother", "sign_eu_arrowturnleft", S("šipka naznačující odbočení vlevo"), { white = 2, black = 1 } },
	{ "euother", "sign_eu_arrowshorizontal", S("šipky oběma směry vodorovně"), { white = 2, black = 1 } },
	{ "euother", "sign_eu_arrowsvertical", S("šipky oběma směry svisle"), { white = 2, black = 1 } },
	{ "euother", "sign_eu_turningprioroad4", S("E 2b Tvar křižovatky (lze otáčet, varianta 1)"), { white = 2, black = 1 }, "small" },
	{ "euother", "sign_eu_turningprioroad3-1", S("E 2b Tvar křižovatky (lze otáčet, varianta 2)"), { white = 2, black = 1 }, "small" },
	{ "euother", "sign_eu_turningprioroad3-2", S("E 2b Tvar křižovatky (lze otáčet, varianta 3)"), { white = 2, black = 1 }, "small" },
	-- { "euother", "sign_eu_additionallane", "Additional Lane", { white = 3, black = 1 }, "big" },
	-- { "euother", "sign_eu_mergelanes", "Merge Lanes", { white = 3, black = 1 }, "big" },
	{ "euother", "sign_eu_laneshift", S("IS 10a Návěst změny směru jízdy (varianta 1)"), { white = 3, black = 1 }, "big" },
	{ "euother", "sign_eu_transfertoothercarriageway1", S("IS 10a Návěst změny směru jízdy (varianta 2)"), { white = 3, black = 1 }, "big" },
	{ "euother", "sign_eu_transfertoothercarriageway2", S("IS 10a Návěst změny směru jízdy (varianta 3)"), { white = 3, black = 1 }, "big" },

	-- EU Priority
	{ "euprio", "sign_eu_yield", S("P 4 Dej přednost v jízdě!"), { white = 2, red = 2 } },
	{ "euprio", "sign_eu_stop", S("P 6 Stůj, dej přednost v jízdě!"), { white = 1, red = 3 } },
	{ "euprio", "sign_eu_givewayoncoming", S("P 7 Přednost protijedoucích vozidel"), { white = 2, red = 2, black = 1 } },
	{ "euprio", "sign_eu_priooveroncoming", S("P 8 Přednost před protijedoucími vozidly"), { white = 1, red = 1, blue = 2 }, "small" },
	{ "euprio", "sign_eu_rightofway", S("P 1 Křižovatka s vedlejší pozemní komunikací"), { white = 2, red = 2, black = 1 } },
	{ "euprio", "sign_eu_majorroad", S("P 2 Hlavní pozemní komunikace"), { white = 2, yellow = 2 } },
	{ "euprio", "sign_eu_endmajorroad", S("P 3 Konec hlavní pozemní komunikace"), { white = 2, yellow = 2, black = 1 } },
	{ "euprio", "sign_eu_greenarrow", S("zelená šipka"), { green = 2, black = 2 } },

	-- EU Prohibitory
	{ "euprohib", "sign_eu_novehicles", S("B 1 Zákaz vjezdu všech vozidel (v obou směrech)"), { red = 2, white = 2 } },
	{ "euprohib", "sign_eu_nomotorcars", S("B 3a Zákaz vjezdu všech motorových vozidel s výjimkou motocyklů bez postranního vozíku"), { red = 2, white = 1, black = 1 } },
	{ "euprohib", "sign_eu_notrucks", S("B 4 Zákaz vjezdu nákladních automobilů"), { red = 2, white = 1, black = 1 } },
	{ "euprohib", "sign_eu_nobikes", S("B 8 Zákaz vjezdu jízdních kol"), { red = 2, white = 1, black = 1 } },
	{ "euprohib", "sign_eu_nopedestrians", S("B 30 Zákaz vstupu chodců"), { red = 2, white = 1, black = 1 } },
	{ "euprohib", "sign_eu_nohorsebackriding", S("B 31 Zákaz vjezdu pro jezdce na zvířeti"), { red = 2, white = 1, black = 1 } },
	{ "euprohib", "sign_eu_nomotorvehicles", S("B 11 Zákaz vjezdu všech motorových vozidel"), { red = 2, white = 1, black = 1 } },
	{ "euprohib", "sign_eu_noentry", S("B 2 Zákaz vjezdu všech vozidel"), { red = 3, white = 1 } },
	{ "euprohib", "sign_eu_nouturns", S("B 25 Zákaz otáčení"), { red = 2, white = 1, black = 1 } },
	{ "euprohib", "sign_eu_30zone", S("IZ 8a Zóna s dopravním omezením (30 km/h)"), { red = 2, white = 1, black = 1 } },
	{ "euprohib", "sign_eu_30zoneend", S("IZ 8b Konec zóny s dopravním omezením (30 km/h)"), { grey = 2, white = 1, black = 1 } },
	{ "euprohib", "sign_eu_noovertaking", S("B 21a Zákaz předjíždění"), { red = 2, white = 1, black = 1 } },
	{ "euprohib", "sign_eu_endnoovertaking", S("B 21b Konec zákazu předjíždění"), { grey = 2, white = 1, black = 1 } },
	{ "euprohib", "sign_eu_end", S("B 26 Konec všech zákazů"), { white = 2, black = 1 } },
	{ "euprohib", "sign_eu_noparking", S("B 29 Zákaz stání"), { red = 2, blue = 2 } },
	{ "euprohib", "sign_eu_nostopping", S("B 28 Zákaz zastavení"), { red = 2, blue = 2 } },
	{ "euprohib", "sign_eu_10", S("B 20a Nejvyšší dovolená rychlost (10 km/h)"), { red = 2, white = 1, black = 1 } },
	{ "euprohib", "sign_eu_30", S("B 20a Nejvyšší dovolená rychlost (30 km/h)"), { red = 2, white = 1, black = 1 } },
	{ "euprohib", "sign_eu_50", S("B 20a Nejvyšší dovolená rychlost (50 km/h)"), { red = 2, white = 1, black = 1 } },
	{ "euprohib", "sign_eu_70", S("B 20a Nejvyšší dovolená rychlost (70 km/h)"), { red = 2, white = 1, black = 1 } },
	{ "euprohib", "sign_eu_100", S("B 20a Nejvyšší dovolená rychlost (100 km/h)"), { red = 2, white = 1, black = 1 } },
	{ "euprohib", "sign_eu_120", S("B 20a Nejvyšší dovolená rychlost (120 km/h)"), { red = 2, white = 1, black = 1 } },

	-- EU Warning
	{ "euwarn", "sign_eu_danger", S("A 22 Jiné nebezpečí"), { red = 2, white = 2, black = 1 } },
	{ "euwarn", "sign_eu_twowaytraffic", S("A 9 Provoz v obou směrech"), { red = 2, white = 2, black = 1 } },
	{ "euwarn", "sign_eu_trafficlightahead", S("A 10 Světelné signály"), { red = 3, white = 2, yellow = 1, green = 1 } },
	{ "euwarn", "sign_eu_farmanimals", S("A 13 Zvířata"), { red = 2, white = 2, black = 1 } },
	{ "euwarn", "sign_eu_intersectionrightofwayright", S("A 3 Křižovatka"), { red = 2, white = 2, black = 1 } },
	{ "euwarn", "sign_eu_curveleft", S("A 1b Zatáčka vlevo"), { red = 2, white = 2, black = 1 } },
	{ "euwarn", "sign_eu_curveright", S("A 1a Zatáčka vpravo"), { red = 2, white = 2, black = 1 } },
	{ "euwarn", "sign_eu_doublecurveleft", S("A 2b Dvojitá zatáčka, první vlevo"), { red = 2, white = 2, black = 1 } },
	{ "euwarn", "sign_eu_doublecurveright", S("A 2a Dvojitá zatáčka, první vpravo"), { red = 2, white = 2, black = 1 } },
	{ "euwarn", "sign_eu_downhillgrade", S("A 5a Nebezpečné klesání"), { red = 2, white = 2, black = 2 } },
	{ "euwarn", "sign_eu_uphillgrade", S("A 5b Nebezpečné stoupání"), { red = 2, white = 2, black = 2 } },
	{ "euwarn", "sign_eu_bumpyroad", S("A 7a Nerovnost vozovky"), { red = 2, white = 2, black = 1 } },
	{ "euwarn", "sign_eu_slipdanger", S("A 8 Nebezpečí smyku"), { red = 2, white = 2, black = 1 } },
	{ "euwarn", "sign_eu_roadnarrowsboth", S("A 6a Zúžená vozovka (z obou stran)"), { red = 2, white = 2, black = 1 } },
	{ "euwarn", "sign_eu_roadnarrowsleft", S("A 6b Zúžená vozovka (z jedné strany) (vlevo)"), { red = 2, white = 2, black = 1 } },
	{ "euwarn", "sign_eu_roadnarrowsright", S("A 6b Zúžená vozovka (z jedné strany) (vpravo)"), { red = 2, white = 2, black = 1 } },
	{ "euwarn", "sign_eu_roadworks", S("A 15 Práce na silnici"), { red = 2, white = 2, black = 1 } },
	{ "euwarn", "sign_eu_jam", S("A 23 Kolona"), { red = 2, white = 2, black = 1 } },
	{ "euwarn", "sign_eu_pedestrians", S("A 12a Chodci"), { red = 2, white = 2, black = 1 } },
	{ "euwarn", "sign_eu_children", S("A 12b Děti"), { red = 2, white = 2, black = 1 } },
	{ "euwarn", "sign_eu_bikes", S("A 19 Cyklisté"), { red = 2, white = 2, black = 1 } },
	{ "euwarn", "sign_eu_deercrossing", S("A 14 Zvěř"), { red = 2, white = 2, black = 1 } },
	-- { "euwarn", "sign_eu_busses", S(""), { red = 2, white = 2, black = 1 } },
	-- { "euwarn", "sign_eu_railroadcrossing", "Railroad Crossing", { red = 2, white = 2, black = 1 } },
	{ "euwarn", "sign_eu_cross1", S("A 32a Výstražný kříž pro železniční přejezd jednokolejný"), {white = 1, red = 2 }},
	{ "euwarn", "sign_eu_cross2", S("A 32b Výstražný kříž pro železniční přejezd vícekolejný"), {white = 2, red = 3 }},

	-- Others
	{ "warn", "sign_curve_chevron_right", S("barevné zvýraznění zatáčky vpravo"), { yellow = 3, black = 3 }, "minetest", "streets_curve_sign.png" },
	{ "warn", "sign_curve_chevron_left", S("barevné zvýraznění zatáčky vlevo"), { yellow = 3, black = 3 }, "minetest", "streets_curve_sign.png^[transformFX" },
	--[[
	{ "warn", "sign_warning", "Warning Sign", { black = 2 }, "minetest", "streets_square_sign_empty.png^streets_sign_warning.png", "streets_sign_back.png^[colorize:#D20000FF" },
	{ "warn", "sign_water", "Water Warning Sign", { green = 1, blue = 3, black = 1 }, "minetest", "streets_square_sign_empty.png^streets_sign_water.png", "streets_sign_back.png^[colorize:#D20000FF" },
	{ "warn", "sign_lava", "Lava Warning Sign", { green = 1, red = 3 }, "minetest",
		"streets_square_sign_empty.png^streets_sign_lava.png", "streets_sign_back.png^[colorize:#D20000FF" },
	{ "warn", "sign_construction", "Construction Warning Sign", { green = 1, blue = 1, brown = 1 }, "minetest",
		"streets_square_sign_empty.png^streets_sign_construction.png", "streets_sign_back.png^[colorize:#D20000FF" },
	]]
	{ "reg", "sign_grass", S("dopravní značka: @1", S("nevstupujte na trávník")), { green = 3, red = 2 }, "minetest",
		"streets_square_sign_empty.png^streets_sign_grass.png", "streets_sign_back.png^[colorize:#D20000FF" },
	--[[
	{ "info", "sign_mine", "Mine Sign", { blue = 2, yellow = 1 }, "minetest",
		"streets_square_sign_empty.png^streets_sign_mine.png", "streets_sign_back.png^[colorize:#D20000FF" },
	{ "info", "sign_shop", "Shop Sign", { blue = 1, red = 1, yellow = 1 }, "minetest",
		"streets_square_sign_empty.png^streets_sign_shop.png", "streets_sign_back.png^[colorize:#D20000FF" },
	{ "info", "sign_work_shop", "Workshop Sign", { red = 1, yellow = 2, blue = 1 }, "minetest",
		"streets_square_sign_empty.png^streets_sign_workshop.png", "streets_sign_back.png^[colorize:#D20000FF" },
	]]
}

-- v[1] section
-- v[2] name
-- v[3] description
-- v[4] dyes
-- v[5] type (null => normal) // not null or "minetest" => should have own inventory image
-- v[6] tile image for type == "minetest",
-- v[7] back tile image for type == "minetest" (optional)

for k, v in ipairs(all_signs) do
	local def = {
		name = v[2],
		friendlyname = S("dopravní značka: @1", v[3]),
		light_source = 3,
		tiles = {
			"streets_"..v[2]..".png",
			"streets_sign_back.png",
		},
		type = v[5] or "normal",
		section = v[1],
		dye_needed = v[4],
	}
	if v[5] == "minetest" and v[6] ~= nil then
		def.tiles = {
			v[7] or "streets_sign_back.png",
			v[7] or "streets_sign_back.png",
			v[7] or "streets_sign_back.png",
			v[7] or "streets_sign_back.png",
			"streets_sign_back.png",
			v[6]
		}
	elseif v[5] ~= nil then
		-- def.inventory_image = "streets_"..v[1].."_inv.png"
	end
	streets.register_road_sign(def)
	print("LADĚNÍ: registered streets:"..v[2]..": "..(minetest.registered_nodes["streets:"..v[2]] and "true" or "false"))
end

minetest.register_alias("streets:sign_eu_guideboard", "streets:sign_eu_guideboard_right")
minetest.register_alias("streets:sign_eu_guideboard_center", "streets:sign_eu_guideboard_right_center")
minetest.register_alias("streets:sign_eu_guideboard_polemount", "streets:sign_eu_guideboard_right_polemount")


--[[ EU Signs
dofile(streets.conf.modpath .. "/streets_signs/eu/euwarn.lua")
dofile(streets.conf.modpath .. "/streets_signs/eu/euother.lua")
dofile(streets.conf.modpath .. "/streets_signs/eu/euprio.lua")
dofile(streets.conf.modpath .. "/streets_signs/eu/eumandat.lua")
dofile(streets.conf.modpath .. "/streets_signs/eu/euprohib.lua")
dofile(streets.conf.modpath .. "/streets_signs/eu/euinfo.lua")
]]
