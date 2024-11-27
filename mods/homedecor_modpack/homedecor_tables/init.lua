ch_base.open_mod(minetest.get_current_modname())
local modpath = minetest.get_modpath("homedecor_tables")


dofile(modpath.."/misc.lua")
dofile(modpath.."/endtable.lua")
dofile(modpath.."/coffeetable.lua")

ch_base.close_mod(minetest.get_current_modname())
