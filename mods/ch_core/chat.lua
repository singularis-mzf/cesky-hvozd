ch_core.require_submod("chat", "privs")
ch_core.require_submod("chat", "data")
ch_core.require_submod("chat", "lib")

minetest.register_on_joinplayer(function(player, last_login)
	local player_name = player:get_player_name()
	local online_charinfo = ch_core.get_joining_online_charinfo(player_name)
	online_charinfo.doslech = 65535
	online_charinfo.chat_ignore_list = {} -- player => true
end)

local color_celoserverovy = minetest.get_color_escape_sequence("#ff8700")
local color_mistni = minetest.get_color_escape_sequence("#fff297")
local color_rp = color_mistni
local color_soukromy = minetest.get_color_escape_sequence("#ff4cf3")
local color_sepot = minetest.get_color_escape_sequence("#fff297cc")
-- local color_skupinovy = minetest.get_color_escape_sequence("#54cc29")
local color_systemovy = minetest.get_color_escape_sequence("#cccccc")
local color_reset = minetest.get_color_escape_sequence("#ffffff")

function ch_core.systemovy_kanal(komu, zprava)
	if zprava == "" then
		return true -- je-li zprava "", ignorovat
	end
	if not komu or komu == "" then -- je-li komu "", rozeslat všem
		minetest.chat_send_all(color_systemovy .. "SERVER: " .. zprava .. color_reset)
	else
		minetest.chat_send_player(komu, color_systemovy .. "SERVER: " .. zprava .. color_reset)
	end
end

function ch_core.chat(rezim, odkoho, zprava, pozice)
	pozice = vector.new(pozice.x, pozice.y, pozice.z)

	if rezim == "rp" then
		return ch_core.rp_kanal(odkoho, zprava, pozice)
	end
	if rezim ~= "celoserverovy" and rezim ~= "mistni" and rezim ~= "sepot" then
		minetest.log("error", "ch_core.chat(): invalid chat mode '"..rezim.."'!!!")
		return false
	end

	local pocitadlo, odkoho_info, odkoho_doslech, odkoho_s_diakritikou, barva_zpravy, posl_adresat
	pocitadlo = 0
	posl_adresat = ""
	odkoho_info = ch_core.online_charinfo[odkoho] or {}
	odkoho_doslech = odkoho_info.doslech or 65535
	odkoho_s_diakritikou = ch_core.prihlasovaci_na_zobrazovaci(odkoho)

	if rezim == "celoserverovy" then
		barva_zpravy = color_celoserverovy
	elseif rezim == "sepot" then
		barva_zpravy = color_sepot
	else
		barva_zpravy = color_mistni
	end

	for _, komu_player in pairs(minetest.get_connected_players()) do
		local komu = komu_player:get_player_name()
		local komu_info = ch_core.online_charinfo[komu]
		if komu_info and komu ~= odkoho and (not komu_info.chat_ignore_list[odkoho] or minetest.check_player_privs(odkoho, "protection_bypass")) then
			local vzdalenost_odkoho_komu = math.ceil(vector.distance(pozice, komu_player:get_pos()))
			local komu_doslech = komu_info.doslech or 65535
			local v_doslechu
			if rezim == "celoserverovy" then
				v_doslechu = true
			else
				v_doslechu = vzdalenost_odkoho_komu <= komu_doslech
				if v_doslechu and rezim == "sepot" then
					v_doslechu = vzdalenost_odkoho_komu <= 5
				end
			end
			if v_doslechu then
				local extra_spec
				if odkoho_info.chat_ignore_list[komu] then
					extra_spec = " (ign.)"
				elseif vzdalenost_odkoho_komu > odkoho_doslech then
					extra_spec = " (m.d.)"
				else
					extra_spec = ""
				end
				minetest.chat_send_player(komu, barva_zpravy..odkoho_s_diakritikou..extra_spec..": "..zprava..color_systemovy.." ("..vzdalenost_odkoho_komu.." m)"..color_reset)
				pocitadlo = pocitadlo + 1
				posl_adresat = komu
			end
		end
	end
	minetest.chat_send_player(odkoho, barva_zpravy..odkoho_s_diakritikou..": "..zprava..color_systemovy.." ["..pocitadlo.." post.]"..color_reset)
	if rezim == "sepot" then
		zprava = minetest.sha1(zprava:gsub("%s", ""))
	end
	minetest.log("action", "CHAT:"..rezim..":"..odkoho..">"..pocitadlo.." characters(ex.:"..posl_adresat.."): "..zprava)
	return true
