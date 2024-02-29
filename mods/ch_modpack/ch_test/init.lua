print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
local modpath = minetest.get_modpath("ch_test")

-- dofile(modpath.."/dynamic_liquids.lua")
dofile(modpath.."/area_storages.lua")
--dofile(modpath.."/clothinggen.lua")
-- dofile(modpath.."/colored_stone.lua")
dofile(modpath.."/chest.lua")
dofile(modpath.."/hud_test.lua")
dofile(modpath.."/extra_logging.lua")
-- dofile(modpath.."/interiors.lua")
dofile(modpath.."/landscape_generation.lua")
--dofile(modpath.."/path_generation.lua")
-- dofile(modpath.."/ui_page.lua")
dofile(modpath.."/globalstep_lag_logging.lua")
-- dofile(modpath.."/markers.lua")
dofile(modpath.."/testcommand.lua")
dofile(modpath.."/testnodes.lua")
dofile(modpath.."/wanted_blocks.lua")
----
-- dofile(modpath.."/array_stats.lua")

--[[
local ore_nodenames = {
	"default:stone_with_coal", "default:stone_with_iron",
	"default:stone_with_copper", "default:stone_with_tin",
	-- "default:stone_with_gold",
	"default:stone_with_mese", "default:stone_with_diamond",
	"moreores:silver_lump", "moreores:mithril_lump",
	"denseores:large_coal_ore",
	"denseores:large_copper_ore",
	"denseores:large_diamond_ore",
	-- "denseores:large_gold_ore",
	"denseores:large_iron_ore",
	"denseores:large_mese_ore",
	"denseores:large_tin_ore",
	"denseores:large_silver_ore",
	"denseores:large_mithril_ore",
	"technic:mineral_lead",
-- + uranium
}
]]

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
