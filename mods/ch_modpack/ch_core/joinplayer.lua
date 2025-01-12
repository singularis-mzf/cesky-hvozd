ch_core.open_submod("joinplayer", {chat = true, data = true, events = true, formspecs = true, lib = true, nametag = true, pryc = true})

local F = minetest.formspec_escape
local ifthenelse = ch_core.ifthenelse

ch_core.register_event_type("joinplayer", {
	-- ignoruje postavy, které budou odpojeny, a turistické postavy
	description = "vstup do hry",
	access = "players",
	default_text = "Připojila se postava: {PLAYER}",
	chat_access = "public",
})

ch_core.register_event_type("joinplayer_new", {
	-- jen turistické postavy, kromě těch, které budou odpojeny
	description = "vstup do hry (tur.p.)",
	access = "players",
	default_text = "Připojila se turistická postava: {PLAYER}",
	chat_access = "public",
})

ch_core.register_event_type("joinplayer_for_admin", {
	-- všechny postavy
	description = "vstup do hry*",
	access = "admin",
	chat_access = "admin",
})

ch_core.register_event_type("leaveplayer", {
	-- ignoruje postavy, které budou odpojeny
	description = "odchod ze hry",
	access = "admin",
	default_text = "Odpojila se postava: {PLAYER}",
	chat_access = "public",
})

ch_core.register_event_type("leaveplayer_for_admin", {
	-- všechny postavy
	description = "odchod ze hry*",
	access = "admin",
	chat_access = "admin",
	default_text = "{PLAYER} se odpojil/a ze hry",
})

