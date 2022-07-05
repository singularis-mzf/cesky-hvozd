local path = minetest.get_modpath("guinea_pig")

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

-- Animals
dofile(path .. "/guinea_pig.lua") 

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
