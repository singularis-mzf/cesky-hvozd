local random = math.random

-- https://weblog.jamisbuck.org/2011/1/27/maze-generation-growing-tree-algorithm.html
local function growing_tree(width, depth, chooser)
	if not chooser then
		return {}
	end

	local function to_vertex(i, j)
		return (i - 1) * width + j
	end

	local maze = futil.SparseGraph(width * depth)
	local visited = futil.Set()

	local function get_unvisited_neighbors(i, j)
		local neighbors = {}
		if i ~= 1 and not visited:contains(to_vertex(i - 1, j)) then
			neighbors[#neighbors + 1] = { i - 1, j }
		end
		if i ~= depth and not visited:contains(to_vertex(i + 1, j)) then
			neighbors[#neighbors + 1] = { i + 1, j }
		end
		if j ~= 1 and not visited:contains(to_vertex(i, j - 1)) then
			neighbors[#neighbors + 1] = { i, j - 1 }
		end
		if j ~= width and not visited:contains(to_vertex(i, j + 1)) then
			neighbors[#neighbors + 1] = { i, j + 1 }
		end
		return neighbors
	end

	local cell = { random(depth), random(width) }
	visited:add(to_vertex(unpack(cell)))
	local fringe_cells = { cell }

	while #fringe_cells > 0 do
		local cell_i = chooser(fringe_cells)
		cell = fringe_cells[cell_i]
		local neighbors = get_unvisited_neighbors(unpack(cell))
		if #neighbors == 0 then
			table.remove(fringe_cells, cell_i) -- TODO: expensive (O(n))
		else
			local neighbor = neighbors[random(#neighbors)]
			local neighbor_v = to_vertex(unpack(neighbor))
			local cell_v = to_vertex(unpack(cell))
			visited:add(neighbor_v)
			maze:add_edge(cell_v, neighbor_v)
			maze:add_edge(neighbor_v, cell_v)
			fringe_cells[#fringe_cells + 1] = neighbor
		end
	end

	return maze
end

we_maze.chooser = {}
function we_maze.chooser.random(cells)
	return random(#cells)
end
function we_maze.chooser.newest(cells)
	return #cells
end

function we_maze.algorithm.backtrack(width, depth)
	return growing_tree(width, depth, we_maze.chooser.newest)
end

function we_maze.algorithm.prims(width, depth)
	return growing_tree(width, depth, we_maze.chooser.random)
end
