local doslech = {}

local colors = {
	celoserverovy = minetest.get_color_escape_sequence("#ff8700"),
	mistni = minetest.get_color_escape_sequence("#fff297"),
	rp = minetest.get_color_escape_sequence("#fff297"),
	soukromy = minetest.get_color_escape_sequence("#ff4cf3"),
	sepot = minetest.get_color_escape_sequence("#fff297cc"),
	skupinovy = minetest.get_color_escape_sequence("#54cc29"),
	systemovy = minetest.get_color_escape_sequence("#cccccc"),
}
local reset_color = minetest.get_color_escape_sequence("#ffffff")
local posl_soukr_adresat = {}

ch_core.systemovy_kanal = function(komu, zprava)
	if zprava ~= "" then -- je-li zprava "", ignorovat
		local barevna_zprava = colors.systemovy .. "SERVER: " .. zprava .. reset_color
		if not komu or komu == "" then -- je-li komu "", rozeslat všem
			minetest.chat_send_all(barevna_zprava)
		else
			minetest.chat_send_player(komu, barevna_zprava)
		end
	end
	return true
end

ch_core.mistni_kanal = function(odkoho, zprava, pozice, max_dosah)
	local pocitadlo = 0
	local odkoho_doslech = ch_core.doslech[odkoho]
	pozice = vector.new(pozice.x, pozice.y, pozice.z)
	local barva_zpravy = max_dosah and colors.sepot or colors.mistni
	local odkoho_s_diakritikou = ch_core.na_jmeno_bez_barev(odkoho)

	for _, player in pairs(minetest.get_connected_players()) do
		local komu = player:get_player_name()
		if komu ~= odkoho and (not ch_core.ignorovani_chatu[odkoho .. ">>>>" .. komu] or minetest.check_player_privs(komu, "protection_bypass")) then
			local vzdalenost_odkoho_komu = math.ceil(vector.distance(pozice, player:get_pos()))
			local komu_doslech = ch_core.doslech[komu]
			if (not max_dosah or vzdalenost_odkoho_komu <= max_dosah) and vzdalenost_odkoho_komu <= komu_doslech then
				minetest.chat_send_player(komu, barva_zpravy .. odkoho_s_diakritikou .. (vzdalenost_odkoho_komu > komu_doslech and " (m.d.)" or "") .. ": " .. zprava .. " (" .. vzdalenost_odkoho_komu .. " m)" .. reset_color)
				pocitadlo = pocitadlo + 1
			end
		end
	end
	minetest.chat_send_player(odkoho, barva_zpravy .. odkoho_s_diakritikou .. ": " .. zprava .. colors.systemovy .. " (" .. pocitadlo .. " post.)" .. reset_color)
	return true
end

ch_core.rp_kanal = function(odkoho, zprava, pozice)
	local pocitadlo = 0
	pozice = vector.new(pozice.x, pozice.y, pozice.z)
	local barevna_zprava = colors.rp .. "*" .. ch_core.na_jmeno_bez_barev(odkoho) .. " " .. zprava .. "*" .. reset_color
	for _, player in pairs(minetest.get_connected_players()) do
		local komu = player:get_player_name()
		if (not ch_core.ignorovani_chatu[odkoho .. ">>>>" .. komu] or minetest.check_player_privs(komu, "protection_bypass")) then
			local vzdalenost_odkoho_komu = math.ceil(vector.distance(pozice, player:get_pos()))
			if vzdalenost_odkoho_komu <= ch_core.doslech[komu] then
				minetest.chat_send_player(komu, barevna_zprava)
				pocitadlo = pocitadlo + 1
			end
		end
	end
	return true
end

ch_core.celoserverovy_kanal = function(odkoho, zprava)
	local pocitadlo = 0
	local barva_zpravy = colors.celoserverovy
	local odkoho_s_diakritikou = ch_core.na_jmeno_bez_barev(odkoho)
	for _, player in pairs(minetest.get_connected_players()) do
		local komu = player:get_player_name()
		if komu ~= odkoho and (not ch_core.ignorovani_chatu[odkoho .. ">>>>" .. komu] or minetest.check_player_privs(komu, "protection_bypass")) then
			local vzdalenost_odkoho_komu = math.ceil(vector.distance(pozice, player:get_pos()))
			local komu_doslech = ch_core.doslech[komu]
			minetest.chat_send_player(komu, barva_zpravy .. odkoho_s_diakritikou .. (vzdalenost_odkoho_komu > komu_doslech and " (m.d.)" or "") .. ": " .. zprava .. " (" .. vzdalenost_odkoho_komu .. " m)" .. reset_color)
			pocitadlo = pocitadlo + 1
		end
	end
	minetest.chat_send_player(odkoho, barva_zpravy .. odkoho_s_diakritikou .. ": " .. zprava .. colors.systemovy .. " (" .. pocitadlo .. " post.)" .. reset_color)
	return true
