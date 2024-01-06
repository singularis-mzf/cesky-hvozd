local player_to_area = {}
local known_areas = {}
local known_areas_count = 0

local worldpath = minetest.get_worldpath()

local block_side = 256

local function xyz_to_area_id(x, y, z)
	return math.floor(x / block_side)..","..math.floor(y / block_side)..","..math.floor(z / block_side)
end

local function pos_to_area_id(pos)
	return math.floor(pos.x / block_side)..","..math.floor(pos.y / block_side)..","..math.floor(pos.z / block_side)
end

local function pos_to_area_aabb(pos)
	local x_min, y_min, z_min = math.floor(pos.x / block_side), math.floor(pos.y / block_side), math.floor(pos.z / block_side)
	return {x_min, y_min, z_min, x_min + block_side - 1, y_min + block_side - 1, z_min + block_side - 1}
end

local function xyz_to_area_aabb(x, y, z)
	local x_min, y_min, z_min = math.floor(x / block_side), math.floor(y / block_side), math.floor(z / block_side)
	return {x_min, y_min, z_min, x_min + block_side - 1, y_min + block_side - 1, z_min + block_side - 1}
end

local function process_player(player_name, x, y, z)
	local previous_area = player_to_area[player_name] -- previous area of the player or nil
	if previous_area ~= nil then
		local aabb = previous_area.aabb
		if aabb[1] <= x and aabb[2] <= y and aabb[3] <= z and x <= aabb[4] and y <= aabb[5] and z <= aabb[6] then
			return -- no change
		end
	end
	local area_id = xyz_to_area_id(x, y, z)
	local new_area = known_areas[area_id]
	if new_area ~= nil then
		-- cache hit
		player_to_area[player_name] = new_area
		return
	end
	-- create a new area:
	new_area = {
		aabb = xyz_to_area_aabb(x, y, z),
		id = area_id,
	}
	player_to_area[player_name] = new_area
	local filename = worldpath.."/test_area_storages/"..new_area.aabb[3]
	minetest.mkdir(filename)
	filename = filename.."/"..area_id..".dat"
	minetest.safe_file_write(filename, "TEST: "..area_id)
	known_areas[area_id] = new_area
	known_areas_count = known_areas_count + 1
	minetest.log("action", "[ch_test] count of known areas increased to "..known_areas_count.." by adding "..area_id)
end

local function on_globalstep(dtime)
	for player_name, player in pairs(minetest.get_connected_players()) do
		local player_pos = vector.round(player:get_pos())
		process_player(player_name, player_pos.x, player_pos.y, player_pos.z)
	end
end

minetest.register_globalstep(on_globalstep)
