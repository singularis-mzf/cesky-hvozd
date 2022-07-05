local modname = minetest.get_current_modname()
local path = minetest.get_modpath(modname)

dofile(path.."/electric_furnace.lua")
dofile(path.."/grinder.lua")
dofile(path.."/compressor.lua")
