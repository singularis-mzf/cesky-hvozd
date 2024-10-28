local ch_smooth = ...
local assert_is_shape = assert(ch_smooth.assert_is_shape)
local nodename_to_material = assert(ch_smooth.nodename_to_material)
local rotate_map = assert(ch_smooth.rotate_map)
local rotate_shape = assert(ch_smooth.rotate_shape)
local shape_id = assert(ch_smooth.shape_id)

--
-- get_node_category(name) => air|ignore|water
--[[
	name -- Itemstring bloku. Zjistí, zda jde o vzduch (air nebo air-like), vodu (liquid) nebo něco jiného.
]]
-----------------------------------------------------------------------------
local function get_node_category(name)
	if name == nil then
		return "ignore"
	elseif name == "air" then
		return "air"
	else
		local ndef = minetest.registered_nodes[name]
		if ndef == nil then
			return "ignore" -- unknown node
		elseif ndef.liquidtype ~= nil and ndef.liquidtype ~= "none" then
			return "water"
		elseif ((ndef.groups or empty_table).attached_node or 0) > 0 then
			return "air"
		else
			return "ignore" -- other node
		end
	end
end

--[[
	Pokud na pozici "pos" je tvar nějakého materiálu, určí všechny podstatné parametry.
]]
local function search_for_base_node(nm, pos)
	-- => material, base_pos, name, param2, [name_above, param2_above, [name_above2, param2_above2]]
	-- => nil
	local name, param2, name_below, param2_below, name_below2, param2_below2
	local material, test, test2, default

	name, param2 = nm:get(pos)
	material = nodename_to_material[name]
	if material == nil then
		print("LADĚNÍ: "..name.." => unknown material")
		return nil
	end
	-- print("LADĚNÍ: materiál = "..dump2({material = material}))
	pos = vector.copy(pos)
	test, test2, default = material.test_below, material.test_below2, material.default
	if test == nil and test2 == nil then
		-- no tests => normal node (type "normal" or "bank")
		print("base node found at "..minetest.pos_to_string(pos)..": "..name.."/"..param2 --[[..", material = "..dump2(material)]])
		return material, pos, name, param2
	end
	pos.y = pos.y - 1
	name_below, param2_below = nm:get(pos)
	if test ~= nil and name_below ~= nil and test[name_below] ~= nil then
		-- it's a double shape
		print("base node (double) found at "..minetest.pos_to_string(pos)..": "..name_below.."/"..param2_below.."; above = "..name.."/"..param2--[[..", material = "..dump2(material)]])
		return test[name_below], pos, name_below, param2_below, name, param2
	end
	pos.y = pos.y - 1
	name_below2, param2_below2 = nm:get(pos)
	if test2 ~= nil and name_below2 ~= nil and test2[name_below2] ~= nil then
		print("base node (double bank) found at "..minetest.pos_to_string(pos)..": "..name_below2.."/"..param2_below2.."; above = "..name_below.."/"..param2_below.."; above2 = "..name.."/"..param2--[[..", material = "..dump2(material)]])
		-- it's a double bank shape
		return test2[name_below2], pos, name_below2, param2_below2, name_below, param2_below, name, param2
	end
	if default ~= nil then
		pos.y = pos.y + 2
		print("base node found (default match) at "..minetest.pos_to_string(pos)..": "..name.."/"..param2 --[[..", material = "..dump2(material)]])
		return default, pos, name, param2
	end
	print("no match found")
	return nil -- no match found
end



--[[
	Vychází z pozice "pos" a směrem +Y se pokusí najít nejbližší vzduch
	nebo vodu.
	Pokud uspěje, vrací: air_category, air_pos, air_node_name
		air_category -- "air" nebo "water", podle toho, zda se povrch nachází pod vzduchem nebo pod vodou.
		air_pos -- pozice nejbližšího vzduchu/vody
		air_node_name -- přesný itemstring bloku vzduchu/vody
	Pokud neuspěje, vrací: nil, nil, nil
]]
local function search_for_air(nm, pos)
	-- => air_category, air_pos, air_node_name or nil, nil, nil
	local air_category, node_name, y_limit
	pos = vector.copy(pos)
	for y = pos.y, pos.y + 4 do
		pos.y = y
		node_name = nm:get(pos)
		if node_name == nil then
			break
		end
		air_category = get_node_category(node_name)
		if air_category == "air" then
			print("air ("..node_name..") found at "..minetest.pos_to_string(pos))
			return "air", pos, "air"
		elseif air_category == "water" then
			local ndef = minetest.registered_nodes[node_name]
			local liquid_source = ndef and ndef.liquid_alternative_source
			if source == nil then
				source = "default:water_source"
			end
			print("liquid ("..source..") found at "..minetest.pos_to_string(pos))
			return "water", pos, source
		end
	end
	return nil, nil, nil
end


