print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
local S = minetest.get_translator("orienteering")
local mod_map = nil -- minetest.get_modpath("map") -- map mod from Minetest Game
local ifthenelse = assert(ch_core.ifthenelse)

local orienteering = {}
orienteering.playerhuds = {}
orienteering.settings = {}
orienteering.settings.speed_unit = S("m/s")
orienteering.settings.length_unit = S("m")
orienteering.settings.hud_pos = { x = 0.5, y = 0 }
orienteering.settings.hud_offset = { x = 0, y = 15 }
orienteering.settings.hud_alignment = { x = 0, y = 0 }

local set = tonumber(minetest.settings:get("orienteering_hud_pos_x"))
if set then orienteering.settings.hud_pos.x = set end
set = tonumber(minetest.settings:get("orienteering_hud_pos_y"))
if set then orienteering.settings.hud_pos.y = set end
set = tonumber(minetest.settings:get("orienteering_hud_offset_x"))
if set then orienteering.settings.hud_offset.x = set end
set = tonumber(minetest.settings:get("orienteering_hud_offset_y"))
if set then orienteering.settings.hud_offset.y = set end
set = minetest.settings:get("orienteering_hud_alignment")
if set == "left" then
	orienteering.settings.hud_alignment.x = 1
elseif set == "center" then
	orienteering.settings.hud_alignment.x = 0
elseif set == "right" then
	orienteering.settings.hud_alignment.x = -1
end

local minimap_modes = {
	{type = "off", label = "minimapa je skryta"},
	{type = "surface", label = "povrch 512 (1/4)", size = 512},
	{type = "surface", label = "povrch 256 (2/4)", size = 256},
	{type = "surface", label = "povrch 128 (3/4)", size = 128},
	{type = "surface", label = "povrch 64 (4/4)", size = 64},
	{type = "radar", label = "radar 256 (1/4)", size = 256},
	{type = "radar", label = "radar 128 (2/4)", size = 128},
	{type = "radar", label = "radar 64 (3/4)", size = 64},
	{type = "radar", label = "radar 32 (4/4)", size = 32},
}

local function open_minimap(itemstack, user, pointed_thing)
	user:set_minimap_modes(minimap_modes, 0)
	ch_core.systemovy_kanal(user:get_player_name(),
	                        S("Now you can view a minimap using the appropriate key (the default for computers is V). A minimap will be accessible as long as you would have a Map or Quadcorder on the hotbar."))
end

local o_lines = 4 -- Number of lines in HUD

local yaw_abbrs = {
	"S",
	"SSV",
	"SV",
	"VSV",
	"V",
	"VJV",
	"JV",
	"JJV",
	"J",
	"JJZ",
	"JZ",
	"ZJZ",
	"Z",
	"ZSZ",
	"SZ",
	"SSZ",
	"S",
}

-- Helper function to switch between 12h and 24 mode for the time
function orienteering.toggle_time_mode(itemstack, user, pointed_thing)
	--[[ Player attribute “orienteering:twelve”:
	* "true": Use 12h mode for time
	* "false" or unset: Use 24h mode for time ]]
	if user:get_meta():get_string("orienteering:twelve") == "true" then
		user:get_meta():set_string("orienteering:twelve", "false")
	else
		user:get_meta():set_string("orienteering:twelve", "true")
	end
	orienteering.update_hud_displays(user)
end

local use = S("Put this tool in your hotbar to see the data it provides.")
local use_time = S("Put this tool in your hotbar to make use of its functionality. Punch to toggle between 24-hour and 12-hour display for the time feature.")

orienteering.update_bc_player_huds = dofile(minetest.get_modpath("orienteering").."/compass.lua")

-- Displays height (Y)
minetest.register_tool("orienteering:altimeter", {
	description = S("Altimeter"),
	_ch_help = "Je-li na výběrové liště, zobrazuje vaši současnou výšku (Y).",
	_ch_help_group = "o:a",
	_tt_help = S("Shows your elevation"),
	_doc_items_longdesc = S("It shows you your current elevation (Y)."),
	_doc_items_usagehelp = use,
	wield_image = "orienteering_altimeter.png",
	inventory_image = "orienteering_altimeter.png",
	groups = { disable_repair = 1 },
})

