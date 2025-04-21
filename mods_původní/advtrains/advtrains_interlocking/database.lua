-- interlocking/database.lua
-- saving the location of TCB's, their neighbors and their state
--[[

== Route releasing (TORR) ==
A train passing through a route happens as follows:
Route set from entry to exit signal
Train passes entry signal and enters first TS past the signal
-> Route from signal cleared (TSs remain locked)
-> 'route' status of first TS past signal cleared
-> 'route_post' (holding the turnout locks) remains set
Train continues along the route.
Whenever train leaves a TS
-> Clearing any routes set from this TC outward recursively - see "Reversing problem"
-> Free turnout locks and clear 'route_post'
Whenever train enters a TS
-> Clear route status from the just entered TC (but not route_post)
Note that this prohibits by design that the train clears the route ahead of it.
== Reversing Problem ==
Encountered at the Royston simulation in SimSig. It is solved there by imposing a time limit on the set route. Call-on routes can somehow be set anyway.
Imagine this setup: (T=Train, R=Route, >=in_dir TCB)
    O-|  Royston P2 |-O
T->---|->RRR-|->RRR-|--
Train T enters from the left, the route is set to the right signal. But train is supposed to reverse here and stops this way:
    O-|  Royston P2 |-O
------|-TTTT-|->RRR-|--
The "Route" on the right is still set. Imposing a timeout here is a thing only professional engineers can determine, not an algorithm.
    O-|  Royston P2 |-O
<-T---|------|->RRR-|--
The train has left again, while route on the right is still set.
So, we have to clear the set route when the train has left the left TC.
This does not conflict with call-on routes, because both station tracks are set as "allow call-on"
Because none of the routes extends past any non-call-on sections, call-on route would be allowed here, even though the route
is locked in opposite direction at the time of routesetting.
Another case of this:
--TTT/--|->RRR--
The / here is a non-interlocked turnout (to a non-frequently used siding). For some reason, there is no exit node there,
so the route is set to the signal at the right end. The train is taking the exit to the siding and frees the TC, without ever
having touched the right TC.


== Terminology / Variable Names ==

"tcb" : A TCB table (as in track_circuit_breaks)
"tcbs" : One side of a tcb (that is tcb == {[1] = tcbs, [2] = tcbs})
"sigd" : A table of format {p=<position>, s=<side aka connid>} by which a "tcbs" is uniqely identified.

== Section Autorepair & Turnout Cache ==

As fundamental part of reworked route programming mechanism, Track Section objects become weak now. They are created and destroyed on demand.
ildb.repair_tcb automatically checks all nearby sections for issues and repairs them automatically.

Also the database now holds a cache of the turnouts in the section and their position for all possible driving paths.
Every time a repair operation takes place, and on every track edit operation, the affected sections need to have their cache updated.

]]--

local TRAVERSER_LIMIT = 1000


local ildb = {}

local track_circuit_breaks = {}
local track_sections = {}

-- Assignment of signals to TCBs
local signal_assignments = {}

-- track+direction -> signal position
local influence_points = {}

advtrains.interlocking.npr_rails = {}


function ildb.load(data)
	if not data then return end
	if data.tcbs then
		if data.tcbpts_conversion_applied then
			track_circuit_breaks = data.tcbs
		else
			-- Convert legacy pos_to_string tcbs to new advtrains.encode_pos position strings
			for pts, tcb in pairs(data.tcbs) do
				local pos = minetest.string_to_pos(pts)
				if pos then
					-- that was a pos_to_string
					local epos = advtrains.encode_pos(pos)
					atdebug("ILDB converting TCB position format",pts,"->",epos)
					track_circuit_breaks[epos] = tcb
				else
					-- keep entry, it is already new
					track_circuit_breaks[pts] = tcb
				end
				-- convert the routes.[].locks table keys
				for t_side,tcbs in pairs(tcb) do
					if tcbs.routes then
						for t_rnum,route in pairs(tcbs.routes) do
							for t_rsnm,rseg in ipairs(route) do
								local locks_n = {}
								for lpts,state in pairs(rseg.locks) do
									local lpos = minetest.string_to_pos(lpts)
									if lpos then
										local epos = advtrains.encode_pos(lpos)
										atdebug("ILDB converting tcb",pts,"side",t_side,"route",t_rnum,"lock position format",lpts,"->",epos)
										locks_n[epos] = state
									else
										-- already correct format
										locks_n[lpts] = state
									end
								end
								rseg.locks = locks_n
							end
						end
					end
				end
			end
		end
	end
	if data.ts then
		track_sections = data.ts
	end
	if data.signalass then
		signal_assignments = data.signalass
	end
	if data.rs_locks then
		if data.tcbpts_conversion_applied then
			advtrains.interlocking.route.rte_locks = data.rs_locks
		else
			advtrains.interlocking.route.rte_locks = {}
			for pts, lta in pairs(data.rs_locks) do
				local pos = minetest.string_to_pos(pts)
				if pos then
					-- that was a pos_to_string
					local epos = advtrains.encode_pos(pos)
					atdebug("ILDB converting Route Lock position format",pts,"->",epos)
					advtrains.interlocking.route.rte_locks[epos] = lta
				else
					-- keep entry, it is already new
					advtrains.interlocking.route.rte_locks[pts] = lta
				end
			end
		end
	end
	if data.rs_callbacks then
		advtrains.interlocking.route.rte_callbacks = data.rs_callbacks
	end
	if data.influence_points then
		influence_points = data.influence_points
	end
	if data.npr_rails then
		advtrains.interlocking.npr_rails = data.npr_rails
	end
	
	-- let signal_api load data
	advtrains.interlocking.signal.load(data)
	
	--COMPATIBILITY to Signal aspect format
	-- TODO remove in time...
	for pts,tcb in pairs(track_circuit_breaks) do
		for connid, tcbs in ipairs(tcb) do
			if tcbs.routes then
				for _,route in ipairs(tcbs.routes) do
					if route.aspect then
						-- transform the signal aspect format
						local asp = route.aspect
						if type(asp.main) == "table" then
							atwarn("Transforming route aspect of signal",pts,"/",connid,"")
							if asp.main.free then
								asp.main = asp.main.speed
							else
								asp.main = 0
							end
							if asp.dst.free then
								asp.dst = asp.dst.speed
							else
								asp.dst = 0
							end
							asp.proceed_as_main = asp.shunt.proceed_as_main
							asp.shunt = asp.shunt.free
							-- Note: info table not transferred, it's not used right now
						end
					end
				end
			end
		end
	end
