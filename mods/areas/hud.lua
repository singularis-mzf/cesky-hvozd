-- This is inspired by the landrush mod by Bremaweb
local S = minetest.get_translator("areas")
areas.hud = {}
areas.hud.refresh = 0

minetest.register_globalstep(function(dtime)
	areas.hud.refresh = areas.hud.refresh + dtime
	if areas.hud.refresh > areas.config["tick"] then
		areas.hud.refresh = 0
	else
		return
	end

	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local player_is_admin = minetest.check_player_privs(name, "areas")
		local pos = vector.round(player:get_pos())
		pos = vector.apply(pos, function(p)
			return math.max(math.min(p, 2147483), -2147483)
		end)
		local areaStrings = {}

		for _, id in ipairs(areas:getAreaIdsAtPosByPriority(pos)) do
			local area = areas.areas[id]
			if not area then
				error("Internal error: area ID "..id.." is invalid!")
			end
			if area.type ~= 1 or player_is_admin then
				local str_parts = {
					area.name, -- 1
					" [", -- 2
					id, -- 3
					"", -- 4
					"",-- 5
					", ", -- 6
					S(areas.area_types_number_to_name[area.type] or "unknown"), -- 7
					"", -- 8
					"", -- 9
					"]", -- 10
				}
				if area.owner and area.owner ~= "Administrace" then
					str_parts[4] = ", "
					str_parts[5] = area.owner
				end
				if player_is_admin then
					str_parts[8] = ", "
					str_parts[9] = "z"..area.zindex
				end
				table.insert(areaStrings, table.concat(str_parts))
			end
		end

		for i, area in pairs(areas:getExternalHudEntries(pos)) do
			local str = ""
			if area.name then str = area.name .. " " end
			if area.id then str = str.."["..area.id.."] " end
			if area.owner then str = str.."("..area.owner..")" end
			table.insert(areaStrings, str)
		end

		local areaString = S("Areas:")
		if #areaStrings > 0 then
			areaString = areaString.."\n"..
				table.concat(areaStrings, "\n")
		end
		local hud = areas.hud[name]
		if not hud then
			hud = {}
			areas.hud[name] = hud
			hud.areasId = player:hud_add({
				hud_elem_type = "text",
				name = "Areas",
				number = 0xFFFFFF,
				position = {x=0, y=1},
				offset = {x=8, y=-8},
				text = areaString,
				scale = {x=200, y=60},
				alignment = {x=1, y=-1},
			})
			hud.oldAreas = areaString
			return
		elseif hud.oldAreas ~= areaString then
			player:hud_change(hud.areasId, "text", areaString)
			hud.oldAreas = areaString
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	areas.hud[player:get_player_name()] = nil
end)
