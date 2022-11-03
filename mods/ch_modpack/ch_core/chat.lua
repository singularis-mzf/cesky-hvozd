ch_core.open_submod("chat", {privs = true, data = true, lib = true, nametag = true})

minetest.register_on_joinplayer(function(player, last_login)
	local online_charinfo = ch_core.get_joining_online_charinfo(player:get_player_name())
	if online_charinfo.doslech == nil then
		online_charinfo.doslech = 65535
	end
	online_charinfo.chat_ignore_list = {} -- player => true
end)

-- BARVY
-- ===========================================================================

local color_celoserverovy = minetest.get_color_escape_sequence("#ff8700")
local color_mistni = minetest.get_color_escape_sequence("#fff297")
local color_mistni_zblizka = minetest.get_color_escape_sequence("#64f231") -- 54cc29
local color_rp = color_mistni
local color_soukromy = minetest.get_color_escape_sequence("#ff4cf3")
local color_sepot = minetest.get_color_escape_sequence("#fff297cc")
local color_systemovy = minetest.get_color_escape_sequence("#cccccc")
local color_reset = minetest.get_color_escape_sequence("#ffffff")

-- NASTAVENÍ
-- ===========================================================================
local vzdalenost_zblizka = 10 -- počet metrů, na které se ještě považuje hovor za hovor zblízka; nemá vliv na šepot
local vzdalenost_pro_ignorovani = 150 -- poloměr koule, ve které se nesmí nacházet ignorující postava, aby se zobrazila zpráva nad postavou

