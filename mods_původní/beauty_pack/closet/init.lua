--
-- closet
-- License:GPLv3
--

local modname = "closet"
local modpath = minetest.get_modpath(modname)
-- internationalization boilerplate
local S = minetest.get_translator(minetest.get_current_modname())

--
-- Closet Mod
--

closet = {}

-- Load the files
assert(loadfile(modpath .. "/api/api.lua"))(modpath)
assert(loadfile(modpath .. "/closet.lua"))(S)
