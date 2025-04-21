-- Setting and clearing routes

-- TODO duplicate
local lntrans = { "A", "B" }
local function sigd_to_string(sigd)
	return minetest.pos_to_string(sigd.p).." / "..lntrans[sigd.s]
end

local ildb = advtrains.interlocking.db
local ilrs = {}

local sigd_equal = advtrains.interlocking.sigd_equal

-- table containing locked points
-- also manual locks (maintenance a.s.o.) are recorded here
-- [pts] = { 
--		[n] = { [by = <ts_id>], rsn = <human-readable text>, [origin = <sigd>] }
--	}
ilrs.rte_locks = {}
ilrs.rte_callbacks = {
	ts = {},
	lck = {}
}


-- main route setting. First checks if everything can be set as designated,
-- then (if "try" is not set) actually sets it
-- returns:
-- true - route can be/was successfully set
-- false, message, cbts, cblk - something went wrong, what is contained in the message.
-- cbts: the ts id of the conflicting ts, cblk: the pts of the conflicting component
function ilrs.set_route(signal, route, try)
	if not try then
		local tsuc, trsn, cbts, cblk = ilrs.set_route(signal, route, true)
		if not tsuc then
			return false, trsn, cbts, cblk
		end
	end

	
	-- we start at the tc designated by signal
	local c_sigd = signal
	local first = true
	local i = 1
	local rtename = route.name
	local signalname = (ildb.get_tcbs(signal).signal_name or "") .. sigd_to_string(signal)
	local c_tcbs, c_ts_id, c_ts, c_rseg, c_lckp
	-- signals = { { pos = ., tcbs_ref = <tcbs>, role = "main_distant", main_aspect = nil, dst_type = "next_main" or "none" } 
	local signals = {}
	local nodst
	while c_sigd and i<=#route do
		c_tcbs = ildb.get_tcbs(c_sigd)
		if not c_tcbs then
			if not try then atwarn("Did not find TCBS",c_sigd,"while setting route",rtename,"of",signal) end
			return false, "No TCB found at "..sigd_to_string(c_sigd)..". Please update or reconfigure route!"
		end
		if i == 1 then
			nodst = c_tcbs.nodst
		end
		c_ts_id = c_tcbs.ts_id
		if not c_ts_id then
			if not try then atwarn("Encountered End-Of-Interlocking while setting route",rtename,"of",signal) end
			return false, "No track section adjacent to "..sigd_to_string(c_sigd)..". Please reconfigure route!"
		end
		c_ts = ildb.get_ts(c_ts_id)
		c_rseg = route[i]
		c_lckp = {}
		
		if not c_ts then
			if not try then atwarn("Encountered ts missing during a real run of routesetting routine, at ts=",c_ts_id,"while setting route",rtename,"of",signal) end
			return false, "Section '"..(c_ts_id).."' not found!", c_ts_id, nil
		elseif c_ts.route then
			if not try then atwarn("Encountered ts lock during a real run of routesetting routine, at ts=",c_ts_id,"while setting route",rtename,"of",signal) end
			return false, "Section '"..(c_ts.name or c_ts_id).."' already has route set from "..sigd_to_string(c_ts.route.origin)..":\n"..c_ts.route.rsn, c_ts_id, nil
		end
		if c_ts.trains and #c_ts.trains>0 then
			if c_rseg.call_on then
				--atdebug("Routesetting: Call-on situation in", c_ts_id)
			else
				if not try then atwarn("Encountered ts occupied during a real run of routesetting routine, at ts=",c_ts_id,"while setting route",rtename,"of",signal) end
				return false, "Section '"..(c_ts.name or c_ts_id).."' is occupied!", c_ts_id, nil
			end
		end
		
		-- collect locks from rs cache and from route def
		local c_locks = {}
		if route.use_rscache and c_ts.rs_cache and c_rseg.next then
			-- rscache needs to be enabled, present and next must be defined
			start_pkey = advtrains.encode_pos(c_sigd.p)
			end_pkey = advtrains.encode_pos(c_rseg.next.p)
			if c_ts.rs_cache[start_pkey] and c_ts.rs_cache[start_pkey][end_pkey] then
				for lp,lst in pairs(c_ts.rs_cache[start_pkey][end_pkey]) do
					--atdebug("Add lock from RSCache:",lp,"->",lst)
					c_locks[lp] = lst
				end
			elseif not try then
				atwarn("While setting route",rtename,"of",signal,"segment "..i..",required path from",c_tcbs,"to",c_rseg.next,"was not found in the track section's RS cache. Please check!")
			end
		end
		-- add all from locks, these override the rscache
		for lpts,lst in pairs(c_rseg.locks) do
			--atdebug("Add lock from Routedef:",lpts,"->",lst,"overrides",c_locks[lpts] or "none")
			c_locks[lpts] = lst
		end
		
		for lp, state in pairs(c_locks) do
			local confl = ilrs.has_route_lock(lp, state)
			
			local pos = advtrains.decode_pos(lp)
			if advtrains.is_passive(pos) then
				local cstate = advtrains.getstate(pos)
				if cstate ~= state then
					local confl = ilrs.has_route_lock(lp)
					if confl then
						if not try then atwarn("Encountered route lock while a real run of routesetting routine, at position",pos,"while setting route",rtename,"of",signal) end
						return false, "Lock conflict at "..minetest.pos_to_string(pos)..", Held locked by:\n"..confl, nil, lp
					elseif not try then
						advtrains.setstate(pos, state)
					end
				end
				if not try then
					ilrs.add_route_lock(lp, c_ts_id, "Route '"..rtename.."' from signal '"..signalname.."'", signal)
					c_lckp[#c_lckp+1] = lp
				end
			else
				if not try then atwarn("Encountered route lock misconfiguration (no passive component) while a real run of routesetting routine, at position",pts,"while setting route",rtename,"of",signal) end
				return false, "No passive component at "..minetest.pos_to_string(pos)..". Please update track section or reconfigure route!"
			end
		end
		-- sanity check, is section at next the same as the current?
		local nvar = c_rseg.next
		if nvar then
			local re_tcbs = ildb.get_tcbs({p = nvar.p, s = (nvar.s==1) and 2 or 1})
			if (not re_tcbs or not re_tcbs.ts_id or re_tcbs.ts_id~=c_ts_id)
					and route[i+1] then --FIX 2025-01-08: in old worlds the final TCB may be wrong (it didn't matter back then), don't error out here (route still shown invalid in UI)
				if not try then atwarn("Encountered inconsistent ts (front~=back) while a real run of routesetting routine, at position",pts,"while setting route",rtename,"of",signal) end
				return false, "TCB at "..minetest.pos_to_string(nvar.p).." has different section than previous TCB. Please update track section or reconfigure route!"
			end
		end
		-- reserve ts and write locks
		if not try then
			if not route[i+1] then
				-- We shouldn't use the "next" value of the final route segment, because this can lead to accidental route-cancelling of already set routes from another signal.
				nvar = nil
			end
			c_ts.route = {
				origin = signal,
				entry = c_sigd,
				rsn = "Route '"..rtename.."' from signal '"..signalname.."', segment #"..i,
				first = first,
			}
			c_ts.route_post = {
				locks = c_lckp,
				next = nvar,
			}
			if c_tcbs.signal then
				c_tcbs.route_committed = true
				c_tcbs.route_origin = signal
				-- determine route role
				local ndef = advtrains.ndb.get_ndef(c_tcbs.signal)
				local assign_dst = c_rseg.assign_dst
				if assign_dst == nil then
					assign_dst = (i~=1) -- special behavior when assign_dst is nil (and not false):
					-- defaults to false for the very first signal and true for all others (= minimal user configuration overhead)
				end
				local sig_table = {
					pos = c_tcbs.signal,
					tcbs_ref = c_tcbs,
					role = ndef and ndef.advtrains and ndef.advtrains.route_role,
					main_aspect = c_rseg.main_aspect,
					assign_dst = assign_dst
				}
				signals[#signals+1] = sig_table
			end
		end
		-- advance
		first = nil
		c_sigd = c_rseg.next
		i = i + 1
	end

	-- Get reference to signal at end of route
	local last_mainsig = nil
	if c_sigd then
		local e_tcbs = ildb.get_tcbs(c_sigd)
		local pos = e_tcbs and e_tcbs.signal
		if pos then
			last_mainsig = pos
		end
	end
	for i = #signals, 1, -1 do
		-- note the signals are iterated backwards. Switch depending on the role
		local sig = signals[i]
		-- apply mainaspect
		sig.tcbs_ref.route_aspect = sig.main_aspect or "_default" -- or route.main_aspect : TODO this does not work if a distant signal is on the path! Implement per-sig aspects!
		if sig.role == "distant" or sig.role == "distant_repeater" or sig.role == "main_distant" then
			if last_mainsig then
				-- assign the remote as the last mainsig if desired
				if sig.assign_dst then
					sig.tcbs_ref.route_remote = last_mainsig
				end
				-- if it wasn't a distant_repeater clear the mainsig
				if sig.role ~= "distant_repeater" then
					last_mainsig = false
				end
			end
		end
		if sig.role == "main" or sig.role == "main_distant" or sig.role == "end" then
			-- record this as the new last mainsig
			last_mainsig = sig.pos
		end
		-- for shunt signals nothing happens
		-- update the signal aspect on map
		advtrains.interlocking.signal.update_route_aspect(sig.tcbs_ref, i ~= 1)
	end
	
	return true
end

-- Change 2024-01-27: pts is not an encoded pos, not a pos-to-string!

-- Checks whether there is a route lock that prohibits setting the component
-- to the wanted state. returns string with reasons on conflict
function ilrs.has_route_lock(pts)
	-- look this up
	local e = ilrs.rte_locks[pts]
	if not e then return nil
	elseif #e==0 then
		ilrs.rte_locks[pts] = nil
		return nil
	end
	local txts = {}
	for _, ent in ipairs(e) do
		txts[#txts+1] = ent.rsn
	end
	return table.concat(txts, "\n")
end

-- adds route lock for position
function ilrs.add_route_lock(pts, ts, rsn, origin)
	ilrs.free_route_locks_indiv(pts, ts, true)
	local elm = {by=ts, rsn=rsn, origin=origin}
	if not ilrs.rte_locks[pts] then
		ilrs.rte_locks[pts] = { elm }
	else
		table.insert(ilrs.rte_locks[pts], elm)
	end
end

-- adds route lock for position
function ilrs.add_manual_route_lock(pts, rsn)
	local elm = {rsn=rsn}
	if not ilrs.rte_locks[pts] then
		ilrs.rte_locks[pts] = { elm }
	else
		table.insert(ilrs.rte_locks[pts], elm)
	end
end

-- frees route locking for all points (components) that were set by this ts
function ilrs.free_route_locks(ts, lcks, nocallbacks)
	for _,pts in pairs(lcks) do
		ilrs.free_route_locks_indiv(pts, ts, nocallbacks)
	end
end

function ilrs.free_route_locks_indiv(pts, ts, nocallbacks)
	-- legacy: if starts with bracket then pts is still in old pos_to_string format (may happen because ts.route_post is not migrated)
	if string.match(pts, "^%(") then
		atdebug("free_route_locks_indiv: converting position",pts)
		pts = advtrains.encode_pos(minetest.string_to_pos(pts))
	end
	local e = ilrs.rte_locks[pts]
	if not e then return nil
	elseif #e==0 then
		ilrs.rte_locks[pts] = nil
		return nil
	end
	local i = 1
	while i <= #e do
		if e[i].by == ts then
			--atdebug("free_route_locks_indiv",pts,"clearing entry",e[i].by,e[i].rsn)
			table.remove(e,i)
		else
			i = i + 1
		end
	end
	-- This must be delayed, because this code is executed in-between a train step
	-- TODO use luaautomation timers?
	if not nocallbacks then
		minetest.after(0, ilrs.update_waiting, "lck", pts)
		minetest.after(0.5, advtrains.set_fallback_state, advtrains.decode_pos(pts))
	end
end
-- frees all route locks, even manual ones set with the tool, at a specific position
function ilrs.remove_route_locks(pts, nocallbacks)
	ilrs.rte_locks[pts] = nil
	-- This must be delayed, because this code is executed in-between a train step
	-- TODO use luaautomation timers?
	if not nocallbacks then
		minetest.after(0, ilrs.update_waiting, "lck", pts)
	end
end


-- starting from the designated sigd, clears all subsequent route and route_post
-- information from the track sections.
-- note that this does not clear the routesetting status from the entry signal,
-- only from the ts's
function ilrs.cancel_route_from(sigd)
	-- we start at the tc designated by signal
	local c_sigd = sigd
	local c_tcbs, c_ts_id, c_ts, c_rseg, c_lckp
	while c_sigd do
		--atdebug("cancel_route_from: at sigd",c_sigd)
		c_tcbs = ildb.get_tcbs(c_sigd)
		if not c_tcbs then
			atwarn("Failed to cancel route, no TCBS at",c_sigd)
			return false
		end
		
		--atdebug("cancelling",c_ts.route.rsn)
		-- clear signal aspect and routesetting state
		c_tcbs.route_committed = nil
		c_tcbs.route_aspect = nil
		c_tcbs.route_remote = nil
		c_tcbs.routeset = nil
		c_tcbs.route_auto = nil
		c_tcbs.route_origin = nil
		
		advtrains.interlocking.signal.update_route_aspect(c_tcbs)
		
		c_ts_id = c_tcbs.ts_id
		if not c_tcbs then
			atwarn("Failed to cancel route, end of interlocking at",c_sigd)
			return false
		end
		c_ts = ildb.get_ts(c_ts_id)
		
		if not c_ts
			or not c_ts.route
			or not sigd_equal(c_ts.route.entry, c_sigd) then
			--atdebug("cancel_route_from: abort (eoi/no route):")
			return false
		end
		
		c_ts.route = nil
		
		if c_ts.route_post then
			advtrains.interlocking.route.free_route_locks(c_ts_id, c_ts.route_post.locks)
			c_sigd = c_ts.route_post.next
		else
			c_sigd = nil
		end
		c_ts.route_post = nil
		minetest.after(0, advtrains.interlocking.route.update_waiting, "ts", c_ts_id)
	end
	--atdebug("cancel_route_from: done (no final sigd)")
	return true
end

-- TCBS Routesetting helper: generic update function for
-- route setting
-- Call this function to set and cancel routes!
-- sigd, tcbs: self-explanatory
-- newrte: If a new route should be set, the route index of it (in tcbs.routes). nil otherwise
-- cancel: true in combination with newrte=nil causes cancellation of the current route.
function ilrs.update_route(sigd, tcbs, newrte, cancel)
	--atdebug("Update_Route for",sigd,tcbs.signal_name)
	local has_changed_aspect = false
	if tcbs.route_origin and not sigd_equal(tcbs.route_origin, sigd) then
		--atdebug("Signal not in control, held by",tcbs.signal_name)
		return
	end
	-- clear route_rsn, it will be set again if needed
	tcbs.route_rsn = nil
	if (newrte and tcbs.routeset and tcbs.routeset ~= newrte) or cancel then
		if tcbs.route_committed then
			--atdebug("Cancelling:",tcbs.routeset)
			advtrains.interlocking.route.cancel_route_from(sigd)
		end
		tcbs.route_committed = nil
		tcbs.route_aspect = nil
		tcbs.route_remote = nil
		has_changed_aspect = true
		tcbs.routeset = nil
		tcbs.route_auto = nil
	end
	if newrte or tcbs.routeset then
		if tcbs.route_committed then
			return
		end
		if newrte then tcbs.routeset = newrte end
		--atdebug("Setting:",tcbs.routeset)
		local succ, rsn, cbts, cblk
		local route = tcbs.routes[tcbs.routeset]
		if route then
			succ, rsn, cbts, cblk = ilrs.set_route(sigd, route)
		else
			succ = false
			rsn = attrans("Route state changed.")
		end
		if not succ then
			tcbs.route_rsn = rsn
			--atdebug("Routesetting failed:",rsn)
			-- add cbts or cblk to callback table
			if cbts then
				--atdebug("cbts =",cbts)
				if not ilrs.rte_callbacks.ts[cbts] then ilrs.rte_callbacks.ts[cbts]={} end
				advtrains.insert_once(ilrs.rte_callbacks.ts[cbts], sigd, sigd_equal)
			end
			if cblk then
				--atdebug("cblk =",cblk)
				if not ilrs.rte_callbacks.lck[cblk] then ilrs.rte_callbacks.lck[cblk]={} end
				advtrains.insert_once(ilrs.rte_callbacks.lck[cblk], sigd, sigd_equal)
			end
		else
			--atdebug("Committed Route:",tcbs.routeset)
			-- set_route now sets the signal aspects
			--has_changed_aspect = true
			-- route success. apply default_autoworking flag if requested
			if route.default_autoworking then
				tcbs.route_auto = true --FIX 2025-01-08: never set it to false if it was true!
			end
		end
	end
	if has_changed_aspect then
		-- FIX: prevent an minetest.after() loop caused by update_signal_aspect dispatching path invalidation, which in turn calls ARS again
		advtrains.interlocking.signal.update_route_aspect(tcbs)
	end
	advtrains.interlocking.update_player_forms(sigd)
end

-- Try to re-set routes that conflicted with this point
-- sys can be one of "ts" and "lck"
-- key is then ts_id or pts respectively
function ilrs.update_waiting(sys, key)
	--atdebug("update_waiting:",sys,".",key)
	local t = ilrs.rte_callbacks[sys][key]
	ilrs.rte_callbacks[sys][key] = nil
	if t then
		for _,sigd in ipairs(t) do
			--atdebug("Updating", sigd)
			-- While these are run, the table we cleared before may be populated again, which is in our interest.
			-- (that's the reason we needed to copy it)
			local tcbs = ildb.get_tcbs(sigd)
			if tcbs then
				ilrs.update_route(sigd, tcbs)
			end
		end
	end
end

advtrains.interlocking.route = ilrs

