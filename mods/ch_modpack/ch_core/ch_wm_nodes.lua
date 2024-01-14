ch_core.open_submod("ch_wm_nodes", {lib = true})

local function gen_walldir(args)
	local result = table.copy(args)
	for k, v in pairs(args) do
		result[v] = k
	end
	return result
end

--- DATA
local walldirs = {
	[0] = gen_walldir({front = "-z", back = "+z", left = "-x", right = "+x", top = "+y", bottom = "-y"}),
	[1] = gen_walldir({front = "-x", back = "+x", left = "-z", right = "+z", top = "+y", bottom = "-y"}),
	[2] = gen_walldir({front = "+z", back = "-z", left = "+x", right = "-x", top = "+y", bottom = "-y"}),
	[3] = gen_walldir({front = "+x", back = "-x", left = "+z", right = "-z", top = "+y", bottom = "-y"}),
	[4] = gen_walldir({front = "+y", back = "-y", left = "-x", right = "+x", top = "+z", bottom = "-z"}),
	[5] = gen_walldir({front = "-y", back = "+y", left = "-z", right = "+z", top = "-x", bottom = "+x"}),
}

local walldir_to_facedir = {1, 2, 3, 13, 15}
walldir_to_facedir[0] = 0

local facedir_to_walldir = {
	1, 2, 3, -- 0 (1)
	4, 1, 5, 3, -- 4
	5, 1, 4, 3, -- 8
	0, 4, 2, 5, -- 12
	0, 5, 2, 4, -- 16
	0, 3, 2, 1, -- 20
}
facedir_to_walldir[0] = 0
if facedir_to_walldir[23] == nil then error("assertion failed") end

local all_sides = {"front", "back", "left", "right", "top", "bottom"}

-- CH-wallmounted nodes

local function transfer_value(from_v, from_i, to_v, to_i)
	-- example:
	-- transfer_value(from_vector, "+x", to_vector, "-z")
	if #from_i ~= 2 or #to_i ~= 2 then
		error("transfer_value(): invalid input: "..dump2({from_v = from_v, from_i = from_i, to_v = to_v, to_i = to_i}))
	end
	local n = from_v[from_i:sub(2, 2)]
	if to_i:sub(1,1) ~= from_i:sub(1,1) then
		n = -n
	end
	to_v[to_i:sub(2,2)] = n
	return to_v
end

function ch_core.rotate_boxes_for_walldir(walldir, boxes)
	if type(boxes) ~= "table" then
		error("Boxes must be a table!")
	end
	local walldir_def = walldirs[walldir]
	if walldir_def == nil then
		error("ch_core.rotate_nodebox_for_walldir(): Invalid walldir value: "..walldir)
	end
	if type(boxes[1]) ~= "table" then
		boxes = {boxes}
	end
	local result = {}
	for i, box in ipairs(boxes) do
		local fmin, fmax = vector.new(box[1], box[2], box[3]), vector.new(box[4], box[5], box[6])
		local min, max = vector.zero(), vector.zero()
		transfer_value(fmin, "+x", min, walldir_def.right)
		transfer_value(fmin, "+y", min, walldir_def.top)
		transfer_value(fmin, "+z", min, walldir_def.back)
		transfer_value(fmax, "+x", max, walldir_def.right)
		transfer_value(fmax, "+y", max, walldir_def.top)
		transfer_value(fmax, "+z", max, walldir_def.back)
		result[i] = {min.x, min.y, min.z, max.x, max.y, max.z}
	end
	return result
end

function ch_core.rotate_connected_boxes_for_walldir(walldir, node_box)
	if type(node_box) ~= "table" or node_box.type ~= "connected" then
		error("Invalid arguments: "..dump2({walldir = walldir, node_box = node_box}))
	end
	if node_box.disconnected_sides ~= nil then
		minetest.log("warning", "ch_core.rotate_connected_boxes_for_walldir(): disconnected_sides not supported!")
	end
	local walldir_def = walldirs[walldir]
	if walldir_def == nil then
		error("ch_core.rotate_connected_boxes_for_walldir(): Invalid walldir value: "..walldir)
	end
	local result = {
		type = "connected",
	}
	if node_box.disconnected ~= nil then
		result.disconnected = ch_core.rotate_boxes_for_walldir(walldir, node_box.disconnected)
	end
	for _, side in ipairs(all_sides) do
		local new_side = walldirs[0][walldir_def[side]]
		-- local new_side = walldir_def[walldirs[0][side]]
		-- print("DEBUG: walldir "..walldir..": side "..side.." => "..walldir_def[side].." => "..new_side)
		if node_box["connect_"..side] ~= nil then
			result["connect_"..new_side] = ch_core.rotate_boxes_for_walldir(walldir, node_box["connect_"..side])
		end
		if node_box["disconnected_"..side] ~= nil then
			result["disconnected_"..new_side] = ch_core.rotate_boxes_for_walldir(walldir, node_box["disconnected_"..side])
		end
	end
	if node_box.fixed ~= nil then
		result.fixed = ch_core.rotate_boxes_for_walldir(walldir, node_box.fixed)
	end
	return result
end

function ch_core.rotate_connect_sides_for_walldir(walldir, connect_sides)
	-- print("ch_core.rotate_connect_sides_for_walldir called.")
	local walldir_def = walldirs[walldir]
	if walldir_def == nil then
		error("ch_core.rotate_connect_sides_for_walldir(): Invalid walldir value: "..walldir)
	end
	local result = {}
	for _, side in ipairs(connect_sides) do
		local new_side_i = walldirs[0][side]
		if new_side_i ~= nil then
			table.insert(result, walldir_def[new_side_i])
		end
	end
	-- print("will return connect_sides = "..dump2(result))
	return result
end

function ch_core.on_rotate_walldir(pos, node, user, mode, new_param2)
	local player_name = user and user:get_player_name()
	if not player_name then
		return false
	end
	if minetest.is_protected(pos, player_name) then
		minetest.record_protection_violation(pos, player_name)
		return false
	end
	local ndef = minetest.registered_nodes[node.name]
	local walldir_nodes = ndef and ndef.walldir_nodes
	local result_node = walldir_nodes and walldir_nodes[facedir_to_walldir[new_param2]]
	if not result_node then
		return false
	end
	if result_node ~= node.name then
		node.name = result_node
		minetest.swap_node(pos, node)
	end
	return true
end

function ch_core.walldir_to_facedir(walldir)
	return walldir_to_facedir[walldir]
end

ch_core.close_submod("ch_wm_nodes")
