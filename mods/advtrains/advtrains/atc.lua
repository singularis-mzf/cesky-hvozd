--atc.lua
--registers and controls the ATC system

local atc={}

local eval_conditional

-- ATC persistence table. advtrains.atc is created by init.lua when it loads the save file.
atc.controllers = {}
function atc.load_data(data)
	local temp = data and data.controllers or {}
	--transcode atc controller data to node hashes: table access times for numbers are far less than for strings
	for pts, data in pairs(temp) do
		if type(pts)=="number" then
			pts=minetest.pos_to_string(minetest.get_position_from_hash(pts))
		end
		atc.controllers[pts] = data
	end
end
function atc.save_data()
	return {controllers = atc.controllers}
end
--contents: {command="...", arrowconn=0-15 where arrow points}

--general
function atc.train_set_command(train, command, arrow)
	atc.train_reset_command(train, true)
	train.atc_delay = 0
	train.atc_arrow = arrow
	train.atc_command = command
end

function atc.send_command(pos, par_tid)
	local pts=minetest.pos_to_string(pos)
	if atc.controllers[pts] then
		--atprint("Called send_command at "..pts)
		local train_id = par_tid or advtrains.get_train_at_pos(pos)
		if train_id then
			if advtrains.trains[train_id] then
				--atprint("send_command inside if: "..sid(train_id))
				if atc.controllers[pts].arrowconn then
					atlog("ATC controller at",pts,": This controller had an arrowconn of", atc.controllers[pts].arrowconn, "set. Since this field is now deprecated, it was removed.")
					atc.controllers[pts].arrowconn = nil
				end
				
				local train = advtrains.trains[train_id]
				local index = advtrains.path_lookup(train, pos)
				
				local iconnid = 1
				if index then
					iconnid = train.path_cn[index]
				else
					atwarn("ATC rail at", pos, ": Rail not on train's path! Can't determine arrow direction. Assuming +!")
				end
				
				local command = atc.controllers[pts].command				
				command = eval_conditional(command, iconnid==1, train.velocity)
				if not command then command="" end
				command=string.match(command, "^%s*(.*)$")
				
				if command == "" then
					atprint("Sending ATC Command to", train_id, ": Not modifying, conditional evaluated empty.")
					return true
				end
				
				atc.train_set_command(train, command, iconnid==1)
				atprint("Sending ATC Command to", train_id, ":", command, "iconnid=",iconnid)
				return true
				
			else
				atwarn("ATC rail at", pos, ": Sending command failed: The train",train_id,"does not exist. This seems to be a bug.")
			end
		else
			atwarn("ATC rail at", pos, ": Sending command failed: There's no train at this position. This seems to be a bug.")
			-- huch
			--local train = advtrains.trains[train_id_temp_debug]
			--atlog("Train speed is",train.velocity,", have moved",train.dist_moved_this_step,", lever",train.lever)
			--advtrains.path_print(train, atlog)
			-- TODO track again when ATC bugs occur...
			
		end
	else
		atwarn("ATC rail at", pos, ": Sending command failed: Entry for controller not found.")
		atwarn("ATC rail at", pos, ": Please visit controller and click 'Save'")
	end
	return false
end

-- Resets any ATC commands the train is currently executing, including the target speed (tarvelocity) it is instructed to hold
-- if keep_tarvel is set, does not clear the tarvelocity
function atc.train_reset_command(train, keep_tarvel)
	train.atc_command=nil
	train.atc_delay=nil
	train.atc_brake_target=nil
	train.atc_wait_finish=nil
	train.atc_wait_autocouple=nil
	train.atc_arrow=nil
	if not keep_tarvel then
		train.tarvelocity=nil
	end
end

--nodes
local idxtrans={static=1, mesecon=2, digiline=3}
local apn_func=function(pos)
	-- FIX for long-persisting ndb bug: there's no node in parameter 2 of this function!
	local meta=minetest.get_meta(pos)
	if meta then
		meta:set_string("infotext", attrans("ATC controller, unconfigured."))
		-- meta:set_string("formspec", atc.get_atc_controller_formspec(pos, meta))
	end
end

-- formspec and callback:

local function get_custom_state(pos)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	return {
		pos = pos,
		node_name_f = minetest.formspec_escape(node.name),
		mode = tonumber(meta:get_string("mode")) or 1,
		command = meta:get_string("command"),
		command_on = meta:get_string("command_on"),
		channel = meta:get_string("channel"),
		line = meta:get_string("line"),
		routingcode = meta:get_string("routingcode"),
		text_inside = meta:get_string("text_inside"),
		text_outside = meta:get_string("text_outside"),
		ars = meta:get_string("ars"),
	}
end

