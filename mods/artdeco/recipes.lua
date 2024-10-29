minetest.register_craft({
	output = "artdeco:1a",
	recipe = {
		{"group:stone"},
		{"artdeco:1e"},
	},
})
minetest.register_craft({
	output = "artdeco:1b",
	recipe = {
		{"",            "group:stone"},
		{"group:stone", "artdeco:1e"},
	},
})
minetest.register_craft({
	output = "artdeco:1c",
	recipe = {
		{"",            "group:stone", ""},
		{"group:stone", "artdeco:1e",  "group:stone"},
	},
})
minetest.register_craft({
	output = "artdeco:1d",
	recipe = {
		{"group:stone", "artdeco:1c",  "group:stone"},
	},
})
minetest.register_craft({
	output = "artdeco:1e",
	recipe = {
		{"group:marble"},
	},
})
minetest.register_craft({
	output = "artdeco:1f",
	recipe = {
		{"group:stone", "artdeco:1e"},
	},
})
minetest.register_craft({
	output = "artdeco:1g",
	recipe = {
		{"group:stone", "artdeco:1e", "group:stone"},
	},
})
minetest.register_craft({
	output = "artdeco:1h",
	recipe = {
		{"group:stone", "artdeco:1g", "group:stone"},
    },
})
minetest.register_craft({
	output = "artdeco:1i",
	recipe = {
		{"artdeco:1e"},
		{"group:stone"},
	},
})
minetest.register_craft({
	output = "artdeco:1j",
	recipe = {
		{"group:stone", "artdeco:1e"},
		{"",            "group:stone"},
	},
})
minetest.register_craft({
	output = "artdeco:1k",
	recipe = {
		{"group:stone", "artdeco:1e",  "group:stone"},
		{"",            "group:stone", ""},
	},
})
minetest.register_craft({
	output = "artdeco:1l",
	recipe = {
		{"group:stone", "artdeco:1k",  "group:stone"},
	},
})

minetest.register_craft({
    type="cooking",
    output="artdeco:2d",
    recipe="default:coral_skeleton",
})

minetest.register_craft({
	output = "artdeco:2a",
	recipe = {
		{"group:stone"},
		{"artdeco:2d"},
	},
})
minetest.register_craft({
	output = "artdeco:2b",
	recipe = {
		{"artdeco:2d", "group:stone"},
	},
})
minetest.register_craft({
	output = "artdeco:2c",
	recipe = {
		{"artdeco:2d"},
		{"group:stone"},
	},
})

minetest.register_craft({
    type="cooking",
    output="artdeco:italianmarble",
    recipe="artdeco:1e",
})


