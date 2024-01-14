ch_core.open_submod("areas", {lib = true})

ch_core.areas = {}

local world_path = minetest.get_worldpath()
local ch_areas_file_path = world_path.."/ch_areas.json"
local store = AreaStore()
local area_id_to_store_id = {}
local store_id_to_area_id = {}

function ch_core.add_area(pos1, pos2, area_name, area_type)
	local areas = ch_core.areas

	if area_type == 0 then
		minetest.log("ch_core.add_area(): cannot add a removed area!")
		return false
	end

	local area_id
	for i = 1, #areas do
		if areas[i].type == 0 then
			area_id = i
			break
		end
	end
	if not area_id then
		area_id = #areas + 1
	end

	local def = {
		id = area_id,
		name = area_name or "",
		type = area_type or 1,
		min = vector.new(math.min(pos1.x, pos2.x), math.min(pos1.y, pos2.y), math.min(pos1.z, pos2.z)),
		max = vector.new(math.max(pos1.x, pos2.x), math.max(pos1.y, pos2.y), math.max(pos1.z, pos2.z)),
	}
	ch_core.areas[area_id] = def
	local store_id = store:insert_area(def.min, def.max, area_id)
	if store_id then
		area_id_to_store_id[area_id] = store_id
		store_id_to_area_id[store_id] = area_id
	else
		minetest.log("warning", "The inserting of area ID "..area_id.." to AreaStore failed!")
	end
	ch_core.save_areas()
	return area_id
end

function ch_core.get_areas_at_pos(pos)
	local areas = store:get_areas_for_pos(pos, false, false)
	local result = {}
	for store_id, _ in pairs(areas) do
		table.insert(result, ch_core.areas[store_id_to_area_id[store_id]])
	end
	return result
end

function ch_core.remove_area(id)
	local areas = ch_core.areas
	local area = areas[id]
	if not area or area.type == 0 then
		return false
	end
	store:remove_area(area_id_to_store_id[area.id])
	area.type = 0
	while #areas > 0 and areas[#areas].type == 0 do
		print("DEBUG: removed area #"..#areas.." cleared")
		areas[#areas] = nil
	end
	return ch_core.save_areas()
end

function ch_core.save_areas()
	local data = minetest.write_json(ch_core.areas)
	if not data then
		minetest.log("error", "ch_core.save_areas(): failed to serialize data!")
		return false
	end
	if not minetest.safe_file_write(ch_areas_file_path, data) then
		minetest.log("error", "ch_core.save_areas(): failed to save data!")
		return false
	end
	return true
end

function ch_core.areas_hud_handler(pos, list)
	local areas_to_add = store:get_areas_for_pos(pos, false, true)
	for --[[ store_id ]] _, store_data in pairs(areas_to_add) do
		local area = ch_core.areas[tonumber(store_data.data)]
		if area and area.type ~= 0 then
			table.insert(list, {name = area.name, id = -area.id})
		end
	end
end

-- Deserialize data
local f, err = io.open(ch_areas_file_path, "r")
if f then
	local s, d
	s = f:read("*a")
	if s then
		d, err = minetest.parse_json(s)
	end
	io.close(f)
	if not d then
		minetest.log("warning", "CH areas file cannot be loaded: "..(err or "nil"))
	else
		ch_core.areas = d
		for area_id, area_def in ipairs(d) do
			if area_def.type ~= 0 then
				local store_id = store:insert_area(area_def.min, area_def.max, area_id)
				if store_id then
					minetest.log("warning", "DEBUG: area ID "..area_id.." stored to the AreaStore with store_id = "..store_id.." and min = "..minetest.pos_to_string(area_def.min)..", max = "..minetest.pos_to_string(area_def.max))
					area_id_to_store_id[area_id] = store_id
				else
					minetest.log("warning", "The inserting of area ID "..area_id.." to AreaStore failed!")
				end
			end
		end
	end
else
	minetest.log("warning", "CH areas file cannot be openned: "..(err or "nil"))
end

ch_core.close_submod("areas")
