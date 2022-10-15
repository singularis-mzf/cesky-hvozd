local S = minetest.get_translator("areas")

-- returns areaId (nil if input is not valid), areaObject (nil if not exists)
local function parseAreaId(areaId)
	if not areaId then
		return
	end
	areaId = tonumber(areaId)
	if areaId == nil or math.floor(areaId) ~= areaId or areaId < 1 then
		return
	end
	return areaId, areas.areas[areaId]
end

minetest.register_chatcommand("protect", {
	params = S("<AreaName>"),
	description = S("Protect an area"),
	privs = areas.adminPrivs,
	func = function(name, param)
		if param == "" then
			return false, S("Invalid usage, see /help @1.", "protect")
		end
		local pos1, pos2 = areas:getPos(name)
		if not (pos1 and pos2) then
			return false, S("You need to select an area first.")
		end

		minetest.log("action", "/protect invoked, owner="..name..
				" AreaName="..param..
				" StartPos="..minetest.pos_to_string(pos1)..
				" EndPos="  ..minetest.pos_to_string(pos2))

		local canAdd, errMsg = areas:canPlayerAddArea(pos1, pos2, name)
		if not canAdd then
			return false, S("You can't protect that area: @1", errMsg)
		end

		local id = areas:add("Administrace", param, pos1, pos2, nil)
		areas:save()

		return true, S("Area protected. ID: @1", id)
	end
})

minetest.register_chatcommand("area_set_owner", {
	params = S("<AreaId>").." "..S("<NewOwner>"),
	description = S("Changes the owner of an existing area"),
	privs = areas.adminPrivs,
	func = function(name, param)
		local areaIdRaw, newOwner = param:match('^(%S+)%s(%S+)$')

		if not areaIdRaw then
			return false, S("Invalid usage, see /help @1.", "set_owner")
		end

		local areaId, area = parseAreaId(areaIdRaw)
		if not area then
			return false, S("Area does not exist.")
		end

		if not areas:player_exists(newOwner) then
			return false, S("The player \"@1\" does not exist.", newOwner)
		end

		minetest.log("action", name.." runs /area_set_owner. ID = "..areaId.." Owner: "..area.owner.." => "..newOwner)

		area.owner = newOwner
		areas:save()

		return true, S("Owner changed.")
	end
})

minetest.register_chatcommand("area_set_name", {
	params = S("<AreaId>").." "..S("<NewName>"),
	description = S("Changes the name of an existing area"),
	privs = areas.adminPrivs,
	func = function(name, param)
		local areaIdRaw, newName = param:match('^(%S+)%s(.+)$')

		if not areaIdRaw then
			return false, S("Invalid usage, see /help @1.", "set_owner")
		end

		local areaId, area = parseAreaId(areaIdRaw)
		if not area then
			return false, S("Area does not exist.")
		end

		minetest.log("action", name.." runs /area_set_name. ID = "..areaId.." Name: "..area.name.." => "..newName)

		area.name = newName
		areas:save()

		return true, S("Name changed.")
	end
})


minetest.register_chatcommand("area_set_type", {
	params = S("<AreaId>").." "..S("<NewType>"),
	description = S("Changes the type of an existing area"),
	privs = areas.adminPrivs,
	func = function(name, param)
		local areaIdRaw, newType = param:match('^(%S+)%s(%S+)$')

		if not areaIdRaw then
			return false, S("Invalid usage, see /help @1.", "set_owner")
		end

		local areaId, area = parseAreaId(areaIdRaw)
		if not area then
			return false, S("Area does not exist.")
		end

		if not areas.area_types_name_to_number[newType] then
			return false, S("Invalid area type!")
		end

		minetest.log("action", name.." runs /area_set_type. ID = "..areaId.." Type: "..(area.type or "nil").." => "..areas.area_types_name_to_number[newType])

		area.type = areas.area_types_name_to_number[newType]
		areas:save()

		return true, S("Type changed.")
	end
})

