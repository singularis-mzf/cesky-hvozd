ch_core.open_submod("data")

-- BARVY
-- ===========================================================================

--[[
local nametag_color_red = minetest.get_color_escape_sequence("#cc5257");
local nametag_color_blue = minetest.get_color_escape_sequence("#6693ff");
local nametag_color_green = minetest.get_color_escape_sequence("#48cc3d");
local nametag_color_yellow = minetest.get_color_escape_sequence("#fff966");
local nametag_color_aqua = minetest.get_color_escape_sequence("#66f8ff");
local nametag_color_grey = minetest.get_color_escape_sequence("#cccccc");
local color_reset = minetest.get_color_escape_sequence("#ffffff");

local nametag_color_bgcolor_table = {r = 0, g = 0, b = 0, a = 0}
local nametag_color_normal_table = {r = 255, g = 255, b = 255, a = 255}
local nametag_color_unregistered_table = {r = 204, g = 204, b = 204, a = 255} -- 153?
local nametag_color_unregistered = nametag_color_grey
]]

-- POZICE A OBLASTI
-- ===========================================================================

ch_core.unregistered_spawn = vector.new(-70,9.5,40)
ch_core.registered_spawn = ch_core.unregistered_spawn

local zero_by_type = {
	int = 0,
	float = 0.0,
	-- nil = nil,
	string = "",
	vector = vector.zero(),
}

-- GLOBÁLNÍ DATA
-- ===========================================================================
local global_data_data_types = {
	posun_casu = "int",
	povinne_vytisky = "vector",
	povinne_vytisky_listname = "string",
	pristi_ick = "int",
	registered_spawn = "vector",
	unregistered_spawn = "vector",
}

local initial_global_data = {
	pristi_ick = 10000,
	registered_spawn = vector.new(-70,9.5,40),
	unregistered_spawn = vector.new(-70,9.5,40),
}

for k, t in pairs(global_data_data_types) do
	if initial_global_data[k] == nil then
		initial_global_data[k] = zero_by_type[t]
	end
end

-- DATA O POSTAVÁCH
-- ===========================================================================
-- key => "int|float", unknown keys are deserialized as strings
local offline_charinfo_data_types = {
	ap_level = "int", -- > 0
	ap_xp = "int", -- >= 0
	ap_version = "int", -- >= 0
	doslech = "int", -- >= 0
	last_login = "int", -- >= 0, in seconds since 1. 1. 2000 UTC; 0 is invalid value
	neshybat = "int", -- 0 = shýbat se při stisku Shift, 1 = neshýbat se
	past_ap_playtime = "float", -- in seconds
	past_playtime = "float", -- in seconds
	pending_registration_privs = "string",
	pending_registration_type = "string",
	skryt_body = "int", -- 0 => zobrazit, 1 => skrýt

	trest = "int",
}

local initial_offline_charinfo = {
	ap_level = 1, -- must be > 0
	ap_version = ch_core.verze_ap,
	doslech = 50,
}
for k, t in pairs(offline_charinfo_data_types) do
	if initial_offline_charinfo[k] == nil then
		initial_offline_charinfo[k] = zero_by_type[t]
	end
end
local storage = ch_core.storage

ch_core.global_data = table.copy(initial_global_data)
ch_core.online_charinfo = {}
ch_core.offline_charinfo = {}
local old_online_charinfo = {}

local function is_invalid_player_name(player_name)
	if type(player_name) == "number" then
		player_name = tostring(player_name)
	elseif type(player_name) ~= "string" then
		return "Invalid player_name type "..type(player_name).."!"
	end
	if #player_name == 0 then
		return "Empty player_name!"
	end
	if #player_name > 19 then
		return "Player name "..player_name.." too long!"
	end
	if string.find(player_name, "[^_%w-]") then
		return "Player name '"..player_name.."' contains an invalid character!"
	end
	return false
end

local function verify_valid_player_name(player_name)
	local message = is_invalid_player_name(player_name)
	if message then
		error(message)
	else
		return tostring(player_name)
	end