minetest.register_craft({
	output = "artdeco:tile1 11",
	recipe = {
		{"default:stone",     "default:gold_lump", "default:stone"},
		{"default:gold_lump", "default:stone",     "default:gold_lump"},
		{"default:stone",     "default:gold_lump", "default:stone"},
	},
})
minetest.register_craft({
	output = "artdeco:tile2 11",
	recipe = {
		{"default:gold_lump", "default:stone",     "default:gold_lump"},
		{"default:stone",     "default:gold_lump", "default:stone"},
		{"default:gold_lump", "default:stone",     "default:gold_lump"},
	},
})
minetest.register_craft({
	output = "artdeco:tile3 11",
	recipe = {
		{"default:clay_brick", "default:stone",      "default:clay_brick"},
		{"default:stone",      "default:clay_brick", "default:stone"},
		{"default:clay_brick", "default:stone",      "default:clay_brick"},
	},
})
minetest.register_craft({
	output = "artdeco:tile4 11",
	recipe = {
		{"default:stone",      "default:clay_brick", "default:stone"},
		{"default:clay_brick", "default:stone",      "default:clay_brick"},
		{"default:stone",      "default:clay_brick", "default:stone"},
	},
})
minetest.register_craft({
	output = "artdeco:tile5 5",
	recipe = {
		{"",                       "default:sandstonebrick", ""},
		{"default:sandstonebrick", "default:obsidianbrick",  "default:sandstonebrick"},
		{"",                       "default:sandstonebrick", ""},
	},
})
minetest.register_craft({
	output = "artdeco:brownwalltile",
	recipe = {
		{"default:desert_stone",     "default:desert_sandstone", "default:desert_stone"},
		{"default:desert_sandstone", "default:desert_stone",     "default:desert_sandstone"},
		{"default:desert_stone",     "default:desert_sandstone", "default:desert_stone"},
	},
})
minetest.register_craft({
	output = "artdeco:greenwalltile",
	recipe = {
		{"default:sandstone", "default:stone",     "default:sandstone"},
		{"default:stone",     "default:sandstone", "default:stone"},
		{"default:sandstone", "default:stone",     "default:sandstone"},
	},
})
minetest.register_craft({
	output = "artdeco:ceilingtile",
	recipe = {
		{"default:silver_sandstone", "screwdriver:screwdriver"},
	},
    replacements = {{"screwdriver:screwdriver", "screwdriver:screwdriver"}},
})
minetest.register_craft({
	output = "artdeco:decoblock1",
	recipe = {
        {"screwdriver:screwdriver"},
		{"artdeco:2d"},
	},
    replacements = {{"screwdriver:screwdriver", "screwdriver:screwdriver"}},
})
minetest.register_craft({
	output = "artdeco:decoblock2",
	recipe = {
        {"", "screwdriver:screwdriver"},
		{"artdeco:2d", ""},
	},
    replacements = {{"screwdriver:screwdriver", "screwdriver:screwdriver"}},
})
minetest.register_craft({
	output = "artdeco:decoblock3",
	recipe = {
		{"artdeco:2d", "screwdriver:screwdriver"},
	},
    replacements = {{"screwdriver:screwdriver", "screwdriver:screwdriver"}},
})
minetest.register_craft({
	output = "artdeco:decoblock4",
	recipe = {
		{"artdeco:2d", ""},
        {"", "screwdriver:screwdriver"},
	},
    replacements = {{"screwdriver:screwdriver", "screwdriver:screwdriver"}},
})
minetest.register_craft({
	output = "artdeco:decoblock5",
	recipe = {
		{"artdeco:2d"},
        {"screwdriver:screwdriver"},
	},
    replacements = {{"screwdriver:screwdriver", "screwdriver:screwdriver"}},
})
minetest.register_craft({
	output = "artdeco:decoblock6",
	recipe = {
		{"", "artdeco:2d"},
        {"screwdriver:screwdriver", ""},
	},
    replacements = {{"screwdriver:screwdriver", "screwdriver:screwdriver"}},
})

minetest.register_craft({
	output = "artdeco:whitegardenstone",
    type = "shapeless",
	recipe = {"default:gravel", "dye:white"},
})
minetest.register_craft({
	output = "artdeco:stonewall",
    type = "shapeless",
	recipe = {"default:gravel", "dye:brown", "basic_materials:wet_cement"},
})
minetest.register_craft({
	output = "artdeco:lionheart",
	recipe = {
		{"screwdriver:screwdriver", "artdeco:2d"},
	},
    replacements = {{"screwdriver:screwdriver", "screwdriver:screwdriver"}},
})

minetest.register_craft({
	output = "artdeco:arch2a 10",
	recipe = {
		{"artdeco:2d", "artdeco:2d", "artdeco:2d"},
		{"artdeco:2d", "",           "artdeco:2d"},
	},
})
minetest.register_craft({
	output = "artdeco:arch1a 10",
	recipe = {
		{"artdeco:2a", "artdeco:2a", "artdeco:2a"},
		{"artdeco:2d", "",           "artdeco:2d"},
	},
})
minetest.register_craft({
	output = "artdeco:arch1b 12",
	recipe = {
		{"artdeco:2d", "",           "artdeco:2d"},
		{"artdeco:2d", "",           "artdeco:2d"},
		{"artdeco:2d", "",           "artdeco:2d"},
	},
})
minetest.register_craft({
	output = "artdeco:arch1c",
	recipe = {
		{"artdeco:2d"},
	},
})
minetest.register_craft({
	output = "artdeco:arch1d",
	recipe = {
		{"artdeco:2c"},
	},
})
minetest.register_craft({
	output = "artdeco:arch1e",
	recipe = {
		{"artdeco:2a"},
	},
})
minetest.register_craft({
	output = "artdeco:dblarch1a 10",
	recipe = {
		{"artdeco:2a", "artdeco:2a", "artdeco:2a"},
		{"artdeco:2d", "",           ""},
		{"artdeco:2d", "",           ""},
	},
})

