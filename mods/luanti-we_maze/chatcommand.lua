local f = string.format
local S = we_maze.S

local algorithms = {}
for algorithm in futil.table.pairs_by_key(we_maze.algorithm) do
	algorithms[#algorithms + 1] = algorithm
end

worldedit.register_command("maze", {
	description = S("generate a maze"),
	params = S(
		"<wall_node>[,<wall_node,...] [<fill_node=air> [<path_width=1> [<wall_width=1> [<algorithm=@1|random> [<seed>]]]]]",
		table.concat(algorithms, "|")
	),
	privs = { [we_maze.settings.priv] = true },
	require_pos = 2,
	parse = function(param)
		local nodes, rest = unpack(param:split("%s+", false, 1, true))
		if not nodes then
			return false, S("please specify at least one wall node (comma delimited)")
		end
		nodes = nodes:split(",", false)
		if #nodes == 0 then
			return false, S("please specify at least one wall node (comma delimited)")
		end
		local wall_nodes = {}
		for i = 1, #nodes do
			local node = nodes[i]
			local actual_node = worldedit.normalize_nodename(node)
			if not actual_node then
				return false, S("invalid node name for wall: @1", node)
			end
			wall_nodes[i] = actual_node
		end
		rest = rest or ""
		local fill_node, path_width, wall_width, algorithm, seed
		fill_node, rest = unpack(rest:split("%s+", false, 1, true))
		if fill_node then
			if tonumber(fill_node) then
				-- e.g. wielded_light has nodes named 1, 2, 3 etc. but this is more likely a mistake
				return false, S("invalid node name for fill: @1", fill_node)
			end
			local actual_fill_node = worldedit.normalize_nodename(fill_node)
			if not actual_fill_node then
				return false, S("invalid node name for fill: @1", fill_node)
			end
			fill_node = actual_fill_node
		else
			fill_node = "air"
		end
		rest = rest or ""
		path_width, rest = unpack(rest:split("%s+", false, 1, true))
		if path_width then
			local actual_path_width = tonumber(path_width)
			if not futil.is_positive_integer(actual_path_width) then
				return false, S("path_width must be a positive integer not @1", path_width)
			end
			path_width = actual_path_width
		else
			path_width = 1
		end
		rest = rest or ""
		wall_width, rest = unpack(rest:split("%s+", false, 1, true))
		if wall_width then
			local actual_wall_width = tonumber(wall_width)
			if not futil.is_positive_integer(actual_wall_width) then
				return false, S("wall_width must be a positive integer not @1", wall_width)
			end
			wall_width = actual_wall_width
		else
			wall_width = 1
		end
		rest = rest or ""
		algorithm, rest = unpack(rest:split("%s+", false, 1, true))
		if algorithm then
			if algorithm == "random" then
				algorithm = algorithms[math.random(#algorithms)]
			elseif not we_maze.algorithm[algorithm] then
				return false,
					S("unknown algorithm @1. supported are @2, or random", algorithm, table.concat(algorithms, ", "))
			end
		else
			algorithm = "wilsons"
		end
		if rest then
			seed = tonumber(rest)
			if not seed then
				return false, S("seed must be a number")
			end
		end
		return true, wall_nodes, fill_node, path_width, wall_width, algorithm, seed
	end,
	func = function(name, wall_nodes, fill_node, path_width, wall_width, algorithm, seed)
		local dx = math.abs(worldedit.pos1[name].x - worldedit.pos2[name].x) + 1
		local dz = math.abs(worldedit.pos1[name].z - worldedit.pos2[name].z) + 1

		if (dx - wall_width) < (path_width + wall_width) then
			return false, S("maze with given parameters will not fit in the specified volume")
		end
		if (dz - wall_width) < (path_width + wall_width) then
			return false, S("maze with given parameters will not fit in the specified volume")
		end

		minetest.log("action", f("%s invoked //maze @%s-%s", name, worldedit.pos1[name], worldedit.pos2[name]))
		local start = minetest.get_us_time()
		we_maze.generate(name, wall_nodes, fill_node, path_width, wall_width, algorithm, seed)
		return true, S("maze generated in @1s", f("%.03f", (minetest.get_us_time() - start) / 1e6))
	end,
})
