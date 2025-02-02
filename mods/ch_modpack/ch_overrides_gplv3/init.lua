ch_base.open_mod(minetest.get_current_modname())

local dofile = ch_core.compile_dofile()

dofile("advtrains.lua")

ch_base.close_mod(minetest.get_current_modname())