-- HISTORIE
-- ===========================================================================
ch_core.last_mistni = {char = "", char_gen = 0, count = 0, zprava = ""}
ch_core.last_celoserverovy = {char = "", char_gen = 0, count = 0, zprava = ""}
ch_core.last_sepot = {char = "", char_gen = 0, count = 0, zprava = ""}
ch_core.last_soukromy = {char = "", char_gen = 0, count = 0, zprava = ""}

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

	if rezim ~= "celoserverovy" and rezim ~= "mistni" and rezim ~= "sepot" then
		minetest.log("error", "ch_core.chat(): invalid chat mode '"..rezim.."'!!!")
		return false
	end

	local pocitadlo = 0
	local posl_adresat = ""
	local odkoho_info = ch_core.online_charinfo[odkoho] or {}
	local odkoho_doslech = odkoho_info.doslech or 65535
	local odkoho_s_diakritikou = ch_core.prihlasovaci_na_zobrazovaci(odkoho)
	local barva_zpravy, barva_zpravy_zblizka, posl_adresat, min_vzdal_ignorujici, min_vzdal_adresat

	if rezim == "celoserverovy" then
		barva_zpravy = color_celoserverovy
		barva_zpravy_zblizka = barva_zpravy
	elseif rezim == "sepot" then
		barva_zpravy = color_sepot
		barva_zpravy_zblizka = barva_zpravy
	else -- "mistni"
		barva_zpravy = color_mistni
		barva_zpravy_zblizka = color_mistni_zblizka
	end

	local casti_zpravy = {
		barva_zpravy, -- [1] (neměnit, reprezentuje kanál)
		"", -- [2]
		odkoho_s_diakritikou, -- [3]
		": ", -- [4] // mění se
		barva_zpravy, -- [5] // mění se
		zprava, -- [6]
		"", -- [7]
		color_systemovy, -- [8]
		" (", -- [9]
		0, -- [10] // mění se
		" m)", -- [11]
		color_reset, -- [12]
	}

	for _, komu_player in pairs(minetest.get_connected_players()) do
		local komu = komu_player:get_player_name()
		local komu_info = ch_core.online_charinfo[komu]
		if komu_info and komu ~= odkoho then
			local vzdalenost_odkoho_komu = math.ceil(vector.distance(pozice, komu_player:get_pos()))
			local komu_doslech = komu_info.doslech or 65535
			if not komu_info.chat_ignore_list[odkoho] or minetest.check_player_privs(odkoho, "protection_bypass") then
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
					if vzdalenost_odkoho_komu <= vzdalenost_zblizka then
						casti_zpravy[5] = barva_zpravy_zblizka
					else
						casti_zpravy[5] = barva_zpravy
					end
					if odkoho_info.chat_ignore_list[komu] then
						casti_zpravy[4] = "(ign.): "
					elseif vzdalenost_odkoho_komu > odkoho_doslech then
						casti_zpravy[4] = "(m.d.): "
					elseif rezim == "sepot" then
						casti_zpravy[4] = "(šepot): "
					else
						casti_zpravy[4] = ": "
					end
					casti_zpravy[10] = vzdalenost_odkoho_komu
					minetest.chat_send_player(komu, table.concat(casti_zpravy))
					pocitadlo = pocitadlo + 1
					if rezim == "sepot" then
						minetest.sound_play("chat3_bell", {to_player = komu, gain = 1.0}, true)
					end

					if not min_vzdal_adresat or vzdalenost_odkoho_komu < min_vzdal_adresat then
						min_vzdal_adresat = vzdalenost_odkoho_komu
						posl_adresat = komu
					end
				end
			else
				-- ignorující
				if not min_vzdal_ignorujici or min_vzdal_ignorujici < vzdalenost_odkoho_komu then
					min_vzdal_ignorujici = vzdalenost_odkoho_komu
				end
			end
		end
	end

	-- Zaslat postavě „odkoho“
	casti_zpravy[4] = ": "
	casti_zpravy[5] = barva_zpravy_zblizka
	casti_zpravy[9] = " ["
	casti_zpravy[10] = pocitadlo
	casti_zpravy[11] = " post.]"
	minetest.chat_send_player(odkoho, table.concat(casti_zpravy))

	-- Zobrazit nad postavou:
	local zobrazeno_nad_postavou = "false"
	if (rezim == "mistni" or rezim == "celoserverovy")
		and min_vzdal_adresat and min_vzdal_adresat <= vzdalenost_zblizka
		and (not min_vzdal_ignorujici or min_vzdal_ignorujici > vzdalenost_pro_ignorovani)
	then
		local player = minetest.get_player_by_name(odkoho)
		if player then
			local horka_zprava = ch_core.utf8_wrap(zprava, 60)
			horka_zprava[1] = barva_zpravy_zblizka..horka_zprava[1]
			horka_zprava.timeout = ch_core.cas + 15
			odkoho_info.horka_zprava = horka_zprava
			player:set_nametag_attributes(ch_core.compute_player_nametag(odkoho_info, ch_core.get_offline_charinfo(odkoho)))
			zobrazeno_nad_postavou = "true"
		else
			zobrazeno_nad_postavou = "fail"
		end
	end

	-- Zapsat do logu:
	if rezim == "sepot" then
		zprava = minetest.sha1(odkoho.."/"..zprava:gsub("%s", ""))
	end
	minetest.log("action", "CHAT:"..rezim..":"..odkoho..">"..pocitadlo.." characters(ex.:"..(posl_adresat or "nil")..", mv_adr="..(min_vzdal_adresat or "nil")..", znadpost="..zobrazeno_nad_postavou.."): "..zprava)

	-- Zaznamenat aktivitu:
	if (rezim == "mistni" or rezim == "celoserverovy" or rezim == "sepot") then
		local last = ch_core["last_"..rezim]
		if zprava ~= last.zprava and pocitadlo > 0 then
			last.zprava = zprava
			if last.char ~= odkoho then
				last.char = odkoho
				last.char_gen = last.char_gen + 1
				last.count = 1
			else
				last.count = last.count + 1
			end
		end
	end

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
		zprava = minetest.sha1(odkoho.."/"..zprava:gsub("%s", ""))
		minetest.log("action", "CHAT:soukroma_zprava:"..odkoho..">"..komu..": "..zprava)
		minetest.sound_play("chat3_bell", {to_player = komu, gain = 1.0}, true)

		-- Zaznamenat aktivitu:
		local last = ch_core.last_soukromy
		if zprava ~= last.zprava then
			last.zprava = zprava
			if last.char ~= odkoho then
				last.char = odkoho
				last.char_gen = last.char_gen + 1
				last.count = 1
			else
				last.count = last.count + 1
			end
		end

		return true
	end
	ch_core.systemovy_kanal(odkoho, komu .. " není ve hře!")
	return true
end

