local green = minetest.get_color_escape_sequence("#bada55")
local green2 = minetest.get_color_escape_sequence("#33ff55")

-- poison and drunk effects function
local effect_me = function(pos, player, def)

	local name = player:get_player_name() ; if not name then return end

	if def.poison or def.drunk then

		player:hud_change(stamina.players[name].hud_id, "text", "stamina_hud_poison.png")
	end

	if def.poison and def.poison > 0 then

		stamina.players[name].poisoned = def.poison

		minetest.chat_send_player(name, green .. "Seems you have been poisoned!")

	elseif def.drunk and def.drunk > 0 then

		stamina.players[name].drunk = def.drunk

		minetest.chat_send_player(name, green .. "You seem a little tipsy!")
	end
end


-- restore stamina function
local full_stamina = function(pos, player, def)

	local name = player:get_player_name() ; if not name then return end

	stamina.change(player, 100) -- set to 100 incase of default stamina increase

	minetest.chat_send_player(name, green2 .. "You suddenly feel full!")
end


-- add lucky blocks
lucky_block:add_blocks({
	{"cus", effect_me, {poison = 5}},
	{"cus", effect_me, {poison = 10}},
	{"cus", effect_me, {drunk = 30}},
	{"cus", full_stamina}
})