-- Displays X and Z coordinates
minetest.register_tool("orienteering:triangulator", {
	description = S("Triangulator"),
	_ch_help = "Je-li na výběrové liště, zobrazuje vaše souřadnice X a Z.",
	_ch_help_group = "o:t",
	_tt_help = S("Shows your horizontal coordinates"),
	_doc_items_longdesc = S("It shows you the coordinates of your current position in the horizontal plane (X and Z)."),
	_doc_items_usagehelp = use,
	wield_image = "orienteering_triangulator.png",
	inventory_image = "orienteering_triangulator.png",
	groups = { disable_repair = 1 },
})

-- Displays player yaw
minetest.register_tool("orienteering:compass", {
	description = S("Compass"),
	_ch_help = "Je-li na výběrové liště, zobrazuje váš směr ve stupních.",
	_ch_help_group = "o:c",
	_tt_help = S("Shows your yaw"),
	_doc_items_longdesc = S("It shows you your yaw (horizontal viewing angle) in degrees."),
	_doc_items_usagehelp = use,
	wield_image = "orienteering_compass_wield.png",
	inventory_image = "orienteering_compass_inv.png",
	groups = { disable_repair = 1 },
})

-- Displays player pitch
minetest.register_tool("orienteering:sextant", {
	description = S("Sextant"),
	_ch_help = "Je-li na výběrové liště, zobrazuje vám sklon ve stupních.",
	_ch_help_group = "o:s",
	_tt_help = S("Shows your pitch"),
	_doc_items_longdesc = S("It shows you your pitch (vertical viewing angle) in degrees."),
	_doc_items_usagehelp = use,
	wield_image = "orienteering_sextant_wield.png",
	inventory_image = "orienteering_sextant_inv.png",
	groups = { disable_repair = 1 },
})

-- Ultimate orienteering tool: Displays X,Y,Z, yaw, pitch, time, speed and enables the minimap
minetest.register_tool("orienteering:quadcorder", {
	description = S("Quadcorder"),
	_ch_help = "Nejmocnější orientační pomůcka. Je-li na výběrové liště, zobrazuje všechny vaše souřadnice,\nsměr i sklon, herní čas a vaši aktuální rychlost.\nRovněž poskytuje přístup k minimapě.",
	_ch_help_group = "o:q",
	_tt_help = S("Shows your coordinates, yaw, pitch, time, speed and enables minimap"),
	_doc_items_longdesc = S("This is the ultimate orientieering tool. It shows you your coordinates (X, Y and Z), shows your yaw and pitch (horizontal and vertical viewing angles), the current time, your current speed and it enables you to access the minimap."),
	wield_image = "orienteering_quadcorder.png",
	_doc_items_usagehelp = use_time,
	wield_scale = { x=1, y=1, z=3.5 },
	inventory_image = "orienteering_quadcorder.png",
	groups = { disable_repair = 1 },
	on_use = open_minimap,
})

-- Displays game time
minetest.register_tool("orienteering:watch", {
	description = S("Watch"),
	_ch_help = "Jsou-li na výběrové liště, zobrazuje vám herní čas.",
	_ch_help_group = "o:w",
	_tt_help = S("Shows the time"),
	_doc_items_longdesc = S("It shows you the current time."),
	_doc_items_usagehelp = S("Put the watch in your hotbar to see the time. Punch to toggle between the 24-hour and 12-hour display."),
	wield_image = "orienteering_watch.png",
	inventory_image = "orienteering_watch.png",
	groups = { disable_repair = 1 },
	on_use = orienteering.toggle_time_mode,
})

-- Displays speed
minetest.register_tool("orienteering:speedometer", {
	description = S("Speedometer"),
	_ch_help = "Je-li na výběrové liště, zobrazuje vaši současnou rychlost.",
	_ch_help_group = "o:sp",
	_tt_help = S("Shows your speed"),
	_doc_items_longdesc = S("It shows you your current horizontal (“hor.”) and vertical (“ver.”) speed in meters per second, where one meter is the side length of a single cube."),
	_doc_items_usagehelp = use,
	wield_image = "orienteering_speedometer_wield.png",
	inventory_image = "orienteering_speedometer_inv.png",
	groups = { disable_repair = 1 },
})

