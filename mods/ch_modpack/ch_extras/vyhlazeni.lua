-- VYHLAZENÍ TERÉNU

--[[
general_shapes[i] = {type, vx*z*} // shapedef
rotate_map[0..3] = "vx*z*"
vzorec_to_shape[vzorec] = {shapedef, param2}
material_to_shapes["materiál"][vzorec] = {type, node, node_below, shape}
nodename_to_material["nodename"] = {item = "materiál", shape = shapedef}

TODO:
[ ] implementovat podporu tvarů vysokých dva bloky a jejich osamostatněných polovin
[ ] pod vodou používat výhradně pobřežní tvary, pokud existují
[ ] vyladit chování se stromy, květinami apod.

]]

-- Definice
-- ==========================================================================
-- Definice materiálů, které bude možno vyhlazovat.
local materials = {
	{item = "default:desert_sand"},
	{item = "default:dirt"},
	{item = "default:dirt_with_coniferous_litter"},
	{item = "default:dirt_with_grass"},
	{item = "default:dirt_with_rainforest_litter"},
	-- {item = "default:dirt_with_snow"},
	-- {item = "default:dry_dirt_with_dry_grass"},
	{item = "default:gravel"},
	{item = "default:sand"},
	{item = "default:silver_sand"},
	{item = "default:snowblock"},
}

-- Definice tvarů
-- index => tabulka popisující obecný tvar
local general_shapes = {
	-- NORMAL SHAPES
	{
		type = "normal",
		prefix = "slab_",
		suffix = "",
		vxmzm = 0.5,
		vxpzm = 0.5,
		vxpzp = 0.5,
		vxmzp = 0.5,
	},
	{
		type = "normal",
		prefix = "slope_",
		suffix = "",
		vxmzm = 0,
		vxpzm = 0,
		vxpzp = 1,
		vxmzp = 1,
	},
	{
		type = "normal",
		prefix = "slope_",
		suffix = "_half",
		vxmzm = 0,
		vxpzm = 0,
		vxpzp = 0.5,
		vxmzp = 0.5,
	},
	{
		type = "normal",
		prefix = "slope_",
		suffix = "_half_raised",
		vxmzm = 0.5,
		vxpzm = 0.5,
		vxpzp = 1,
		vxmzp = 1,
	},
	{
		type = "normal",
		prefix = "slope_",
		suffix = "_inner",
		vxmzm = 1,
		vxpzm = 0,
		vxpzp = 1,
		vxmzp = 1,
	},
	{
		type = "normal",
		prefix = "slope_",
		suffix = "_inner_half",
		vxmzm = 0.5,
		vxpzm = 0,
		vxpzp = 0.5,
		vxmzp = 0.5,
	},
	{
		type = "normal",
		prefix = "slope_",
		suffix = "_outer",
		vxmzm = 0,
		vxpzm = 0,
		vxpzp = 0,
		vxmzp = 1,
	},
	{
		type = "normal",
		prefix = "slope_",
		-- suffix = "_outer_half",
		suffix = "_outer_cut_half",
		vxmzm = 0,
		vxpzm = 0,
		vxpzp = 0,
		vxmzp = 0.5,
	},
	{
		type = "normal",
		prefix = "slope_",
		suffix = "_outer_half_raised",
		vxmzm = 0.5,
		vxpzm = 0.5,
		vxpzp = 0.5,
		vxmzp = 1,
	},
	{
		type = "normal",
		prefix = "slope_",
		suffix = "_cut",
		vxmzm = 0.5,
		vxpzm = 0,
		vxpzp = 0.5,
		vxmzp = 1,
	},
	{
		type = "normal",
		prefix = "slope_",
		suffix = "_inner_cut_half_raised",
		vxmzm = 1,
		vxpzm = 0.5,
		vxpzp = 1,
		vxmzp = 1,
	},
	{
		type = "normal",
		prefix = "",
		suffix = "",
		vxmzm = 1,
		vxpzm = 1,
		vxpzp = 1,
		vxmzp = 1,
	},
	--[[ {
		type = "normal",
		prefix = "slope_",
		suffix = "_inner_half_raised",
		vxmzm = 1,
		vxpzm = 0.5,
		vxpzp = 1,
		vxmzp = 1,
	}, ]]
}