end

function ildb.save()
	local data = {
		tcbs = track_circuit_breaks,
		ts=track_sections,
		signalass = signal_assignments,
		rs_locks = advtrains.interlocking.route.rte_locks,
		rs_callbacks = advtrains.interlocking.route.rte_callbacks,
		influence_points = influence_points,
		npr_rails = advtrains.interlocking.npr_rails,
		tcbpts_conversion_applied = true, -- remark that legacy pos conversion has taken place
	}
	advtrains.interlocking.signal.save(data)
	return data
end

--
--[[
TCB data structure
{
-- This is the "A" side of the TCB
[1] = { -- Variant: with adjacent TCs.
	ts_id = <id> -- ID of the assigned track section
	xlink = <other sigd> -- If two sections of track are not physically joined but must function as one TS (e.g. knights move crossing), a bidirectional link can be added with exactly one other TCB.
	-- TS search will behave as if these two TCBs were physically connected.
	
	signal = <pos> -- optional: when set, routes can be set from this tcb/direction and signal
	-- aspect will be set accordingly.
	routeset = <index in routes> -- Route set from this signal. This is the entry that is cleared once
	-- train has passed the signal. (which will set the aspect to "danger" again)
	route_committed = <boolean> -- When setting/requesting a route, routetar will be set accordingly,
	-- while the signal still displays danger and nothing is written to the TCs
	-- As soon as the route can actually be set, all relevant TCs and turnouts are set and this field
	-- is set true, clearing the signal
	aspect = <asp> -- The aspect the signal should show. If this is nil, should show the most restrictive aspect (red)
	signal_name = <string> -- The human-readable name of the signal, only for documenting purposes
	routes = { <route definition> } -- a collection of routes from this signal
	route_auto = <boolean> -- When set, we will automatically re-set the route (designated by routeset)
	
	auto_block_signal_mode = <boolean> -- Simplified mode for simple block signals:
	-- Signal has only one route which is constantly re-set (route_auto is implied)
	-- Supposed to be used when only a single track section is ahead and it directly ends at the next signal
	-- UI only offers to enable or disable the signal
	-- ARS is implicitly disabled on the signal
},
-- This is the "B" side of the TCB
[2] = { -- Variant: end of track-circuited area (initial state of TC)
	ts_id = nil, -- this is the indication for end_of_interlocking
}
}

Route definition
routes = {
	[i] = {
		-- one table for each track section on the route
		-- Note that the section ID is implicitly inferred from the TCB
		1 = {
			locks = { -- component locks for this section of the route.
				800080008000 = st
			}
			next = S[(-23,9,0)/2] -- the start TCB of the next route segment (pointing forward)
			-- Signal info: relates to the signal at the start of this section:
			main_aspect = "_free" -- The main aspect that the route start signal is to show
			assign_dst = false  -- Whether to assign distant signal (affects only the signal at the start of the route)
								-- false: start signal does not set distant signal (the default), for long blocks
								-- it is assumed that the next main signal will have its own distant sig
								-- true: start signal sets distant signal to the next signal on the route with route_role "main" (typically the end signal)
								-- for short blocks where end signal doesn't have its own distant sig
			call_on = false	-- if true, when this route is set, section is allowed to be occupied by a train (but it must not have a route set in)
		}
		2 = {
			locks = {}
			-- if next is omitted, then there is no final TCB (e.g. a buffer)
		}
		name = "<the route name>"
		ars = { <ARS rule definition table> }
		use_rscache = false -- if true, the track section's rs_cache will be used to set locks in addition to the locks table
							-- this is disabled for legacy routes, but enabled for all new routes by default
		default_autoworking = false -- if true, when route is set autoworking will be by default on. Used for Blocksignal mode
	}
}

Track section
[id] = {
	name = "Some human-readable name"
	tc_breaks = { <signal specifier>,... } -- Bounding TC's (signal specifiers)
	rs_cache = { [startTcbPosEnc] = { [endTcbPosEnc] = { [componentPosEnc] = "state" } } }
	-- Saves the turnout states that need to be locked when a route is set from tcb#x to tcb#y
	-- e.g. "800080008005" = { "800080007EEA" = { "800080008000" = "st" } }
	--       start TCB           end TCB             switch pos
	-- Recalculated on every change via update_rs_cache
	-- Note that the tcb side number is not saved because it is unnecessary
	fixed_locks = { "800080008000" = "st" }
	-- table of fixed locks to be set for all routes thru this section (e.g. level crossings
	
	route = {
		origin = <signal>,  -- route origin
		entry = <sigd>,     -- supposed train entry point
		rsn = <string>,
		first = <bool>
	}
	route_post = {
		locks = {[n] = <pts>}
		next = <sigd>
	}
	-- Set whenever a route has been set through this TC. It saves the origin tcb id and side
	-- (=the origin signal). rsn is some description to be shown to the user
	-- first says whether to clear the routesetting status from the origin signal.
	-- locks contains the positions where locks are held by this ts.
	-- 'route' is cleared when train enters the section, while 'route_post' cleared when train leaves section.
	
	trains = {<id>, ...} -- Set whenever a train (or more) reside in this TC
	-- Note: The same train ID may be contained in this mapping multiple times, when it has entered the section in two different places.
}


Signal specifier (sigd) (a pair of TCB/Side):
{p = <pos>, s = <1/2>}

Signal Assignments: reverse lookup of signals assigned to TCBs
signal_assignments = {
[<signal pts>] = <sigd>
}
]]

-- Maximum scan length for track iterator
local TS_MAX_SCAN = 1000

-- basic functions

function ildb.get_tcb(pos)
	local pts = advtrains.encode_pos(pos)
	return track_circuit_breaks[pts]
end

function ildb.get_tcbs(sigd)
	local tcb = ildb.get_tcb(sigd.p)
	if not tcb then return nil end
	return tcb[sigd.s]
end

function ildb.get_ts(id)
	return track_sections[id]
end

-- retrieve full tables. Please use only read-only!
function ildb.get_all_tcb()
	return track_circuit_breaks
end
function ildb.get_all_ts()
	return track_sections
end

function tsrepair_notify(notify_pname, ...)
	if notify_pname then
		minetest.chat_send_player(notify_pname, advtrains.print_concat_table({"TS Check:",...}))
	end
end

-- Checks the consistency of the track section at the given position, attempts to autorepair track sections if they are inconsistent
-- There are 2 operation modes:
--		1: pos is NOT a TCB, tcb_connid MUST be nil
-- 		2: pos is a TCB, tcb_connid MUST be given
-- @param pos: the position to start from
-- @param tcb_connid: If provided node is a TCB, the direction in which to search
-- @param notify_pname: the player to notify about reparations
-- Returns:
-- ts_id - the track section that was found
-- nil - No track section exists
function ildb.check_and_repair_ts_at_pos(pos, tcb_connid, notify_pname, force_create)
	--atdebug("check_and_repair_ts_at_pos", pos, tcb_connid)
	-- check prereqs
	if ildb.get_tcb(pos) then
		if not tcb_connid then error("check_and_repair_ts_at_pos: Startpoint is TCB, must provide tcb_connid!") end
	else
		-- FIX 2025-01-07: If the checked pos is not a TCB, we always need to search in both directions, otherwise we errorneously split a ts
		tcb_connid = nil
	end
	-- STEP 1: Ensure that only one section is at this place
	-- get all TCBs adjacent to this 
	local all_tcbs = ildb.get_all_tcbs_adjacent(pos, tcb_connid)
	local first_ts = true
	local ts_id
	for _,sigd in ipairs(all_tcbs) do
		ildb.tcbs_ensure_ts_ref_exists(sigd)
		local tcbs_ts_id = sigd.tcbs.ts_id
		if first_ts then
			-- this one determines
			ts_id = tcbs_ts_id
			first_ts = false
		else
			-- these must be the same as the first
			if ts_id ~= tcbs_ts_id then
				-- inconsistency is found, repair it
				--atdebug("check_and_repair_ts_at_pos: Inconsistency is found!")
				tsrepair_notify(notify_pname, "Track section inconsistent here, repairing...")
				return ildb.repair_ts_merge_all(all_tcbs, force_create, notify_pname)
				-- Step2 check is no longer necessary since we just created that new section
			end
		end
	end
	-- only one found (it is either nil or a ts id)
	--atdebug("check_and_repair_ts_at_pos: TS consistent id=",ts_id,"")
	if not ts_id then
		if force_create and next(all_tcbs) then --ensure at least one tcb is in list
			return ildb.repair_ts_merge_all(all_tcbs, force_create, notify_pname)
		else
			--tsrepair_notify(notify_pname, "No track section found here.")
			return nil
			-- All TCBs agreed that there is no section here
		end
	end
	
	local ts = ildb.get_ts(ts_id)
	if not ts then
		-- This branch may never be reached, because ildb.tcbs_ensure_ts_ref_exists(sigd) is already supposed to clear out missing sections
		error("check_and_repair_ts_at_pos: Resolved to nonexisting section although ildb.tcbs_ensure_ts_ref_exists(sigd) was supposed to prevent this. Panic!")
	end
	ildb.purge_ts_tcb_refs(ts_id)
	-- STEP 2: Ensure that all_tcbs is equal to the track section's TCB list. If there are extra TCBs then the section should be split
	-- ildb.tcbs_ensure_ts_ref_exists(sigd) has already make sure that all tcbs are found in the ts's tc_breaks list
	-- That means it is sufficient to compare the LENGTHS of both lists, if one is longer then it is inconsistent
	if #ts.tc_breaks ~= #all_tcbs then
		--atdebug("check_and_repair_ts_at_pos: Partition is found!")
		tsrepair_notify(notify_pname, "Track section partition found, repairing...")
		return ildb.repair_ts_merge_all(all_tcbs, force_create, notify_pname)
	end
	--tsrepair_notify(notify_pname, "Found section", ts.name or ts_id, "here.")
	ildb.update_rs_cache(ts_id)
	return ts_id
end

-- Helper function to prevent duplicates
local function insert_sigd_if_not_present(tab, sigd)
	local found = false
	for _, ssigd in ipairs(tab) do
		if vector.equals(sigd.p, ssigd.p) and sigd.s==ssigd.s then
			found = true
		end
	end
	if not found then
		table.insert(tab, sigd)
	end
	return not found
end

-- Starting from a position, search all TCBs that can be reached from this position.
-- In a non-faulty setup, all of these should have the same track section assigned.
-- This function does not trigger a repair.
-- @param inipos: the initial position
-- @param inidir: the initial direction, or nil to search in all directions
-- @param per_track_callback: A callback function called with signature (pos, connid, bconnid) for every track encountered
-- Returns: a list of sigd's describing the TCBs found (sigd's point inward):
-- 		{p=<pos>, s=<side>, tcbs=<ref to tcbs table>}
function ildb.get_all_tcbs_adjacent(inipos, inidir, per_track_callback)
	--atdebug("get_all_tcbs_adjacent: inipos",inipos,"inidir",inidir,"")
	local found_sigd = {}
	local ti = advtrains.get_track_iterator(inipos, inidir, TS_MAX_SCAN, true)
	-- if initial start is TCBS and has xlink, need to add that to the TI
	local inisi = {p=inipos, s=inidir};
	local initcbs = ildb.get_tcbs(inisi)
	if initcbs then
		ildb.validate_tcb_xlink(inisi, true)
		if initcbs.xlink then
			-- adding the tcb will happen when this branch is retrieved again using ti:next_branch()
			--atdebug("get_all_tcbs_adjacent: Putting xlink Branch for initial node",initcbs.xlink)
			ti:add_branch(initcbs.xlink.p, initcbs.xlink.s)
		end
	end
	local pos, connid, bconnid, tcb
	while ti:has_next_branch() do
		pos, connid = ti:next_branch()
		--atdebug("get_all_tcbs_adjacent: BRANCH: ",pos, connid)
		bconnid = nil
		local is_branch_start = true
		repeat
			-- callback
			if per_track_callback then
				per_track_callback(pos, connid, bconnid)
			end
			tcb = ildb.get_tcb(pos)
			if tcb then
				local using_connid = bconnid
				-- found a tcb
				if is_branch_start then
					-- A branch cannot be a TCB, as that would imply that it was a turnout/crossing (illegal)
					-- UNLESS: (a) it is the start point or (b) it was added via xlink
					-- Then the correct conn to use is connid (pointing forward)
					--atdebug("get_all_tcbs_adjacent: Inserting TCB at branch start",pos, connid)
					using_connid = connid
				end
				-- add the sigd of this tcb and a reference to the tcb table in it
				--atdebug("get_all_tcbs_adjacent: Found TCB: ",pos, using_connid, "ts=", tcb[using_connid].ts_id)
				local si = {p=pos, s=using_connid, tcbs=tcb[using_connid]}
				-- if xlink exists, add it now (only if we are not in branch start)
				ildb.validate_tcb_xlink(si, true)
				if not is_branch_start and si.tcbs.xlink then
					-- adding the tcb will happen when this branch is retrieved again using ti:next_branch()
					--atdebug("get_all_tcbs_adjacent: Putting xlink Branch",si.tcbs.xlink)
					ti:add_branch(si.tcbs.xlink.p, si.tcbs.xlink.s)
				end
				insert_sigd_if_not_present(found_sigd, si)
				if not is_branch_start then
					break
				end
			end
			pos, connid, bconnid = ti:next_track()
			is_branch_start = false
			--atdebug("get_all_tcbs_adjacent: TRACK: ",pos, connid, bconnid)
		until not pos
	end
	return found_sigd
