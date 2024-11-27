ch_base.open_mod(minetest.get_current_modname())
local path = minetest.get_modpath("guinea_pig")


-- Animals
dofile(path .. "/guinea_pig.lua") 

ch_base.close_mod(minetest.get_current_modname())
