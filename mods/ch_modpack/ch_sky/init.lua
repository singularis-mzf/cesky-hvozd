print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

ch_sky = {}

function ch_sky.colorize_sky(player, ratio, color)
	if color ~= nil and type(color) ~= "string" then
		error("ch_sky.colorize_sky() supports only string as color!")
	end
	local player_name = player:get_player_name()
-- 	-- print("DEBUG: ch_sky.colorize_sky(): "..dump2({player_name = player_name, ratio = ratio, color = color}))
	local online_skyinfo = ch_core.safe_get_4(ch_core, "online_charinfo", player_name, "sky_info")
	if online_skyinfo == nil then
		return
	end
	if ratio == 0 then
		online_skyinfo.colorize_color = nil
		online_skyinfo.colorize_ratio = nil
	else
		online_skyinfo.colorize_ratio = ratio
		if color ~= nil then
			online_skyinfo.colorize_color = color
		elseif online_skyinfo.colorize_color == nil then
			online_skyinfo.colorize_color = "#ffffff"
		end
	end
	online_skyinfo.force_update = true
end

function ch_sky.is_enabled_for_player(player)
	local player_name = player:get_player_name()
	local offline_charinfo = ch_core.offline_charinfo[player_name]
	return offline_charinfo == nil or offline_charinfo.no_ch_sky ~= 1
end

local get_colors_cache = {}

local function get_colors(day_night_ratio)
	local result = get_colors_cache[day_night_ratio]
	if result ~= nil then
		return result
	end
	result = {}
	local w, cw = day_night_ratio, 1.0 - day_night_ratio
	local coratio = 1.0 - day_night_ratio
	local r = math.min(255, math.max(0, math.floor(255 * w + 18.6 * cw)))
	local g = math.min(255, math.max(0, math.floor(255 * w + 17.1 * cw)))
	local b = math.min(255, math.max(0, math.floor(255 * w + 24.9 * cw)))
	result.multiplier = string.format("#%02x%02x%02x", r, g, b)
	r = math.floor(r * 0.949)
	g = math.floor(g * 0.961)
	b = math.floor(b * 0.937)
	result.base_color = string.format("#%02x%02x%02x", r, g, b)
	get_colors_cache[day_night_ratio] = result
	return result
end

local function update_ch_sky(player, player_name, online_skyinfo, global_day_night_ratio)
	assert(online_skyinfo)
	if not online_skyinfo.ch_sky_enabled then
		if online_skyinfo.ch_sky_active then
			-- deactivate ch_sky
			player:set_sky() -- reset the sky
			online_skyinfo.ch_sky_active = false
		end
		return
	end
	local day_night_ratio = player:get_day_night_ratio() or global_day_night_ratio
	if not online_skyinfo.force_update and online_skyinfo.ch_sky_active then
		if online_skyinfo.day_night_ratio == day_night_ratio then
			return false -- nothing to update
		end
	else
		online_skyinfo.ch_sky_active = true
		online_skyinfo.force_update = false
	end
	local colors = get_colors(day_night_ratio)
	local texture_modifier = ""
	if online_skyinfo.colorize_color ~= nil and online_skyinfo.colorize_ratio ~= nil then
		local ratio_int = math.floor(online_skyinfo.colorize_ratio * 255)
		ratio_int = math.min(255, math.max(0, ratio_int))
		texture_modifier = string.format("%s^[colorize:%s:%d", texture_modifier, online_skyinfo.colorize_color, ratio_int)
	end
	texture_modifier = texture_modifier.."^[multiply:"..colors.multiplier
	-- print("DEBUG: will set texture modifier: "..texture_modifier)
	player:set_sky({
		type = "skybox",
		base_color = online_skyinfo.colorize_color or colors.base_color,
		textures = {
			"TropicalSunnyDayUp.jpg^[transformR90"..texture_modifier,
			"TropicalSunnyDayDown.jpg"..texture_modifier,
			"TropicalSunnyDayRight.jpg"..texture_modifier,
			"TropicalSunnyDayLeft.jpg"..texture_modifier,
			"TropicalSunnyDayFront.jpg"..texture_modifier,
			"TropicalSunnyDayBack.jpg"..texture_modifier,
		},
		clouds = false,
	})
end

local dtime_acc = 0
local function on_globalstep(dtime)
	dtime_acc = dtime_acc + dtime
	if dtime_acc < 1 then
		return
	end
	dtime_acc = dtime_acc - 1

	local herni_cas = ch_core.herni_cas() or {}
	local global_day_night_ratio = herni_cas.day_night_ratio or 1.0

	for _, player in ipairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		local online_skyinfo = ch_core.safe_get_4(ch_core, "online_charinfo", player_name, "sky_info")
		if online_skyinfo ~= nil then
			update_ch_sky(player, player_name, online_skyinfo, global_day_night_ratio)
		end
	end
end

local function on_joinplayer(player, _last_login)
	local player_name = player:get_player_name()
	local online_charinfo = ch_core.get_joining_online_charinfo(player_name)
	online_charinfo.sky_info = {
		ch_sky_active = false,
		ch_sky_enabled = true,
		day_night_ratio = -1,
		force_update = true,
	}
	local offline_charinfo = ch_core.offline_charinfo[player_name]
	if offline_charinfo == nil or offline_charinfo.no_ch_sky ~= 1 then
		update_ch_sky(player, player_name, online_charinfo.sky_info, (ch_core.herni_cas() or {}).day_night_ratio or 1.0)
	else
		online_charinfo.sky_info.ch_sky_enabled = false
	end
end

minetest.register_globalstep(on_globalstep)
minetest.register_on_joinplayer(on_joinplayer)


--[[
local function mydofile(filename)
	local f = loadfile(modpath.."/"..filename)
	assert(f)
	return f(tinv, utils)
end
]]

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
