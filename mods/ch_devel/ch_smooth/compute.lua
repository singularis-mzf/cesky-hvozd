local ch_smooth = ...

local NodeManipulator = assert(ch_smooth.NodeManipulator)
local assert_is_shape = assert(ch_smooth.assert_is_shape)
local copy_shape = assert(ch_smooth.copy_shape)
local get_or_add = assert(ch_smooth.get_or_add)
local load_nodes = assert(ch_smooth.load_nodes)
local material_to_shapes = assert(ch_smooth.material_to_shapes)
local shape_id = assert(ch_smooth.shape_id)
local visualize_shape = assert(ch_smooth.visualize_shape)

local empty_table = {}

local function quantize(y)
	if y < 0.0 then
		return -math.floor(-2 * y + 0.5) / 2
	else
		return math.floor(2 * y + 0.5) / 2
	end
end

local function consolide_nodes(node_1, key_1, node_2, key_2)
	local st1, st2 = node_1.shape_type, node_2.shape_type
	if st1 == "ignore" and st2 == "ignore" then
		return -- both nodes are 'ignore'
	end
	local by1, by2 = node_1.base_pos.y, node_2.base_pos.y
	if math.abs(by2 - by1) > 1 then
		return -- nodes are too distant to consolide
	end
	local y1, y2 = node_1[key_1], node_2[key_2]

	if st1 ~= "ignore" and st2 ~= "ignore" then
		-- both nodes can be shifted
		assert(tonumber(y1))
		assert(tonumber(y2))
		y1 = quantize((by1 + y1 + by2 + y2) / 2)
		node_1[key_1] = quantize(y1 - by1)
		node_2[key_2] = quantize(y1 - by2)
	elseif st1 ~= "ignore" then
		-- only node_1 can be changed
		node_1[key_1] = by2 + 1
	else
		-- only node_2 can be changed
		node_2[key_2] = by1 + 1
	end
end

local function elastic_computation(points)
	--[[ points = {
		[1] = weight,
		[2] = node,
		[3] = key,
	}]]
	local a, b = 0, 0
	for _, point in ipairs(points) do
		local weight, node, key = unpack(point)
		local y = node.base_pos.y
		if node.shape_type == "ignore" then
			y = y + 1
		else
			y = y + node[key]
		end
		a = a + weight * y
		b = b + weight
	end
	if b ~= 0 then
		return quantize(a / b)
	else
		return nil
	end
end

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
	-- print("find_shape() called: "..dump2({material = material, shape = shape, options = options}))
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
			--[[
			local na, nb, nc, nd
			local counts = {}
			local values = {a, b, c, d}
			for _, value in ipairs(values) do
				counts[value] = (counts[value] or 0) + 1
			end
			]]
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

local function get_shifted_shape(base_shape, shift)
	return {
		vxmzm = base_shape.vxmzm + shift,
		vxpzm = base_shape.vxpzm + shift,
		vxpzp = base_shape.vxpzp + shift,
		vxmzp = base_shape.vxmzp + shift,
	}
end

local function find_shape_with_shifts(material, shape, options, shifts)
	options = table.copy(options)
	options.exact_only = true
	local result = find_shape(material, shape, options)
	if result ~= nil then
		print("DEBUG: shape found with shift 0")
		return result
	end
	for _, shift in ipairs(shifts) do
		result = find_shape(material, get_shifted_shape(shape, assert(shift)), options)
		if result ~= nil then
			print("DEBUG: shape found with shift "..shift)
			return result
		end
	end
	return nil
end

