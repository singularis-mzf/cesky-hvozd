-- stoprail.lua
-- adds "stop rail". Recognized by lzb. (part of behavior is implemented there)

local rwt = assert(advtrains.lines.rwt)

local function to_int(n)
	--- Disallow floating-point numbers
	local k = tonumber(n)
	if k then
		return math.floor(k)
	end
end

local function updatemeta(pos)
	local meta = minetest.get_meta(pos)
	local pe = advtrains.encode_pos(pos)
	local stdata = advtrains.lines.stops[pe]
	if not stdata then
		meta:set_string("infotext", attrans("Error"))
	end
	local stn = advtrains.lines.stations[stdata.stn]
	local stn_viewname = stn and stn.name or "-"
	
	meta:set_string("infotext", attrans("Stn. @1 (@2) T. @3", stn_viewname, stdata.stn or "", stdata.track or ""))
end

local door_dropdown = {L=1, R=2, C=3}
local door_dropdown_rev = {["vpravo"]="R", ["vlevo"]="L", ["neotvírat"]="C"}

local function get_stn_dropdown(stn, player_name)
	local stations = advtrains.lines.load_stations_for_formspec()
	local selected_index
	local result = {"dropdown[0.25,2;6,0.75;stn;(nepřiřazeno)"}
	local right_mark
	for i, st in ipairs(stations) do
		if player_name ~= nil and player_name ~= st.owner then
			right_mark = "(cizí) "
		else
			right_mark = ""
		end
		table.insert(result, ","..right_mark..minetest.formspec_escape(st.stn.."  |  "..st.name))
		if st.stn == stn then
			selected_index = i + 1
		end
	end
	table.insert(result, ";"..(selected_index or "1")..";true]")
	return table.concat(result)
end

local player_to_stn_override = {}

