-- smartroute.lua
-- Implementation of the advtrains auto-route search

local atil = advtrains.interlocking
local ildb = atil.db
local sr = {}


-- Start the SmartRoute process. This searches for routes and tries to match them with existing routes, showing them in a form
function sr.start(pname, sigd)
	-- is start signal a shunt signal? This becomes default setting for searching_shunt
	local is_startsignal_shunt = false
	local tcbs = ildb.get_tcbs(sigd)
	if tcbs.signal then
		local ndef = advtrains.ndb.get_ndef(tcbs.signal)
		if ndef and ndef.advtrains then
			if ndef.advtrains.route_role == "shunt" then
				is_startsignal_shunt = true
			end
		end
	end
	sr.propose_next(pname, sigd, 0, is_startsignal_shunt)
end


local function otherside(s)
	if s==1 then return 2 else return 1 end
end

--route search implementation
-- new 2025-01-06: rely on the already present info from rscache to traverse sections
-- this allows to implement a breadth first search
-- format of foundroute:
-- { name = "the name", tcbseq = { list of sigds in sequence, not containing the start sigd }}

local function build_route_from_foundroute(froute, name)
	local route = {
		name = froute.name,
		use_rscache = true,
		smartroute_generated = true,
	}
	for _, sigd in ipairs(froute.tcbseq) do
		route[#route+1] = { next = sigd, locks = {} }
	end
	return route
end

-- Maximum num of sections for routes to be found
local RTE_MAX_SECS = 16

-- scan for possible routes from the start tcb in a bread-first-search manner
-- find_more_than: search is aborted only if more than the specified number of routes are found
function sr.rescan(pname, sigd, tcbs, find_more_than, searching_shunt, pname)
	local found_routes = {}
	local restart_tcbs = { {sigd = sigd, tcbseq = {} } }
	local last_len = 0
	while true do
		-- take first entry out of restart_tcbs (due to the way it is inserted the first entry will always be the one with the lowest length
		local cur_restart
		for idx, rst in ipairs(restart_tcbs) do
			cur_restart = rst
			table.remove(restart_tcbs, idx)
			break
		end
		if not cur_restart then
			-- we have no candidates left. Give up and return what we have
			--atdebug("(SR) No Candidates left, end rescan")
			return found_routes
		end
		-- check if we need to stop due to having found enough routes
		local cur_len = #cur_restart.tcbseq
		if cur_len > last_len then
			-- one level is finished, check if enoufh routes are found
			if #found_routes > find_more_than then
				--atdebug("(SR) Layer finished and enough routes found, end rescan")
				return found_routes
			end
			last_len = cur_len
		end
		-- our current restart point is nouw in cur_restart
		local c_sigd = cur_restart.sigd
		--atdebug("(SR) Search continues at",c_sigd,"seqlen",#cur_restart.tcbseq)
		-- do a TS repair, this also updates the RS cache should it be out of date
		local c_ts_id = ildb.check_and_repair_ts_at_pos(c_sigd.p, c_sigd.s, pname, false)
		if c_ts_id then
			local c_ts = ildb.get_ts(c_ts_id)
			local bgn_pts = advtrains.encode_pos(c_sigd.p)
			local rsout = c_ts.rs_cache[bgn_pts]
			if rsout then
				for _, end_sigd in ipairs(c_ts.tc_breaks) do
					end_pkey = advtrains.encode_pos(end_sigd.p)
					if rsout[end_pkey] then
						--atdebug("(SR) Section",c_ts_id,c_ts.name,"has way",c_sigd,"->",end_sigd)
						local nsigd = {p=end_sigd.p, s = end_sigd.s==1 and 2 or 1} -- invert to other side
						-- record nsigd in the tcbseq
						local ntcbseq = table.copy(cur_restart.tcbseq)
						ntcbseq[#ntcbseq+1] = nsigd
						local shall_continue = true
						-- check if that sigd is a route target
						local tcbs = ildb.get_tcbs(nsigd)
                        if tcbs.signal then
							local ndef = advtrains.ndb.get_ndef(tcbs.signal)
							if ndef and ndef.advtrains then
								if ndef.advtrains.route_role == "main" or ndef.advtrains.route_role == "main_distant"
											or ndef.advtrains.route_role == "end" or ndef.advtrains.route_role == "shunt" then
									-- signal is suitable target
									local is_mainsignal = ndef.advtrains.route_role ~= "shunt"
									--atdebug("(SR) Suitable end signal at",nsigd,", recording route!")
									-- record the found route in the results
									found_routes[#found_routes+1] = {
											tcbseq = ntcbseq,
											shunt_route = not is_mainsignal,
											name = tcbs.signal_name or atil.sigd_to_string(nsigd)
									}
									-- if this is a main signal and/or we are only searching shunt routes, stop the search here
									if is_mainsignal or searching_shunt then
											--atdebug("(SR) Not continuing this branch!")
											shall_continue = false
									end
								end
							end
                        end
						-- unless overridden, insert the next restart point
						if shall_continue then
							restart_tcbs[#restart_tcbs+1] =  {sigd = nsigd, tcbseq = ntcbseq } 
						end
					end
				end
			else
				--atdebug("(SR) Section",c_ts_id,c_ts.name,"found no rscache entry for start ",bgn_pts)
			end
		else
			--atdebug("(SR) Stop at",c_sigd,"because no sec ahead")
		end
	end
end

local players_smartroute_actions = {}
-- Propose to pname the smartroute actions in a form, with the current settings as passed to this function
function sr.propose_next(pname, sigd, find_more_than, searching_shunt)
	local tcbs = ildb.get_tcbs(sigd)
	if not tcbs or not tcbs.routes then
		minetest.chat_send_player(pname, "Smartroute: TCBS or routes don't exist here!")
		return
	elseif not tcbs.ts_id then
		minetest.chat_send_player(pname, "Smartroute: No track section directly ahead!")
		return
	end
	-- Step 1: search for routes using the current settings
	local found_routes = sr.rescan(pname, sigd, tcbs, find_more_than, searching_shunt, pname)
	-- Step 2: store in actions table
	players_smartroute_actions[pname] = {
		sigd = sigd,
		searching_shunt = searching_shunt,
		found_routes = found_routes
	}
	-- step 3: build form
	local form = "size[5,5]label[0,0;Route search: "..#found_routes.." found]"
	local tab = {}
	for idx, froute in ipairs(found_routes) do
		tab[idx] = minetest.formspec_escape(froute.name.." (Len="..#froute.tcbseq..")")
	end
	form=form.."textlist[0.5,1;4,3;rtelist;"..table.concat(tab, ",").."]"
	form=form.."button[0.5,4;2,1;continue;Search further]"
	form=form.."button[2.5,4;2,1;apply;Apply]"
	
	minetest.show_formspec(pname, "at_il_smartroute_propose", form)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pname = player:get_player_name()
	if not minetest.check_player_privs(pname, "interlocking") then
		return
	end
	if formname ~= "at_il_smartroute_propose" then
		return
	end
	-- retrieve from the storage the current search result
	local srtab = players_smartroute_actions[pname]
	if not srtab then
		return
	end
	local sigd = srtab.sigd
	local found_routes = srtab.found_routes
	
	if fields.continue then
		-- search on, but find at least one route more
		sr.propose_next(pname, sigd, #found_routes, srtab.searching_shunt)
		return
	end
	
	if fields.apply then
		-- user is happy with the found routes. Proceed to save them in the signal
		local tcbs = ildb.get_tcbs(sigd)
		if not tcbs then return end
		-- remove routes for endpoints for which routes already exist
		local ex_endpts = {} -- key = sigd_to_string
		for rtid, route in ipairs(tcbs.routes) do
			local valid = advtrains.interlocking.check_route_valid(route, sigd)
			local endpoint = route[#route].next -- 'next' field of the last route segment (the segment with index==len)
			if valid and endpoint then
				local endstr = advtrains.interlocking.sigd_to_string(endpoint)
				--atdebug("(Smartroute) Find existing endpoint:",route.name,"ends at",endstr)
				ex_endpts[endstr] = route.name
			else
				--atdebug("(Smartroute) Find existing endpoint:",route.name," not considered, endpoint",endpoint,"valid",valid)
			end
		end
		local new_frte = {}
		for _,froute in ipairs(found_routes) do
			local endpoint = froute.tcbseq[#froute.tcbseq]
			local endstr = advtrains.interlocking.sigd_to_string(endpoint)
			if not ex_endpts[endstr] then
				new_frte[#new_frte+1] = froute
			else
				--atdebug("(Smartroute) Throwing away",froute.name,"because endpoint",endstr,"already reached by route",ex_endpts[endstr])
			end
		end
		
		-- All remaining routes will be applied to the signal
		local sel_rte = #tcbs.routes+1
		for idx, froute in ipairs(new_frte) do
			tcbs.routes[#tcbs.routes+1] = build_route_from_foundroute(froute)
		end
		-- if only one route present and it is newly created (there was no route before, thus sel_rte==1), make default
		if sel_rte == 1 and #tcbs.routes == 1 then
			local route1 = tcbs.routes[1]
			route1.ars = {default=true}
			-- if that only route furthermore is a suitable block signal route (1 section with no locks), set it into block signal mode
			if #route1 == 1 then
				local ts = tcbs.ts_id and advtrains.interlocking.db.get_ts(tcbs.ts_id)
				if ts and #ts.tc_breaks == 2 then
					-- check for presence of any locks
					local epos1 = advtrains.encode_pos(ts.tc_breaks[1].p)
					local epos2 = advtrains.encode_pos(ts.tc_breaks[2].p)
					local haslocks =
							(route1[1].locks and next(route1[1].locks)) -- the route itself has no locks
							or (ts.fixed_locks and next(ts.fixed_locks)) -- the section has no fixedlocks
							or (ts.rs_cache and ts.rs_cache[epos1] and ts.rs_cache[epos1][epos2] and next(ts.rs_cache[epos1][epos2])) -- the section has no locks in rscache
					if not haslocks then
						-- yeah, blocksignal!
						route1.default_autoworking = true
					end
				end
			end
		end
		--atdebug("Smartroute done!")
		advtrains.interlocking.show_signalling_form(sigd, pname, sel_rte)
		players_smartroute_actions[pname] = nil
	end
	if fields.quit then
		players_smartroute_actions[pname] = nil
	end
end)


advtrains.interlocking.smartroute = sr
