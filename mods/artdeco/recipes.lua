local italianmarble = "darkage:marble"
local limestone = "artdeco:2d"
local marble1e = "ch_extras:marble"
local stone = "default:stone"
local screwdriver = "unifieddyes:airbrush"

minetest.register_craft({
	output = "artdeco:1a",
	recipe = {
		{stone},
		{marble1e},
	},
})
minetest.register_craft({
	output = "artdeco:1b",
	recipe = {
		{"",            stone},
		{stone, marble1e},
	},
})
minetest.register_craft({
	output = "artdeco:1c",
	recipe = {
		{"",            stone, ""},
		{stone, marble1e,  stone},
	},
})
minetest.register_craft({
	output = "artdeco:1d",
	recipe = {
		{stone, "artdeco:1c",  stone},
	},
})
minetest.register_craft({
	output = marble1e,
	recipe = {
		{"group:marble"},
	},
})
minetest.register_craft({
	output = "artdeco:1f",
	recipe = {
		{stone, marble1e},
	},
})
minetest.register_craft({
	output = "artdeco:1g",
	recipe = {
		{stone, marble1e, stone},
	},
})
minetest.register_craft({
	output = "artdeco:1h",
	recipe = {
		{stone, "artdeco:1g", stone},
    },
})
minetest.register_craft({
	output = "artdeco:1i",
	recipe = {
		{marble1e},
		{stone},
	},
})
minetest.register_craft({
	output = "artdeco:1j",
	recipe = {
		{stone, marble1e},
		{"",            stone},
	},
})
minetest.register_craft({
	output = "artdeco:1k",
	recipe = {
		{stone, marble1e,  stone},
		{"",            stone, ""},
	},
})
minetest.register_craft({
	output = "artdeco:1l",
	recipe = {
		{stone, "artdeco:1k",  stone},
	},
})

minetest.register_craft({
    output = limestone,
	type = "shapeless",
    recipe = {"darkage:chalk_powder", "darkage:chalk_powder"},
})

minetest.register_craft({
	output = "artdeco:2a",
	recipe = {
		{stone},
		{limestone},
	},
})
minetest.register_craft({
	output = "artdeco:2b",
	recipe = {
		{limestone, stone},
	},
})
minetest.register_craft({
	output = "artdeco:2c",
	recipe = {
		{limestone},
		{stone},
	},
})

minetest.register_craft({
    type="cooking",
    output=italianmarble,
    recipe=marble1e,
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
	output = "artdeco:tile5 2",
	recipe = {
		{"bakedclay:slab_orange_2", "bakedclay:slab_orange_2", "bakedclay:slab_orange_2"},
		{"bakedclay:slab_orange_2", "artdeco:brownwalltile", "bakedclay:slab_orange_2"},
		{"bakedclay:slab_orange_2", "bakedclay:slab_orange_2", "bakedclay:slab_orange_2"},
	},
})
minetest.register_craft({
	output = "artdeco:brownwalltile 4",
	recipe = {
		{"bakedclay:orange",     "bakedclay:brown", ""},
		{"bakedclay:brown",     "bakedclay:orange", ""},
	},
})
minetest.register_craft({
	output = "artdeco:greenwalltile 4",
	recipe = {
		{"bakedclay:green", "bakedclay:white"},
		{"bakedclay:white", "bakedclay:green"},
	},
})
minetest.register_craft({
	output = "artdeco:ceilingtile",
	recipe = {
		{italianmarble, ""},
		{screwdriver, ""},
	},
    replacements = {{screwdriver, screwdriver}},
})
minetest.register_craft({
	output = "artdeco:decoblock1",
	recipe = {
        {screwdriver},
		{limestone},
	},
    replacements = {{screwdriver, screwdriver}},
})
minetest.register_craft({
	output = "artdeco:decoblock2",
	recipe = {
        {"", screwdriver},
		{limestone, ""},
	},
    replacements = {{screwdriver, screwdriver}},
})
minetest.register_craft({
	output = "artdeco:decoblock3",
	recipe = {
		{limestone, screwdriver},
	},
    replacements = {{screwdriver, screwdriver}},
})
minetest.register_craft({
	output = "artdeco:decoblock4",
	recipe = {
		{limestone, ""},
        {"", screwdriver},
	},
    replacements = {{screwdriver, screwdriver}},
})
minetest.register_craft({
	output = "artdeco:decoblock5",
	recipe = {
		{limestone},
        {screwdriver},
	},
    replacements = {{screwdriver, screwdriver}},
})
minetest.register_craft({
	output = "artdeco:decoblock6",
	recipe = {
		{"", limestone},
        {screwdriver, ""},
	},
    replacements = {{screwdriver, screwdriver}},
})

