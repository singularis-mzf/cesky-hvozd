ch_base.open_mod(minetest.get_current_modname())

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

ch_sky = {}

local function get_online_skyinfo_and_player_name(player)
	local player_name = player:get_player_name()
	local online_charinfo = ch_core.online_charinfo[player_name]
	if online_charinfo == nil and minetest.get_player_name(player_name) then
		minetest.log("warning", "online_charinfo not found for online player "..player_name.."!")
		return
	end
	return online_charinfo.sky_info, player_name
end

local function is_underground(y)
	return y <= -100
end

--[[
	args = {
		day_color = string or nil,
		day_ratio = string or nil,
		night_color = string or nil,
		night_ratio = string or nil,
	}
]]

function ch_sky.colorize_sky(player, args)
	if
		(args.day_color ~= nil and type(args.day_color) ~= "string") or
		(args.night_color ~= nil and type(args.night_color) ~= "string")
	then
		error("ch_sky.colorize_sky() supports only string as color!")
	end
	local online_skyinfo = get_online_skyinfo_and_player_name(player)
	if online_skyinfo == nil then
		return
	end
	online_skyinfo.colorize_day_color = args.day_color
	online_skyinfo.colorize_day_ratio = args.day_ratio
	online_skyinfo.colorize_night_color = args.night_color
	online_skyinfo.colorize_night_ratio = args.night_ratio
	online_skyinfo.force_update = true
end

function ch_sky.is_enabled_for_player(player)
	local player_name = player:get_player_name()
	local offline_charinfo = ch_core.offline_charinfo[player_name]
	return offline_charinfo == nil or offline_charinfo.no_ch_sky ~= 1
end

function ch_sky.get_sky(player)
	local online_skyinfo, player_name = get_online_skyinfo_and_player_name(player)
	if online_skyinfo ~= nil then
		return online_skyinfo.sky
	else
		return player:get_sky(true)
	end
end

function ch_sky.get_sun(player)
	local online_skyinfo, player_name = get_online_skyinfo_and_player_name(player)
	if online_skyinfo ~= nil then
		return online_skyinfo.sun
	else
		return player:get_sun()
	end
end

function ch_sky.get_moon(player)
	local online_skyinfo, player_name = get_online_skyinfo_and_player_name(player)
	if online_skyinfo ~= nil then
		return online_skyinfo.moon
	else
		return player:get_moon()
	end
end

function ch_sky.get_stars(player)
	local online_skyinfo, player_name = get_online_skyinfo_and_player_name(player)
	if online_skyinfo ~= nil then
		return online_skyinfo.stars
	else
		return player:get_stars()
	end
end

function ch_sky.set_sky(player, sky)
	local online_skyinfo, player_name = get_online_skyinfo_and_player_name(player)
	if online_skyinfo ~= nil then
		if online_skyinfo.sky == nil then
			online_skyinfo.sky = sky
		else
			for k, v in pairs(sky) do
				if (k == "sky_color" or k == "fog") and type(v) == "table" and type(online_skyinfo.sky[k]) == "table" then
					local subtable = online_skyinfo.sky[k]
					for k2, v2 in pairs(v) do
						subtable[k2] =v2
					end
				else
					online_skyinfo.sky[k] = v
				end
			end
		end
		if online_skyinfo.ch_sky_active then
			return
		end
	end
	player:set_sky(sky)
end

function ch_sky.set_sun(player, sun)
	local online_skyinfo, player_name = get_online_skyinfo_and_player_name(player)
	if online_skyinfo ~= nil then
		if online_skyinfo.sun == nil then
			online_skyinfo.sun = sun
		else
			for k, v in pairs(sun) do
				online_skyinfo.sun[k] = v
			end
		end
		if online_skyinfo.ch_sky_active then
			return
		end
	end
	player:set_sun(sky)
end

function ch_sky.set_moon(player, moon)
	local online_skyinfo, player_name = get_online_skyinfo_and_player_name(player)
	if online_skyinfo ~= nil then
		if online_skyinfo.moon == nil then
			online_skyinfo.moon = moon
		else
			for k, v in pairs(moon) do
				online_skyinfo.moon[k] = v
			end
		end
		if online_skyinfo.ch_sky_active then
			return
		end
	end
	player:set_moon(sky)
