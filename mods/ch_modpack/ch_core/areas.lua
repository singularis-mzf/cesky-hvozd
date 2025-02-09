ch_core.open_submod("areas", {data = true, lib = true})

local world_path = minetest.get_worldpath()
local ch_areas_file_path = world_path.."/ch_areas_v2.json"

local after_player_area_change = {}
local after_player_areas_change = {}

local function load_ch_areas()
	local data
	local f, err = io.open(ch_areas_file_path, "r")
	if not f then
		minetest.log("warning", "CH areas file cannot be openned: "..(err or "nil"))
		return {}
	end
	local s = f:read("*a")
	if s then
		data, err = minetest.parse_json(s)
	end
	io.close(f)
	if not data then
		minetest.log("warning", "CH areas file cannot be loaded: "..(err or "nil"))
		return {}
	end
	local list = {}
	for k, _ in pairs(data) do
		table.insert(list, k)
	end
	table.sort(list)
	minetest.log("warning", "CH areas loaded: "..table.concat(list, ", ")) -- [ ] DEBUG...
	return data
end

ch_core.areas = load_ch_areas()

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

--[[
	POZNÁMKA: Tyto dva callbacky budou volány s parametry (player_name, old_areas, new_areas),
	kde old_areas může být nil.
]]

function ch_core.register_on_player_change_area(callback)
	table.insert(after_player_area_change, callback)
end

function ch_core.register_on_player_change_areas(callback)
	table.insert(after_player_areas_change, callback)
end

function ch_core.set_player_areas(player_name, player_areas)
	assert(player_name)
	assert(player_areas)
	assert(type(player_areas) == "table")
	local online_charinfo = ch_data.online_charinfo[player_name]
	if online_charinfo == nil then
		return
	end
	if #player_areas == 0 then
		player_areas[1] = {
			id = 0,
			name = "Český hvozd",
			type = 1, -- normal
			-- def = nil
		}
	end
	local old_player_areas = assert(online_charinfo.areas)
	online_charinfo.areas = player_areas
	local changes = 0
	if #old_player_areas == player_areas then
		for i = 1, #old_player_areas do
			if old_player_areas[i].id ~= player_areas[i].id then
				changes = changes + 1
			end
		end
		if changes == 0 then
			-- no changes
			return
		end
	end
	-- callbacks
	if old_player_areas[1].id ~= player_areas[1].id then
		for _, f in ipairs(after_player_area_change) do
			f(player_name, old_player_areas, player_areas)
		end
	end
	for _, f in ipairs(after_player_areas_change) do
		f(player_name, old_player_areas, player_areas)
	end
end

ch_core.close_submod("areas")
