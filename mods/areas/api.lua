local hudHandlers = {
	ch_core.areas_hud_handler
}

areas.registered_on_adds = {}
areas.registered_on_removes = {}
areas.registered_on_moves = {}

function areas:registerOnAdd(func)
	table.insert(areas.registered_on_adds, func)
end

function areas:registerOnRemove(func)
	table.insert(areas.registered_on_removes, func)
end

function areas:registerOnMove(func)
	table.insert(areas.registered_on_moves, func)
end

--- Adds a function as a HUD handler, it will be able to add items to the Areas HUD element.
function areas:registerHudHandler(handler)
	table.insert(hudHandlers, handler)
end

function areas:getExternalHudEntries(pos)
	local areas = {}
	for _, func in pairs(hudHandlers) do
		func(pos, areas)
	end
	return areas
end

-- Compares the priority of areas and returns number > 0 if a has greater
-- priority, 0 if a has the same priority and < 1 if a has lesser priority than b.
-- Accepts are objects or nil as parameters. (nil is considered to have
-- a lesser priority than areas.)
-- Parameters a_id and b_id are optional.
local function areas_priority_cmp(a, b, a_id, b_id)
	-- 0. nil => lower priority
	if not a then
		if not b then
			return 0
		else
			return -1
		end
	end
	if not b then
		return 1
	end

	-- 1. greater z-index => higher priority
	if a.zindex < b.zindex then return -1 end
	if a.zindex > b.zindex then return 1 end

	-- 2. smaller area => higher priority
	local a_size = ch_core.objem_oblasti(a.pos1, a.pos2)
	local b_size = ch_core.objem_oblasti(b.pos1, b.pos2)
	if a_size > b_size then return -1 end
	if a_size < b_size then return 1 end

	-- 3. smaller ID => higher priority
	if a_id and b_id then
		if a_id > b_id then return -1 end
		if a_id < b_id then return 1 end
	end
	return 0
end

--- Returns a list of areas that include the provided position.
function areas:getAreasAtPos(pos)
	local res = {}

	if self.store then
		local a = self.store:get_areas_for_pos(pos, false, true)
		for store_id, store_area in pairs(a) do
			local id = tonumber(store_area.data)
			res[id] = self.areas[id]
		end
	else
		local px, py, pz = pos.x, pos.y, pos.z
		for id, area in pairs(self.areas) do
			local ap1, ap2 = area.pos1, area.pos2
			if
					(px >= ap1.x and px <= ap2.x) and
					(py >= ap1.y and py <= ap2.y) and
					(pz >= ap1.z and pz <= ap2.z) then
				res[id] = area
			end
		end
	end
	return res
end

-- Returns a list of ids of areas that include the provided position,
-- ordered from the highest priority to the lowest.
function areas:getAreaIdsAtPosByPriority(pos)
	local source = self:getAreasAtPos(pos)
	local res = {}

	for area_id, _ in pairs(source) do
		table.insert(res, area_id)
	end
	if #res > 1 then
		table.sort(res, function(a, b)
			if not source[a] or not source[b] then
				error("Internal error: invalid id found in areas:getAreaIdsAtPosByPriority!")
			end
			return areas_priority_cmp(source[a], source[b], a, b) > 0
		end)
	end
	return res
end

-- Returns id and definition of the area with the highest priority,
-- on nil, if the position is unprotected.
function areas:getMainAreaAtPos(pos)
	local main_area_id, main_area
	local count = 0
	for area_id, area in pairs(self:getAreasAtPos(pos)) do
		count = count + 1
		if areas_priority_cmp(main_area, area, main_area_id, area_id) < 0 then
			main_area_id = area_id
			main_area = area
		end
	end
	return main_area_id, main_area
end

--- Returns areas that intersect with the passed area.
function areas:getAreasIntersectingArea(pos1, pos2)
	local res = {}
	if self.store then
		local a = self.store:get_areas_in_area(pos1, pos2,
				true, false, true)
		for store_id, store_area in pairs(a) do
			local id = tonumber(store_area.data)
			res[id] = self.areas[id]
		end
	else
		self:sortPos(pos1, pos2)
		local p1x, p1y, p1z = pos1.x, pos1.y, pos1.z
		local p2x, p2y, p2z = pos2.x, pos2.y, pos2.z
		for id, area in pairs(self.areas) do
			local ap1, ap2 = area.pos1, area.pos2
			if
					(ap1.x <= p2x and ap2.x >= p1x) and
					(ap1.y <= p2y and ap2.y >= p1y) and
					(ap1.z <= p2z and ap2.z >= p1z) then
				-- Found an intersecting area.
				res[id] = area
			end
		end
	end
	return res