minetest.register_craft({
	output = "artdeco:dblarchslab 4",
	recipe = {
		{"artdeco:2a", "artdeco:2a"},
	},
})
minetest.register_craft({
	output = "artdeco:archwin1a",
	recipe = {
		{"artdeco:italianmarble",},
        {"default:glass",        },
        {"moreores:silver_lump",}
	},
})
minetest.register_craft({
	output = "artdeco:archwin1b",
	recipe = {
        {"moreores:silver_lump", "default:glass", "artdeco:italianmarble",},
	},
})
minetest.register_craft({
	output = "artdeco:archwin1c",
	recipe = {
        {"moreores:silver_lump",},
        {"default:glass",        },
		{"artdeco:italianmarble",},
	},
})
minetest.register_craft({
	output = "artdeco:archwin2a",
	recipe = {
		{"artdeco:italianmarble",},
        {"default:glass",        },
        {"default:copper_lump",}
	},
})
minetest.register_craft({
	output = "artdeco:archwin2b",
	recipe = {
        {"default:copper_lump", "default:glass", "artdeco:italianmarble",},
	},
})
minetest.register_craft({
	output = "artdeco:archwin2c",
	recipe = {
        {"default:copper_lump",},
        {"default:glass",        },
		{"artdeco:italianmarble",},
	},
})
minetest.register_craft({
	output = "artdeco:wincross1a",
	recipe = {
		{"screwdriver:screwdriver", "artdeco:italianmarble"},
	},
    replacements = {{"screwdriver:screwdriver", "screwdriver:screwdriver"}},
})
minetest.register_craft({
	output = "artdeco:wincross1b",
	recipe = {
		{"artdeco:italianmarble", "screwdriver:screwdriver"},
	},
    replacements = {{"screwdriver:screwdriver", "screwdriver:screwdriver"}},
})
minetest.register_craft({
	output = "artdeco:lightwin1",
	recipe = {
        {"",                            "homedecor:pole_wrought_iron", ""},
		{"homedecor:pole_wrought_iron", "moreblocks:super_glow_glass", "homedecor:pole_wrought_iron"},
	},
})
minetest.register_craft({
	output = "artdeco:lightwin2",
	recipe = {
		{"homedecor:pole_wrought_iron", "moreblocks:super_glow_glass", "homedecor:pole_wrought_iron"},
	},
})
minetest.register_craft({
	output = "artdeco:lightwin3",
	recipe = {
		{"homedecor:pole_wrought_iron", "moreblocks:super_glow_glass", "homedecor:pole_wrought_iron"},
        {"",                            "homedecor:pole_wrought_iron", ""},
	},
})
minetest.register_craft({
	output = "artdeco:irongrating",
	recipe = {
		{"homedecor:fence_wrought_iron_2"},
	},
})
minetest.register_craft({
	output = "artdeco:column1a 3",
	recipe = {
		{"artdeco:2a"},
		{"artdeco:2a"},
		{"artdeco:2a"},
	},
})
minetest.register_craft({
	output = "artdeco:column1b 3",
	recipe = {
		{"artdeco:2b"},
		{"artdeco:2b"},
		{"artdeco:2b"},
	},
})
minetest.register_craft({
	output = "artdeco:column1c",
	recipe = {
		{"artdeco:2c"},
		{"artdeco:2c"},
		{"artdeco:2c"},
	},
})
minetest.register_craft({
	output = "artdeco:column1d",
	recipe = {
		{"artdeco:2d"},
		{"artdeco:2d"},
		{"artdeco:2d"},
	},
})
minetest.register_craft({
	output = "artdeco:column_base 2",
	recipe = {
		{"artdeco:2d"},
		{"artdeco:column1d"},
	},
})
minetest.register_craft({
	output = "artdeco:thinstonewall 6",
	recipe = {
		{"artdeco:stonewall", "artdeco:stonewall", "artdeco:stonewall", },
		{"artdeco:stonewall", "artdeco:stonewall", "artdeco:stonewall", },
	},
})
minetest.register_craft({
	output = "artdeco:estatedoor 2",
	recipe = {
		{"building_blocks:hardwood", "building_blocks:hardwood"},
		{"default:glass",            "artdeco:irongrating"},
		{"building_blocks:hardwood", "building_blocks:hardwood"},
	},
})