local function get_formspec(custom_state)
	local F = minetest.formspec_escape
	local formspec = {
		ch_core.formspec_header({
			formspec_version = 6,
			size = {12,12.75},
			auto_background = true,
		}),
		"style[command,command_on;font=mono]"..
		"item_image[0.25,0.25;1,1;"..custom_state.node_name_f.."]"..
		"label[1.4,0.85;řídicí obvod ATC]"..
		"button_exit[11,0.25;0.75,0.75;close;X]"..
		"field[0.25,4.25;11.5,0.75;text_inside;nový text uvnitř:;"..F(custom_state.text_inside).."]"..
		"field[0.25,5.5;11.5,0.75;text_outside;nový text venku:;"..F(custom_state.text_outside).."]"..
		"field[0.25,6.75;3,0.75;line;nová linka:;"..F(custom_state.line).."]"..
		"field[0.25,8;3,0.75;routingcode;nový směr. kód:;"..F(custom_state.routingcode).."]"..
		"textarea[0.25,9.25;3,2.25;ars;vlaky\\, pro které platí:;"..F(custom_state.ars).."]"..
		"label[3.5,6.55;nápověda:]"..
		"tablecolumns[text;text]"..
		"table[3.5,6.75;8.25,4.75;atc_help;S{0-20|M},Zpomalí/zrychlí na zadanou rychlost,SM,Zrychlí na maximální rychlost,"..
		"B{0-20},Zpomalí na zadanou rychlost,W,Počká na dosažení cílové rychlosti,D{0-...},Počká zadaný počet sekund,"..
		"R,Pokud vlak stojí\\, obrátí směr jízdy,OL,Otevře levé dveře,OR,Otevře pravé dveře,OC,Zavře všechny dveře,"..
		"K,Vyhodí cestující (ne strojvedoucí/ho),Cpl,Počkat na náraz do vagonu a připojit ho,"..
		"A0,Vypne ARS,A1,Zapne ARS,I+ {...}\\;,Vykonat\\, pokud jede vlak po směru šipky,"..
		"I- {...}\\;,Nevykonat (ř.obvod je jednosměrný),I<{0-20} {...}\\;,Vykonat\\, je-li rychlost menší než uvedená"..
		",,(analogicky pro op. <=\\, >= a >);]",
		"button_exit[0.25,11.75;11.5,0.75;save;Uložit]"..
		"tooltip[line;Nová linka na odjezdu. Prázdné pole = zachovat stávající linku. Pro smazání linky zadejte znak -]"..
		"tooltip[routingcode;Nový směrový kód na odjezdu. Prázdné pole = zachovat stávající směrový kód. Pro smazání kódu vlaku zadejte znak -]"..
		"tooltip[text_inside;Nastavit text uvnitř vlaku. Prázdné pole = zachovat stávající. - = smazat]"..
		"tooltip[text_outside;Nastavit text vně vlaku. Prázdné pole = zachovat stávající. - = smazat]"..
		"tooltip[ars;Seznam podmínek\\, z nichž musí vlak splnit alespoň jednu\\, aby zde zastavil:\nLN {linka}\nRC {směrovací kód}\n"..
		"* = jakýkoliv vlak\n\\# komentář]",
	}
	if custom_state.mode < 3 then
		table.insert(formspec, "field[0.25,1.75;11.5,0.75;command;program:;"..F(custom_state.command).."]")
		if custom_state.mode == 2 then
			table.insert(formspec, "field[0.25,3;11.5,0.75;command_on;program (při signálu):;"..F(custom_state.command_on).."]")
		end
	else
		table.insert(formspec, "field[0.25,1.75;11.5,0.75;channel;"..attrans("Digiline channel")..";"..F(custom_state.channel).."]")
	end
	return table.concat(formspec)
end

