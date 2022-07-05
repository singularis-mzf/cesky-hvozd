FB = {}
FB.NAME = "factory_bridges"
FB.LOCAL = minetest.get_translator("factory_bridges")

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

dofile(minetest.get_modpath(FB.NAME).."/models.lua")
dofile(minetest.get_modpath(FB.NAME).."/nodes.lua")
dofile(minetest.get_modpath(FB.NAME).."/items.lua")
dofile(minetest.get_modpath(FB.NAME).."/crafts.lua")

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
