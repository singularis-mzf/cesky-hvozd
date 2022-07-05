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
-- local color_bgcolor = {r = 0, g = 0, b = 0, a = 0}
local color_normal = {r = 255, g = 255, b = 255, a = 255}
local color_unregistered = {r = 153, g = 153, b = 153, a = 255}

-- POZICE A OBLASTI
-- ===========================================================================

ch_core.unregistered_spawn = vector.new(-70,9.5,40)
ch_core.registered_spawn = ch_core.unregistered_spawn

-- TITULKY HRÁČŮ/EK
-- ===========================================================================
ch_core.titulky_hracu_ek = {
	Administrace = {
		titul = "správa serveru",
		jmenobezbarev = "Administrace",
		jmeno = nametag_color_red .. "Admin" .. nametag_color_blue .. "istrace" .. color_reset,
		-- jmeno = nametag_color_red .. "Admin" .. nametag_color_blue .. "istrace" .. color_reset,
	},
	Stepanka = {
		jmenobezbarev = "Štěpánka",
		jmeno = "Štěpánka",
	},
}

-- FUNKCE (vztažené k datům)
-- ===========================================================================
ch_core.na_jmeno_bez_barev = function(jmeno)
	local t = ch_core.titulky_hracu_ek[jmeno]
	if t and t.jmenobezbarev then
		return t.jmenobezbarev
	else
		return jmeno
	end
end

ch_core.na_jmeno_bez_barev_a_mezer = function(jmeno)
	return string.gsub(ch_core.na_jmeno_bez_barev(jmeno), " ", "")
end
