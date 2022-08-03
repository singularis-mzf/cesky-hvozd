-- Giftbox2 mod configuration file

-- Random gift box drops (format is same as for drop in the node definition)
giftbox2.config.drops = {
	-- digging gift box allows for a single drop of items with a given a rarity
	{ items = { "default:shovel_diamond" }, rarity = 300 },
	{ items = { "default:axe_mese" }, rarity = 290 },
	{ items = { "default:shovel_bronze" }, rarity = 280 },

	{ items = { "default:diamondblock" }, rarity = 160 },
	{ items = { "default:goldblock" }, rarity = 160 },

	{ items = { "default:diamond 3" }, rarity = 150 },
	{ items = { "default:gold_ingot 6" }, rarity = 150 },
	{ items = { "default:steelblock 3" }, rarity = 150 },

	{ items = { "default:coalblock 10" }, rarity = 80 },
	{ items = { "default:obsidian 5" }, rarity = 80 },

	{ items = { "default:papyrus 9" }, rarity = 75 },
	{ items = { "default:cactus 9" }, rarity = 75 },

	{ items = { "default:sword_diamond" }, rarity = 40 },
	{ items = { "default:pick_diamond" }, rarity = 40 },

	{ items = { "default:wood 99" }, rarity = 25 },
	{ items = { "default:junglewood 99" }, rarity = 25 },
	{ items = { "default:pine_wood 99" }, rarity = 25 },
	{ items = { "default:aspen_wood 99" }, rarity = 25 },
	{ items = { "default:acacia_wood 99" }, rarity = 25 },

	{ items = { "default:sword_bronze" }, rarity = 20 },
	{ items = { "default:pick_bronze" }, rarity = 20 },

	{ items = { "default:blueberries 30" }, rarity = 6 },
	{ items = { "default:apple 30" }, rarity = 5 },

	{ items = { "default:clay 40" }, rarity = 5 },
	{ items = { "default:silver_sandstone 80" }, rarity = 4 },
	{ items = { "default:desert_sandstone 80" }, rarity = 4 },
	{ items = { "default:sandstone 80" }, rarity = 4 },

	{ items = { "default:coal_lump 3" }, rarity = 3 },

	-- default drop must be placed last and have rarity of 0 to avoid empty drops
	{ items = { "default:coal_lump" }, rarity = 0 },
}

-------------------------------------------------------

local N = function(s) return s end

-- Gift box texts
-- Warning: Changing these texts will break translation!
giftbox2.config.public_infotext1 = N("Gift Box")
giftbox2.config.public_infotext2 = N("“@1”")
giftbox2.config.private_infotext1 = N("Gift Box for @1")
giftbox2.config.private_infotext2 = N("Dear @1: “@2”")
