function we_maze.maze_to_schem(maze, width, depth)
	local function to_vertex(i, j)
		return (i - 1) * width + j
	end

	local schem = {}
	for i = 1, 2 * depth + 1 do
		local row = {}
		for j = 1, 2 * width + 1 do
			if (i % 2 == 0) and (j % 2 == 0) then
				row[j] = true
			elseif (i % 2 ~= 0) and (j % 2 ~= 0) then
				row[j] = false
			elseif i % 2 == 0 and 1 < j and j < 2 * width then
				row[j] = maze:has_edge(to_vertex(i / 2, (j - 1) / 2), to_vertex(i / 2, (j + 1) / 2))
			elseif j % 2 == 0 and 1 < i and i < 2 * depth then
				row[j] = maze:has_edge(to_vertex((i - 1) / 2, j / 2), to_vertex((i + 1) / 2, j / 2))
			else
				row[j] = false
			end
		end
		schem[i] = row
	end

	return schem
end

function we_maze.schem_to_string(schem)
	local rows = {}
	for i = 1, #schem do
		local row = {}
		for j = 1, #schem[i] do
			row[j] = schem[i][j] and " " or "X"
		end
		rows[i] = table.concat(row, "")
	end
	return table.concat(rows, "\n")
end

local function build_maze(maze, width, depth, pos1, pos2, path_width, wall_width, data, area, fill_id, node_ids)
	local schem = we_maze.maze_to_schem(maze, width, depth)
	local z0 = pos1.z
	for i, row in ipairs(schem) do
		local z_width
		if i % 2 == 0 then
			z_width = path_width
		else
			z_width = wall_width
		end
		local x0 = pos1.x
		for j, is_path in ipairs(row) do
			local x_width
			if j % 2 == 0 then
				x_width = path_width
			else
				x_width = wall_width
			end
			for dx = 0, x_width - 1 do
				local x = x0 + dx
				for dz = 0, z_width - 1 do
					local z = z0 + dz
					if is_path then
						for y = pos1.y, pos2.y do
							data[area:index(x, y, z)] = fill_id
						end
					else
						for y = pos1.y, pos2.y do
							data[area:index(x, y, z)] = node_ids[math.random(#node_ids)]
						end
					end
				end
			end
			x0 = x0 + x_width
		end
		z0 = z0 + z_width
	end
end

function we_maze.generate(player_name, wall_nodes, fill_node, path_width, wall_width, algorithm, seed, ...)
	path_width = path_width or 1
	wall_width = wall_width or 1
	algorithm = algorithm or "wilsons"
	if seed then
		math.randomseed(seed)
	end
	local pos1, pos2 = vector.sort(worldedit.pos1[player_name], worldedit.pos2[player_name])
	local manip, area = worldedit.manip_helpers.init(pos1, pos2)
	local data = manip:get_data()
	local fill_id = minetest.get_content_id(fill_node)
	local node_ids = {}
	for i = 1, #wall_nodes do
		node_ids[i] = minetest.get_content_id(wall_nodes[i])
	end
	local width = math.floor(((pos2.x - pos1.x) + 1 - wall_width) / (path_width + wall_width))
	local depth = math.floor(((pos2.z - pos1.z) + 1 - wall_width) / (path_width + wall_width))
	local maze = we_maze.algorithm[algorithm](width, depth, ...)
	build_maze(maze, width, depth, pos1, pos2, path_width, wall_width, data, area, fill_id, node_ids)
	worldedit.manip_helpers.finish(manip, data)

	return maze, we_maze.maze_to_schem(maze, width, depth)
end
