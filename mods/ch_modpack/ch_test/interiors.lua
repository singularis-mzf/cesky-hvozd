local counter = 0

local allowed_players = {
	Administrace = true,
	singleplayer = true,
}

local function step(dtime)
	for player_name, online_charinfo in pairs(ch_core.online_charinfo) do
		local player = minetest.get_player_by_name(player_name)
		local player_pos = player and player:get_pos()
		if allowed_players[player_name] and player_pos ~= nil then
			local player_pos_rounded = vector.round(player_pos)
			local player_last_pos_rounded = online_charinfo.player_last_pos_rounded
			if not player_last_pos_rounded then
				online_charinfo.player_last_pos_rounded = player_pos_rounded
			elseif not vector.equals(player_last_pos_rounded, player_pos_rounded) then
				-- detect
				local was_in_interior = online_charinfo.was_in_interior or 0 -- 0 => exterior, 1 => interior
				local nlight = minetest.get_natural_light(vector.offset(player_pos_rounded, 0, 1, 0), 0.5) or 0
				if nlight < 10 then
					-- interior
					if was_in_interior == 0 then
						counter = counter + 1
						online_charinfo.was_in_interior = 1
						minetest.chat_send_player(player_name, "*** ["..counter.."] Vstoupil/a jste do interiéru "..minetest.pos_to_string(player_pos)..".")
					end
				else
					-- exterior
					if was_in_interior == 1 then
						counter = counter + 1
						online_charinfo.was_in_interior = 0
						minetest.chat_send_player(player_name, "*** ["..counter.."] Opustil/a jste interiér "..minetest.pos_to_string(player_pos)..".")
					end
				end
			end
		end
	end
end

minetest.register_globalstep(step)

local def = {
	params = "<ano|ne>",
	description = "Zapne nebo vypne experimentální detekci interiérů a exteriérů.",
	func = function(player_name, param)
		if param == "ano" then
			allowed_players[player_name] = true
		elseif param == "ne" then
			allowed_players[player_name] = false
		else
			return false, "Neplatné zadání. Použijte „/testinteriérů ano“ nebo „/testinteriérů ne“."
		end
		return true
	end,
}
minetest.register_chatcommand("testinteriérů", def)
minetest.register_chatcommand("testinterieru", def)