if not mod_map then
	-- Enables minimap (surface)
	minetest.register_tool("orienteering:map", {
		description = S("Map"),
		_ch_help = "Je-li na výběrové liště, umožní vám přístup k minimapě (ve výchozím nastavení klávesou V).",
		_ch_help_group = "o:mm",
		_tt_help = S("Allows using the minimap"),
		_doc_items_longdesc = S("The map allows you to view a minimap of the area around you."),
		_doc_items_usagehelp = S("If you put a map in your hotbar, you will be able to access the minimap (only surface mode). Press the “minimap” key to view the minimap."),
		wield_image = "orienteering_map.png",
		wield_scale = { x=1.5, y=1.5, z=0.15 },
		inventory_image = "orienteering_map.png",
		groups = { disable_repair = 1 },
		on_use = open_minimap,
	})
end

-- Enables minimap (radar)
minetest.register_tool("orienteering:automapper", {
	description = S("Radar Mapper"),
	_ch_help = "Je-li na výběrové liště, umožní vám přístup k minimapě v normálním i radarovém režimu.",
	_ch_help_group = "o:rm",
	_tt_help = S("Allows using the minimap and radar"),
	_doc_items_longdesc = S("The radar mapper is a device that combines a map with a radar. It unlocks both the surface mode and radar mode of the minimap."),
	_doc_items_usagehelp = S("If you put a radar mapper in your hotbar, you will be able to access the minimap. Press the “minimap” key to view the minimap."),
	wield_image = "orienteering_automapper_wield.png",
	wield_scale = { x=1, y=1, z=2 },
	inventory_image = "orienteering_automapper_inv.png",
	groups = { disable_repair = 1 },
})

-- Displays X,Y,Z coordinates, yaw and game time
minetest.register_tool("orienteering:gps", {
	description = S("GPS device"),
	_ch_help = "Je-li na výběrové liště, zobrazuje vám všechny souřadnice, směr a herní čas.",
	_ch_help_group = "o:gps",
	_tt_help = S("Shows your coordinates, yaw and the time"),
	_doc_items_longdesc = S("The GPS device shows you your coordinates (X, Y and Z), your yaw (horizontal viewing angle) and the time."),
	_doc_items_usagehelp = use_time,
	wield_image = "orienteering_gps_wield.png",
	wield_scale = { x=1, y=1, z=2 },
	inventory_image = "orienteering_gps_inv.png",
	groups = { disable_repair = 1 },
	on_use = orienteering.toggle_time_mode,
})

if minetest.get_modpath("default") ~= nil then
	-- Register crafts
	minetest.register_craft({
		output = "orienteering:altimeter",
		recipe = {
			{"default:glass"},
			{"default:steel_ingot"},
			{"default:steel_ingot"},
		}
	})
	minetest.register_craft({
		output = "orienteering:triangulator",
		recipe = {
			{"", "default:bronze_ingot", ""},
			{"default:bronze_ingot", "", "default:bronze_ingot"},
		}
	})
	minetest.register_craft({
		output = "orienteering:sextant",
		recipe = {
			{"", "default:gold_ingot", ""},
			{"default:gold_ingot", "default:gold_ingot", "default:gold_ingot"},
		}
	})
	minetest.register_craft({
		output = "orienteering:compass",
		recipe = {
			{"", "default:tin_ingot", ""},
			{"default:tin_ingot", "group:stick", "default:tin_ingot"},
			{"", "default:tin_ingot", ""},
		}
	})
	minetest.register_craft({
		output = "orienteering:speedometer",
		recipe = {
			{"", "default:gold_ingot", ""},
			{"default:steel_ingot", "group:stick", "default:steel_ingot"},
			{"", "default:steel_ingot", ""},
		}
	})
	minetest.register_craft({
		output = "orienteering:automapper",
		recipe = {
			{"default:gold_ingot", "default:gold_ingot", "default:gold_ingot"},
			{"default:mese_crystal", "default:obsidian_shard", "default:mese_crystal"},
			{"default:gold_ingot", "default:gold_ingot", "default:gold_ingot"}
		}
	})
	minetest.register_craft({
		output = "orienteering:gps",
		recipe = {
			{ "default:gold_ingot", "orienteering:triangulator", "default:gold_ingot" },
			{ "orienteering:compass", "default:bronze_ingot", "orienteering:watch" },
                        { "default:tin_ingot", "orienteering:altimeter", "default:tin_ingot" }
		}
	})
	minetest.register_craft({
		output = "orienteering:quadcorder",
		recipe = {
			{ "default:gold_ingot", "default:gold_ingot", "default:gold_ingot" },
			{ "orienteering:speedometer", "default:diamond", "orienteering:automapper", },
                        { "orienteering:sextant", "default:diamond", "orienteering:gps" }
		}
	})
	minetest.register_craft({
		output = "orienteering:watch",
		recipe = {
			{ "default:copper_ingot" },
			{ "default:glass" },
			{ "default:copper_ingot" }
		}
	})

	if (not mod_map) and minetest.get_modpath("dye") then
		minetest.register_craft({
			output = "orienteering:map",
			recipe = {
				{ "default:paper", "default:paper", "default:paper" },
				{ "default:paper", "dye:black", "default:paper" },
				{ "default:paper", "default:paper", "default:paper" },
			}
		})
	end

