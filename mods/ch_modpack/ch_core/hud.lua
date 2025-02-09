ch_core.open_submod("hud", {chat = true, data = true, lib = true})

local ifthenelse = ch_core.ifthenelse

-- PLAYER LIST
local base_y_offset = 90
local y_scale = 20

local text_hud_defaults = {
	type = "text",
	position = { x = 0.5, y = 0 },
	-- offset
	-- text
	alignment = { x = 1, y = 1 },
	scale = { x = 100, y = 100 },
	number = 0xFFFFFF,
}

function ch_core.show_player_list(player, online_charinfo)
	if online_charinfo.player_list_huds then
		return false
	end

	-- gether the list of players
	local items = {}
	for c_player_name, c_online_charinfo in pairs(ch_data.online_charinfo) do
		local c_offline_charinfo = ch_data.offline_charinfo[c_player_name]
		local titul = c_offline_charinfo and c_offline_charinfo.titul
		local dtituly = c_online_charinfo.docasne_tituly or {}

		if not titul then
			if string.sub(c_player_name, -2) == "PP" then
				titul = "pomocná postava"
			elseif not minetest.check_player_privs(c_player_name, "ch_registered_player") then
				titul = "nová postava"
			end
		end

		local zobrazovaci_jmeno = ch_core.prihlasovaci_na_zobrazovaci(c_player_name)
		local text = zobrazovaci_jmeno
		if titul then
			text = text.." ["..titul.."]"
		end
		for dtitul, _ in pairs(dtituly) do
			text = text.." ["..dtitul.."]"
		end
		table.insert(items, { name = zobrazovaci_jmeno, text = text })
	end

	-- sort the list
	table.sort(items, function(a, b) return ch_core.utf8_mensi_nez(a.name, b.name, true) end)

	local huds, new_hud
	local hud_defs = {}

	for _, item in ipairs(items) do
		new_hud = table.copy(text_hud_defaults)
		new_hud.offset = { x = 5, y = base_y_offset + 3 + #hud_defs * y_scale }
		new_hud.text = item.text
		table.insert(hud_defs, new_hud)
	end
	new_hud = {
		type = "image",
		alignment = { x = -1, y = 1 },
		position = { x = 1, y = 0 },
		offset = { x = 0, y = base_y_offset },
		text = "ch_core_white_pixel.png^[multiply:#333333^[opacity:128",
		scale = { x = -50, y = #hud_defs * y_scale + 8 },
		number = text_hud_defaults.number,
	}
	huds = {
		player:hud_add(new_hud)
	}
	online_charinfo.player_list_huds = huds
	for i, hud_def in ipairs(hud_defs) do
		huds[i + 1] = player:hud_add(hud_def)
	end
	return true
end

function ch_core.hide_player_list(player, online_charinfo)
	if not online_charinfo.player_list_huds then
		return false
	end
	local huds = online_charinfo.player_list_huds
	online_charinfo.player_list_huds = nil
	for _, hud_id in ipairs(huds) do
		player:hud_remove(hud_id)
	end
	return true
end

local has_hudbars = minetest.get_modpath("hudbars")

-- GAME TIME HUDBAR
if has_hudbars then
	local icon_day = "ch_core_slunce.png^[resize:20x20"
	local icon_night = "moon.png^[resize:20x20"
	local bar_day = "hudbars_bar_day.png"
	local bar_night = "hudbars_bar_night.png"

	hb.register_hudbar("ch_gametime", 0xCCCCCC, "", {icon = icon_day, bgicon = nil, bar = bar_day},
		0, 100, true, "@1 min.", {order = {"value"}, textdomain = "hudbars"})

	local function after_joinplayer(player_name)
		local player = minetest.get_player_by_name(player_name)
		if player ~= nil then
			local offline_charinfo = ch_data.offline_charinfo[player_name]
			if offline_charinfo ~= nil and offline_charinfo.skryt_zbyv ~= 1 then
				hb.unhide_hudbar(player, "ch_gametime")
				ch_core.update_gametime_hudbar({player})
			end
		end
	end

	local function on_joinplayer(player, last_login)
		hb.init_hudbar(player, "ch_gametime")
		minetest.after(1, after_joinplayer, player:get_player_name())
	end
	minetest.register_on_joinplayer(on_joinplayer)

	function ch_core.show_gametime_hudbar(player_name)
		local offline_charinfo = ch_data.offline_charinfo[player_name]
		if offline_charinfo ~= nil and offline_charinfo.skryt_zbyv ~= 0 then
			offline_charinfo.skryt_zbyv = 0
			ch_data.save_offline_charinfo(player_name)
			local player = minetest.get_player_by_name(player_name)
			if player ~= nil then
				hb.unhide_hudbar(player, "ch_gametime")
				ch_core.update_gametime_hudbar({player})
			end
			return true
		end
		return false
	end

	function ch_core.hide_gametime_hudbar(player_name)
		local offline_charinfo = ch_data.offline_charinfo[player_name]
		if offline_charinfo ~= nil and offline_charinfo.skryt_zbyv ~= 1 then
			offline_charinfo.skryt_zbyv = 1
			ch_data.save_offline_charinfo(player_name)
			local player = minetest.get_player_by_name(player_name)
			if player ~= nil then
				hb.hide_hudbar(player, "ch_gametime")
			end
			return true
		end
		return false
	end

	function ch_core.is_gametime_hudbar_shown(player_name)
		local offline_charinfo = ch_data.offline_charinfo[player_name]
		return offline_charinfo ~= nil and offline_charinfo.skryt_zbyv ~= 1
	end

	local cache_time_speed = 0
	local cache_is_night
	local cache_value = -1
	local dawn = 330
	local dusk = 1140

	function ch_core.update_gametime_hudbar(players, timeofday)
		local skip_cache = players ~= nil
		if players == nil then
			players = {}
			for _, player in ipairs(minetest.get_connected_players()) do
				local player_name = player:get_player_name()
				local offline_charinfo = ch_data.offline_charinfo[player_name] or {}
				if offline_charinfo.skryt_zbyv ~= 1 then
					table.insert(players, player)
				end
			end
		end
		if #players == 0 then
			return -- no players
		end

		local tod = timeofday or minetest.get_timeofday()
		if tod == nil then return end
		tod = tod * 1440 -- převést na počet herních minut
		local is_night = tod < dawn or tod >= dusk
		local time_speed = tonumber(minetest.settings:get("time_speed"))
		if time_speed == nil then
			minetest.log("warning", "[ch_core/hud] Cannot determine time_speed!")
			time_speed = 72
		end

		local new_value, new_max_value, new_icon, new_bar
		if is_night then
			new_value = math.ceil((ifthenelse(tod >= dusk, 1440 + dawn, dawn) - tod) / time_speed)
			if skip_cache or time_speed ~= cache_time_speed or cache_is_night ~= is_night then
				new_icon, new_bar = icon_night, bar_night
				new_max_value = math.ceil((1440 - (dusk - dawn)) / time_speed)
				cache_is_night, cache_time_speed = is_night, time_speed -- update cache
			end
		else
			new_value = math.ceil((dusk - tod) / time_speed)
			if skip_cache or time_speed ~= cache_time_speed or cache_is_night then
				new_icon, new_bar = icon_day, bar_day
				new_max_value = math.ceil((dusk - dawn) / time_speed)
				cache_is_night, cache_time_speed = is_night, time_speed -- update cache
			end
		end
		if skip_cache or new_value ~= cache_value then
			cache_value = new_value
		else
			if new_max_value == nil and new_icon == nil then
				return true -- nothing to update
			end
			new_value = nil -- don't update value if not necesarry
		end
		for _, player in ipairs(players) do
			hb.change_hudbar(player, "ch_gametime", new_value, new_max_value, new_icon, nil, new_bar)
		end
		return true
	end
else
	function ch_core.show_gametime_hudbar(player_name)
		return
	end

	function ch_core.hide_gametime_hudbar(player_name)
		return
	end

	function ch_core.update_gametime_hudbar(players, tod)
		return
	end

	function ch_core.is_gametime_hudbar_shown(player_name)
		return false
	end
end

-- CH_HUDBARS

if not has_hudbars then
	ch_core.count_of_ch_hudbars = 0
else
	ch_core.count_of_ch_hudbars = 2

	local hudbar_formatstring = "@1: @2"
	local hudbar_formatstring_config = {
		order = { "label", "value" },
		textdomain = "hudbars",
	}
	local hudbar_defaults = {
		icon = "default_snowball.png", bgicon = nil, bar = "hudbars_bar_timer.png"
	}
	for i = 1, ch_core.count_of_ch_hudbars, 1 do
		hb.register_hudbar("ch_hudbar_"..i, 0xFFFFFF, "x", hudbar_defaults, 0, 100, true, hudbar_formatstring, hudbar_formatstring_config)
	end
	minetest.register_on_joinplayer(function(player, last_login)
		for i = 1, ch_core.count_of_ch_hudbars, 1 do
			hb.init_hudbar(player, "ch_hudbar_"..i, 0, 100, true)
		end
	end)
end

function ch_core.try_alloc_hudbar(player)
	local online_charinfo = ch_data.online_charinfo[player:get_player_name()]
	if online_charinfo then
		local hudbars = online_charinfo.hudbars
		if not hudbars then
			hudbars = {}
			online_charinfo.hudbars = hudbars
		end
		for i = 1, ch_core.count_of_ch_hudbars, 1 do
			if not hudbars[i] then
				local result = "ch_hudbar_"..i
				hudbars[i] = result
				return result
			end
		end
	end
	return nil
end

function ch_core.free_hudbar(player, hudbar_id)
	local online_charinfo = ch_data.online_charinfo[player:get_player_name()]
	if not online_charinfo then
		minetest.log("warning", "Cannot get online_charinfo of player "..player:get_player_name().." to free a hudbar "..hudbar_id.."!")
		return false
	end
	local hudbars = online_charinfo.hudbars
	if not hudbars then
		hudbars = {}
		online_charinfo.hudbars = hudbars
	end

	if hudbar_id:sub(1, 10) == "ch_hudbar_" then
		local hudbar_index = tonumber(hudbar_id:sub(11, -1))
		if 1 <= hudbar_index and hudbar_index <= ch_core.count_of_ch_hudbars then
			if hudbars[hudbar_index] then
				hudbars[hudbar_index] = nil
				hb.hide_hudbar(player, hudbar_id)
				return true
			else
				return false -- not allocated
			end
		end
	end
	minetest.log("error", "Invalid hudbar_id to free: "..hudbar_id)
	return false
end

-- DATE AND TIME HUD
local datetime_hud_defaults = {
	type = "text",
	position = { x = 1, y = 1 },
	offset = { x = -5, y = -5 },
	text = "",
	alignment = { x = -1, y = -1 },
	scale = { x = 100, y = 100 },
	number = 0x999999,
	style = 2,
	z_index = 50,
}

local datetime_huds = {
}

local function on_joinplayer(player, last_login)
	local player_name = player:get_player_name()
	datetime_huds[player_name] = {
		counter = 0,
		hud_id = player:hud_add(datetime_hud_defaults),
		hud_text = "",
	}
end

local function on_leaveplayer(player, timed_out)
	local player_name = player:get_player_name()
	datetime_huds[player_name] = nil
end

local acc_time = 0

local function on_step(dtime)
	acc_time = acc_time + dtime
	if acc_time > 0.5 then
		local cas = ch_time.aktualni_cas()
		local text = string.format("%s\n%d. %s %s\n%02d:%02d %s",
			cas:den_v_tydnu_nazev(), cas.den, cas:nazev_mesice(2), cas.rok, cas.hodina, cas.minuta, cas:posun_text())
		for player_name, record in pairs(datetime_huds) do
			local player = minetest.get_player_by_name(player_name)
			if player ~= nil then
				local ltext = ch_core.prihlasovaci_na_zobrazovaci(player_name).."\n"..text
				if record.hud_text ~= ltext then
					record.hud_text = ltext
					ltext = ltext.." ["..record.counter.."]"
					player:hud_change(record.hud_id, "text", ltext)
					record.counter = record.counter + 1
				end
			end
		end
	end
end

function ch_core.clear_datetime_hud(player)
	local player_name = player:get_player_name()
	local hud = datetime_huds[player_name]
	if hud then
		player:hud_remove(hud.hud_id)
		datetime_huds[player_name] = nil
		return true
	else
		return false
	end
end

local function clear_datetime_hud(player_name, param)
	local player = minetest.get_player_by_name(player_name)
	if player ~= nil and ch_core.clear_datetime_hud(player) then
		return true
	else
		ch_core.systemovy_kanal(player_name, "CHYBA: okno s datem a časem nenalezeno, možná už je skyto.")
	end
end

local cc_def = {
	description = "Do odhlášení skryje z obrazovky datum a čas.",
	func = clear_datetime_hud,
}

minetest.register_on_joinplayer(on_joinplayer)
minetest.register_on_leaveplayer(on_leaveplayer)
minetest.register_globalstep(on_step)
minetest.register_chatcommand("skrýtčas", cc_def)
minetest.register_chatcommand("skrytcas", cc_def)

ch_core.close_submod("hud")
