print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
-----------------------------------------------------------------------------------------------
local title		= "Cave Stuff"
local version	= "0.0.3"
local mname		= "cavestuff"
-----------------------------------------------------------------------------------------------

-- support for i18n
local S = minetest.get_translator("cavestuff")

cavestuff = {}

dofile(minetest.get_modpath("cavestuff").."/nodes.lua")
dofile(minetest.get_modpath("cavestuff").."/mapgen.lua")

-----------------------------------------------------------------------------------------------

-- print("[Mod] "..title.." ["..version.."] ["..mname.."] Loaded...")
print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
