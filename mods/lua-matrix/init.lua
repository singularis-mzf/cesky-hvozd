-- this whole mod is just a thin wrapper around https://github.com/davidm/lua-matrix

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local mod_path = minetest.get_modpath(minetest.get_current_modname())

matrix = dofile(mod_path .. "/matrix.lua")

-- that's it

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