end

function ch_core.get_offline_charinfo(player_name)
	local result = ch_core.offline_charinfo[player_name]
	if not result then
		minetest.log("action", "Will create offline_charinfo for player '"..verify_valid_player_name(player_name).."'")
		result = table.copy(initial_offline_charinfo)
		ch_core.offline_charinfo[player_name] = result
	end
	return result
end

-- Vrátí online_charinfo připojující se postavy;
-- tato funkce smí být volána pouze z obsluhy „on_joinplayer“!
function ch_core.get_joining_online_charinfo(player_name)
	local result = ch_core.online_charinfo[player_name]
	if not result then
		-- the first call => create a new online_charinfo
		local player_info = minetest.get_player_information(player_name)
		local now = minetest.get_us_time()
		local player = minetest.get_player_by_name(player_name)
		result = {
			-- nejvyšší verze formspec podporovaná klientem; 0, pokud údaj není k dispozici
			formspec_version = player_info.formspec_version or 0,
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
			-- přihlašovací jméno
			player_name = player_name,
		}
		ch_core.online_charinfo[player_name] = result
		old_online_charinfo[player_name] = nil
		minetest.log("action", "JOIN PLAYER(" .. player_name ..") at "..now.." with lang_code \""..result.lang_code.."\", formspec_version = "..result.formspec_version.." and protocol_version = "..result.protocol_version)

		-- local player = minetest.get_player_by_name(player_name)
		if player then
			local meta = player:get_meta()
			local s = meta:get_string("navody")
			if s and s ~= "" then
				result.navody = minetest.deserialize(s, true) or result.navody
			end

			if minetest.is_creative_enabled(player_name) then
				result.is_creative = true
				if ch_core.set_immortal then
					ch_core.set_immortal(player, true)
				end
			end
		else
			minetest.log("error", "Player object not available for "..player_name.." in get_joining_online_charinfo()!")
		end
	end
	return result
end

-- Vrátí online_charinfo odpojující se postavy, případně {}.
-- Pokud je online_charinfo platné, smaže ho z tabulky.
-- tato funkce smí být volána pouze z obsluhy „on_joinplayer“ nebo „on_shutdown“!
function ch_core.get_leaving_online_charinfo(player_name)
	local result = ch_core.online_charinfo[player_name]
	if result then
		old_online_charinfo[player_name] = result
		ch_core.online_charinfo[player_name] = nil
		print("LEAVE PLAYER(" .. player_name ..") at "..ch_core.cas)
		return result
	else
		return old_online_charinfo[player_name] or {}
	end
end

function ch_core.save_global_data(keys)
	local ax = type(keys)
	if ax == "table" then
		ax = ch_core.save_global_data
		for _, key in ipairs(keys) do
			ax(key)
		end
		return
	elseif ax ~= "string" and ax ~= "number" then
		error("save_global_data() called with an argument of invalid type "..ax.."!")
	end

	local data_type = global_data_data_types[keys]
	if data_type == nil then
		minetest.log("warning", "save_global_data() called for unknown key '"..keys.."', ignored.")
		return false
	end
	local full_key = "/"..keys
	local value = ch_core.global_data[keys]
	if data_type == "int" then
		storage:set_int(full_key, value or 0)
	elseif data_type == "float" then
		storage:set_float(full_key, value or 0.0)
	elseif data_type == "vector" then
		storage:set_string(full_key, minetest.pos_to_string(vector.round(value)))
	else
		storage:set_string(full_key, value or "")
	end
	return true
end

-- datatype = "string"|"int"|"float"|"vector"|"nil"
function ch_core.save_offline_charinfo(player_name, keys)
	local offline_charinfo = ch_core.offline_charinfo[player_name]
	if not offline_charinfo then
		return 0
	end
	if type(keys) ~= "table" then
		keys = {keys}
	end
	local counter = 0
	for _, key in ipairs(keys) do
		local value = offline_charinfo[key]
		local full_key = player_name.."/"..key
		local data_type = offline_charinfo_data_types[key]
		if data_type == "int" then
			storage:set_int(full_key, value or 0)
		elseif data_type == "float" then
			storage:set_float(full_key, value or 0.0)
		elseif data_type == "vector" then
			storage:set_string(full_key, minetest.pos_to_string(vector.round(value)))
		else
			storage:set_string(full_key, value or "")
		end
		counter = counter + 1
	end
	return counter
