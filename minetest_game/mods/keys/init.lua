ch_base.open_mod(minetest.get_current_modname())
-- Minetest mod: keys
local keys_path = minetest.get_modpath("keys")

dofile(keys_path.."/craftitems.lua")
dofile(keys_path.."/crafting.lua")
dofile(keys_path.."/aliases.lua")
ch_base.close_mod(minetest.get_current_modname())
