ch_base.open_mod(minetest.get_current_modname())
FB = {}
FB.NAME = "factory_bridges"
FB.LOCAL = minetest.get_translator("factory_bridges")


dofile(minetest.get_modpath(FB.NAME).."/models.lua")
dofile(minetest.get_modpath(FB.NAME).."/nodes.lua")
dofile(minetest.get_modpath(FB.NAME).."/items.lua")
dofile(minetest.get_modpath(FB.NAME).."/crafts.lua")

ch_base.close_mod(minetest.get_current_modname())
