ch_base.open_mod(minetest.get_current_modname())

nameznik = {}

dofile(minetest.get_modpath("nameznik").."/nameznik.lua")
ch_base.close_mod(minetest.get_current_modname())
