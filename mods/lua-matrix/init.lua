ch_base.open_mod(minetest.get_current_modname())
-- this whole mod is just a thin wrapper around https://github.com/davidm/lua-matrix


local mod_path = minetest.get_modpath(minetest.get_current_modname())

matrix = dofile(mod_path .. "/matrix.lua")

-- that's it

ch_base.close_mod(minetest.get_current_modname())