minetest.register_craft({
	output = "artdeco:whitegardenstone",
    type = "shapeless",
	recipe = {"default:gravel", "dye:white"},
})
minetest.register_craft({
	output = "artdeco:lionheart",
	recipe = {
		{screwdriver, limestone},
	},
    replacements = {{screwdriver, screwdriver}},
})

minetest.register_craft({
	output = "artdeco:arch2a 10",
	recipe = {
		{limestone, limestone, limestone},
		{limestone, "",           limestone},
	},
})
minetest.register_craft({
	output = "artdeco:arch1a 10",
	recipe = {
		{"artdeco:2a", "artdeco:2a", "artdeco:2a"},
		{limestone, "",           limestone},
	},
})
minetest.register_craft({
	output = "artdeco:arch1b 12",
	recipe = {
		{limestone, "",           limestone},
		{limestone, "",           limestone},
		{limestone, "",           limestone},
	},
})
minetest.register_craft({
	output = "artdeco:arch1c",
	recipe = {
		{limestone},
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
		{limestone, "",           ""},
		{limestone, "",           ""},
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
		{italianmarble,},
        {"default:glass",        },
        {"moreores:silver_lump",}
	},
})
minetest.register_craft({
	output = "artdeco:archwin1b",
	recipe = {
        {"moreores:silver_lump", "default:glass", italianmarble,},
	},
})
minetest.register_craft({
	output = "artdeco:archwin1c",
	recipe = {
        {"moreores:silver_lump",},
        {"default:glass",        },
		{italianmarble,},
	},
})
minetest.register_craft({
	output = "artdeco:archwin2a",
	recipe = {
		{italianmarble,},
        {"default:glass",        },
        {"default:copper_lump",}
	},
})
minetest.register_craft({
	output = "artdeco:archwin2b",
	recipe = {
        {"default:copper_lump", "default:glass", italianmarble,},
	},
})
minetest.register_craft({
	output = "artdeco:archwin2c",
	recipe = {
        {"default:copper_lump",},
        {"default:glass",        },
		{italianmarble,},
	},
})
minetest.register_craft({
	output = "artdeco:wincross1a",
	recipe = {
		{screwdriver, italianmarble},
	},
    replacements = {{screwdriver, screwdriver}},
})
minetest.register_craft({
	output = "artdeco:wincross1b",
	recipe = {
		{italianmarble, screwdriver},
	},
    replacements = {{screwdriver, screwdriver}},
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
		{limestone},
		{limestone},
		{limestone},
	},
})
minetest.register_craft({
	output = "artdeco:column_base 2",
	recipe = {
		{limestone},
		{"artdeco:column1d"},
	},
})
minetest.register_craft({
	output = "artdeco:thinstonewall 3",
	recipe = {
		{"default:cobble", "", ""},
		{"default:cobble", "", ""},
		{"default:cobble", "", ""},
	},
})
minetest.register_craft({
	output = "artdeco:estatedoor 2",
	recipe = {
		{"building_blocks:hardwood", "building_blocks:hardwood", ""},
		{"default:glass",            "default:glass", ""},
		{"building_blocks:hardwood", "building_blocks:hardwood", ""},
	},
})