--[[
local general_double_shapes = {
	-- DOUBLE SHAPES
	{
		type = "double",
		prefix = "slope_",
		suffix = "_inner_cut",
		upper_prefix = "slope_",
		upper_suffix = "_outer_cut",
		vxmzm = 1,
		vxpzm = 0,
		vxpzp = 1,
		vxmzp = 2,
	},
	{
		type = "double",
		prefix = "slope_",
		suffix = "_inner_cut_half_raised",
		upper_prefix = "slope_",
		upper_suffix = "_outer_cut_half",
		vxmzm = 1,
		vxpzm = 0.5,
		vxpzp = 1,
		vxmzp = 1.5,
	},
}
]]

local vyhladit_rollback_log = {}

--
-- assert_has(t, fields...)
-----------------------------------------------------------------------------
local function assert_has(t, ...)
	if type(t) ~= "table" then
		error("Argument is not a table!")
	end
	for _, name in ipairs({...}) do
		if t[name] == nil then
			error("Argument does not have the required field '"..name.."'!")
		end
	end
	return t
end

--
-- assert_is_shape(x)
-----------------------------------------------------------------------------
local function assert_is_shape(t)
	if type(t) ~= "table" then
		error("Argument is not a table!")
	end
	for _, name in ipairs({"vxmzm", "vxpzm", "vxpzp", "vxmzp"}) do
		if t[name] == nil then
			error("Argument is not a shape, because does not have the field '"..name.."'!: "..dump2(t))
		end
	end
	return t
end

--
-- assert_not_nil(x)
-----------------------------------------------------------------------------
local function assert_not_nil(x)
	if x == nil then
		error("Assertion failed!")
	end
	return x
end

--
--
-----------------------------------------------------------------------------
local function shape_id(t)
	if t == nil then
		minetest.log("warning", "shape_id() called with nil argument!")
		return "nil"
	end
	assert_is_shape(t)
	-- return (t.vxmzm or "nil")..","..(t.vxpzm or "nil")..","..(t.vxpzp or "nil")..","..(t.vxmzp or "nil")
	return t.vxmzm..","..t.vxpzm..","..t.vxpzp..","..t.vxmzp
end

local rotate_map = {
	[0] = "vxmzm",
	[1] = "vxpzm",
	[2] = "vxpzp",
	[3] = "vxmzp",
}

--
--
-----------------------------------------------------------------------------
local function rotate_shape(shape, facedir)
	if facedir == nil or not rotate_map[facedir] then
		error("rotate_tvar(): invalid facedir "..(facedir or "nil"))
	end
	if shape == nil then
		return nil -- accepts nil
	end
	assert_is_shape(shape)
	local result = {}
	for i = 0, 3 do
		result[rotate_map[i]] = shape[rotate_map[(facedir + i) % 4]]
	end
	return result
end

-- vzorec tvaru => {shapedef = generic shape def, param2 = odpovídající otočení}
local vzorec_to_shape = {}
local vzorec_to_shape_pocet = 0

for i, shape in ipairs(general_shapes) do
	assert_is_shape(shape)
	local vzorce = {
		[0] = shape_id(shape),
		[1] = shape_id(rotate_shape(shape, 1)),
		[2] = shape_id(rotate_shape(shape, 2)),
		[3] = shape_id(rotate_shape(shape, 3)),
	}

	for param2 = 0,3 do
		local vzorec = vzorce[param2]
		if vzorec_to_shape[vzorec] == nil then
			vzorec_to_shape[vzorec] = {shape = shape, param2 = param2}
			vzorec_to_shape_pocet = vzorec_to_shape_pocet + 1
		else
			print("duplicity at key <"..vzorec..">: existing: "..dump2(vzorec_to_shape[vzorec])..", new = "..dump2({shape = shape, param2 = param2}))
		end

		if shape.vxmzm == shape.vxpzm and shape.vxpzm == shape.vxpzp and shape.vxpzp == shape.vxmzp and shape.vxmzp == shape.vxmzm then
			-- print("break at key "..vzorec..", because it is a slab")
			break
		end
	end