local function show_stoprailform(pos, player)
	local pe = advtrains.encode_pos(pos)
	local pname = player:get_player_name()
	if minetest.is_protected(pos, pname) then
		minetest.chat_send_player(pname, attrans("Position is protected!"))
		return
	end
	
	local stdata = advtrains.lines.stops[pe]
	if not stdata then
		advtrains.lines.stops[pe] = {
					stn="", track="", doors="R", wait=10, ars={default=true}, ddelay=1,speed="M"
				}
		stdata = advtrains.lines.stops[pe]
	end
	
	local stn = advtrains.lines.stations[stdata.stn]
	local stnname = stn and stn.name or ""
	if not stdata.ddelay then
		stdata.ddelay = 1
	end
	if not stdata.speed then
		stdata.speed = "M"
	end
	
	local item_name = (minetest.registered_items["advtrains_line_automation:dtrack_stop_placer"] or {}).description or ""
	local pname_unless_admin
	if not minetest.check_player_privs(pname, "train_admin") then
		pname_unless_admin = pname
	end
	local formspec = "formspec_version[4]"..
		"size[8,12]"..
		"item_image[0.25,0.25;1,1;advtrains_line_automation:dtrack_stop_placer]"..
		"textarea[1.35,0.6;5.5,0.6;;;"..minetest.formspec_escape(string.format("%s %d,%d,%d", item_name, pos.x, pos.y, pos.z)).."]"..
		"button_exit[7,0.25;0.75,0.75;close;X]"..
		"style[ars,line,routingcode;font=mono]"..
		"label[0.25,1.75;"..attrans("Station Code").." | "..attrans("Station Name").."]"..
		get_stn_dropdown(player_to_stn_override[pname] or stdata.stn, pname_unless_admin)..
		"field[6.75,2;1,0.75;track;"..attrans("Track")..";"..minetest.formspec_escape(stdata.track).."]"..
		"label[0.25,3.4;"..attrans("Door Side").."]"..
		"dropdown[2.25,3;2,0.75;doors;vlevo,vpravo,neotvírat;"..door_dropdown[stdata.doors].."]"..
		"checkbox[4.5,3.25;reverse;"..attrans("Reverse train")..";"..(stdata.reverse and "true" or "false").."]"..
		"checkbox[4.5,3.75;kick;"..attrans("Kick out passengers")..";"..(stdata.kick and "true" or "false").."]"..
		"checkbox[4.5,4.25;keepopen;Nezavírat dveře na odj.;"..(stdata.keepopen and "true" or "false").."]"..
		"label[0.25,4.3;"..attrans("Stop Time").."]"..
		"field[0.25,4.5;1,0.75;wait;;"..stdata.wait.."]"..
		"label[1.5,4.9;+]"..
		"field[2,4.5;1,0.75;ddelay;;"..minetest.formspec_escape(stdata.ddelay).."]".. -- "..attrans("Door Delay").."
		(advtrains.lines.open_station_editor ~= nil and "button[3.5,4.5;4,0.75;editstn;Editor dopraven]" or "")..
		"field[0.25,6;2,0.75;speed;"..attrans("Dep. Speed")..";"..minetest.formspec_escape(stdata.speed).."]"..
		"field[2.5,6;2,0.75;line;Linka na odj.;"..minetest.formspec_escape(stdata.line or "").."]"..
		"field[4.75,6;2,0.75;routingcode;Sm.kód na odj.;"..minetest.formspec_escape(stdata.routingcode or "").."]"..
		"field[0.25,7.25;2,0.75;interval;Interval \\[s\\]:;"..minetest.formspec_escape(stdata.interval or "").."]"..
		"field[2.5,7.25;2,0.75;ioffset;Jeho posun:;"..minetest.formspec_escape(stdata.ioffset or "0").."]"..
		"button[4.75,7;3,1.0;ioffsetnow;Nastavit posun\nna odjezd teď + uložit]"..
		"textarea[0.25,8.4;7.5,1.5;ars;"..attrans("Trains stopping here (ARS rules)")..";"..advtrains.interlocking.ars_to_text(stdata.ars).."]"..
		"label[0.3,10.25;Platí jen pro vlaky s]"..
		"field[3,10;1,0.5;minparts;;"..minetest.formspec_escape(stdata.minparts or "0").."]"..
		"label[4.15,10.25;až]"..
		"field[4.6,10;1,0.5;maxparts;;"..minetest.formspec_escape(stdata.maxparts or "128").."]"..
		"label[5.75,10.25;vozy.]"..
		"button_exit[0.25,11;7.5,0.75;save;"..attrans("Save").."]"..
		"tooltip[close;Zavře dialogové okno]"..
		"tooltip[stn;Dopravna\\, ke které tato zastávka patří. Jedna dopravna může mít víc kolejí. K vytvoření a úpravám dopraven použijte Editor dopraven.]"..
		"tooltip[track;Číslo koleje]"..
		"tooltip[wait;Základní doba stání s otevřenými dveřmi]"..
		"tooltip[ddelay;Dodatečná doba stání před odjezdem po uzavření dveří]"..
		"tooltip[speed;Cílová rychlost zastavivšího vlaku na odjezdu. Platné hodnoty jsou M pro nejvyšší rychlost vlaku a čísla 0 až 20.]"..
		"tooltip[line;Nová linka na odjezdu. Prázdné pole = zachovat stávající linku. Pro smazání linky zadejte znak -]"..
		"tooltip[routingcode;Nový směrový kód na odjezdu. Prázdné pole = zachovat stávající směrový kód. Pro smazání kódu vlaku zadejte znak -]"..
		"tooltip[ars;Seznam podmínek\\, z nichž musí vlak splnit alespoň jednu\\, aby zde zastavil:\nLN {linka}\nRC {směrovací kód}\n"..
		"* = jakýkoliv vlak\n\\# značí komentář a ! na začátku řádky danou podmínku neguje (nedoporučuje se)]"..
		"tooltip[minparts;Minimální počet vozů\\, které musí vlak mít\\, aby zde zastavil. Výchozí hodnota je 0.]"..
		"tooltip[maxparts;Maximální počet vozů\\, které vlak může mít\\, aby zde zastavil. Výchozí (a maximální) hodnota je 128.]"..
		"tooltip[editsn;Otevře v novém okně editor dopraven.\nPoužijte tento editor pro založení nové dopravny\\, jíž budete moci přiřadit koleje.]"..
		"tooltip[interval;Hodnota v sekundách 1 až 3600 nebo nevyplněno. Je-li vyplněno\\, rozdělí čas na intervaly zadané délky,\n"..
		"a pokud z této zastávkové koleje v rámci jednoho z nich odjede vlak\\, odjezd dalšího bude pozdržen do začátku\n"..
		"následujícího intervalu. Výchozí začátky intervalů stejné délky jsou v celé železniční síti společné.\n"..
		"Slouží k nastavení intervalového provozu.]"..
		"tooltip[ioffset;Hodnota v sekundách 0 až (interval - 1). Posune začátek intervalů oproti výchozímu stavu\n"..
		"o zadaný počet sekund vpřed. Slouží k detailnímu vyladění času odjezdů relativně vůči ostatním linkám.]"..
		"tooltip[ioffsetnow;Nastaví posun intervalu tak\\, aby pro tuto kolej nový interval začínal právě teď.\n"..
		"Také uloží ostatní provedené změny.]"


	minetest.show_formspec(pname, "at_lines_stop_"..pe, formspec)
