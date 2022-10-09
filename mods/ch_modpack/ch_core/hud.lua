ch_core.open_submod("hud", {chat = true, data = true, lib = true})

-- PLAYER LIST
local base_y_offset = 90
local y_scale = 20

local text_hud_defaults = {
	hud_elem_type = "text",
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
	for c_player_name, c_online_charinfo in pairs(ch_core.online_charinfo) do
		local c_offline_charinfo = ch_core.offline_charinfo[c_player_name]
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
		hud_elem_type = "image",
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

-- CH_HUDBARS

local has_hudbars = minetest.get_modpath("hudbars")
if not has_hudbars then
	ch_core.count_of_ch_hudbars = 0
else
	ch_core.count_of_ch_hudbars = 4

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
	local online_charinfo = ch_core.online_charinfo[player:get_player_name()]
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
	local online_charinfo = ch_core.online_charinfo[player:get_player_name()]
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
	hud_elem_type = "text",
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
	datetime_huds[player_name] = player:hud_add(datetime_hud_defaults)
end

local function on_leaveplayer(player, timed_out)
	local player_name = player:get_player_name()
	datetime_huds[player_name] = nil
end

local weekdays = {"neděle", "pondělí", "úterý", "středa", "čtvrtek", "pátek", "sobota"}
local monthnames = {"ledna", "února", "března", "dubna", "května", "června", "července", "srpna", "září", "října", "listopadu", "prosince"}
local acc_time = 0

local function on_step(dtime)
	acc_time = acc_time + dtime
	if acc_time > 0.5 then
		local time = os.time()
		local offset
		if os.date("*t", time).isdst then
			offset = "+02:00"
			-- time = time + 7200
		else
			offset = "+01:00"
			-- time = time + 3600
		end
		local t = os.date("*t", time)
		local time_text = string.format("%s\n%d. %s %s\n%02d:%02d %s", weekdays[t.wday], t.day, monthnames[t.month], t.year, t.hour, t.min, offset)
		for player_name, hud_id in pairs(datetime_huds) do
			local player = minetest.get_player_by_name(player_name)
			if player then
				player:hud_change(hud_id, "text", time_text)
			end
		end
	end
end

local function clear_datetime_hud(player_name, param)
	local hud_id = datetime_huds[player_name]
	local player = minetest.get_player_by_name(player_name)
	if hud_id and player then
		player:hud_remove(hud_id)
		datetime_huds[player_name] = nil
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
