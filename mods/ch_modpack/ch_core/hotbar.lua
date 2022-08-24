ch_core.open_submod("hotbar")

function ch_core.predmety_na_liste(player, jako_pole)
	local result = {}
	if not player then
		return result
	end
	local inv = player:get_inventory()
	if not inv then
		return result
	end
	local hotbar = inv:get_list("main")
	if not hotbar then
		return result
	end
	local hotbar_length = player:hud_get_hotbar_itemcount()

	if not hotbar_length then
		hotbar_length = 8
	elseif hotbar_length > 32 then
		hotbar_length = 32
	elseif hotbar_length < 1 then
		hotbar_length = 1
	end

	if jako_pole then
		for i = 1, hotbar_length, 1 do
			local name = hotbar[i]:get_name()
			if name and name ~= "" then
				local t = result[name]
				if t then
					table.insert(t, i)
				else
					result[name] = {i}
				end
			end
		end
	else
		for i = hotbar_length, 1, -1 do
			local name = hotbar[i]:get_name()
			if name and name ~= "" then
				result[name] = i
			end
		end
	end
	return result
end

ch_core.close_submod("hotbar")
