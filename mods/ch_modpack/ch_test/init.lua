print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
local modpath = minetest.get_modpath("ch_test")

-- dofile(modpath.."/dynamic_liquids.lua")
dofile(modpath.."/clothinggen.lua")
dofile(modpath.."/extra_logging.lua")
dofile(modpath.."/interiors.lua")
dofile(modpath.."/landscape_generation.lua")
dofile(modpath.."/path_generation.lua")
dofile(modpath.."/ui_page.lua")
dofile(modpath.."/globalstep_lag_logging.lua")
dofile(modpath.."/4dirtest.lua")
----
dofile(modpath.."/array_stats.lua")

local expect_compactor = minetest.settings:get_bool("ch_expect_compactor", false)

print("expect_compactor is "..(expect_compactor and "true" or "false"))

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