local function get_invalid_locale_formspec(invalid_locale, protocol_version)
	if invalid_locale == nil or invalid_locale == "" then
		invalid_locale = "en"
	end

	local krok1_cs, krok1_sk, krok1_en
	local krok2_cs, krok2_sk, krok2_en
	if protocol_version < 43 then
		krok1_cs = F("1. Odpojte se ze hry a v hlavním menu na kartě Settings (Nastavení) klikněte na All Settings (Všechna nastavení).\n\n")
		krok1_sk = F("1. Odpojte sa zo hry a v hlavnom menu na karte Settings (Nastavenia) kliknite na All Settings (Všetky nastavenia).\n\n")
		krok1_en = F("1. Disconnect the client and in the main menu on the Settings tab click to \"All Settings\" button.\n\n")

		krok2_cs = F("2. Ve skupině „Client and Server“ (Klient a server) nastavite „Language“ („Jazyk“) na hodnotu „cs“ nebo „sk“.\n\n")
		krok2_sk = F("2. V skupine „Client and Server“ (Klient a server) nastavte „Language“ („Jazyk“) na hodnotu „sk“ alebo „cs“.\n\n")
		krok2_en = F("2. In the group \"Client and Server\" set \"Language\" to one of the values \"cs\" or \"sk\".\n\n")
	else
		-- Minetest >= 5.8.0
		krok1_cs = F("1. Odpojte se ze hry a klikněte na ozubené kolo v pravém horním rohu menu (Nastavení).\n\n")
		krok1_sk = F("1. Odpojte sa zo hry a kliknite kliknite na ozubené koleso v pravom hornom rohu rozhrania (Nastavenia).\n\n")
		krok1_en = F("1. Disconnect the client and click the gear in the top right corner of the interface (Settings).\n\n")

		krok2_cs = F("2. Ve skupině „User Interfaces“ (Užívateľské rozhranie) nebo „Accessibility“ nastavite „Language“ („Jazyk“) na hodnotu „Česky [cs]“ nebo „Slovenčina [sk]“.\n\n")
		krok2_sk = F("2. V skupine „User Interfaces“ (Uživatelská rozhraní) lebo „Accessibility“ nastavte „Language“ („Jazyk“) na hodnotu „Slovenčina [sk]“ lebo „Česky [cs]“.\n\n")
		krok2_en = F("2. In the group \"User Interfaces\" or \"Accessibility\" set \"Language\" to one of the values \"Česky [cs]\" or \"Slovenčina [sk]\".\n\n")
	end

	local result = {
		"formspec_version[4]",
		"size[12,14]",
		"label[0.375,0.5;česky:]",
		"textarea[0.375,0.7;11,4;cz;;",
		F("Připojili jste se na server Český hvozd. Server detekoval, že váš klient je nastaven na lokalizaci „"..invalid_locale.."“, která není na tomto serveru podporována. Abyste mohli pokračovat ve hře, musíte nastavit svého klienta na lokalizaci „cs“ nebo „sk“. Postup je následující:\n\n"),
		krok1_cs,
		krok2_cs,
		F("3. Úplně restartujte klienta (vypněte ho a znovu zapněte).\n\n"),
		F("4. Znovu se pokuste připojit na Český hvozd.\n\n"),
		F("Pokud se vám tato zpráva zobrazuje, přestože máte uvedené nastavení správně, je to pravděpodobně chyba na straně serveru. Kontakt pro nahlášení takové chyby najdete na stránkách http://ceskyhvozd.svita.cz\n"),
		"]",
		"label[0.375,5.0;slovensky:]",
		"textarea[0.375,5.2;11,4;sk;;",
		F("Pripojili ste sa na server Český hvozd. Server detekoval, že váš klient je nastavený na lokalizáciu „"..invalid_locale.."“, ktorá nie je na tomto serveri podporovaná. Aby ste mohli pokračovať v hre, musíte nastaviť svojho klienta na lokalizáciu „sk“ alebo „cs“. Postup je nasledujúci:\n\n"),
		krok1_sk,
		krok2_sk,
		F("3. Úplne reštartujte klienta (vypnite ho a znovu zapnite).\n\n"),
		F("4. Znova sa pokúste pripojiť na Český hvozd.\n\n"),
		F("Ak sa vám táto správa zobrazuje, hoci máte uvedené nastavenie správne, je to pravdepodobne chyba na strane servera. Kontakt pre nahlásenie takejto chyby nájdete na stránkach http://ceskyhvozd.svita.cz\n"),
		"]",
		"label[0.375,9.5;English:]",
		"textarea[0.375,9.7;11,3;en;;",
		F("You have connected to the Český Hvozd Server. The server detected that your client is set to localization \""..invalid_locale.."\" that is not supported on this server. To continue playing you must set up your client to one of the localizations \"cs\" or \"sk\". Please, bear in mind that playing on this server requires at least basic ability to read and write in Czech or Slovak language.\n\n"),
		F("The way to set up the client localization is as follows:\n\n"),
		krok1_en,
		krok2_en,
		F("3. Completely restart your client (close it and start it again).\n\n"),
		F("4. Try to connect to Český Hvozd again.\n\n"),
		F("If you have the Language setting set correctly, but this message still appears, it is probably a server-side bug. The contact information needed to report such bug is available in Czech on the website https://ceskyhvozd.svita.cz\n"),
		"]",
		"button_exit[1,13;10,0.75;zavrit;Odpojit / Odpojiť / Disconnect]",
	}
	return table.concat(result)
end

local function invalid_locale_formspec_callback(custom_state, player, formname, fields)
	if fields.quit then
		minetest.disconnect_player(player:get_player_name(), "Klient je nastavený na jazyk nepodporovaný na straně serveru.")
	end
end

