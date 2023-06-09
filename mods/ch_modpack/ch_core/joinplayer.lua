ch_core.open_submod("joinplayer", {data = true, formspecs = true, lib = true, nametag = true, pryc = true})

local F = minetest.formspec_escape

local function get_invalid_locale_formspec(invalid_locale)
	if invalid_locale == nil or invalid_locale == "" then
		invalid_locale = "en"
	end

	local result = {
		"formspec_version[4]",
		"size[12,14]",
		"label[0.375,0.5;česky:]",
		"textarea[0.375,0.7;11,4;cz;;",
		F("Připojili jste se na server Český hvozd. Server detekoval, že váš klient je nastaven na lokalizaci „"..invalid_locale.."“, která není na tomto serveru podporována. Abyste mohli pokračovat ve hře, musíte nastavit svého klienta na lokalizaci „cs“ nebo „sk“. Postup je následující:\n\n"),
		F("1. Odpojte se ze hry a v hlavním menu na kartě Settings (Nastavení) klikněte na All Settings (Všechna nastavení).\n\n"),
		F("2. Ve skupině „Client and Server“ (Klient a server) nastavite „Language“ („Jazyk“) na hodnotu „cs“ nebo „sk“.\n\n"),
		F("3. Úplně restartujte klienta (vypněte ho a znovu zapněte).\n\n"),
		F("4. Znovu se pokuste připojit na Český hvozd.\n\n"),
		F("Pokud se vám tato zpráva zobrazuje, přestože máte uvedené nastavení správně, je to pravděpodobně chyba na straně serveru. Kontakt pro nahlášení takové chyby najdete na stránkách http://ceskyhvozd.svita.cz\n"),
		"]",
		"label[0.375,5.0;slovensky:]",
		"textarea[0.375,5.2;11,4;sk;;",
		F("Pripojili ste sa na server Český hvozd. Server detekoval, že váš klient je nastavený na lokalizáciu „"..invalid_locale.."“, ktorá nie je na tomto serveri podporovaná. Aby ste mohli pokračovať v hre, musíte nastaviť svojho klienta na lokalizáciu „sk“ alebo „cs“. Postup je nasledujúci:\n\n"),
		F("1. Odpojte sa zo hry a v hlavnom menu na karte Settings (Nastavenia) kliknite na All Settings (Všetky nastavenia).\n\n"),
		F("2. V skupine „Client and Server“ (Klient a server) nastavte „Language“ („Jazyk“) na hodnotu „sk“ alebo „cs“.\n\n"),
		F("3. Úplne reštartujte klienta (vypnite ho a znovu zapnite).\n\n"),
		F("4. Znova sa pokúste pripojiť na Český hvozd.\n\n"),
		F("Ak sa vám táto správa zobrazuje, hoci máte uvedené nastavenie správne, je to pravdepodobne chyba na strane servera. Kontakt pre nahlásenie takejto chyby nájdete na stránkach http://ceskyhvozd.svita.cz\n"),
		"]",
		"label[0.375,9.5;English:]",
		"textarea[0.375,9.7;11,3;en;;",
		F("You have connected to the Český Hvozd Server. The server detected that your client is set to localization \""..invalid_locale.."\" that is not supported on this server. To continue playing you must set up your client to one of the localizations \"cs\" or \"sk\". Please, bear in mind that playing on this server requires at least basic ability to read and write in Czech or Slovak language.\n\n"),
		F("The way to set up the client localization is as follows:\n\n"),
		F("1. Disconnect the client and in the main menu on the Settings tab click to \"All Settings\" button.\n\n"),
		F("2. In the group \"Client and Server\" set \"Language\" to one of the values \"cs\" or \"sk\".\n\n"),
		F("3. Completely restart your client (close it and start it again).\n\n"),
		F("4. Try to connect to Český hvozd again.\n\n"),
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

local function on_newplayer(player)
	local player_name = player:get_player_name()
	minetest.log("action", "[ch_core] New player '"..player_name.."'");
	ch_core.delete_offline_charinfo(player_name)
	local offline_charinfo = ch_core.get_offline_charinfo(player_name)
	offline_charinfo.pending_registration_type = "new"
end

local function after_joinplayer(player_name)
	local player = minetest.get_player_by_name(player_name)
	if player then
		local controls = player:get_player_control()
		if not controls.aux1 then
			player:set_properties({stepheight = 0.3})
		end
		player:set_clouds({density = 0}) -- disable clouds
	end
end

local function on_joinplayer(player, last_login)
	local player_name = player:get_player_name()
	local online_charinfo = ch_core.get_joining_online_charinfo(player_name)
	local offline_charinfo = ch_core.get_offline_charinfo(player_name)

	if online_charinfo.formspec_version < 4 then
		minetest.disconnect_player(player_name, "Váš klient je příliš starý. Pro připojení k tomuto serveru prosím použijte Minetest 5.5.0 nebo novější.")
		return true
	end
	local lang_code = online_charinfo.lang_code
	if not ch_core.supported_lang_codes[lang_code] then
		if minetest.check_player_privs(player_name, "server") then
			minetest.after(0.2, function()
				minetest.chat_send_player(player_name, "VAROVÁNÍ: U vašeho klienta byla detekována nepodporovaná lokalizace '"..lang_code.."'!")
			end)
		else
			minetest.after(0.2, function()
				ch_core.show_formspec(player_name, "ch_core:invalid_locale", get_invalid_locale_formspec(lang_code), invalid_locale_formspec_callback, {}, {})
			end)
			return true
		end
	end

	player:set_nametag_attributes(ch_core.compute_player_nametag(online_charinfo, offline_charinfo))
	player:hud_set_flags({minimap = false, minimap_radar = false})
	minetest.after(0.5, function() ch_core.set_pryc(player_name, {no_hud = true, silently = true}) end)
	minetest.after(2, after_joinplayer, player_name)
	return true
end

--[[
local function on_leaveplayer(player)
	local player_name = player:get_player_name()
end
]]

minetest.register_on_newplayer(on_newplayer)
minetest.register_on_joinplayer(on_joinplayer)
-- minetest.register_on_leaveplayer(on_leaveplayer)

ch_core.close_submod("joinplayer")