end

function ch_core.rp_kanal(odkoho, zprava, pozice)
	pozice = vector.new(pozice.x, pozice.y, pozice.z)

	local pocitadlo = 0
	local barevna_zprava = color_rp .. "*" .. ch_core.prihlasovaci_na_zobrazovaci(odkoho) .. " " .. zprava .. "*" .. color_reset
	for _, komu_player in pairs(minetest.get_connected_players()) do
		local komu = komu_player:get_player_name()
		local komu_info = ch_core.online_charinfo[komu]
		if komu_info and komu ~= odkoho and (not komu_info.chat_ignore_list[odkoho] or minetest.check_player_privs(odkoho, "protection_bypass")) then
			local vzdalenost_odkoho_komu = math.ceil(vector.distance(pozice, komu_player:get_pos()))
			local komu_doslech = komu_info.doslech or 65535
			if vzdalenost_odkoho_komu <= komu_doslech  then
				minetest.chat_send_player(komu, barevna_zprava)
				pocitadlo = pocitadlo + 1
			end
		end
	end
	minetest.chat_send_player(odkoho, color_rp .. "*" .. ch_core.prihlasovaci_na_zobrazovaci(odkoho) .. " " .. zprava .. "*" .. color_systemovy .. " (" .. pocitadlo .. " post.)" .. color_reset)
	minetest.log("action", "CHAT:rp:"..odkoho..": "..zprava)
	return true
end

