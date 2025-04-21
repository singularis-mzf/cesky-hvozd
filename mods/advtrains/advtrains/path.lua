-- path.lua
-- Functions for pathpredicting, put in a separate file. 

-- Naming conventions:
-- 'index' - An index of the train.path table.
-- 'offset' - A value in meters that determines how far on the path to walk relative to a certain index
-- 'n' - Referring or pointing towards the 'next' path item, the one with index+1
-- 'p' - Referring or pointing towards the 'prev' path item, the one with index-1
-- 'f' - Referring to the positive end of the path (the end with the higher index)
-- 'b' - Referring to the negative end of the path (the end with the lower index)

-- New path structure of trains:
--Tables:
-- path      - path positions. 'indices' are relative to this. At the moment, at.round_vector_floor_y(path[i])
--              is the node this item corresponds to, however, this will change in the future.
-- path_node - (reserved)
-- path_cn   - Connid of the current node that points towards path[i+1]
-- path_cp   - Connid of the current node that points towards path[i-1]
--     When the day comes on that path!=node, these will only be set if this index represents a transition between rail nodes
-- path_dist - The total distance of this path element from path element 0
-- path_dir  - The direction of this path item's transition to the next path item, which is the angle of conns[path_cn[i]].c
-- path_speed- Populated by the LZB system. The maximum speed (velocity) permitted in the moment this path item is passed.
--             (this saves brake distance calculations every step to determine LZB control). nil means no limit.
--Variables:
-- path_ext_f/b - how far path[i] is set
-- path_trk_f/b - how far the path extends along a track. beyond those values, paths are generated in a straight line.
-- path_req_f/b - how far path items were requested in the last step
--
--Distance and index:
-- There is an important difference between the path index and the actual distance on the track: The distance between two path items can be larger than 1,
-- but the corresponding index increment is still 1.
-- Indexes in advtrains can be fractional values. If they are, it means that the actual position is interpolated between the 2 adjacent path items.
-- If you need to proceed along the path by a specific actual distance, it does NOT work to simply add it to the index. You should use the path_get_index_by_offset() function.

-- creates the path data structure, reconstructing the train from a position and a connid
-- returns: true - successful
--           nil - node not yet available/unloaded, please wait
--         false - node definitely gone, remove train
function advtrains.path_create(train, pos, connid, rel_index)
	local posr = advtrains.round_vector_floor_y(pos)
	local node_ok, conns, rhe, connmap = advtrains.get_rail_info_at(pos)
	if not node_ok then
		return node_ok
	end
	local mconnid = advtrains.get_matching_conn(connid, connmap)
	train.index = rel_index
	train.path = { [0] = { x=posr.x, y=posr.y+rhe, z=posr.z } }
	train.path_cn = { [0] = connid }
	train.path_cp = { [0] = mconnid }
	train.path_dist = { [0] = 0 }
	
	train.path_dir = {
		[0] = advtrains.conn_angle_median(conns[mconnid].c, conns[connid].c)
	}
	
	train.path_speed = { }
	
	train.path_ext_f=0
	train.path_ext_b=0
	train.path_trk_f=0
	train.path_trk_b=0
	train.path_req_f=0
	train.path_req_b=0
	
	advtrains.occ.set_item(train.id, posr, 0)
	return true
end

-- Sets position and connid to properly restore after a crash, e.g. in order
-- to save the train or to invalidate its path
-- Assumes that the train is in clean state
-- if invert ist true, setrestore will use the end index
function advtrains.path_setrestore(train, invert)
	local idx = train.index
	if invert then
		idx = train.end_index
	end
	
	local pos, connid, frac = advtrains.path_getrestore(train, idx, invert, true)
	
	train.last_pos = pos
	train.last_connid = connid
	train.last_frac = frac
