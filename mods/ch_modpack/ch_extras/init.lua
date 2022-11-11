print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local modpath = minetest.get_modpath("ch_extras")

dofile(modpath.."/nodes.lua")
dofile(modpath.."/tools.lua")
dofile(modpath.."/totalst.lua")

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
