local ores_in_stone = {
	["default:stone_with_coal"] = {"default:stone", "default:coal_lump"},
	["default:stone_with_copper"] = {"default:stone", "default:copper_lump"},
	["default:stone_with_diamond"] = {"default:stone", "default:diamond"},
	["default:stone_with_gold"] = {"default:stone", "default:gold_lump"},
	["default:stone_with_iron"] = {"default:stone", "default:iron_lump"},
	-- ["default:stone_with_mese"] = {"default:stone", "default:mese_crystal"},
	["default:stone_with_tin"] = {"default:stone", "default:tin_lump"},
	["moreores:mineral_mithril"] = {"default:stone", "moreores:mithril_lump"},
	["moreores:mineral_silver"] = {"default:stone", "moreores:silver_lump"},
	["technic:mineral_chromium"] = {"default:stone", "technic:chromium_lump"},
	["technic:mineral_lead"] = {"default:stone", "technic:lead_lump"},
	["technic:mineral_sulfur"] = {"default:stone", "technic:sulfur_lump"},
	["technic:mineral_uranium"] = {"default:stone", "technic:uranium_lump"},
	["technic:mineral_zinc"] = {"default:stone", "technic:zinc_lump"},

	["denseores:large_coal_ore"] = {"default:stone", "default:coal_lump", "default:coal_lump"},
	["denseores:large_copper_ore"] = {"default:stone", "default:copper_lump", "default:copper_lump"},
	["denseores:large_diamond_ore"] = {"default:stone", "default:diamond", "default:diamond"},
	["denseores:large_gold_ore"] = {"default:stone", "default:gold_lump", "default:gold_lump"},
	["denseores:large_iron_ore"] = {"default:stone", "default:iron_lump", "default:iron_lump"},
	["denseores:large_mese_ore"] = {"default:stone", "default:mese_crystal", "default:mese_crystal"},
	["denseores:large_mithril_ore"] = {"default:stone", "moreores:mithril_lump", "moreores:mithril_lump"},
	["denseores:large_silver_ore"] = {"default:stone", "moreores:silver_lump", "moreores:silver_lump"},
	["denseores:large_tin_ore"] = {"default:stone", "default:tin_lump", "default:tin_lump"},
}

for mineral, recipe in pairs(ores_in_stone) do
	minetest.register_craft({output = mineral, type = "shapeless", recipe = recipe})
end
