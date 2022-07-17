--[[

Ice Cream Mod by Can202

Credits:

We Used VSCode(to edit text), Pixelorama(Edit Pixel Art)

Can202 (Coding, and Pixel Art)

]]

local modpath = minetest.get_modpath("icecream")

dofile(modpath.."/src/item.lua")
dofile(modpath.."/src/craft.lua")

if minetest.get_modpath("awards") then
	dofile(modpath.."/src/awards.lua")
end
