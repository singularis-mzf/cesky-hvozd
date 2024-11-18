-- stoprail.lua
-- adds "stop rail". Recognized by lzb. (part of behavior is implemented there)


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
	local formspec = "formspec_version[4]"..
		"size[8,10]"..
		"item_image[0.25,0.25;1,1;advtrains_line_automation:dtrack_stop_placer]"..
		"label[1.4,0.85;"..minetest.formspec_escape(item_name).."]"..
		"button_exit[7,0.25;0.75,0.75;close;X]"..
		"style[stn,ars,line,routingcode;font=mono]"..
		"field[0.25,2;2,0.75;stn;"..attrans("Station Code")..";"..minetest.formspec_escape(stdata.stn).."]"..
		"field[2.5,2;4,0.75;stnname;"..attrans("Station Name")..";"..minetest.formspec_escape(stnname).."]"..
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
		"field[0.25,6;2,0.75;speed;"..attrans("Dep. Speed")..";"..minetest.formspec_escape(stdata.speed).."]"..
		"field[2.5,6;2,0.75;line;Linka na odj.;"..minetest.formspec_escape(stdata.line or "").."]"..
		"field[4.75,6;2,0.75;routingcode;Sm.kód na odj.;"..minetest.formspec_escape(stdata.routingcode or "").."]"..
		"textarea[0.25,7.25;7.5,1.5;ars;"..attrans("Trains stopping here (ARS rules)")..";"..advtrains.interlocking.ars_to_text(stdata.ars).."]"..
		"button_exit[0.25,9;7.5,0.75;save;"..attrans("Save").."]"..
		"tooltip[close;Zavře dialogové okno]"..
		"tooltip[stn;Vnitřní kód stanice/zastávky pro jednodušší manipulaci. Jedna stanice může mít víc kolejí.]"..
		"tooltip[stnname;Název stanice/zastávky\\, jak má být zobrazován. Pokud stanice/zastávka již existuje, nevyplňujte (stačí zadat kód a kolej)\\, leda chcete zastávku přejmenovat.]"..
		"tooltip[track;Číslo koleje]"..
		"tooltip[wait;Základní doba stání s otevřenými dveřmi]"..
		"tooltip[ddelay;Dodatečná doba stání před odjezdem po uzavření dveří]"..
		"tooltip[speed;Cílová rychlost zastavivšího vlaku na odjezdu. Platné hodnoty jsou M pro nejvyšší rychlost vlaku a čísla 0 až 20.]"..
		"tooltip[line;Nová linka na odjezdu. Prázdné pole = zachovat stávající linku. Pro smazání linky zadejte znak -]"..
		"tooltip[routingcode;Nový směrový kód na odjezdu. Prázdné pole = zachovat stávající směrový kód. Pro smazání kódu vlaku zadejte znak -]"..
		"tooltip[ars;Seznam podmínek\\, z nichž musí vlak splnit alespoň jednu\\, aby zde zastavil:\nLN {linka}\nRC {směrovací kód}\n"..
		"* = jakýkoliv vlak\n\\# komentář]"

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
		if fields.save then
			if fields.stn and stdata.stn ~= fields.stn and fields.stn ~= "" then
				local stn = advtrains.lines.stations[fields.stn]
				if stn then
					if (stn.owner == pname or minetest.check_player_privs(pname, "train_admin")) then
						stdata.stn = fields.stn
					else
						minetest.chat_send_player(pname, attrans("Station code '@1' does already exist and is owned by @2", fields.stn, stn.owner))
						show_stoprailform(pos,player)
						return
					end
				else
					advtrains.lines.stations[fields.stn] = {name = fields.stnname, owner = pname}
					stdata.stn = fields.stn
				end
			end
			local stn = advtrains.lines.stations[stdata.stn]
			if stn and fields.stnname and fields.stnname ~= stn.name and (stn.name == nil or stn.name == "" or fields.stnname ~= "") then
				if (stn.owner == pname or minetest.check_player_privs(pname, "train_admin")) then
					stn.name = fields.stnname
				else
					minetest.chat_send_player(pname, attrans("Not allowed to edit station name, owned by @1", stn.owner))
				end
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
			show_stoprailform(pos, player)
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
								-- DEBUG:
								-- minetest.chat_send_all("DEBUG: Train approaches to "..minetest.pos_to_string(pos).."!")
								-- print("DEBUG: train approaches to "..minetest.pos_to_string(pos).." = "..dump2({train = train, stdata = stdata, pe = pe, pos = pos, index = index, has_entered = has_entered}))
							end
						end
					end
				end,
				on_train_enter = function(pos, train_id, train, index)
					-- print("DEBUG: on_train_enter called: "..dump2({pos = pos, train_id = train_id, index = index}))
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