end

-- Called by frontend functions when multiple tcbs's that logically belong to one section have been determined to have different sections
-- Parameter is the output of ildb.get_all_tcbs_adjacent(pos)
-- Returns the ID of the track section that results after the merge
function ildb.repair_ts_merge_all(all_tcbs, force_create, notify_pname)
	--atdebug("repair_ts_merge_all: Instructed to merge sections of following TCBs:")
	-- The first loop does the following for each TCBS:
	-- a) Store the TS ID in the set of TS to update
	-- b) Set the TS ID to nil, so that the TCBS gets removed from the section
	local ts_to_update = {}
	local ts_name_repo = {}
	local any_ts = false
	for _,sigd in ipairs(all_tcbs) do
		local ts_id = sigd.tcbs.ts_id
		--atdebug(sigd, "ts=", ts_id)
		if ts_id then
			local ts = track_sections[ts_id]
			if ts then
				any_ts = true
				ts_to_update[ts_id] = true
				-- if nonstandard name, store this
				if ts.name and not string.match(ts.name, "^Section") then
					ts_name_repo[#ts_name_repo+1] = ts.name
				end
			end
		end
		sigd.tcbs.ts_id = nil
	end
	if not any_ts and not force_create then
		-- nothing to do at all, just no interlocking. Why were we even called
		--atdebug("repair_ts_merge_all: No track section present, will not create a new one")
		return nil
	end
	-- Purge every TS in turn. TS's that are now empty will be deleted. TS's that still have TCBs will be kept
	for ts_id, _ in pairs(ts_to_update) do
		local remain_ts = ildb.purge_ts_tcb_refs(ts_id)
	end
	-- Create a new fresh track section with all the TCBs we have in our collection
	local new_ts_id, new_ts = ildb.create_ts_from_tcb_list(all_tcbs)
	tsrepair_notify(notify_pname, "Created track section",new_ts_id,"from",#all_tcbs,"TCBs")
	return new_ts_id
end

-- For the specified TS, go through the list of TCBs and purge all TCBs that have no corresponding backreference in their TCBS table.
-- If the track section ends up empty, it is deleted in this process.
-- Should the track section still exist after the purge operation, it is returned.
function ildb.purge_ts_tcb_refs(ts_id)
	local ts = track_sections[ts_id]
	if not ts then
		return nil
	end
	local has_changed = false
	local i = 1
	while ts.tc_breaks[i] do
		-- get TCBS
		local sigd = ts.tc_breaks[i]
		local tcbs = ildb.get_tcbs(sigd)
		if tcbs then
			if tcbs.ts_id == ts_id then
				-- this one is legit
				i = i+1
			else
				-- this one is to be purged
				--atdebug("purge_ts_tcb_refs(",ts_id,"): purging",sigd,"(backreference = ",tcbs.ts_id,")")
				table.remove(ts.tc_breaks, i)
				has_changed = true
			end
		else
			-- if not tcbs: was anyway an orphan, remove it
			--atdebug("purge_ts_tcb_refs(",ts_id,"): purging",sigd,"(referred nonexisting TCB)")
			table.remove(ts.tc_breaks, i)
			has_changed = true
		end
	end
	if #ts.tc_breaks == 0 then
		-- remove the section completely
		--atdebug("purge_ts_tcb_refs(",ts_id,"): after purging, the section is empty, is being deleted")
		track_sections[ts_id] = nil
		return nil
	else
		if has_changed then
			-- needs to update route cache
			ildb.update_rs_cache(ts_id)
		end
		return ts
	end
end

-- For the specified TCBS, make sure that the track section referenced by it
-- (a) exists and
-- (b) has a backreference to this TCBS stored in its tc_breaks list
function ildb.tcbs_ensure_ts_ref_exists(sigd)
	local tcbs = sigd.tcbs or ildb.get_tcbs(sigd)
	if not tcbs or not tcbs.ts_id then return end
	local ts = ildb.get_ts(tcbs.ts_id)
	if not ts then
		--atdebug("tcbs_ensure_ts_ref_exists(",sigd,"): TS does not exist, setting to nil")
		-- TS is deleted, clear own ts id
		tcbs.ts_id = nil
		return
	end
	local did_insert = insert_sigd_if_not_present(ts.tc_breaks, {p=sigd.p, s=sigd.s})
	if did_insert then
		--atdebug("tcbs_ensure_ts_ref_exists(",sigd,"): TCBS was missing reference in TS",tcbs.ts_id)
		ildb.update_rs_cache(tcbs.ts_id)
	end
end

function ildb.create_ts_from_tcb_list(sigd_list)
	local id = advtrains.random_id(8)
	
	while track_sections[id] do
		id = advtrains.random_id(8)
	end
	--atdebug("create_ts_from_tcb_list: sigd_list=",sigd_list, "new ID will be ",id)

	local tcbr = {}
	-- makes a copy of the sigd list, for use in repair mechanisms where sigd may contain a tcbs field which we dont want
	for _, sigd in ipairs(sigd_list) do
		table.insert(tcbr, {p=sigd.p, s=sigd.s})
		local tcbs = sigd.tcbs or ildb.get_tcbs(sigd)
		if tcbs.ts_id then
			error("Trying to create TS with TCBS that is already assigned to other section")
		end
		tcbs.ts_id = id
	end
	
	local new_ts = {
		tc_breaks = tcbr
	}
	track_sections[id] = new_ts
	-- update the TCB markers
	for _, sigd in ipairs(sigd_list) do
		advtrains.interlocking.show_tcb_marker(sigd.p)
	end
	
	
	ildb.update_rs_cache(id)
	return id, new_ts
end

-- RS CACHE --

--[[
node_from_to_list - cache of from-to connid mappings and their associated state.
Acts like a cache, built on demand by ildb.get_possible_out_connids(nodename)
node_name = {
	from_connid = {
		to_connid = state
	}
}
]]
local node_from_to_state_cache = {}

function ildb.get_possible_out_connids(node_name, in_connid)
	if not node_from_to_state_cache[node_name] then
		node_from_to_state_cache[node_name] = {}
	end
	local nt = node_from_to_state_cache[node_name]
	if not nt[in_connid] then
		local ta = {}
		--atdebug("Node From/To State Cache: Caching for ",node_name,"connid",in_connid)
		local ndef = minetest.registered_nodes[node_name]
		if ndef.advtrains.node_state_map then
			for state, tnode in pairs(ndef.advtrains.node_state_map) do
				local tndef = minetest.registered_nodes[tnode]
				-- verify that the conns table is identical - this is purely to catch setup errors!
				if not tndef.at_conns or not tndef.at_conn_map then
					--atdebug("ndef:",ndef,", tndef:",tndef)
					error("In AT setup for node "..tnode..": Node set as state "..state.." of "..node_name.." in state_map, but is missing at_conns/at_conn_map!")
				end
				if #ndef.at_conns ~= #tndef.at_conns then
					--atdebug("ndef:",ndef,", tndef:",tndef)
					error("In AT setup for node "..tnode..": Conns table does not match that of "..node_name.." (of which this is state "..state..")")
				end
				for connid=1,#ndef.at_conns do
					if ndef.at_conns[connid].c ~= tndef.at_conns[connid].c then
						--atdebug("ndef:",ndef,", tndef:",tndef)
						error("In AT setup for node "..tnode..": Conns table does not match that of "..node_name.." (of which this is state "..state..")")
					end
				end
				-- do the actual caching by looking at the conn_map
				local target_connid = tndef.at_conn_map[in_connid]
				if ta[target_connid] then
					-- Select the variant for which the other way would back-connect. This way, turnouts will switch to the appropriate branch if the train joins
					local have_back_conn = (tndef.at_conn_map[target_connid])==in_connid
					--atdebug("Found second state mapping",in_connid,"-",target_connid,"have_back_conn=",have_back_conn)
					if have_back_conn then
						--atdebug("Overwriting",in_connid,"-",target_connid,"=",state)
						ta[target_connid] = state
					end
				else
					--atdebug("Setting",in_connid,"-",target_connid,"=",state)
					ta[target_connid] = state
				end
			end
		else
			error("Node From/To State Cache: "..node_name.." doesn't have a state map, is not a switchable track! Panic!")
		end
		nt[in_connid] = ta
	end
	return nt[in_connid]
end

local function recursively_find_routes(s_pos, s_connid, locks_found, result_table, scan_limit)
	--atdebug("Recursively restarting at ",s_pos, s_connid, "limit left", scan_limit)
	local ti = advtrains.get_track_iterator(s_pos, s_connid, scan_limit, false)
	local pos, connid, bconnid = ti:next_branch()
	pos, connid, bconnid = ti:next_track()-- step once to get ahead of previous turnout
	local last_pos
	while pos do -- this stops the loop when either the track end is reached or the limit is hit
		local node = advtrains.ndb.get_node_or_nil(pos)
		--atdebug("Walk ",pos, "nodename", node.name, "entering at conn",bconnid)
		local ndef = minetest.registered_nodes[node.name]
		if ndef.advtrains and ndef.advtrains.node_state_map then
			-- Stop, this is a switchable node. Find out which conns we can go at
			--atdebug("Found turnout ",pos, "nodename", node.name, "entering at conn",bconnid)
			local pts = advtrains.encode_pos(pos)
			if locks_found[pts] then
				-- we've been here before. Stop
				--atdebug("Was already seen! returning")
				return
			end
			local out_conns = ildb.get_possible_out_connids(node.name, bconnid)
			-- note 2025-01-06: get_possible_out_connids contains some logic so that the correct switch state is selected even if the turnout is entered from the branch side (see "have_back_conn")
			for oconnid, state in pairs(out_conns) do
				--atdebug("Going in direction",oconnid,"state",state)
				locks_found[pts] = state
				recursively_find_routes(pos, oconnid, locks_found, result_table, ti.limit)
				locks_found[pts] = nil
			end
			return
		end
		--otherwise, this might be a tcb
		local tcb = ildb.get_tcb(pos)
		if tcb then
			-- we found a tcb, store the current locks in the result_table
			local end_pkey = advtrains.encode_pos(pos)
			--atdebug("Found end TCB", pos, end_pkey,", returning")
			if result_table[end_pkey] then
				atwarn("While caching track section routing, found multiple route paths within same track section. Only first one found will be used")
			else
				result_table[end_pkey] = table.copy(locks_found)
			end
			return
		end
		-- Go forward
		last_pos = pos
		pos, connid, bconnid = ti:next_track()
	end 
	--atdebug("recursively_find_routes: Reached track end or limit at", last_pos, ". This path is not saved, returning")
end

-- Updates the turnout cache of the given track section
function ildb.update_rs_cache(ts_id)
	local ts = ildb.get_ts(ts_id)
	if not ts then
		error("Update TS Cache called with nonexisting ts_id "..(ts_id or "nil"))
	end
	local rscache = {}
	--atdebug("== Running update_rs_cache for ",ts_id) 
	-- start on every of the TS's TCBs, walk the track forward and store locks along the way
	for start_tcbi, start_tcbs in ipairs(ts.tc_breaks) do
		start_pkey = advtrains.encode_pos(start_tcbs.p)
		rscache[start_pkey] = {}
		--atdebug("Starting for ",start_tcbi, start_tcbs)
		local locks_found = {}
		local result_table = {}
		
		recursively_find_routes(start_tcbs.p, start_tcbs.s, locks_found, result_table, TS_MAX_SCAN)
		-- now result_table contains found route locks. Match them with the other TCBs we have in this section
		for end_tcbi, end_tcbs in ipairs(ts.tc_breaks) do
			if end_tcbi ~= start_tcbi then
				end_pkey = advtrains.encode_pos(end_tcbs.p)
				if result_table[end_pkey] then
					--atdebug("Set RSCache entry",end_pkey.."-"..end_pkey,"=",result_table[end_pkey])
					local lockstab = result_table[end_pkey]
					if ts.fixed_locks then -- include the sections fixedlocks if present
						for pts, st in pairs(ts.fixed_locks) do lockstab[pts] = st end
					end
					rscache[start_pkey][end_pkey] = lockstab
					result_table[end_pkey] = nil
				end
			end
		end
		-- warn about superfluous entry
		for sup_end_pkey, sup_entry in pairs(result_table) do
			atwarn("In update_rs_cache for section",ts_id,"found superfluous endpoint",sup_end_pkey,"->",sup_entry)
		end
	end
	ts.rs_cache = rscache
	--atdebug("== Done update_rs_cache for ",ts_id, "result:",rscache) 
end


--- DB API functions

local lntrans = { "A", "B" }
function ildb.sigd_to_string(sigd)
	return minetest.pos_to_string(sigd.p).." / "..lntrans[sigd.s]
end

-- Create a new TCB at the position and update/repair the adjoining sections
function ildb.create_tcb_at(pos)
	--atdebug("create_tcb_at",pos)
	local pts = advtrains.encode_pos(pos)
	track_circuit_breaks[pts] = {[1] = {}, [2] = {}}
	local all_tcbs_1 = ildb.get_all_tcbs_adjacent(pos, 1)
	--atdebug("TCBs on A side",all_tcbs_1)
	local all_tcbs_2 = ildb.get_all_tcbs_adjacent(pos, 2)
	--atdebug("TCBs on B side",all_tcbs_2)
	-- perform TS repair
	ildb.repair_ts_merge_all(all_tcbs_1, false)
	ildb.repair_ts_merge_all(all_tcbs_2, false)
end

-- Remove TCB at the position and update/repair the now joined section
--   skip_tsrepair: should be set to true when the rail node at the TCB position is already gone.
--                  Assumes the track sections are now separated and does not attempt the repair process.
function ildb.remove_tcb_at(pos, pname, skip_tsrepair)
	--atdebug("remove_tcb_at",pos)
	local pts = advtrains.encode_pos(pos)
	local old_tcb = track_circuit_breaks[pts]
	-- unassign signals if defined
	for connid=1,2 do
		if old_tcb[connid].signal then
			ildb.set_sigd_for_signal(old_tcb[connid].signal, nil)
		end
	end
	track_circuit_breaks[pts] = nil
	-- purge the track sections adjacent
	if old_tcb[1].ts_id then
		ildb.purge_ts_tcb_refs(old_tcb[1].ts_id)
	end
	if old_tcb[2].ts_id then
		ildb.purge_ts_tcb_refs(old_tcb[2].ts_id)
	end
	-- update xlink partners
	if old_tcb[1].xlink then
		ildb.validate_tcb_xlink(old_tcb[1].xlink)
	end
	if old_tcb[2].xlink then
		ildb.validate_tcb_xlink(old_tcb[2].xlink)
	end
	advtrains.interlocking.remove_tcb_marker(pos)
	-- If needed, merge the track sections here
	if not skip_tsrepair then
		ildb.check_and_repair_ts_at_pos(pos, nil, pname)
	end
	return true
end

-- Xlink: Connecting not-physically-connected sections handling

-- Ensures that the xlink of this tcbs is bidirectional
function ildb.validate_tcb_xlink(sigd, suppress_repairs)
	local tcbs = sigd.tcbs or ildb.get_tcbs(sigd)
	local osigd = tcbs.xlink
	if not osigd then return end
	local otcbs = ildb.get_tcbs(tcbs.xlink)
	if not otcbs then
		--atdebug("validate_tcb_xlink",sigd,": Link partner ",osigd,"orphaned")
		tcbs.xlink = nil
		if not suppress_repairs then
			ildb.check_and_repair_ts_at_pos(sigd.p, sigd.s)
		end
		return
	end
	if otcbs.xlink then
		if not vector.equals(otcbs.xlink.p, sigd.p) or otcbs.xlink.s~=sigd.s then
			--atdebug("validate_tcb_xlink",sigd,": Link partner ",osigd,"backreferencing to someone else (namely",otcbs.xlink,") clearing it")
			tcbs.xlink = nil
			if not suppress_repairs then
				ildb.check_and_repair_ts_at_pos(sigd.p, sigd.s)
				--atdebug("validate_tcb_xlink",sigd,": Link partner ",osigd," was backreferencing to someone else, now updating that")
				ildb.validate_tcb_xlink(osigd)
			end
		end
	else
		--atdebug("validate_tcb_xlink",sigd,": Link partner ",osigd,"wasn't backreferencing, clearing it")
		tcbs.xlink = nil
		if not suppress_repairs then
			ildb.check_and_repair_ts_at_pos(sigd.p, sigd.s)
		end
	end
end

function ildb.add_tcb_xlink(sigd1, sigd2)
	--("add_tcb_xlink",sigd1, sigd2)
	local tcbs1 = sigd1.tcbs or ildb.get_tcbs(sigd1)
	local tcbs2 = sigd2.tcbs or ildb.get_tcbs(sigd2)
	if vector.equals(sigd1.p, sigd2.p) then
		--atdebug("add_tcb_xlink Cannot xlink with same TCB")
		return
	end
	if not tcbs1 or not tcbs2 then
		--atdebug("add_tcb_xlink TCBS doesnt exist")
		return
	end
	if tcbs1.xlink or tcbs2.xlink then
		--atdebug("add_tcb_xlink One already linked")
		return
	end
	-- apply link
	tcbs1.xlink = {p=sigd2.p, s=sigd2.s}
	tcbs2.xlink = {p=sigd1.p, s=sigd1.s}
	-- update section. It should be sufficient to call update only once because the TCBs are linked anyway now
	ildb.check_and_repair_ts_at_pos(sigd1.p, sigd1.s)
end

function ildb.remove_tcb_xlink(sigd)
	--atdebug("remove_tcb_xlink",sigd)
	-- Validate first. If Xlink is gone already then, nothing to do
	ildb.validate_tcb_xlink(sigd)
	-- Checking all of these already done by validate
	local tcbs = sigd.tcbs or ildb.get_tcbs(sigd)
	local osigd = tcbs.xlink
	if not osigd then
		-- validate already cleared us
		--atdebug("remove_tcb_xlink: Already gone by validate")
		return
	end
	local otcbs = ildb.get_tcbs(tcbs.xlink)
	-- clear it
	otcbs.xlink = nil
	tcbs.xlink = nil
	-- Update section for ourself and the other one
	ildb.check_and_repair_ts_at_pos(sigd.p, sigd.s)
	ildb.check_and_repair_ts_at_pos(osigd.p, osigd.s)
end

function ildb.create_ts_from_tcbs(sigd)
	--atdebug("create_ts_from_tcbs",sigd)
	local all_tcbs = ildb.get_all_tcbs_adjacent(sigd.p, sigd.s)
	ildb.repair_ts_merge_all(all_tcbs, true)
end

-- Remove the given track section, leaving its TCBs with no section assigned
function ildb.remove_ts(ts_id)
	--atdebug("remove_ts",ts_id)
	local ts = track_sections[ts_id]
	if not ts then
		error("remove_ts: "..ts_id.." doesn't exist")
	end
	while ts.tc_breaks[i] do
		-- get TCBS
		local sigd = ts.tc_breaks[i]
		local tcbs = ildb.get_tcbs(sigd)
		if tcbs then
			--atdebug("cleared TCB",sigd)
			tcbs.ts_id = nil
		else
			--atdebug("orphan TCB",sigd)
		end
		i = i+1
	end
	track_sections[ts_id] = nil
end

-- Returns true if it is allowed to modify any property of a track section, such as
-- - removing TCBs
-- - merging and dissolving sections
-- As of now the action will be denied if a route is set or if a train is in the section.
function ildb.may_modify_ts(ts)
	if ts.route or ts.route_post or (ts.trains and #ts.trains>0) then
		return false
	end
	return true
end


function ildb.may_modify_tcbs(tcbs)
	if tcbs.ts_id then
		local ts = ildb.get_ts(tcbs.ts_id)
		if ts and not ildb.may_modify_ts(ts) then
			return false
		end
	end
	return true
end


-- Signals/IP --


-- returns the sigd the signal at pos belongs to, if this is known
function ildb.get_sigd_for_signal(pos)
	local pts = advtrains.roundfloorpts(pos)
	local sigd = signal_assignments[pts]
	if sigd then
		if not ildb.get_tcbs(sigd) then
			signal_assignments[pts] = nil
			return nil
		end
		return sigd
	end
	return nil
end
function ildb.set_sigd_for_signal(pos, sigd) -- do not use!
	local pts = advtrains.roundfloorpts(pos)
	signal_assignments[pts] = sigd
end

-- Assign the signal at pos to the given TCB side.
function ildb.assign_signal_to_tcbs(pos, sigd)
	local tcbs = ildb.get_tcbs(sigd)
	assert(tcbs, "assign_signal_to_tcbs invalid sigd!")
	tcbs.signal = pos
	if not tcbs.routes then
		tcbs.routes = {}
	end
	ildb.set_sigd_for_signal(pos, sigd)
end

-- unassign the signal from the given sigd (looks in tcbs.signal for the signalpos)
function ildb.unassign_signal_for_tcbs(sigd)
	local tcbs = advtrains.interlocking.db.get_tcbs(sigd)
	if not tcbs then return end
	local pos = tcbs.signal
	if not pos then return end
	ildb.set_sigd_for_signal(pos, nil)
	tcbs.signal = nil
	tcbs.route_aspect = nil
	tcbs.route_remote = nil
end

-- checks if there's any influence point set to this position
-- if purge is true, checks whether the associated signal still exists
-- and deletes the ip if not.
function ildb.is_ip_at(pos, purge)
	local pts = advtrains.roundfloorpts(pos)
	if influence_points[pts] then
		if purge then
			-- is there still a signal assigned to it?
			for connid, sigpos in pairs(influence_points[pts]) do
				local asp = advtrains.interlocking.signal.get_aspect_info(sigpos)
				if not asp then
					atlog("Clearing orphaned signal influence point", pts, "/", connid)
					ildb.clear_ip_signal(pts, connid)
				end
			end
			-- if there's no side left after purging, return false
			if not influence_points[pts] then return false end
		end
		return true
	end
	return false
end

-- checks if a signal is influencing here
function ildb.get_ip_signal(pts, connid)
	if influence_points[pts] then
		return influence_points[pts][connid]
	end
end

-- Tries to get aspect to obey here, if there
-- is a signal ip at this location
-- auto-clears invalid assignments
function ildb.get_ip_signal_asp(pts, connid)
	local p = ildb.get_ip_signal(pts, connid)
	if p then
		local asp = advtrains.interlocking.signal.get_aspect_info(p)
		if not asp then
			atlog("Clearing orphaned signal influence point", pts, "/", connid)
			ildb.clear_ip_signal(pts, connid)
			return nil
		end
		return asp, p
	end
	return nil
end

-- set signal assignment.
function ildb.set_ip_signal(pts, connid, spos)
	ildb.clear_ip_by_signalpos(spos)
	if not influence_points[pts] then
		influence_points[pts] = {}
	end
	influence_points[pts][connid] = spos
end
-- clear signal assignment.
function ildb.clear_ip_signal(pts, connid)
	influence_points[pts][connid] = nil
	for _,_ in pairs(influence_points[pts]) do
		return
	end
	influence_points[pts] = nil
end

function ildb.get_ip_by_signalpos(spos)
	for pts,tab in pairs(influence_points) do
		for connid,pos in pairs(tab) do
			if vector.equals(pos, spos) then
				return pts, connid
			end
		end
	end
end
function ildb.check_for_duplicate_ip(spos)
	local main_ip_found = false
	-- first pass: check for duplicates
	for pts,tab in pairs(influence_points) do
		for connid,pos in pairs(tab) do
			if vector.equals(pos, spos) then
				if main_ip_found then
					atwarn("Signal at",spos,": Deleting duplicate signal influence point at",pts,"/",connid)
					tab[connid] = nil
				end
				main_ip_found = true
			end
		end
	end
	-- second pass: delete empty tables
	for pts,tab in pairs(influence_points) do
		if not tab[1] and not tab[2] then -- only those two connids may exist
			influence_points[pts] = nil
		end
	end
end

-- clear signal assignment given the signal position
function ildb.clear_ip_by_signalpos(spos)
	local pts, connid = ildb.get_ip_by_signalpos(spos)
	if pts then ildb.clear_ip_signal(pts, connid) end
end


advtrains.interlocking.db = ildb