end

-- print("vygenerováno "..vzorec_to_shape_pocet.." vzorců")

-- Itemstring materiálu => tabulka: vzorec tvaru => {type, node, node_below, shapedef}
local material_to_shapes = {}

-- Itemstring libovolného tvaru => {item = itemstring materiálu, shapedef}
local nodename_to_material = {}

for _, material in ipairs(materials) do
	local item = material.item
	local modname, subname = item:match("^(.*):(.*)$")
	if (modname or subname) == nil then
		error("Invalid item: "..item.."!")
	end
	if material.prefix == nil then
		if modname == "default" then
			material.prefix = "moreblocks:"
		else
			material.prefix = modname..":"
		end
	end
	if material.name == nil then
		material.name = subname
	end

	local matshapes = {}
	for vzorec, shape_info in pairs(vzorec_to_shape) do
		local shape, param2 = shape_info.shape, shape_info.param2
		local nodename
		if shape.prefix == "" and shape.suffix == "" then
			nodename = material.item
		else
			nodename = material.prefix..shape.prefix..material.name..shape.suffix
		end
		if minetest.registered_nodes[nodename] ~= nil then
			assert_not_nil(shape.type)
			if shape.type == "normal" then
				nodename_to_material[nodename] = {
					item = material.item,
					shape = shape,
				}
			end
			local data
			if shape.type == "normal" then
				if shape.prefix == "" and shape.suffix == "" then
					data = {
						node = {name = material.item, param2 = param2},
						shape = shape,
						type = "normal",
					}
				else
					data = {
						node = {name = nodename, param2 = param2},
						shape = shape,
						type = "normal"
					}
					local bankslope_node_name = material.prefix.."bankslope_"..material.name..shape.suffix
					if shape.prefix == "slope_" and minetest.registered_nodes[bankslope_node_name] then
						data.bankslope_node = {name = bankslope_node_name, param2 = param2}
					end
				end
			--[[
			elseif shape.type == "double" then
				data = {
					node = {name = material.prefix..shape.upper_prefix..material.name..shape.upper_suffix, param2 = param2},
					node_below = {name = material.prefix..shape.prefix..material.name..shape.suffix, param2 = param2},
					shape = shape,
					type = "double",
				} ]]
			else
				error("Invalid shape type: "..shape.type)
			end
			matshapes[vzorec] = data
		end
	end
	material_to_shapes[material.item] = matshapes
end

--
-- analyze_node(pos) => {material, param2, vx*z*} or nil
-----------------------------------------------------------------------------
local function analyze_node(pos)
	local node = minetest.get_node_or_nil(pos)
	if node == nil then
		return nil
	end
	local material = nodename_to_material[node.name]
	if material == nil then
		return nil
	end
	local param2 = 0
	if node.param2 ~= nil and rotate_map[node.param2] ~= nil then
		param2 = node.param2
	end
	local result = rotate_shape(material.shape, param2)
	assert_is_shape(result)
	result.param2 = param2
	result.material = material.item

	minetest.log("action", "[analyze_node]"..minetest.pos_to_string(pos).." "..node.name.."/"..node.param2.." => "..result.material.." "..shape_id(result))
	return result
end

--
-- compute_abcd(nodes, map) => y-coodinate or nil
-----------------------------------------------------------------------------
local function compute_abcd(nodes, map)
	local sum, count = 0, 0

	for i, key in pairs(map) do
		local node = nodes[i]
		if node.type == "normal" then
			-- print("sum = "..sum.." + "..xnode.pos.y.." + "..xnode[key])
			sum = sum + node.pos.y + node[key]
			count = count + 1
		end
	end
	if count > 0 then
		return math.round(2 * sum / count - 0.01) / 2
	end
end

