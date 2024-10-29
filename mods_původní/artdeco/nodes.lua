minetest.register_node("artdeco:1e", {
	description = "Marble",
	tiles = {"artdeco_1c.png"},
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:1a", {
	description = "Marble Top",
	tiles = {"artdeco_1a.png", "artdeco_1c.png", "artdeco_1b.png"},
	paramtype = "light",
 	paramtype2 = "facedir",
 	legacy_facedir_simple = true,
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:1b", {
	description = "Marble Top Corner",
	tiles = {"artdeco_1a.png", "artdeco_1c.png",
	"artdeco_1b.png", "artdeco_1d.png^[transformFX.png",
	"artdeco_1b.png", "artdeco_1d.png"},
	paramtype2 = "facedir",
	legacy_facedor_simple = true,
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:1c", {
	description = "Marble Top End",
 	tiles = {"artdeco_1a.png", "artdeco_1c.png",
 "artdeco_1d.png", "artdeco_1d.png^[transformFX",
		"artdeco_1b.png", "artdeco_1e.png"},
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	groups ={cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:1d", {
	description = "Marble Top Column",
	tiles = {"artdeco_1a.png", "artdeco_1c.png", "artdeco_1e.png"},
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:1f", {
	description = "Marble Corner",
	tiles = {"artdeco_1c.png", "artdeco_1c.png",
	"artdeco_1c.png", "artdeco_1f.png",
	"artdeco_1c.png", "artdeco_1f.png^[transformFX.png"},
	paramtype2 = "facedir",
	legacy_facedor_simple = true,
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:1g", {
	description = "Marble End",
	tiles = {"artdeco_1c.png", "artdeco_1c.png",
		"artdeco_1f.png^[transformFX.png", "artdeco_1f.png",
		"artdeco_1c.png", "artdeco_1g.png"},
	paramtype2 = "facedir",
	legacy_facedor_simple = true,
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:1h", {
	description = "Marble Column",
	tiles = {"artdeco_1c.png", "artdeco_1c.png", "artdeco_1g.png"},
	paramtype2 = "facedir",
	legacy_facedor_simple = true,
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:1i", {
	description = "Marble Bottom",
	tiles = {"artdeco_1c.png", "artdeco_1a.png", "artdeco_1j.png"},
 	paramtype2 = "facedir",
 	legacy_facedir_simple = true,
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:1j", {
	description = "Marble Bottom Corner",
	tiles = {"artdeco_1c.png", "artdeco_1a.png",
	"artdeco_1j.png", "artdeco_1h.png^[transformFX.png",
	"artdeco_1j.png", "artdeco_1h.png"},
	paramtype2 = "facedir",
	legacy_facedor_simple = true,
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:1k", {
	description = "Marble Bottom End",
	tiles = {"artdeco_1c.png", "artdeco_1a.png",
		"artdeco_1h.png","artdeco_1h.png^[transformFX",
		"artdeco_1j.png", "artdeco_1i.png"},
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:1l", {
	description = "Marble Bottom Column",
	tiles = {"artdeco_1c.png", "artdeco_1a.png", "artdeco_1i.png"},
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:2d", {
	description = "Limestone",
	tiles = {"artdeco_2a.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:2a", {
	description = "Limestone Top",
	tiles = {"artdeco_2a.png", "artdeco_2a.png", "artdeco_2b.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:2b", {
	description = "Limestone Moulding",
	tiles = {"artdeco_2a.png", "artdeco_2a.png", "artdeco_2c.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:2c", {
	description = "Limestone Bottom",
	tiles = {"artdeco_2a.png", "artdeco_2a.png", "artdeco_2d.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:italianmarble", {
	description = "Italian Marble",
	tiles = {"artdeco_italianmarble.png"},
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:tile1", {
	description = "Diamond Tile Centered",
	tiles = {"artdeco_tile_1.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:tile2", {
	description = "Diamond Tile",
	tiles = {"artdeco_tile_2.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:tile3", {
	description = "Mosaic Tile",
	tiles = {"artdeco_tile_3.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:tile4", {
	description = "Mosaic Tile Centered",
	tiles = {"artdeco_tile_4.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:tile5", {
	description = "Windmill Tile",
	tiles = {"artdeco_tile_5.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:decoblock1", {
	description = "Motif",
	tiles = {"artdeco_decoblock_1.png", "artdeco_decoblock_1.png", "artdeco_decoblock_7.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:decoblock2", {
	description = "Lintel w/ Motif",
	tiles = {"artdeco_2a.png", "artdeco_2a.png", "artdeco_decoblock_2.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:decoblock3", {
	description = "Lintel",
	tiles = {"artdeco_decoblock_1.png", "artdeco_decoblock_1.png", "artdeco_decoblock_3.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:decoblock4", {
	description = "Limestone Column Cap",
	tiles = {"artdeco_decoblock_1.png", "artdeco_decoblock_1.png", "artdeco_decoblock_4.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:decoblock5", {
	description = "Limestone Column",
	tiles = {"artdeco_decoblock_1.png", "artdeco_decoblock_1.png", "artdeco_decoblock_5.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:decoblock6", {
	description = "Limestone Column Motif",
	tiles = {"artdeco_decoblock_1.png", "artdeco_decoblock_1.png", "artdeco_decoblock_6.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:whitegardenstone", {
	description = "Garden Stone",
	tiles = {"artdeco_whitegardenstone.png"},
	groups = {crumbly=2, falling_node=1},
	is_ground_content = false,
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=05},
		dug = {name="default+gravel_footstep", gain=1.0},
	}),
})

minetest.register_node("artdeco:stonewall", {
	description = "Cobblestone Wall",
	tiles = {"artdeco_stonewall.png"},
	groups = {cracky=3, stone=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:brownwalltile", {
	description = "Brown Tile",
	tiles = {"artdeco_tile_brown.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:greenwalltile", {
	description = "Green Tile",
	tiles = {"artdeco_tile_green.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:ceilingtile", {
	description = "Chiseled Tile",
	tiles = {"artdeco_tile_ceiling.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:lionheart", {
	description = "Lionheart",
	tiles = {"artdeco_lionheart.png", "artdeco_lionheart.png",
	"artdeco_lionheart.png", "artdeco_lionheart.png",
	"artdeco_lionheart.png", "artdeco_lionheart_front.png"},
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})
