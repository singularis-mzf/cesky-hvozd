darkage = {}

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

dofile(minetest.get_modpath("darkage").."/nodes.lua")
dofile(minetest.get_modpath("darkage").."/craftitems.lua")
dofile(minetest.get_modpath("darkage").."/crafts.lua")
dofile(minetest.get_modpath("darkage").."/mapgen.lua")
dofile(minetest.get_modpath("darkage").."/stairs.lua")
dofile(minetest.get_modpath("darkage").."/aliases.lua")

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