function ch_core.soukroma_zprava(odkoho, komu, zprava)
	local odkoho_info = ch_core.online_charinfo[odkoho]
	if not odkoho_info or odkoho == "" or zprava == "" then
		minetest.log("warning", "private message not send: "..(odkoho_info and "true" or "false")..","..odkoho..","..#zprava)
		return true
	end
	if komu == "" then
		komu = odkoho_info.posl_soukr_adresat
		if not komu then
			ch_core.systemovy_kanal(odkoho, "Dosud jste nikomu nepsal/a, musíte uvést jméno adresáta/ky soukromé zprávy.")
			return true
		end
	end
	if not minetest.player_exists(komu) then
		ch_core.systemovy_kanal(odkoho, "Postava " .. ch_core.prihlasovaci_na_zobrazovaci(komu) .. " neexistuje!")
		return true
	end
	local komu_info = ch_core.online_charinfo[komu]
	if komu_info then
		if komu_info.chat_ignore_list[odkoho] and not minetest.check_player_privs(odkoho, "protection_bypass") then
			ch_core.systemovy_kanal(odkoho, "Postava " .. ch_core.prihlasovaci_na_zobrazovaci(komu) .. " vás ignoruje!")
			return true
		end
		minetest.chat_send_player(odkoho, color_soukromy .. "-> ".. ch_core.prihlasovaci_na_zobrazovaci(komu)..": "..zprava .. color_reset)
		minetest.chat_send_player(komu, color_soukromy .. ch_core.prihlasovaci_na_zobrazovaci(odkoho)..": "..zprava .. color_reset)
		odkoho_info.posl_soukr_adresat = komu
		minetest.log("action", "CHAT:soukroma_zprava:"..odkoho..">"..komu..": "..minetest.sha1(zprava:gsub("%s", "")))
		return true
	end
	ch_core.systemovy_kanal(odkoho, komu .. " není ve hře!")
	return true
end

local function on_chat_message(jmeno, zprava)
	-- minetest.log("info", "on_chat_message("..jmeno..","..zprava..")") -- DEBUGGING ONLY!
	local info = minetest.get_player_by_name(jmeno)
	if not info then
		minetest.log("warning", "No info found about player "..jmeno.."!")
		return true
	end
	local info_pos = info:get_pos()
	if not info_pos then
		minetest.log("warning", "No position of player "..jmeno.."!")
		return true
	end
	local c = zprava:sub(1, 1)
	if c == "!" then
		-- celoserverový kanál
		if not minetest.check_player_privs(jmeno, "shout") then
			ch_core.systemovy_kanal(jmeno, "Nemůžete psát do celoserverového kanálu, protože vám bylo odebráno právo shout!")
			return false
		end
		-- zprava = zprava:sub(zprava:sub(2,2) == " " and 3 or 2, #zprava)
		return ch_core.chat("celoserverovy", jmeno, zprava, info_pos)
	elseif c == "_" then
		-- šepot
		-- zprava = zprava:sub(zprava:sub(2,2) == " " and 3 or 2, #zprava)
		return ch_core.chat("sepot", jmeno, zprava, info_pos)
	elseif c == "*" then
		-- kanál hraní role
		zprava = zprava:sub(zprava:sub(2,2) == " " and 3 or 2, #zprava)
		return ch_core.chat("rp", jmeno, zprava, info_pos)
	elseif c == "\"" then
		-- soukromá zpráva
		local i = string.find(zprava, " ")
		if not i then
			return true
		end
		return ch_core.soukroma_zprava(jmeno, ch_core.odstranit_diakritiku(zprava:sub(2, i - 1)), zprava:sub(i + 1))
	else
		-- místní zpráva
		return ch_core.chat("mistni", jmeno, zprava, info_pos)
	end
end

function ch_core.set_doslech(player_name, param)
	if param == "" or string.match(param, "%D") or param + 0 < 0 or param + 0 > 65535 then
		return false
	end
	param = math.max(0, math.min(65535, param + 0))
	local player_info = ch_core.online_charinfo[player_name] or {}
	player_info.doslech = param
	-- print("player_name=("..player_name.."), param=("..param..")")
	ch_core.systemovy_kanal(player_name, "Doslech nastaven na " .. param)
	return true
end

function ch_core.set_ignorovat(player_name, name_to_ignore)
	local player_info = ch_core.online_charinfo[player_name]
	if not player_info then
		minetest.log("error", "[ch_core] cannot found online_charinfo["..player_name.."]")
		return false
	end
	local ignore_list = player_info.chat_ignore_list
	if not ignore_list then
		minetest.log("error", "[ch_core] online_charinfo["..player_name.."] does not have ignore_list!")
		return false
	end
	name_to_ignore = ch_core.jmeno_na_prihlasovaci(name_to_ignore)
	if not minetest.player_exists(name_to_ignore) then
		ch_core.systemovy_kanal(player_name, "Postava " .. ch_core.prihlasovaci_na_zobrazovaci(name_to_ignore) .. " neexistuje!")
	elseif name_to_ignore == player_name then
		ch_core.systemovy_kanal(player_name, "Nemůžete ignorovat sám/a sebe!")
	elseif minetest.check_player_privs(name_to_ignore, "protection_bypass") then
		ch_core.systemovy_kanal(player_name, "Postava " .. ch_core.prihlasovaci_na_zobrazovaci(name_to_ignore) .. " má právo protection_bypass, takže ji nemůžete ignorovat!")
	elseif ignore_list[name_to_ignore] then
		ch_core.systemovy_kanal(player_name, "Postavu " .. ch_core.prihlasovaci_na_zobrazovaci(name_to_ignore) .. " již ignorujete!")
	else
		ignore_list[name_to_ignore] = 1
		ch_core.systemovy_kanal(player_name, "Nyní postavu " .. ch_core.prihlasovaci_na_zobrazovaci(name_to_ignore) .. " ignorujete. Toto platí, než se odhlásíte ze hry nebo než ignorování zrušíte příkazem /neignorovat.")
		local target_info = ch_core.online_charinfo[name_to_ignore]
		if target_info then -- pokud je hráč/ka online...
			ch_core.systemovy_kanal(name_to_ignore, "Postava " .. ch_core.prihlasovaci_na_zobrazovaci(player_name) .. " vás nyní ignoruje.")
		end
	end
	return true
end

function ch_core.unset_ignorovat(player_name, name_to_unignore)
	local player_info = ch_core.online_charinfo[player_name]
	if not player_info then
		minetest.log("error", "[ch_core] cannot found online_charinfo["..player_name.."]")
		return false
	end
	local ignore_list = player_info.chat_ignore_list
	if not ignore_list then
		minetest.log("error", "[ch_core] online_charinfo["..player_name.."] does not have ignore_list!")
		return false
	end

	if ignore_list[name_to_unignore] then
		ignore_list[name_to_unignore] = nil
		ch_core.systemovy_kanal(player_name, "Ignorování postavy " .. ch_core.prihlasovaci_na_zobrazovaci(name_to_unignore) .. " zrušeno.")
		local target_info = ch_core.online_charinfo[name_to_unignore]
		if target_info then -- pokud je hráč/ka online...
			ch_core.systemovy_kanal(name_to_unignore, "Postava " .. ch_core.prihlasovaci_na_zobrazovaci(player_name) .. " vás přestala ignorovat. Nyní již můžete této postavě psát.")
		end
	else
		ch_core.systemovy_kanal(player_name, "Postava " .. ch_core.prihlasovaci_na_zobrazovaci(name_to_unignore) .. " není vámi ignorována.")
	end
	return true
end

minetest.register_on_chat_message(on_chat_message)

minetest.override_chatcommand("me", {func = function(player_name, message)
	local player = minetest.get_player_by_name(player_name)
	if not player then
		return false
	end
	return ch_core.rp_kanal(player_name, message, player:get_pos())
end})

minetest.override_chatcommand("msg", {func = function(player_name, text)
	local player = minetest.get_player_by_name(player_name)
	if not string.find(text, " ") or not player then
		return false
	end
	return on_chat_message(player_name, "\"" .. text)
end})

minetest.register_chatcommand("doslech", {
	params = "[<metrů>]",
	description = "Nastaví omezený doslech v chatu. Hodnota musí být celé číslo v rozsahu 0 až 65535. Bez parametru nastaví 65535.",
	privs = { shout = true },
	func = function(player_name, param)
		return ch_core.set_doslech(player_name, param)
	end,
})
minetest.register_chatcommand("ignorovat", {
	params = "<jménohráče/ky>",
	description = "Do vašeho odhlášení nebudete dostávat žádné zprávy od daného hráče/ky, ledaže má právo protection_bypass.",
	privs = {},
	func = function(player_name, name_to_ignore)
		return ch_core.set_ignorovat(player_name, name_to_ignore)
	end,
})
minetest.register_chatcommand("neignorovat", {
	params = "<jménohráče/ky>",
	description = "Zruší omezení zadané příkazem /ignorovat.",
	privs = {},
	func = function(player_name, name_to_unignore)
		return ch_core.unset_ignorovat(player_name, name_to_unignore)
	end,
})

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
		local offline_charinfo = ch_core.get_offline_charinfo(login)
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
		ch_core.update_player_nametag(login)
		ch_core.save_offline_charinfo(login, "string", "barevne_jmeno")
		-- if (color:sub(1, 1) ~= "#") then
		return true
	end,
})

minetest.register_chatcommand("nastavit_jmeno", {
	params = "<nové jméno postavy>",
	description = "Nastaví zobrazované jméno postavy",
	privs = { server = true },
	func = function(player_name, param)
		local login = ch_core.odstranit_diakritiku(param):gsub(" ", "_")
		if not minetest.player_exists(login) then
			return false, "Postava '"..login.."' neexistuje!"
		end
		local offline_charinfo = ch_core.get_offline_charinfo(login)
		local puvodni_jmeno = offline_charinfo.jmeno or login
		if puvodni_jmeno ~= param then
			offline_charinfo.jmeno = param
			local barevne_jmeno = offline_charinfo.barevne_jmeno
			if barevne_jmeno then
				offline_charinfo.barevne_jmeno = barevne_jmeno:gsub(puvodni_jmeno, param)
				ch_core.save_offline_charinfo(login, "string", "barevne_jmeno")
			end
			ch_core.save_offline_charinfo(login, "string", "jmeno")
			ch_core.update_player_nametag(login)
			return true, "Jméno nastaveno: "..login.." > "..param
		else
			ch_core.update_player_nametag(login)
			return true, "Titulek obnoven: "..login.." > "..param
		end
	end,
})

minetest.register_chatcommand("nastavit_titul", {
	params = "<prihlasovaci_jmeno_postavy> [text titulu]",
	description = "Nastaví nebo zruší postavě titul nad jménem",
	privs = { server = true },
	func = function(player_name, param)
		local i = string.find(param, " ")
		if i then
			return ch_core.set_titul(param:sub(1, i - 1), param:sub(i + 1))
		else
			return ch_core.set_titul(param, "")
		end
	end,
})

minetest.send_join_message = function(player_name)
	return ch_core.systemovy_kanal("", "Připojila se postava: "..ch_core.prihlasovaci_na_zobrazovaci(player_name))
end
minetest.send_leave_message = function(player_name, is_timedout)
	return ch_core.systemovy_kanal("", "Odpojila se postava: "..ch_core.prihlasovaci_na_zobrazovaci(player_name))
end
