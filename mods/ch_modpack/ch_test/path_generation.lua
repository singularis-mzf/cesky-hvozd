-- PATH GENERATION

-- použití:
--		/emergeblocks (x1, y1, z1) (x2, y1 + 20, z2)
--		//luatransform ch_core.generate_path_{ns|sn|we|ew}_at(pos)

local buildable_nodes = {
	["default:acacia_bush_leaves"] = true,
	["default:acacia_bush_stem"] = true,
	["default:bush_leaves"] = true,
	["default:bush_stem"] = true,
	["default:blueberry_bush_leaves"] = true,
	["default:blueberry_bush_leaves_with_berries"] = true,
	["default:pine_bush_needles"] = true,
	["default:pine_bush_stem"] = true,
	["default:snow"] = true,
	["cavestuff:desert_pebble_1"] = true,
	["cavestuff:desert_pebble_2"] = true,
	["cavestuff:pebble_1"] = true,
	["cavestuff:pebble_2"] = true,
	["molehills:molehill"] = true,
}

local function air_kind(node_name)
	if node_name == "air" then
		return 1 -- real air
	end
	if node_name == "ignore" then
		return 0 -- not air, not loaded
	end
	if buildable_nodes[node_name] or node_name == "moreblocks:panel_stone_block_2" then
		return 2 -- buildable node
	end
	local ndef = minetest.registered_nodes[node_name]
	if not ndef then
		return 3 -- unknown node
	end
	if ndef.buildable_to then
		return 4 -- buildable node
	end
	if minetest.get_item_group(node_name, "tree") ~= 0 then
		return 5 -- buildable node
	end
	return 0 -- not air
end

local air_kind_cache = {}

local function air_kind_wrapper(node_name)
	local result = air_kind_cache[node_name]
	if not result then
		result = air_kind(node_name)
		print("DEBUG: "..node_name.." = "..result)
		air_kind_cache[node_name] = result
	end
	return result
end

local function create_bulk(x_min, y_min, z_min, x_max, y_max, z_max)
	local result = {}
	for x = x_min, x_max do
		for y = y_min, y_max do
			for z = z_min, z_max do
				table.insert(result, vector.new(x, y, z))
			end
		end
	end
	return result
end

local bulk_set_node = minetest.bulk_set_node
local get_node = minetest.get_node
local set_node = minetest.set_node

function ch_core.generate_path_we_at(pos)
	-- to east (+x), -z
	for i = 0,6 do
		local lpos = vector.new(pos.x, pos.y, pos.z - i)
		if air_kind_wrapper(get_node(lpos).name) == 1 then
			return false
		end
		lpos.y = lpos.y + 1
		if air_kind_wrapper(get_node(lpos).name) == 0 then
			return false
		end
	end
	local bulk = create_bulk(pos.x, pos.y - 1, pos.z - 6, pos.x, pos.y - 1, pos.z - 4)
	bulk_set_node(bulk, {name = "default:stone"})
	for i = 1, #bulk do
		local item = bulk[i]
		item.y = pos.y
	end
	bulk_set_node(bulk, {name = "ch_extras:railway_gravel"})
	for i = 1, #bulk do
		local item = bulk[i]
		item.z = item.z + 3
	end
	table.insert(bulk, pos)
	bulk_set_node(bulk, {name = "default:stone_block"})
	bulk = create_bulk(pos.x, pos.y + 1, pos.z - 6, pos.x, pos.y + 20, pos.z)
	table.insert(bulk, vector.offset(pos, 0, 1, -1))
	table.insert(bulk, vector.offset(pos, 0, 1, -2))
	table.insert(bulk, vector.offset(pos, 0, 1, -4))
	table.insert(bulk, vector.offset(pos, 0, 1, -6))
	bulk_set_node(bulk, {name = "air"})
	set_node(vector.offset(pos, 0, 1, 0), {name = "moreblocks:panel_stone_block_2", param2 = 0})
	set_node(vector.offset(pos, 0, 1, -3), {name = "moreblocks:panel_stone_block_2", param2 = 2})
	set_node(vector.offset(pos, 0, 1, -5), {name = "advtrains:dtrack_st", param2 = 3})
	return true
end

