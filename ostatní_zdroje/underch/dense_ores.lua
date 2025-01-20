underch.dense_ores = {}

function underch.dense_ores.register_ore(name, id, texture, item)
	minetest.register_node("underch:" .. id .. "_dense_ore", {
		description = name .. " Dense Ore",
		tiles = {"default_stone.png^" .. texture .. "^(" .. texture .. "^[transform7)"},
		groups = {cracky = 1, jit_shadow = 1},
		after_dig_node = underch.jit.dig_shadow,
		drop = {
			items = {{items = {item .. " 2"}}, {items = {item}, rarity = 2}}
		},
		sounds = default.node_sound_stone_defaults(),
	})
end

underch.dense_ores.register_ore("Coal", "coal", "default_mineral_coal.png", "default:coal_lump");
underch.dense_ores.register_ore("Iron", "iron", "default_mineral_iron.png", "default:iron_lump");
underch.dense_ores.register_ore("Copper", "copper", "default_mineral_copper.png", "default:copper_lump");
underch.dense_ores.register_ore("Gold", "gold", "default_mineral_gold.png", "default:gold_lump");