local new_player_texts = {
	{
		title = "Vítejte na serveru Český hvozd!",
		formspec_text = F("V nabídce vlevo si zvolte téma, které vás zajímá. Kliknutím na tlačítko „X“ toto okno zavřete a vstoupíte do herního světa."..
			" Později ho můžete znovu otevřít příkazem „/novinky“ nebo tím, že se odpojíte a znovu připojíte.\n\n"..
			"Při objevování světa se vám mohou hodit přemísťovací příkazy „/začátek“, „/doma“ a „/domů“ a možnost běhat rychle "..
			"(pokud to neumíte, doporučuji nejdřív navštívit areál „Úvod do Minetestu“). "..
			"Další informace o serveru, včetně mapy herního světa a instrukcí, jak získat práva potřebná "..
			"pro plnohodnotnou hru, najdete na webu:\n\nhttps://ceskyhvozd.svita.cz\n\n"..
			"Přeji příjemnou a zajímavou hru!\n-- Administrace\n"),
	}, {
		title = "Co je Český hvozd za server?",
		formspec_text = F("Český hvozd je dělnicko-kouzelnický server s československou tematikou, plně lokalizovaný do češtiny, "..
			"který nabízí relativně civilizované prostředí pro dospělé české a slovenské hráče/ky "..
			"a spoustu mírových činností, které zde budete moci dělat.\n\nServer spravuje Singularis "..
			"prostřednictvím postavy jménem Administrace.\n\n"..
			"Český hvozd byl otevřen pro veřejnost 3. prosince 2022 po zruba šesti měsících vývoje. "..
			"Nikdy na něm nebylo mnoho hráčů/ek, takže hra zde většinou připomíná spíš "..
			"hru v režimu jednoho hráče/ky, jen s občasným setkáním s druhým hráčem/kou.\n\n"..
			"Kromě lokalizace (která vám snad umožní cítit se tu jako doma) je hlavní předností "..
			"spousta technických vylepšení a úprav implementovaných speciálně pro tento server, s nimiž se během hry setkáte "..
			"(např. ovládání herního četu)."),
	}, {
		title = "Jaká tu platí pravidla?",
		formspec_text = F("Nejdůležitější pravidla lze shrnout takto:\n\n"..
			"• Snaž se jít ostatním dobrým příkladem.\n\n"..
			"• Snaž se, aby sis hru co nejlépe užil jak ty, tak všichni ostatní, kdo tu hrají.\n\n"..
			"• Respektuj pokyny Administrace a zaměření serveru.\n\n"..
			"Toto jsou nejdůležitější pravidla, která platí pro celý server. "..
			"Pro jednotlivá místa a činnosti platí další pravidla, která se ovšem dozvíš postupně, např. na cedulích ve hře."),
	}, {
		title = "Co mám teď dělat?",
		formspec_text = F("Záleží na tom, jak dobře ovládáte Minetest jako takový.\n\nPokud jste začátečník/ice, "..
			"nejlépe uděláte, když nejprve navštívíte výukový areál Úvod do Minetestu (hned vedle Začátku), "..
			"tam se naučíte ovládání hry, což vám ušetří spoustu potíží později. Přinejmenším byste se měli naučit "..
			"ovládání herního četu\n\n"..
			"Pokud ovládání hry zvládáte, začněte průzkumem herního světa — můžete tu cestovat (pěšky, pomocí cestovní budky, "..
			"vlakem, tramvají či na kole), "..
			"a pokud potkáte nějakého dalšího hráče/ku, můžete s ní/m komunikovat. V okně inventáře si prohlédněte paletu "..
			"předmětů a ostatní karty (zejména Nastavení).\n\n"..
			"K návštěvě určitě doporučuji Výstaviště, kde jsou vystaveny různé bloky a tvary, které lze na tomto serveru používat ke stavění.\n\n"..
			"Stavět, těžit, obchodovat nebo se usadit budete moci, teprve až si zvolíte dělnický nebo kouzelnický styl hry a až "..
			"Administrace vaši postavu schválí (podrobnější informace na webu)."),
	}, {
		title = "Ovládání četu (chatu)",
		formspec_text = F("Okno četu otevřete klávesou T (pro napsání jedné zprávy) nebo klávesou F10 (zůstane otevřeno do dalšího stisku F10).\n\n"..
			"Normální zprávy, které do četu zadáte, uvidí převážně jen postavy v okolí 50 metrů kolem vás. "..
			"Pokud má vaše zpráva dojít všem hráčským postavám ve hře, musíte před ni napsat znak „!“, jedná se o takzvaný celoserverový kanál. "..
			"Normální zprávy (základní kanál) slouží primárně pro komunikaci na krátkou vzdálenost.\n\n"..
			"Soukromou zprávu na jinou postavu ve hře zašlete tak, že před text zprávy vložíte uvozovku a jednoznačnou předponu jména postavy. "..
			"Např. zprávu Administraci můžete poslat zadáním:\n\n\"Adm ahoj\n\n"..
			"Pokud vámi zadaná předpona nebude jednoznačná, systém zprávu neodešle a zobrazí vám varování, takže budete moci svoji chybu napravit.\n\n"..
			"Pokud vámi zadaná zpráva začíná znakem „/“, pochopí ji server jako příkaz a tento příkaz vykoná. "..
			"Příkazy v četu slouží k vyvolání různých akcí ve hře.\n\nChcete-li napsat zprávu na postavu, která není zrovna ve hře, "..
			"použijte herní poštu (dostupnou příkazem „/pošta“ nebo tlačítkem v inventáři). "..
			"Herní pošta má ovládání podobné jednoduchému e-mailovému klientovi."),
	}, {
		title = "Nefungují mi háčky a čárky, co s tím?",
		formspec_text = F("Máte-li problém s psaním diakritiky, pište bez ní. Všechny příkazy, jména postav a většinou i parametry příkazů "..
			"lze zadat bez diakritiky a systém si s tím poradí (tzn. např. místo /začátek stačí psát /zacatek)."),
	}, {
		title = "Jsou dostupné zdrojové kódy módů?",
		formspec_text = F("Ano, aktuální a úplný zdrojový kód všech módů je dostupný v repozitáři:\n\nhttps://github.com/singularis-mzf/cesky-hvozd\n\n"..
			"Veškerý zdrojový kód je svobodný, takže ho (v případě zájmu) můžete v mezích svých technických dovedností využít na vlastních serverech.\n\n"..
			"Server používá upravené verze módů podléhajících licenci AGPLv3 a jiným svobodným licencím."),
	}
}