local function formspec_callback(custom_state, player, formname, fields)
	local pos = custom_state.pos
	if advtrains.is_protected(pos, player:get_player_name()) then
		minetest.record_protection_violation(pos, player:get_player_name())
		return
	end

	if fields.command ~= nil then custom_state.command = fields.command end
	if fields.command_on ~= nil then custom_state.command_on = fields.command_on end
	if fields.line ~= nil then custom_state.line = fields.line end
	if fields.routingcode ~= nil then custom_state.routingcode = fields.routingcode end
	if fields.text_inside ~= nil then custom_state.text_inside = fields.text_inside end
	if fields.text_outside ~= nil then custom_state.text_outside = fields.text_outside end
	if fields.ars ~= nil then custom_state.ars = fields.ars end
	if fields.channel ~= nil then custom_state.channel = fields.channel end

	local meta=minetest.get_meta(pos)
	if meta then
		if not fields.save then 
			--[[--maybe only the dropdown changed
			if fields.mode then
				meta:set_string("mode", idxtrans[fields.mode])
				if fields.mode=="digiline" then
					meta:set_string("infotext", attrans("ATC controller, mode @1\nChannel: @2", fields.mode, meta:get_string("command")) )
				else
					meta:set_string("infotext", attrans("ATC controller, mode @1\nCommand: @2", fields.mode, meta:get_string("command")) )
				end
				meta:set_string("formspec", atc.get_atc_controller_formspec(pos, meta))
			end]]--
			return
		end
		if custom_state.ars == "" then custom_state.ars = "*" end
		--meta:set_string("mode", idxtrans[fields.mode])
		meta:set_string("command", custom_state.command)
		--meta:set_string("command_on", fields.command_on)
		meta:set_string("channel", custom_state.channel)
		meta:set_string("line", custom_state.line)
		meta:set_string("routingcode", custom_state.routingcode)
		meta:set_string("text_inside", custom_state.text_inside)
		meta:set_string("text_outside", custom_state.text_outside)
		meta:set_string("ars", custom_state.ars)
		--if fields.mode=="digiline" then
		--	meta:set_string("infotext", attrans("ATC controller, mode @1\nChannel: @2", fields.mode, meta:get_string("command")) )
		--else
		meta:set_string("infotext", attrans("ATC controller, mode @1\nCommand: @2", "-", meta:get_string("command")) )
		--end
		-- meta:set_string("formspec", atc.get_atc_controller_formspec(pos, meta))
		
		local pts=minetest.pos_to_string(pos)
		local _, conns=advtrains.get_rail_info_at(pos, advtrains.all_tracktypes)
		atc.controllers[pts]={command=fields.command}
		if #advtrains.occ.get_trains_at(pos) > 0 then
			atc.send_command(pos)
		end
	end
end

advtrains.atc_function = function(def, preset, suffix, rotation)
		return {
			after_place_node=apn_func,
			after_dig_node=function(pos)
				advtrains.invalidate_all_paths(pos)
				advtrains.ndb.clear(pos)
				local pts=minetest.pos_to_string(pos)
				atc.controllers[pts]=nil
			end,
			on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
				if advtrains.is_protected(pos, clicker:get_player_name()) then
					minetest.record_protection_violation(pos, clicker:get_player_name())
					return
				end
				local custom_state = get_custom_state(pos)
				ch_core.show_formspec(clicker, "advtrains:atc", get_formspec(custom_state), formspec_callback, custom_state, {})
			end,
			advtrains = {
				on_train_enter = function(pos, train_id, train, index)
					if train.path_cn[index] ~= 1 then
						return -- opposite direction
					end
					local meta = minetest.get_meta(pos)
					if advtrains.interlocking ~= nil then
						local ars = meta:get_string("ars")
					 	ars = advtrains.interlocking.text_to_ars(ars) or {default = true}
						if not (ars.default or advtrains.interlocking.ars_check_rule_match(ars, train)) then
							return -- ARS does not match
						end
					end
					local function apply_change(old_value, change)
						if change == "-" then return nil elseif change == "" then return old_value else return change end
					end
					train.line = apply_change(train.line, meta:get_string("line"))
					train.routingcode = apply_change(train.routingcode, meta:get_string("routingcode"))
					train.text_inside = apply_change(train.text_inside, meta:get_string("text_inside"))
					train.text_outside = apply_change(train.text_outside, meta:get_string("text_outside"))
					atc.send_command(pos, train_id)
				end,
			},
		}
end

