local def
local F = minetest.formspec_escape
local ifthenelse = ch_core.ifthenelse
local rwt = assert(advtrains.lines.rwt)

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

local function filter_mine(a, player_info)
	return a.owner == player_info.name
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
	{
		description = "moje (podle kódu A-Z)",
		filter = filter_mine,
		sorter = sort_by_stn,
	},
	{
		description = "moje (podle názvu A-Z)",
		filter = filter_mine,
		sorter = sort_by_name,
	},
	{
		description = "moje (od nejbližší)",
		filter = filter_mine,
		sorter = sort_by_distance,
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
		local filter = filters[custom_state.active_filter]
		local filter_func = filter.filter or filter_all
		local sorter_func = filter.sorter
		stations = {}
		for _, st in ipairs(load_stations()) do
			if filter_func(st, player_info) then
				table.insert(stations, st)
			end
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
		table.insert(formspec, "button[0.5,8;4.5,0.75;vytvorit;vytvořit novou]"..
			"button[10,8;4.5,0.75;jrad;jízdní řády...]")
		if st and (pinfo.role == "admin" or st.owner == pinfo.player_name) then
			table.insert(formspec, "button[5.25,8;4.5,0.75;ulozit;uložit změny]")
			if st.tracks[1] == nil then
				table.insert(formspec, "button[15.25,8;3,0.75;smazat;smazat]")
			end
			if custom_state.linevars[1] ~= nil then
				table.insert(formspec, "label[0.5,9.4;přiřadit kolej]"..
					"field[2.75,9.1;1,0.6;kolej;;]"..
					"label[3.9,9.4;lince]"..
					"dropdown[5,9.1;5,0.6;klinevar;")
				for i, lvar in ipairs(custom_state.linevars) do
					if i ~= 1 then
						table.insert(formspec, ",")
					end
					table.insert(formspec, F(lvar.linevar.." | "..lvar.dep.." "..stn.." ["..lvar.track.."]"))
				end
				table.insert(formspec, ";"..custom_state.current_linevar..";true]"..
					"button[10.25,9;4.25,0.75;priradit_kolej;přiřadit]"..
					"tooltip[klinevar;")
				table.insert(formspec, F("Vysvětlení formátu:\n<linka>/<kód vých.dop.>/<sm.kód> | <odjezd> <kód dop.> [<stávající kolej>]"))
				table.insert(formspec, "]")
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
	elseif fields.jrad then
		local st = custom_state.stations[(custom_state.selection_index or 0) - 1]
		if st == nil then
			ch_core.systemovy_kanal(custom_state.player_name, "CHYBA: není vybrána žádná zastávka!")
			return
		end
		advtrains.lines.show_jr_formspec(player, nil, assert(st.stn))
		return
	elseif fields.priradit_kolej then
		local st = custom_state.stations[(custom_state.selection_index or 0) - 1]
		if st == nil then
			ch_core.systemovy_kanal(custom_state.player_name, "CHYBA: není vybrána žádná zastávka!")
			return
		end
		local linevar_to_change = custom_state.linevars[custom_state.current_linevar]
		if linevar_to_change == nil then
			ch_core.systemovy_kanal(custom_state.player_name, "CHYBA: vnitřní chyba 1!")
			return
		end
		local linevar_def = advtrains.lines.try_get_linevar_def(linevar_to_change.linevar, linevar_to_change.stn)
		if linevar_def == nil then
			ch_core.systemovy_kanal(custom_state.player_name, "CHYBA: vnitřní chyba 2!")
			return
		end
		local stop = linevar_def.stops[linevar_to_change.linevar_index]
		if stop == nil then
			ch_core.systemovy_kanal(custom_state.player_name, "CHYBA: vnitřní chyba 3!")
			return
		end
		if stop.stn ~= st.stn then
			ch_core.systemovy_kanal(custom_state.player_name, "CHYBA: vnitřní chyba 4!")
			return
		end
		stop.track = tostring(fields.kolej)
		linevar_to_change.track = stop.track
		ch_core.systemovy_kanal(custom_state.player_name, "Přiřazená kolej úspěšně nastavena.")
		update_formspec = true
	elseif fields.quit then
		return
	end

	if fields.dopravna then
		local event = minetest.explode_table_event(fields.dopravna)
		if event.type == "CHG" then
			custom_state.selection_index = ifthenelse(event.row > 1, event.row, nil)
			local st = custom_state.stations[(custom_state.selection_index or 0) - 1]
			local new_linevars = {}
			custom_state.linevars = new_linevars
			custom_state.current_linevar = 1
			if st ~= nil then
				for _, r in ipairs(advtrains.lines.get_linevars_by_station(st.stn)) do
					local line, stn = advtrains.lines.linevar_decompose(r.linevar)
					for _, i in ipairs(r.indices) do
						local stop = r.linevar_def.stops[i]
						table.insert(new_linevars, {
							stn = stn,
							linevar = r.linevar,
							linevar_index = i,
							dep = assert(stop.dep),
							track = stop.track or "",
						})
					end
				end
			end
			update_formspec = true
		end
	end

	if fields.klinevar then
		local n = tonumber(fields.klinevar)
		if n ~= nil and custom_state.linevars[n] ~= nil then
			custom_state.current_linevar = n
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
		linevars = {--[[
			{stn = string, linevar = string, linevar_index = int, track = string}...
		]]},
		current_linevar = 1,
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
core.register_chatcommand("zastavky", def)
core.register_chatcommand("zastávky", def)


-- Jízdní řád

--[[
	custom_state = {
		pos = vector or nil, -- node position (will use metadata to determine the owner)
		player_name = string, -- player to whom the formspec is to be shown (will use this to determine privs)
		stn = int, -- station selection from stns
		stns = {
			{stn = "", fs = "(vyberte dopravnu)", name_fs = ""},
			{stn = string, fs = string, name_fs = string}...
		}, -- the list of stations to select from; the first must be "", which means no station
		track = int, -- selection of track from "tracks" list
		tracks = {"", string...}, -- the list of tracks to select from; the first must be "", which means all tracks
		linevar = int,
		linevars = {{
			stn = string, -- station from linevar
			linevar = string, -- linevar
			line_fs = string, -- line for formspec
			target_fs = string, -- terminus name for formspec
			track_fs = string, -- track info for formspec ("" if not available)
			status_fs = string, -- line status for formspec (including color column)
			train_name_fs = string, -- train name for formspec ("" if not available)
			linevar_index = int, -- index of the selected station (stn) in linevar_def.stops of this linevar
		}...},
		stop = int,
		stops = {{
			stn = string,
			name_fs = string,
			track_fs = string,
			dep = int,
			wait = int,
			linevar_index = int, -- index of this stop in linevar_def.stops
		}...},
		message = string, -- message for label[] on the bottom; "" to disable
	}
]]

local all_stations_record = {stn = "", fs = F("(vyberte dopravnu)"), name_fs = ""}
local is_visible_mode = assert(advtrains.lines.is_visible_mode)

-- refresh custom_state.stops according to custom_state.linevar
local function jr_refresh_stops(custom_state, stn_to_select)
	if stn_to_select == "" then
		stn_to_select = nil
	end
	local linevar_info = custom_state.linevars[custom_state.linevar]
	local index_to_select = 0
	local result = {}
	if linevar_info ~= nil then
		local linevar_def = advtrains.lines.try_get_linevar_def(linevar_info.linevar, linevar_info.stn)
		if linevar_def == nil then
			-- invalid linevar => no stops
			core.log("error", "Player "..custom_state.player_name.." selected invalid linevar "..linevars[linevar].linevar.."!")
		else
			local stops = linevar_def.stops
			for linevar_index, stop_data in ipairs(linevar_def.stops) do
				if is_visible_mode(stop_data.mode) then
					local r = {
						stn = assert(stop_data.stn),
						name_fs = F(advtrains.lines.get_station_name(stop_data.stn)),
						track_fs = stop_data.track or "",
						dep = stop_data.dep,
						wait = stop_data.wait or 10,
						linevar_index = linevar_index,
					}
					if r.track_fs ~= "" then
						r.track_fs = F("["..r.track_fs.."]")
					end
					table.insert(result, r)
					if stn_to_select ~= nil and index_to_select == 0 and r.stn == stn_to_select then
						index_to_select = #result -- stop selected
					end
				end
			end
		end
	end
	if index_to_select == 0 and result[1] ~= nil then
		index_to_select = 1
	end
	custom_state.stop = index_to_select
	custom_state.stops = result
	custom_state.message = ""
end

local function get_all_linevars()
	local result = {}
	local empty_table = {}
	local trains_by_linevar = advtrains.lines.get_trains_by_linevar()
	for stn, stdata in pairs(advtrains.lines.stations) do
		for linevar, linevar_def in pairs(stdata.linevars or empty_table) do
			local line, stn = advtrains.lines.linevar_decompose(linevar)
			local target_fs = F(advtrains.lines.get_line_description(linevar_def, {line_number = false, last_stop = true, last_stop_prefix = "",
				last_stop_uppercase = false, train_name = false}))
			local status_fs
			if trains_by_linevar[linevar] ~= nil then
				status_fs = "#00ff00,v provozu"
			else
				status_fs = "#999999,neznámý"
			end
			table.insert(result, {
				stn = stn,
				linevar = linevar,
				line_fs = F(line),
				target_fs = target_fs,
				track_fs = "",
				status_fs = status_fs,
				train_name_fs = F(linevar_def.train_name or ""),
				linevar_index = 1,
			})
		end
	end
	table.sort(result, function(a, b) return a.linevar < b.linevar end)
	return result
end

--[[
	stn_filter = string,
	track_filter = string or nil,
]]
local function get_linevars_by_filter(stn_filter, track_filter)
	local result = {}
	local empty_table = {}
	local line_description_options = {line_number = false, last_stop = true, last_stop_prefix = "", last_stop_uppercase = false, train_name = false}
	local trains_by_linevar = advtrains.lines.get_trains_by_linevar()
	assert(stn_filter)
	if track_filter == "" then
		track_filter = nil
	end
	for stn, stdata in pairs(advtrains.lines.stations) do
		for linevar, linevar_def in pairs(stdata.linevars or empty_table) do
			local last_stop_index = advtrains.lines.get_last_stop(linevar_def, false)
			if last_stop_index ~= nil then
				for linevar_index = 1, last_stop_index - 1 do -- NOTE: the last visible station is intentionally ignored here!
					local stop_data = linevar_def.stops[linevar_index]
					local initialized = false
					local line, stn, line_fs, target_fs, status_fs
					if
						stop_data.stn == stn_filter and
						is_visible_mode(stop_data.mode) and
						(track_filter == nil or track_filter == stop_data.track)
					then
						if not initialized then
							initialized = true
							line, stn = advtrains.lines.linevar_decompose(linevar)
							line_fs = F(line)
							target_fs = F(advtrains.lines.get_line_description(linevar_def, line_description_options))
							if trains_by_linevar[linevar] ~= nil then
								status_fs = "#00ff00,v provozu"
							else
								status_fs = "#999999,neznámý"
							end
						end
						local track_fs = stop_data.track
						if track_fs == nil or track_fs == "" then
							track_fs = ""
						else
							track_fs = F("["..track_fs.."]")
						end
						table.insert(result, {
							stn = stn,
							linevar = linevar,
							line_fs = line_fs,
							target_fs = target_fs,
							track_fs = track_fs,
							status_fs = status_fs,
							train_name_fs = F(linevar_def.train_name or ""),
							linevar_index = assert(linevar_index),
						})
					end
				end
			end
		end
	end
	table.sort(result, function(a, b)
		if a.linevar ~= b.linevar then
			return a.linevar < b.linevar
		else
			return a.linevar_index < b.linevar_index
		end
	end)
	return result
end

local function is_jr_node_name(name)
	return core.get_item_group(name, "ch_jrad") ~= 0
end

-- refresh custom_state.linevars according to custom_state.stn and custom_state.track
local function jr_refresh_linevars(custom_state, linevar_to_select, linevar_index_to_select)
	if linevar_to_select == "" then
		linevar_to_select = nil
	end
	assert(linevar_index_to_select == nil or type(linevar_index_to_select) == "number")
	local stn = assert(custom_state.stn)
	local stn_info = assert(custom_state.stns[stn])
	local track = assert(custom_state.track)
	local tracks = assert(custom_state.tracks)

	local new_linevars
	if stn_info.stn == "" then
		new_linevars = get_all_linevars()
	else
		new_linevars = get_linevars_by_filter(stn_info.stn, assert(tracks[track]))
	end
	local index_to_select = 1
	if linevar_to_select ~= nil then
		for i, r in ipairs(new_linevars) do
			if r.linevar == linevar_to_select and (linevar_index_to_select == nil or r.linevar_index == linevar_index_to_select) then
				index_to_select = i
				break
			end
		end
	end
	if new_linevars[index_to_select] == nil then
		index_to_select = 0
	end
	custom_state.linevars = new_linevars
	custom_state.linevar = index_to_select
	custom_state.message = ""

	local pos = custom_state.pos
	if pos ~= nil and is_jr_node_name(core.get_node(pos).name) then
		local meta = core.get_meta(pos)
		meta:set_string("stn", custom_state.stns[custom_state.stn].stn)
		meta:set_string("track", custom_state.tracks[custom_state.track])
		local infotext = {"jízdní řád\n"}
		if stn_info.stn == "" then
			table.insert(infotext, "<všechny linky>")
		else
			table.insert(infotext, advtrains.lines.get_station_name(stn_info.stn))
			if custom_state.tracks[custom_state.track] ~= "" then
				table.insert(infotext, " ["..custom_state.tracks[custom_state.track].."]")
			end
		end
		if new_linevars[1] ~= nil then
			local prefix = "\n"
			local set = {[""] = true}
			for _, linevar_info in ipairs(new_linevars) do
				local line = advtrains.lines.linevar_decompose(linevar_info.linevar)
				if not set[line] then
					set[line] = true
					table.insert(infotext, prefix.."["..line.."]")
					prefix = " "
				end
			end
		end
		meta:set_string("infotext", table.concat(infotext))
	end
end

-- refresh custom_state.tracks according to custom_state.stn
-- and selects a specified track, if available
local function jr_refresh_tracks(custom_state, track_to_select)
	if track_to_select == "" then
		track_to_select = nil
	end
	local result = {""}
	local index_to_select = 1
	local current_stn = custom_state.stns[custom_state.stn].stn
	if current_stn ~= "" and advtrains.lines.stations[current_stn] ~= nil then
		local track_set = {[""] = true}
		-- search for tracks:
		for epos, stdata in pairs(advtrains.lines.stops) do
			if stdata.stn == current_stn and stdata.track ~= nil and not track_set[stdata.track] then
				track_set[stdata.track] = true
				table.insert(result, tostring(stdata.track))
			end
		end
		if #result > 1 then
			table.sort(result)
			assert(result[1] == "")
			if track_to_select ~= nil then
				for i, track in ipairs(result) do
					if track_to_select == track then
						index_to_select = i
					end
				end
			end
		end
	end
	custom_state.tracks = result
	custom_state.track = index_to_select
	custom_state.message = ""
end

--[[
	-- will refresh custom_state.stns[] and (optionally) select a wanted station if it's on the list,
	-- otherwise the default 'select station' option will be chosen
	custom_state = table,
	stn_to_select = string or nil,
]]
local function jr_refresh_stns(custom_state, stn_to_select)
	if stn_to_select == "" then
		stn_to_select = nil
	end
	local result = {all_stations_record}
	local index_to_select = 1
	for i, st in ipairs(load_stations()) do
		result[1 + i] = {
			stn = assert(st.stn),
			fs = F(st.stn.." | "..st.name),
			name_fs = F(st.name),
		}
		if stn_to_select ~= nil and st.stn == stn_to_select then
			index_to_select = 1 + i
		end
	end
	custom_state.stns = result
	custom_state.stn = index_to_select
	custom_state.message = ""
end

-- will refresh a departure message according to linevar + stop
local function jr_refresh_departure(custom_state)
	local linevar_info = custom_state.linevars[custom_state.linevar]
	local stop_info = custom_state.stops[custom_state.stop]
	if linevar_info == nil or stop_info == nil then
		custom_state.message = ""
		return
	end
	local linevar_def = advtrains.lines.try_get_linevar_def(linevar_info.linevar)
	if linevar_def == nil then
		custom_state.message = ""
		return
	end
	local rwtime = rwt.to_secs(rwt.get_time())
	local prediction = advtrains.lines.predict_station_departures(linevar_def, assert(stop_info.linevar_index), rwtime)
	if #prediction == 0 then
		custom_state.message = "v nejbližší době nenalezeny žádné odjezdy zvolené linky"
		return
	end
	local deps = {}
	for i, pred in ipairs(prediction) do
		deps[i] = tostring(pred.dep - rwtime)
	end
	custom_state.message = "nejbližší odjezdy zvolené linky za: "..table.concat(deps, ", ").." s"
end

local function get_jr_formspec(custom_state)
	local formspec = {
		ch_core.formspec_header({
			formspec_version = 6,
			size = {20, 12},
			auto_background = true,
		})
	}
	local access_level = "player" -- player | owner | admin
	local node_owner
	if custom_state.pos ~= nil then
		node_owner = core.get_meta(custom_state.pos):get_string("owner")
		if node_owner == "" then
			node_owner = nil
		end
	end
	local stn, stn_owner
	if custom_state.stn > 1 and custom_state.stns[custom_state.stn] ~= nil then
		stn_owner = (advtrains.lines.stations[custom_state.stns[custom_state.stn].stn] or {}).owner -- may be nil
	end

	if not custom_state.force_unprivileged then
		if ch_core.get_player_role(custom_state.player_name) == "admin" then
			access_level = "admin"
		elseif custom_state.player_name == node_owner or custom_state.player_name == stn_owner then
			access_level = "owner"
		end
	end

	if node_owner ~= nil then
		if access_level ~= "player" then
			-- admin or owner:
			table.insert(formspec, "label[0.5,0.6;Jízdní řády]"..
				"dropdown[5,0.3;10,0.6;dopravna;")
			for i, r in ipairs(custom_state.stns) do
				table.insert(formspec, ifthenelse(i == 1, r.fs, ","..r.fs))
			end
			table.insert(formspec, ";"..custom_state.stn..";true]"..
				"dropdown[15.25,0.3;3.5,0.6;kolej;")
			for i, r in ipairs(custom_state.tracks) do
				if i == 1 then
					table.insert(formspec, "(všechny koleje)")
				else
					table.insert(formspec, ","..F(r))
				end
			end
			table.insert(formspec, ";"..custom_state.track..";true]")
		else
			-- player (including 'new' players)
			local stn_info = custom_state.stns[custom_state.stn]
			if stn_info.stn == "" then
				table.insert(formspec, "label[0.5,0.6;Jízdní řády (všechny linky)]")
			else
				local track = custom_state.tracks[custom_state.track]
				if track ~= "" then
					track = F(" ["..track.."]")
				end
				table.insert(formspec, "label[0.5,0.6;"..F("Jízdní řády: ")..stn_info.name_fs..track.."]")
			end
		end
		if access_level ~= "admin" then
			-- player/owner
			table.insert(formspec, "label[0.5,1.65;vlastník/ice j. řádu: ")
			table.insert(formspec, ch_core.prihlasovaci_na_zobrazovaci(node_owner))
			if stn_owner ~= nil then
				table.insert(formspec, " | dopravnu spravuje: ")
				table.insert(formspec, ch_core.prihlasovaci_na_zobrazovaci(stn_owner))
			end
			table.insert(formspec, "]")
		else
			-- admin only
			table.insert(formspec, "label[0.5,1.65;vlastník/ice:]"..
				"field[2.75,1.25;5,0.75;owner;;")
			table.insert(formspec, ch_core.prihlasovaci_na_zobrazovaci(node_owner))
			table.insert(formspec, "]button[8,1.25;3,0.75;setowner;nastavit]")
			if stn_owner ~= nil then
				table.insert(formspec, "label[11.25,1.65;dopravnu spravuje: "..ch_core.prihlasovaci_na_zobrazovaci(stn_owner).."]")
			end
		end
	else
		table.insert(formspec, "label[0.5,0.6;Příruční jízdní řády (všechny linky)]")
	end

	table.insert(formspec, "tablecolumns[text,align=right,tooltip=linka;text,width=12,tooltip=cíl;text,tooltip=kolej;color,span=1;text,tooltip=stav;color,span=1;text,tooltip=jméno vlaku]"..
		"table[0.5,2.25;11,5;linka;")
	for i, r in ipairs(custom_state.linevars) do
		if i > 1 then
			table.insert(formspec, ",")
		end
		table.insert(formspec, r.line_fs..","..r.target_fs..","..r.track_fs..","..r.status_fs..",#cccccc,"..r.train_name_fs)
	end
	table.insert(formspec, ifthenelse(custom_state.linevar > 0, ";"..custom_state.linevar.."]", ";]"))
	table.insert(formspec, "tablecolumns[text,align=right;text;text]"..
		"table[12.5,2.25;7,8.75;zastavka;")
	if custom_state.stops[1] ~= nil then
		local selected_stop_index = custom_state.stop
		if custom_state.stops[selected_stop_index] == nil then
			selected_stop_index = 1
		end
		local base_dep
		for i, r in ipairs(custom_state.stops) do
			if i > 1 then
				table.insert(formspec, ",")
			end
			if i >= selected_stop_index then
				if i == selected_stop_index then
					base_dep = assert(r.dep)
					table.insert(formspec, "0,")
				else
					table.insert(formspec, (r.dep - base_dep)..",")
				end
			else
				table.insert(formspec, "    ,")
			end
			table.insert(formspec, r.name_fs..","..r.track_fs)
		end
		table.insert(formspec, ";"..selected_stop_index.."]")
	else
		table.insert(formspec, ";]") -- empty list
	end
	table.insert(formspec, "button_exit[18.75,0.3;0.75,0.75;close;X]")
	if custom_state.message ~= "" then
		table.insert(formspec, "label[5.25,11.35;"..F(custom_state.message).."]")
	end
	table.insert(formspec, "button[0.5,11;4.5,0.75;refresh;zjistit nejbližší odjezdy...]")
	return table.concat(formspec)
end

local function jr_formspec_callback(custom_state, player, formname, fields)
	if fields.dopravna then
		local new_stn = tonumber(fields.dopravna)
		if new_stn ~= nil and new_stn ~= custom_state.stn and custom_state.stns[new_stn] ~= nil then
			custom_state.stn = new_stn
			local current_track = custom_state.tracks[custom_state.track] or ""
			local current_linevar_info = custom_state.linevars[custom_state.linevar]
			jr_refresh_tracks(custom_state, current_track)
			if current_linevar_info ~= nil then
				jr_refresh_linevars(custom_state, current_linevar_info.linevar, current_linevar_info.linevar_index)
			else
				jr_refresh_linevars(custom_state)
			end
			jr_refresh_stops(custom_state, custom_state.stns[new_stn].stn)
			jr_refresh_departure(custom_state)
			return get_jr_formspec(custom_state)
		end
	end
	if fields.kolej then
		local new_track = tonumber(fields.kolej)
		if new_track ~= nil and new_track ~= custom_state.track and custom_state.tracks[new_track] ~= nil then
			custom_state.track = new_track
			local current_linevar_info = custom_state.linevars[custom_state.linevar]
			if current_linevar_info ~= nil then
				jr_refresh_linevars(custom_state, current_linevar_info.linevar, current_linevar_info.linevar_index)
			else
				jr_refresh_linevars(custom_state)
			end
			jr_refresh_stops(custom_state, custom_state.stns[custom_state.stn].stn)
			jr_refresh_departure(custom_state)
			return get_jr_formspec(custom_state)
		end
	end
	if fields.setowner and custom_state.pos ~= nil and is_jr_node_name(core.get_node(custom_state.pos).name) then
		local meta = core.get_meta(custom_state.pos)
		local jm = ch_core.jmeno_na_existujici_prihlasovaci(fields.owner)
		if jm ~= nil then
			meta:set_string("owner", jm)
		else
			core.chat_send_player(custom_state.player_name, "*** Postava '"..fields.owner.."' neexistuje!")
		end
		return get_jr_formspec(custom_state)
	end
	if fields.linka then
		local event = core.explode_table_event(fields.linka)
		local new_line
		if event.type == "CHG" or event.type == "DCL" then
			new_line = tonumber(event.row)
		end
		if new_line ~= nil and new_line ~= custom_state.linevar then
			local new_linevar_info = custom_state.linevars[new_line]
			if new_linevar_info ~= nil then
				jr_refresh_linevars(custom_state, new_linevar_info.linevar, new_linevar_info.linevar_index)
			else
				jr_refresh_linevars(custom_state)
			end
			jr_refresh_stops(custom_state, custom_state.stns[custom_state.stn].stn)
			jr_refresh_departure(custom_state)
			return get_jr_formspec(custom_state)
		end
	end
	if fields.zastavka then
		local event = core.explode_table_event(fields.zastavka)
		if event.type == "CHG" or event.type == "DCL" then
			local new_stop = tonumber(event.row)
			if new_stop ~= nil and new_stop ~= custom_state.stop and custom_state.stops[new_stop] ~= nil then
				custom_state.stop = new_stop
				if event.type == "DCL" then
					jr_refresh_departure(custom_state)
				end
				return get_jr_formspec(custom_state)
			end
		end
	end
	if fields.refresh then
		jr_refresh_departure(custom_state)
		return get_jr_formspec(custom_state)
	end
end

function advtrains.lines.show_jr_formspec(player, pos, stn, track, linevar, stop_stn, force_unprivileged)
	assert(core.is_player(player))
	local custom_state = {
		player_name = player:get_player_name(),
		stn = 1,
		stns = {all_stations_record},
		track = 1,
		tracks = {""},
		linevar = 0,
		linevars = {},
		stop = 0,
		stops = {},
		message = "",
		force_unprivileged = force_unprivileged,
	}
	if pos ~= nil then
		custom_state.pos = pos
	end
	jr_refresh_stns(custom_state, stn)
	jr_refresh_tracks(custom_state, track)
	jr_refresh_linevars(custom_state, linevar)
	if stop_stn == nil then
		stop_stn = custom_state.stns[custom_state.stn].stn
	end
	jr_refresh_stops(custom_state, stop_stn)
	jr_refresh_departure(custom_state)

	-- show formspec:
	return ch_core.show_formspec(player, "advtrains_line_automation:jizdni_rad",
		get_jr_formspec(custom_state), jr_formspec_callback, custom_state, {})
end
