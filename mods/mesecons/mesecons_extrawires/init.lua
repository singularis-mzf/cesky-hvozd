print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

dofile(minetest.get_modpath("mesecons_extrawires").."/crossover.lua");
dofile(minetest.get_modpath("mesecons_extrawires").."/tjunction.lua");
dofile(minetest.get_modpath("mesecons_extrawires").."/corner.lua");
dofile(minetest.get_modpath("mesecons_extrawires").."/doublecorner.lua");
dofile(minetest.get_modpath("mesecons_extrawires").."/vertical.lua");
dofile(minetest.get_modpath("mesecons_extrawires").."/mesewire.lua");
print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
