ch_core.open_submod("rotation")

--[[
Funkce ch_rotation může být v definici každého bloku (node) a měla by být
použita při pokusu o otáčení bloku namísto on_rotate nebo jiných metod.
Musí podporovat dvě formy volání:

1. ch_rotation(pos, node)
- vždy vrací tabulku, jednu z těchto tří forem:
a) {type = "none"}
b) {type = "facedir", facedir = int(>= 0 && <= 23), extra_data = int(>= 0 && <= 255)}
c) {type = "degrotate", degrotate = int(>=0 && <= 239), step = int(1..120), extra_data = int(>= 0 && <= 255)}

2. ch_rotation(pos, node, rotation [, simulation = bool (default = false)])
- pokusí se otočit blok na dané pozici podle požadavku;
  pokud uspěje, nastaví také obsah "node" a "rotation" na hodnoty odpovídající
  novému natočení bloku (které nemusejí přesně odpovídat požadavku)
- vrací true v případě úspěchu
- v případě selhání vrací false a "node" a "rotation" zůstávají beze změny
- rotation je tabulka ve formátu, který vrací předchozí forma funkce
- je-li simulation true, ve skutečnosti blok neotočí, ale provede plnou
  simulaci (včetně např. volání metod can_dig sousedních bloků, je-li to potřeba)

]]

function ch_core.ch_rotation_facedir(pos, node, rotation, simulation)
	assert(pos)
	assert(node)
	if rotation == nil then
		local facedir = node.param2 % 32
		return {type = "facedir", facedir = math.min(facedir, 23), extra_data = node.param2 - facedir}
	end
	if rotation.type ~= "facedir" or rotation.facedir < 0 or rotation.facedir > 23 then return false end
	node.param2 = rotation.facedir + rotation.extra_data
	if not simulation then
		minetest.swap_node(pos, node)
	end
	return true
end

function ch_core.ch_rotation_4dir(pos, node, rotation, simulation)
	assert(pos)
	assert(node)
	if rotation == nil then
		local facedir = node.param2 % 4
		return {type = "facedir", facedir = facedir, extra_data = node.param2 - facedir}
	end
	if rotation.type ~= "facedir" or rotation.facedir < 0 or rotation.facedir > 3 then return false end
	node.param2 = rotation.facedir + rotation.extra_data
	if not simulation then
		minetest.swap_node(pos, node)
	end
	return true
end

local facedir_to_wallmounted = {
	[0] = 4, [1] = 2, [2] = 5, [3] = 3,
	[4] = 1, [5] = 2, [6] = 0, [7] = 3,
	[8] = 0, [9] = 2, [10] = 1, [11] = 3,
	[12] = 4, [13] = 1, [14] = 5, [15] = 0,
	[16] = 4, [17] = 0, [18] = 5, [19] = 1,
	[20] = 4, [21] = 3, [22] = 5, [23] = 2,
}
local wallmounted_to_facedir = {
	[0] = 6, [1] = 4, [2] = 1, [3] = 3, [4] = 0, [5] = 2,
}

function ch_core.ch_rotation_wallmounted(pos, node, rotation, simulation)
	assert(pos)
	assert(node)
	if rotation == nil then
		local wm = node.param2 % 8
		return {type = "facedir", facedir = wallmounted_to_facedir[math.min(wm, 5)] , extra_data = node.param2 - wm}
	end
	if rotation.type ~= "facedir" or facedir_to_wallmounted[rotation.facedir] == nil then return false end
	node.param2 = facedir_to_wallmounted[rotation.facedir] + rotation.extra_data
	if not simulation then
		minetest.swap_node(pos, node)
	end
	return true
end

function ch_core.ch_rotation_degrotate(pos, node, rotation, simulation)
	assert(pos)
	assert(node)
	if rotation == nil then
		local degrotate = node.param2
		if degrotate >= 240 then
			degrotate = 239
		end
		return {type = "degrotate", degrotate = degrotate, extra_data = 0}
	end
	if rotation.type ~= "degrotate" or rotation.degrotate < 0 or rotation.degrotate > 239 then return false end
	node.param2 = rotation.degrotate
	if not simulation then
		minetest.swap_node(pos, node)
	end
	return true
end

