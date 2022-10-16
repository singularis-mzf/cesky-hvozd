--Variables
jonez = {}
local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)
local S = minetest.get_translator(mod_name)
assert(loadfile(mod_path .. "/chisel.lua"))(S)

local function firstToUpper(str)
	return (str:gsub("^%l", string.upper))
end

jonez.chisel.register_chiselable("jonez:marble", "jonez:marble", "raw" )
minetest.register_node("jonez:marble", {
	description = S("Ancient Marble"),
	tiles = {"jonez_marble.png"},
	is_ground_content = true,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

jonez.chisel.register_chiselable("jonez:marble_polished", "jonez:marble", "polished" )
minetest.register_node("jonez:marble_polished", {
	description = S("Ancient Polished Marble"),
	tiles = {"jonez_marble_polished.png"},
	is_ground_content = true,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

jonez.chisel.register_chiselable_stair_and_slab("marble", "marble", "raw" )
stairs.register_stair_and_slab(
	"marble",
	"jonez:marble",
	{cracky = 2, stone = 1},
	{"jonez_marble.png"},
	S("Ancient Marble Stair"),
	S("Ancient Marble Slab"),
	default.node_sound_stone_defaults()
)

jonez.chisel.register_chiselable("jonez:marble_brick", "jonez:marble_brick", "raw" )
minetest.register_node("jonez:marble_brick", {
	description = S("Ancient Marble Brick"),
	tiles = {"jonez_marble_brick.png"},
	is_ground_content = false,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

jonez.chisel.register_chiselable_stair_and_slab("marble_brick", "marble_brick", "raw" )
stairs.register_stair_and_slab(
	"marble_brick",
	"jonez:marble_brick",
	{cracky = 2, stone = 1},
	{"jonez_marble_brick.png"},
	S("Ancient Marble Brick Stair"),
	S("Ancient Marble Brick Slab"),
	default.node_sound_stone_defaults()
)

jonez.chisel.register_chiselable("jonez:marble_brick_polished", "jonez:marble_brick", "polished" )
minetest.register_node("jonez:marble_brick_polished", {
	description = S("Ancient Marble Polished Brick"),
	tiles = {"jonez_marble_brick_polished.png"},
	is_ground_content = false,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

jonez.chisel.register_chiselable_stair_and_slab("marble_polished", "marble", "polished" )
stairs.register_stair_and_slab(
	"marble_polished",
	"jonez:marble_polished",
	{cracky = 2, stone = 1},
	{"jonez_marble_polished.png"},
	S("Ancient Polished Marble Stair"),
	S("Ancient Polished Marble Slab"),
	default.node_sound_stone_defaults()
)

jonez.chisel.register_chiselable_stair_and_slab("marble_brick_polished", "marble_brick", "polished" )
stairs.register_stair_and_slab(
	"marble_brick_polished",
	"jonez:marble_brick_polished",
	{cracky = 2, stone = 1},
	{"jonez_marble_brick_polished.png"},
	S("Ancient Polished Marble Brick Stair"),
	S("Ancient Polished Marble Brick Slab"),
	default.node_sound_stone_defaults()
)

minetest.register_craft({
	output = 'jonez:marble_brick',
	recipe = {
		{'jonez:marble', 'jonez:marble'},
		{'jonez:marble', 'jonez:marble'},
	}
})

minetest.register_craft({
	output = 'jonez:marble_brick_polished',
	recipe = {
		{'jonez:marble_polished', 'jonez:marble_polished'},
		{'jonez:marble_polished', 'jonez:marble_polished'},
	}
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "jonez:marble",
	wherein = "default:stone",
	clust_scarcity = 7*7*7,
	clust_num_ores = 5,
	clust_size = 3,
	height_min = -512,
	height_max = -65,
	flags = "absheight",
})

local styles = {
	"roman",
	"greek",
	"germanic",
	"tuscan",
	"romanic",
	"nabataean",
	"artdeco",
	"minoan",
	"attic",
	"versailles",
	"medieval",
	"gothic",
	"pompeiian",
	"corinthian",
	"carthaginian",
	"industrial",
	"romanesque",
	"cimmerian",
	"nubian",
	"norman",
	"romantic"
}

-- The Crafting of the Greek Set

minetest.register_craft({
	output = 'jonez:greek_shaft 3',
	type = "shaped",
	recipe = {
		{'', 'jonez:marble_polished', ''},
		{'', 'jonez:marble_polished', ''},
		{'', 'jonez:marble_polished', ''},
	},
})

minetest.register_craft({
	output = 'jonez:greek_architrave 3',
	type = "shaped",
	recipe = {
		{'', '', ''},
		{'', '', ''},
		{'stairs:slab_marble_polished', 'stairs:slab_marble_polished', 'stairs:slab_marble_polished'},
	},
})

minetest.register_craft({
	output = 'jonez:greek_base 2',
	type = "shaped",
	recipe = {
		{'', '', ''},
		{'', 'jonez:marble_polished', ''},
		{'', 'stairs:slab_marble_polished', ''},
	},
})

minetest.register_craft({
	output = 'jonez:greek_capital 2',
	type = "shaped",
	recipe = {
		{'', '', ''},
		{'', 'stairs:slab_marble_polished', ''},
		{'', 'jonez:marble_polished', ''},
	},
})

for i = 1, #styles do

	jonez.chisel.register_chiselable("jonez:"..styles[i].."_architrave", "jonez:architrave", styles[i] )
	minetest.register_node("jonez:"..styles[i].."_architrave", {
		description = S("Ancient").." "..S(firstToUpper(styles[i])).." "..S("Architrave"),
		tiles = {"jonez_"..styles[i].."_top_bottom.png", "jonez_"..styles[i].."_top_bottom.png", "jonez_"..
			styles[i].."_architrave.png"},
		is_ground_content = false,
		groups = {cracky=3},
		paramtype2 = "facedir",
		sounds = default.node_sound_stone_defaults(),
	})

	jonez.chisel.register_chiselable("jonez:"..styles[i].."_capital", "jonez:capital", styles[i] )
	minetest.register_node("jonez:"..styles[i].."_capital", {
		description = S("Ancient").." "..S(firstToUpper(styles[i])).." "..S("Capital"),
		tiles = {"jonez_"..styles[i].."_top_bottom.png", "jonez_"..styles[i].."_top_bottom.png", "jonez_"..styles[i]..
			"_capital.png"},
		is_ground_content = false,
		groups = {cracky=3},
		paramtype2 = "facedir",
		sounds = default.node_sound_stone_defaults(),
	})

	jonez.chisel.register_chiselable("jonez:"..styles[i].."_shaft", "jonez:shaft", styles[i] )
	minetest.register_node("jonez:"..styles[i].."_shaft", {
		description = S("Ancient").." "..S(firstToUpper(styles[i])).." "..S("Shaft"),
		tiles = {"jonez_"..styles[i].."_top_bottom.png", "jonez_"..styles[i].."_top_bottom.png", "jonez_"..styles[i]..
			"_shaft.png"},
		is_ground_content = false,
		groups = {cracky=3},
		paramtype2 = "facedir",
		sounds = default.node_sound_stone_defaults(),
	})

	jonez.chisel.register_chiselable("jonez:"..styles[i].."_base", "jonez:base", styles[i] )
	minetest.register_node("jonez:"..styles[i].."_base", {
		description = S("Ancient").." "..S(firstToUpper(styles[i])).." "..S("Base"),
		tiles = {"jonez_"..styles[i].."_top_bottom.png", "jonez_"..styles[i].."_top_bottom.png", "jonez_"..styles[i]..
			"_base.png"},
		is_ground_content = false,
		groups = {cracky=3},
		paramtype2 = "facedir",
		sounds = default.node_sound_stone_defaults(),
	})
end

local vines = {
	{name= "jonez:swedish_ivy", description= "Swedish Ivy", texture= "jonez_sweedish_ivy.png"},
	{name= "jonez:ruin_creeper", description= "Ruin Creeper", texture= "jonez_ruin_creeper.png"},
	{name= "jonez:ruin_vine", description= "Ruin Vine", texture= "jonez_ruin_vine.png"},
	{name= "jonez:climbing_rose", description= "Climbing Rose", texture= "jonez_climbing_rose.png"},
}

for i = 1, #vines do
	minetest.register_node(vines[i].name, {
		description = S(vines[i].description),
		drawtype = "nodebox",
		walkable = true,
		paramtype = "light",
		paramtype2 = "facedir",
		tiles = {vines[i].texture},
		use_texture_alpha = true,
		inventory_image = vines[i].texture,
		wield_image = vines[i].texture,
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, 0.49, 0.5, 0.5, 0.5}
		},
		groups = {
			snappy = 2, flammable = 3, oddly_breakable_by_hand = 3, choppy = 2, carpet = 1, leafdecay = 3, leaves = 1
		},
		sounds = default.node_sound_leaves_defaults(),
	})
end

local panels = {
	{name= "jonez_panel_1", description= "Mosaic Glass Panel", textures={front= "jonez_panel_1.png",
		edge="jonez_panes_edge.png"},
		recipe = {
			{"dye:blue", "dye:black", "dye:pink"},
			{"dye:red", "xpanes:pane_flat", "dye:green"},
			{"dye:yellow", "dye:black", "dye:orange"},
		}
	},
	{name= "jonez_panel_2", description= "Blossom Glass Panel", textures={front="jonez_panel_2.png",
		edge="jonez_panes_edge.png"},
		recipe = {
			{"dye:blue", "dye:red", "dye:green"},
			{"dye:yellow", "xpanes:pane_flat", "dye:yellow"},
			{"dye:green", "dye:red", "dye:orange"},
		}
	},
	{name= "wrought_lattice_bottom", description= "Ancient Wrought Lattice (Bottom)",
		textures={front="jonez_wrought_lattice_bottom.png", edge="jonez_panes_edge.png"},
		use_texture_alpha = true,
		recipe = {
			{'', '', ''},
			{'default:steel_ingot', 'default:tin_ingot', 'default:steel_ingot'},
			{'default:steel_ingot', 'default:tin_ingot', 'default:steel_ingot'},
		}
	},
	{name= "palace_window_top", description= "Palace Window (Top)",
		textures={front="jonez_palace_window_top.png", edge="default_wood.png"},
		use_texture_alpha = true,
		recipe = {
			{'', 'xpanes:pane_flat', ''},
			{'', 'xpanes:pane_flat', ''},
			{'', '', ''},
		}
	},
	{name= "palace_window_bottom", description= "Palace Window (Bottom)",
		textures={front="jonez_palace_window_bottom.png", edge="default_wood.png"},
		use_texture_alpha = true,
		recipe = {
			{'', '', ''},
			{'', 'xpanes:pane_flat', ''},
			{'', 'xpanes:pane_flat', ''},
		}
	},
}

for j=1, #panels do
	xpanes.register_pane(panels[j].name, {
		description = S(panels[j].description),
		textures = {panels[j].textures.front, nil, panels[j].textures.edge},
		use_texture_alpha = panels[j].use_texture_alpha,
		inventory_image = panels[j].textures.front,
		wield_image = panels[j].textures.front,
		sounds = default.node_sound_glass_defaults(),
		groups = {snappy=2, cracky=3, oddly_breakable_by_hand=3},
		recipe = panels[j].recipe
	})
end

local pavements= {
	{name= "jonez:blossom_pavement", description= "Ancient Blossom Pavement", texture= "jonez_blossom_pavement.png",
		recipe = {
			{'', 'stairs:slab_marble', ''},
			{'stairs:slab_marble', 'stairs:slab_marble', 'stairs:slab_marble'},
			{'', 'stairs:slab_marble', ''},
		}
	},
	{name= "jonez:tiled_pavement", description= "Ancient Tiled Pavement", texture= "jonez_tiled_pavement.png",
		recipe = {
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick', ''},
			{'', 'stairs:slab_marble_brick', 'stairs:slab_marble_brick'},
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick', ''},
		}
	},
	{name= "jonez:mosaic_pavement", description= "Ancient Mosaic Pavement", texture= "jonez_mosaic_pavement.png",
		recipe = {
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick', 'stairs:slab_marble_brick'},
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick', 'stairs:slab_marble_brick'},
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick', 'stairs:slab_marble_brick'},
		}
	},
	{name= "jonez:diamond_pavement", description= "Ancient Diamond Pavement", texture= "jonez_diamond_pavement.png",
		recipe = {
			{'', 'stairs:slab_marble', ''},
			{'stairs:slab_marble', '', 'stairs:slab_marble'},
			{'', 'stairs:slab_marble', ''},
		}
	},
	{name= "jonez:pebbled_pavement", description= "Ancient Pebbled Pavement", texture= "jonez_pebbled_pavement.png",
		recipe = {
			{'', 'stairs:slab_marble_brick_polished', ''},
			{'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick_polished',
			'stairs:slab_marble_brick_polished'},
			{'', 'stairs:slab_marble_brick_polished', ''},
		}
	},
	{name= "jonez:pebbled_medieval_pavement", description= "Ancient Pebbled Medieval Pavement",
		texture= "jonez_pebbled_medieval_pavement.png",
		recipe = {
			{'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick_polished', ''},
			{'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick_polished',
				'stairs:slab_marble_brick_polished'},
			{'', 'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick_polished'},
		}
	},
	{name= "jonez:pebbled_gothic_pavement", description= "Ancient Pebbled Gothic Pavement",
		texture= "jonez_pebbled_gothic_pavement.png",
		recipe = {
			{'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick_polished', ''},
			{'', 'stairs:slab_marble_brick_polished', ''},
			{'', 'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick_polished'},
		}
	},
	{name= "jonez:pebbled_wall", description= "Ancient Pebbled Wall", texture= "jonez_pebbled_wall.png",
		recipe = {
			{'', 'stairs:slab_marble_brick_polished', ''},
			{'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick_polished',
				'stairs:slab_marble_brick_polished'},
			{'', 'stairs:slab_marble_brick_polished', ''},
		}
	},
	{name= "jonez:gothic_wall", description= "Ancient Gothic Wall", texture= "jonez_gothic_top_bottom.png",
		recipe = {
			{'', 'stairs:slab_marble_brick', ''},
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick', 'stairs:slab_marble_brick'},
			{'', 'stairs:slab_marble_brick', ''},
		}
	},
	{name= "jonez:pompeiian_wall", description= "Ancient Pompeiian Wall", texture= "jonez_pompeiian_wall.png",
		recipe = {
			{'', 'stairs:slab_marble_brick_polished', ''},
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick'},
			{'', 'stairs:slab_marble_brick_polished', ''},
		}
	},
	{name= "jonez:pompeiian_pavement", description= "Ancient Pompeiian Pavement",
		texture= "jonez_pompeiian_pavement.png",
		recipe = {
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick'},
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick'},
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick'},
		}
	},
	{name= "jonez:pompeiian_path", description= "Ancient Pompeiian Path", texture= "jonez_pompeiian_path.png",
		amount = 4,
		recipe = {
			{'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick', 'stairs:slab_marble_brick_polished'},
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick', 'stairs:slab_marble_brick'},
			{'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick', 'stairs:slab_marble_brick_polished'},
		}
	},
	{name= "jonez:carthaginian_pavement", description= "Carthaginian Pavement",
		texture= "jonez_carthaginian_pavement.png", amount = 4,
		recipe = {
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick'},
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick', 'stairs:slab_marble_brick'},
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick'},
		}
	},
	{name= "jonez:carthaginian_wall", description= "Carthaginian Wall", texture= "jonez_carthaginian_wall.png",
		amount = 4,
		recipe = {
			{'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick', 'stairs:slab_marble_brick_polished'},
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick'},
			{'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick', 'stairs:slab_marble_brick_polished'},
		}
	},
	{name= "jonez:nubian_wall", description= "Nubian Wall", texture= "jonez_nubian_wall.png", amount = 9,
		recipe = {
			{'default:sandstonebrick', 'default:sandstonebrick', 'default:sandstonebrick'},
			{'default:sandstonebrick', 'default:sandstonebrick', 'default:sandstonebrick'},
			{'default:sandstonebrick', 'default:sandstonebrick', 'default:sandstonebrick'},
		}
	},
}

for i = 1, #pavements do
	minetest.register_node(pavements[i].name, {
		description = S(pavements[i].description),
		tiles = {pavements[i].texture},
		is_ground_content = true,
		groups = {cracky=3},
		sounds = default.node_sound_stone_defaults(),
	})
	local amount
	if pavements[i].amount then
		amount = tostring(pavements[i].amount)
	else
		amount = "1"
	end
	minetest.register_craft({
		output = pavements[i].name .. " " .. amount,
		type = 'shaped',
		recipe = pavements[i].recipe,
	})
end

minetest.register_node("jonez:wrought_lattice_top", {
	description = S("Ancient Wrought Lattice (Top)"),
	is_ground_content = true,
	groups = {cracky=3},
	walkable = true,
	sounds = default.node_sound_stone_defaults(),
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.0, 0.5, 0.1875, 0.0},
		}
	},
	tiles = {
		nil,
		nil,
		nil,
		nil,
		"jonez_wrought_lattice_top.png",
		"jonez_wrought_lattice_top.png"
	},
	use_texture_alpha = true,
})

minetest.register_craft({
	output = 'jonez:wrought_lattice_top',
	recipe = {
		{'default:steel_ingot', 'default:tin_ingot', 'default:steel_ingot'},
		{'default:steel_ingot', 'default:tin_ingot', 'default:steel_ingot'},
		{'', '', ''},
	}
})

minetest.register_node("jonez:versailles_pavement", {
	description = S("Versailles Pavement"),
	tiles = {"jonez_versailles_pavement.png"},
	is_ground_content = false,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = 'jonez:versailles_pavement',
	type = "shaped",
	recipe = {
		{'', '', ''},
		{'', 'stairs:slab_marble_brick', ''},
		{'stairs:slab_marble_brick', '', 'stairs:slab_marble_brick'},
	},
})

minetest.register_node("jonez:versailles_tile", {
	description = S("Versailles Tile"),
	tiles = {"jonez_versailles_tile.png"},
	is_ground_content = false,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = 'jonez:versailles_tile 9',
	type = "shapeless",
	recipe = {
		'jonez:diamond_pavement', 'stairs:slab_marble_brick', 'jonez:diamond_pavement',
		'stairs:slab_marble_brick', 'jonez:diamond_pavement', 'stairs:slab_marble_brick',
		'jonez:diamond_pavement', 'stairs:slab_marble_brick', 'jonez:diamond_pavement',
	},
})

minetest.register_node("jonez:pompeiian_altar", {
	description = S("Ancient Pompeiian Altar"),
	tiles = {"jonez_pompeiian_top_bottom.png", "jonez_pompeiian_top_bottom.png", "jonez_pompeiian_altar.png"},
	is_ground_content = false,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = 'jonez:pompeiian_altar',
	type = "shaped",
	recipe = {
		{'', '', ''},
		{'', 'stairs:slab_marble_brick_polished', ''},
		{'', 'jonez:marble_polished', ''},
	},
})

minetest.register_node("jonez:censer", {
	description = S("Censer"),
    tiles = {"jonez_censer_top.png", "jonez_censer_top.png", "jonez_censer_front.png"},
    drawtype = "nodebox",
    paramtype = "light",
    node_box = {
        type = "fixed",
        fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.375, 0.5}, -- NodeBox1
			{-0.4375, -0.375, -0.4375, 0.4375, -0.3125, 0.4375}, -- NodeBox2
			{-0.375, -0.3125, -0.375, 0.375, -0.25, 0.375}, -- NodeBox3
			{-0.3125, -0.3125, -0.3125, 0.3125, 0.25, 0.3125}, -- NodeBox4
			{-0.375, 0.25, -0.375, 0.375, 0.3125, 0.375}, -- NodeBox5
			{-0.4375, 0.3125, -0.4375, 0.4375, 0.375, -0.375}, -- NodeBox6
			{-0.5, 0.375, -0.5, 0.5, 0.5, -0.4375}, -- NodeBox7
			{-0.4375, 0.3125, 0.375, 0.4375, 0.375, 0.4375}, -- NodeBox8
			{-0.5, 0.375, 0.4375, 0.5, 0.5, 0.5}, -- NodeBox9
			{0.375, 0.3125, -0.4375, 0.4375, 0.375, 0.4375}, -- NodeBox10
			{0.4375, 0.375, -0.5, 0.5, 0.5, 0.5}, -- NodeBox11
			{-0.5, 0.375, -0.5, -0.4375, 0.5, 0.5}, -- NodeBox12
			{-0.4375, 0.3125, -0.4375, -0.375, 0.375, 0.4375}, -- NodeBox13
         },
    },
    groups = {cracky=1},
})

