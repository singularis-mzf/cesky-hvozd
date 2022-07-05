local color_bgcolor = {r = 0, g = 0, b = 0, a = 0}
local color_normal = {r = 255, g = 255, b = 255, a = 255}
local color_unregistered = {r = 153, g = 153, b = 153, a = 255}

local function on_newplayer(player)
	local player_name = player:get_player_name()

	print("[ch_core] New player '"..player_name.."'");
	local inv = player:get_inventory();
	inv:add_item("main", "default:cobble 50")

	return
end

local function on_joinplayer(player, last_login)
	local player_name = player:get_player_name()

	if not minetest.check_player_privs(player, "ch_registered_player") then
		player:set_nametag_attributes({ text = "*nová postava*\n" .. player_name, color = color_unregistered, bgcolor = color_bgcolor, })

	elseif string.sub(player_name, -2) == "PP" then
		player:set_nametag_attributes({ text = "*pomocná postava*\n" .. player_name, color = color_unregistered, bgcolor = color_bgcolor, })

	else
		local t = ch_core.titulky_hracu_ek[player_name]
		if t then
			local titul = t.titul
			titul = titul and "*" .. titul .. "*\n" or ""
			player:set_nametag_attributes({
				text = titul .. (t.jmeno or player_name),
				color = t.color or color_normal,
				bgcolor = t.bgcolor or color_bgcolor,
				})
		end
	end
end

minetest.register_on_newplayer(on_newplayer)
minetest.register_on_joinplayer(on_joinplayer)