end

function ch_core.delete_offline_charinfo(player_name, keys)
	local delete_all = not keys
	if delete_all then
		-- delete all keys
		for full_key, _ in pairs((storage:to_table() or {}).fields or {}) do
			local name --[[, key]] = full_key:match("^([^/]+)/(.+)$")
			if name and name == player_name then
				storage:set_string(full_key, "")
				minetest.log("info", "[ch_core] Key '"..full_key.."' removed from mod storage.")
			end
		end
		ch_core.offline_charinfo[player_name] = nil
		return true
	end

	if type(keys) ~= "table" then
		keys = {keys}
	end
	local offline_charinfo = ch_core.offline_charinfo[player_name]
	if not offline_charinfo then
		return false
	end
	for _, key in ipairs(keys) do
		storage:set_string(player_name.."/"..key, "")
		offline_charinfo[key] = initial_offline_charinfo[key]
		minetest.log("info", "[ch_core] Key '"..key.."' removed from mod storage.")
	end
	return true
end

function ch_core.set_titul(player_name, titul)
	local offline_charinfo = ch_core.get_offline_charinfo(player_name)
	offline_charinfo.titul = titul
	ch_core.save_offline_charinfo(player_name, "titul")
	local online_charinfo = ch_core.online_charinfo[player_name]
	local player = minetest.get_player_by_name(player_name)
	if player and online_charinfo and ch_core.compute_player_nametag then
		player:set_nametag_attributes(ch_core.compute_player_nametag(online_charinfo, offline_charinfo))
	end
	return true
end

-- ch_core.set_temporary_titul() -- Nastaví či zruší dočasný titul postavy.
--
function ch_core.set_temporary_titul(player_name, titul, titul_enabled)
	if type(player_name) ~= "string" then
		error("ch_core.set_temporary_titul(): Invalid player_name type: "..type(player_name).."!")
	end
	local online_charinfo = ch_core.online_charinfo[player_name]
	if not online_charinfo or not titul or titul == "" then return false end
	local dtituly = ch_core.get_or_add(online_charinfo, "docasne_tituly")
	if titul_enabled then
		dtituly[titul] = 1
	else
		dtituly[titul] = nil
	end
	local player = minetest.get_player_by_name(player_name)
	if player and ch_core.compute_player_nametag then
		player:set_nametag_attributes(ch_core.compute_player_nametag(online_charinfo, ch_core.get_offline_charinfo(player_name)))
		return true
	else
		return false
	end
end

local function restore_value_by_type(data_type, value, value_description)
	if data_type == "int" then
		return math.round(tonumber(value))
	elseif data_type == "float" then
		return tonumber(value)
	elseif data_type == "string" then
		return value
	elseif data_type == "vector" then
		local result = minetest.string_to_pos(value)
		if result == nil then
			minetest.log("warning", "Invalid value ignored on restore! (description = "..(value_description or "nil")..")")
			return zero_by_type["vector"]
		end
		return result
	elseif data_type == "nil" then
		return nil
	else
		error("restore_value_by_type() called with invalid data_type "..dump2(data_type).."!")
	end
end

