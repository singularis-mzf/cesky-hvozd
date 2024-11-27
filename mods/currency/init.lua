ch_base.open_mod(minetest.get_current_modname())
local modpath = minetest.get_modpath("currency")

minetest.log("info", "Currency mod loading...")

currency = {}
if minetest.global_exists("default") then
	currency.node_sound_wood_defaults = default.node_sound_wood_defaults
else
	currency.node_sound_wood_defaults = function() end
end

dofile(modpath.."/barter.lua")
minetest.log("info", "[Currency] Barter Loaded!")
dofile(modpath.."/safe.lua")
minetest.log("info", "[Currency] Safe Loaded!")
dofile(modpath.."/crafting.lua")
minetest.log("info", "[Currency] Crafting Loaded!")
ch_base.close_mod(minetest.get_current_modname())
