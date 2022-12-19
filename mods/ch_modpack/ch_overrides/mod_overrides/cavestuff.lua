-- DROPS
local override = {
	drop = {
		max_items = 1,
		items = {
			{items = {"cavestuff:pebble_1", "cavestuff:pebble_1", "cavestuff:pebble_1", "cavestuff:pebble_1"}, rarity = 16},
			{items = {"default:cobble"}, rarity = 1},
		}
	}
}
minetest.override_item("default:cobble", override)
minetest.override_item("default:stone", override)

override = {
	drop = {
		max_items = 1,
		items = {
			{items = {"cavestuff:desert_pebble_1", "cavestuff:desert_pebble_1", "cavestuff:desert_pebble_1", "cavestuff:desert_pebble_1"}, rarity = 16},
			{items = {"default:desert_cobble"}, rarity = 1},
		}
	}
}
minetest.override_item("default:desert_cobble", override)
minetest.override_item("default:desert_stone", override)
