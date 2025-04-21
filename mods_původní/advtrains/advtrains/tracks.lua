-- tracks.lua
-- rewritten with advtrains 2.5 according to new track registration system


--[[

Tracks in advtrains are defined by the node definition. They must have at least 2 connections, but can have any number.
Switchable nodes (turnouts, single/double-slip switches) are implemented by having a separate node (node name) for each of the possible states.

	minetest.register_node(nodename, {
	... usual node definition ...
	groups = {
		advtrains_track = 1,
		advtrains_track_<tracktype>=1
		^- these groups tell that the node is a track
		not_blocking_trains=1,
		^- this group tells that the node should not block trains although it's walkable.
	},
	
	at_rail_y = 0,
	^- Height of this rail node (the y position of a wagon that stands centered on this rail)
	at_conns = {
		  [1] = { c=0..15, y=0..1 },
		  [2] = { c=0..15, y=0..1 },
		( [3] = { c=0..15, y=0..1 }, )
		( [4] = { c=0..15, y=0..1 }, )
		( ... )
	}
	^- Connections of this rail. There are two general cases:
	   a) SIMPLE TRACK - the track has exactly 2 connections, and does not feature a turnout, crossing or other contraption
	      For simple tracks, except for the at_conns table no further setup needs to be specified. A train entering on conn 1 will go out at conn 2 and vice versa.
		  A track with only one connection defined is not permitted.
	   b) COMPOUND TRACK - the track has more than 2 connections
	      This will be used for turnouts and crossings. Tracks with more than 2 conns MUST define 'at_conn_map'.
		  Switchable nodes, whose state can be changed (e.g. turnouts) MUST define a 'state_map' within the advtrains table as well.
		  This differs from the behavior up until 2.4.2, where the conn mapping was fixed.
	^- Connection definition:
	   - c is the direction of the connection (0-16). For the mapping to world directions see helpers.lua.
	   - Connections will be auto-rotated with param2 of the node (horizontal, param2 values 0-3 only)
	   - y is the height of the connection (rail will only connect when this matches)
	^- The index of a connection inside the conns table (1, 2, 3, ...) is referred throughout advtrains code as 'connid'
	^- IMPORTANT: For switchable nodes (any kind of turnout), it is crucial that for all of the node's variants the at_conns table stays the same. See below.
	   
	at_conn_map = {
		[1] = 2,
		[2] = 1,
		[3] = 1,
	}
	^- Connection map of this rail. It specifies when a train enters the track on connid X, on which connid it will leave
	   This field MUST be specified when the number of connections in at_conns is greater than 2
	   This field may, and obviously will, vary between nodes for switchable nodes.
	
	can_dig = advtrains.track_can_dig_callback
	after_dig_node = advtrains.track_update_callback
	after_place_node = advtrains.track_update_callback
	^- the code in these 3 default minetest API functions is required for advtrains to work, however you can add your own code
	
	on_rightclick = advtrains.state_node_on_rightclick_callback
	^- Must be added if the node is a turnout and if it should be switched by right-click. It will cause the turnout to be switched to next_state.
	
	advtrains = {
		on_train_enter=function(pos, train_id, train, index) end
		^- called when a train enters the rail
		on_train_leave=function(pos, train_id, train, index) end
		^- called when a train leaves the rail
		
		-- The following function is only in effect when interlocking is enabled:
		on_train_approach = function(pos, train_id, train, index, has_entered, lzbdata)
		^- called when a train is approaching this position, called exactly once for every path recalculation (which can happen at any time)
		^- This is called so that if the train would start braking now, it would come to halt about(wide approx) 5 nodes before the rail.
		^- has_entered: when true, the train is already standing on this node with its front tip, and the enter callback has already been called.
		   Possibly, some actions need not to be taken in this case. Only set if it's the very first node the train is standing on.
		^- lzbdata should be ignored and nothing should be assigned to it
		
		-- The following information is required if the node is a turnout (e.g. can be switched into different positions)
		node_state = "st"
		^- The name of the state this node represents
		^- Conventions for this field are as follows:
		   - Two-way straight/turn switches: 'st'=straight branch, 'cr'=diverting/turn branch
		   - 3-way turnouts, Y-turnouts: 'l'=left branch, 's'=straight branch, 'r'=right branch
		   
		node_next_state = "cr"
		^- The name of the state that the turnout should be switched to when it is right-clicked
		
		node_fallback_state = "st"
		^- The name of the state that the turnout should "fall back" to when it is released
		   Only used by the interlocking system, when a route on the node is released it is switched back to this state.
		
		node_state_map = {
			["st"] = "<node name of the st variant>",
			["cr"] = "<node name of the cr variant>",
			... etc ...
		}
		^- Map of state name to the appropriate node name that should be set by advtrains when a switch is requested
		   Note that for all of those nodes, the at_conns table must be identical (however the conn_map will vary)
		   
		node_on_switch_state = function(pos, node, oldstate, newstate)
		^- Called when the node state is switched by advtrains, after the node replacement has commenced.
		
		Turnout switching can happen programmatically via advtrains.setstate(pos, state), via user right_click or via the interlocking system.
		In no other situation is it permissible to exchange track nodes in-place, unless both at_conns and at_conn_map stay identical.
		
		Note that the fields node_state, node_next_state and node_state_map completely replace the getstate/setstate functions.
		There must be a one-to-one mapping between states and node names and no function can be defined for state switching.
		This principle enables the seamless working of the interlocking autorouter and reduces failure points.
		The node_state_* system can also be used as drop-in replacement for the passive-API-enabled nodes (andrews-cross, mesecon_switch etc.)
		The advtrains API functions advtrains.getstate() and advtrains.setstate() remain the programmatic access points, but will now utilize the new state system.
		
		
		trackworker_next_rot = <nodename of next rotation step>,
		^- if set, right-click with trackworker will set this node
		trackworker_rot_incr_param2 = true
		^- if set, trackworker will increase node param2 on rightclick
		
		trackworker_next_var = <nodename of next variant>
		^- if set, left-click with trackworker will set this node
	}
	})

]]--