--
-- get_node_category(pos) => air|ignore|water
-----------------------------------------------------------------------------
local function get_node_category(pos)
	local node = minetest.get_node_or_nil(pos)
	if node == nil then
		return "ignore"
	elseif node.name == "air" then
		return "air"
	else
		local ndef = minetest.registered_nodes[node.name]
		if ndef == nil then
			return "ignore" -- unknown node
		elseif ndef.liquidtype ~= nil and ndef.liquidtype ~= "none" then
			return "water"
		elseif ndef.groups ~= nil and ndef.groups.attached_node ~= nil and ndef.groups.attached_node > 0 then
			return "air"
		else
			return "ignore" -- other node
		end
	end
end


-- material.."/"..původnívzorec => náhradní vzorec
local shape_replacement_cache = {}

--
-- find_shape(...) => {type, node, node_below, bankslope_node, shape} or nil
-----------------------------------------------------------------------------
local function find_shape(material, shape, exact_only)
	local vzorec = shape_id(shape)
	local mat_shapes = material_to_shapes[material]
	if mat_shapes[vzorec] ~= nil then
		return mat_shapes[vzorec]
	end
	if exact_only then
		return
	end
	local cache_key = material.."/"..vzorec
	local cached_vzorec = shape_replacement_cache[cache_key]
	if cached_vzorec ~= nil and mat_shapes[cached_vzorec] ~= nil then
		return mat_shapes[cached_vzorec] -- cache hit
	end

	local best_shape, best_shape_exact_hits, best_shape_diff, best_vzorec
	for vzorec_tvaru, matshape in pairs(mat_shapes) do
		local exact_hits, diff = 0, 0
		for _, key in ipairs({"vxpzp", "vxmzp", "vxpzm", "vxmzm"}) do
			local new_diff = math.abs(shape[key] - matshape.shape[key])
			if new_diff ~= 0 then
				diff = diff + new_diff
			else
				exact_hits = exact_hits + 1
			end
		end
		if best_shape == nil or exact_hits > best_shape_exact_hits or (exact_hits == best_shape_exact_hits and diff < best_shape_diff) then
			best_shape = matshape
			best_shape_diff = diff
			best_shape_exact_hits = exact_hits
			best_vzorec = vzorec_tvaru
		end
	end
	if best_shape == nil then
		return
	end
	if cached_vzorec == nil then
		shape_replacement_cache[cache_key] = best_vzorec
		minetest.log("warning", "added shape replacement "..cache_key.." => "..best_vzorec.." to the cache")
	end
	-- print("find_shape(): "..(best_shape and shape_id(best_shape.shape) or "nil").." selected instead of "..vzorec.." with exact_hits = "..(best_shape_exact_hits or "nil").." and diff = "..(best_shape_diff or "nil"))
	return best_shape
end

local map_a = {[1] = "vxpzp", [2] = "vxmzp", [4] = "vxpzm", [5] = "vxmzm"}
local map_b = {[2] = "vxpzp", [3] = "vxmzp", [5] = "vxpzm", [6] = "vxmzm"}
local map_c = {[4] = "vxpzp", [5] = "vxmzp", [7] = "vxpzm", [8] = "vxmzm"}
local map_d = {[5] = "vxpzp", [6] = "vxmzp", [8] = "vxpzm", [9] = "vxmzm"}

--
-- get_updated_nodes(...)
-----------------------------------------------------------------------------
local function get_updated_nodes(nodes, value_map_pairs)
	local result = {}
	for i = 1, 9 do
		result[i] = nodes[i]
	end
	for _, pair in ipairs(value_map_pairs) do
		if pair[1] ~= nil then
			for i, key in pairs(pair[2]) do
				local node = result[i]
				if node.type == "normal" and node.pos.y + node[key] ~= pair[1] then
					node[key] = pair[1] - node.pos.y
					-- print("get_updated_nodes(): node "..i.." changed")
					node.changed = true
				end
			end
		end
	end
	return result
end

