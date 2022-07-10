local modpath = minetest.get_modpath("ch_core")

-- BARVY
-- ===========================================================================

local nametag_color_red = minetest.get_color_escape_sequence("#cc5257");
local nametag_color_blue = minetest.get_color_escape_sequence("#6693ff");
local nametag_color_green = minetest.get_color_escape_sequence("#48cc3d");
local nametag_color_yellow = minetest.get_color_escape_sequence("#fff966");
local nametag_color_aqua = minetest.get_color_escape_sequence("#66f8ff");
local nametag_color_gray = minetest.get_color_escape_sequence("#999999");
local color_reset = minetest.get_color_escape_sequence("#ffffff");

local nametag_color_bgcolor = {r = 0, g = 0, b = 0, a = 0}
local nametag_color_normal = {r = 255, g = 255, b = 255, a = 255}
local nametag_color_unregistered = {r = 153, g = 153, b = 153, a = 255}

-- POZICE A OBLASTI
-- ===========================================================================

ch_core.unregistered_spawn = vector.new(-70,9.5,40)
ch_core.registered_spawn = ch_core.unregistered_spawn

-- DATA O POSTAVÁCH
-- ===========================================================================
-- TODO: Separate!
local storage = ch_core.storage

ch_core.online_charinfo = {}
ch_core.offline_charinfo = {}
local old_online_charinfo = {}

function ch_core.get_offline_charinfo(player_name)
	local result = ch_core.offline_charinfo[player_name]
	if not result then
		minetest.log("action", "Will create offline_charinfo for player '"..player_name.."'")
		result = {}
		ch_core.offline_charinfo[player_name] = result
	end
	return result
end

function ch_core.delete_offline_charinfo(player_name)
	ch_core.offline_charinfo[player_name] = nil
	for key, _ in pairs((storage:to_table() or {}).fields or {}) do
		local i = string.find(key, "/")
		if i == #player_name + 1 and key:sub(1, #player_name) == player_name then
			storage:set_string(key, "")
			minetest.log("info", "[ch_core] Key '"..key.."' removed from mod storage.")
		end
	end
	return true
end

-- Vrátí online_charinfo připojující se postavy;
-- tato funkce smí být volána pouze z obsluhy „on_joinplayer“!
function ch_core.get_joining_online_charinfo(player_name)
	local result = ch_core.online_charinfo[player_name]
	if not result then
		-- the first call => create a new online_charinfo
		result = { join_timestamp = os.time() }
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
		print("LEAVE PLAYER(" .. player_name ..") at "..os.time());
		return result
	else
		return old_online_charinfo[player_name] or {}
	end
	
	return ch_core.online_charinfo[player_name] or old_online_charinfo[player_name] or {}
end

-- datatype = "string"|"int"|"float"|"nil"
function ch_core.save_offline_charinfo(player_name, data_type, key)
	local offline_charinfo = ch_core.offline_charinfo[player_name]
	if not offline_charinfo then
		return false
	end
	local value = offline_charinfo[key]
	key = player_name.."/"..key
	if data_type ~= "nil" and value then
		if data_type == "string" then
			storage:set_string(key, value)
		elseif data_type == "int" then
			storage:set_int(key, value)
		elseif data_type == "float" then
			storage:set_float(key, value)
		else
			error("Unsupported data type '"..datatype.."'!")
		end
	else
		-- delete key
		storage:set_string(key, "")
	end
	return true
end

function ch_core.set_titul(player_name, titul)
	ch_core.get_offline_charinfo(player_name).titul = titul
	ch_core.save_offline_charinfo(player_name, "string", "titul")
	return ch_core.update_player_nametag(player_name)
end

function ch_core.update_player_nametag(player_name)
	local offline_charinfo = ch_core.get_offline_charinfo(player_name)
	local player = minetest.get_player_by_name(player_name)
	local player_info = ch_core.get_offline_charinfo(player_name)

	if not player or not player_info then
		minetest.log("warning", "update_player_nametag() called, but player or player_info are missing for player '"..player_name.."'!")
		return false
	end

	local nametag = {bgcolor = nametag_color_bgcolor}
	local barevne_jmeno = player_info.barevne_jmeno or player_info.jmeno or player_name

	print("DEBUG: barevne_jmeno = "..(player_info.barevne_jmeno or "nil")..", jmeno = "..(player_info.jmeno or "nil"))

	if string.sub(player_name, -2) == "PP" then
		nametag.color = nametag_color_unregistered
		nametag.text = "*pomocná postava*\n"..barevne_jmeno
	elseif minetest.check_player_privs(player, "ch_registered_player") then
		nametag.color = nametag_color_normal
		nametag.text = player_info.titul or ""
		if nametag.text == "" then
			nametag.text = barevne_jmeno
		else
			nametag.text = "*"..nametag.text.."*\n"..barevne_jmeno
		end
	else
		nametag.color = nametag_color_unregistered
		nametag.text = "*nová postava*\n"..barevne_jmeno
	end
	print("DEBUG: will set nametag attributes: text = "..nametag.text.." (delka="..#(nametag.text)..")")

	player:set_nametag_attributes(nametag)
	return true
end

-- restore offline data from the storage
local counter = 0
for key, value in pairs((storage:to_table() or {}).fields or {}) do
	local i = string.find(key, "/")
	if i then
		local player_name = key:sub(1, i - 1)
		local table_key = key:sub(i + 1, -1)
		local offline_charinfo = ch_core.get_offline_charinfo(player_name)
		offline_charinfo[table_key] = value
		counter = counter + 1
	else
		minetest.log("warning", "Invalid key '"..key.."' in mod storage!")
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
		local current_playtime = os.time() - online_info.join_timestamp
		local total_playtime = (offline_info.past_playtime or 0) + current_playtime

		offline_info.past_playtime = total_playtime
		ch_core.save_offline_charinfo(player_name, "float", "past_playtime")
		online_info.join_timestamp = nil
		print("PLAYER(" .. player_name .."): played seconds: " .. current_playtime .. " / " .. total_playtime);
	end
end

local function on_shutdown()
	for player_name, online_info in pairs(table.copy(ch_core.online_charinfo)) do
		if online_info.join_timestamp then
			local offline_info = ch_core.get_offline_charinfo(player_name)
			local current_playtime = os.time() - online_info.join_timestamp
			local total_playtime = (offline_info.past_playtime or 0) + current_playtime

			offline_info.past_playtime = total_playtime
			ch_core.save_offline_charinfo(player_name, "float", "past_playtime")
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

ch_core.submod_loaded("data")
