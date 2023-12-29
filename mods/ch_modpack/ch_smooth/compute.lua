local assert_not_nil = ch_smooth.assert_not_nil

local NodeManipulator = assert_not_nil(ch_smooth.NodeManipulator)
local assert_is_shape = assert_not_nil(ch_smooth.assert_is_shape)
local load_nodes = assert_not_nil(ch_smooth.load_nodes)
local material_to_shapes = assert_not_nil(ch_smooth.material_to_shapes)
local shape_id = assert_not_nil(ch_smooth.shape_id)

local empty_table = {}

--
-- compute_abcd(nodes, map) => y-coodinate or nil
-----------------------------------------------------------------------------
local function compute_abcd(nodes, map)
	local sum, count = 0, 0

	for i, key in pairs(map) do
		local node = nodes[i]
		if node.shape_type == "normal" then
			print("DEBUG: sum = "..sum.." + "..node.base_pos.y.." + "..node[key].." (key = "..key..")")
			sum = sum + node.base_pos.y + node[key]
			count = count + 1
		end
	end
	if count > 0 then
		print("compute_abcd(): count == "..count..", sum == "..sum..", result == "..(math.round(2 * sum / count - 0.01) / 2))
		return math.round(2 * sum / count - 0.01) / 2
	else
		print("compute_abcd(): count == 0 (no data)")
		return nil
	end
end

-- material.."/"..původnívzorec => náhradní vzorec
local shape_replacement_cache = {}

local find_shape_map = {"vxpzp", "vxmzp", "vxpzm", "vxmzm"}

--
-- find_shape(...) => {type, node, [node_above], [node_above2], shape} or nil
--
-- Pokusí se najít sestavu bloků odpovídající požadovanému tvaru.
-- Umí hledat i přibližně.
-----------------------------------------------------------------------------
local function find_shape(material, shape, options)
	if options == nil then
		options = {}
	end
	print("find_shape() called: "..dump2({material = material, shape = shape, options = options}))
	local exact_only = options.exact_only
	local vzorec = shape_id(shape)
	local mat_shapes = material_to_shapes[material]
	local result = mat_shapes[vzorec]
	if exact_only or result ~= nil then
		return result -- exact match
	end

	local cache_key = material.."/"..vzorec
	local cached_vzorec = shape_replacement_cache[cache_key]
	if cached_vzorec ~= nil and mat_shapes[cached_vzorec] ~= nil then
		return mat_shapes[cached_vzorec] -- cache hit
	end

	local best_shape, best_shape_exact_hits, best_shape_diff, best_vzorec
	for vzorec_tvaru, matshape in pairs(mat_shapes) do
		local exact_hits, diff = 0, 0
		for _, key in ipairs(find_shape_map) do
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
		return -- nothing found
	end
	if cached_vzorec == nil then
		shape_replacement_cache[cache_key] = best_vzorec
		minetest.log("warning", "added shape replacement "..cache_key.." => "..best_vzorec.." to the cache")
	end
	print("find_shape(): "..(best_shape and shape_id(best_shape.shape) or "nil").." selected instead of "..vzorec.." with exact_hits = "..(best_shape_exact_hits or "nil").." and diff = "..(best_shape_diff or "nil"))
	return best_shape
end
-- ch_smooth.find_shape = find_shape

local map_a = {[1] = "vxpzp", [2] = "vxmzp", [4] = "vxpzm", [5] = "vxmzm"}
local map_b = {[2] = "vxpzp", [3] = "vxmzp", [5] = "vxpzm", [6] = "vxmzm"}
local map_c = {[4] = "vxpzp", [5] = "vxmzp", [7] = "vxpzm", [8] = "vxmzm"}
local map_d = {[5] = "vxpzp", [6] = "vxmzp", [8] = "vxpzm", [9] = "vxmzm"}

