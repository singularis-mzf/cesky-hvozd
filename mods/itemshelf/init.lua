ch_base.open_mod(minetest.get_current_modname())
-- Itemshelf mod by Zorman2000

local modpath = minetest.get_modpath("itemshelf")


-- Load files
dofile(modpath .. "/api.lua")
dofile(modpath .. "/nodes.lua")

ch_base.close_mod(minetest.get_current_modname())
