local modpath = minetest.get_modpath("homedecor_tables")

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

dofile(modpath.."/misc.lua")
dofile(modpath.."/endtable.lua")
dofile(modpath.."/coffeetable.lua")

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
