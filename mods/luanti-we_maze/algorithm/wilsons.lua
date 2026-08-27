local random = math.random

local function offset(i, j, dir)
	if dir == "u" then
		return i - 1, j
	elseif dir == "d" then
		return i + 1, j
	elseif dir == "l" then
		return i, j - 1
	elseif dir == "r" then
		return i, j + 1
	end
end

-- https://weblog.jamisbuck.org/2011/1/20/maze-generation-wilson-s-algorithm
function we_maze.algorithm.wilsons(width, depth)
	local function to_vertex(i, j)
		return (i - 1) * width + j
	end

	local maze = futil.SparseGraph(width * depth)
	local visited = futil.Set()

	local remaining = {}
	for i = 1, depth do
		for j = 1, width do
			remaining[#remaining + 1] = { i, j }
		end
	end

	local function remove_random_remaining()
		local i = random(#remaining)
		local el = remaining[i]
		table.remove(remaining, i) -- TODO O(n) but lua makes it hard to be better...
		return unpack(el)
	end
	local function remove(i, j) -- TODO O(n) but lua makes it hard to be better...
		for k = 1, #remaining do
			local el2 = remaining[k]
			if i == el2[1] and j == el2[2] then
				table.remove(remaining, k)
				return
			end
		end
	end
	local function get_valid_dirs(i, j)
		local dirs = {}
		if i ~= 1 then
			dirs[#dirs + 1] = "u"
		end
		if i ~= depth then
			dirs[#dirs + 1] = "d"
		end
		if j ~= 1 then
			dirs[#dirs + 1] = "l"
		end
		if j ~= width then
			dirs[#dirs + 1] = "r"
		end
		return dirs
	end
	local function find_path_to_maze(i, j)
		local path = {}
		for k = 1, depth do
			path[k] = {}
		end
		while not visited[to_vertex(i, j)] do
			local dirs = get_valid_dirs(i, j)
			local dir = dirs[random(#dirs)]
			path[i][j] = dir
			i, j = offset(i, j, dir)
		end
		return path
	end

	local i, j = remove_random_remaining()
	visited[to_vertex(i, j)] = true

	while #remaining > 0 do
		i, j = remove_random_remaining()
		local path = find_path_to_maze(i, j)
		local dir = path[i][j]
		while dir do
			local v = to_vertex(i, j)
			visited[v] = true
			remove(i, j)
			local next_i, next_j = offset(i, j, dir)
			local next_v = to_vertex(next_i, next_j)
			maze:add_edge(v, next_v)
			maze:add_edge(next_v, v)
			i, j = next_i, next_j
			dir = path[i][j]
		end
	end

	return maze
end
