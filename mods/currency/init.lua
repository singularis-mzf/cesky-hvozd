print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
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
print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