--[[
	Pokud se zadané hodnoty A, B, C, D všechny neshodují, pokusí se najít "korekci" pro získání lepšího tvaru.
	Vrací:
	a) v případě úspěchu:
		true, newa, newb, newc, newd
	b) v případě selhání:
		false, a, b, c, d
]]
local function get_abcd_correction(a, b, c, d)
	--[[
		Cíl:
			1) seřadit hodnoty podle počtu výskytů (A)
			2) seřadit hodnoty podle velikosti (B)
			3) v (A) najít hodnotu, která se vyskytuje nejméně a z nich tu nejvyšší
			4) v (B) k ní najít sousední hodnoty a z nich vybrat tu, která se vyskytuje víc; vyskytují-li se stejně, pak vybrat tu menší;
				4*) pokud nemá sousední hodnotu, jsou všechny hodnoty stejné, a tedy jsme selhali.
			5) nahradit hodnotu nalezenou v kroku 3 hodnotou nahrazenou v kroku 4
	]]
	if a == b and b == c and c == d then
		return false, a, b, c, d -- nemohu pracovat, pokud se alespoň jedna hodnota neliší
	end
	local raw_values = {a, b, c, d}
	local new_values = table.copy(raw_values)
	local values = {}
	for i, rw in ipairs(raw_values) do
		if values[rw] == nil then
			values[rw] = {indices = {i}, value = rw}
		else
			table.insert(values[rw].indices, i)
		end
	end

	local values_by_count, values_by_value = {}
	for rw, value in pairs(values) do
		table.insert(values_by_count, value)
	end
	values_by_value = table.copy(values_by_count)
	table.sort(values_by_count, function(a, b) return #a.indices < #b.indices or (#a.indices == #b.indices and a.value > b.value) end)
	table.sort(values_by_value, function(a, b) return a.value < b.value end)
	local target_index = values_by_count[1].indices[1]
	local target_rw = values_by_count[1].value
	for i, value in ipairs(values_by_value) do
		if value.value == target_rw then
			local candidate_a, candidate_b = values_by_value[i - 1], values_by_value[i + 1]
			local source_rw
			if candidate_a ~= nil and candidate_b ~= nil then
				local candidates = {candidate_a, candidate_b}
				table.sort(candidates, function(a, b)
					if #a.indices > #b.indices then return true end
					if #a.indices < #b.indices then return false end
					return a.value < b.value
				end)
				source_rw = candidates[1].value
			elseif candidate_a == nil and candidate_b == nil then
				error("Unexpected error: no candidates for replacement!")
			else
				-- a single candidate
				source_rw = (candidate_a or candidate_b).value
			end
			new_values[target_index] = source_rw
			print("DEBUG: ABCD correction: ("..table.concat(raw_values, ",")..") => ("..table.concat(new_values, ",")..")")
			return true, unpack(new_values)
		end
	end
	error("Unexpected: value not found!")
end

--[[
	Pro zadané hodnoty spočítá a navrhne změny bloků. Vrací:
	{
		failures = int, -- počet bloků, k nimž nebyl u materiálu nalezen blok odpovídajícího tvaru
		node_changes = {[1..9] = {type, node, [node_above], [node_above2], shape} or nil}, -- výstupy funkce find_shape() pro jednotlivé bloky
	}
]]
local function compute_shape_proposals(newa, newb, newc, newd, nodes)
	local new_shapes = {}
	local main_base_y = assert(nodes[5].base_pos.y)
	local value_map_pairs = {
		{assert(newa), map_a},
		{newb, map_b},
		{newc, map_c},
		{newd, map_d}
	}
	for _, pair in ipairs(value_map_pairs) do
		local new_y, idx_map = pair[1], pair[2]
		if new_y ~= nil then
			for i = 1, 9 do
				local key = idx_map[i]
				if key ~= nil then
					local node = nodes[i]
					local current_shape = new_shapes[i] or node
					local new_shape = new_shapes[i]
					-- print("DEBUG dump = "..dump2({i = i, key = key, node = node}))
					if node.shape_type ~= "ignore" and node.base_pos.y + current_shape[key] ~= new_y then
						if new_shape == nil then
							new_shape = copy_shape(node)
							new_shapes[i] = new_shape
						end
						new_shape[key] = new_y - node.base_pos.y
					end
				end
			end
		end
	end

	-- Pokusit se najít konkrétní bloky podle navržených tvarů
	local node_changes = {}
	local shape_failures = 0
	for i = 1, 9 do
		local new_shape = new_shapes[i]
		if new_shape ~= nil then
			local new_nodes = find_shape(nodes[i].material, new_shape, {exact_only = true})
			if new_nodes == nil then
				shape_failures = shape_failures + 1
				new_nodes = find_shape(nodes[i].material, new_shape, {exact_only = false})
			end
			if new_nodes ~= nil then
				node_changes[i] = new_nodes
			end
		end
	end
	print("DEBUG: compute_shape_proposals("..newa..", "..newb..", "..newc..", "..newd..", nodes) => "..shape_failures.." failures")
	return {
		failures = shape_failures,
		node_changes = node_changes,
		newa = newa, newb = newb, newc = newc, newd = newd,
	}
end

local function find_best_proposal(newa, newb, newc, newd, nodes)
	local shifts = {0, -0.5, 0.5, -1, 1}
	local y_base = nodes[5].base_pos.y
	local proposal, best_proposal
	local corrections = 0
	local success

	while true do
		for i, shift in ipairs(shifts) do
			print("DEBUG: Will try to compute proposals with shift "..shift.."...")
			proposal = compute_shape_proposals(newa + shift, newb + shift, newc + shift, newd + shift, nodes)
			if best_proposal == nil or proposal.failures < best_proposal.failures then best_proposal = proposal end
			if best_proposal.failures == 0 then
				return best_proposal, 0
			end
		end
		success, newa, newb, newc, newd = get_abcd_correction(newa, newb, newc, newd)
		if not success then
			return best_proposal, proposal.failures
		end
		corrections = corrections + 1
		print(visualize_shape("ABCD["..corrections.."]", {vxmzm = newa - y_base, vxpzm = newb - y_base, vxmzp = newc - y_base, vxpzp = newd - y_base}))
	end
end

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
	if nodes[5].shape_type == "ignore" then
		print("central node is ignore!")
		return
	end
	print("DEBUG: vyhladit() will work at "..minetest.pos_to_string(pos))

	consolide_nodes(nodes[1], "vxpzm", nodes[2], "vxmzm")
	consolide_nodes(nodes[2], "vxpzm", nodes[3], "vxmzm")
	consolide_nodes(nodes[1], "vxmzp", nodes[4], "vxmzm")
	consolide_nodes(nodes[3], "vxpzp", nodes[6], "vxpzm")
	consolide_nodes(nodes[4], "vxmzp", nodes[7], "vxmzm")
	consolide_nodes(nodes[6], "vxpzp", nodes[9], "vxpzm")
	consolide_nodes(nodes[7], "vxpzp", nodes[8], "vxmzp")
	consolide_nodes(nodes[8], "vxpzp", nodes[9], "vxmzp")

	print("DEBUG: after consolidation = "..dump2(nodes))

	local y_base = nodes[5].base_pos.y
	local newa = elastic_computation({
		-- weight, node, key
		{4, nodes[1], "vxmzp"},
		{4, nodes[1], "vxpzm"},
		{2, nodes[1], "vxmzm"},
		{1, nodes[4], "vxmzp"},
		{1, nodes[2], "vxpzm"},
	})
	local newb = elastic_computation({
		{4, nodes[3], "vxmzm"},
		{4, nodes[3], "vxpzp"},
		{2, nodes[3], "vxpzm"},
		{1, nodes[2], "vxmzm"},
		{1, nodes[6], "vxpzp"},
	})
	local newc = elastic_computation({
		{4, nodes[7], "vxmzm"},
		{4, nodes[7], "vxpzp"},
		{2, nodes[7], "vxmzp"},
		{1, nodes[4], "vxmzm"},
		{1, nodes[8], "vxpzp"},
	})
	local newd = elastic_computation({
		{4, nodes[9], "vxmzp"},
		{4, nodes[9], "vxpzm"},
		{2, nodes[9], "vxpzp"},
		{1, nodes[8], "vxmzp"},
		{1, nodes[6], "vxpzm"},
	})

	print("DEBUG: [VYHLAZENI "..operation_id.."] new = {A = "..(newa or "nil")..", B = "..(newb or "nil")..", C = "..(newc or "nil")..", D = "..(newd or "nil").."}")
	if newa == nil or newb == nil or newc == nil or newd == nil then
		return
	end
	print(visualize_shape("ABCD", {vxmzm = newa - y_base, vxpzm = newb - y_base, vxmzp = newc - y_base, vxpzp = newd - y_base}))
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

	local best_proposal, shape_failures = find_best_proposal(newa, newb, newc, newd, nodes)
	if best_proposal == nil then
		minetest.log("warning", "[ch_smooth] failed with "..shape_failures.." shape failures.")
		return
	end
	for i = 1, 1 do
		print("DEBUG: ["..i.."] Will test proposal...")
		local proposal = best_proposal
		if true then
			-- použít tento návrh
			minetest.log("action", "[ch_smooth] proposal chosen with failures = "..best_proposal.failures..", result = "..dump2(proposal))
			for j = 1, 9 do
				local change = proposal.node_changes[j]
				if change ~= nil then
					local old_node = nodes[j]
					local base_pos = old_node.base_pos

					-- zpráva do logu:
					local message = "[ch_smooth] will change shape at "..minetest.pos_to_string(base_pos).." from "..shape_id(nodes[j]).." to "..
						shape_id(change.shape).." ("..old_node.old_name.."/"..old_node.old_param2.." => "..change.node.name.."/"..change.node.param2..")"
					if change.node_above ~= nil then
						local old_name, old_param2 = nm:get(vector.offset(base_pos, 0, 1, 0))
						message = message.." + above1("..(old_name or "nil").."/"..(old_param2 or "nil").." => "..
							change.node_above.name.."/"..change.node_above.param2..")"
					end
					if change.node_above2 ~= nil then
						local old_name, old_param2 = nm:get(vector.offset(base_pos, 0, 2, 0))
						message = message.." + above2("..(old_name or "nil").."/"..(old_param2 or "nil").." => "..
							change.node_above2.name.."/"..change.node_above2.param2..")"
					end
					minetest.log("action", message)

					-- aplikovat změnu
					nm:set(vector.copy(base_pos), change.node.name, change.node.param2)
					if change.node_above ~= nil then
						nm:set(vector.offset(base_pos, 0, 1, 0), change.node_above.name, change.node_above.param2)
					end
					if change.node_above2 ~= nil then
						nm:set(vector.offset(base_pos, 0, 2, 0), change.node_above2.name, change.node_above2.param2)
					end
	
				end
			end
			break
		end
	end
--[[
	local value_map_pairs = {
		{newa, map_a},
		{newb, map_b},
		{newc, map_c},
		{newd, map_d}
	}
	for _, pair in ipairs(value_map_pairs) do
		local new_y, idx_map = pair[1], pair[2]
		if new_y ~= nil then
			for i = 1, 9 do
				local key = idx_map[i]
				if key ~= nil then
					local node = nodes[i]
					-- print("DEBUG dump = "..dump2({i = i, key = key, node = node}))
					if node.shape_type ~= "ignore" and node.base_pos.y + node[key] ~= new_y then
						local old_value = node[key]
						node[key] = new_y - node.base_pos.y
						print("get_updated_nodes(): node "..i.." changed: "..key.." changed from "..old_value.." to "..node[key]..".")
						node.changed = true
					end
				end
			end
		end
	end
	]]

	-- local new_nodes = get_updated_nodes(nodes, {{newa, map_a}, {newb, map_b}, {newc, map_c}, {newd, map_d}})

	--[[ if new_nodes == nil then
		minetest.log("action", "vyhladit() failed completely")
		return -- failed completely
	end ]]

	--[[
	for i = 1, 9 do
		local node = nodes[i]
		if node.shape_type ~= "ignore" and node.changed then
			assert_is_shape(node)

			local nodes_to_set = {}
			local shift_up = false
			local old_vzorec = shape_id(node.old_shape)
			print("konsolidovat() B "..i.." 0")

			-- local new_shape = find_shape_with_shifts(node.material, node, {}, {-0.5, 0.5, -1, 1, -1.5, 1.5})
			local new_shape = find_shape_with_shifts(node.material, node, {}, {-1})
			if new_shape == nil then
				new_shape = find_shape(node.material, node)
			end

			if new_shape == nil then
				minetest.log("warning", "tvar "..shape_id(new_shape).."\" nenalezen u materiálu "..node.material)
			else
				-- print(visualize_shape(node.base_pos, new_shape))
				-- print("New shape found = "..dump2(new_shape))
				minetest.log("action", "[ch_smooth] will change shape at "..minetest.pos_to_string())

				minetest.log("action", "DEBUG: Will change shape of "..minetest.pos_to_string(node.base_pos).." from "..old_vzorec..
				" ("..node.old_name..", "..node.old_param2..") ".." to "..shape_id(new_shape.shape)..
				" ("..((nodes_to_set[0] or nodes_to_set[-1] or {}).name or "nil")..", "..
				((nodes_to_set[0] or nodes_to_set[-1] or {}).param2 or "nil")..")")


				nm:set(vector.copy(node.base_pos), new_shape.node.name, new_shape.node.param2)
				if new_shape.node_above ~= nil then
					nm:set(vector.offset(node.base_pos, 0, 1, 0), new_shape.node_above.name, new_shape.node_above.param2)
				end
				if new_shape.node_above2 ~= nil then
					nm:set(vector.offset(node.base_pos, 0, 2, 0), new_shape.node_above2.name, new_shape.node_above2.param2)
				end
				]]
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
			-- end
			-- print("vyhladit() B "..i.." 7")

			--[[ minetest.log("action", "DEBUG: Will change shape of "..minetest.pos_to_string(node.base_pos).." from "..old_vzorec..
				" ("..node.old_name..", "..node.old_param2..") ".." to "..shape_id(new_shape.shape)..
				" ("..((nodes_to_set[0] or nodes_to_set[-1] or {}).name or "nil")..", "..
				((nodes_to_set[0] or nodes_to_set[-1] or {}).param2 or "nil")..")") ]]
			--[[

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
			--[[
		end
	end
	]]

	nm:commit()

	print("[VYHLADIT "..operation_id.."]: smoothing finished at "..minetest.pos_to_string(pos).."\n\n")

	return {}
end

ch_smooth.vyhladit = vyhladit