end
local tmp_checkboxes = {}
minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pname = player:get_player_name()
	local pe = string.match(formname, "^at_lines_stop_(............)$")
	local pos = advtrains.decode_pos(pe)
	if pos then
		if minetest.is_protected(pos, pname) then
			minetest.chat_send_player(pname, attrans("Position is protected!"))
			return
		end
		
		local stdata = advtrains.lines.stops[pe]
		if not tmp_checkboxes[pe] then
			tmp_checkboxes[pe] = {}
		end
		if fields.kick then			-- handle checkboxes due to MT's weird handling
			tmp_checkboxes[pe].kick = (fields.kick == "true")
		end
		if fields.reverse then
			tmp_checkboxes[pe].reverse = (fields.reverse == "true")
		end
		if fields.keepopen then
			tmp_checkboxes[pe].keepopen = (fields.keepopen == "true")
		end

		if fields.stn then
			local new_index = tonumber(fields.stn)
			if new_index ~= nil then
				player_to_stn_override[pname] = new_index
			end
		end

		local set_offset

		if fields.ioffsetnow and fields.interval ~= "" and fields.interval ~= "0" then
			local interval = to_int(fields.interval)
			if 0 < interval and interval <= 3600 then
				local rwtime = rwt.to_secs(rwt.get_time())
				set_offset = rwtime % interval
			end
		end

		if fields.save or set_offset ~= nil then
			local new_index = player_to_stn_override[pname]
			if new_index ~= nil then
				if new_index == 1 then
					-- no name station
					stdata.stn = ""
					minetest.log("action", pname.." set track at "..minetest.pos_to_string(pos).." to no station.")
				else
					local stations = advtrains.lines.load_stations_for_formspec()
					local station = stations[new_index - 1]
					if station ~= nil then
						if station.owner == pname or minetest.check_player_privs(pname, "train_admin") then
							stdata.stn = station.stn
							minetest.log("action", pname.." set track at "..minetest.pos_to_string(pos).." to station '"..tostring(station.stn).."'.")
						else
							minetest.chat_send_player(pname, attrans("Station code '@1' does already exist and is owned by @2", station.stn, station.owner))
							show_stoprailform(pos,player)
							return
						end
					end
				end
				player_to_stn_override[pname] = nil
			end

			-- dropdowns
			if fields.doors then
				stdata.doors = door_dropdown_rev[fields.doors] or "C"
			end
			
			if fields.track then
				stdata.track = fields.track
			end
			if fields.wait then
				stdata.wait = to_int(fields.wait) or 10
			end
			
			if fields.ars then
				stdata.ars = advtrains.interlocking.text_to_ars(fields.ars)
			end

			if fields.ddelay then
				stdata.ddelay = to_int(fields.ddelay) or 1
			end
			if fields.speed then
				stdata.speed = to_int(fields.speed) or "M"
			end
			if fields.line then
				stdata.line = fields.line
			end
			if fields.routingcode then
				stdata.routingcode = fields.routingcode
			end
			if fields.minparts then
				local v = to_int(fields.minparts)
				if v <= 0 or v > 128 then v = nil end
				stdata.minparts = v
			end
			if fields.maxparts then
				local v = to_int(fields.maxparts)
				if v <= 0 or v > 128 then v = nil end
				stdata.maxparts = v
			end
			if fields.interval then
				if fields.interval == "" or fields.interval == "0" then
					stdata.interval = nil
				else
					local n = to_int(fields.interval)
					if 0 < n and n <= 3600 then
						stdata.interval = n
					end
				end
			end
			if stdata.interval == nil then
				stdata.ioffset = nil
			elseif set_offset ~= nil then
				stdata.ioffset = set_offset
			elseif fields.ioffset then
				if fields.ioffset == "" or fields.ioffset == "0" then
					stdata.ioffset = nil
				else
					local n = to_int(fields.ioffset)
					if n > 0 then
						stdata.ioffset = n % stdata.interval
					else
						stdata.ioffset = nil
					end
				end
			end

			for k,v in pairs(tmp_checkboxes[pe]) do --handle checkboxes
				stdata[k] = v or nil
			end
			tmp_checkboxes[pe] = nil
			--TODO: signal
			updatemeta(pos)
			minetest.log("action", pname.." saved stoprail at "..minetest.pos_to_string(pos))
			show_stoprailform(pos, player)
		elseif fields.editstn and advtrains.lines.open_station_editor ~= nil then
			minetest.close_formspec(pname, formname)
			minetest.after(0.25, advtrains.lines.open_station_editor, player)
			return
		end
	end			
	
