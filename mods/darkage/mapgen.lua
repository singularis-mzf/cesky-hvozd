--[[
	This file generates:
	darkage:mud
	darkage:silt
	darkage:chalk
	darkage:ors
	darkage:shale
	darkage:slate
	darkage:schist
	darkage:basalt
	darkage:marble
	darkage:serpentine
	darkage:gneiss
--]]

--[[ Updated by lumberJack (2021) to use optimize mapgen with register_ore method.
Attempts to follow general trends of legacy mapgen (available in legacy_mapgen.lua), 
but with some variation to suit newer biomes that have become available since this mod was authored. 
Some tweaking to noise params may be needed to adjust to desired rarity and other characteristics of ores. ]]--

minetest.register_ore({
    ore_type = "sheet",
    ore = "darkage:mud",
    wherein = {
        "default:dirt_with_grass", "default:dirt", 
        "default:dry_dirt", "default:dry_dirt_with_dry_grass", 
        "default:dirt_with_dry_grass",
        "default:dirt_with_rainforest_litter"
    },
    y_min = -4,
    y_max = 1,
    column_height_min = 6,
    column_height_max = 6,
    column_midpoint_factor = 0,
    biomes = {"deciduous_forest_shore", "savanna_shore", "rainforest_swamp"},
    noise_threshold = 0.4,
    noise_params = {
        offset = 0,
        scale = 1,
        spread = {x = 100, y = 100, z = 100},
        seed = 129,
        octaves = 1,
        persist = 0.6
    }
})

minetest.register_ore({
    ore_type = "sheet",
    ore = "darkage:silt",
    wherein = "default:dirt",
    y_min = -15,
    y_max = 0,
    column_height_min = 1,
    column_height_max = 5,
    biomes = {"deciduous_forest_shore", "savanna_shore", "rainforest_swamp"},
    noise_threshold = 0.5,
    noise_params = {
        offset = 0,
        scale = 1,
        spread = {x = 100, y = 100, z = 100},
        seed = 48,
        octaves = 1,
        persist = 0.6
    }
})

minetest.register_ore({
    ore_type = "sheet",
    ore = "darkage:chalk",
    wherein = "default:stone",
    y_min = -15,
    y_max = 31000,
    column_height_min = 6,
    column_height_max = 10,
    noise_threshold = 0.5,
    noise_params = {
        offset = 0,
        scale = 1,
        spread = {x = 128, y = 128, z = 128},
        seed = 137,
        octaves = 1,
        persist = 0.55
    }
})

minetest.register_ore({
    ore_type = "sheet",
    ore = "darkage:ors",
    wherein = { "default:desert_stone", "default:desert_sandstone"},
    y_min = -200,
    y_max = 31000,
    column_height_min = 6,
    column_height_max = 10,
    noise_threshold = 0.2,
    noise_params = {
        offset = 0,
        scale = 1,
        spread = {x = 120, y = 120, z = 120},
        seed = 153,
        octaves = 1,
        persist = 0.5
    }
})

minetest.register_ore({
    ore_type = "sheet",
    ore = "darkage:shale",
    wherein = "default:stone",
    y_min = -50,
    y_max = 10,
    column_height_min = 6,
    column_height_max = 10,
    noise_threshold = 0.35,
    noise_params = {
        offset = -0.12,
        scale = 1,
        spread = {x = 100, y = 100, z = 100},
        seed = 4171,
        octaves = 1,
        persist = 0.6
    }
})

minetest.register_ore({
    ore_type = "sheet",
    ore = "darkage:slate",
    wherein = "default:stone",
    y_min = -500,
    y_max = 0,
    column_height_min = 6,
    column_height_max = 10,
    noise_threshold = 0.35,
    noise_params = {
        offset = -0.12,
        scale = 1,
        spread = {x = 100, y = 100, z = 100},
        seed = 3127,
        octaves = 1,
        persist = 0.6
    }
})

minetest.register_ore({
    ore_type = "sheet",
    ore = "darkage:schist",
    wherein = "default:stone",
    y_min = -31000,
    y_max = -10,
    column_height_min = 6,
    column_height_max = 10,
    noise_threshold = 0.4,
    noise_params = {
        offset = -0.12,
        scale = 1,
        spread = {x = 100, y = 100, z = 100},
        seed = 8291,
        octaves = 1,
        persist = 0.6
    }
})

minetest.register_ore({
    ore_type = "sheet",
    ore = "darkage:basalt",
    wherein = "default:stone",
    y_min = -31000,
    y_max = -50,
    column_height_min = 6,
    column_height_max = 10,
    noise_threshold = 0.35,
    noise_params = {
        offset = 0,
        scale = 1,
        spread = {x = 100, y = 100, z = 100},
        seed = 2203,
        octaves = 1,
        persist = 0.6
    }
})


minetest.register_ore({
    ore_type = "sheet",
    ore = "darkage:marble",
    wherein = "default:stone",
    y_min = -31000,
    y_max = -75,
    column_height_min = 6,
    column_height_max = 10,
    noise_threshold = 0.35,
    noise_params = {
        offset = 0,
        scale = 1,
        spread = {x = 100, y = 100, z = 100},
        seed = 1219,
        octaves = 1,
        persist = 0.6
    }
})


minetest.register_ore({
    ore_type = "sheet",
    ore = "darkage:serpentine",
    wherein = "default:stone",
    y_min = -31000,
    y_max = -350,
    column_height_min = 6,
    column_height_max = 10,
    noise_threshold = 0.4,
    noise_params = {
        offset = 0,
        scale = 1,
        spread = {x = 100, y = 100, z = 100},
        seed = 9261,
        octaves = 1,
        persist = 0.6
    }
})

minetest.register_ore({
    ore_type = "sheet",
    ore = "darkage:gneiss",
    wherein = "default:stone",
    y_min = -31000,
    y_max = -250,
    column_height_min = 6,
    column_height_max = 10,
    noise_threshold = 0.35,
    noise_params = {
        offset = 0,
        scale = 1,
        spread = {x = 100, y = 100, z = 100},
        seed = 234,
        octaves = 1,
        persist = 0.6
    }
})