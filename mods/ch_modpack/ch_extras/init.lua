print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local modpath = minetest.get_modpath("ch_extras")

ch_extras = {}

dofile(modpath.."/3dprint.lua")
dofile(modpath.."/covers.lua")
dofile(modpath.."/craftitems.lua")
dofile(modpath.."/nodes.lua")
dofile(modpath.."/switch.lua")
dofile(modpath.."/tools.lua")
dofile(modpath.."/totalst.lua")
dofile(modpath.."/vyhlazeni.lua")

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
