print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
dofile(minetest.get_modpath(minetest.get_current_modname())..DIR_DELIM.."camera.lua")
print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