end

ch_core.soukroma_zprava = function(odkoho, komu, zprava)
	if odkoho == "" or zprava == "" then
		return true
	end
	if komu == "" then
		komu = posl_soukr_adresat[odkoho]
		if not komu then
			ch_core.systemovy_kanal(odkoho, "Dosud jste nikomu nepsali, musíte uvést jméno adresáta/ky soukromé zprávy.")
			return true
		end
	end
	if not minetest.player_exists(komu) then
		ch_core.systemovy_kanal(odkoho, "Hráč/ka " .. ch_core.na_jmeno_bez_barev(komu) .. " neexistuje!")
		return true
	end
	if ch_core.ignorovani_chatu[odkoho .. ">>>>" .. komu] and not minetest.check_player_privs(odkoho, "protection_bypass") then
		ch_core.systemovy_kanal(odkoho, "Hráč/ka " .. ch_core.na_jmeno_bez_barev(komu) .. " vás ignoruje!")
		return true
	end
	for _, player in pairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		if player_name == komu then
			minetest.chat_send_player(odkoho, colors.soukromy .. "-> ".. ch_core.na_jmeno_bez_barev(komu)..": "..zprava .. reset_color)
			minetest.chat_send_player(komu, colors.soukromy .. ch_core.na_jmeno_bez_barev(odkoho)..": "..zprava .. reset_color)
			posl_soukr_adresat[odkoho] = komu
			return true
		end
	end
	ch_core.systemovy_kanal(odkoho, komu .. " není ve hře!")
	return true
end