--
-- analyze_node(nm, pos) => {
--		base_pos, (= updated position of the base block)
--		shape_type,
--		material,
--		name, param2,
--		[name_above, param2_above], (for shape_types "double" and "double_bank")
--		[name_above2, param2_above2], (for shape_type "double_bank")
--		vx*z*,
--		air_node_name,
--		} or nil
-----------------------------------------------------------------------------
local function analyze_node(nm, pos)
	-- search for air/surface:
	local orig_pos = pos
	local air_name, air_category, surface_name, surface_category

	pos = vector.copy(pos)
	air_name = nm:get(pos)
	if air_name == nil then return nil end
	air_category = get_node_category(air_name)
	if air_category == "air" or air_category == "water" then
		-- => -Y (search for surface)
		for i = 1, 4 do
			pos.y = pos.y - 1
			surface_name = nm:get(pos)
			if surface_name == nil then return nil end
			surface_category = get_node_category(surface_name)
			if surface_category == "air" or surface_category == "water" then
				-- surface not found, try again..
				air_name, air_category = surface_name, surface_category
				surface_name = nil
			else
				-- print("DEBUG: surface found (i == "..i..") at"..minetest.pos_to_string(pos))
				-- surface found!
				break
			end
		end
		if surface_name == nil then
			return nil
		end
	else
		-- => +Y (search for air)
		surface_name, surface_category = air_name, air_category
		for i = 1, 4 do
			pos.y = pos.y + 1
			air_name = nm:get(pos)
			if air_name == nil then return nil end
			air_category = get_node_category(air_name)
			if air_category ~= "air" and air_category ~= "water" then
				-- air/water not found, try again...
				surface_category, surface_name = air_category, air_name
				air_name = nil
			else
				pos.y = pos.y - 1
				-- print("DEBUG: surface found (i == "..i..") at"..minetest.pos_to_string(pos))
				break -- surface found!
			end
		end
	end
	-- pos je nyní pozice bloku povrchu pod vzduchem/vodou
	if air_category == "air" then
		air_name = "air"
	elseif air_category == "water" then
		local ndef = minetest.registered_nodes[air_name]
		air_name = (ndef and ndef.liquid_alternative_source) or "default:water_source"
	end
	print("DEBUG: analyze_node("..minetest.pos_to_string(orig_pos)..") => surface found at "..minetest.pos_to_string(pos).." ("..surface_name..") under ("..air_name..").")

	local material, base_pos, name, param2, name_above, param2_above, name_above2, param2_above2 =
		search_for_base_node(nm, pos)
	if material == nil then
		print("DEBUG: analyze_node(): unknown or unsupported material "..surface_name)
		return nil -- unknown or unsupported material
	end
	if rotate_map[param2] == nil then
		param2 = 0
	end
	local result_shape = rotate_shape(material.shape, param2)
	assert_is_shape(result_shape)

	local result = {
		base_pos = assert(base_pos),
		shape_type = material.shape.type,
		material = material.item,
		old_name = name,
		old_param2 = param2,
		vxmzm = result_shape.vxmzm,
		vxmzp = result_shape.vxmzp,
		vxpzp = result_shape.vxpzp,
		vxpzm = result_shape.vxpzm,
		old_shape = result_shape,
		air_node_name = assert(air_name),
	}
	if name_above ~= nil then
		result.name_above = name_above
		result.param2_above = assert(param2_above)
	end
	if name_above2 ~= nil then
		result.name_above2 = name_above2
		result.param2_above2 = assert(param2_above2)
	end
	local message = "[analyze_node]"..minetest.pos_to_string(orig_pos).." => "..minetest.pos_to_string(base_pos)..": "..
		name.."/"..param2.." => "..material.item.." "..shape_id(result) --[[.."; dump = "..dump2(result)]]
	print(message)
	-- minetest.log("action", message)
	return result
end

--
-- load_nodes(pos) => {
--		[1..9] = {
--			shape_type, -- typ tvaru (normal|double|...) nebo "ignore"
-- 			base_pos,
--			old_name,
--			old_param2,
--			for shape_type ~= "ignore":
--				material,
--				vx*z*,
--				old_shape,
--				[ old_name_above, old_param2_above ],
--				[ old_name_above2, old_param2_above2 ],
--				air_node_name,
--	}} or nil if the central node ([5]) is not of a known material
-------------------------------------------------------------------------------
local function load_nodes(nm, pos)
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
	-- nodes[5]
	local node_analysis = analyze_node(nm, pos)
	if node_analysis == nil then
		print("DEBUG: node at "..minetest.pos_to_string(pos).." ("..minetest.get_node(pos).name..") is not smoothable")
		return nil -- the central node is not a normal (smoothable) node
	end

	local nodes = {1, 2, 3, 4, 5, 6, 7, 8, 9}

	nodes[5] = node_analysis
	local y_base = nodes[5].base_pos.y
	--[[
	nodes[5] = {
		type = node_analysis.shape_type,
		base_pos = node_analysis.base_pos,
		old_name = node_analysis.name,
		old_param2 = node_analysis.param2,
		old_shape = node_analysis,
		air_node_name = node_analysis.air_node_name,
		vxmzm = node_analysis.vxmzm,
		vxpzm = node_analysis.vxpzm,
		vxpzp = node_analysis.vxpzp,
		vxmzp = node_analysis.vxmzp,
		material = node_analysis.material, -- only node name
	}
	]]
	-- minetest.log("action", "[vyhl] Node at "..minetest.pos_to_string(lpos).." ("..node.name..", "..node.param2..") read as "..nodes[5].material.." of shape "..shape_id(nodes[5])..", above_category = "..(above_category or "nil"))

	local i = 1
	for z = pos.z - 1, pos.z + 1 do
		for x = pos.x - 1, pos.x + 1 do
			if i ~= 5 then
				local lpos = vector.new(x, y_base, z)
				node_analysis = analyze_node(nm, lpos)
				if node_analysis == nil then
					local name, param2 = nm:get(lpos)
					node_analysis = {
						shape_type = "ignore",
						base_pos = lpos,
						old_name = name,
						old_param2 = param2,
					}
				end
				nodes[i] = node_analysis
			end
			i = i + 1
		end
	end

	-- Visualize results:
	print("load_nodes("..minetest.pos_to_string(pos)..") => "..dump2(nodes))

	return nodes
end

ch_smooth.load_nodes = load_nodes
