ch_base.open_mod(minetest.get_current_modname())

local dofile = ch_core.compile_dofile()

dofile("builtin_item.lua") -- upraví chování předmětů na zemi
dofile("dirt_with_x.lua") -- upraví textury hlíny
dofile("mese_crystals.lua") -- použije model (mesh) k zobrazení krystalů mese, umožní jejich umístění do herního světa
dofile("snow.lua") -- použije model (mesh) k zobrazení sněhu

--[[ temp

minetest.override_item("default:aspen_wood", {
	tiles = {"(default_aspen_wood.png^[resize:128x128)^(ch_core_planks_128.png^[makealpha:255,255,255^[opacity:50^[resize:128x128)"},
})

minetest.override_item("default:acacia_wood", {
	tiles = {"(default_acacia_wood.png^[resize:128x128)^(ch_core_planks_128.png^[makealpha:255,255,255^[opacity:100^[resize:128x128)"},
})

minetest.override_item("default:junglewood", {
	tiles = {"(default_junglewood.png^[resize:128x128)^(ch_core_planks_128.png^[makealpha:255,255,255^[opacity:150^[resize:128x128)"},
})
]]

--[[
minetest.override_item("default:pine_wood", {
	tiles = {"default_pine_wood.png^[resize:128x128^(ch_core_planks_128.png^[makealpha:255,255,255^[opacity:50^[resize:128x128)"},
})
]]

--[[
minetest.override_item("default:wood", {
	tiles = {"(default_wood.png^[resize:128x128)^(ch_core_planks_128.png^[makealpha:255,255,255^[opacity:100^[resize:128x128)"},
}) ]]
ch_base.close_mod(minetest.get_current_modname())