minetest.register_chatcommand("area_set_zindex", {
	params = S("<AreaId>").." "..S("<ZIndex>"),
	description = S("Changes the z-index of an existing area"),
	privs = areas.adminPrivs,
	func = function(name, param)
		local areaIdRaw, newz = param:match('^(%S+)%s(%S+)$')

		if not areaIdRaw then
			return false, S("Invalid usage, see /help @1.", "set_owner")
		end

		local areaId, area = parseAreaId(areaIdRaw)
		if not area then
			return false, S("Area does not exist.")
		end

		newz = tonumber(newz)
		if not newz or newz ~= math.floor(newz) then
			return false, S("Invalid z-index!")
		end

		minetest.log("action", name.." runs /area_set_zindex. ID = "..areaId.." Z-index: "..area.zindex.." => "..newz)

		area.zindex = newz
		areas:save()

		return true, S("Z-index changed.")
	end
})




minetest.register_chatcommand("find_areas", {
	params = "<regexp>",
	description = S("Find areas using a Lua regular expression"),
	privs = areas.adminPrivs,
	func = function(name, param)
		if param == "" then
			return false, S("A regular expression is required.")
		end

		-- Check expression for validity
		local function testRegExp()
			("Test [1]: Player (0,0,0) (0,0,0)"):find(param)
		end
		if not pcall(testRegExp) then
			return false, S("Invalid regular expression.")
		end

		local matches = {}
		for id, area in pairs(areas.areas) do
			local str = areas:toString(id)
			if str:find(param) then
				table.insert(matches, str)
			end
		end
		if #matches > 0 then
			return true, table.concat(matches, "\n")
		else
			return true, S("No matches found.")
		end
	end
})


minetest.register_chatcommand("list_areas", {
	description = S("List your areas, or all areas if you are an admin."),
	privs = areas.adminPrivs,
	func = function(name, param)
		local admin = minetest.check_player_privs(name, areas.adminPrivs)
		local areaStrings = {}
		for id, area in pairs(areas.areas) do
			if admin or areas:isAreaOwner(id, name) then
				table.insert(areaStrings, areas:toString(id))
			end
		end
		if #areaStrings == 0 then
			return true, S("No visible areas.")
		end
		return true, table.concat(areaStrings, "\n")
	end
})


minetest.register_chatcommand("recursive_remove_areas", {
	params = S("<ID>"),
	description = S("Recursively remove areas using an ID"),
	privs = areas.adminPrivs,
	func = function(name, param)
		local id = tonumber(param)
		if not id then
			return false, S("Invalid usage, see"
					.." /help @1.", "recursive_remove_areas")
		end

		if not areas:isAreaOwner(id, name) then
			return false, S("Area @1 does not exist or is"
					.." not owned by you.", id)
		end

		areas:remove(id, true)
		areas:save()
		return true, S("Removed area @1 and it's sub areas.", id)
	end
})


minetest.register_chatcommand("remove_area", {
	params = S("<ID>"),
	description = S("Remove an area using an ID"),
	privs = areas.adminPrivs,
	func = function(name, param)
		local id = tonumber(param)
		if not id then
			return false, S("Invalid usage, see /help @1.", "remove_area")
		end

		if not areas:isAreaOwner(id, name) then
			return false, S("Area @1 does not exist or"
					.." is not owned by you.", id)
		end

		areas:remove(id)
		areas:save()
		return true, S("Removed area @1", id)
	end
})

minetest.register_chatcommand("move_area", {
	params = S("<ID>"),
	description = S("Move (or resize) an area to the current positions."),
	privs = areas.adminPrivs,
	func = function(name, param)
		local id = tonumber(param)
		if not id then
			return false, S("Invalid usage, see /help @1.", "move_area")
		end

		local area = areas.areas[id]
		if not area then
			return false, S("Area does not exist.")
		end

		local pos1, pos2 = areas:getPos(name)
		if not pos1 then
			return false, S("You need to select an area first.")
		end

		areas:move(id, area, pos1, pos2)
		areas:save()

		return true, S("Area successfully moved.")
	end,
})


