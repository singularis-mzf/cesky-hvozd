ch_base.open_mod(minetest.get_current_modname())

dofile(minetest.get_modpath("mesecons_extrawires").."/crossover.lua");
dofile(minetest.get_modpath("mesecons_extrawires").."/tjunction.lua");
dofile(minetest.get_modpath("mesecons_extrawires").."/corner.lua");
dofile(minetest.get_modpath("mesecons_extrawires").."/doublecorner.lua");
dofile(minetest.get_modpath("mesecons_extrawires").."/vertical.lua");
dofile(minetest.get_modpath("mesecons_extrawires").."/mesewire.lua");
ch_base.close_mod(minetest.get_current_modname())
