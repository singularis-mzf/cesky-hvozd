-- LANDSPACE GENERATION

-- použití:
--		//luatransform ch_core.generate_landscape(pos, "typ", poloměr)

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

local rocks_shapes = {
	glove = {max_param2 = 23},
	flat = {max_param2 = 19},
	round = {max_param2 = 23},
	large_flat = {max_param2 = 23, probability = 20},
	spike = {max_param2 = 3},
	pillar_45 = {max_param2 = 3},
	pillar_90 = {max_param2 = 3},
	stub = {max_param2 = 3},
}

local rocks_materials = {
	stone = {"default:dirt", "default:dirt_with_grass", "default:dirt_with_dry_grass", "default:dirt_with_snow"},
	desert_stone = {"default:desert_stone", "default:desert_cobble"},
	sand = {"default:sand", "default:sandstone"},
	desert_sand = {"default:desert_sand", "default:desert_sandstone"},
	silver_sand = {"default:silver_sand", "default:silver_sandstone"},
}

local rocks_shapes_list = {}
local rocks_node_to_material = {}
for shape, _ in pairs(rocks_shapes) do
	table.insert(rocks_shapes_list, shape)
end
for material, list in pairs(rocks_materials) do
	for _, name in ipairs(list) do
		rocks_node_to_material[name] = material
	end
end

local bulk_set_node = minetest.bulk_set_node
local get_item_group = minetest.get_item_group
local get_node = minetest.get_node
local set_node = minetest.set_node

function ch_core.generate_landscape(pos, typ, polomer)
	local node_air = {name = "air"}
	if typ == "skála" then
		for x = pos.x - polomer, pos.x + polomer do
			for z = pos.z - polomer, pos.z + polomer do
				for y = pos.y + polomer, pos.y - polomer, -1 do
					local new_pos = vector.new(x, y, z)
					if vector.distance(new_pos, pos) < polomer then
						local node = get_node(new_pos)
						local air_kind_value =  air_kind(node.name)
						if air_kind_value > 1 or (air_kind_value == 0 and get_item_group(node.name, "crumbly") ~= 0) then
							set_node(new_pos, node_air)
						elseif air_kind_value ~= 1 then
							break
						end
					end
				end
			end
		end
	elseif typ == "krtince" then
		local molehill_node = {name = "molehills:molehill"}
		for x = pos.x - polomer, pos.x + polomer do
			for z = pos.z - polomer, pos.z + polomer do
				for y = pos.y + polomer, pos.y - polomer, -1 do
					local new_pos = vector.new(x, y, z)
					if vector.distance(new_pos, pos) < polomer then
						local node = get_node(new_pos)
						local air_kind_value =  air_kind(node.name)
						if air_kind_value > 1 then
							if get_item_group(get_node(vector.offset(new_pos, 0, -1, 0)).name, "soil") ~= 0 and math.random(1, 2) == 2 then
								set_node(new_pos, molehill_node)
							end
							break
						end
					end
				end
			end
		end
	elseif typ == "keře" then
		local sapling_node = {name = "default:bush_sapling"}
		for x = pos.x - polomer, pos.x + polomer do
			for z = pos.z - polomer, pos.z + polomer do
				for y = pos.y + polomer, pos.y - polomer, -1 do
					local new_pos = vector.new(x, y, z)
					if vector.distance(new_pos, pos) < polomer then
						local node = get_node(new_pos)
						local air_kind_value =  air_kind(node.name)
						if air_kind_value > 1 then
							if
								get_item_group(get_node(vector.offset(new_pos, 0, -1, 0)).name, "soil") ~= 0
								and minetest.find_node_near(new_pos, 3, {"default:bush_sapling"}) == nil
								and math.random(1, 2) == 2
							then
								set_node(new_pos, sapling_node)
								minetest.get_node_timer(new_pos):start(3)
							end
							break
						end
					end
				end
			end
		end
	elseif typ == "balvany" then
		for x = pos.x - polomer, pos.x + polomer do
			for z = pos.z - polomer, pos.z + polomer do
				for y = pos.y + polomer, pos.y - polomer, -1 do
					local new_pos = vector.new(x, y, z)
					if vector.distance(new_pos, pos) < polomer then
						local node = get_node(new_pos)
						local air_kind_value = air_kind(node.name)
						if air_kind_value == 0 then
							new_pos.y = y + 1
						else
							node = get_node(vector.offset(new_pos, 0, -1, 0))
						end
						if air_kind_value ~= 1 then
							local material = rocks_node_to_material[node.name]
							local shape_index = math.random(1, #rocks_shapes_list)
							local probability = rocks_shapes[rocks_shapes_list[shape_index]].probability

							while probability ~= nil and math.random(1, 100) > probability do
								shape_index = math.random(1, #rocks_shapes_list)
								probability = rocks_shapes[rocks_shapes_list[shape_index]].probability
							end

							if material and math.floor(math.random(1, 16)) == 3 then
								local shape = rocks_shapes_list[shape_index]
								local shape_def = rocks_shapes[shape]
								set_node(new_pos, {
									name = "rocks:"..material.."_"..shape,
									param2 = math.random(0, shape_def.max_param2 or 23),
								})
							end
							break
						end
					end
				end
			end
		end
	else
		minetest.chat_send_all("CHYBA: neznámý typ krajiny '"..typ.."'!")
	end
	--[[
	
	
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
	return true ]]
end
