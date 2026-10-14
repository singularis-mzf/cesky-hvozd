ch_core.open_submod("data")

-- POZICE A OBLASTI
-- ===========================================================================

local function setting_get_pos(name, setting_level)
	local result = minetest.setting_get_pos(name)
	if result ~= nil then
		minetest.log("action", "Position setting "..name.." read: "..minetest.pos_to_string(result))
	elseif setting_level == "required" then
		error("Required position setting "..name.." not set or have an invalid format!")
	elseif setting_level == "optional" then
		minetest.log("action", "Position setting "..name.." not set (optional).")
	else
		minetest.log("error", "Position setting "..name.." not set! Will be reset to zeroes.")
		result = vector.zero()
	end
	return result
end

local function setting_get_str(name, setting_level)
	local result = minetest.settings:get(name)
	if result ~= nil then
		minetest.log("action", "String setting "..name.." read: "..result)
	elseif setting_level == "required" then
		error("Required string setting "..name.." not set!")
	elseif setting_level == "optional" then
		minetest.log("action", "String setting "..name.." not set (optional).")
	else
		minetest.log("error", "String setting "..name.." not set! Will be reset to an empty string")
		result = ""
	end
	return result
end

ch_core.config = {
	povinne_vytisky_listname = setting_get_str("ch_povinne_vytisky_listname", "optional") or "main",
}

ch_core.positions = {
	zacatek_1 = setting_get_pos("static_spawnpoint") or vector.new(-70,9.5,40),
	zacatek_2 = setting_get_pos("ch_zacatek_2"),
	zacatek_3 = setting_get_pos("ch_zacatek_3"),
	vezeni_min = setting_get_pos("ch_vezeni_min"),
	vezeni_max = setting_get_pos("ch_vezeni_max"),
	vezeni_cil = setting_get_pos("ch_vezeni_cil"),
	vezeni_dvere = setting_get_pos("ch_vezeni_dvere", "optional"),
	povinne_vytisky = setting_get_pos("ch_povinne_vytisky", "optional"),
}

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
}

local initial_global_data = {
	pristi_ick = 10000,
}

for k, t in pairs(global_data_data_types) do
	if initial_global_data[k] == nil then
		initial_global_data[k] = zero_by_type[t]
	end
end

local storage = ch_core.storage
ch_core.global_data = table.copy(initial_global_data)

ch_data.is_acceptable_name = function(player_name)
	local types = {}
	for i = 1, #player_name do
		local b = string.byte(player_name, i)
		if b == 0x2d or b == 0x5f then
			types[i] = '_'
		elseif 0x30 <= b and b <= 0x39 then
			types[i] = '0'
		elseif b < 0x61 then
			types[i] = 'A'
		else
			types[i] = 'a'
		end
	end
	local digits, dashes = 0, 0
	for i = 1, #player_name do
		if types[i] == '0' then
			digits = digits + 1
		elseif digits > 0 then
			-- číslice jsou dovoleny jen na konci jména
			return false
		elseif types[i] == '_' then
			dashes = dashes + 1
			-- pomlčky a podtržítka jsou dovoleny jen mezi písmeny
			if i == 1 or i == #player_name or string.lower(types[i - 1]) ~= 'a' or string.lower(types[i + 1]) ~= 'a' then
				return false
			end
		end
	end
	return digits <= 4 and dashes <= 5 -- omezení počtu
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

