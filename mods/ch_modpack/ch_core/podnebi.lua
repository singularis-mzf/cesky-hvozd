ch_core.open_submod("podnebi", {privs = true, chat = true})

local biomy = {
	cold_desert = "bílá poušť",
	coniferous_forest_dunes = "písek v jehličnatém lese",
	coniferous_forest = "jehličnatý les",
	deciduous_forest = "příjemný les",
	deciduous_forest_shore = "pobřeží jehličnatého lesa",
	desert = "poušť",
	grassland_dunes = "písek u luk",
	grassland = "louka",
	icesheet = "ledovec",
	rainforest_swamp = "močál",
	rainforest = "tropický prales",
	sandstone_desert = "pískovcová poušť",
	savanna = "savana",
	savanna_shore = "pobřeží savany",
	snowy_grassland = "zimní louka",
	taiga = "tajga",
	tundra_beach = "pláž tundry",
	tundra_highland = "vysočina",
	tundra = "tundra",
}

local def = {
	description = "Vypíše údaje o podnebí na aktuální pozici",
	privs = {server = true},
	func = function(player_name, param)
		local player = minetest.get_player_by_name(player_name)
		local player_pos = player and player:get_pos()
		if not player_pos then
			return false, "Vnitřní chyba serveru"
		end
		player_pos = vector.round(player_pos)
		local info = minetest.get_biome_data(player_pos)
		if not info then
			return false, "Chybná pozice"
		end
		local biome_name, humidity, heat = minetest.get_biome_name(info.biome) or "unknown", info.heat or 0, info.humidity or 0
		if biomy[biome_name] ~= nil then
			biome_name = biomy[biome_name]
		elseif biome_name:sub(-6, -1) == "_under" and biomy[biome_name:sub(1, -7)] ~= nil then
			biome_name = biomy[biome_name:sub(1, -7)].."/katakomby"
		elseif biome_name:sub(-6, -1) == "_ocean" and biomy[biome_name:sub(1, -7)] ~= nil then
			biome_name = biomy[biome_name:sub(1, -7)].."/voda"
		end
		ch_core.systemovy_kanal(player_name, minetest.pos_to_string(player_pos).." biom: "..biome_name..", průměrná teplota: "..math.round(heat / 100 * 50 - 5).." °C, vlhkost: "..math.round(humidity).." % (nemusí dávat smysl)")
		return true
	end,
}
minetest.register_chatcommand("podnebí", def)
minetest.register_chatcommand("podnebi", def)

ch_core.close_submod("podnebi")