end

function ch_sky.set_stars(player, stars)
	local online_skyinfo, player_name = get_online_skyinfo_and_player_name(player)
	if online_skyinfo ~= nil then
		if online_skyinfo.stars == nil then
			online_skyinfo.stars = stars
		else
			for k, v in pairs(stars) do
				online_skyinfo.stars[k] = v
			end
		end
		if online_skyinfo.ch_sky_active then
			return
		end
	end
	player:set_stars(sky)
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
	local force_update = online_skyinfo.force_update
	if not online_skyinfo.ch_sky_enabled then
		if online_skyinfo.ch_sky_active then
			-- deactivate ch_sky
			online_skyinfo.ch_sky_active = false
			online_skyinfo.force_update = false
			player:set_sky()
			player:set_sun()
			player:set_moon()
			player:set_stars()
			player:set_sky(online_skyinfo.sky)
			player:set_sun(online_skyinfo.sun)
			player:set_moon(online_skyinfo.moon)
			player:set_stars(online_skyinfo.stars)
		end
		return
	elseif not online_skyinfo.ch_sky_active then
		-- activate ch_sky
		player:set_sun()
		player:set_moon()
		player:set_stars()
		online_skyinfo.ch_sky_active = true
		force_update = true
	end
	online_skyinfo.force_update = false

	local player_is_underground = is_underground(player:get_pos().y)
	local day_night_ratio = math.max(0.0, math.min(1.0,
		(player:get_day_night_ratio() or global_day_night_ratio)))
	if not force_update and player_is_underground == online_skyinfo.player_was_underground and day_night_ratio == online_skyinfo.last_day_night_ratio then
		return -- nothing to update
	end
	local is_night = day_night_ratio < 0.5
	local sky_color, texture_modifier
	if player_is_underground then
		sky_color = "#030303"
		texture_modifier = "^[resize:1x1^[multiply:"..sky_color
	else
		local colors = get_colors(day_night_ratio)
		texture_modifier = "^[multiply:"..colors.multiplier
		local colorize_color, colorize_ratio
		if is_night then
			colorize_color, colorize_ratio = online_skyinfo.colorize_night_color, online_skyinfo.colorize_night_ratio
		else
			colorize_color, colorize_ratio = online_skyinfo.colorize_day_color, online_skyinfo.colorize_day_ratio
		end
		if colorize_color ~= nil and colorize_ratio ~= nil and colorize_ratio > 0.0 then
			local int_ratio = math.max(0, math.min(255, math.floor(colorize_ratio * 255)))
			sky_color = colorize_color
			texture_modifier = string.format("%s^[colorize:%s:%d", texture_modifier, sky_color, int_ratio)
		else
			sky_color = colors.base_color
		end
	end
	if force_update or player_is_underground ~= online_skyinfo.player_was_underground then
		online_skyinfo.player_was_underground = player_is_underground
		if player_is_underground then
			player:set_sun{visible = false, sunrise_visible = false}
			player:set_moon{visible = false}
			player:set_stars{visible = false}
		else
			player:set_sun()
			player:set_moon()
			player:set_stars()
		end
	end
	if force_update or online_skyinfo.last_texture_modifier ~= texture_modifier then
		online_skyinfo.last_texture_modifier = texture_modifier
		player:set_sky({
			type = "skybox",
			base_color = assert(sky_color),
			textures = {
				-- top:
				"TropicalSunnyDayUp.jpg^[transformR90"..texture_modifier,
				-- bottom:
				"TropicalSunnyDayDown.jpg^[multiply:#000000",
				"TropicalSunnyDayRight.jpg"..texture_modifier,
				"TropicalSunnyDayLeft.jpg"..texture_modifier,
				"TropicalSunnyDayFront.jpg"..texture_modifier,
				"TropicalSunnyDayBack.jpg"..texture_modifier,
			},
			clouds = false,
		})
	end
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
		force_update = true,
		last_day_night_ratio = -1,
		last_texture_modifier = "",
		sky = player:get_sky(true),
		sun = player:get_sun(),
		moon = player:get_moon(),
		stars = player:get_stars(),
		player_was_underground = is_underground(player:get_pos().y),
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

ch_base.close_mod(minetest.get_current_modname())