end)

local adefunc = function(def, preset, suffix, rotation)
		return {
			after_place_node=function(pos)
				local pe = advtrains.encode_pos(pos)
				advtrains.lines.stops[pe] = {
					stn="", track="", doors="R", wait=10
				}
				updatemeta(pos)
			end,
			after_dig_node=function(pos)
				local pe = advtrains.encode_pos(pos)
				advtrains.lines.stops[pe] = nil
			end,
			on_punch = function(pos, node, puncher, pointed_thing)
				updatemeta(pos)
			end,
			on_rightclick = function(pos, node, player)
				if minetest.is_player(player) then
					player_to_stn_override[player:get_player_name()] = nil
				end
				show_stoprailform(pos, player)
			end,
			advtrains = {
				on_train_approach = advtrains.lines.on_train_approach,
				on_train_enter = advtrains.lines.on_train_enter,
				on_train_leave = advtrains.lines.on_train_leave,
			},
		}
end

advtrains.station_stop_rail_additional_definition = adefunc -- HACK for tieless_tracks

minetest.register_lbm({
	label = "Update line track metadata",
	name = "advtrains_line_automation:update_metadata",
	nodenames = {
		"advtrains_line_automation:dtrack_stop_st",
		"advtrains_line_automation:dtrack_stop_st_30",
		"advtrains_line_automation:dtrack_stop_st_45",
		"advtrains_line_automation:dtrack_stop_st_60",
		"advtrains_line_automation:dtrack_stop_tieless_st",
		"advtrains_line_automation:dtrack_stop_tieless_st_30",
		"advtrains_line_automation:dtrack_stop_tieless_st_40",
		"advtrains_line_automation:dtrack_stop_tieless_st_60",
	},
	run_at_every_load = true,
	action = updatemeta,
})

if minetest.get_modpath("advtrains_train_track") ~= nil then
	advtrains.register_tracks("default", {
		nodename_prefix="advtrains_line_automation:dtrack_stop",
		texture_prefix="advtrains_dtrack_stop",
		models_prefix="advtrains_dtrack",
		models_suffix=".b3d",
		shared_texture="advtrains_dtrack_shared_stop.png",
		description=attrans("Station/Stop Rail"),
		formats={},
		get_additional_definiton = adefunc,
	}, advtrains.trackpresets.t_30deg_straightonly)

	minetest.register_craft({
		output = "advtrains_line_automation:dtrack_stop_placer 2",
		recipe = {
			{"default:coal_lump", ""},
			{"advtrains:dtrack_placer", "advtrains:dtrack_placer"},
		},
	})
end
