print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
local modpath = minetest.get_modpath("ch_test")

local dofile = ch_core.dofile

-- dofile({name = "dynamic_liquids.lua"})
dofile({name = "area_storages.lua"})
-- dofile({name = "areas_test.lua"})
--dofile({name = "clothinggen.lua"})
-- dofile({name = "colored_stone.lua"})
-- dofile({name = "chest.lua"})
dofile({name = "hud_test.lua"})
-- dofile({name = "extra_logging.lua"})
dofile({name = "interiors.lua"})
dofile({name = "landscape_generation.lua"})
--dofile({name = "path_generation.lua"})
-- dofile({name = "ui_page.lua"})
dofile({name = "globalstep_lag_logging.lua"})
dofile({name = "obj_in_radius_logging.lua"})
-- dofile({name = "markers.lua"})
dofile({name = "testcommand.lua"})
dofile({name = "testnodes.lua"})
dofile({name = "verify_tiles.lua"})
-- dofile({name = "wanted_blocks.lua"})
----
-- dofile({name = "array_stats.lua"})

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
