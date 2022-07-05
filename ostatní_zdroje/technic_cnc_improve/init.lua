local modname = minetest.get_current_modname()
local path = minetest.get_modpath(modname)

dofile(path.."/cnc.lua")
dofile(path.."/cnc_api.lua")
dofile(path.."/cnc_nodes.lua")
