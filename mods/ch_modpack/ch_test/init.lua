print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
local modpath = minetest.get_modpath("ch_test")

-- dofile(modpath.."/dynamic_liquids.lua")
dofile(modpath.."/area_storages.lua")
-- dofile(modpath.."/areas_test.lua")
--dofile(modpath.."/clothinggen.lua")
-- dofile(modpath.."/colored_stone.lua")
-- dofile(modpath.."/chest.lua")
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

ch_test = {
	dofile = function(file, options, ...)
		local path = options.path
		if path == nil then
			local modname = minetest.get_current_modname()
			if modname == nil then
				error("options.path must be set unless a mod is loading!")
			end
			path = minetest.get_modpath(modname)
			assert(path)
		end
		local f = loadfile(path.."/"..file)
		if f ~= nil then
			return f(...)
		elseif not options.nofail then
			error("dofile(): "..path.."/"..file.." not found!")
		end
	end
}

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