end

-- Checks if the node at the position is accessible by player named 'name'
function areas:canInteract(pos, name, reason, quiet)
	if minetest.check_player_privs(name, "protection_bypass") then
		return true
	end

	local main_area_id, main_area = self:getMainAreaAtPos(pos)
	-- minetest.log("warning", "DEBUG: canInteract(): main area: "..(main_area_id or "nil"))
	return not main_area_id or self:canInteractInAreaById(name, main_area_id, reason, quiet)
end

-- pos: only informative and optional, has no effect on the result
function areas:canInteractInAreaById(name, area_id, reason, quiet, pos)
	if minetest.check_player_privs(name, "protection_bypass") then
		return true
	end
	local main_area = self.areas[area_id]
	if not main_area then
		return true -- unprotected (area not found)
	end
	if main_area.type == 1 then
		-- 1 normal -- ch_registered_player priv or ownership is required to build
		return main_area.owner == name or minetest.check_player_privs(name, "ch_registered_player")

	elseif main_area.type == 2 then
		-- 2 open -- no priv is required to build
		return true

	elseif main_area.type == 3 then
		-- 3 private -- ch_registered_player priv or ownership is required to build
					-- but the owner should be noticed when someone else builds or enters there
					-- also the interacting player should be warned
		if main_area.owner == name then
			return true
		elseif minetest.check_player_privs(name, "ch_registered_player") then
			-- TODO: announce if not quiet
			return true
		else
			return false
		end

	elseif main_area.type == 4 then
		-- 4 locked -- ch_trustful_player priv or ownership is required to build
		return main_area.owner == name or minetest.check_player_privs(name, "ch_trustful_player")

	elseif main_area.type == 5 then
		-- 5 guarded -- only owner could build there
		return main_area.owner == name

	elseif main_area.type == 6 then
		-- 6 shared -- not implemented yet
		return true

	else
		if not quiet then
			minetest.log("warning", "areas:canInteractInAreaById found unknown type of area: "..(main_area.type or "nil"))
		end
		return true -- area of an unknown type
	end
end


-- Returns a table (list) of all players that own an area
function areas:getNodeOwners(pos)
	local owners = {}
	for _, area in pairs(self:getAreasAtPos(pos)) do
		table.insert(owners, area.owner)
	end
	return owners
end

--- Checks if the area intersects with an area that the player can't interact in.
-- Note that this fails and returns false when the specified area is fully
-- owned by the player, but with multiple protection zones, none of which
-- cover the entire checked area.
-- @param name (optional) Player name. If not specified checks for any intersecting areas.
-- @param allow_open Whether open areas should be counted as if they didn't exist. [ignored in this implementation]
-- @return Boolean indicating whether the player can interact in that area.
-- @return Inaccessible intersecting area ID, if found.
function areas:canInteractInArea(pos1, pos2, name, allow_open, reason, quiet)
	minetest.log("warning", "DEBUG: canInteractInArea() called")
	if name and minetest.check_player_privs(name, "protection_bypass") then
		return true
	end
	self:sortPos(pos1, pos2)

	local areas = self:getAreasIntersectingArea(pos1, pos2)
	local areas_by_priority = {}

	local blocking_area = nil
	local result = true

	for id, _ in pairs(areas) do
		table.insert(areas_by_priority, id)
	end
	table.sort(areas_by_priority, function(a, b) return areas_priority_cmp(areas[a], areas[b]) > 0 end)

	for i, area_id in ipairs(areas_by_priority) do
		local area = areas[area_id]
		local area_pos1, area_pos2 = area.pos1, area.pos2
		self:sortPos(area_pos1, area_pos2)
		local is_subarea = false
		for j = i + 1, #areas_by_priority, 1 do
			if areas:isSubarea(area_pos1, area_pos2, areas_by_priority[j]) then
				is_subarea = true
				break
			end
		end
		if not is_subarea then
			local can_interact = self:canInteractInAreaById(name, area_id, reason, quiet)
			if not can_interact then
				blocking_area = area_id
				result = false
				break
			end
		end
	end

	--[[ minetest.log("action", "DEBUG: canInteractInArea("..minetest.pos_to_string(pos1)..", "..minetest.pos_to_string(pos2)..", "..name..", reason = "..(reason or "nil")..", quiet = "..(quiet and "true" or "false")..") => "..(result and "true" or "false")..", "..(blocking_area or "nil")) ]]

	return result, blocking_area
end