end
-- Get restore position, connid and frac (in this order) for a train that will originate at the passed index
-- If invert is set, it will return path_cp and multiply frac by -1, in order to reverse the train there.
function advtrains.path_getrestore(train, index, invert)
	local idx = index
	local cns = train.path_cn
	
	if invert then
		cns = train.path_cp
	end
	
	local fli = atfloor(index)
	advtrains.path_get(train, fli)
	if fli > train.path_trk_f then
		fli = train.path_trk_f
	end
	if fli < train.path_trk_b then
		fli = train.path_trk_b
	end
	return advtrains.path_get(train, fli),
			cns[fli],
			(idx - fli) * (invert and -1 or 1)
end

-- Invalidates a path
-- this is supposed to clear stuff from the occupation tables
-- This function throws a warning whenever any code calls it while the train steps are run, since that must not happen.
-- The ignore_lock parameter can be used to ignore this, however, it should then be accompanied by a call to train_ensure_init
-- before returning from the calling function.
function advtrains.path_invalidate(train, ignore_lock)
	if advtrains.lock_path_inval and not ignore_lock then
		atwarn("Train ",train.id,": Illegal path invalidation has occured during train step:")
		atwarn(debug.traceback())
	end
	if train.path then
		--atdebug("path_invalidate for",train.id)
		local _cnt = 0
		for i,p in pairs(train.path) do
			_cnt = _cnt + 1
			if _cnt > 10000 then
				atdebug(train)
				error("Loop trap in advtrains.path_invalidate was triggered!")
			end
			advtrains.occ.clear_all_items(train.id, advtrains.round_vector_floor_y(p))
		end
		--atdebug("occ cleared")
	end
	train.path = nil
	train.path_dist = nil
	train.path_cp = nil
	train.path_cn = nil
	train.path_dir = nil
	train.path_speed = nil
	train.path_ext_f=0
	train.path_ext_b=0
	train.path_trk_f=0
	train.path_trk_b=0
	train.path_req_f=0
	train.path_req_b=0
	
	train.dirty = true
	--atdebug(train.id, "Path invalidated")
end

-- Keeps the path intact, but invalidates all path nodes from the specified index (inclusive)
-- onwards. This has the advantage that we don't need to recalculate the whole path, and we can do it synchronously.
function advtrains.path_invalidate_ahead(train, start_idx, ignore_when_passed)
	if not train.path then
		-- the path wasn't even initialized. Nothing to do
		return
	end

	local idx = atfloor(start_idx)
	--atdebug("Invalidate_ahead:",train.id,"start_index",start_idx,"cur_idx",train.index)
	
	if(idx <= train.index - 0.5) then
		if ignore_when_passed then
			--atdebug("ignored passed")
			return
		end
		advtrains.path_print(train, atwarn)
		error("Train "+train.id+": Cannot path_invalidate_ahead start_idx="+idx+" as train has already passed!")
	end
	
	-- leave current node in path, it won't change. What might change is the path onward from here (e.g. switch)
	local i = idx + 1
	while train.path[i] do
		advtrains.occ.clear_specific_item(train.id, advtrains.round_vector_floor_y(train.path[i]), i)
		i = i+1
	end
	train.path_ext_f=idx
	train.path_trk_f=math.min(idx, train.path_trk_f)
	
	-- callbacks called anyway for current node, because of LZB
	advtrains.run_callbacks_invahead(train.id, train, idx)
end

-- Prints a path using the passed print function
-- This function should be 'atprint', 'atlog', 'atwarn' or 'atdebug', because it needs to use print_concat_table
function advtrains.path_print(train, printf)
	printf("path_print: tid =",train.id," index =",train.index," end_index =",train.end_index," vel =",train.velocity)
	if not train.path then
		printf("path_print: Path is invalidated/inexistant.")
		return
	end
	printf("i:	CP	Position	Dir				CN		Dist		Speed")
	for i = train.path_ext_b, train.path_ext_f do
		if i==train.path_trk_b then
			printf("--Back on-track border here--")
		end
		printf(i,":	",train.path_cp[i],"	",train.path[i],"	",train.path_dir[i],"	",train.path_cn[i],"		",train.path_dist[i],"		",train.path_speed[i])
		if i==train.path_trk_f then
			printf("--Front on-track border here--")		
		end
	end
