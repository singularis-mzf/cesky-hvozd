ch_base.open_mod(minetest.get_current_modname())
darkage = {}


dofile(minetest.get_modpath("darkage").."/nodes.lua")
dofile(minetest.get_modpath("darkage").."/craftitems.lua")
dofile(minetest.get_modpath("darkage").."/crafts.lua")
dofile(minetest.get_modpath("darkage").."/mapgen.lua")
dofile(minetest.get_modpath("darkage").."/stairs.lua")
dofile(minetest.get_modpath("darkage").."/aliases.lua")

ch_base.close_mod(minetest.get_current_modname())
