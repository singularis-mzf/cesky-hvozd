-- route_ui.lua
-- User interface for showing and editing routes

local atil = advtrains.interlocking
local ildb = atil.db
local F = advtrains.formspec

-- TODO duplicate
local lntrans = { "A", "B" }
local function sigd_to_string(sigd)
	return minetest.pos_to_string(sigd.p).." / "..lntrans[sigd.s]
end

-- indexed by pname
local sel_rpartcache = {}

function atil.show_route_edit_form(pname, sigd, routeid, sel_rpartidx)

	if not minetest.check_player_privs(pname, {train_operator=true, interlocking=true}) then
		minetest.chat_send_player(pname, "Insufficient privileges to use this!")
		return
	end
	
	local tcbs = atil.db.get_tcbs(sigd)
	if not tcbs then return end
	local route = tcbs.routes[routeid]
	if not route then return end
	
	local form = "size[9,11]label[0.5,0.2;Route overview]"
	form = form.."field[0.8,1.2;6.5,1;name;Route name;"..minetest.formspec_escape(route.name).."]"
	form = form.."button[7.0,0.9;1.5,1;setname;Set]"
	
	-- construct textlist for route information
	local tab = {}
	local tabref = {}
	local function itab(rseg, t, rty, rpara)
		tab[#tab+1] = minetest.formspec_escape(string.gsub(t, ",", " "))
		tabref[#tab] = { [rty] = true, param = rpara, seg = rseg, idx = #tab }
	end
	itab(1, "("..(tcbs.signal_name or "+")..") Route #"..routeid, "signal", sigd)
	
	-- this code is partially copy-pasted from routesetting.lua
	-- we start at the tc designated by signal
	local c_sigd = sigd
	local i = 1
	local c_tcbs, c_ts_id, c_ts, c_rseg
	while c_sigd and i<=#route do
		c_tcbs = ildb.get_tcbs(c_sigd)
		if not c_tcbs then
			itab(i, "-!- No TCBS at "..sigd_to_string(c_sigd)..". Please reconfigure route!", "err", nil)
			break
		end
		c_ts_id = c_tcbs.ts_id
		if not c_ts_id then
			itab(i, "-!- No track section adjacent to "..sigd_to_string(c_sigd)..". Please reconfigure route!", "err", nil)
			break
		end
		c_ts = ildb.get_ts(c_ts_id)
		
		c_rseg = route[i]
		
		local signame = "-"
		if c_tcbs and c_tcbs.signal then signame = c_tcbs.signal_name or "o" end
		itab(i, ""..i.." "..sigd_to_string(c_sigd).." ("..signame..")", "signal", c_sigd)
		itab(i, "= "..(c_ts and c_ts.name or c_ts_id).." ="..(c_rseg.call_on and " [CO]" or ""), "section", c_ts_id)
		
		if c_rseg.locks then
			for pts, state in pairs(c_rseg.locks) do
				
				local pos = advtrains.decode_pos(pts)
				itab(i, "L "..pts.." -> "..state, "lock", pos)
				if not advtrains.is_passive(pos) then
					itab(i, "-!- No passive component at "..pts..". Please reconfigure route!", "err", nil)
					break
				end
			end
		end
		-- sanity check, is section at next the same as the current?
		local nvar = c_rseg.next
		if nvar then
			local re_tcbs = ildb.get_tcbs({p = nvar.p, s = (nvar.s==1) and 2 or 1})
			if not re_tcbs or not re_tcbs.ts_id or re_tcbs.ts_id~=c_ts_id then
				itab(i, "-!- At "..sigd_to_string(c_sigd)..".Section Start and End do not match!", "err", nil)
				break
			end
		end
		-- advance
		c_sigd = nvar
		i = i + 1
	end
	if c_sigd then
		local e_tcbs = ildb.get_tcbs(c_sigd)
		local signame = "-"
		if e_tcbs and e_tcbs.signal then signame = e_tcbs.signal_name or "o" end
		itab(i, "E "..sigd_to_string(c_sigd).." ("..signame..")", "end", c_sigd)
	else
		itab(i, "E (none)", "end", nil)
	end
	
	if not sel_rpartidx then sel_rpartidx = 1 end
	form = form.."textlist[0.5,2;3.5,3.9;routelog;"..table.concat(tab, ",")..";"..(sel_rpartidx or 1)..";false]"
	
	-- to the right of rtelog, controls are displayed for the thing in focus
	-- What is in focus is determined by the parameter sel_rpartidx
	
	local sel_rpart = tabref[sel_rpartidx]
	--atdebug("sel rpart",sel_rpart)
	
	if sel_rpart and sel_rpart.signal then
		-- get TCBS here and rseg selected
		local s_tcbs = ildb.get_tcbs(sel_rpart.param)
		local rseg = route[sel_rpart.seg]
		-- main aspect list
		local signalpos = s_tcbs and s_tcbs.signal
		if signalpos and rseg then
			form = form..F.label(4.5, 2, "Signal Aspect:")
			local ndef = signalpos and advtrains.ndb.get_ndef(signalpos)
			if ndef and ndef.advtrains and ndef.advtrains.main_aspects then
				local entries = { "<Default Aspect>" }
				local sel = 1
				for i, mae in ipairs(ndef.advtrains.main_aspects) do
					entries[i+1] = mae.description
					if mae.name == rseg.main_aspect then
						sel = i+1
					end
				end
				form = form..F.dropdown(4.5, 3.0, 4, "sa_main_aspect", entries, sel, true)
			end
			-- checkbox for assign distant signal
			local assign_dst = rseg.assign_dst
			if assign_dst == nil then
				assign_dst = (sel_rpart.seg~=1) -- special behavior when assign_dst is nil (and not false):
				-- defaults to false for the very first signal and true for all others (= minimal user configuration overhead)
				-- Note: on save, the value will be fixed at either false or true
			end
			form = form..string.format("checkbox[4.5,4.0;sa_distant;Announce distant signal;%s]", assign_dst)
		else
			form = form..F.label(4.5, 2, "No Signal at this TCB")
		end
	elseif sel_rpart and sel_rpart.section then
		local rseg = route[sel_rpart.seg]
		if rseg then
			form = form..F.label(4.5, 2, "Section Options:")
			-- checkbox for call-on
			form = form..string.format("checkbox[4.5,4.0;se_callon;Call-on (section may be occupied);%s]", rseg.call_on)
		end
	elseif sel_rpart and sel_rpart.err then
		form = form.."textarea[4.5,2.5;4,4;errorta;Error:;"..tab[sel_rpartidx].."]"
	else
		form = form..F.label(4.5, 2, "<< Select a route part to edit options")
	end
	
	form = form.."button[0.5,6;1,1;prev;<<<]"
	form = form.."button[1.5,6;1,1;back;"..routeid.."/"..#tcbs.routes.."]"
	form = form.."button[2.5,6;1,1;next;>>>]"
	
	
	--if route.smartroute_generated or route.default_autoworking then
	--	form = form.."button[3.5,6;2,1;noautogen;Clr Autogen]"
	--end
	form = form.."button[5.5,6;3,1;delete;Delete Route]"
	form = form.."button[0.5,7;3,1;back;Back to signal]"
	form = form.."button[3.5,7;2,1;clone;Clone Route]"
	form = form.."button[5.5,7;3,1;newfrom;New From Route]"
	
	--atdebug(route.ars)
	form = form.."style[ars;font=mono]"
	form = form.."textarea[0.8,8.3;5,3;ars;ARS Rule List;"..atil.ars_to_text(route.ars).."]"
	form = form.."button[5.5,8.23;3,1;savears;Save ARS List]"
	
	local formname = "at_il_routeedit_"..minetest.pos_to_string(sigd.p).."_"..sigd.s.."_"..routeid
	minetest.show_formspec(pname, formname, form)
	-- record selected entry from routelog for receive fields callback
	sel_rpartcache[pname] = sel_rpart
end


minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pname = player:get_player_name()
	-- retreive sel_rpart from the cache in any case and clear it out
	local sel_rpart = sel_rpartcache[pname]
	if not minetest.check_player_privs(pname, {train_operator=true, interlocking=true}) then
		return
	end
	
	local pts, connids, routeids = string.match(formname, "^at_il_routeedit_([^_]+)_(%d)_(%d+)$")
	local pos, connid, routeid
	if pts then
		pos = minetest.string_to_pos(pts)
		connid = tonumber(connids)
		routeid = tonumber(routeids)
		if not connid or connid<1 or connid>2 then return end
		if not routeid then return end
	end
	if pos and connid and routeid and not fields.quit then
		local sigd = {p=pos, s=connid}
		local tcbs = ildb.get_tcbs(sigd)
		if not tcbs then return end
		local route = tcbs.routes[routeid]
		if not route then return end
		
		if fields.prev then
			atil.show_route_edit_form(pname, sigd, routeid - 1)
			return
		end
		if fields.next then
			atil.show_route_edit_form(pname, sigd, routeid + 1)
			return
		end
		
		if fields.setname and fields.name then
			route.name = fields.name
		end
		
		if fields.sa_main_aspect and sel_rpart and sel_rpart.signal then
			local idx = tonumber(fields.sa_main_aspect)
			-- get TCBS here and rseg selected
			local s_tcbs = ildb.get_tcbs(sel_rpart.param)
			local rseg = route[sel_rpart.seg]
			-- main aspect list
			local signalpos = s_tcbs and s_tcbs.signal
			if rseg then
				rseg.main_aspect = nil
				if idx > 1 then
					local ndef = signalpos and advtrains.ndb.get_ndef(signalpos)
					if ndef and ndef.advtrains and ndef.advtrains.main_aspects then
						rseg.main_aspect = ndef.advtrains.main_aspects[idx - 1].name
					end
				end
			end
		end
		if fields.sa_distant and sel_rpart and sel_rpart.signal then
			local rseg = route[sel_rpart.seg]
			if rseg then
				rseg.assign_dst = minetest.is_yes(fields.sa_distant)
			end
		end
		if fields.se_callon and sel_rpart and sel_rpart.section then
			local rseg = route[sel_rpart.seg]
			if rseg then
				rseg.call_on = minetest.is_yes(fields.se_callon)
				-- reshow form to update CO marker
				atil.show_route_edit_form(pname, sigd, routeid, sel_rpart.idx)
				return
			end
		end
		
		--if fields.noautogen then
		--	route.smartroute_generated = nil
		--	route.default_autoworking = nil
		--	-- reshow form for the button to disappear
		--	atil.show_route_edit_form(pname, sigd, routeid, sel_rpart and sel_rpart.idx)
		--	return
		--end
		
		if fields.delete then
			-- if something set the route in the meantime, make sure this doesn't break.
			atil.route.update_route(sigd, tcbs, nil, true)
			table.remove(tcbs.routes, routeid)
			advtrains.interlocking.show_signalling_form(sigd, pname)
			-- cleanup
			sel_rpartcache[pname] = nil
			return
		end
		
		if fields.clone then
			-- if something set the route in the meantime, make sure this doesn't break.
			atil.route.update_route(sigd, tcbs, nil, true)
			local rcopy = table.copy(route)
			rcopy.name = route.name.."_copy"
			rcopy.smartroute_generated = nil
			table.insert(tcbs.routes, routeid+1, rcopy)
			advtrains.interlocking.show_signalling_form(sigd, pname)
			-- cleanup
			sel_rpartcache[pname] = nil
			return
		end

		if fields.newfrom then
			advtrains.interlocking.init_route_prog(pname, sigd, route)
			minetest.close_formspec(pname, formname)
			tcbs.ars_ignore_next = nil
			-- cleanup
			sel_rpartcache[pname] = nil
			return
		end
		
		if fields.ars and fields.savears then
			route.ars = atil.text_to_ars(fields.ars)
			--atdebug(route.ars)
		end
		
		if fields.back then
			advtrains.interlocking.show_signalling_form(sigd, pname)
			-- cleanup
			sel_rpartcache[pname] = nil
			return
		end
		
		-- if an entry was selected in the textlist (and its not the current one) update the form
		if fields.routelog then
			local prev_idx = sel_rpart and sel_rpart.idx or 1
			local tev = minetest.explode_textlist_event(fields.routelog)
			local new_idx = tev and tev.index
			if new_idx and new_idx ~= prev_idx then
				atil.show_route_edit_form(pname, sigd, routeid, new_idx)
				return
			end
		end
		
		if fields.quit then
			-- cleanup
			sel_rpartcache[pname] = nil
		end
		
	end
end)
