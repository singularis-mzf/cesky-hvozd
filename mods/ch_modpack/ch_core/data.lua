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
	past_playtime = "float",
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

local storage = ch_core.storage

ch_core.online_charinfo = {}
ch_core.offline_charinfo = {}
local old_online_charinfo = {}

function ch_core.get_offline_charinfo(player_name)
	local result = ch_core.offline_charinfo[player_name]
	if not result then
		minetest.log("action", "Will create offline_charinfo for player '"..player_name.."'")
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
		result = {
			join_timestamp = ch_core.cas,
			player_name = player_name,
		}
		ch_core.online_charinfo[player_name] = result
		old_online_charinfo[player_name] = nil
		print("JOIN PLAYER(" .. player_name ..") at "..result.join_timestamp);
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

--[[
function ch_core.update_player_nametag(player_name)
	local online_charinfo = ch_core.online_charinfo[player_name] -- may be null
	local offline_charinfo = ch_core.get_offline_charinfo(player_name)
	local player = minetest.get_player_by_name(player_name)

	if not player or not offline_charinfo then
		minetest.log("warning", "update_player_nametag() called, but player or offline_charinfo are missing for player '"..player_name.."'!")
		return false
	end

	local nametag = {
		bgcolor = nametag_color_bgcolor_table,
	}

	local titul, barevne_jmeno, local_color_reset, staly_titul

	if string.sub(player_name, -2) == "PP" then
		-- pomocná postava
		local_color_reset = nametag_color_grey
		nametag.color = nametag_color_unregistered
		staly_titul = "pomocná postava"
	elseif minetest.check_player_privs(player, "ch_registered_player") then
		local_color_reset = color_reset
		nametag.color = nametag_color_normal_table
		staly_titul = offline_charinfo.titul
		if staly_titul and staly_titul == "" then
			staly_titul = nil
		end
	else
		-- neregistrovaná postava
		local_color_reset = nametag_color_grey
		nametag.color = nametag_color_unregistered_table
		staly_titul = "nová postava"
	end

	local docasne_tituly = (online_charinfo and online_charinfo.docasne_tituly) or {}
	for dtitul, _ in pairs(docasne_tituly) do
		titul = (titul or "").."*"..dtitul.."*\n"
	end
	if titul then
		-- dočasný titul
		titul = nametag_color_green..titul..local_color_reset
	elseif staly_titul then
		-- trvalý titul
		titul = "*"..staly_titul.."*\n"
	else
		titul = ""
	end

	barevne_jmeno = offline_charinfo.barevne_jmeno or offline_charinfo.jmeno or player_name
	nametag.text = titul..barevne_jmeno

	player:set_nametag_attributes(nametag)
	return true
end
]]

-- restore offline data from the storage
local counter = 0
for full_key, value in pairs((storage:to_table() or {}).fields or {}) do
	local player_name, key = full_key:match("^([^/]*)/(.+)$")
	if player_name and player_name ~= "" then
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
	end
end
print("[ch_core] Restored "..counter.." data pairs from the mod storage.")

local function on_joinplayer(player, last_login)
	ch_core.get_joining_online_charinfo(player:get_player_name())
	return true
end

local function on_leaveplayer(player, timedout)
	local player_name = player:get_player_name()
	local online_info = ch_core.get_leaving_online_charinfo(player_name)

	if online_info.join_timestamp then
		local offline_info = ch_core.get_offline_charinfo(player_name)
		local current_playtime = ch_core.cas - online_info.join_timestamp
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

minetest.register_on_joinplayer(on_joinplayer)
minetest.register_on_leaveplayer(on_leaveplayer)
minetest.register_on_shutdown(on_shutdown)

--[[
storage:set_string("postavy/Administrace/titul", "správa serveru")
storage:set_string("postavy/Administrace/jmeno", "Administrace")
storage:set_string("postavy/Administrace/barevne_jmeno", nametag_color_red .. "Admin" .. nametag_color_blue .. "istrace" .. color_reset)
storage:set_string("postavy/Stepanka/jmeno", "Štěpánka")
storage:set_string("postavy/Zaneta_Novakova/jmeno", "Žaneta Nováková")
]]

ch_core.close_submod("data")