local function on_chat_message(jmeno, zprava)
	-- minetest.log("info", "on_chat_message("..jmeno..","..zprava..")") -- DEBUGGING ONLY!
	local info = minetest.get_player_by_name(jmeno)
	local info_pos = info:get_pos()
	local online_charinfo = ch_core.online_charinfo[jmeno]
	if not info then
		minetest.log("warning", "No info found about player "..jmeno.."!")
		return true
	end
	if not info_pos then
		minetest.log("warning", "No position of player "..jmeno.."!")
		return true
	end
	if not online_charinfo then
		minetest.log("warning", "No online_charinfo of character "..jmeno.."!")
		return true
	end

	-- disrupt /pryč:
	local pryc_func = online_charinfo.pryc
	if pryc_func then
		pryc_func(info, online_charinfo)
	end

	local c = zprava:sub(1, 1)
	if c == "!" then
		-- celoserverový kanál
		if not minetest.check_player_privs(jmeno, "shout") then
			ch_core.systemovy_kanal(jmeno, "Nemůžete psát do celoserverového kanálu, protože vám bylo odebráno právo shout!")
			return false
		end
		-- zprava = zprava:sub(zprava:sub(2,2) == " " and 3 or 2, #zprava)
		return ch_core.chat("celoserverovy", jmeno, zprava:sub(2, -1), info_pos)
	elseif c == "_" then
		-- šepot
		-- zprava = zprava:sub(zprava:sub(2,2) == " " and 3 or 2, #zprava)
		return ch_core.chat("sepot", jmeno, zprava:sub(2, -1), info_pos)
	elseif c == "\"" then
		-- soukromá zpráva
		local i = string.find(zprava, " ")
		if not i then
			return true
		end
		local komu
		if i > 2 then
			local kandidati = {}
			local predpona = zprava:sub(2, i - 1)
			for prihlasovaci, _ in pairs(ch_core.online_charinfo) do
				local zobrazovaci = ch_core.prihlasovaci_na_zobrazovaci(prihlasovaci)
				if (#prihlasovaci >= #predpona and prihlasovaci:sub(1, #predpona) == predpona)
				   or (#zobrazovaci >= #predpona and zobrazovaci:sub(1, #predpona) == predpona) then
					table.insert(kandidati, prihlasovaci)
				end
			end
			if #kandidati > 1 then
				local s
				if #kandidati < 5 then
					s = "možnosti"
				else
					s = "možností"
				end
				ch_core.systemovy_kanal(jmeno, "CHYBA: Nejednoznačná předpona „"..predpona.."“ ("..#kandidati.." "..s..")")
				return true
			elseif #kandidati == 1 then
				komu = kandidati[1]
			else
				komu = predpona
			end
		else
			komu = ""
		end
		return ch_core.soukroma_zprava(jmeno, komu, zprava:sub(i + 1))
	else
		-- místní zpráva
		if c == "=" then
			zprava = zprava:sub(2, -1)
		end
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

	name_to_unignore = ch_core.jmeno_na_prihlasovaci(name_to_unignore)
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

--[[
	Vezme tabulku s údaji pro hráčský štítek a vygeneruje tabulku
	s atributy pro metodu player:set_nametag_attributes().
	Předaná tabulka musí obsahovat přinejmenším položku ["jmeno"]
	obsahující barevné jméno.
]]
function ch_core.process_player_nametag(data)
	local result = {color = nametag_color_normal_table} -- text, color, bgcolor
	-- data:
	--		- docasne_tituly = { [titul] = ?, [titul] = ? }
	--		- titul
	--		- jmeno -- musí být a musí obsahovat barvu
	--		- cet = { [1], [2], [3] } -- je-li, musí obsahovat barvu
	local parts = {}
	local priznak = false

	-- dočasné tituly
	for titul, _ in pairs(data.docasne_tituly or {}) do
		if not priznak then
			table.insert(parts, nametag_color_green)
			priznak = true
		end
		table.insert(parts, "*")
		table.insert(parts, titul)
		table.insert(parts, "*\n")
	end
	if not priznak and data.titul then
		-- stálý titul
		table.insert(parts, nametag_color_green)
		table.insert(parts, "*")
		table.insert(parts, titul)
		table.insert(parts, "*\n")
	end

	-- jméno (barevné)
	table.insert(parts, data.jmeno or "")

	-- čet
	if data.cet and data.cet[1] then
		table.insert(parts, ":\n")
		table.insert(parts, data.cet[1])
		if data.cet[2] then
			table.insert(parts, "\n")
			table.insert(parts, data.cet[2])
			if data.cet[3] then
				table.insert(parts, "\n")
				table.insert(data.cet[3])
			end
		end
		result.bgcolor = nametag_chat_bgcolor_table
	else
		result.bgcolor = nametag_nochat_bgcolor_table
	end
	result.text = table.concat(parts)
	return result
end

minetest.register_on_chat_message(on_chat_message)

minetest.override_chatcommand("me", {
	params = "<text>",
	description = "Pošle zprávu do základní kanálu četu. Funguje stejně jako přístupový znak „=“.",
	func = function(player_name, message)
		return on_chat_message(player_name, "="..message)
	end,
})

minetest.override_chatcommand("msg", {
	params = "<Jméno_Postavy> <text>",
	description = "Zašle soukromou zprávu v četu. Funguje stejně jako přístupový znak „\"“, ale vyžaduje zadání jména postavy.",
	func = function(player_name, text)
	return on_chat_message(player_name, "\"" .. text)
	end,
})

minetest.register_chatcommand("doslech", {
	params = "[<metrů>]|uložit",
	description = "Nastaví omezený doslech v chatu. Hodnota musí být celé číslo v rozsahu 0 až 65535. Bez parametru nastaví vypíše stávající hodnoty, s parametrem „uložit“ uloží aktuální doslech jako výchozí.",
	privs = { shout = true },
	func = function(player_name, param)
		local online_charinfo = ch_core.online_charinfo[player_name]
		if not online_charinfo then
			return false, "Vnitřní chyba!"
		end
		local aktualni_doslech = online_charinfo.doslech
		local offline_charinfo = ch_core.offline_charinfo[player_name]
		local vychozi_doslech = offline_charinfo and offline_charinfo.doslech
		if param == "" then
			ch_core.systemovy_kanal(player_name, "Aktuální doslech: "..aktualni_doslech.." m, výchozí doslech (po přihlášení): "..(vychozi_doslech and (vychozi_doslech.." m") or "neznámý"))
			return true
		elseif param == "uložit" or param == "ulozit" then
			offline_charinfo = ch_core.get_offline_charinfo(player_name)
			offline_charinfo.doslech = online_charinfo.doslech
			ch_core.save_offline_charinfo(player_name, {"doslech"})
			ch_core.systemovy_kanal(player_name, "Doslech: "..aktualni_doslech.." m nastaven jako výchozí po přihlášení do hry.")
			return true
		else
			return ch_core.set_doslech(player_name, param)
		end
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

minetest.register_chatcommand("kdojsem", {
	description = "Vypíše zobrazované jméno postavy (včetně případných barev).",
	privs = {},
	func = function(player_name, param)
		if player_name then
			local vysl
			local offline_charinfo = ch_core.offline_charinfo[player_name]
			if offline_charinfo then
				vysl = offline_charinfo.barevne_jmeno or (color_reset..(offline_charinfo.jmeno or player_name))
			else
				vysl = color_reset..player_name
			end
			vysl = vysl..color_systemovy.."\n(přihlašovací jméno: "..player_name..")"
			ch_core.systemovy_kanal(player_name, vysl)
			return true
		else
			return false
		end
	end,
})

minetest.send_join_message = function(player_name)
	local online_charinfo = ch_core.get_joining_online_charinfo(player_name)
	local supported_lang_code = ch_core.supported_lang_codes[online_charinfo.lang_code or ""]
	local message = "Připojila se postava: "..ch_core.prihlasovaci_na_zobrazovaci(player_name)
	if not supported_lang_code then
		message = message.." [*klient postavy má nastaven nepodporovaný jazyk, bude odpojen*]"
	end

	return ch_core.systemovy_kanal("", message)
end
minetest.send_leave_message = function(player_name, is_timedout)
	return ch_core.systemovy_kanal("", "Odpojila se postava: "..ch_core.prihlasovaci_na_zobrazovaci(player_name))
end

-- /info_o
local function info_o(player_name, param)
	local admin_name = player_name
	player_name = ch_core.jmeno_na_prihlasovaci(param)
	local view_name = ch_core.prihlasovaci_na_zobrazovaci(player_name)
	local offline_charinfo = ch_core.offline_charinfo[player_name]
	if not offline_charinfo then
		minetest.chat_send_player(admin_name, "*** Nejsou uloženy žádné informace o "..view_name..".")
		return true
	end
	local online_charinfo = ch_core.online_charinfo[player_name] -- may be nil!
	local result = {"*** Informace o "..view_name..":"}
	local past_playtime = offline_charinfo.past_playtime or 0
	local past_ap_playtime = offline_charinfo.past_ap_playtime or 0
	if online_charinfo then
		local current_playtime = 1.0e-6 * (minetest.get_us_time() - online_charinfo.join_timestamp)
		table.insert(result, "\n* Odehraná doba [s]: "..current_playtime.." nyní + "..past_playtime.." dříve")
	else
		table.insert(result, "\n* Odehraná doba [s]: "..past_playtime)
	end
	table.insert(result, "\n* Aktivní odehraná doba: "..past_ap_playtime.." s = "..(past_ap_playtime / 3600).." hod.")
	table.insert(result, "\n* Úroveň "..offline_charinfo.ap_level..", "..offline_charinfo.ap_xp.." bodů")
	if ch_core.ap_get_level then
		local level_def = ch_core.ap_get_level(offline_charinfo.ap_level)
		table.insert(result, " z "..level_def.count..", "..(level_def.base + offline_charinfo.ap_xp).." celkem")
	end
	table.insert(result, "\n* Doslech: aktuální "..(online_charinfo and online_charinfo.doslech and online_charinfo.doslech.." m" or "neznámý")..", výchozí "..(offline_charinfo.doslech and offline_charinfo.doslech.." m" or "neznámý"))

	minetest.chat_send_player(admin_name, table.concat(result))
	return true
end


minetest.register_chatcommand("info_o", {
	params = "<Jméno postavy>",
	description = "Vypíše systémové informace o postavě",
	privs = { server = true },
	func = info_o,
})

-- log all chatcommands except /msg

minetest.register_on_chatcommand(function(name, command, params)
	if command ~= "msg" then
		minetest.log("action", name.."$ /"..command.." "..params)
	end
end)

ch_core.close_submod("chat")
