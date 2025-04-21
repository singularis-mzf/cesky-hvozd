-- passive.lua
-- Rework for advtrains 2.5: The passive API now uses the reworked node_state system. Please see the comment in tracks.lua

function advtrains.getstate(parpos, pnode)
	local pos
	if atlatc then
		pos = atlatc.pcnaming.resolve_pos(parpos)
	else
		pos = advtrains.round_vector_floor_y(parpos)
	end
	if type(pos)~="table" or (not pos.x or not pos.y or not pos.z) then
		debug.sethook()
		error("Invalid position supplied to getstate")
	end
	local node=pnode or advtrains.ndb.get_node(pos)
	local ndef=minetest.registered_nodes[node.name]
	local st
	if ndef and ndef.advtrains then
		return ndef.advtrains.node_state
	end
end

function advtrains.setstate(parpos, newstate, pnode)
	local pos
	if atlatc then
		pos = atlatc.pcnaming.resolve_pos(parpos)
	else
		pos = advtrains.round_vector_floor_y(parpos)
	end
	if type(pos)~="table" or (not pos.x or not pos.y or not pos.z) then
		debug.sethook()
		error("Invalid position supplied to setstate")
	end
	local node=pnode or advtrains.ndb.get_node(pos)
	local ndef=minetest.registered_nodes[node.name]
	
	if not ndef or not ndef.advtrains then
		return false, "missing_node_def"
	end
	local old_state = ndef.advtrains.node_state
	
	if old_state == newstate then
		-- nothing needs to be done
		return true
	end
	
	if not ndef.advtrains.node_state_map then
		return false, "missing_node_state_map"
	end
	local new_node_name = ndef.advtrains.node_state_map[newstate]
	if not new_node_name then
		return false, "no_such_state"
	end
	
	-- prevent state switching when route lock or train is present
	if advtrains.get_train_at_pos(pos) then
		return false, "train_here"
	end
	
	if advtrains.interlocking and advtrains.interlocking.route.has_route_lock(advtrains.encode_pos(pos)) then
		return false, "route_lock_here"
	end
	
	-- perform the switch
	local new_node = {name = new_node_name, param2 = node.param2}
	advtrains.ndb.swap_node(pos, new_node)
	-- if callback is present, call it
	if ndef.advtrains.node_on_switch_state then
		ndef.advtrains.node_on_switch_state(pos, new_node, old_state, newstate)
	end
	-- invalidate paths (only relevant if this is a track)
	advtrains.invalidate_all_paths(pos)

	return true
end

function advtrains.is_passive(parpos, pnode)
	local pos
	if atlatc then
		pos = atlatc.pcnaming.resolve_pos(parpos)
	else
		pos = advtrains.round_vector_floor_y(parpos)
	end
	if type(pos)~="table" or (not pos.x or not pos.y or not pos.z) then
		debug.sethook()
		error("Invalid position supplied to getstate")
	end
	local node=pnode or advtrains.ndb.get_node(pos)
	local ndef=minetest.registered_nodes[node.name]
	if ndef and ndef.advtrains and ndef.advtrains.node_state_map then
		return true
	else
		return false
	end
end

-- switches a node back to fallback state, if defined. Doesn't support pcnaming.
function advtrains.set_fallback_state(pos, pnode)
	local node=pnode or advtrains.ndb.get_node(pos)
	local ndef=minetest.registered_nodes[node.name]
	
	if not ndef or not ndef.advtrains or not ndef.advtrains.node_fallback_state then
		return false, "no_fallback_state"
	end
	
	return advtrains.setstate(pos, ndef.advtrains.node_fallback_state, node)
end
