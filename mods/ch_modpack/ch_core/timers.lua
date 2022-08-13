ch_core.require_submod("timers", "data")
ch_core.require_submod("timers", "hud")
ch_core.require_submod("timers", "chat")

ch_core.count_of_ch_timer_hudbars = 4

local timer_bar_icon = "default_snowball.png"
local timer_bar_bgicon = nil
local timer_bar_bar = "hudbars_bar_timer.png"

function ch_core.start_ch_timer(online_charinfo, timer_id, delay, label, func, text_color)
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
	local now = os.clock()
	local new_timer = {
		started_at = now,
		run_at = now + delay,
		func = func,
	}
	timers[timer_id] = new_timer
	local player = minetest.get_player_by_name(online_charinfo.player_name)
	local hudbar_id = player and ch_core.try_alloc_hudbar(player)
	if hudbar_id then
		new_timer.hudbar = hudbar_id
		new_timer.last_hud_value = math.ceil(delay)
		hb.change_hudbar(player, hudbar_id, new_timer.last_hud_value, new_timer.last_hud_value, timer_bar_icon, timer_bar_bgicon, timer_bar_bar, label, text_color or 0xFFFFFF)
		if delay >= 0.1 then
			hb.unhide_hudbar(player, hudbar_id)
		end
	end
	return true
end

function ch_core.is_ch_timer_running(online_charinfo, timer_id)
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
		if not online_charinfo then
			return false, "Vnitřní chyba serveru."
		end
		ch_core.cancel_ch_timer(online_charinfo, "custom_timer")
		if param ~= "" then
			local timer_func = function()
				ch_core.systemovy_kanal(player_name, "Nastavený časovač vypršel.")
			end
			ch_core.start_ch_timer(online_charinfo, "custom_timer", tonumber(param), "odpočet", timer_func)
		end
		return true
	end,
}
minetest.register_chatcommand("odpočítat", def)

ch_core.submod_loaded("timers")
