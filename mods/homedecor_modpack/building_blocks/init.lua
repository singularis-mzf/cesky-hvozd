local modpath = minetest.get_modpath("building_blocks")

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

dofile(modpath.."/alias.lua")
dofile(modpath.."/node_stairs.lua")
dofile(modpath.."/others.lua")
dofile(modpath.."/recipes.lua")

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
