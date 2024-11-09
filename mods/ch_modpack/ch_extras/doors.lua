-- Doors: ch_extras:*
---------------------------------------------------------------
local def = {
	tiles = {{name = "ch_extras_obsidian_door.png", backface_culling = true}},
	description = "luxusní obsidiánové dveře",
	inventory_image = "ch_extras_obsidian_door_item.png",
	groups = {node = 1, cracky = 3},
	sounds = default.node_sound_glass_defaults(),
	sound_open = "doors_glass_door_open",
	sound_close = "doors_glass_door_close",
	gain_open = 0.3, gain_close = 0.25,
	recipe = {
		{"default:gold_ingot", ""},
		{"doors:door_obsidian_glass", ""},
	},
}
doors.register("door_luxury_obsidian", def)
minetest.register_craft({
	output = "doors:door_luxury_obsidian",
	recipe = {
		{"default:obsidian_glass", "default:obsidian_glass", "default:gold_ingot"},
		{"default:obsidian_glass", "default:obsidian_glass", ""},
		{"default:obsidian_glass", "default:obsidian_glass", ""},
	},
})

def = {
	tiles = {{name = "ch_extras_glass_door.png", backface_culling = true}},
	description = "luxusní prosklené dveře",
	inventory_image = "ch_extras_glass_door_item.png",
	groups = {node = 1, cracky = 3},
	sounds = default.node_sound_glass_defaults(),
	sound_open = "doors_glass_door_open",
	sound_close = "doors_glass_door_close",
	gain_open = 0.3, gain_close = 0.25,
	recipe = {
		{"default:glass", "default:steel_ingot", ""},
		{"default:glass", "default:glass", ""},
		{"default:glass", "group:wood", ""},
	},
}
doors.register("door_luxury_glass", def)

def = {
	tiles = {{name = "ch_extras_wood_door.png", backface_culling = true}},
	description = "stylové dřevěné dveře",
	inventory_image = "ch_extras_wood_door_item.png",
	groups = {node = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	gain_open = 0.06, gain_close = 0.13,
	recipe = {
		{"default:glass", "default:glass", ""},
		{"group:wood", "group:wood", ""},
		{"group:wood", "group:wood", ""},
	},
}
doors.register("door_luxury_wood", def)

local function get_stone_door_inventory_image(texture)
	return "[combine:40x40:12,4=default_stone.png\\^[resize\\:16x16:12,20=default_stone.png\\^[resize\\:16x16"
end

local function get_stone_door_tile(texture)
	return {name = "[combine:128x128:0,0="..texture.."\\^[resize\\:64x64:64,0="..texture.."\\^[resize\\:64x64:0,64="..texture.."\\^[resize\\:64x64:64,64="..texture.."\\^[resize\\:64x64", backface_culling = true}
end

-- doors:stone_door
doors.register("door_stone", {
	tiles = {get_stone_door_tile("default_stone.png")},
	use_texture_alpha = "opaque",
	description = "kamenné dveře ze skalního kamene",
	inventory_image = get_stone_door_inventory_image("default_stone.png"),
	groups = { cracky = 2, oddly_breakable_by_hand = 2 },
	recipe = {
		{"default:stone", "default:stone", ""},
		{"default:stone", "default:stone", ""},
		{"default:stone", "default:stone", ""},
	},
})

doors.register("door_desert_stone", {
	tiles = {get_stone_door_tile("default_desert_stone.png")},
	use_texture_alpha = "opaque",
	description = "kamenné dveře z pouštního kamene",
	inventory_image = get_stone_door_inventory_image("default_desert_stone.png"),
	groups = { cracky = 2, oddly_breakable_by_hand = 2 },
	recipe = {
		{"default:desert_stone", "default:desert_stone", ""},
		{"default:desert_stone", "default:desert_stone", ""},
		{"default:desert_stone", "default:desert_stone", ""},
	},
})