--
-- load_nodes(pos) => {[1..9] = {type, pos, old_node,
--    type == "normal": + material, vx*z*, old_shape
-- }} or nil if the central node is not of a known material
-------------------------------------------------------------------------------
local function load_nodes(pos)
	--[[
		nodes:
		[1]    [2]    [3]
		    A      B
		[4]    [5]    [6]
		    C      D
		[7]    [8]    [9]

		        |
		x ->, z v
	]]
	local i, lpos, node, node_analysis, above_category
	local nodes = {}

	-- nodes[5]
	node = minetest.get_node_or_nil(pos)
	lpos = vector.offset(pos, 0, 1, 0)
	above_category = get_node_category(lpos)
	node_analysis = analyze_node(pos)

	if node_analysis == nil or above_category == "ignore" then
		-- print("DEBUG: load_nodes() will fail: "..dump2({node_analysis = node_analysis, above_category = above_category}))
		return
	end

	nodes[5] = {
		type = "normal",
		pos = pos,
		old_node = node,
		old_shape = node_analysis,
		above_category = above_category,
		vxmzm = node_analysis.vxmzm,
		vxpzm = node_analysis.vxpzm,
		vxpzp = node_analysis.vxpzp,
		vxmzp = node_analysis.vxmzp,
		material = node_analysis.material,
	}
	-- minetest.log("action", "[vyhl] Node at "..minetest.pos_to_string(lpos).." ("..node.name..", "..node.param2..") read as "..nodes[5].material.." of shape "..shape_id(nodes[5])..", above_category = "..(above_category or "nil"))

	i = 1
	for z = pos.z - 1, pos.z + 1 do
		for x = pos.x - 1, pos.x + 1 do
			if i ~= 5 then
				lpos = vector.new(x, pos.y, z)
				above_category = "ignore"
				for j = 3, -3, -1 do
					print("D")
					lpos.y = pos.y + j
					node = minetest.get_node_or_nil(lpos)
					node_analysis = analyze_node(lpos)
					if node_analysis ~= nil then
						above_category = get_node_category(vector.offset(lpos, 0, 1, 0))
						break
					end
				end
				if above_category == "ignore" then
					-- surface node not found at all
					nodes[i] = {
						type = "ignore",
						pos = lpos,
						old_node = node,
					}
				else
					assert_not_nil(node_analysis)
					nodes[i] = {
						type = "normal",
						pos = lpos,
						old_node = node,
						old_shape = node_analysis,
						above_category = above_category,
						vxmzm = node_analysis.vxmzm,
						vxpzm = node_analysis.vxpzm,
						vxpzp = node_analysis.vxpzp,
						vxmzp = node_analysis.vxmzp,
						material = node_analysis.material,
					}
					-- minetest.log("action", "[vyhl] Node at "..minetest.pos_to_string(lpos).." ("..node.name..", "..node.param2..") read as "..nodes[i].material.." of shape "..shape_id(nodes[i])..", above_category = "..above_category)
				end
			end
			i = i + 1
		end
	end
	return nodes
end

