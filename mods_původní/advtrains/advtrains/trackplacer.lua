--trackplacer.lua
--holds code for the track-placing system. the default 'track' item will be a craftitem that places rails as needed. this will neither place or change switches nor place vertical rails.

--all new trackplacer code
local tp={
	groups={}
}

--[[ New in version 2.5:

The track placer no longer uses hacky nodename pattern matching.
The base criterion for rotating or matching tracks is the common "ndef.advtrains.track_place_group" property.
Only rails where this field is set are considered for replacement. Other rails can still be considered for connection.
Replacement ("bending") of rails can only happen within their respective track place group. Only two-conn rails are allowed in the trackplacer.

The track registration functions register the candidates for any given track_place_group in two separate collections:
- double: tracks that can be used to connect both ends of the rail
- single: tracks that will be used to connect conn1 when only a single end is to be connected

When track placing is requested, the calling code just supplies the track_place_group to be placed.

]]--

local function rotate(conn, rot)
	return (conn + rot) % 16
end

-- Register a track node as candidate
-- tpg: the track place group to register the candidates for
--        NOTE: This value is automatically added to the node definition (ndef) in field ndef.advtrains.track_place_group!
-- name, ndef: the node name and node definition table to register
-- as_single: whether the rail should be considered as candidate for one-endpoint connection
--            Typically only set for the straight rail variants
-- as_double: whether the rail should be considered as candidate for two-endpoint connection
--            Typically set for straights and curves
-- ignore_2conn_for_legacy_xing: skips the 2-connection assertion - ONLY for compatibility with the legacy crossing nodes, DO NOT USE!
function tp.register_candidate(tpg, name, ndef, as_single, as_double, ignore_2conn_for_legacy_xing)
	--atdebug("TP Register candidate:",tpg, name, as_single, as_double)
	--get or create TP group
	if not tp.groups[tpg] then
		tp.groups[tpg] = {double = {}, single1 = {}, single2 = {}, default = {name = name, param2 = 0} }
		-- note: this causes the first candidate to ever be registered to be the default (which is typically what you want)
		-- But it can be overwritten using tp.set_default_place_candidate
	end
	local g = tp.groups[tpg]
	
	-- get conns
	if not ignore_2conn_for_legacy_xing then
		assert(#ndef.at_conns == 2)
	end
	local c1, c2 = ndef.at_conns[1].c, ndef.at_conns[2].c
	local is_symmetrical = (rotate(c1, 8) == c2)
	
	-- store all possible rotations (param2 values)
	for i=0,3 do
		if as_double then
			g.double[rotate(c1,i*4).."_"..rotate(c2,i*4)] = {name=name, param2=i}
			if not is_symmetrical then
				g.double[rotate(c2,i*4).."_"..rotate(c1,i*4)] = {name=name, param2=i}
				-- if the track is unsymmetric (e.g. a curve), we may require the "wrong" orientation to fill a gap.
			end
		end
		if as_single then
			g.single1[rotate(c1,i*4)] = {name=name, param2=i}
			g.single2[rotate(c2,i*4)] = {name=name, param2=i}
		end
	end
	
	-- Set track place group on the node
	if not ndef.advtrains then
		ndef.advtrains = {}
	end
	ndef.advtrains.track_place_group = tpg
end

-- Sets the node that is placed by the track placer when there is no track nearby. param2 defaults to 0
function tp.set_default_place_candidate(tpg, name, param2)
	if not tp.groups[tpg] then
		tp.groups[tpg] = {double = {}, single1 = {}, single2 = {}, default = {name = name, param2 = param2 or 0} }
	else
		tp.groups[tpg].default = {name = name, param2 = param2 or 0}
	end
end

local function check_or_bend_rail(origin, dir, pname, commit)
	local pos = advtrains.pos_add_dir(origin, dir)
	local back_dir = advtrains.oppd(dir);
	
	local node_ok, conns = advtrains.get_rail_info_at(pos)
	if not node_ok then
		-- try the node one level below
		pos.y = pos.y - 1
		node_ok, conns = advtrains.get_rail_info_at(pos)
	end
	if not node_ok then
		return false
	end
	-- if one conn of the node here already points towards us, nothing to do
	for connid, conn in ipairs(conns) do
		if back_dir == conn.c then
			return true
		end
	end
	-- can we bend the node here?
	local node = advtrains.ndb.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	if not ndef or not ndef.advtrains or not ndef.advtrains.track_place_group then
		return false
	end
	-- now the track must be two-conn, else it wouldn't be allowed to have track_place_group set.
	--assert(#conns == 2) -- cannot check here, because of legacy crossing hack
	-- Is player and game allowed to do this?
	if not advtrains.can_dig_or_modify_track(pos) then
		return false
	end
	if not advtrains.check_track_protection(pos, pname) then
		return false
	end
	-- we confirmed that track can be modified. Does there exist a suitable connection candidate?
	-- check if there are any unbound ends
	local bound_connids = {}
	for connid, conn in ipairs(conns) do
		local adj_pos, adj_connid = advtrains.get_adjacent_rail(pos, conns, connid)
		if adj_pos then
			bound_connids[#bound_connids+1] = connid
		end
	end
	-- depending on the nummber of ends, decide
	if #bound_connids == 2 then
		-- rail is within a fixed track, do not break up
		return false
	end
	-- obtain the group table
	local g = tp.groups[ndef.advtrains.track_place_group]
	if #bound_connids == 1 then
		-- we can attempt double
		local bound_dir = conns[bound_connids[1]].c
		if g.double[back_dir.."_"..bound_dir] then
			if commit then
				advtrains.ndb.swap_node(pos, g.double[back_dir.."_"..bound_dir])
			end
			return true
		end
	else
		-- rail is entirely unbound, we can attempt single1
		if g.single1[back_dir] then
			if commit then
				advtrains.ndb.swap_node(pos, g.single1[back_dir])
			end
			return true
		end
	end
end

local function track_place_node(pos, node, ndef_p, pname)
	--atdebug("track_place_node: ",pos, node)
	advtrains.ndb.swap_node(pos, node)
	local ndef = ndef_p or minetest.registered_nodes[node.name]
	if ndef and ndef.after_place_node then
		-- resolve player again
		local player = pname and core.get_player_by_name(pname) or nil
		ndef.after_place_node(pos, player) -- note: itemstack and pointed_thing are NOT available here anymore (crap!)
	end
end


-- Main API function to place a track. Replaces the older "placetrack"
-- This function will attempt to place a track of the specified track placing group at the specified position, connecting it
-- with neighboring rails. Neighboring rails can themselves be replaced ("bent") within their own track place group,
-- if the player is permitted to do this.
-- Order of preference is:
--    Connect two track ends if possible
--    Connect one track end if any rail is near
--    Place the default track if no tracks are near
-- The function returns true on success.
function tp.place_track(pos, tpg, pname, yaw)
	-- 1. collect neighboring tracks and whether they can be connected
	--atdebug("tp.place_track(",pos, tpg, pname, yaw,")")
	local cand = {}
	for i=0,15 do
		if check_or_bend_rail(pos, i, pname) then
			cand[#cand+1] = i
		end
	end
	--atdebug("Candidates: ",cand)
	-- obtain the group table
	local g = tp.groups[tpg]
	if not g then
		error("tp.place_track: for tpg="..tpg.." couldn't find the group table")
	end
	--atdebug("Group table:",g)
	-- 2. try all possible two-endpoint connections
	for k1, conn1 in ipairs(cand) do
		for k2, conn2 in ipairs(cand) do
			if k1~=k2 then
				-- order of conn1/conn2: prefer conn1 being in the direction of the player facing.
				-- the combination the other way round will be run through in a later loop iteration
				if advtrains.yawToDirection(yaw, conn1, conn2) == conn1 then
					-- does there exist a suitable double-connection rail?
					--atdebug("Try double conn: ",conn1, conn2)
					local node = g.double[conn1.."_"..conn2]
					if node then
						check_or_bend_rail(pos, conn1, pname, true)
						check_or_bend_rail(pos, conn2, pname, true)
						track_place_node(pos, node, nil, pname) -- calls after_place_node implicitly
						return true
					end
				end
			end
		end
	end
	-- 3. try all possible one_endpoint connections
	for k1, conn1 in ipairs(cand) do
		-- select single1 or single2? depending on yaw
		local single
		if advtrains.yawToDirection(yaw, conn1, advtrains.oppd(conn1)) == conn1 then
			single = g.single1
		else
			single = g.single2
		end
		--atdebug("Try single conn: ",conn1)
		local node = single[conn1]
		if node then
			check_or_bend_rail(pos, conn1, pname, true)
			track_place_node(pos, node, nil, pname) -- calls after_place_node implicitly
			return true
		end
	end
	-- 4. if nothing worked, set the default
	local node = g.default
	track_place_node(pos, node, nil, pname) -- calls after_place_node implicitly
	return true
end


-- TRACK WORKER --


minetest.register_craftitem("advtrains:trackworker",{
	description = attrans("Track Worker Tool\n\nLeft-click: change rail type (straight/curve/switch)\nRight-click: rotate object"),
	groups = {cracky=1}, -- key=name, value=rating; rating=1..3.
	inventory_image = "advtrains_trackworker.png",
	wield_image = "advtrains_trackworker.png",
	stack_max = 1,
	on_place = function(itemstack, placer, pointed_thing)
		local name = placer:get_player_name()
		if not name then
			return
		end
		local has_aux1_down = placer:get_player_control().aux1
		if pointed_thing.type=="node" then
			local pos=pointed_thing.under
			if not advtrains.check_track_protection(pos, name) then
				return
			end
			local node=minetest.get_node(pos)

			-- New since 2.5: only the fields in the node definition are considered, no more hacky pattern matching on the nodename
			
			local ndef = minetest.registered_nodes[node.name]
			
			if not ndef.advtrains or not ndef.advtrains.trackworker_next_rot then
				minetest.chat_send_player(placer:get_player_name(), attrans("This node can't be rotated using the trackworker!"))
				return
			end
			
			-- check if the node is modify-protected
			if advtrains.is_track(node.name) then
				-- is a track, we can query
				local can_modify, reason = advtrains.can_dig_or_modify_track(pos)
				if not can_modify then
					local str = attrans("This track can not be rotated!")
					if reason then
						str = str .. " " .. reason
					end
					minetest.chat_send_player(placer:get_player_name(), str)
					return
				end
			end
			
			if has_aux1_down then
				--feature: flip the node by 180°
				--i've always wanted this!
				advtrains.ndb.swap_node(pos, {name=node.name, param2=(node.param2+2)%4})
				return
			end
			
			local new_node = {name = ndef.advtrains.trackworker_next_rot, param2 = node.param2}
			if ndef.advtrains.trackworker_rot_incr_param2 then
				new_node.param2 = ((node.param2 + 1) % 4)
			end
			advtrains.ndb.swap_node(pos, new_node)
		end
	end,
	on_use=function(itemstack, player, pointed_thing)
		local name = player:get_player_name()
		if not name then
		   return
		end
		if pointed_thing.type=="node" then
			local pos=pointed_thing.under
			local node=minetest.get_node(pos)
			if not advtrains.check_track_protection(pos, name) then
				return
			end
			
			-- New since 2.5: only the fields in the node definition are considered, no more hacky pattern matching on the nodename
			
			local ndef = minetest.registered_nodes[node.name]
			
			if not ndef.advtrains or not ndef.advtrains.trackworker_next_var then
				minetest.chat_send_player(name, attrans("This node can't be changed using the trackworker!"))
				return
			end
			
			-- check if the node is modify-protected
			if advtrains.is_track(node.name) then
				-- is a track, we can query
				local can_modify, reason = advtrains.can_dig_or_modify_track(pos)
				if not can_modify then
					local str = attrans("This track can not be rotated!")
					if reason then
						str = str .. " " .. reason
					end
					minetest.chat_send_player(name, str)
					return
				end
			end
			
			local new_node = {name = ndef.advtrains.trackworker_next_var, param2 = node.param2}
			advtrains.ndb.swap_node(pos, new_node)
		end
	end,
})

--putting into right place
advtrains.trackplacer=tp
