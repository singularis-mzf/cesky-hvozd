ch_base.open_mod(minetest.get_current_modname())
tombs = {}
tombs.nodes = {}
tombs.recipes = {}
--break the file up to make it easier to maintain.
dofile(minetest.get_modpath('tombs')..'/machine.lua')
dofile(minetest.get_modpath('tombs')..'/collision_boxes.lua')
dofile(minetest.get_modpath('tombs')..'/gravestones.lua')
dofile(minetest.get_modpath('tombs')..'/formspec.lua')
dofile(minetest.get_modpath('tombs')..'/chisel.lua')

-- materials

local color_gold = "#C0AA1C"
local color_white = "#FFFFFF"

local materials = {
	["bakedclay:black"] = {color = color_gold},
	["bakedclay:blue"] = {color = color_gold},
	-- ["bakedclay:brown"] = true,
	["bakedclay:cyan"] = {color = color_white},
	["bakedclay:dark_green"] = {color = color_gold},
	["bakedclay:dark_grey"] = {color = color_white},
	["bakedclay:green"] = {color = color_white},
	["bakedclay:grey"] = true,
	["bakedclay:magenta"] = {color = color_white},
	-- ["bakedclay:natural"] = true,
	["bakedclay:orange"] = true,
	["bakedclay:pink"] = true,
	["bakedclay:red"] = {color = color_gold},
	["bakedclay:violet"] = {color = color_gold},
	["bakedclay:white"] = true,
	-- ["bakedclay:yellow"] = true,
	-- ["basic_materials:cement_block"] = true,
	["basic_materials:concrete_block"] = {color = color_gold},
	-- ["darkage:marble"] = true,
	-- ["default:desert_sandstone"] = true,
	["default:desert_stone"] = {color = color_white},
	["default:goldblock"] = true,
	-- ["default:sandstone"] = true,
	-- ["default:silver_sandstone"] = true,
	["default:steelblock"] = true,
	["default:stone"] = {color = color_gold},
	["default:mossycobble"] = {color = color_white, map64 = true},
	["default:wood"] = {color = color_white},
	["ch_extras:marble"] = true,
	["moreblocks:copperpatina"] = true,
	-- ["technic:blast_resistant_concrete"] = true,
	["technic:granite"] = {color = color_white},
	["technic:marble"] = true,
}

-- bakedclay

local empty_table = {}

for name, mdef in pairs(materials) do
	local ndef = minetest.registered_nodes[name]
	if ndef ~= nil then
		if mdef == true then
			mdef = {color = "black"}
		end
		if ndef.description == nil then
			error("[tombs] Invalid description for "..name)
		end
		local texture = ndef.tiles
		if type(texture) == "table" then
			texture = texture[1]
			if type(texture) == "table" then
				texture = assert(texture.name)
			end
		end
		if mdef.map64 then
			local t = "[combine:64x64"
			for x = -16, 48, 32 do
				for y = -16, 48, 32 do
					t = t..":"..x..","..y.."="..texture.."\\^[resize\\:32x32"
				end
			end
			texture = t
		end
		tombs.register_stones(name, name:gsub(":", "_"), ndef.description, {{name = texture}}, mdef)
	else
		minetest.log("warning", "Material "..name.." expected for tomb stone not found!")
	end
end
ch_base.close_mod(minetest.get_current_modname())