--
-- vyhladit(pos, operation_id)
-----------------------------------------------------------------------------
local function vyhladit(pos, operation_id)
	print("\n\n[VYHLADIT "..operation_id.."]: smoothing started at "..minetest.pos_to_string(pos))
	local nm = NodeManipulator:new()
	print("NodeManipulator created.")
	local nodes = load_nodes(nm, pos)
	print("load_nodes() finished.")
	if nodes == nil then
		print("nodes == nil")
		return
	end
	print("DEBUG: vyhladit() will work at "..minetest.pos_to_string(pos))
	local y_base = nodes[5].base_pos.y
	-- print("NODES = "..dump2(nodes))
	local newa = compute_abcd(nodes, map_a)
	local newb = compute_abcd(nodes, map_b)
	local newc = compute_abcd(nodes, map_c)
	local newd = compute_abcd(nodes, map_d)

	print(visualize_shape("ABCD", {vxmzm = newa, vxpzm = newb, vxmzp = newc, vxpzp = newd}))
	if operation_id then
		minetest.log("action", "[VYHLAZENI "..operation_id.."] new = {A = "..(newa or "nil")..", B = "..(newb or "nil")..", C = "..(newc or "nil")..", D = "..(newd or "nil").."}")
	end
	-- print("new values: "..dump2({newa = newa, newb = newb, newc = newc, newd = newd}))
	--[[if newa ~= nil then
		newa = newa - y_base
	end
	if newb ~= nil then
		newb = newb - y_base
	end
	if newc ~= nil then
		newc = newc - y_base
	end
	if newd ~= nil then
		newd = newd - y_base
	end]] 

	local value_map_pairs = {
		{newa, map_a},
		{newb, map_b},
		{newc, map_c},
		{newd, map_d}
	}
	for _, pair in ipairs(value_map_pairs) do
		if pair[1] ~= nil then
			for i, key in pairs(pair[2]) do
				local node = nodes[i]
				if node.shape_type ~= "ignore" and node.base_pos.y + node[key] ~= pair[1] then
					local old_value = node[key]
					node[key] = pair[1] - node.base_pos.y
					print("get_updated_nodes(): node "..i.." changed: "..key.." changed from "..old_value.." to "..node[key]..".")
					node.changed = true
				end
			end
		end
	end

	-- local new_nodes = get_updated_nodes(nodes, {{newa, map_a}, {newb, map_b}, {newc, map_c}, {newd, map_d}})

	--[[ if new_nodes == nil then
		minetest.log("action", "vyhladit() failed completely")
		return -- failed completely
	end ]]

	for i = 1, 9 do
		local node = nodes[i]
		if node.shape_type ~= "ignore" and node.changed then
			assert_is_shape(node)

			-- local nodes_to_set = {}
			-- local shift_up = false
			-- local new_shape
			-- local old_vzorec = shape_id(node.old_shape)
			print("konsolidovat() B "..i.." 0, node = "..dump2(node))

			-- attempt 1: exact match only
			local new_shape = find_shape(node.material, node, {exact_only = true})
			if new_shape == nil then
				print("konsolidovat() B "..i.." 1")
				-- attempt 2
				local shifted_shape = {
					vxmzm = node.vxmzm - 1,
					vxpzm = node.vxpzm - 1,
					vxpzp = node.vxpzp - 1,
					vxmzp = node.vxmzp - 1
				}
				-- print("konsolidovat() B "..i.." 1B")
				new_shape = find_shape(node.material, shifted_shape, {exact_only = true})
				-- print("konsolidovat() B "..i.." 1C")
				if new_shape ~= nil then
					-- shift up
					print("konsolidovat() B "..i.." 2")
					for k, v in pairs(shifted_shape) do
						node[k] = v
					end
					node.pos.y = node.pos.y + 1
				else
					-- print("konsolidovat() B "..i.." 3")
					-- attempt 3 (final)
					new_shape = find_shape(node.material, node)
					-- print("konsolidovat() B "..i.." 4")
				end
			end

			if new_shape == nil then
				minetest.log("warning", "tvar "..shape_id(new_shape).."\" nenalezen u materiálu "..node.material)
			else
				print(visualize_shape(new_shape.base_pos, new_shape))
				-- print("New shape found = "..dump2(new_shape))
				nm:set(vector.copy(node.base_pos), new_shape.node.name, new_shape.node.param2)
				if new_shape.node_above ~= nil then
					nm:set(vector.offset(node.base_pos, 0, 1, 0), new_shape.node_above.name, new_shape.node_above.param2)
				end
				if new_shape.node_above2 ~= nil then
					nm:set(vector.offset(node.base_pos, 0, 2, 0), new_shape.node_above2.name, new_shape.node_above2.param2)
				end
				--[[
				if new_shape.type == "normal" then
					nm:set(node.base_pos, new_shape.node.name, new_shape.node.param2)
				elseif new_shape.type == "bank" then
					print("bank shape...")
					nm:set(node.base_pos, new_shape.node.name, new_shape.node.param2)
					nm:set(vector.offset(node.base_pos, 0, 1, 0), node.air_node_name, 0)
				elseif new_shape.type == "double" then
					print("double shape...")
					nm:set(node.base_pos, new_shape.node.name, new_shape.node.param2)
				elseif new_shape.type == "double_bank" then
				else
					minetest.log("warning", "Unknown new_shape.type: "..(new_shape.type or "nil").."!")
				end
				]]
				--[[ if new_shape.type == "normal" then
				elseif new_shape.type == "double" then
					nodes_to_set[0] = new_shape.node
					nodes_to_set[-1] = new_shape.node_below
				elseif new_shape.type == "bankslope" then
					nodes_to_set[0] = {name = "air", param2 = 0}
					nodes_to_set[-1] = new_shape.node_below
				end ]]
				--[[
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
				]]
			end
			-- print("vyhladit() B "..i.." 7")

			--[[
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
			]]
		end
	end

	print("[VYHLADIT "..operation_id.."]: smoothing finished at "..minetest.pos_to_string(pos).."\n\n")

	return {}
end

ch_smooth.vyhladit = vyhladit