end

function orienteering.update_automapper(player)
	local player_name = player:get_player_name() or ""
	local online_charinfo = ch_core.online_charinfo[player_name]
	if not online_charinfo then
		minetest.log("warning", "orienteering.update_automapper(): online_charinfo for player "..player_name.." not found!")
		return
	end
	if online_charinfo.enable_minimap == nil then
		online_charinfo.enable_minimap = false
		online_charinfo.enable_radar = false
	end
	local enable_radar = ifthenelse(
		orienteering.tool_active(player, "orienteering:automapper") or orienteering.tool_active(player, "orienteering:quadcorder"),
		true, false)
	local enable_minimap = ifthenelse(
		enable_radar or minetest.is_creative_enabled(player_name) or
		orienteering.tool_active(player, ifthenelse(mod_map, "map:mapping_kit", "orienteering:map")), true, false)

	if enable_minimap ~= online_charinfo.enable_minimap or enable_radar ~= online_charinfo.enable_radar then
		online_charinfo.enable_minimap = enable_minimap
		online_charinfo.enable_radar = enable_radar
		player:hud_set_flags({minimap = enable_minimap, minimap_radar = enable_radar})
		if enable_minimap or enable_radar then
			player:set_minimap_modes(minimap_modes, 0)
		end
	end
end

-- Checks whether a certain orienteering tool is “active” and ready for use
function orienteering.tool_active(player, item)
	-- Requirement: player carries the tool in the hotbar
	local result = ch_core.predmety_na_liste(player, false)[item]
	if result then
		return true
	else
		return false
	end
end

function orienteering.init_hud(player)
	orienteering.update_automapper(player)
	local name = player:get_player_name()
	orienteering.playerhuds[name] = {}
	for i=1, o_lines do
		orienteering.playerhuds[name]["o_line"..i] = player:hud_add({
			hud_elem_type = "text",
			text = "",
			position = orienteering.settings.hud_pos,
			offset = { x = orienteering.settings.hud_offset.x, y = orienteering.settings.hud_offset.y + 20*(i-1) },
			alignment = orienteering.settings.hud_alignment,
			number = 0xFFFFFF,
			scale= { x = 100, y = 20 },
			z_index = 0,
		})
	end
end