end

-- Function to get path entry at a position. This function will automatically calculate more of the path when required.
-- returns: pos, on_track
function advtrains.path_get(train, index)
	if not train.path then
		error("For train "..train.id..": path_get called but there's no path set yet!")
	end
	if index ~= atfloor(index) then
		error("For train "..train.id..": Called path_get() but index="..index.." is not a round number")
	end
	
	local pef = train.path_ext_f
	-- generate forward (front of train, positive)
	while index > pef do
		local pos = train.path[pef]
		local connid = train.path_cn[pef]
		local node_ok, this_conns, adj_pos, adj_connid, conn_idx, nextrail_y, next_conns, next_connmap
		if pef == train.path_trk_f then
			node_ok, this_conns = advtrains.get_rail_info_at(pos)
			if not node_ok then error("For train "..train.id..": Path item "..pef.." on-track but not a valid node!") end
			adj_pos, adj_connid, conn_idx, nextrail_y, next_conns, next_connmap = advtrains.get_adjacent_rail(pos, this_conns, connid)
		end
		pef = pef + 1
		if adj_pos then
			advtrains.occ.set_item(train.id, adj_pos, pef)
			
			local mconnid = advtrains.get_matching_conn(adj_connid, next_connmap)
			-- NO split points handling here. It is only required for backwards path calculation
			
			adj_pos.y = adj_pos.y + nextrail_y
			train.path_cp[pef] = adj_connid
			train.path_cn[pef] = mconnid
			train.path_dir[pef] = advtrains.conn_angle_median(next_conns[adj_connid].c, next_conns[mconnid].c)
			train.path_trk_f = pef
		else
			-- off-track fallback behavior
			adj_pos = advtrains.pos_add_angle(pos, train.path_dir[pef-1])
			--atdebug("Offtrack overgenerating(front) at",adj_pos,"index",peb,"trkf",train.path_trk_f)
			train.path_dir[pef] = train.path_dir[pef-1]
		end
		train.path[pef] = adj_pos
		train.path_dist[pef] = train.path_dist[pef-1] + vector.distance(pos, adj_pos)
	end
	train.path_ext_f = pef
	
	
	local peb = train.path_ext_b
	-- generate backward (back of train, negative)
	while index < peb do
		local pos = train.path[peb]
		local connid = train.path_cp[peb]
		local node_ok, this_conns, adj_pos, adj_connid, conn_idx, nextrail_y, next_conns, next_connmap
		if peb == train.path_trk_b then
			node_ok, this_conns = advtrains.get_rail_info_at(pos)
			if not node_ok then error("For train "..train.id..": Path item "..peb.." on-track but not a valid node!") end
			adj_pos, adj_connid, conn_idx, nextrail_y, next_conns, next_connmap = advtrains.get_adjacent_rail(pos, this_conns, connid)
		end
		peb = peb - 1
		if adj_pos then
			advtrains.occ.set_item(train.id, adj_pos, peb)
			
			local mconnid = advtrains.get_matching_conn(adj_connid, next_connmap)
			-- If, for this position, we have remembered the origin conn, apply it here
			if next_connmap then -- only needs to be done when this track is a turnout (>2 conns)
				local origin_conn = train.path_ori_cp[advtrains.encode_pos(adj_pos)]
				if origin_conn then
					--atdebug("Train",train.id,"at",adj_pos,"restoring turnout origin CP",origin_conn,"for path item",index)
					mconnid = origin_conn
				end
			end
						
			adj_pos.y = adj_pos.y + nextrail_y
			train.path_cn[peb] = adj_connid
			train.path_cp[peb] = mconnid
			train.path_dir[peb] = advtrains.conn_angle_median(next_conns[mconnid].c, next_conns[adj_connid].c)
			train.path_trk_b = peb
		else
			-- off-track fallback behavior
			adj_pos = advtrains.pos_add_angle(pos, train.path_dir[peb+1] + math.pi)
			--atdebug("Offtrack overgenerating(back) at",adj_pos,"index",peb,"trkb",train.path_trk_b)
			train.path_dir[peb] = train.path_dir[peb+1]
		end
		train.path[peb] = adj_pos
		train.path_dist[peb] = train.path_dist[peb+1] - vector.distance(pos, adj_pos)
	end
	train.path_ext_b = peb
	
	if index < train.path_req_b then
		train.path_req_b = index
	end
	if index > train.path_req_f then
		train.path_req_f = index
	end
	
	return train.path[index], (index<=train.path_trk_f and index>=train.path_trk_b)
	
