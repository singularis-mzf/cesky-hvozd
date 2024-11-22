local def
local F = minetest.formspec_escape
local ifthenelse = ch_core.ifthenelse

local function load_stations()
	local result = {}
	local by_stn = {}
	local all_lines_set = {["*"] = true}
	local lines_set = {}
	for stn, data in pairs(advtrains.lines.stations) do
		local new_station = {
			stn = stn,
			name = data.name or "",
			owner = data.owner or "",
			tracks = {},
		}
		by_stn[stn] = new_station
		lines_set[stn] = {}
		table.insert(result, new_station)
	end
	for epos, data in pairs(advtrains.lines.stops) do
		if data.stn ~= nil and data.stn ~= "" and by_stn[data.stn] ~= nil then
			local st = by_stn[data.stn]
			local new_track = {
				epos = epos,
				pos = assert(advtrains.decode_pos(epos)),
				track = data.track or "",
			}
			table.insert(st.tracks, new_track)
			local ars = data.ars
			if ars ~= nil then
				if ars.default then
					lines_set[data.stn] = all_lines_set
				else
					local set = lines_set[data.stn]
					for _, rule in ipairs(ars) do
						if not rule.n and rule.ln ~= nil then
							set[rule.ln] = true
						end
					end
				end
			end
		end
	end
	for _, st in ipairs(result) do
		local set = lines_set[st.stn]
		if set["*"] then
			st.lines = {"*"}
		else
			local lines = {}
			for line, _ in pairs(set) do
				table.insert(lines, line)
			end
			table.sort(lines)
			st.lines = lines
		end
	end
	table.sort(result, function(a, b) return a.stn < b.stn end)
	return result
end

advtrains.lines.load_stations_for_formspec = load_stations

local function station_distance(player_pos, st)
	if st.tracks[1] == nil then
		return -- no tracks
	end
	local distance = vector.distance(player_pos, st.tracks[1].pos)
	for i = 2, #st.tracks do
		local d2 = vector.distance(player_pos, st.tracks[i].pos)
		if d2 < distance then
			distance = d2
		end
	end
	return distance
end

local function station_distance_s(player_pos, st)
	local result = station_distance(player_pos, st)
	if result ~= nil then
		return string.format("%d m", result)
	else
		return ""
	end
end


local function filter_all()
	return true
end

local function sort_by_distance(a, b, player_info)
	return (station_distance(player_info.pos, a) or 1.0e+20) < (station_distance(player_info.pos, b) or 1.0e+20)
end

local function sort_by_stn(a, b)
	return tostring(a.stn) < tostring(b.stn)
end

local function sort_by_name(a, b)
	local a_key, b_key = ch_core.utf8_radici_klic(a.name, false), ch_core.utf8_radici_klic(b.name, false)
	if a_key ~= b_key then
		return a_key < b_key
	else
		return sort_by_stn(a, b)
	end
end

local filters = {
	{
		description = "od nejbližší",
		-- filter = filter_all,
		sorter = sort_by_distance,
	},
	{
		description = "podle kódu A-Z",
		-- filter = filter_all,
		sorter = sort_by_stn,
	},
	{
		description = "podle názvu A-Z",
		-- filter = filter_all,
		sorter = sort_by_name,
	},
}