function orienteering.update_hud_displays(player)
	local toDegrees=180/math.pi
	local lista = ch_core.predmety_na_liste(player, false)
	local name = player:get_player_name()
	local player_huds = orienteering.playerhuds[name]
	local gps, altimeter, triangulator, compass, sextant, watch, speedometer, quadcorder

	if player_huds == nil then
		minetest.log("warning", "Orienteering HUDs not yet initialized for player "..name)
		return -- probably not initialized yet
	end

	gps = lista["orienteering:gps"]
	altimeter = lista["orienteering:altimeter"]
	triangulator = lista["orienteering:triangulator"]
	compass = lista["orienteering:compass"]
	sextant = lista["orienteering:sextant"]
	watch = lista["orienteering:watch"]
	speedometer = lista["orienteering:speedometer"]
	quadcorder = lista["orienteering:quadcorder"]

	local str_pos, str_angles, str_time, str_speed
	local pos = vector.round(player:get_pos())
	if (altimeter and triangulator) or gps or quadcorder then
		str_pos = S("Coordinates: X=@1, Y=@2, Z=@3", pos.x, pos.y, pos.z)
	elseif altimeter then
		str_pos = S("Height: Y=@1", pos.y)
	elseif triangulator then
		str_pos = S("Coordinates: X=@1, Z=@2", pos.x, pos.z)
	else
		str_pos = ""
	end

	-- Yaw in Minetest goes counter-clockwise, which is opposite of how compasses work
	local yaw = 360-player:get_look_horizontal()*toDegrees
	local pitch = player:get_look_vertical()*toDegrees
	local yaw_abbr = yaw_abbrs[1 + math.floor((yaw + 11.25) / 22.5)] or "chyba"
	if ((compass or gps) and sextant) or quadcorder then
		str_angles = S("Yaw: @1° (@2), pitch: @3°", string.format("%.1f", yaw), yaw_abbr, string.format("%.1f", pitch))
	elseif compass or gps then
		str_angles = S("Yaw: @1° (@2)", string.format("%.1f", yaw), yaw_abbr)
	elseif sextant then
		str_angles = S("Pitch: @1°", string.format("%.1f", pitch))
	else
		str_angles = ""
	end

	local time = minetest.get_timeofday()
	if watch or gps or quadcorder then
		local totalminutes = time * 1440
		local minutes = totalminutes % 60
		local hours = math.floor((totalminutes - minutes) / 60)
		minutes = math.floor(minutes)
		local twelve = player:get_meta():get_string("orienteering:twelve") == "true"
		if twelve then
			if hours == 12 and minutes == 0 then
				str_time = S("Time: noon")
			elseif hours == 0 and minutes == 0 then
				str_time = S("Time: midnight")
			else
				local hours12 = math.fmod(hours, 12)
				if hours12 == 0 then hours12 = 12 end
				if hours >= 12 then
					str_time = S("Time: @1:@2 p.m.", string.format("%i", hours12), string.format("%02i", minutes))
				else
					str_time = S("Time: @1:@2 a.m.", string.format("%i", hours12), string.format("%02i", minutes))
				end
			end
		else
			str_time = S("Time: @1:@2", string.format("%02i", hours), string.format("%02i", minutes))
		end
	else
		str_time = ""
	end

	if speedometer or quadcorder then
		local speed_hor, speed_ver
		local v
		local attach = player:get_attach()
		if attach == nil then
			v = player:get_velocity()
		else
			v = attach:get_velocity()
			if not v then
				v = player:get_velocity()
			end
		end
		speed_ver = v.y
		v.y = 0
		speed_hor = vector.length(v)

		local u = orienteering.settings.speed_unit
		str_speed = S("Speed: hor.: @1 @2, vert.: @3 @4", string.format("%.1f", speed_hor), u, string.format("%.1f", speed_ver), u)
	else
		str_speed = ""
	end

	local strs = { str_pos, str_angles, str_time, str_speed }
	local line = 1
	for i=1, o_lines do
		if strs[i] ~= "" then
			player:hud_change(player_huds["o_line"..line], "text", strs[i])
			line = line + 1
		end
	end
	for l=line, o_lines do
		player:hud_change(player_huds["o_line"..l], "text", "")
	end

	orienteering.update_bc_player_huds(player)
end

if mod_map then
	-- Disable all HUD flag handling in map mod because we already handle it
	-- ourselves.
	map.update_hud_flags = function() end
end

minetest.register_on_newplayer(orienteering.init_hud)
minetest.register_on_joinplayer(orienteering.init_hud)

minetest.register_on_leaveplayer(function(player)
	orienteering.playerhuds[player:get_player_name()] = nil
end)

local updatetimer = 0
minetest.register_globalstep(function(dtime)
	updatetimer = updatetimer + dtime
	if updatetimer > 0.1 then
		local players = minetest.get_connected_players()
		for i=1, #players do
			orienteering.update_automapper(players[i])
			orienteering.update_hud_displays(players[i])
		end
		updatetimer = updatetimer - dtime
	end
end)

if minetest.get_modpath("awards") ~= nil and minetest.get_modpath("default") ~= nil then
	awards.register_achievement("orienteering_quadcorder", {
		title = S("Master of Orienteering"),
		description = S("Craft a quadcorder."),
		icon = "orienteering_quadcorder.png",
		trigger = {
			type = "craft",
			item = "orienteering:quadcorder",
			target = 1
		}
	})
end
print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