end

-- interpolated position to fractional index given, and angle based on path_dir
-- returns: pos, angle(yaw), p_floor, p_ceil
function advtrains.path_get_interpolated(train, index)
	local i_floor = atfloor(index)
	local i_ceil = i_floor + 1
	local frac = index - i_floor
	local p_floor = advtrains.path_get(train, i_floor)
	local p_ceil = advtrains.path_get(train, i_ceil)
	-- Note: minimal code duplication to path_get_adjacent, for performance
	
	local a_floor = train.path_dir[i_floor]
	local a_ceil = train.path_dir[i_ceil]
	
	local ang = advtrains.minAngleDiffRad(a_floor, a_ceil)
	
	return vector.add(p_floor, vector.multiply(vector.subtract(p_ceil, p_floor), frac)), (a_floor + frac * ang)%(2*math.pi), p_floor, p_ceil
end
-- returns the 2 path positions directly adjacent to index and the fraction on how to interpolate between them
-- returns: pos_floor, pos_ceil, fraction
function advtrains.path_get_adjacent(train, index)
	local i_floor = atfloor(index)
	local i_ceil = i_floor + 1
	local frac = index - i_floor
	local p_floor = advtrains.path_get(train, i_floor)
	local p_ceil = advtrains.path_get(train, i_ceil)
	return p_floor, p_ceil, frac
end

local function n_interpolate(s, e, f)
	return s + (e-s)*f
end

-- This function determines the index resulting from moving along the path by 'offset' meters
-- starting from 'index'. See also the comment on the top of the file.
function advtrains.path_get_index_by_offset(train, index, offset)
	local advtrains_path_get = advtrains.path_get

	-- Step 1: determine my current absolute pos on the path
	local start_index_f = atfloor(index)
	local end_index_f = start_index_f + 1
	local c_idx = atfloor(index + offset)
	local c_idx_f = c_idx + 1

	local frac = index - start_index_f

	advtrains_path_get(train, math.min(start_index_f, end_index_f, c_idx, c_idx_f))
	advtrains_path_get(train, math.max(start_index_f, end_index_f, c_idx, c_idx_f))

	local dist1, dist2 = train.path_dist[start_index_f], train.path_dist[start_index_f+1]
	local start_dist = dist1 + (dist2-dist1)*frac
	
	-- Step 2: determine the total end distance and estimate the index we'd come out
	local end_dist = start_dist + offset
	
	local c_idx = atfloor(index + offset)
	
	-- Step 3: move forward/backward to find real index
	-- We assume here that the distance between 2 path items is never smaller than 1.
	-- Our estimated index is therefore either exact or too far over, and we're going to go back
	-- towards the origin. It is therefore sufficient to query path_get a single time
	
	-- How we'll adjust c_idx
	--  Desired position:  -------#------
	--  Path items      :  --|--|--|--|--
	--  c_idx           :       ^

	while train.path_dist[c_idx] < end_dist do
		c_idx = c_idx + 1
	end
	
	while train.path_dist[c_idx] > end_dist do
		c_idx = c_idx - 1
	end
	
	-- Step 4: now c_idx points to the place shown above. Find out the fractional part.
	
	dist1, dist2 = train.path_dist[c_idx], train.path_dist[c_idx+1]
	
	frac = (end_dist - dist1) / (dist2 - dist1)
	
	assert(frac>=0 and frac<1, frac)
	
	return c_idx + frac
