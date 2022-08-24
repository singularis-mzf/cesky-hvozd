ch_core.open_submod("dennoc", {privs = true, chat = true})

--[[
	/dennoc
	/dennoc den
	/dennoc noc
	/dennoc XX:XX
]]

local def = {
	privs = {},
	params = "[koeficient]",
	description = "Nastaví osobní osvětlení světa.",
	func = function(player_name, param)
		local player = minetest.get_player_by_name(player_name)
		if not player then
			return false
		end

		local c
		if param == "" then
			player:override_day_night_ratio(nil)
			ch_core.systemovy_kanal(player_name, "/dennoc: osobní osvětlení světa zrušeno")
			return true
		elseif param == "den" then
			c = 1
		elseif param == "noc" then
			c = 0
		else
			local s = param:gsub(",", ".")
			c = tonumber(s)
		end
		if 0.0 <= c and c <= 1.0 then
			player:override_day_night_ratio(c)
			ch_core.systemovy_kanal(player_name, "/dennoc: osobní osvětlení světa nastaveno na koeficient "..c)
			return true
		end
		return false, "Neplatný formát parametru!"
	end
}
minetest.register_chatcommand("dennoc", def)

ch_core.close_submod("dennoc")
