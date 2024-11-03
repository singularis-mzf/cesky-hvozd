--[[ -- nahrazeno za ch_extras:marble
minetest.register_node("artdeco:1e", {
	description = "venkovní mramor",
	tiles = {"artdeco_1c.png"},
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})
]]

minetest.register_node("artdeco:1a", {
	description = "venkovní mramor s obkladem nahoře",
	tiles = {"artdeco_1a.png", "artdeco_1c.png", "artdeco_1b.png"},
	paramtype = "light",
 	paramtype2 = "facedir",
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:1b", {
	description = "venkovní mramor s obkladem nahoře a na jedné hraně",
	tiles = {"artdeco_1a.png", "artdeco_1c.png",
	"artdeco_1b.png", "artdeco_1d.png^[transformFX.png",
	"artdeco_1b.png", "artdeco_1d.png"},
	paramtype2 = "facedir",
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:1c", {
	description = "venkovní mramor s obkladem nahoře a na dvou hranách",
 	tiles = {"artdeco_1a.png", "artdeco_1c.png",
 "artdeco_1d.png", "artdeco_1d.png^[transformFX",
		"artdeco_1b.png", "artdeco_1e.png"},
	paramtype2 = "facedir",
	groups ={cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:1d", {
	description = "sloup z venkovního mramoru (hlavice)",
	tiles = {"artdeco_1a.png", "artdeco_1c.png", "artdeco_1e.png"},
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:1f", {
	description = "venkovní mramor s obkladem na jedné hraně",
	tiles = {"artdeco_1c.png", "artdeco_1c.png",
	"artdeco_1c.png", "artdeco_1f.png",
	"artdeco_1c.png", "artdeco_1f.png^[transformFX.png"},
	paramtype2 = "facedir",
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:1g", {
	description = "venkovní mramor s obkladem na dvou hranách",
	tiles = {"artdeco_1c.png", "artdeco_1c.png",
		"artdeco_1f.png^[transformFX.png", "artdeco_1f.png",
		"artdeco_1c.png", "artdeco_1g.png"},
	paramtype2 = "facedir",
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:1h", {
	description = "sloup z venkovního mramoru (dřík)",
	tiles = {"artdeco_1c.png", "artdeco_1c.png", "artdeco_1g.png"},
	paramtype2 = "facedir",
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:1i", {
	description = "venkovní mramor s obkladem dole",
	tiles = {"artdeco_1c.png", "artdeco_1a.png", "artdeco_1j.png"},
 	paramtype2 = "facedir",
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:1j", {
	description = "venkovní mramor s obkladem dole a na jedné hraně",
	tiles = {"artdeco_1c.png", "artdeco_1a.png",
	"artdeco_1j.png", "artdeco_1h.png^[transformFX.png",
	"artdeco_1j.png", "artdeco_1h.png"},
	paramtype2 = "facedir",
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:1k", {
	description = "venkovní mramor s obkladem dole a na dvou hranách",
	tiles = {"artdeco_1c.png", "artdeco_1a.png",
		"artdeco_1h.png","artdeco_1h.png^[transformFX",
		"artdeco_1j.png", "artdeco_1i.png"},
	paramtype2 = "facedir",
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:1l", {
	description = "sloup z venkovního mramoru (podstavec)",
	tiles = {"artdeco_1c.png", "artdeco_1a.png", "artdeco_1i.png"},
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:2d", {
	description = "vápenec",
	tiles = {"artdeco_2a.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:2a", {
	description = "vápencový blok se světlým obkladem",
	tiles = {"artdeco_2a.png", "artdeco_2a.png", "artdeco_2b.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:2b", {
	description = "vápencový blok se středním obkladem",
	tiles = {"artdeco_2a.png", "artdeco_2a.png", "artdeco_2c.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:2c", {
	description = "vápencový blok s tmavým obkladem",
	tiles = {"artdeco_2a.png", "artdeco_2a.png", "artdeco_2d.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

--[[ -- nahrazeno za darkage:marble
minetest.register_node("artdeco:italianmarble", {
	description = "italský mramor",
	tiles = {"artdeco_italianmarble.png"},
	groups = {cracky=3, marble=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})
]]

minetest.register_node("artdeco:tile1", {
	description = "dlažba s diamantovým ornamentem",
	tiles = {"artdeco_tile_1.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:tile2", {
	description = "mozaika s diamantovým ornamentem",
	tiles = {"artdeco_tile_2.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:tile3", {
	description = "mozaiková dlažba 1",
	tiles = {"artdeco_tile_3.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:tile4", {
	description = "mozaiková dlažba 2",
	tiles = {"artdeco_tile_4.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:tile5", {
	description = "mozaiková dlažba 3",
	tiles = {"artdeco_tile_5.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:decoblock1", {
	description = "vápencový blok s cihlovým motivem", -- ???
	tiles = {"artdeco_decoblock_1.png", "artdeco_decoblock_1.png", "artdeco_decoblock_7.png"},
	paramtype2 = "wallmounted",
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:decoblock2", {
	description = "vápencový překlad s motivem vázy",
	paramtype2 = "wallmounted",
	tiles = {"artdeco_2a.png", "artdeco_2a.png", "artdeco_decoblock_2.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:decoblock3", {
	description = "vápencový překlad",
	paramtype2 = "wallmounted", -- TODO: colorwallmounted
	tiles = {"artdeco_decoblock_1.png", "artdeco_decoblock_1.png", "artdeco_decoblock_3.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:decoblock4", {
	description = "vápencový sloup (hlavice)",
	tiles = {"artdeco_decoblock_1.png", "artdeco_decoblock_1.png", "artdeco_decoblock_4.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:decoblock5", {
	description = "vápencový sloup (dřík)",
	tiles = {"artdeco_decoblock_1.png", "artdeco_decoblock_1.png", "artdeco_decoblock_5.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:decoblock6", {
	description = "vápencový sloup (dřík s motivem vázy)",
	tiles = {"artdeco_decoblock_1.png", "artdeco_decoblock_1.png", "artdeco_decoblock_6.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:whitegardenstone", {
	description = "kamenná stezka z bílých oblázků",
	tiles = {"artdeco_whitegardenstone.png"},
	groups = {crumbly=2, falling_node=1},
	is_ground_content = false,
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=05},
		dug = {name="default+gravel_footstep", gain=1.0},
	}),
})

--[[
minetest.register_node("artdeco:stonewall", {
	description = "kamenná zídka",
	tiles = {"artdeco_stonewall.png"},
	groups = {cracky=3, stone=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})
]]

minetest.register_node("artdeco:brownwalltile", {
	description = "obklad z hnědých kachliček",
	tiles = {"artdeco_tile_brown.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:greenwalltile", {
	description = "obklad ze zelenavých kachliček",
	tiles = {"artdeco_tile_green.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:ceilingtile", {
	description = "vyřezávaný mramor",
	tiles = {"artdeco_tile_ceiling.png"},
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("artdeco:lionheart", {
	description = "mramorový blok s motivem lva",
	tiles = {"artdeco_lionheart.png", "artdeco_lionheart.png",
	"artdeco_lionheart.png", "artdeco_lionheart.png",
	"artdeco_lionheart.png", "artdeco_lionheart_front.png"},
	paramtype2 = "facedir",
	groups = {cracky=3},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})