end


-- The path_dist[] table contains absolute distance values for every whole index.
-- Use this function to retrieve the correct absolute distance for a fractional index value (interpolate between floor and ceil index)
-- returns: absolute distance from path item 0
function advtrains.path_get_path_dist_fractional(train, index)
	local start_index_f = atfloor(index)
	local frac = index - start_index_f
	-- ensure path exists
	advtrains.path_get_adjacent(train, index)
	local dist1, dist2 = train.path_dist[start_index_f], train.path_dist[start_index_f+1]
	return dist1 + (dist2-dist1)*frac
end

local PATH_CLEAR_KEEP = 4

function advtrains.path_clear_unused(train)
	local i
	for i = train.path_ext_b, train.path_req_b - PATH_CLEAR_KEEP do
		advtrains.occ.clear_specific_item(train.id, advtrains.round_vector_floor_y(train.path[i]), i)
		train.path[i] = nil
		train.path_dist[i-1] = nil
		train.path_cp[i] = nil
		train.path_cn[i] = nil
		train.path_dir[i] = nil
		train.path_ext_b = i + 1
	end
	
	--[[ Why exactly are we clearing path from the front? This doesn't make sense!
	for i = train.path_ext_f,train.path_req_f + PATH_CLEAR_KEEP,-1 do
		advtrains.occ.clear_item(train.id, advtrains.round_vector_floor_y(train.path[i]))
		train.path[i] = nil
		train.path_dist[i] = nil
		train.path_cp[i] = nil
		train.path_cn[i] = nil
		train.path_dir[i+1] = nil
		train.path_ext_f = i - 1
	end ]]
	train.path_trk_b = math.max(train.path_trk_b, train.path_ext_b)
	--train.path_trk_f = math.min(train.path_trk_f, train.path_ext_f)
	
	train.path_req_f = math.ceil(train.index)
	train.path_req_b = math.floor(train.end_index or train.index)
end

-- Scan the path of the train for position, without querying the occupation table
-- returns index, or nil if pos is not on the path
function advtrains.path_lookup(train, pos)
	local cp = advtrains.round_vector_floor_y(pos)
	for i = train.path_ext_b, train.path_ext_f do
		if vector.equals(advtrains.round_vector_floor_y(train.path[i]), cp) then
			return i
		end
	end
	return nil
end

-- Projects the path of "train" onto the path of "onto_train_id", and returns the index on onto_train's path
-- that corresponds to "index" on "train"'s path, as well as whether both trains face each other
-- index may be fractional
-- heuristic: see advtrains.occ.reverse_lookup_sel()
-- returns: res_index, trains_facing
-- returns nil when path can not be projected, either because trains are on different tracks or
-- node at "index" happens to be on a turnout and it's the wrong direction
-- Note - duplicate with similar functionality is in train_step_b() - that code combines train detection with projecting
function advtrains.path_project(train, index, onto_train_id, heuristic)
	local base_idx = atfloor(index)
	local frac_part = index - base_idx
	local base_pos = advtrains.path_get(train, base_idx)
	local base_cn =  train.path_cn[base_idx]
	local otrn = advtrains.trains[onto_train_id]
	-- query occupation
	local occ = advtrains.occ.reverse_lookup_sel(base_pos, heuristic)
	-- is wanted train id contained?
	local ob_idx = occ[onto_train_id]
	if not ob_idx then
		return nil
	end

	-- retrieve other train's cn and cp
	local ocn = otrn.path_cn[ob_idx]
	local ocp = otrn.path_cp[ob_idx]

	if base_cn == ocn then
		-- same direction
		return ob_idx + frac_part, false
	elseif base_cn == ocp then
		-- facing trains - subtract index frac
		return ob_idx - frac_part, true
	else
		-- same path item but no common connections - deny
		return nil
	end
end


