ch_base.open_mod(core.get_current_modname())

local worldpath = core.get_worldpath()
local datapath = worldpath.."/ch_playerdata"
local playerlist_path = worldpath.."/ch_data_players"
local storage = core.get_mod_storage()
local old_online_charinfo = {} -- uchovává online_charinfo[] po odpojení postavy
local players_list, players_set = {}, {} -- seznam/množina všech známých hráčských postav (pro offline_charinfo)
local lc_to_player_name = {} -- pro jména existujících postav lowercase => loginname
local current_format_version = 2

ch_data = {
	online_charinfo = {},
	offline_charinfo = {},
	supported_lang_codes = {cs = true, sk = true},
	-- Tato funkce může být přepsána. Rozhoduje, zda zadané jméno postavy je přijatelné.
	is_acceptable_name = function(player_name) return true end,
	initial_offline_charinfo = {
		-- int (> 0) -- pro [ch_core/ap], udává aktuální úroveň postavy
		ap_level = 1, -- musí být > 0
		-- int (> 0) -- pro [ch_core/ap], udává verzi systému AP (pro upgrade)
		ap_version = 1,
		-- int (>= 0) -- pro [ch_core/ap], udává celkový počet bodů aktivity postavy
		ap_xp = 0,
		-- int {0, 1} -- 0 = nic, 1 = předměty házet do koše
		discard_drops = 0,
		-- string -- pro [ch_core/teleport], pozice uložená příkazem /domů
		domov = "",
		-- int (>= 0) -- pro [ch_core/chat] udává aktuální doslech
		doslech = 50,
		-- int {0, 1} -- pro [ch_core] 0 = normální velikost, 1 = rozšířený inventář
		extended_inventory = 0,
		-- string -- pole příznaků
		flags = "",
		-- string YYYY-MM-DD nebo "" -- datum, kdy byla hráči/ce naposledy vypsána oznámení po přihlášení do hry (YYYY-MM-DD)
		last_ann_shown_date = "1970-01-01",
		-- int (>= 0) -- v sekundách od 1. 1. 2000 UTC; 0 značí neplatnou hodnotu
		last_login = 0,
		-- int {0, 1} -- 0 = shýbat se při stisku Shift; 1 = neshýbat se
		neshybat = 0,
		-- int {0, 1} -- 0 = krásná obloha ano, 1 ne
		no_ch_sky = 0,
		-- float -- v sekundách
		past_ap_playtime = 0.0,
		-- float -- v sekundách
		past_playtime = 0.0,
		-- string -- výčet dodatečných práv naplánovaných pro registraci postavy
		pending_registration_privs = "",
		-- string -- typ naplánované registrace postavy
		pending_registration_type = "",
		-- int -- pro [ch_bank]
		rezim_plateb = 0,
		-- int {0, 1} -- 0 => zobrazit, 1 => skrýt
		skryt_body = 0,
		-- int {0, 1} -- 0 => zobrazovat (výchozí), 1 => skrýt
		skryt_hlad = 0,
		-- int {0, 1} -- 0 => zobrazovat (výchozí), 1 => skrýt
		skryt_zbyv = 0,
		-- string -- pro [ch_core/teleport], pozice uložená příkazem /stavím
		stavba = "",
		-- string -- nastavení filtru událostí
		ui_event_filter = "",
		-- int (>= 1) -- číslo verze uložených dat (umožňuje upgrade)
		version = current_format_version,
		-- int {1, 2, 3} -- volba cíle pro /začátek: 1 => Začátek, 2 => Masarykovo náměstí, 3 => Hlavní nádraží
		zacatek_kam = 1,
	},
	initial_offline_playerinfo = {
		-- int -- výše uloženého trestu (může být záporná)
		trest = 0,
	}
}

-- POZNÁMKA: protože příznaky z následujícího pole se mapují na znaky v řetězci 'flags', nesmí se mazat ani zakomentovat!
-- Je však možno je přejmenovat při zachování pozice.
local flag_ids = {
	"discard_drops",
	"extended_inventory",
	"neshybat",
	"no_ch_sky",
	"skryt_body",
	"skryt_hlad",
	"skryt_zbyv",
}
local flag_name_to_id = {}