function ch_core.set_titul(player_name, titul)
	local offline_charinfo = ch_data.get_offline_charinfo(player_name)
	offline_charinfo.titul = titul
	ch_data.save_offline_charinfo(player_name)
	local online_charinfo = ch_data.online_charinfo[player_name]
	local player = core.get_player_by_name(player_name)
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
	local online_charinfo = ch_data.online_charinfo[player_name]
	if not online_charinfo or not titul or titul == "" then return false end
	local dtituly = ch_core.get_or_add(online_charinfo, "docasne_tituly")
	if titul_enabled then
		dtituly[titul] = 1
	else
		dtituly[titul] = nil
	end
	local player = core.get_player_by_name(player_name)
	if player and ch_core.compute_player_nametag then
		player:set_nametag_attributes(ch_core.compute_player_nametag(online_charinfo, ch_data.get_offline_charinfo(player_name)))
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
local storage_table = (storage:to_table() or {}).fields or {}
for full_key, value in pairs(storage_table) do
	local player_name, key = full_key:match("^([^/]*)/(.+)$")
	if player_name == "" and key ~= "" then
		local data_type = global_data_data_types[key]
		ch_core.global_data[key] = restore_value_by_type(data_type, value, "global property "..key)
		global_counter = global_counter + 1
	else
		storage:set_string(full_key, "")
		core.log("warning", "Invalid key '"..full_key.."' (value "..value..") removed from mod storage!")
		delete_counter = delete_counter + 1
	end
end
print("[ch_core] Restored "..player_field_counter.." data pairs of "..player_counter.." players and "..global_counter.." global pairs from the mod storage. "..delete_counter.." was deleted.")

-- Check and update keys
for key, data_type in pairs(global_data_data_types) do
	if ch_core.global_data[key] == nil and data_type ~= "nil" then
		ch_core.global_data[key] = zero_by_type[data_type]
	end
end

def = {
	description = "Zaznamená do příslušného souboru co nejvíc údajů o aktuálním stavu hráčské postavy. Pouze pro Administraci.",
	params = "<Jmeno_postavy>",
	privs = {server = true},
	func = function(admin_name, player_name)
		local player = core.get_player_by_name(player_name)
		if player == nil then
			return false, "Postava neexistuje!"
		end
		player_name = player:get_player_name()
		local inv = player:get_inventory()
		local result = {
			player_name = player_name,
			pos = player:get_pos(),
			velocity = player:get_velocity(),
			hp = player:get_hp(),
			inv_main = inv:get_list("main"),
			inv_craft = inv:get_list("craft"),
			wield_index = player:get_wield_index(),
			armor_groups = player:get_armor_groups(),
			animation = player:get_animation(),
			attachment = {player:get_attach()},
			children = player:get_children(),
			bone_overrides = player:get_bone_overrides(),
			properties = player:get_properties(),
			is_player = player:is_player(),
			nametag_attributes = player:get_nametag_attributes(),
			look_dir = player:get_look_dir(),
			look_vertical = player:get_look_vertical(),
			look_horizontal = player:get_look_horizontal(),
			breath = player:get_breath(),
			fov = {player:get_fov()},
			meta = player:get_meta():to_table(),
			player_control = player:get_player_control(),
			player_control_bits = player:get_player_control_bits(),
			physics_override = player:get_physics_override(),
			huds = player:hud_get_all(),
			hud_flags = player:hud_get_flags(),
			hotbar_size = player:hud_get_hotbar_itemcount(),
			hotbar_image = player:hud_get_hotbar_image(),
			hotbar_selected_image = player:hud_get_hotbar_selected_image(),
			sky = player:get_sky(),
			sun = player:get_sun(),
			moon = player:get_moon(),
			stars = player:get_stars(),
			clouds = player:get_clouds(),
			day_night_ratio_override = player:get_day_night_ratio(),
			local_animation = {player:get_local_animation()},
			eye_offset = {player:get_eye_offset()},
			lighting = player:get_lighting(),
			flags = player:get_flags(),
			online_charinfo = ch_data.online_charinfo[player_name] or "nil",
			offline_charinfo = ch_data.offline_charinfo[player_name] or "nil",
		}
		result = dump2(result)
		local parts = string.split(result, "\n_[")
		table.sort(parts)
		result = table.concat(parts, "\n_[")
		local path = core.get_worldpath().."/_dump_"..player_name..".txt"
		core.safe_file_write(path, result)
		return true, "Zaznamenáno do: "..path
	end,
}

core.register_chatcommand("dumpplayer", def)

ch_core.close_submod("data")