function ch_core.generate_path_ew_at(pos)
	-- to west (-x), +z
	for i = 0,6 do
		local lpos = vector.new(pos.x, pos.y, pos.z + i)
		if air_kind_wrapper(get_node(lpos).name) == 1 then
			return false
		end
		lpos.y = lpos.y + 1
		if air_kind_wrapper(get_node(lpos).name) == 0 then
			return false
		end
	end
	local bulk = create_bulk(pos.x, pos.y - 1, pos.z + 4, pos.x, pos.y - 1, pos.z + 6)
	bulk_set_node(bulk, {name = "default:stone"})
	for i = 1, #bulk do
		local item = bulk[i]
		item.y = pos.y
	end
	bulk_set_node(bulk, {name = "ch_extras:railway_gravel"})
	for i = 1, #bulk do
		local item = bulk[i]
		item.z = item.z - 3
	end
	table.insert(bulk, pos)
	bulk_set_node(bulk, {name = "default:stone_block"})
	bulk = create_bulk(pos.x, pos.y + 1, pos.z, pos.x, pos.y + 20, pos.z + 6)
	table.insert(bulk, vector.offset(pos, 0, 1, 1))
	table.insert(bulk, vector.offset(pos, 0, 1, 2))
	table.insert(bulk, vector.offset(pos, 0, 1, 4))
	table.insert(bulk, vector.offset(pos, 0, 1, 6))
	bulk_set_node(bulk, {name = "air"})
	set_node(vector.offset(pos, 0, 1, 0), {name = "moreblocks:panel_stone_block_2", param2 = 2})
	set_node(vector.offset(pos, 0, 1, 3), {name = "moreblocks:panel_stone_block_2", param2 = 0})
	set_node(vector.offset(pos, 0, 1, 5), {name = "advtrains:dtrack_st", param2 = 3})
	return true
end

function ch_core.generate_path_ns_at(pos)
	-- to south (-z), +x
	for i = 0,6 do
		local lpos = vector.new(pos.x + i, pos.y, pos.z)
		if air_kind_wrapper(get_node(lpos).name) == 1 then
			return false
		end
		lpos.y = lpos.y + 1
		if air_kind_wrapper(get_node(lpos).name) == 0 then
			return false
		end
	end
	local bulk = create_bulk(pos.x + 4, pos.y - 1, pos.z, pos.x + 6, pos.y - 1, pos.z)
	bulk_set_node(bulk, {name = "default:stone"})
	for i = 1, #bulk do
		local item = bulk[i]
		item.y = pos.y
	end
	bulk_set_node(bulk, {name = "ch_extras:railway_gravel"})
	for i = 1, #bulk do
		local item = bulk[i]
		item.x = item.x - 3
	end
	table.insert(bulk, pos)
	bulk_set_node(bulk, {name = "default:stone_block"})
	bulk = create_bulk(pos.x, pos.y + 1, pos.z, pos.x + 6, pos.y + 20, pos.z)
	table.insert(bulk, vector.offset(pos, 1, 1, 0))
	table.insert(bulk, vector.offset(pos, 2, 1, 0))
	table.insert(bulk, vector.offset(pos, 4, 1, 0))
	table.insert(bulk, vector.offset(pos, 6, 1, 0))
	bulk_set_node(bulk, {name = "air"})
	set_node(vector.offset(pos, 0, 1, 0), {name = "moreblocks:panel_stone_block_2", param2 = 3})
	set_node(vector.offset(pos, 3, 1, 0), {name = "moreblocks:panel_stone_block_2", param2 = 1})
	set_node(vector.offset(pos, 5, 1, 0), {name = "advtrains:dtrack_st", param2 = 2})
	return true
end

function ch_core.generate_path_sn_at(pos)
	-- to north (+z), -x
	for i = 0,6 do
		local lpos = vector.new(pos.x - i, pos.y, pos.z)
		if air_kind_wrapper(get_node(lpos).name) == 1 then
			return false
		end
		lpos.y = lpos.y + 1
		if air_kind_wrapper(get_node(lpos).name) == 0 then
			return false
		end
	end
	local bulk = create_bulk(pos.x - 6, pos.y - 1, pos.z, pos.x - 4, pos.y - 1, pos.z)
	bulk_set_node(bulk, {name = "default:stone"})
	for i = 1, #bulk do
		local item = bulk[i]
		item.y = pos.y
	end
	bulk_set_node(bulk, {name = "ch_extras:railway_gravel"})
	for i = 1, #bulk do
		local item = bulk[i]
		item.x = item.x + 3
	end
	table.insert(bulk, pos)
	bulk_set_node(bulk, {name = "default:stone_block"})
	bulk = create_bulk(pos.x - 6, pos.y + 1, pos.z, pos.x, pos.y + 20, pos.z)
	table.insert(bulk, vector.offset(pos, -1, 1, 0))
	table.insert(bulk, vector.offset(pos, -2, 1, 0))
	table.insert(bulk, vector.offset(pos, -4, 1, 0))
	table.insert(bulk, vector.offset(pos, -6, 1, 0))
	bulk_set_node(bulk, {name = "air"})
	set_node(vector.offset(pos, 0, 1, 0), {name = "moreblocks:panel_stone_block_2", param2 = 1})
	set_node(vector.offset(pos, -3, 1, 0), {name = "moreblocks:panel_stone_block_2", param2 = 3})
	set_node(vector.offset(pos, -5, 1, 0), {name = "advtrains:dtrack_st", param2 = 2})
	return true
end