--
-- vyhladit(pos)
-----------------------------------------------------------------------------
local function vyhladit(pos, operation_id)
	local nodes = load_nodes(pos)
	if nodes == nil then
		return
	end
	-- print("DEBUG: vyhladit() will work at "..minetest.pos_to_string(pos))
	-- print("NODES = "..dump2(nodes))
	local newa = compute_abcd(nodes, map_a)
	local newb = compute_abcd(nodes, map_b)
	local newc = compute_abcd(nodes, map_c)
	local newd = compute_abcd(nodes, map_d)

	if operation_id then
		minetest.log("action", "[VYHLAZENI "..operation_id.."] new = {A = "..(newa or "nil")..", B = "..(newb or "nil")..", C = "..(newc or "nil")..", D = "..(newd or "nil").."}")
	end
	-- print("new values: "..dump2({newa = newa, newb = newb, newc = newc, newd = newd}))

	local new_nodes = get_updated_nodes(nodes, {{newa, map_a}, {newb, map_b}, {newc, map_c}, {newd, map_d}})

	if new_nodes == nil then
		minetest.log("action", "vyhladit() failed completely")
		return -- failed completely
	end

	local result = {}
	for i = 1, 9 do
		local node = new_nodes[i]
		if node.changed then
			assert_is_shape(node)
			-- print("konsolidovat() B "..i)

			local nodes_to_set = {}
			local shift_up = false
			local new_shape
			local old_vzorec = shape_id(node.old_shape)
			-- print("konsolidovat() B "..i.." 0, node = "..dump2(node))

			-- attempt 1
			new_shape = find_shape(node.material, node, true)
			if new_shape == nil then
				-- print("konsolidovat() B "..i.." 1")
				-- attempt 2
				local shifted_shape = {vxmzm = node.vxmzm - 1, vxpzm = node.vxpzm - 1, vxpzp = node.vxpzp - 1, vxmzp = node.vxmzp - 1}
				-- print("konsolidovat() B "..i.." 1B")
				new_shape = find_shape(node.material, shifted_shape, true)
				-- print("konsolidovat() B "..i.." 1C")
				shift_up = new_shape ~= nil
				-- print("konsolidovat() B "..i.." 2")
				if shift_up then
					for k, v in pairs(shifted_shape) do
						node[k] = v
					end
					node.pos = vector.offset(node.pos, 0, 1, 0)
					node.old_node = minetest.get_node(node.pos)
					nodes_to_set[-1] = {name = node.material, param2 = 0}
				else
					-- print("konsolidovat() B "..i.." 3")
					-- attempt 3 (final)
					new_shape = find_shape(node.material, node, false)
					-- print("konsolidovat() B "..i.." 4")
				end
			end

			if new_shape == nil then
				minetest.log("warning", "tvar "..shape_id(new_shape).."\" nenalezen u materiálu "..node.material)
			else
				--[[ if new_shape.type == "normal" then
				elseif new_shape.type == "double" then
					nodes_to_set[0] = new_shape.node
					nodes_to_set[-1] = new_shape.node_below
				elseif new_shape.type == "bankslope" then
					nodes_to_set[0] = {name = "air", param2 = 0}
					nodes_to_set[-1] = new_shape.node_below
				end ]]
				if new_shape.type == "normal" and node.above_category == "water" and new_shape.bankslope_node ~= nil then
					local water_node = "default:water_source"
					local node_above = minetest.get_node_or_nil(vector.offset(node.pos, 0, 1, 0))
					local ndef = node_above and minetest.registered_nodes[node_above.name]
					if ndef ~= nil and ndef.liquid_alternative_source ~= nil then
						water_node = ndef.liquid_alternative_source
					end
					nodes_to_set[0] = {name = "water_node", param2 = 0}
					nodes_to_set[-1] = new_shape.bankslope_node
					minetest.log("warning", "DEBUG: Will use a bank slope at "..minetest.pos_to_string(node.pos))
				elseif new_shape.type == "normal" then
					nodes_to_set[0] = new_shape.node
				else
					error("Invalid new_shape.type: "..(new_shape.type or "nil"))
				end
			end
			-- print("vyhladit() B "..i.." 7")

			minetest.log("action", "DEBUG: Will change shape of "..minetest.pos_to_string(node.pos).." from "..old_vzorec.." ("..node.old_node.name..", "..node.old_node.param2..") ".." to "..shape_id(new_shape.shape).." ("..((nodes_to_set[0] or nodes_to_set[-1] or {}).name or "nil")..", "..((nodes_to_set[0] or nodes_to_set[-1] or {}).param2 or "nil")..")")

			for j = -1, 0 do
				if nodes_to_set[j] ~= nil then
					local lpos = vector.offset(node.pos, 0, j, 0)
					table.insert(result, {
						pos = lpos,
						old = minetest.get_node(lpos),
						new = table.copy(nodes_to_set[j]),
					})
				end
			end
		end
	end

	return result
end

