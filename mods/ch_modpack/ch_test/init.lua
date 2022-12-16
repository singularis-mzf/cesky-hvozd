print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
local modpath = minetest.get_modpath("ch_test")

-- dofile(modpath.."/dynamic_liquids.lua")
dofile(modpath.."/clothinggen.lua")
dofile(modpath.."/extra_logging.lua")
dofile(modpath.."/landscape_generation.lua")
dofile(modpath.."/path_generation.lua")
dofile(modpath.."/ui_page.lua")
----
dofile(modpath.."/array_stats.lua")

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

