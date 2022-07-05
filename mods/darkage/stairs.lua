if minetest.get_modpath("moreblocks") then

local S = minetest.get_translator("darkage")

	stairsplus:register_all("darkage", "basalt", "darkage:basalt", {
		description = S("Basalt"),
		tiles = {"darkage_basalt.png"},
		groups = {cracky=3},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

	stairsplus:register_all("darkage", "marble", "darkage:marble", {
		description = S("Marble"),
		tiles = {"darkage_marble.png"},
		groups = {cracky=3},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

	stairsplus:register_all("darkage", "serpentine", "darkage:serpentine", {
		description = S("Serpentine"),
		tiles = {"darkage_serpentine.png"},
		groups = {cracky=3},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

	stairsplus:register_all("darkage", "ors", "darkage:ors", {
		description = S("Old Red Sandstone"),
		tiles = {"darkage_ors.png"},
		groups = {crumbly=2,cracky=2},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

	stairsplus:register_all("darkage", "schist", "darkage:schist", {
		description = S("Schist"),
		tiles = {"darkage_schist.png"},
		groups = {cracky=3},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

	stairsplus:register_all("darkage", "slate", "darkage:slate", {
		description = S("Slate"),
		tiles = {"darkage_slate.png"},
		groups = {cracky=2},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

	stairsplus:register_all("darkage", "gneiss", "darkage:gneiss", {
		description = S("Gneiss"),
		tiles = {"darkage_gneiss.png"},
		groups = {cracky=3},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

	stairsplus:register_all("darkage", "chalk", "darkage:chalk", {
		description = S("Chalk"),
		tiles = {"darkage_chalk.png"},
		groups = {crumbly=2,cracky=2},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

	stairsplus:register_all("darkage", "slate_cobble", "darkage:slate_cobble", {
		description = S("Slate Cobble"),
		tiles = {"darkage_slate_cobble.png"},
		groups = {cracky=2},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

	stairsplus:register_all("darkage", "slate_brick", "darkage:slate_brick", {
		description = S("Slate Brick"),
		tiles = {"darkage_slate_brick.png"},
		groups = {cracky=2},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

	stairsplus:register_all("darkage", "ors_brick", "darkage:ors_brick", {
		description = S("Old Red Sandstone Brick"),
		tiles = {"darkage_ors_brick.png"},
		groups = {crumbly=2,cracky=2},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

stairsplus:register_all("darkage", "ors_cobble", "darkage:ors_cobble", {
		description = S("Old Red Sandstone Cobble"),
		tiles = {"darkage_ors_cobble.png"},
		groups = {crumbly=2,cracky=2},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

	stairsplus:register_all("darkage", "gneiss_cobble", "darkage:gneiss_cobble", {
		description = S("Gneiss Cobble"),
		tiles = {"darkage_gneiss_cobble.png"},
		groups = {cracky=3},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})
	
	stairsplus:register_all("darkage", "gneiss_brick", "darkage:gneiss_brick", {
		description = S("Gneiss Brick"),
		tiles = {"darkage_gneiss_brick.png"},
		groups = {cracky=3},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

	stairsplus:register_all("darkage", "basalt_cobble", "darkage:basalt_cobble", {
		description = S("Basalt Cobble"),
		tiles = {"darkage_basalt_cobble.png"},
		groups = {cracky=3},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})
	
	stairsplus:register_all("darkage", "basalt_brick", "darkage:basalt_brick", {
			description = S("Basalt Brick"),
			tiles = {"darkage_basalt_brick.png"},
			groups = {cracky=3},
			sounds = default.node_sound_stone_defaults(),
			sunlight_propagates = true,
	})

--[[
	stairsplus:register_all("darkage", "straw", "darkage:straw", {
		description = S("Straw"),
		tiles = {"darkage_straw.png"},
		groups = {snappy=3, flammable=2},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

	stairsplus:register_all("darkage", "straw_bale", "darkage:straw_bale", {
		description = S("Straw Bale"),
		tiles = {"darkage_straw_bale.png"},
		groups = {snappy=2, flammable=2},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})
]]

	stairsplus:register_all("darkage", "slate_tile", "darkage:slate_tile", {
		description = S("Slate Tile"),
		tiles = {"darkage_slate_tile.png"},
		groups = {cracky=2},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

	stairsplus:register_all("darkage", "marble_tile", "darkage:marble_tile", {
		description = S("Marble Tile"),
		tiles = {"darkage_marble_tile.png"},
		groups = {cracky=2},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

	stairsplus:register_all("darkage", "stone_brick", "darkage:stone_brick", {
		description = S("Stone Brick"),
		tiles = {"darkage_stone_brick.png"},
		groups = {cracky=3},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

	stairsplus:register_all("darkage", "reinforced_chalk", "darkage:reinforced_chalk", {
		description = S("Reinforced Chalk"),
		tiles = {"darkage_chalk.png^darkage_reinforce.png"},
		groups = {cracky=3},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

	stairsplus:register_all("darkage", "glass", "darkage:glass", {
		description = S("Medieval Glass"),
		tiles = {"darkage_glass.png"},
		use_texture_alpha = "clip",
		groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

	stairsplus:register_all("darkage", "glow_glass", "darkage:glow_glass", {
		description = S("Medieval Glow Glass"),
		tiles = {"darkage_glass.png"},
		use_texture_alpha = "clip",
		paramtype = "light",
		light_source = 14,
		groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

	stairsplus:register_all("darkage", "reinforced_wood", "darkage:reinforced_wood", {
		description = S("Reinforced Wood"),
		tiles = {"default_wood.png^darkage_reinforce.png"},
		groups = {snappy=2,choppy=3,oddly_breakable_by_hand=3,flammable=3},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

elseif minetest.get_modpath("stairs") then

	stairs.register_stair_and_slab("basalt", "darkage:basalt",
		{cracky=3},
		{"darkage_basalt.png"},
		S("Basalt Stair"),
		S("Basalt Slab"),
		default.node_sound_stone_defaults()
	)

	stairs.register_stair_and_slab("marble", "darkage:marble",
		{cracky=3},
		{"darkage_marble.png"},
		S("Marble Stair"),
		S("Marble Slab"),
		default.node_sound_stone_defaults()
	)

	stairs.register_stair_and_slab("marble", "darkage:serpentine",
		{cracky=3},
		{"darkage_serpentine.png"},
		S("Serpentine Stair"),
		S("Serpentine Slab"),
		default.node_sound_stone_defaults()
	)

	stairs.register_stair_and_slab("ors", "darkage:ors",
		{crumbly=2,cracky=2},
		{"darkage_ors.png"},
		S("Old Red Sandstone Stair"),
		S("Old Red Sandstone Slab"),
		default.node_sound_stone_defaults()
	)

	stairs.register_stair_and_slab("schist", "darkage:schist",
		{cracky=3},
		{"darkage_schist.png"},
		S("Schist Stair"),
		S("Schist Slab"),
		default.node_sound_stone_defaults()
	)

	stairs.register_stair_and_slab("slate", "darkage:slate",
		{cracky=2},
		{"darkage_slate.png"},
		S("Slate Stair"),
		S("Slate Slab"),
		default.node_sound_stone_defaults()
	)

	stairs.register_stair_and_slab("gneiss", "darkage:gneiss",
		{cracky=3},
		{"darkage_gneiss.png"},
		S("Gneiss Stair"),
		S("Gneiss Slab"),
		default.node_sound_stone_defaults()
	)

	stairs.register_stair_and_slab("chalk", "darkage:chalk",
		{crumbly=2,cracky=2},
		{"darkage_chalk.png"},
		S("Chalk Stair"),
		S("Chalk Slab"),
		default.node_sound_stone_defaults()
	)

	stairs.register_stair_and_slab("slate_cobble", "darkage:slate_cobble",
		{cracky=2},
		{"darkage_slate_cobble.png"},
		S("Slate Cobble Stair"),
		S("Slate Cobble Slab"),
		default.node_sound_stone_defaults()
	)
	
	stairs.register_stair_and_slab("slate_brick", "darkage:slate_brick",
		{cracky=2},
		{"darkage_slate_brick.png"},
		S("Slate Brick Stair"),
		S("Slate Brick Slab"),
		default.node_sound_stone_defaults()
	)

	stairs.register_stair_and_slab("ors_cobble", "darkage:ors_cobble",
		{crumbly=2,cracky=2},
		{"darkage_ors_cobble.png"},
		S("Old Red Sandstone Cobble Stair"),
		S("Old Red Sandstone Cobble Slab"),
		default.node_sound_stone_defaults()
	)

	stairs.register_stair_and_slab("ors_brick", "darkage:ors_brick",
		{crumbly=2,cracky=2},
		{"darkage_ors_brick.png"},
		S("Old Red Sandstone Brick Stair"),
		S("Old Red Sandstone Brick Slab"),
		default.node_sound_stone_defaults()
	)
	
	stairs.register_stair_and_slab("gneiss_cobble", "darkage:gneiss_cobble",
		{crumbly=2,cracky=2},
		{"darkage_gneiss_cobble.png"},
		S("Gneiss Cobble Stair"),
		S("Gneiss Cobble Slab"),
		default.node_sound_stone_defaults()
	)
	
	stairs.register_stair_and_slab("gneiss_brick", "darkage:gneiss_brick",
		{crumbly=2,cracky=2},
		{"darkage_gneiss_brick.png"},
		S("Gneiss Brick Stair"),
		S("Gneiss Brick Slab"),
		default.node_sound_stone_defaults()
	)

	stairs.register_stair_and_slab("basalt_cobble", "darkage:basalt_cobble",
		{cracky=3},
		{"darkage_basalt_cobble.png"},
		S("Basalt Cobble Stair"),
		S("Basalt Cobble Slab"),
		default.node_sound_stone_defaults()
	)
	
	stairs.register_stair_and_slab("basalt_brick", "darkage:basalt_brick",
		{cracky=3},
		{"darkage_basalt_brick.png"},
		S("Basalt Brick Stair"),
		S("Basalt Brick Slab"),
		default.node_sound_stone_defaults()
	)

	--[[
	stairs.register_stair_and_slab("straw", "darkage:straw",
		{snappy=3, flammable=2},
		{"darkage_straw.png"},
		S("Straw Stair"),
		S("Straw Slab"),
		default.node_sound_stone_defaults()
	)

	stairs.register_stair_and_slab("straw_bale", "darkage:straw_bale",
		{snappy=2, flammable=2},
		{"darkage_straw_bale.png"},
		S("Straw Bale Stair"),
		S("Straw Bale Slab"),
		default.node_sound_stone_defaults()
	)
	]]

	stairs.register_stair_and_slab("slate_tile", "darkage:slate_tile",
		{cracky=2},
		{"darkage_slate_tile.png"},
		S("Slate Tile Stair"),
		S("Slate Tile Slab"),
		default.node_sound_stone_defaults()
	)

	stairs.register_stair_and_slab("marble_tile", "darkage:marble_tile",
		{cracky=2},
		{"darkage_marble_tile.png"},
		S("Marble Tile Stair"),
		S("Marble Tile Slab"),
		default.node_sound_stone_defaults()
	)

	stairs.register_stair_and_slab("stone_brick", "darkage:stone_brick",
		{cracky=3},
		{"darkage_stone_brick.png"},
		S("Stone Brick Stair"),
		S("Stone Brick Slab"),
		default.node_sound_stone_defaults()
	)

	stairs.register_stair_and_slab("reinforced_chalk", "darkage:reinforced_chalk",
		{cracky=3},
		{"darkage_chalk.png^darkage_reinforce.png"},
		S("Reinforced Chalk Stair"),
		S("Reinforced Chalk Slab"),
		default.node_sound_stone_defaults()
	)

	stairs.register_stair_and_slab("glass", "darkage:glass",
		{snappy=2,cracky=3,oddly_breakable_by_hand=3},
		{"darkage_glass.png"},
		S("Medieval Glass Stair"),
		S("Medieval Glass Slab"),
		default.node_sound_stone_defaults()
	)

	stairs.register_stair_and_slab("glow_glass", "darkage:glow_glass",
		{snappy=2,cracky=3,oddly_breakable_by_hand=3},
		{"darkage_glass.png"},
		S("Medieval Glow Glass Stair"),
		S("Medieval Glow Glass Slab"),
		default.node_sound_stone_defaults()
	)

	stairs.register_stair_and_slab("reinforced_wood", "darkage:reinforced_wood",
		{snappy=2,choppy=3,oddly_breakable_by_hand=3,flammable=3},
		{"default_wood.png^darkage_reinforce.png"},
		S("Reinforced Wood Stair"),
		S("Reinforced Wood Slab"),
		default.node_sound_stone_defaults()
	)
end