local function dump_privs(privs)
	local names = {}
	for k, v in pairs(privs) do
		if v then
			table.insert(names, k)
		end
	end
	table.sort(names, function(a, b) return a < b end)
	return "["..#names.."]("..table.concat(names, ",")..")"
end


local function get_new_player_formspec(custom_state)
	local formspec = {
		ch_core.formspec_header({formspec_version = 5, size = {18, 10}, auto_background = true}),
		"button_exit[16.8,0.25;0.8,0.8;zavrit;X]"..
		"tooltip[zavrit;zavřít]"..
		"style_type[table;font=italic]"..
		"tablecolumns[text]"..
		"table[0.5,0.5;8,9.1;volba;",
		F(new_player_texts[1].title),
	}
	local volba = custom_state.volba
	local heading_color = minetest.get_color_escape_sequence("#00FF00")
	for i = 2, #new_player_texts do
		table.insert(formspec, ","..F(new_player_texts[i].title))
	end
	table.insert(formspec, ";"..volba.."]"..
		"label[9,0.75;"..heading_color..F(new_player_texts[volba].title).."]"..
		"box[8.9,1.15;8.7,8.45;#00000099]"..
		"textarea[9,1.25;8.5,8.25;;;"..new_player_texts[volba].formspec_text.."\n]")
	return table.concat(formspec)
end

local function new_player_formspec_callback(custom_state, player, formname, fields)
	if fields.quit then return end
	if fields.volba then
		local event = minetest.explode_table_event(fields.volba)
		if event.type == "CHG" or event.type == "DCL" then
			custom_state.volba = assert(tonumber(event.row))
			return get_new_player_formspec(custom_state)
		end
	end
