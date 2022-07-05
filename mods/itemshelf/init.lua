-- Itemshelf mod by Zorman2000

local modpath = minetest.get_modpath("itemshelf")

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

-- Load files
dofile(modpath .. "/api.lua")
dofile(modpath .. "/nodes.lua")

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