-- restore offline data from the storage
local player_counter, player_field_counter, global_counter, delete_counter = 0, 0, 0, 0
local player_set = {}
local storage_table = (storage:to_table() or {}).fields or {}
for full_key, value in pairs(storage_table) do
	local player_name, key = full_key:match("^([^/]*)/(.+)$")
	if player_name == "" and key ~= "" then
		local data_type = global_data_data_types[key]
		ch_core.global_data[key] = restore_value_by_type(data_type, value, "global property "..key)
		global_counter = global_counter + 1
	elseif player_name and not is_invalid_player_name(player_name) then
		local offline_charinfo = ch_core.get_offline_charinfo(player_name)
		local data_type = offline_charinfo_data_types[key]
		if data_type == "int" then
			offline_charinfo[key] = math.round(tonumber(value))
		elseif data_type == "float" then
			offline_charinfo[key] = tonumber(value)
		else
			offline_charinfo[key] = value
		end
		player_field_counter = player_field_counter + 1
		if player_set[player_name] == nil then
			player_set[player_name] = true
			player_counter = player_counter + 1
		end
	else
		storage:set_string(full_key, "")
		minetest.log("warning", "Invalid key '"..full_key.."' (value "..value..") removed from mod storage!")
		delete_counter = delete_counter + 1
	end
end
print("[ch_core] Restored "..player_field_counter.." data pairs of "..player_counter.." players and "..global_counter.." global pairs from the mod storage. "..delete_counter.." was deleted.")

-- Check and update keys
for player_name, offline_charinfo in pairs(ch_core.offline_charinfo) do
	for key, _ in pairs(offline_charinfo_data_types) do
		if offline_charinfo[key] == nil then
			offline_charinfo[key] = initial_offline_charinfo[key]
			minetest.log("warning", "Missing offline_charinfo key "..player_name.."/"..key.." vivified")
		end
	end
	if offline_charinfo.past_playtime < 0 then
		minetest.log("warning", "Invalid past_playtime for "..player_name.." ("..offline_charinfo.past_playtime..") corrected to zero!")
		offline_charinfo.past_playtime = 0 -- correction of invalid data
	end
end
for key, data_type in pairs(global_data_data_types) do
	if ch_core.global_data[key] == nil and data_type ~= "nil" then
		ch_core.global_data[key] = zero_by_type[data_type]
	end
end

local function on_joinplayer(player, last_login)
	local player_name = player:get_player_name()
	local online_charinfo = ch_core.get_joining_online_charinfo(player_name)
	local offline_charinfo = ch_core.get_offline_charinfo(player_name) -- create offline_charinfo, if not exists
	online_charinfo.doslech = offline_charinfo.doslech

	offline_charinfo.last_login = os.time() - 946684800
	ch_core.save_offline_charinfo(player_name, "last_login")

	return true
end

local function save_playtime(online_charinfo, offline_charinfo)
	local now = minetest.get_us_time()
	local past_playtime = offline_charinfo.past_playtime or 0
	local current_playtime = math.max(0, 1.0e-6 * (now - online_charinfo.join_timestamp))
	local total_playtime = past_playtime + current_playtime

	offline_charinfo.past_playtime = total_playtime
	ch_core.save_offline_charinfo(online_charinfo.player_name, "past_playtime")
	online_charinfo.join_timestamp = nil
	return past_playtime, current_playtime, total_playtime
end

local function on_leaveplayer(player, timedout)
	local player_name = player:get_player_name()
	local online_info = ch_core.get_leaving_online_charinfo(player_name)

	if online_info.join_timestamp then
		local past_playtime, current_playtime, total_playtime = save_playtime(online_info, ch_core.get_offline_charinfo(player_name))
		print("PLAYER(" .. player_name .."): played seconds: " .. current_playtime .. " / " .. total_playtime)
	end
end

local function on_shutdown()
	for player_name, online_info in pairs(table.copy(ch_core.online_charinfo)) do
		if online_info.join_timestamp then
			local past_playtime, current_playtime, total_playtime
			past_playtime, current_playtime, total_playtime = save_playtime(online_info, ch_core.get_offline_charinfo(player_name))
			print("PLAYER(" .. player_name .."): played seconds: " .. current_playtime .. " / " .. total_playtime)
		end
	end
end