end

local function on_newplayer(player)
	local player_name = player:get_player_name()
	minetest.log("action", "[ch_core] New player '"..player_name.."'");
	ch_core.delete_offline_charinfo(player_name)
	local offline_charinfo = ch_core.get_offline_charinfo(player_name)
	offline_charinfo.pending_registration_type = "new"
end

local function after_joinplayer(player_name, join_timestamp)
	local online_charinfo = ch_core.online_charinfo[player_name]
	local player = minetest.get_player_by_name(player_name)
	if player == nil or online_charinfo == nil or online_charinfo.join_timestamp ~= join_timestamp then
		return
	end
	local controls = player:get_player_control()
	if not controls.aux1 then
		player:set_properties({stepheight = 0.3})
	end
	player:set_clouds({density = 0}) -- disable clouds
	--[[
		5.5.x => formspec_version = 5, protocol_version = 40
		5.6.x => formspec_version = 6, protocol_version = 41
		5.7.x => formspec_version = 6, protocol_version = 42
		5.8.0 => formspec_version = 7, protocol_version = 43
		5.9.0 => formspec_version = ?, protocol_version = ?
		5.10.0 => formspec_version = 8, protocol_version = 46
	]]
	local online_charinfo = ch_core.online_charinfo[player_name]
	if online_charinfo.protocol_version < 42 and online_charinfo.protocol_version ~= 0 then
		local client_version
		if online_charinfo.protocol_version == 40 then
			client_version = "5.5.x"
		elseif online_charinfo.protocol_version == 41 then
			client_version = "5.6.x"
		else
			client_version = "?.?.?"
		end
		ch_core.systemovy_kanal(player_name, minetest.get_color_escape_sequence("#cc5257").."VAROVÁNÍ: Váš klient je zastaralý! Zdá se, že používáte klienta Minetest "..client_version..", který nepodporuje některé moderní vlastnosti hry využívané na Českém hvozdu. Hra vám bude fungovat, ale některé bloky se nemusejí zobrazit správně. Pro správné zobrazení doporučujeme přejít na Minetest 5.7.0 nebo novější, máte-li tu možnost.")
	end

	-- Vypsat posledních 5 přihlášených registrovaných postav:
	-- (přeskočit vlastní postavu a předváděcí postavy)
	local last_logins = ch_core.get_last_logins(true, {[player_name] = true, Jan_Rimbaba = true, Zofia_Slivka = true})
	if #last_logins > 0 then
		local output = {
			"INFORMACE: Registrované postavy objevivší se ve hře v poslední době: ",
		}
		-- local last_players = {}
		for i, info in ipairs(last_logins) do
			local viewname = ch_core.prihlasovaci_na_zobrazovaci(info.player_name, true)
			local kdy = info.last_login_before
			if kdy < 0 then
				kdy = "???"
			elseif kdy == 0 then
				kdy = "dnes"
			elseif kdy == 1 then
				kdy = "včera"
			else
				kdy = "před "..kdy.." dny"
			end
			table.insert(output, ch_core.colors.light_green..viewname..ch_core.colors.white.." ("..kdy..")")
			table.insert(output, ", ")
			if i == 5 then break end
		end
		output[#output] = ""
		ch_core.systemovy_kanal(player_name, table.concat(output))
	end

	minetest.log("action", "Player "..player_name.." after_joinplayer privs = "..dump_privs(minetest.get_player_privs(player_name)))
end

local event_types = {"public_announcement", "announcement", "custom"}

local function after_joinplayer_5min(player_name, join_timestamp)
	local online_charinfo = ch_core.online_charinfo[player_name]
	local offline_charinfo = ch_core.offline_charinfo[player_name] or {}
	if online_charinfo == nil or online_charinfo.join_timestamp ~= join_timestamp or minetest.get_player_by_name(player_name) == nil then
		return -- player probably already logged out
	end
	local cas = ch_time.aktualni_cas()
	local dnes = cas:YYYY_MM_DD()
	local last_ann_shown_date = offline_charinfo.last_ann_shown_date or "1970-01-01"
	if last_ann_shown_date >= dnes then return end
	local events = ch_core.get_events_for_player(player_name, event_types, 10, last_ann_shown_date)
	if #events > 0 then
		local output = {}
		local counts_by_description = {}
		for _, record in ipairs(events) do
			local old_count = counts_by_description[record.description] or 0
			counts_by_description[record.description] = old_count + 1
			if old_count < 3 then
				table.insert(output, 1, minetest.get_color_escape_sequence("#6666FF").."<"..record.description.."> ("..record.time:sub(1, 10)..") "..
					minetest.get_color_escape_sequence(record.color)..record.text)
			end
		end
		ch_core.systemovy_kanal(player_name, table.concat(output, "\n"))
	end
	offline_charinfo.last_ann_shown_date = dnes
	ch_core.save_offline_charinfo(player_name, "last_ann_shown_date")
end

local function on_joinplayer_pomodoro(player, player_name, online_charinfo)
	local oc = ch_core.online_charinfo
	local now = minetest.get_us_time()
	local priv = {ch_registered_player = true}
	local prev_leave_timestamp = online_charinfo.prev_leave_timestamp
	if prev_leave_timestamp ~= nil and now - prev_leave_timestamp < 3600000000 then
		minetest.log("warning", "on_joinplayer_pomodoro() not activated, because the player "..player_name.." has returned after "..math.floor((now - prev_leave_timestamp) / 1000000).." seconds")
		return false -- relogin too early
	end
	if not minetest.check_player_privs(player_name, priv) then
		minetest.log("warning", "on_joinplayer_pomodoro() not activated, because the player "..player_name.." is not registered")
		return false -- the new player is not registered
	end
	for k, other_online_charinfo in pairs(oc) do
		if k ~= player_name and minetest.check_player_privs(player_name, priv) then
			local ap_modify_timestamp = other_online_charinfo.ap_modify_timestamp
			if ap_modify_timestamp == nil or now - ap_modify_timestamp < 600000000 then
				minetest.log("warning", "on_joinplayer_pomodoro() not activated, because of already online player "..k)
				return false -- the new player is not alone
			else
				minetest.log("warning", "on_joinplayer_pomodoro() not broken, because the online player "..k.." has been inactive for "..math.floor((now - ap_modify_timestamp) / 1000000).."seconds.")
			end
		end
	end
	ch_time.herni_cas_nastavit(6, 0, 0)
	return true
end

function ch_core.show_new_player_formspec(player_name)
	if minetest.get_player_by_name(player_name) == nil then
		return false
	end
	local custom_state = {volba = 1}
	ch_core.show_formspec(player_name, "ch_core:uvitani", get_new_player_formspec(custom_state), new_player_formspec_callback, custom_state, {})
end

local function on_joinplayer(player, last_login)
	local player_name = player:get_player_name()
	local online_charinfo = ch_core.get_joining_online_charinfo(player_name)
	local offline_charinfo = ch_core.get_offline_charinfo(player_name)
	local news_role = assert(online_charinfo.news_role)
	local lang_code = online_charinfo.lang_code
	local protocol_version = online_charinfo.protocol_version

	ch_core.add_event("joinplayer_for_admin", "{PLAYER} se připojil/a do hry (NR="..news_role..", PV="..protocol_version..")", player_name)

	if news_role == "disconnect" then
		minetest.disconnect_player(player_name, "Váš klient je příliš starý. Pro připojení k tomuto serveru prosím použijte Minetest 5.7.0 nebo novější. Verze 5.6.0 a 5.6.1 budou fungovat s omezeními.")
		return true
	elseif news_role == "invalid_name" then
		minetest.disconnect_player(player_name, "Neplatné přihlašovací jméno '"..player_name.."'. Seznamte se, prosím, s pravidly serveru pro jména, nebo použijte jen písmena anglické abecedy.")
		return true
	end
	if news_role == "invalid_locale" then
		if minetest.check_player_privs(player_name, "server") then
			minetest.after(0.2, function()
				minetest.chat_send_player(player_name, "VAROVÁNÍ: U vašeho klienta byla detekována nepodporovaná lokalizace '"..lang_code.."'!")
			end)
		else
			minetest.after(0.2, function()
				ch_core.show_formspec(player_name, "ch_core:invalid_locale", get_invalid_locale_formspec(lang_code, protocol_version), invalid_locale_formspec_callback, {}, {})
			end)
			return true
		end
	elseif news_role == "new_player" then
		minetest.after(0.2, ch_core.show_new_player_formspec, player_name)
	end

	player:set_nametag_attributes(ch_core.compute_player_nametag(online_charinfo, offline_charinfo))
	player:hud_set_flags({minimap = false, minimap_radar = false})

	-- Reset the creative priv (set for the new characters)
	local privs = minetest.get_player_privs(player_name)
	minetest.log("action", "Player "..player_name.." joined with privs = "..dump_privs(privs))
	if privs.ch_registered_player then
		if privs.creative then
			privs.creative = nil
			minetest.set_player_privs(player_name, privs)
			minetest.log("action", "creative priv reset on join for "..player_name)
		end
	elseif not privs.creative then
		privs.creative = true
		minetest.set_player_privs(player_name, privs)
		minetest.log("action", "creative priv set on join for "..player_name)
	end

	-- Set the inventory size
	ch_core.extend_player_inventory(player_name, offline_charinfo.extended_inventory == 1)

	-- Pomodoro functionality for single-players:
	on_joinplayer_pomodoro(player, player_name, online_charinfo)
	--

	assert(online_charinfo.join_timestamp)
	minetest.after(2, after_joinplayer, player_name, online_charinfo.join_timestamp)
	minetest.after(5 * 60, after_joinplayer_5min, player_name, online_charinfo.join_timestamp)
	return true
end

minetest.send_join_message = function(player_name)
	local online_charinfo = ch_core.get_joining_online_charinfo(player_name)
	-- local lang_code = assert(online_charinfo.lang_code)
	local news_role = assert(online_charinfo.news_role)
	-- local protocol_version = assert(online_charinfo.protocol_version)

	if news_role ~= "disconnect" and news_role ~= "invalid_name" and news_role ~= "invalid_locale" then
		ch_core.add_event(ifthenelse(news_role ~= "new_player", "joinplayer", "joinplayer_new"), nil, player_name)
	end
	return true
end

local function on_leaveplayer(player)
	local player_name = player:get_player_name()
	local privs = minetest.get_player_privs(player_name)

	ch_core.add_event("leaveplayer_for_admin", nil, player_name)

	if privs.ch_registered_player and privs.creative then
		privs.creative = nil
		minetest.set_player_privs(player_name, privs)
		minetest.log("action", "creative priv reset on leave for "..player_name)

		privs = minetest.get_player_privs(player_name) -- update variable
	end
	minetest.log("action", "Player "..player_name.." leaved with privs = "..dump_privs(privs))
end

minetest.send_leave_message = function(player_name, is_timedout)
	local online_charinfo = ch_core.get_leaving_online_charinfo(player_name)
	local news_role = assert(online_charinfo.news_role)

	if news_role ~= "disconnect" and news_role ~= "invalid_name" and news_role ~= "invalid_locale" then
		ch_core.add_event("leaveplayer", nil, player_name)
	end
	return true
end

minetest.register_on_newplayer(on_newplayer)
minetest.register_on_joinplayer(on_joinplayer)
minetest.register_on_leaveplayer(on_leaveplayer)

ch_core.close_submod("joinplayer")