local function get_formspec(custom_state)
	local pinfo = ch_core.normalize_player(assert(custom_state.player_name))
	if pinfo.player == nil then
		minetest.log("error", "Expected player not in game!")
		return ""
	end
	local player_info = {
		name = assert(custom_state.player_name),
		pos = assert(custom_state.player_pos),
	}

	local stations = custom_state.stations
	if stations == nil then
		-- local filter_func = filters[custom_state.active_filter].filter or filter_all
		local sorter_func = filters[custom_state.active_filter].sorter
		stations = {}
		for _, st in ipairs(load_stations()) do
			-- if filter_func(st, player_info) then
				table.insert(stations, st)
			-- end
		end
		table.sort(stations, function(a, b) return sorter_func(a, b, player_info) end)
		custom_state.stations = stations
		if custom_state.selection_index ~= nil and custom_state.selection_index > #stations + 1 then
			custom_state.selection_index = nil
		end
	end

	local selection_index = custom_state.selection_index
    local formspec = {
        ch_core.formspec_header({formspec_version = 6, size = {20, 10}, auto_background = true}),
		"label[0.5,0.6;Editor dopraven]",
    }

	table.insert(formspec, "tablecolumns[image,"..
		"0=ch_core_empty.png,"..
		"1=basic_materials_padlock.png\\^[resize:16x16"..
		";text;text,width=25;color,span=1;text,width=7;text;text]"..
		"table[0.5,1.25;19,5;dopravna;0,KÓD,NÁZEV,#ffffff,SPRAVUJE,VZDÁLENOST,INFO")
	for _, st in ipairs(stations) do
		local n_tracks = #st.tracks
		table.insert(formspec, ",0,"..F(st.stn)..","..F(st.name)..",#ffffff,"..F(ch_core.prihlasovaci_na_zobrazovaci(st.owner))..","..
			F(station_distance_s(custom_state.player_pos, st))..","..n_tracks.." kolej")
		if n_tracks < 1 or n_tracks > 4 then
			table.insert(formspec, "í")
		elseif n_tracks ~= 1 then
			table.insert(formspec, "e")
		end
		if n_tracks > 0 then
			table.insert(formspec, "\\, linky " ..F(table.concat(st.lines, ",")))
		end
	end
	table.insert(formspec, ";"..(selection_index or "").."]")

	-- rozbalovací pole s volbou filtru a řazení
	table.insert(formspec, "dropdown[8,0.3;7,0.6;filter;"..F(assert(filters[1].description)))
	for i = 2, #filters do
		table.insert(formspec, ","..F(filters[i].description))
	end
	table.insert(formspec, ";"..custom_state.active_filter..";true]")

	table.insert(formspec, "button_exit[18.75,0.3;0.75,0.75;close;X]")

	local st = selection_index ~= nil and stations[selection_index - 1]
	local stn, nazev, spravuje
	if st then
		stn = F(st.stn)
		nazev = F(st.name)
		spravuje = F(ch_core.prihlasovaci_na_zobrazovaci(st.owner))
	else
		stn, nazev, spravuje = "", "", F(pinfo.viewname)
	end
	table.insert(formspec,
		"field[0.5,7;2.5,0.75;stn;kód:;"..stn.."]"..
		"field[3.25,7;7,0.75;name;název:;"..nazev.."]"..
		ifthenelse(pinfo.role == "admin", "field[10.5,7;4,0.75;owner;spravuje:;", "label[10.5,6.75;spravuje:\n")..
		spravuje.."]")
	if pinfo.role ~= "new" then
		table.insert(formspec, "button[0.5,8;4.5,0.75;vytvorit;vytvořit novou]")
		if st and (pinfo.role == "admin" or st.owner == pinfo.player_name) then
			table.insert(formspec, "button[5.25,8;4.5,0.75;ulozit;uložit změny]")
			if st.tracks[1] == nil then
				table.insert(formspec, "button[12.5,8;2,0.75;smazat;smazat]")
			end
		end
	end
	if st and st.tracks[1] ~= nil then
		table.insert(formspec, "textarea[14.75,7;4.75,2.5;;pozice kolejí:;"..F(minetest.pos_to_string(st.tracks[1].pos)))
		for i = 2, #st.tracks do
			table.insert(formspec, "\n"..F(minetest.pos_to_string(st.tracks[i].pos)))
		end
		table.insert(formspec, "]")
	end
	return table.concat(formspec)
end

