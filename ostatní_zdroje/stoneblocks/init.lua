local modpath = minetest.get_modpath("stoneblocks")
stoneblocks = {}
stoneblocks.S = nil

if(minetest.get_translator ~= nil) then
    stoneblocks.S = minetest.get_translator(minetest.get_current_modname())
else
    stoneblocks.S = function ( s ) return s end
end

local sound_api = dofile(modpath .. "/sound_api/init.lua")
stoneblocks.soundApi = sound_api

dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/dynamic.lua")
dofile(modpath .. "/ores.lua")
dofile(modpath .. "/crafts.lua")

