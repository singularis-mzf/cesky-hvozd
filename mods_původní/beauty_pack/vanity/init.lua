--
-- vanity
-- License:GPLv3
--

local modname = "vanity"
local modpath = minetest.get_modpath(modname)
-- internationalization boilerplate
local S = minetest.get_translator(minetest.get_current_modname())

--
-- Vanity Mod
--

vanity = {}

-- Load the files
assert(loadfile(modpath .. "/vanity.lua"))(S)
