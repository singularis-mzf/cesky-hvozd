--
-- Climatez
-- License:GPLv3
--

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local mg_name = minetest.get_mapgen_setting("mg_name")

if mg_name ~= "v6" and mg_name ~= "singlenode" then
	assert(loadfile(modpath .. "/engine.lua"))(modpath)
end

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
