--
-- fabric
-- License:GPLv3
--

-- internationalization boilerplate
local S = minetest.get_translator(minetest.get_current_modname())

--
-- Fabric Mod
--

local fabric_dyes = dye.dyes

for i = 1, #fabric_dyes do
	if fabric_dyes[i][1] == "white" then
		fabric_dyes[i][3] = "FFFFFF"
	elseif fabric_dyes[i][1] == "grey" then
		fabric_dyes[i][3] = "808080"
	elseif fabric_dyes[i][1] == "dark_grey" then
		fabric_dyes[i][3] = "A9A9A9"
	elseif fabric_dyes[i][1] == "black" then
		fabric_dyes[i][3] = "000000"
	elseif fabric_dyes[i][1] == "violet" then
		fabric_dyes[i][3] = "EE82EE"
	elseif fabric_dyes[i][1] == "blue" then
		fabric_dyes[i][3] = "0000FF"
	elseif fabric_dyes[i][1] == "cyan" then
		fabric_dyes[i][3] = "00FFFF"
	elseif fabric_dyes[i][1] == "dark_green" then
		fabric_dyes[i][3] = "006400"
	elseif fabric_dyes[i][1] == "green" then
		fabric_dyes[i][3] = "008000"
	elseif fabric_dyes[i][1] == "yellow" then
		fabric_dyes[i][3] = "FFFF00"
	elseif fabric_dyes[i][1] == "brown" then
		fabric_dyes[i][3] = "A52A2A"
	elseif fabric_dyes[i][1] == "orange" then
		fabric_dyes[i][3] = "FFA500"
	elseif fabric_dyes[i][1] == "red" then
		fabric_dyes[i][3] = "FF0000"
	elseif fabric_dyes[i][1] == "magenta" then
		fabric_dyes[i][3] = "FF00FF"
	elseif fabric_dyes[i][1] == "pink" then
		fabric_dyes[i][3] = "FFC0CB"
	end
end

for i = 1, #fabric_dyes do

	local name, desc, rgb = unpack(fabric_dyes[i])

	desc = S(desc)

	minetest.register_craftitem("fabric:".. name, {
		description = S("@1 Cotton Fabric", desc),
		inventory_image = "fabric_fabric.png^[colorize:#"..rgb..":180",
	})

	minetest.register_craft({
		output = "fabric:".. name,
		type = "shaped",
			recipe = {
			{"", "", ""},
			{"", "group:dye,color_" .. name, ""},
			{"farming:cotton", "farming:cotton", "farming:cotton"},
		}
	})
end