--from trainlogic.lua train step
local matchptn={
	["SM"]=function(id, train)
		train.tarvelocity=train.max_speed
		return 2
	end,
	["S([0-9]+)"]=function(id, train, match)
		train.tarvelocity=tonumber(match)
		return #match+1
	end,
	["B([0-9]+)"]=function(id, train, match)
		local btar = tonumber(match)
		if train.velocity>btar then
			train.atc_brake_target=btar
			if not train.tarvelocity or train.tarvelocity>btar then
				train.tarvelocity=btar
			end
		else
			-- independent of brake target, must make sure that tarvelocity is not greater than it
			if train.tarvelocity and train.tarvelocity>btar then
				train.tarvelocity=btar
			end
		end
		return #match+1
	end,
	["BB"]=function(id, train)
		train.atc_brake_target = -1
		train.tarvelocity = 0
		return 2
	end,
	["W"]=function(id, train)
		train.atc_wait_finish=true
		return 1
	end,
	["D([0-9]+)"]=function(id, train, match)
		train.atc_delay=tonumber(match)
		return #match+1
	end,
	["R"]=function(id, train)
		if train.velocity<=0 then
			advtrains.invert_train(id)
			advtrains.train_ensure_init(id, train)
			-- no one minds if this failed... this shouldn't even be called without train being initialized...
		else
			atwarn(sid(id), attrans("ATC Reverse command warning: didn't reverse train, train moving!"))
		end
		return 1
	end,
	["O([LRC])"]=function(id, train, match)
		local tt={L=-1, R=1, C=0}
		local arr=train.atc_arrow and 1 or -1
		train.door_open = tt[match]*arr
		return 2
	end,
	["K"] = function(id, train)
		if train.door_open == 0 then
			atwarn(sid(id), attrans("ATC Kick command warning: Doors closed"))
			return 1
		end
		if train.velocity > 0 then
			atwarn(sid(id), attrans("ATC Kick command warning: Train moving"))
			return 1
		end
		local tp = train.trainparts
		for i=1,#tp do
			local data = advtrains.wagons[tp[i]]
			local obj = advtrains.wagon_objects[tp[i]]
			if data and obj then
				local ent = obj:get_luaentity()
				if ent then
					for seatno,seat in pairs(ent.seats) do
						if data.seatp[seatno] and not ent:is_driver_stand(seat) then
							ent:get_off(seatno)
						end
					end
				end
			end
		end
		return 1
	end,
	["A([01])"]=function(id, train, match)
		if not advtrains.interlocking then return 2 end
		advtrains.interlocking.ars_set_disable(train, match=="0")
		return 2
	end,
	["Cpl"]=function(id, train)
		train.atc_wait_autocouple=true
		return 3
	end,
}

eval_conditional = function(command, arrow, speed)
	--conditional statement?
	local is_cond, cond_applies, compare
	local cond, rest=string.match(command, "^I([%+%-])(.+)$")
	if cond then
		is_cond=true
		if cond=="+" then
			cond_applies=arrow
		end
		if cond=="-" then
			cond_applies=not arrow
		end
	else 
		cond, compare, rest=string.match(command, "^I([<>]=?)([0-9]+)(.+)$")
		if cond and compare then
			is_cond=true
			if cond=="<" then
				cond_applies=speed<tonumber(compare)
			end
			if cond==">" then
				cond_applies=speed>tonumber(compare)
			end
			if cond=="<=" then
				cond_applies=speed<=tonumber(compare)
			end
			if cond==">=" then
				cond_applies=speed>=tonumber(compare)
			end
		end
	end	
	if is_cond then
		atprint("Evaluating if statement: "..command)
		atprint("Cond: "..(cond or "nil"))
		atprint("Applies: "..(cond_applies and "true" or "false"))
		atprint("Rest: "..rest)
		--find end of conditional statement
		local nest, pos, elsepos=0, 1
		while nest>=0 do
			if pos>#rest then
				atwarn(sid(id), attrans("ATC command syntax error: I statement not closed: @1",command))
				return ""
			end
			local char=string.sub(rest, pos, pos)
			if char=="I" then
				nest=nest+1
			end
			if char==";" then
				nest=nest-1
			end
			if nest==0 and char=="E" then
				elsepos=pos+0
			end
			pos=pos+1
		end
		if not elsepos then elsepos=pos-1 end
		if cond_applies then
			command=string.sub(rest, 1, elsepos-1)..string.sub(rest, pos)
		else
			command=string.sub(rest, elsepos+1, pos-2)..string.sub(rest, pos)
		end
		atprint("Result: "..command)
	end
	return command
end

function atc.execute_atc_command(id, train)
	--strip whitespaces
	local command=string.match(train.atc_command, "^%s*(.*)$")
	
	
	if string.match(command, "^%s*$") then
		train.atc_command=nil
		return
	end

	train.atc_command = eval_conditional(command, train.atc_arrow, train.velocity)
	
	if not train.atc_command then return end
	command=string.match(train.atc_command, "^%s*(.*)$")
	
	if string.match(command, "^%s*$") then
		train.atc_command=nil
		return
	end
	
	for pattern, func in pairs(matchptn) do
		local match=string.match(command, "^"..pattern)
		if match then
			local patlen=func(id, train, match)
			--atdebug("Executing: "..string.sub(command, 1, patlen))
			--atdebug("Train ATC State: tvel=",train.tarvelocity,"brktar=",train.atc_brake_target,"delay=",train.atc_delay,"wfinish=",train.atc_wait_finish,"wacpl=",train.atc_wait_autocouple)

			train.atc_command=string.sub(command, patlen+1)
			if train.atc_delay<=0
				and not train.atc_wait_finish
				and not train.atc_wait_autocouple then
				--continue (recursive, cmds shouldn't get too long, and it's a end-recursion.)
				atc.execute_atc_command(id, train)
			end
			return
		end
	end
	atwarn(sid(id), attrans("ATC command parse error: Unknown command: @1", command))
	atc.train_reset_command(train, true)
end



--move table to desired place
advtrains.atc=atc
