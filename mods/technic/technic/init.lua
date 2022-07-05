-- Minetest 0.4.7 mod: technic
-- namespace: technic
-- (c) 2012-2013 by RealBadAngel <mk@realbadangel.pl>
-- (c) 2022 by Singularis <singularis@volny.cz>

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local load_start = os.clock()

technic = rawget(_G, "technic") or {}
technic.creative_mode = minetest.settings:get_bool("creative_mode")


local modpath = minetest.get_modpath("technic")
technic.modpath = modpath


-- Get translator
technic.getter = minetest.get_translator("technic")
local S = technic.getter

-- Read configuration file
dofile(modpath.."/config.lua")

-- Helper functions
dofile(modpath.."/helpers.lua")

-- Items
dofile(modpath.."/items.lua")

-- Craft recipes for items
dofile(modpath.."/crafts.lua")

-- Register functions
dofile(modpath.."/register.lua")

-- Radiation
dofile(modpath.."/radiation.lua")

-- Machines
dofile(modpath.."/machines/init.lua")

-- Tools
dofile(modpath.."/tools/init.lua")

-- Aliases for legacy node/item names
dofile(modpath.."/legacy.lua")

if minetest.settings:get_bool("log_mods") then
	-- print(S("[Technic] Loaded in @1 seconds", string.format("%f", os.clock() - load_start)))
end

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
