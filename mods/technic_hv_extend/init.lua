print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
local modname = minetest.get_current_modname()
local path = minetest.get_modpath(modname)

dofile(path.."/alloy_furnace.lua")
dofile(path.."/electric_furnace.lua")
dofile(path.."/grinder.lua")
dofile(path.."/compressor.lua")
print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
