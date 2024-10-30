print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local modpath = minetest.get_modpath("ch_extras")

ch_extras = {}

dofile(modpath.."/3dprint.lua")
dofile(modpath.."/anchor.lua")
dofile(modpath.."/arcades.lua")
-- dofile(modpath.."/balikovna.lua") -- rozepsáno
dofile(modpath.."/covers.lua")
dofile(modpath.."/craftitems.lua")
dofile(modpath.."/nodes.lua")
dofile(modpath.."/piles.lua")
dofile(modpath.."/switch.lua")
dofile(modpath.."/tools.lua")
dofile(modpath.."/totalst.lua")

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
