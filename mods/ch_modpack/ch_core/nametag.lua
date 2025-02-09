ch_core.open_submod("nametag", {data = true, lib = true})

-- local nametag_color_red = minetest.get_color_escape_sequence("#cc5257");
--local nametag_color_blue = minetest.get_color_escape_sequence("#6693ff");
local nametag_color_green = minetest.get_color_escape_sequence("#48cc3d");
--local nametag_color_yellow = minetest.get_color_escape_sequence("#fff966");
-- local nametag_color_aqua = minetest.get_color_escape_sequence("#66f8ff");
local nametag_color_grey = minetest.get_color_escape_sequence("#cccccc");
local color_reset = minetest.get_color_escape_sequence("#ffffff")

local nametag_nochat_bgcolor_table = {r = 0, g = 0, b = 0, a = 0}
local nametag_chat_bgcolor_table = {r = 0, g = 0, b = 0, a = 255}


-- local nametag_color_bgcolor_table = {r = 0, g = 0, b = 0, a = 0}
local nametag_color_normal_table = {r = 255, g = 255, b = 255, a = 255}
local nametag_color_unregistered_table = {r = 204, g = 204, b = 204, a = 255} -- 153?
local nametag_color_unregistered = nametag_color_grey

local nametag_padding_left = "  "
local nametag_padding_right = nametag_padding_left

function ch_core.compute_player_nametag(online_charinfo, offline_charinfo)
	local color, bgcolor
	local titul, barevne_jmeno, local_color_reset, staly_titul
	local player_name = online_charinfo.player_name
	local casti = {}

	table.insert(casti, nametag_padding_left)

	if string.sub(player_name, -2) == "PP" then
		-- pomocná postava
		local_color_reset = nametag_color_grey
		color = nametag_color_unregistered
		staly_titul = "pomocná postava"
	elseif minetest.check_player_privs(player_name, "ch_registered_player") then
		-- registrovaná postava
		local_color_reset = color_reset
		color = nametag_color_normal_table
		staly_titul = offline_charinfo.titul
		if staly_titul == "" then
			staly_titul = nil
		end
	else
		-- neregistrovaná postava
		local_color_reset = nametag_color_grey
		color = nametag_color_unregistered_table
		staly_titul = "nová postava"
	end

	for dtitul, _ in pairs(online_charinfo.docasne_tituly or {}) do
		titul = (titul or "").."*"..dtitul.."*\n"
	end
	if titul then
		-- dočasný titul
		table.insert(casti, nametag_color_green)
		table.insert(casti, titul)
		table.insert(casti, local_color_reset)
	elseif staly_titul then
		-- trvalý titul
		table.insert(casti, "*"..staly_titul.."*\n")
	end

	barevne_jmeno = offline_charinfo.barevne_jmeno
	if not barevne_jmeno then
		barevne_jmeno = local_color_reset..(offline_charinfo.jmeno or player_name)
	end
	table.insert(casti, barevne_jmeno)

	local horka_zprava = online_charinfo.horka_zprava
	if horka_zprava then
		table.insert(casti, ":\n")
		table.insert(casti, horka_zprava[1])
		if horka_zprava[2] then
			table.insert(casti, "\n")
			table.insert(casti, horka_zprava[2])
			if horka_zprava[3] then
				table.insert(casti, "\n")
				table.insert(casti, horka_zprava[3])
			end
		end
		bgcolor = nametag_chat_bgcolor_table
	else
		bgcolor = nametag_nochat_bgcolor_table
	end

	table.insert(casti, nametag_padding_right)

	local text = table.concat(casti):gsub("\n", nametag_padding_right.."\n"..nametag_padding_left)
	return {color = color, bgcolor = bgcolor, text = text}
end

minetest.register_chatcommand("nastavit_barvu_jmena", {
	params = "<prihlasovaci_jmeno_postavy> [#RRGGBB]",
	description = "Nastaví nebo zruší postavě barevné jméno",
	privs = { server = true },
	func = function(player_name, param)
		local i = string.find(param, " ")
		local login, color
		if not i then
			login = param
			color = ""
		else
			login = param:sub(1, i - 1)
			color = param:sub(i + 1, -1)
		end
		if not minetest.player_exists(login) then
			return false, "Postava s přihlašovacím jménem "..login.." neexistuje!"
		end
		local offline_charinfo = ch_data.get_offline_charinfo(login)
		local jmeno = offline_charinfo.jmeno or login
		if color == "" then
			offline_charinfo.barevne_jmeno = nil
		else
			if jmeno == "Administrace" then
				offline_charinfo.barevne_jmeno = minetest.get_color_escape_sequence("#cc5257").."Admin"..minetest.get_color_escape_sequence("#6693ff").."istrace"..color_reset
			else
				offline_charinfo.barevne_jmeno = minetest.get_color_escape_sequence(string.lower(color))..jmeno..color_reset
			end
		end
		ch_data.save_offline_charinfo(login)
		local online_charinfo = ch_data.online_charinfo[player_name]
		local player = online_charinfo and minetest.get_player_by_name(login)
		if online_charinfo and player then
			player:set_nametag_attributes(ch_core.compute_player_nametag(online_charinfo, offline_charinfo))
		end
		return true
	end,
})

minetest.register_chatcommand("nastavit_jmeno", {
	params = "<nové jméno postavy>",
	description = "Nastaví zobrazované jméno postavy",
	privs = { server = true },
	func = function(player_name, param)
		local login = ch_core.jmeno_na_prihlasovaci(param)
		if not minetest.player_exists(login) then
			return false, "Postava '"..login.."' neexistuje!"
		end
		local offline_charinfo = ch_data.get_offline_charinfo(login)
		local puvodni_jmeno = offline_charinfo.jmeno or login
		local message
		if puvodni_jmeno ~= param then
			offline_charinfo.jmeno = param
			local barevne_jmeno = offline_charinfo.barevne_jmeno
			if barevne_jmeno then
				offline_charinfo.barevne_jmeno = barevne_jmeno:gsub(puvodni_jmeno, param)
			end
			ch_data.save_offline_charinfo(login)
			message = "Jméno nastaveno: "..login.." > "..param
		else
			message = "Titulek obnoven: "..login.." > "..param
		end
		local online_charinfo = ch_data.online_charinfo[login]
		local player = online_charinfo and minetest.get_player_by_name(login)
		if online_charinfo and player then
			player:set_nametag_attributes(ch_core.compute_player_nametag(online_charinfo, offline_charinfo))
		end
		return true, message
	end,
})

minetest.register_chatcommand("nastavit_titul", {
	params = "<prihlasovaci_jmeno_postavy> [text titulu]",
	description = "Nastaví nebo zruší postavě titul nad jménem",
	privs = { server = true },
	func = function(player_name, param)
		local login, new_titul
		local i = string.find(param, " ")
		if i then
			login = ch_core.jmeno_na_prihlasovaci(param:sub(1, i - 1))
			new_titul = param:sub(i + 1)
		else
			login = ch_core.jmeno_na_prihlasovaci(param)
			new_titul = ""
		end
		return ch_core.set_titul(login, new_titul)
	end,
})

ch_core.close_submod("nametag")