local function ch_rotation_4dir_generated(pos, node, rotation, simulation)
	local dir = tonumber(string.sub(node.name, -1, -1))
	if rotation == nil then
		if dir == nil or dir < 0 or dir > 3 then return {type = "none"} end
		return {type = "facedir", facedir = dir, extra_data = node.param2}
	end
	if rotation.type ~= "facedir" or rotation.facedir < 0 or rotation.facedir > 3 or
		dir == nil or dir < 0 or dir > 3 then return false end
	node.name = node.name:sub(1, -2)..rotation.facedir
	node.param2 = rotation.extra_data
	if not simulation then
		minetest.swap_node(pos, node)
	end
	return true
end

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

local function rotate_aabb_0(aabb)
	return
end

local function rotate_aabb_1(aabb)
	local o1, o3, o4, o6 = aabb[3], aabb[2], -aabb[4], aabb[6], -aabb[1]
	aabb[1] = o1
	aabb[3] = o3
	aabb[4] = o4
	aabb[6] = o6
end

local function rotate_tiles_0(tiles)
	return tiles
end

--[[
tiles:
	+Y -Y +X -X +Z -Z
]]
local function rotate_tiles_1(tiles)
	return {
		tiles[1],
		tiles[2],
		tiles[5],
		tiles[6],
		tiles[4],
		tiles[3],
	}
end

local function rotate_tiles_2(tiles)
	return rotate_tiles_1(rotate_tiles_1(tiles))
end

local function rotate_tiles_3(tiles)
	return rotate_tiles_1(rotate_tiles_1(rotate_tiles_1(tiles)))
end

local function rotate_aabb_2(aabb)
	rotate_aabb_1(aabb)
	rotate_aabb_1(aabb)
end

local function rotate_aabb_3(aabb)
	rotate_aabb_1(aabb)
	rotate_aabb_1(aabb)
	rotate_aabb_1(aabb)
end

local n_to_rotate = {
	[0] = rotate_aabb_0,
	[1] = rotate_aabb_1,
	[2] = rotate_aabb_2,
	[3] = rotate_aabb_3,
}

local n_to_rotate_tiles = {
	[0] = rotate_tiles_0,
	[1] = rotate_tiles_1,
	[2] = rotate_tiles_2,
	[3] = rotate_tiles_3,
}

local function get_rotated_node_box(fourdir, nodebox)
	if nodebox.type ~= "fixed" then
		return false
	end
	local rotate = assert(n_to_rotate[fourdir])
	local old_fixed = nodebox.fixed
	local new_fixed
	if type(old_fixed[1]) == "table" then
		new_fixed = {}
		for i, aabb in ipairs(old_fixed) do
			local new_aabb = table.copy(aabb)
			rotate(new_aabb)
			new_fixed[i] = new_aabb
		end
	else
		new_fixed = table.copy(old_fixed)
		rotate(new_fixed)
	end
	return {type = "fixed", fixed = new_fixed}
end

local function get_rotated_tiles(fourdir, tiles)
	tiles = table.copy(tiles)
	while #tiles < 6 do
		tiles[#tiles + 1] = tiles[#tiles]
	end
	return n_to_rotate_tiles[fourdir](tiles)
end

function ch_core.register_4dir_nodes(nodename_prefix, options, common_def, o0, o1, o2, o3)
	local overrides = {[0] = o0, [1] = o1, [2] = o2, [3] = o3}
	for i = 0, 3 do
		local def = table.copy(common_def)
		def.ch_rotation = ch_rotation_4dir_generated
		if options.tiles then
			local new_tiles = get_rotated_tiles(i, def.tiles)
			if new_tiles ~= nil then
				def.tiles = new_tiles
			end
		end
		if options.node_box and def.node_box ~= nil then
			local new_node_box = get_rotated_node_box(i, def.node_box)
			if new_node_box ~= nil then
				def.node_box = new_node_box
			end
		end
		if options.selection_box and def.selection_box ~= nil then
			local new_selection_box = get_rotated_node_box(i, def.selection_box)
			if new_selection_box ~= nil then
				def.selection_box = new_selection_box
			end
		end
		if options.collision_box then
			local new_collision_box = get_rotated_node_box(i, def.collision_box)
			if new_collision_box ~= nil then
				def.collision_box = new_collision_box
			end
		end
		if options.drop and i ~= 0 then
			def.drop = nodename_prefix.."0"
		end
		if common_def.groups ~= nil then
			def.groups = table.copy(common_def.groups)
		else
			def.groups = {}
		end
		if i ~= 0 then
			def.groups.not_in_creative_inventory = 1
		end
		for k, v in pairs(overrides[i]) do
			def[k] = v
		end
		minetest.register_node(nodename_prefix..i, def)
	end
	return true
end

ch_core.close_submod("rotation")