local function on_chat_message(jmeno, zprava)
	minetest.log("info", "on_chat_message("..jmeno..","..zprava..")")
	local info = minetest.get_player_by_name(jmeno)
	if not info then
		minetest.log("warning", "No info found about player "..jmeno.."!")
		return true
	end
	local c = zprava:sub(1, 1)
	local i
	if c == "!" then
		-- celoserverový kanál
		if not minetest.check_player_privs(jmeno, "shout") then
			ch_core.systemovy_kanal(jmeno, "Nemůžete psát do celoserverového kanálu, protože vám bylo odebráno právo shout!")
			return false
		end
		-- zprava = zprava:sub(zprava:sub(2,2) == " " and 3 or 2, #zprava)
		return ch_core.celoserverovy_kanal(jmeno, zprava)
	elseif c == "_" then
		-- šepot
		-- zprava = zprava:sub(zprava:sub(2,2) == " " and 3 or 2, #zprava)
		return ch_core.mistni_kanal(jmeno, zprava, info:get_pos(), 5)
	elseif c == "*" then
		-- kanál hraní role
		zprava = zprava:sub(zprava:sub(2,2) == " " and 3 or 2, #zprava)
		return ch_core.rp_kanal(jmeno, zprava, info:get_pos())
	elseif c == "\"" then
		-- soukromá zpráva
		local i = string.find(zprava, " ")
		if not i then
			return true
		end
		return ch_core.soukroma_zprava(jmeno, ch_core.odstranit_diakritiku(zprava:sub(2, i - 1)), zprava:sub(i + 1))
	else
		-- místní zpráva
		return ch_core.mistni_kanal(jmeno, zprava, info:get_pos(), nil)
	end
end

local function on_joinplayer(player, last_login)
	local player_name = player:get_player_name()
	ch_core.doslech[player_name] = 65535
	ch_core.joinplayer_timestamp[player_name] = os.time()
	print("JOIN PLAYER(" .. player_name ..")");
	return
end

local function on_leaveplayer(player, time)
	local player_name = player:get_player_name()

	local current_played_seconds = os.time() - (ch_core.joinplayer_timestamp[player_name] or 0)
	local total_played_seconds = (ch_core.storage:get_int("playtime/" .. player_name) or 0) + current_played_seconds
	ch_core.storage:set_int("playtime/" .. player_name, total_played_seconds) -- zatím nefunguje!

	ch_core.doslech[player_name] = nil
	ch_core.joinplayer_timestamp[player_name] = nil
	print("LEAVE PLAYER(" .. player_name .."): played seconds: " .. current_played_seconds .. " / " .. total_played_seconds);
	return
end

local function set_doslech(player_name, param)
	if param == "" or string.match(param, "%D") or param + 0 < 0 or param + 0 > 65535 then
		return false
	end
	param = param + 0
	ch_core.doslech[player_name] = param
	-- print("player_name=("..player_name.."), param=("..param..")")
	ch_core.systemovy_kanal(player_name, "Doslech nastaven na " .. param)
	return true
end

local function set_ignorovat(player_name, name_to_ignore)
	if not minetest.player_exists(name_to_ignore) then
		ch_core.systemovy_kanal(player_name, "Hráč/ka " .. ch_core.na_jmeno_bez_barev(name_to_ignore) .. " neexistuje!")
	elseif name_to_ignore == player_name then
		ch_core.systemovy_kanal(player_name, "Nemůžete ignorovat sám/a sebe!")
	elseif minetest.check_player_privs(name_to_ignore, "protection_bypass") then
		ch_core.systemovy_kanal(player_name, "Hráč/ka " .. ch_core.na_jmeno_bez_barev(name_to_ignore) .. " má právo protection_bypass, takže ho/ji nemůžete ignorovat!")
	elseif ch_core.ignorovani_chatu[name_to_ignore .. ">>>>" .. player_name] then
		ch_core.systemovy_kanal(player_name, "Hráče/ku " .. ch_core.na_jmeno_bez_barev(name_to_ignore) .. " již ignorujete!")
	else
		ch_core.ignorovani_chatu[name_to_ignore .. ">>>>" .. player_name] = 1
		if ch_core.doslech[name_to_ignore] then -- pokud je hráč/ka online...
			ch_core.systemovy_kanal(name_to_ignore, "Hráč/ka " .. ch_core.na_jmeno_bez_barev(player_name) .. " vás nyní ignoruje.")
		end
	end
	return true
end

local function unset_ignorovat(player_name, name_to_unignore)
	if ch_core.ignorovani_chatu[name_to_unignore .. ">>>>" .. player_name] then
		ch_core.ignorovani_chatu[name_to_unignore .. ">>>>" .. player_name] = nil
		ch_core.systemovy_kanal(player_name, "Ignorování hráče/ky " .. ch_core.na_jmeno_bez_barev(name_to_unignore) .. " zrušeno.")
	else
		ch_core.systemovy_kanal(player_name, "Hráč/ka " .. ch_core.na_jmeno_bez_barev(name_to_unignore) .. " není vámi ignorován/a.")
	end
	return true
end

minetest.register_on_chat_message(on_chat_message)
minetest.register_on_joinplayer(on_joinplayer)
minetest.register_on_leaveplayer(on_leaveplayer)
minetest.register_chatcommand("doslech", {
	params = "[<metrů>]",
	description = "Nastaví omezený doslech v chatu. Hodnota musí být celé číslo v rozsahu 0 až 65535. Bez parametru nastaví 65535.",
	privs = { shout = true },
	func = set_doslech,
})
minetest.register_chatcommand("ignorovat", {
	params = "<jménohráče/ky>",
	description = "Do vašeho odhlášení nebudete dostávat žádné zprávy od daného hráče/ky, ledaže má právo protection_bypass.",
	privs = {},
	func = set_ignorovat,
})
minetest.register_chatcommand("neignorovat", {
	params = "<jménohráče/ky>",
	description = "Zruší omezení zadané příkazem /ignorovat.",
	privs = {},
	func = unset_ignorovat,
})
minetest.override_chatcommand("me", {func = function(player_name, message)
	return ch_core.rp_kanal(player_name, message, minetest.get_player_by_name(player_name):get_pos())
end})
minetest.override_chatcommand("msg", {func = function(player_name, text)
	if not string.find(text, " ") then
		return false
	end
	return on_chat_message(player_name, "\"" .. text)
end})