for i, flag in ipairs(flag_ids) do
	local old_id = flag_name_to_id[flag]
	if old_id ~= nil then
		error("Flag '"..flag.."' has multiple IDs: "..old_id..", "..i.."!")
	end
	flag_name_to_id[flag] = i
end
ch_data.initial_offline_charinfo.flags = string.rep(" ", #flag_ids)

local function add_player(player_name, new_offline_charinfo, player_info)
	if players_set[player_name] then
		return false
	end
	assert(new_offline_charinfo)
	local lcase = string.lower(player_name)
	-- add player to players_list (persistently):
	table.insert(players_list, player_name)
	core.safe_file_write(playerlist_path, assert(core.serialize(players_list)))
	-- add player to players_set and lc_to_player_name:
	players_set[player_name] = true
	lc_to_player_name[lcase] = player_name
	-- add new offline_charinfo:
	ch_data.offline_charinfo[player_name] = new_offline_charinfo
	-- add new offline_charinfo[].player:
	new_offline_charinfo.player = player_info or table.copy(ch_data.initial_offline_playerinfo)
	if new_offline_charinfo.player.name == nil then
		new_offline_charinfo.player.name = player_name
	end
	return true
end

local function delete_player(player_name)
	-- check if the player exists:
	if not players_set[player_name] then
		return false
	end
	-- detach offline_playerinfo:
	local offline_player_info = assert(ch_data.offline_charinfo[player_name].player)
	local aliases = {}
	for alias, offline_charinfo in pairs(ch_data.offline_charinfo) do
		if alias ~= player_name and offline_charinfo.player.name == player_name then
			offline_player_info = offline_charinfo.player
			table.insert(aliases, alias)
		end
	end
	if #aliases > 0 then
		offline_player_info.name = aliases[1]
		core.log("debug", "delete_player(): dotplayer of "..table.concat(aliases, ",").." corrected to "..player_info.name)
		for _, alias in ipairs(aliases) do
			ch_core.save_offline_playerinfo(alias)
		end
	end
	-- remove player from players_list:
	local lcase = string.lower(player_name)
	for i, pname in ipairs(players_list) do
		if pname == player_name then
			table.remove(players_list, i)
			break
		end
	end
	-- save the player_list:
	core.safe_file_write(playerlist_path, assert(core.serialize(players_list)))
	-- remove player from players_set:
	players_set[player_name] = nil
	-- remove player from lc_to_player_name:
	lc_to_player_name[lcase] = nil
	-- remove player from offline_charinfo:
	ch_data.offline_charinfo[player_name] = nil
	return true
end

function ch_data.get_flag(charinfo, flag_name, default_result)
	local id = flag_name_to_id[flag_name]
	if id ~= nil then
		local result = (charinfo.flags or ""):sub(id, id)
		if result ~= "" then
			return result
		end
	end
	return default_result or " "
end

function ch_data.get_flags(charinfo)
	local flags = charinfo.flags or ""
	local result = {}
	for id, name in ipairs(flag_ids) do
		local value = flags:sub(id, id)
		if value == "" then
			value = " "
		end
		result[name] = value
	end
	return result
end

function ch_data.set_flag(charinfo, flag_name, value)
	local id = flag_name_to_id[flag_name]
	if id == nil then
		return false
	end
	value = (tostring(value).." "):sub(1,1)
	local flags = charinfo.flags or ""
	if flags:len() < id then
		flags = flags..string.rep(" ", id - flags:len() - 1)..value
	else
		flags = flags:sub(1, id - 1)..value..flags:sub(id + 1, -1)
	end
	charinfo.flags = flags
	return true
end

function ch_data.correct_player_name_casing(name)
	return lc_to_player_name[string.lower(name)]
end

function ch_data.get_joining_online_charinfo(player)
	assert(core.is_player(player))
	local player_name = player:get_player_name()
	local result = ch_data.online_charinfo[player_name]
	if result ~= nil then
		return result
	end
	local player_info = core.get_player_information(player_name)
	local now = core.get_us_time()
	result = {
		areas = {{
			id = 0,
			name = "Český hvozd",
			type = 1,
		}},
		-- časová známka vytvoření online_charinfo (vstupu postavy do hry)
		join_timestamp = now,
		-- jazykový kód (obvykle "cs")
		lang_code = player_info.lang_code or "",
		-- úroveň osvětlení postavy
		light_level = 0,
		-- časová známka pro úroveň osvětlení postavy
		light_level_timestamp = now,
		-- verze protokolu
		protocol_version = player_info.protocol_version or 0,
		-- tabulka již zobrazených nápověd (bude deserializována níže)
		navody = {},
		-- co udělat těsně po připojení
		news_role = "new_player",
		-- přihlašovací jméno
		player_name = player_name,
	}

	-- news_role:
	--[[
		5.5.x => formspec_version = 5, protocol_version = 40
		5.6.x => formspec_version = 6, protocol_version = 41
		5.7.x => formspec_version = 6, protocol_version = 42
		5.8.0 => formspec_version = 7, protocol_version = 43
		5.9.0 => formspec_version = ?, protocol_version = ?
		5.10.0 => formspec_version = 8, protocol_version = 46
	]]
	if result.protocol_version < 42 then
		result.news_role = "disconnect"
	elseif not ch_data.supported_lang_codes[result.lang_code] and not core.check_player_privs(player, "server") then
			result.news_role = "invalid_locale"
	elseif core.check_player_privs(player, "ch_registered_player") then
		result.news_role = "player"
	elseif not ch_data.is_acceptable_name(player_name) then
		result.news_role = "invalid_name"
	else
		result.news_role = "new_player"
	end

	ch_data.online_charinfo[player_name] = result
	local prev_online_charinfo = old_online_charinfo[player_name]
	if prev_online_charinfo ~= nil then
		old_online_charinfo[player_name] = nil
		if prev_online_charinfo.leave_timestamp ~= nil then
			result.prev_leave_timestamp = prev_online_charinfo.leave_timestamp
		end
	end
	core.log("action", "JOIN PLAYER(" .. player_name ..") at "..now.." with lang_code \""..result.lang_code..
		"\", formspec_version = "..tostring(player_info.formspec_version)..", protocol_version = "..
		result.protocol_version..", news_role = "..result.news_role..", ip_address = "..tostring(player_info.address))

	-- deserializovat návody:
	local meta = player:get_meta()
	local s = meta:get_string("navody")
	if s and s ~= "" then
		result.navody = core.deserialize(s, true) or result.navody
	end

	if result.news_role ~= "invalid_name" then
		ch_data.get_or_add_offline_charinfo(player_name)
	end
	--[[
	TODO:
	if core.is_creative_enabled(player_name) then
		result.is_creative = true
		if ch_core.set_immortal then
			ch_core.set_immortal(player, true)
				end
			end
		else
			core.log("error", "Player object not available for "..player_name.." in get_joining_online_charinfo()!")
		end
		]]
	return result
end

function ch_data.get_leaving_online_charinfo(player)
	assert(core.is_player(player))
	local player_name = player:get_player_name()
	local result = ch_data.online_charinfo[player_name]
	if result ~= nil then
		result.leave_timestamp = core.get_us_time()
		old_online_charinfo[player_name] = result
		ch_data.online_charinfo[player_name] = nil
		return result
	else
		return old_online_charinfo[player_name]
	end
end

function ch_data.delete_offline_charinfo(player_name)
	if ch_data.online_charinfo[player_name] ~= nil then
		return false, "Postava je ve hře!"
	end
	if not delete_player(player_name) then
		return false, "Mazání selhalo."
	end
	local success, errmsg = os.remove(worldpath.."/ch_playerdata/"..player_name)
	if success then
		return true, "Úspěšně smazáno."
	else
		return false, "Mazání souboru selhalo: "..(errmsg or "nil")
	end
end

function ch_data.get_offline_charinfo(player_name)
	local result = ch_data.offline_charinfo[player_name]
	if result == nil then
		error("Offline charinfo not found for player '"..player_name.."'!")
	end
	return result
end

function ch_data.get_or_add_offline_charinfo(player_name)
	local result = ch_data.offline_charinfo[player_name]
	if result == nil then
		add_player(player_name, table.copy(ch_data.initial_offline_charinfo))
		result = assert(ch_data.offline_charinfo[player_name])
		core.log("action", "[ch_data] Offline charinfo initialized for "..player_name)
		ch_data.save_offline_charinfo(player_name)
	end
	return result
end

local debug_flag = false

function ch_data.save_offline_charinfo(player_name, include_playerinfo)
	if players_set[player_name] == nil then
		return false
	end
	local data = ch_data.offline_charinfo[player_name]
	if data == nil then
		return false
	end
	core.safe_file_write(datapath.."/"..player_name, assert(core.serialize(data)))
	if include_playerinfo and data.player.name ~= player_name then
		local dotplayer_name = data.player.name
		assert(ch_data.offline_charinfo[dotplayer_name])
		assert(ch_data.offline_charinfo[dotplayer_name].player.name == dotplayer_name)
		return ch_data.save_offline_charinfo(dotplayer_name)
	end
	return true
end

function ch_data.save_offline_playerinfo(player_name)
	if players_set[player_name] == nil then
		return false
	end
	local data = ch_data.offline_charinfo[player_name]
	if data == nil then
		return false
	end
	local dotplayer_name = assert(data.player.name)
	assert(ch_data.offline_charinfo[dotplayer_name])
	assert(ch_data.offline_charinfo[dotplayer_name].player.name == dotplayer_name)
	return ch_data.save_offline_charinfo(dotplayer_name)
end

local function on_joinplayer(player, last_login)
	ch_data.get_joining_online_charinfo(player)
end

local function on_leaveplayer(player)
	ch_data.get_leaving_online_charinfo(player)
end

core.register_on_joinplayer(on_joinplayer)
core.register_on_leaveplayer(on_leaveplayer)

local function upgrade_offline_charinfo(player_name, data)
	local old_version = data.version
	if data.version <= 1 then
		data.player.trest = data.trest or 0
		data.trest = nil
	end
	data.version = current_format_version
	core.log("info", "Offline_charinfo["..player_name.."] upgraded from version "..old_version.." to the current version "..data.version..".")
	return true
end

-- Load and initialize:

core.mkdir(datapath)
local function initialize()
	local f = io.open(playerlist_path)
	if f then
		local text = f:read("*a")
		f:close()
		if text ~= nil and text ~= "" then
			local new_players = core.deserialize(text, true)
			if type(new_players) == "table" then
				core.log("action", "[ch_data] "..#new_players.." known players.")
				players_list = new_players
				players_set = {}
				for _, player_name in ipairs(players_list) do
					players_set[player_name] = true
				end
			end
		end
	end
	for _, player_name in ipairs(players_list) do
		f = io.open(datapath.."/"..player_name)
		if f then
			local text = f:read("*a")
			f:close()
			if text ~= nil and text ~= "" then
				local data = core.deserialize(text, true)
				if type(data) == "table" then
					ch_data.offline_charinfo[player_name] = data
					lc_to_player_name[string.lower(player_name)] = player_name
				end
			end
		end
		if ch_data.offline_charinfo[player_name] == nil then
			core.log("error", "[ch_data] deserialization of offline_charinfo["..player_name.."] failed!")
		end
	end
	for player_name, poc in pairs(ch_data.offline_charinfo) do
		-- vivify/upgrade/correct offline_charinfo:
		for key, value in pairs(ch_data.initial_offline_charinfo) do
			if poc[key] == nil then
				poc[key] = value
				core.log("warning", "Missing offline_charinfo key "..player_name.."/"..key.." vivified.")
			end
		end
		-- correct invalid past_playtime:
		if poc.past_playtime < 0 then
			core.log("warning", "Invalid past_playtime for "..player_name.." ("..poc.past_playtime..") corrected to zero!")
			poc.past_playtime = 0 -- correction of invalid data
		end
		-- vivify .player table (including .player.name)
		if poc.player == nil or poc.player.name == nil then
			poc.player = {name = player_name}
		end
	end
	-- link .player tables according to .player.name:
	for player_name, poc in pairs(ch_data.offline_charinfo) do
		local dotplayer_name = assert(poc.player.name)
		if dotplayer_name ~= player_name then
			if players_set[dotplayer_name] and ch_data.offline_charinfo[dotplayer_name] then
				poc.player = assert(ch_data.offline_charinfo[dotplayer_name].player)
			else
				error("offline_charinfo["..player_name.."] looks for player data of '"..dotplayer_name.."', but it doesn't exist!")
			end
		end
	end
	-- upgrade old data:
	for player_name, poc in pairs(ch_data.offline_charinfo) do
		if poc.version < current_format_version then
			upgrade_offline_charinfo(player_name, poc)
		end
	end
end

initialize()
initialize = nil

-- Obsluhy událostí:
-- ======================================================================================================================
local function on_joinplayer(player, last_login)
	local player_name = player:get_player_name()
	local online_charinfo = ch_data.get_joining_online_charinfo(player)
	local offline_charinfo = ch_data.get_offline_charinfo(player_name)
	online_charinfo.doslech = offline_charinfo.doslech

	if offline_charinfo ~= nil then
		offline_charinfo.last_login = os.time() - 946684800
		ch_data.save_offline_charinfo(player_name)
		-- lc_to_player_name[string.lower(player_name)] = player_name
	end

	return true
end

local function save_playtime(online_charinfo, offline_charinfo)
	if offline_charinfo == nil then
		return 0, 0, 0
	end
	local now = core.get_us_time()
	local past_playtime = offline_charinfo.past_playtime or 0
	local current_playtime = math.max(0, 1.0e-6 * (now - online_charinfo.join_timestamp))
	local total_playtime = past_playtime + current_playtime

	offline_charinfo.past_playtime = total_playtime
	ch_data.save_offline_charinfo(online_charinfo.player_name)
	online_charinfo.join_timestamp = nil
	return past_playtime, current_playtime, total_playtime
end

local function on_leaveplayer(player, timedout)
	local player_name = player:get_player_name()
	local online_info = ch_data.get_leaving_online_charinfo(player)

	if online_info.join_timestamp then
		local past_playtime, current_playtime, total_playtime = save_playtime(online_info, ch_data.offline_charinfo[player_name])
		print("PLAYER(" .. player_name .."): played seconds: " .. current_playtime .. " / " .. total_playtime)
	end
end

local function on_shutdown()
	for player_name, online_info in pairs(table.copy(ch_data.online_charinfo)) do
		if online_info.join_timestamp then
			local past_playtime, current_playtime, total_playtime
			past_playtime, current_playtime, total_playtime = save_playtime(online_info, ch_data.offline_charinfo[player_name])
			print("PLAYER(" .. player_name .."): played seconds: " .. current_playtime .. " / " .. total_playtime)
		end
	end
end

local function on_placenode(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	if core.is_player(placer) then
		local player_name = placer:get_player_name()
		local online_charinfo = ch_data.online_charinfo[player_name]
		if online_charinfo ~= nil then
			online_charinfo.last_placenode_ustime = core.get_us_time()
		end
	end
end

local function on_dignode(pos, oldnode, digger)
	if core.is_player(digger) then
		local player_name = digger:get_player_name()
		local online_charinfo = ch_data.online_charinfo[player_name]
		if online_charinfo ~= nil then
			online_charinfo.last_dignode_ustime = core.get_us_time()
		end
	end
end

function ch_data.clear_help(player)
	local player_name = player:get_player_name()
	local online_charinfo = ch_data.online_charinfo[player_name]
	if online_charinfo then
		online_charinfo.navody = {}
		player:get_meta():set_string("navody", core.serialize(online_charinfo.navody))
		return true
	else
		return false
	end
end

--[[
	Otestuje, zda podle online_charinfo má dané postavě být zobrazený
	v četu návod k položce daného názvu. Pokud ano, nastaví příznak, aby se
	to znovu již nestalo, a vrátí definici daného předmětu,
	z níž lze z položek description a _ch_help sestavit text k zobrazení.
]]
function ch_data.should_show_help(player, online_charinfo, item_name)
	local def = core.registered_items[item_name]
	if def and def._ch_help then
		if def._ch_help_group then
			item_name = def._ch_help_group
		end
		local navody = online_charinfo.navody
		if not navody then
			navody = {[item_name] = 1}
			online_charinfo.navody = navody
			player:get_meta():set_string("navody", core.serialize(navody))
			return def.description ~= nil and def
		end
		if not navody[item_name] then
			navody[item_name] = 1
			player:get_meta():set_string("navody", core.serialize(navody))
			return def.description ~= nil and def
		end
	end
	return nil
end

function ch_data.nastavit_shybani(player_name, shybat)
	local offline_charinfo = ch_data.offline_charinfo[player_name]
	if offline_charinfo == nil then
		core.log("error", "ch_data.nastavit_shybani(): Expected offline charinfo for player "..player_name.." not found!")
		return false
	end
	local new_state
	if shybat then
		new_state = 0
	else
		new_state = 1
	end
	offline_charinfo.neshybat = new_state
	ch_data.save_offline_charinfo(player_name)
	return true
end

core.register_on_joinplayer(on_joinplayer)
core.register_on_leaveplayer(on_leaveplayer)
core.register_on_shutdown(on_shutdown)
core.register_on_dignode(on_dignode)
core.register_on_placenode(on_placenode)

local def = {
	description = "Smaže údaje o tom, ke kterým předmětům již byly postavě zobrazeny nápovědy, takže budou znovu zobrazovány nápovědy ke všem předmětům.",
	func = function(player_name, param)
		if ch_data.clear_help(core.get_player_by_name(player_name)) then
			return true, "Údaje smazány."
		else
			core.log("error", "/návodyznovu: vnitřní chyba serveru ("..player_name..")!")
			return false, "Vnitřní chyba serveru"
		end
	end,
}
core.register_chatcommand("návodyznovu", def)
core.register_chatcommand("navodyznovu", def)

def = {
	description = "Odstraní údaje o postavě uložené v systému ch_data. Postava nesmí být ve hře.",
	privs = {server = true},
	func = function(player_name, param)
		local offline_charinfo = ch_data.offline_charinfo[param]
		if not offline_charinfo then
			return false, "Data o "..param.." nenalezena!"
		end
		if ch_data.delete_offline_charinfo(param) then
			return true, "Data o "..param.." smazána."
		else
			return false, "Při odstraňování nastala chyba."
		end
	end,
}

core.register_chatcommand("delete_offline_charinfo", def)

def = {
	description = "Trvale vypne či zapne shýbání postavy při držení Shiftu.",
	params = "<ano|ne>",
	func = function(player_name, param)
		if param ~= "ano" and param ~= "ne" then
			return false, "Chybná syntaxe."
		end
		if ch_data.nastavit_shybani(player_name, param == "ano") then
			core.chat_send_player(player_name, "*** Shýbání postavy "..(param == "ne" and "vypnuto" or "zapnuto")..".")
			return true
		else
			core.log("error", "/shybat: Expected offline charinfo for player "..player_name.." not found!")
			return false, "Vnitřní chyba serveru: Data postavy nenalezena."
		end
	end,
}

core.register_chatcommand("shýbat", def)
core.register_chatcommand("shybat", def)

local function merge_playerinfos(player_name_a, player_name_b)
	if player_name_a == player_name_b then
		return false, "'"..player_name_a.."' a '"..player_name_b.."' reprezentují tutéž postavu!"
	end
	local oci_a = ch_data.offline_charinfo[player_name_a]
	local oci_b = ch_data.offline_charinfo[player_name_b]
	if oci_a == nil then
		return false, "Postava '"..player_name_a.."' neexistuje!"
	end
	if oci_b == nil then
		return false, "Postava '"..player_name_b.."' neexistuje!"
	end
	local dotplayer_a = assert(oci_a.player.name)
	local dotplayer_b = assert(oci_b.player.name)
	if dotplayer_a == dotplayer_b then
		return false, "Postavy '"..player_name_a.."' a '"..player_name_b.."' již patří stejné/mu hráči/ce '"..dotplayer_a.."'."
	end
	local aliases = {dotplayer_b}
	for alias, offline_charinfo in pairs(ch_data.offline_charinfo) do
		if alias ~= dotplayer_b and offline_charinfo.player.name == dotplayer_b then
			table.insert(aliases, alias)
		end
	end
	ch_data.save_offline_charinfo(dotplayer_b)
	for _, alias in ipairs(aliases) do
		ch_data.offline_charinfo[alias].player = oci_a.player
		ch_data.save_offline_charinfo(alias)
		core.log("action", "[MERGE] Player info of .player "..dotplayer_a.." assigned to player "..alias..".")
	end
	return true, "Postavy "..table.concat(aliases, ",").." přiřazeny hráči/ce "..dotplayer_a.."."
end

local function set_main_player(player_name)
	local oci_a = ch_data.offline_charinfo[player_name]
	if oci_a == nil then
		return false, "Postava '"..player_name.."' neexistuje!"
	end
	local old_main = assert(oci_a.player.name)
	if old_main == player_name then
		return false, "Postava '"..player_name.."' již je hlavní."
	end
	local aliases = {}
	for alias, offline_charinfo in pairs(ch_data.offline_charinfo) do
		if alias ~= old_main and offline_charinfo.player.name == old_main then
			table.insert(aliases, alias)
		end
	end
	oci_a.player.name = player_name
	ch_data.save_offline_charinfo(old_main)
	for _, alias in ipairs(aliases) do
		ch_data.save_offline_charinfo(alias)
	end
	return true, "Postava "..player_name.." nastavena jako hlavní (původní hlavní postava: "..old_main..")."
end

function ch_data.get_player_characters(player_name)
	local offline_charinfo = ch_data.offline_charinfo[player_name]
	if offline_charinfo == nil then
		return nil
	end
	local main_name = offline_charinfo.player.name
	local result = {}
	for name, oci in pairs(ch_data.offline_charinfo) do
		if oci.player.name == main_name then
			table.insert(result, name)
		end
	end
	if #result > 1 then
		table.sort(result, function(a, b) return (a == main_name and b ~= main_name) or a < b end) -- TODO: better sorting
	end
	return result, main_name
end

def = {
	description = "Sloučí hráčská data odpovídající postavě B s hráčskými daty odpovídajícími postavě A",
	params = "<Jmeno_postavy_hlavni_A> <Jmeno_postavy_vedlejsi_B>",
	privs = {server = true},
	func = function(admin_name, param)
		local a, b = string.match(param, "^([^ ]+) +([^ ]+)$")
		if a == nil or b == nil then
			return false, "Chybné zadání!"
		end
		local result, message = merge_playerinfos(a, b)
		return result, message
	end,
}

core.register_chatcommand("připojit_postavu", def)
core.register_chatcommand("pripojit_postavu", def)

def = {
	description = "Změní hlavní postavu hráče/ky",
	params = "<Nova_hlavni_postava>",
	privs = {server = true},
	func = function(admin_name, param)
		local result, message = set_main_player(param)
		return result, message
	end,
}

core.register_chatcommand("hlavní_postava", def)
core.register_chatcommand("hlavni_postava", def)

ch_base.close_mod(core.get_current_modname())