--[[
local function test(player_name, param)
	local pos = minetest.string_to_pos(param)
	if pos == nil then
		return false, "Neplatné zadání"
	end

	local result = vyhladit(pos)

	if result == nil then
		return false, "Nepovedlo se."
	end

	for _, action in ipairs(result) do
		minetest.swap_node(action.pos, action.new)
	end

	minetest.after(15, function(res)
		for _, action in ipairs(result) do
			minetest.swap_node(action.pos, action.old)
		end
		minetest.chat_send_player(player_name, "Rollbacked.")
	end, result)

	return true
end
]]

ch_extras.vyhladit = function(pos)
	local result = vyhladit(pos)
	if result == nil then
		return false, "Nepovedlo se."
	end
	local count = 0
	for _, action in ipairs(result) do
		local hash = minetest.hash_node_position(action.pos)
		if vyhladit_rollback_log[hash] == nil then
			vyhladit_rollback_log[hash] = action.old
		end
		minetest.swap_node(action.pos, action.new)
		count = count + 1
	end
	-- minetest.log("warning", "[vyhl] "..count.." bloků nahrazeno.")
	return true, count.." bloků nahrazeno."
end

local function vyhladit_rollback(player_name, param)
	local rollback_log = vyhladit_rollback_log
	vyhladit_rollback_log = {}
	local count = 0
	for hash, node in pairs(rollback_log) do
		local pos = minetest.get_position_from_hash(hash)
		minetest.swap_node(pos, node)
		count = count + 1
	end
	return true, count.." bloků vráceno."
end

local def = {
	description = "Zahodí záznamy o blocích zasažených funkcí vyhlazení.",
	privs = {server = true},
	func = function(player_name, param)
		vyhladit_rollback_log = {}
	end,
}
minetest.register_chatcommand("povrdit_vyhlazení", def)
minetest.register_chatcommand("povrdit_vyhlazeni", def)

def = {
	description = "Vrátí do původního stavu všechny bloky zasažené funkcí vyhlazení.",
	privs = {server = true},
	func = vyhladit_rollback,
}
minetest.register_chatcommand("vyhladit_rollback", def)

local function on_use(itemstack, user, pointed_thing)
	local player_name = user and user:get_player_name()
	if not player_name or not minetest.check_player_privs(player_name, "server") then
		return
	end
	if pointed_thing.type ~= "node" then
		ch_core.systemovy_kanal(player_name, "Nutno kliknout na blok.")
		return
	end
	local result = vyhladit(pointed_thing.under)
	if result == nil then
		ch_core.systemovy_kanal(player_name, "Nemám co vyhlazovat.")
		return
	end
	if result[1] == nil then
		ch_core.systemovy_kanal(player_name, "Operace proběhla, ale nebyly nahrazeny žádné bloky.")
		return
	end
	local operation_id = math.random(1, 9999)
	local count = 0
	local positions = {}
	minetest.log("action", "[VYHLAZENI "..operation_id.."] Started")
	for i, action in ipairs(result) do
		local hash = minetest.hash_node_position(action.pos)
		if vyhladit_rollback_log[hash] == nil then
			vyhladit_rollback_log[hash] = action.old
		end
		count = count + 1
		minetest.log("action", "[VYHLAZENI "..operation_id.."]["..count.."] at "..minetest.pos_to_string(action.pos)..": "..action.old.name.."/"..action.old.param2.." => "..action.new.name.."/"..action.new.param2)
		minetest.swap_node(action.pos, action.new)
		positions[i] = action.pos
	end
	minetest.log("action", "[VYHLAZENI "..operation_id.."] Finished: "..count.." replacements.")
	for i, pos in ipairs(positions) do
		minetest.check_for_falling(pos)
	end
	-- minetest.log("warning", "[vyhl] "..count.." bloků nahrazeno.")
	ch_core.systemovy_kanal(player_name, count.." bloků nahrazeno.")
end

def = {
	description = "hůlka vyhlazení [EXPERIMENTÁLNÍ]",
	inventory_image = "ch_extras_creative_inv.png",
	wield_image = "ch_extras_creative_inv.png",
	on_use = on_use,
	groups = {tools = 1},
}

minetest.register_tool("ch_extras:vyhlazeni", def)
