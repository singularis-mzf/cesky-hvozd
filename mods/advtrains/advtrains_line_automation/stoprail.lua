-- stoprail.lua
-- adds "stop rail". Recognized by lzb. (part of behavior is implemented there)

function advtrains.lines.load_stations_for_formspec()
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
		"size[8,10]"..
		"item_image[0.25,0.25;1,1;advtrains_line_automation:dtrack_stop_placer]"..
		"label[1.4,0.85;"..minetest.formspec_escape(item_name).."]"..
		"button_exit[7,0.25;0.75,0.75;close;X]"..
		"style[ars,line,routingcode;font=mono]"..
		"label[0.25,1.75;"..attrans("Station Code").." | "..attrans("Station Name").."]"..
		get_stn_dropdown(player_to_stn_override[pname] or stdata.stn, pname_unless_admin)..
		--[[
		"field[0.25,2;2,0.75;stn;"..attrans("Station Code")..";"..minetest.formspec_escape(stdata.stn).."]"..
		"field[2.5,2;4,0.75;stnname;"..attrans("Station Name")..";"..minetest.formspec_escape(stnname).."]"..
		]]
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
		"textarea[0.25,7.25;7.5,1.5;ars;"..attrans("Trains stopping here (ARS rules)")..";"..advtrains.interlocking.ars_to_text(stdata.ars).."]"..
		"button_exit[0.25,9;7.5,0.75;save;"..attrans("Save").."]"..
		"tooltip[close;Zavře dialogové okno]"..
		"tooltip[stn;Dopravna\\, ke které tato zastávka patří. Jedna dopravna může mít víc kolejí. K vytvoření a úpravám dopraven použijte Editor dopraven.]"..
		"tooltip[track;Číslo koleje]"..
		"tooltip[wait;Základní doba stání s otevřenými dveřmi]"..
		"tooltip[ddelay;Dodatečná doba stání před odjezdem po uzavření dveří]"..
		"tooltip[speed;Cílová rychlost zastavivšího vlaku na odjezdu. Platné hodnoty jsou M pro nejvyšší rychlost vlaku a čísla 0 až 20.]"..
		"tooltip[line;Nová linka na odjezdu. Prázdné pole = zachovat stávající linku. Pro smazání linky zadejte znak -]"..
		"tooltip[routingcode;Nový směrový kód na odjezdu. Prázdné pole = zachovat stávající směrový kód. Pro smazání kódu vlaku zadejte znak -]"..
		"tooltip[ars;Seznam podmínek\\, z nichž musí vlak splnit alespoň jednu\\, aby zde zastavil:\nLN {linka}\nRC {směrovací kód}\n"..
		"* = jakýkoliv vlak\n\\# značí komentář a ! na začátku řádky danou podmínku neguje (nedoporučuje se)]"

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

		if fields.save then
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
				on_train_approach = function(pos,train_id, train, index, has_entered)
					if has_entered then return end -- do not stop again!
					if train.path_cn[index] == 1 then
						local pe = advtrains.encode_pos(pos)
						local stdata = advtrains.lines.stops[pe]
						if stdata and stdata.stn then
						
							--TODO REMOVE AFTER SOME TIME (only migration)
							if not stdata.ars then
								stdata.ars = {default=true}
							end
							if stdata.ars and (stdata.ars.default or advtrains.interlocking.ars_check_rule_match(stdata.ars, train) ) then
								advtrains.lzb_add_checkpoint(train, index, 2, nil)
								local stn = advtrains.lines.stations[stdata.stn]
								local stnname = stn and stn.name or attrans("Unknown Station")
								train.text_inside = attrans("Next Stop:") .. "\n"..stnname
								advtrains.interlocking.ars_set_disable(train, true)
							end
						end
					end
				end,
				on_train_enter = function(pos, train_id, train, index)
					if train.path_cn[index] == 1 then
						local pe = advtrains.encode_pos(pos)
						local stdata = advtrains.lines.stops[pe]
						if not stdata then
							return
						end
						
						if stdata.ars and (stdata.ars.default or advtrains.interlocking.ars_check_rule_match(stdata.ars, train) ) then
							local stn = advtrains.lines.stations[stdata.stn]
							local stnname = stn and stn.name or attrans("Unknown Station")
							local line, routingcode = stdata.line or "", stdata.routingcode or ""
							
							-- Send ATC command and set text
							advtrains.atc.train_set_command(train, "B0 W O"..stdata.doors..(stdata.kick and "K" or "").." D"..stdata.wait..
								(stdata.keepopen and " " or " OC ")..(stdata.reverse and "R" or "").." D"..(stdata.ddelay or 1)..
								" A1 S" ..(stdata.speed or "M"), true)
							train.text_inside = stnname
							if line == "-" then
								train.line = nil
							elseif line ~= "" then
								train.line = line
							end
							if routingcode == "-" then
								train.routingcode = nil
							elseif routingcode ~= "" then
								train.routingcode = routingcode
							end
							if tonumber(stdata.wait) then
								minetest.after(tonumber(stdata.wait), function() train.text_inside = "" end)
							end
						end
					end
				end
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