minetest.register_chatcommand("area_info", {
	description = S("Get information about area configuration and usage."),
	func = function(name, param)
		local lines = {}
		local privs = minetest.get_player_privs(name)

		-- Short (and fast to access) names
		local cfg = areas.config
		local self_prot  = cfg.self_protection
		local prot_priv  = cfg.self_protection_privilege
		local limit      = cfg.self_protection_max_areas
		local limit_high = cfg.self_protection_max_areas_high
		local size_limit = cfg.self_protection_max_size
		local size_limit_high = cfg.self_protection_max_size_high

		local has_high_limit = privs.areas_high_limit
		local has_prot_priv = not prot_priv or privs[prot_priv]
		local can_prot = privs.areas or (self_prot and has_prot_priv)
		local max_count = can_prot and
			(has_high_limit and limit_high or limit) or 0
		local max_size = has_high_limit and
			size_limit_high or size_limit

		-- Self protection information
		local self_prot_line = self_prot and S("Self protection is enabled.") or
					S("Self protection is disabled.")
		table.insert(lines, self_prot_line)
		-- Privilege information
		local priv_line = has_prot_priv and
					S("You have the necessary privilege (\"@1\").", prot_priv) or
					S("You don't have the necessary privilege (\"@1\").", prot_priv)
		table.insert(lines, priv_line)
		if privs.areas then
			table.insert(lines, S("You are an area"..
				" administrator (\"areas\" privilege)."))
		elseif has_high_limit then
			table.insert(lines,
				S("You have extended area protection"..
				" limits (\"areas_high_limit\" privilege)."))
		end

		-- Area count
		local area_num = 0
		for id, area in pairs(areas.areas) do
			if area.owner == name then
				area_num = area_num + 1
			end
		end
		table.insert(lines, S("You have @1 areas.", area_num))

		-- Area limit
		local area_limit_line = privs.areas and
			S("Limit: no area count limit") or
			S("Limit: @1 areas", max_count)
		table.insert(lines, area_limit_line)

		-- Area size limits
		local function size_info(str, size)
			table.insert(lines, S("@1 spanning up to @2x@3x@4.",
				str, size.x, size.y, size.z))
		end
		local function priv_limit_info(lpriv, lmax_count, lmax_size)
			size_info(S("Players with the \"@1\" privilege"..
				" can protect up to @2 areas", lpriv, lmax_count),
				lmax_size)
		end
		if self_prot then
			if privs.areas then
				priv_limit_info(prot_priv,
					limit, size_limit)
				priv_limit_info("areas_high_limit",
					limit_high, size_limit_high)
			elseif has_prot_priv then
				size_info(S("You can protect areas"), max_size)
			end
		end

		return true, table.concat(lines, "\n")
	end,
})


minetest.register_chatcommand("areas_cleanup", {
	description = S("Removes all ownerless areas"),
	privs = areas.adminPrivs,
	func = function()
		local total, count = 0, 0

		local aareas = areas.areas
		for id, _ in pairs(aareas) do
			local owner = aareas[id].owner

			if not areas:player_exists(owner) then
				areas:remove(id)
				count = count + 1
			end

			total = total + 1
		end
		areas:save()

		return true, "Total areas: " .. total .. ", Removed " ..
			count .. " areas. New count: " .. (total - count)
	end
})

-- CH areas:
minetest.register_chatcommand("add_ch_area", {
	params = S("<AreaType> <AreaName>"),
	description = S("Adds a CH area"),
	privs = areas.adminPrivs,
	func = function(name, param)
		if param == "" then
			return false, S("Invalid usage, see /help @1.", "add_ch_area")
		end
		local pos1, pos2 = areas:getPos(name)
		if not (pos1 and pos2) then
			return false, S("You need to select an area first.")
		end
		local areaType, areaName = param:match('^(%S+)%s(.+)$')
		areaType = areaType and tonumber(areaType)
		if not areaType or areaType == 0 then
			return false, S("Invalid usage, see /help @1.", "add_ch_area")
		end
		minetest.log("action", "/add_ch_area invoked, AreaType="..areaType..
				" AreaName="..areaName..
				" StartPos="..minetest.pos_to_string(pos1)..
				" EndPos="  ..minetest.pos_to_string(pos2))

		local canAdd, errMsg = areas:canPlayerAddArea(pos1, pos2, name)
		if not canAdd then
			return false, S("You can't protect that area: @1", errMsg)
		end

		local id = ch_core.add_area(pos1, pos2, areaName, areaType)
		if id then
			return true, S("Area added. ID: @1", -id)
		else
			return false, S("Adding failed!")
		end
	end
})