--[[
	Otestuje, zda podle online_charinfo má dané postavě být zobrazený
	v četu návod k položce daného názvu. Pokud ano, nastaví příznak, aby se
	to znovu již nestalo, a vráŧí definici daného předmětu,
	z níž lze z položek description a _ch_help sestavit text k zobrazení.
]]
function ch_core.should_show_help(player, online_charinfo, item_name)
	local def = minetest.registered_items[item_name]
	if def and def._ch_help then
		if def._ch_help_group then
			item_name = def._ch_help_group
		end
		local navody = online_charinfo.navody
		if not navody then
			navody = {[item_name] = 1}
			online_charinfo.navody = navody
			player:get_meta():set_string("navody", minetest.serialize(navody))
			return def.description ~= nil and def
		end
		if not navody[item_name] then
			navody[item_name] = 1
			player:get_meta():set_string("navody", minetest.serialize(navody))
			return def.description ~= nil and def
		end
	end
	return nil
end

minetest.register_on_joinplayer(on_joinplayer)
minetest.register_on_leaveplayer(on_leaveplayer)
minetest.register_on_shutdown(on_shutdown)

local def = {
	description = "Smaže údaje o tom, ke kterým předmětům již byly postavě zobrazeny nápovědy, takže budou znovu zobrazovány nápovědy ke všem předmětům.",
	func = function(player_name, param)
		local online_charinfo = ch_core.online_charinfo[player_name]
		local player = minetest.get_player_by_name(player_name)
		if online_charinfo then
			online_charinfo.navody = {}
			if player then
				player:get_meta():set_string("navody", minetest.serialize(online_charinfo.navody))
			else
				minetest.log("error", "Příkaz /návodyznovu nenašel objekt postavy "..player_name.."!")
				return false, "Vnitřní chyba serveru"
			end
			return true, "Údaje smazány."
		else
			minetest.log("error", "Příkaz /návodyznovu nenašel online_charinfo postavy "..player_name.."!")
			return false, "Vnitřní chyba serveru"
		end
	end,
}
minetest.register_chatcommand("návodyznovu", def)
minetest.register_chatcommand("navodyznovu", def)

def = {
	description = "Nastaví posun zobrazovaného času.",
	privs = {server = true},
	func = function(player_name, param)
		local n = tonumber(param)
		if not n then
			return false, "Chybné zadán!!"
		end
		n = math.round(n)
		ch_core.global_data.posun_casu = n
		ch_core.save_global_data("posun_casu")
		minetest.chat_send_player(player_name, "*** Posun nastaven: "..n)
	end,
}

minetest.register_chatcommand("posunčasu", def)
minetest.register_chatcommand("posuncasu", def)

def = {
	description = "Odstraní údaje o postavě uložené v systému ch_core. Postava nesmí být ve hře.",
	privs = {server = true},
	func = function(player_name, param)
		local offline_charinfo = ch_core.offline_charinfo[param]
		if not offline_charinfo then
			return false, "Data o "..param.." nenalezena!"
		end
		if ch_core.delete_offline_charinfo(param) then
			return true, "Data o "..param.." smazána."
		else
			return false, "Při odstraňování nastala chyba."
		end
	end,
}

minetest.register_chatcommand("delete_offline_charinfo", def)

def = {
	description = "Trvale vypne či zapne shýbání postavy při držení Shiftu.",
	params = "<ano|ne>",
	func = function(player_name, param)
		local new_state
		if param == "ano" then
			new_state = 0
		elseif param == "ne" then
			new_state = 1
		else
			return false, "Chybná syntaxe."
		end
		local offline_charinfo = ch_core.offline_charinfo[player_name]
		if offline_charinfo == nil then
			minetest.log("error", "/shybat: Expected offline charinfo for player "..player_name.." not found!")
			return false, "Vnitřní chyba serveru: Data postavy nenalezena."
		end
		offline_charinfo.neshybat = new_state
		ch_core.save_offline_charinfo(player_name, "neshybat")
		minetest.chat_send_player(player_name, "*** Shýbání postavy "..(new_state == 1 and "vypnuto" or "zapnuto")..".")
		return true
	end,
}

minetest.register_chatcommand("shýbat", def)
minetest.register_chatcommand("shybat", def)

ch_core.close_submod("data")