-- This file provides some utilities to register tracks, but tries to not get into the way too much


function advtrains.track_can_dig_callback(pos, player)
	local ok, reason = advtrains.can_dig_or_modify_track(pos)
	if not ok and player then
		minetest.chat_send_player(player:get_player_name(), attrans("This track can not be removed!") .. " " .. reason)
	end
	return ok
end

function advtrains.track_update_callback(pos)
	advtrains.ndb.update(pos)
end

function advtrains.state_node_on_rightclick_callback(pos, node, player)
	if advtrains.check_turnout_signal_protection(pos, player:get_player_name()) then
		local ndef = minetest.registered_nodes[node.name]
		if ndef and ndef.advtrains and ndef.advtrains.node_next_state then
			advtrains.setstate(pos, ndef.advtrains.node_next_state, node)
			advtrains.log("Switch", player:get_player_name(), pos)
		end
	end
end

-- advtrains.register_node_4rot(name, nodedef)
-- Registers four rotations for the node defined by nodedef (0°, 30°, 45° and 60°; the 4 90°-steps are already handled by the param2, resulting in 16 directions total).
-- You must provide the definition for the base node, and certain fields are altered automatically for the 3 additional rotations:
--  name: appends the suffix "_30", "_45" or "_60"
--  description: appends the rotation (human-readable) in parenthesis
--  tiles_prefix: if defined, "tiles" field will be set as prefix..rotationExtension..".png"
--  mesh_prefix, mesh_suffix: if defined, "mesh" field will be set as prefix..rotationExtension..suffix
--  at_conns: are rotated according to the node rotation
--  node_state_map, trackworker_next_var: appends the suffix appropriately.
--  groups: applies save_in_at_nodedb and not_blocking_trains groups if not already present
-- The nodes are registered in the trackworker to be rotated with right-click.
-- definition_mangling_function is an optional parameter. For each of the 4 rotations, it gets passed the modified node definition and may perform final modifications to it.
--  signature: function definition_mangling_function(name, nodedef, rotationIndex, rotationSuffix)
--  Example usage: define the setstate function of turnouts (if that is not done via the "automatic" way of state_node_map)
local rotations = {
	{i = 0, s = "",    h = " (0)",  n = "_30"},
	{i = 1, s = "_30", h = " (30)", n = "_45"},
	{i = 2, s = "_45", h = " (45)", n = "_60"},
	{i = 3, s = "_60", h = " (60)", n = ""},
}
function advtrains.register_node_4rot(ori_name, ori_ndef, definition_mangling_function)
	for _, rot in ipairs(rotations) do
		local ndef = table.copy(ori_ndef)
		if ori_ndef.advtrains then
			-- make sure advtrains table is deep-copied because we may need to replace node_state_map
			ndef.advtrains = table.copy(ori_ndef.advtrains)
		else
			ndef.advtrains = {} -- we need the table later for trackworker
		end
		-- Perform the name mangling
		local suffix = rot.s
		local name = ori_name..suffix
		ndef.description = ori_ndef.description .. rot.h
		if ori_ndef.tiles_prefix then
			ndef.tiles = { ori_ndef.tiles_prefix .. suffix .. ".png" }
		end
		if ori_ndef.mesh_prefix then
			ndef.mesh = ori_ndef.mesh_prefix .. suffix .. ori_ndef.mesh_suffix
		end
		-- rotate connections
		if ori_ndef.at_conns then
			ndef.at_conns = advtrains.rotate_conn_by(ori_ndef.at_conns, rot.i)
		end
		-- update node state map if present
		if ori_ndef.advtrains then
			if ori_ndef.advtrains.node_state_map then
				local new_nsm = {}
				for state, nname in pairs(ori_ndef.advtrains.node_state_map) do
					new_nsm[state] = nname .. suffix
				end
				ndef.advtrains.node_state_map = new_nsm
			end
			if ori_ndef.advtrains.trackworker_next_var then
				ndef.advtrains.trackworker_next_var = ori_ndef.advtrains.trackworker_next_var .. suffix
			end
			-- apply trackworker rot field
			ndef.advtrains.trackworker_next_rot = ori_name .. rot.n
			ndef.advtrains.trackworker_rot_incr_param2 = (rot.n=="")
		end
		-- apply groups
		ndef.groups.save_in_at_nodedb = 1
		ndef.groups.not_blocking_trains = 1
		
		-- give the definition mangling function an option to do some adjustments
		if definition_mangling_function then
			definition_mangling_function(name, ndef, rot.i, suffix)
		end
		
		-- register node
		minetest.register_node(":"..name, ndef)
		
		-- if this has the track_place_group set, register as a candidate for the track_place_group
		if ndef.advtrains.track_place_group then
			advtrains.trackplacer.register_candidate(ndef.advtrains.track_place_group, name, ndef, ndef.advtrains.track_place_single, true)
		end
	end
