ch_core.open_submod("timers", {data = true, hud = true, chat = true})

ch_core.count_of_ch_timer_hudbars = 4

local default_timer_bar_icon = "default_snowball.png"
local default_timer_bar_bar = "hudbars_bar_timer.png"

-- timer_def - podporované klíče:
--  - label -- textový popis pro HUD, může být prázdný řetězec (volitelná)
--  - func -- funkce bez parametrů, která má být spušŧěna po vypršení časovače; může být nil
--  - hudbar_icon -- ikona pro HUD (volitelná)
--  - hudbar_bgicon -- ikona pro HUD na pozadí (volitelná)
--  - hudbar_bar -- textura pro HUD (volitelná)
--  - hudbar_text_color -- barva textu pro HUD (volitelná)
function ch_core.start_ch_timer(online_charinfo, timer_id, delay, timer_def)
	local timers = online_charinfo.ch_timers
	if not timers then
		timers = {}
		online_charinfo.ch_timers = timers
	elseif timers[timer_id] then
		return false -- timer is already running
	end
	if delay < 0.0 then
		error("Negative delay at start_ch_timer()!")
	end
	local now = ch_core.cas
	local new_timer = timer_def or {}
	new_timer = table.copy(new_timer)
	new_timer.started_at = now
	new_timer.run_at = now + delay
	timers[timer_id] = new_timer
	local player = minetest.get_player_by_name(online_charinfo.player_name)
	local hudbar_id = player and ch_core.try_alloc_hudbar(player)
	if hudbar_id then
		new_timer.hudbar = hudbar_id
		new_timer.last_hud_value = math.ceil(delay)
		hb.change_hudbar(player,
			hudbar_id,
			new_timer.last_hud_value,
			new_timer.last_hud_value,
			new_timer.hudbar_icon or default_timer_bar_icon,
			new_timer.hudbar_bgicon,
			new_timer.hudbar_bar or default_timer_bar_bar,
			new_timer.label or "časovač",
			new_timer.hudbar_text_color or 0xFFFFFF)
		if delay >= 0.1 then
			hb.unhide_hudbar(player, hudbar_id)
		end
	end
	return true
end

function ch_core.is_ch_timer_running(online_charinfo, timer_id)
	local timers = online_charinfo.ch_timers
	if timers and timers[timer_id] then
		return true
	else
		return false
	end
end

function ch_core.get_ch_timer_info(online_charinfo, timer_id)
	local timers = online_charinfo.ch_timers
	return timers and timers[timer_id]
end

function ch_core.cancel_ch_timer(online_charinfo, timer_id)
	local timers = online_charinfo.ch_timers
	local timer = timers and timers[timer_id]
	if not timer then
		return false
	end
	if timer.hudbar then
		local player = minetest.get_player_by_name(online_charinfo.player_name)
		hb.hide_hudbar(player, timer.hudbar)
		ch_core.free_hudbar(player, timer.hudbar)
	end
	timers[timer_id] = nil
	return true
end

local def = {
	params = "[početsekund]",
	description = "Odpočítá zadaný počet sekund. Při použití bez parametru jen zruší probíhající odpočet.",
	privs = {},
	func = function(player_name, param)
		local online_charinfo = ch_core.online_charinfo[player_name]
		if param == "" then
			ch_core.cancel_ch_timer(online_charinfo, "custom_timer")
			return true
		end
		local sekund = param:gsub(",", ".")
		sekund = tonumber(sekund)
		if not sekund or sekund < 0 then
			return false, "Neplatné zadání!"
		end
		if not online_charinfo then
			return false, "Vnitřní chyba serveru."
		end
		ch_core.cancel_ch_timer(online_charinfo, "custom_timer")
		local timer_func = function()
			ch_core.systemovy_kanal(player_name, "Nastavený časovač vypršel.")
		end
		ch_core.start_ch_timer(online_charinfo, "custom_timer", sekund, {label = "odpočet", func = timer_func})
		return true
	end,
}
minetest.register_chatcommand("odpočítat", def)
minetest.register_chatcommand("odpocitat", def)

ch_core.close_submod("timers")
