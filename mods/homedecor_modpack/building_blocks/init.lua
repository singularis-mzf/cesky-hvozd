ch_base.open_mod(minetest.get_current_modname())
local modpath = minetest.get_modpath("building_blocks")


dofile(modpath.."/alias.lua")
dofile(modpath.."/node_stairs.lua")
dofile(modpath.."/others.lua")
dofile(modpath.."/recipes.lua")

ch_base.close_mod(minetest.get_current_modname())