end

-- track-related helper functions

function advtrains.is_track(nodename)
	if not minetest.registered_nodes[nodename] then
		return false
	end
	local nodedef=minetest.registered_nodes[nodename]
	if nodedef and nodedef.groups.advtrains_track then
		return true
	end
	return false
end

-- returns the connection tables of the track with given node details
-- returns: conns table, railheight, conn_map table
function advtrains.get_track_connections(name, param2)
	local nodedef=minetest.registered_nodes[name]
	if not nodedef then atprint(" get_track_connections couldn't find nodedef for nodename "..(name or "nil")) return nil end
	local noderot=param2
	if not param2 then noderot=0 end
	if noderot > 3 then atprint(" get_track_connections: rail has invaild param2 of "..noderot) noderot=0 end
	
	if not nodedef.at_conns then
		return nil
	end
	--atdebug("Track connections of ",name,param2,":",nodedef.at_conns)
	return advtrains.rotate_conn_by(nodedef.at_conns, noderot*AT_CMAX/4), (nodedef.at_rail_y or 0), nodedef.at_conn_map
end

-- Function called when a track is about to be dug or modified by the trackworker
-- Returns either true (ok) or false,"translated string describing reason why it isn't allowed"
-- Impl Note: possibly duplicate code in "self contained TCB" - see interlocking/tcb_ts_ui.lua!
function advtrains.can_dig_or_modify_track(pos)
	if advtrains.get_train_at_pos(pos) then
		return false, attrans("Position is occupied by a train.")
	end
	-- interlocking: tcb, signal IP a.s.o.
	if advtrains.interlocking then
		-- TCB?
		if advtrains.interlocking.db.get_tcb(pos) then
			return false, attrans("There's a Track Circuit Break here.")
		end
		-- signal ip?
		if advtrains.interlocking.db.is_ip_at(pos, true) then -- is_ip_at with purge parameter
			return false, attrans("There's a Signal Influence Point here.")
		end
	end
	return true
end
