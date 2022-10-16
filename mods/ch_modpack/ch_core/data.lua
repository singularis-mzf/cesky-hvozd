ch_core.open_submod("data")
local modpath = minetest.get_modpath("ch_core")

-- BARVY
-- ===========================================================================

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

-- POZICE A OBLASTI
-- ===========================================================================

ch_core.unregistered_spawn = vector.new(-70,9.5,40)
ch_core.registered_spawn = ch_core.unregistered_spawn

-- DATA O POSTAVÁCH
-- ===========================================================================
-- key => "int|float", unknown keys are deserialized as strings
local offline_charinfo_data_types = {
	ap_level = "int", -- > 0
	ap_xp = "int", -- >= 0
	ap_version = "int", -- >= 0
	past_ap_playtime = "float", -- in seconds
	past_playtime = "float", -- in seconds
	trest = "int",
}

local initial_offline_charinfo = {}
for k, t in pairs(offline_charinfo_data_types) do
	local v = ""
	if t == "int" then
		v = 0
	elseif t == "float" then
		v = 0.0
	end
	initial_offline_charinfo[k] = v
end
initial_offline_charinfo.ap_level = 1 -- must be > 0
initial_offline_charinfo.ap_version = ch_core.verze_ap

local storage = ch_core.storage

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
			-- tabulka již zobrazených nápověd (bude deserializována níže)
			navody = {},
			-- přihlašovací jméno
			player_name = player_name,
		}
		ch_core.online_charinfo[player_name] = result
		old_online_charinfo[player_name] = nil
		minetest.log("action", "JOIN PLAYER(" .. player_name ..") at "..now.." with lang_code \""..result.lang_code.."\" and formspec_version = "..result.formspec_version)

		local player = minetest.get_player_by_name(player_name)
		if player then
			local meta = player:get_meta()
			local s = meta:get_string("navody")
			if s and s ~= "" then
				result.navody = minetest.deserialize(s, true) or result.navody
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
		print("LEAVE PLAYER(" .. player_name ..") at "..ch_core.cas);
		return result
	else
		return old_online_charinfo[player_name] or {}
	end
	
	return ch_core.online_charinfo[player_name] or old_online_charinfo[player_name] or {}
end

-- datatype = "string"|"int"|"float"|"nil"
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
		keys = {}
		for full_key, _ in pairs((storage:to_table() or {}).fields or {}) do
			local name, key = full_key:match("^([^/]+)/(.+)$")
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
	local online_charinfo = ch_core.online_charinfo[player_name]
	if not online_charinfo or not titul or titul == "" then return false end
	local dtituly = online_charinfo.docasne_tituly
	if not dtituly then
		dtituly = {}
		online_charinfo.docasne_tituly = dtituly
	end
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

-- restore offline data from the storage
local counter, delete_counter = 0, 0
local storage_table = (storage:to_table() or {}).fields or {}
for full_key, value in pairs(storage_table) do
	local player_name, key = full_key:match("^([^/]*)/(.+)$")
	if player_name and not is_invalid_player_name(player_name) then
		local offline_charinfo = ch_core.get_offline_charinfo(player_name)
		local data_type = offline_charinfo_data_types[key]
		if data_type == "int" then
			offline_charinfo[key] = math.round(tonumber(value))
		elseif data_type == "float" then
			offline_charinfo[key] = tonumber(value)
		else
			offline_charinfo[key] = value
		end
		counter = counter + 1
	else
		storage:set_string(full_key, "")
		minetest.log("warning", "Invalid key '"..full_key.."' (value "..value..") removed from mod storage!")
		delete_counter = delete_counter + 1
	end
end
print("[ch_core] Restored "..counter.." data pairs from the mod storage. "..delete_counter.." was deleted.")

-- Check and update keys
for player_name, offline_charinfo in pairs(ch_core.offline_charinfo) do
	for key, data_type in pairs(offline_charinfo_data_types) do
		if offline_charinfo[key] == nil then
			offline_charinfo[key] = initial_offline_charinfo[key]
			minetest.log("warning", "Missing offline_charinfo key "..player_name.."/"..key.." vivified")
		end
	end
end

local function on_joinplayer(player, last_login)
	local player_name = player:get_player_name()
	ch_core.get_joining_online_charinfo(player_name)
	local offline_charinfo = ch_core.get_offline_charinfo(player_name) -- create offline_charinfo, if not exists
	if offline_charinfo.past_playtime < 0 then
		minetest.log("warning", "Invalid past_playtime for "..player_name.." corrected to zero!")
		offline_charinfo.past_playtime = 0 -- correction of invalid data
	end
	return true
end

local function on_leaveplayer(player, timedout)
	local player_name = player:get_player_name()
	local online_info = ch_core.get_leaving_online_charinfo(player_name)

	if online_info.join_timestamp then
		local offline_info = ch_core.get_offline_charinfo(player_name)
		local current_playtime = 1.0e-6 * (minetest.get_us_time() - online_info.join_timestamp)
		local total_playtime = (offline_info.past_playtime or 0) + current_playtime

		offline_info.past_playtime = total_playtime
		ch_core.save_offline_charinfo(player_name, "past_playtime")
		online_info.join_timestamp = nil
		print("PLAYER(" .. player_name .."): played seconds: " .. current_playtime .. " / " .. total_playtime);
	end
end

local function on_shutdown()
	for player_name, online_info in pairs(table.copy(ch_core.online_charinfo)) do
		if online_info.join_timestamp then
			local offline_info = ch_core.get_offline_charinfo(player_name)
			local current_playtime = ch_core.cas - online_info.join_timestamp
			local total_playtime = (offline_info.past_playtime or 0) + current_playtime

			offline_info.past_playtime = total_playtime
			ch_core.save_offline_charinfo(player_name, "past_playtime")
			online_info.join_timestamp = nil
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

ch_core.close_submod("data")