local function formspec_callback(custom_state, player, formname, fields)
	local update_formspec = false

	if fields.vytvorit then
		local new_stn, new_name, new_owner = fields.stn, fields.name or "", fields.owner
		local pinfo = ch_core.normalize_player(player)
		if pinfo.role ~= "admin" or new_owner == nil or new_owner == "" then
			new_owner = pinfo.player_name
		else
			new_owner = ch_core.jmeno_na_prihlasovaci(new_owner)
		end
		if new_stn == nil or new_stn == "" then
			ch_core.systemovy_kanal(custom_state.player_name, "CHYBA: kód nesmí být prázdný!")
			return
		end
		local als = advtrains.lines.stations
		if als[new_stn] ~= nil then
			ch_core.systemovy_kanal(custom_state.player_name, "CHYBA: zastávka s kódem "..new_stn.." již existuje!")
			return
		end
		als[new_stn] = {name = assert(new_name), owner = assert(new_owner)}
		custom_state.stations = nil
		update_formspec = true
		ch_core.systemovy_kanal(custom_state.player_name, "Dopravna úspěšně vytvořena.")
	elseif fields.ulozit then
		local new_stn, new_name, new_owner = fields.stn, fields.name or "", fields.owner
		local pinfo = ch_core.normalize_player(player)
		local st = custom_state.stations[(custom_state.selection_index or 0) - 1]
		if st == nil then
			ch_core.systemovy_kanal(custom_state.player_name, "CHYBA: není vybrána žádná zastávka!")
			return
		end
		local change_stn, change_name = st.stn ~= new_stn, st.name ~= new_name
		local change_owner = pinfo.role == "admin" and fields.owner ~= nil and fields.owner ~= "" and
			ch_core.jmeno_na_prihlasovaci(fields.owner) ~= st.owner
		if not change_stn and not change_name and not change_owner then
			ch_core.systemovy_kanal(custom_state.player_name, "Nic nezměněno.")
			return
		end
		local t = advtrains.lines.stations[st.stn]
		if t == nil then
			ch_core.systemovy_kanal(custom_state.player_name, "CHYBA: zastávka k úpravě nebyla nalezena! Toto je pravděpodobně vnitřní chyba editoru.")
			return
		end
		if change_stn then
			-- zkontrolovat, že cílový kód je volný
			if advtrains.lines.stations[new_stn] ~= nil then
				ch_core.systemovy_kanal(custom_state.player_name, "CHYBA: zastávka s kódem "..new_stn.." již existuje!")
				return
			end
		end
		if change_owner then
			t.owner = ch_core.jmeno_na_prihlasovaci(fields.owner)
			ch_core.systemovy_kanal(custom_state.player_name, "Správa zastávky změněna.")
		end
		if change_name then
			t.name = new_name
			ch_core.systemovy_kanal(custom_state.player_name, "Jmeno zastávky změněno.")
		end
		if change_stn then
			advtrains.lines.stations[new_stn] = t
			local stops = advtrains.lines.stops
			local count = 0
			for _, trackinfo in ipairs(st.tracks) do
				local stop = stops[trackinfo.epos]
				if stop == nil then
					minetest.log("error", "Expected track at position "..trackinfo.epos.." not found!")
				elseif stop.stn ~= st.stn then
					minetest.log("error", "Track at position "..trackinfo.epos.." has unexpected stn '"..tostring(stop.stn).."' instead of '"..st.stn.."'!")
				else
					stop.stn = new_stn
					count = count + 1
				end
			end
			advtrains.lines.stations[st.stn] = nil
			ch_core.systemovy_kanal(custom_state.player_name, "Kód zastávky změněn, "..count.." bloků kolejí aktualizováno.")
		end
		custom_state.stations = nil
		update_formspec = true
	elseif fields.smazat then
		local pinfo = ch_core.normalize_player(player)
		local st = custom_state.stations[(custom_state.selection_index or 0) - 1]
		if st == nil then
			ch_core.systemovy_kanal(custom_state.player_name, "CHYBA: není vybrána žádná zastávka!")
			return
		end
		if st.tracks[1] ~= nil then
			ch_core.systemovy_kanal(custom_state.player_name, "Nelze smazat zastávku, k níž jsou přiřazeny koleje!")
			return
		end
		local t = advtrains.lines.stations[st.stn]
		if t == nil then
			ch_core.systemovy_kanal(custom_state.player_name, "CHYBA: zastávka k úpravě nebyla nalezena! Toto je pravděpodobně vnitřní chyba editoru.")
			return
		end
		advtrains.lines.stations[st.stn] = nil
		ch_core.systemovy_kanal(custom_state.player_name, "Zastávka úspěšně smazána.")
		custom_state.stations = nil
		update_formspec = true
	elseif fields.quit then
		return
	end

	if fields.dopravna then
		local event = minetest.explode_table_event(fields.dopravna)
		if event.type == "CHG" then
			custom_state.selection_index = ifthenelse(event.row > 1, event.row, nil)
			update_formspec = true
		end
	end

	-- filter (must be the last)
	if fields.filter then
		local new_filter = tonumber(fields.filter)
		if filters[new_filter] ~= nil and new_filter ~= custom_state.active_filter then
			custom_state.active_filter = new_filter
			custom_state.stations = nil
			update_formspec = true
		end
	end
	if update_formspec then
		return get_formspec(custom_state)
	end
end

local function show_formspec(player)

	local custom_state = {
		player_name = assert(player:get_player_name()),
		player_pos = vector.round(player:get_pos()),
		active_filter = 1,
		-- selection_index = nil,
	}
	-- ch_core.show_formspec(player_or_player_name, formname, formspec, formspec_callback, custom_state, options)
	ch_core.show_formspec(player, "advtrains_line_automation:editor_dopraven", get_formspec(custom_state), formspec_callback, custom_state, {})
end

advtrains.lines.open_station_editor = show_formspec

def = {
    -- params = "",
    description = "Otevře editor dopraven (stanic, zastávek a odboček)",
    privs = {ch_registered_player = true},
    func = function(player_name, param) show_formspec(minetest.get_player_by_name(player_name)) end,
}
minetest.register_chatcommand("zastavky", def)
minetest.register_chatcommand("zastávky", def)
