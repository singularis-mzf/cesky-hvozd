--Variables
jonez = {
	style_names = {
		raw = "surový",
		polished = "opracovaný",
	},
}
local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)
local S = minetest.get_translator(mod_name)
assert(loadfile(mod_path .. "/chisel.lua"))(S)
local def

local function firstToUpper(str)
	return (str:gsub("^%l", string.upper))
end

local function colorable_256(def)
	def.paramtype2 = "color"
	def.place_param2 = 240
	def.palette = "unifieddyes_palette_extended.png"
	def.on_construct = unifieddyes.on_construct
	def.on_dig = unifieddyes.on_dig
	if def.groups then
		def.groups.ud_param2_colorable = 1
	else
		def.groups = {ud_param2_colorable = 1}
	end
	return def
end

local function colorable_32(def)
	colorable_256(def)
	def.paramtype2 = "colorwallmounted"
	def.palette = "unifieddyes_palette_colorwallmounted.png"
	return def
end

local function combine4(tile, base_size, rotate)
	if not base_size then
		base_size = 16
	end
	local size4 = 2 * base_size
	tile = "("..tile..")"
	local result = {
		"[combine:", -- 1
		size4, -- 2
		"x", -- 3
		size4, -- 4
		":0,0=", -- 5
		tile, -- 6
		":0,", -- 7
		base_size, -- 8
		"=", -- 9
		tile, -- 10
		":", -- 11
		base_size, -- 12
		",0=", -- 13
		tile, -- 14
		":", -- 15
		base_size, -- 16
		",", -- 17
		base_size, -- 18
		"=", -- 19
		tile, -- 20
	}
	if rotate then
		result[10] = "("..tile.."^[transformR90)"
		result[14] = "("..tile.."^[transformR180)"
		result[20] = "("..tile.."^[transformR270)"
	end
	return table.concat(result)
end


jonez.chisel.register_chiselable("jonez:marble", "jonez:marble", "raw" )
minetest.register_node("jonez:marble", {
	description = S("nehodivský mramor"),
	tiles = {"jonez_marble.png"},
	is_ground_content = true,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

jonez.chisel.register_chiselable("jonez:marble_polished", "jonez:marble", "polished" )
minetest.register_node("jonez:marble_polished", {
	description = S("opracovaný nehodivský mramor"),
	tiles = {combine4("jonez_marble_polished.png", 32)},
	is_ground_content = true,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

--[[
jonez.chisel.register_chiselable_stair_and_slab("marble", "marble", "raw" )
stairs.register_stair_and_slab(
	"marble",
	"jonez:marble",
	{cracky = 2, stone = 1},
	{"jonez_marble.png"},
	S("Ancient Marble Stair"),
	S("Ancient Marble Slab"),
	default.node_sound_stone_defaults()
) ]]

jonez.chisel.register_chiselable("jonez:marble_brick", "jonez:marble_brick", "raw" )
minetest.register_node("jonez:marble_brick", colorable_32({
	description = S("cihly z nehodivského mramoru"),
	tiles = {"jonez_marble_brick.png"},
	is_ground_content = false,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
}))

--[[jonez.chisel.register_chiselable_stair_and_slab("marble_brick", "marble_brick", "raw" )
stairs.register_stair_and_slab(
	"marble_brick",
	"jonez:marble_brick",
	{cracky = 2, stone = 1},
	{"jonez_marble_brick.png"},
	S("Ancient Marble Brick Stair"),
	S("Ancient Marble Brick Slab"),
	default.node_sound_stone_defaults()
) ]]

jonez.chisel.register_chiselable("jonez:marble_brick_polished", "jonez:marble_brick", "polished" )
minetest.register_node("jonez:marble_brick_polished", colorable_32({
	description = S("cihly z opracovaného nehodivského mramoru"),
	tiles = {"jonez_marble_brick_polished.png"},
	is_ground_content = false,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
}))

--[[
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
]]

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

--[[
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
]]

local styles = {
	roman = "římsk",
	greek = "řeck",
	germanic = "germánsk",
	tuscan = "tuskánsk",
	romanic = "románsk",
	nabataean = "nabateánsk",
	artdeco = "artdekov",
	minoan = "mínojsk",
	attic = "atick",
	versailles = "versailsk",
	medieval = "středověk",
	gothic = "gotick",
	pompeiian = "pompejsk",
	corinthian = "korintsk",
	carthaginian = "kartágsk",
	industrial = "industriální",
	romanesque = "romaneskní",
	cimmerian = "kimerijsk",
	nubian = "nubijsk",
	norman = "normandsk",
	romantic = "romantick",
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

for style_id, style_name in pairs(styles) do
	local lc_32 = colorable_32
	local texture_transform = "^[transformR180"
	if style_id == "industrial" then
		lc_32 = function(def) return def end
		texture_transform = ""
	end
	local y_tvar, a_tvar
	if style_id ~= "industrial" and style_id ~= "romanesque" then
		y_tvar = style_name .. "ý"
		a_tvar = style_name .. "á"
	else
		y_tvar, a_tvar = style_name, style_name
	end
	jonez.style_names[style_id] = y_tvar

	jonez.chisel.register_chiselable("jonez:"..style_id.."_architrave", "jonez:architrave", style_id)
	minetest.register_node("jonez:"..style_id.."_architrave", lc_32({
		description = S(y_tvar.." architráv"),
		tiles = {"jonez_"..style_id.."_top_bottom.png", "jonez_"..style_id.."_top_bottom.png", "jonez_"..style_id.."_architrave.png"..texture_transform},
		is_ground_content = false,
		groups = {cracky=3},
		paramtype2 = "facedir",
		sounds = default.node_sound_stone_defaults(),
	}))

	jonez.chisel.register_chiselable("jonez:"..style_id.."_capital", "jonez:capital", style_id )
	minetest.register_node("jonez:"..style_id.."_capital", lc_32({
		description = S(a_tvar.." hlavice sloupu"),
		tiles = {"jonez_"..style_id.."_top_bottom.png", "jonez_"..style_id.."_top_bottom.png", "jonez_"..style_id.."_capital.png"..texture_transform},
		is_ground_content = false,
		groups = {cracky=3},
		paramtype2 = "facedir",
		sounds = default.node_sound_stone_defaults(),
	}))

	jonez.chisel.register_chiselable("jonez:"..style_id.."_shaft", "jonez:shaft", style_id )
	minetest.register_node("jonez:"..style_id.."_shaft", lc_32({
		description = S(y_tvar.." dřík sloupu"),
		tiles = {"jonez_"..style_id.."_top_bottom.png", "jonez_"..style_id.."_top_bottom.png", "jonez_"..style_id.."_shaft.png"..texture_transform},
		is_ground_content = false,
		groups = {cracky=3},
		paramtype2 = "facedir",
		sounds = default.node_sound_stone_defaults(),
	}))

	jonez.chisel.register_chiselable("jonez:"..style_id.."_base", "jonez:base", style_id )
	minetest.register_node("jonez:"..style_id.."_base", lc_32({
		description = S(a_tvar.." patka sloupu"),
		tiles = {"jonez_"..style_id.."_top_bottom.png", "jonez_"..style_id.."_top_bottom.png", "jonez_"..style_id.."_base.png"..texture_transform},
		is_ground_content = false,
		groups = {cracky=3},
		paramtype2 = "facedir",
		sounds = default.node_sound_stone_defaults(),
	}))
end

local vines = {
	{name= "jonez:swedish_ivy", description= "břečťan", texture= "jonez_sweedish_ivy.png"},
	{name= "jonez:ruin_creeper", description= "popínavý keř", texture= "jonez_ruin_creeper.png"},
	{name= "jonez:ruin_vine", description= "popínavá rostlina", texture= "jonez_ruin_vine.png"},
	{name= "jonez:climbing_rose", description= "popínavá růže", texture= "jonez_climbing_rose.png"},
}

for i = 1, #vines do
	minetest.register_node(vines[i].name, {
		description = S(vines[i].description),
		drawtype = "nodebox",
		walkable = true,
		paramtype = "light",
		paramtype2 = "facedir",
		tiles = {vines[i].texture},
		use_texture_alpha = "clip",
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
	{name= "jonez_panel_1", description= "barevná skleněná mozaika",
		textures={front= "("..combine4("jonez_panel_1.png", 32)..")^[opacity:220", edge="jonez_panes_edge.png"},
		use_texture_alpha = "blend",
		recipe = {
			{"dye:blue", "dye:black", "dye:pink"},
			{"dye:red", "xpanes:pane_flat", "dye:green"},
			{"dye:yellow", "dye:black", "dye:orange"},
		}
	},
	{name= "jonez_panel_2", description= "barevná skleněná mozaika (motiv květiny)",
		textures={front="("..combine4("jonez_panel_2.png", 32)..")^[opacity:220", edge="jonez_panes_edge.png"},
		use_texture_alpha = "blend",
		recipe = {
			{"dye:blue", "dye:red", "dye:green"},
			{"dye:yellow", "xpanes:pane_flat", "dye:yellow"},
			{"dye:green", "dye:red", "dye:orange"},
		}
	},
	{name= "wrought_lattice_bottom", description= "kovová mřížka (spodní díl)",
		textures={front="jonez_wrought_lattice_bottom.png", edge="ch_core_empty.png"},
		use_texture_alpha = "clip",
		recipe = {
			{'', '', ''},
			{'default:steel_ingot', 'default:tin_ingot', 'default:steel_ingot'},
			{'default:steel_ingot', 'default:tin_ingot', 'default:steel_ingot'},
		}
	},
	{name= "palace_window_top", description= "palácové okno (horní díl)",
		textures={front="jonez_palace_window_top.png", edge="ch_core_empty.png"},
		use_texture_alpha = "clip",
		recipe = {
			{'', 'xpanes:pane_flat', ''},
			{'', 'xpanes:pane_flat', ''},
			{'', '', ''},
		}
	},
	{name= "palace_window_bottom", description= "palácové okno (spodní díl)",
		textures={front="jonez_palace_window_bottom.png", edge="ch_core_empty.png"},
		use_texture_alpha = "clip",
		recipe = {
			{'', '', ''},
			{'', 'xpanes:pane_flat', ''},
			{'', 'xpanes:pane_flat', ''},
		}
	},
}

local panel_c_nodebox = {
	type = "fixed",
	fixed = {{-8/16, -8/16, -1/32, 8/16, 8/16, 1/32}},
}

for j=1, #panels do
	local def = {
		drawtype = "nodebox",
		description = S(panels[j].description.." (vystředěna)"),
		tiles = {
			{ name = panels[j].textures.edge, backface_culling = true},
			{ name = panels[j].textures.edge, backface_culling = true},
			{ name = panels[j].textures.edge, backface_culling = true},
			{ name = panels[j].textures.edge, backface_culling = true},
			{ name = panels[j].textures.front, backface_culling = true},
			{ name = panels[j].textures.front, backface_culling = true},
		},
		use_texture_alpha = panels[j].use_texture_alpha,
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		is_ground_content = false,
		inventory_image = panels[j].textures.front,
		wield_image = panels[j].textures.front,
		sounds = default.node_sound_glass_defaults(),
		groups = {snappy=2, cracky=3, oddly_breakable_by_hand=3},
		node_box = panel_c_nodebox,
		connect_sides = {"left", "right"},
	}
	minetest.register_node("jonez:"..panels[j].name.."_c", def)
	minetest.register_craft({
		output = "jonez:"..panels[j].name.."_c 16",
		recipe = panels[j].recipe,
	})
end

local pavements= {
	{name= "jonez:blossom_pavement", description= "blok s květinovým vzorkem", texture= combine4("jonez_blossom_pavement.png", 32),
		recipe = {
			{'', 'stairs:slab_marble', ''},
			{'stairs:slab_marble', 'stairs:slab_marble', 'stairs:slab_marble'},
			{'', 'stairs:slab_marble', ''},
		}
	},
	{name= "jonez:tiled_pavement", description= "blok s motivem dlažby", texture= combine4("jonez_tiled_pavement.png", 32),
		recipe = {
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick', ''},
			{'', 'stairs:slab_marble_brick', 'stairs:slab_marble_brick'},
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick', ''},
		}
	},
	{name= "jonez:mosaic_pavement", description= "blok s motivem dlaždic", texture= "jonez_mosaic_pavement.png",
		recipe = {
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick', 'stairs:slab_marble_brick'},
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick', 'stairs:slab_marble_brick'},
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick', 'stairs:slab_marble_brick'},
		}
	},
	{name= "jonez:diamond_pavement", description= "diamantová mozaika", texture= combine4("jonez_diamond_pavement.png", 32),
		recipe = {
			{'', 'stairs:slab_marble', ''},
			{'stairs:slab_marble', '', 'stairs:slab_marble'},
			{'', 'stairs:slab_marble', ''},
		}
	},
	{name= "jonez:pebbled_pavement", description= "stezka z oblázků", texture= combine4("jonez_pebbled_pavement.png", 32),
		recipe = {
			{'', 'stairs:slab_marble_brick_polished', ''},
			{'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick_polished',
			'stairs:slab_marble_brick_polished'},
			{'', 'stairs:slab_marble_brick_polished', ''},
		}
	},
	{name= "jonez:pebbled_medieval_pavement", description= "středověká stezka z oblázků",
		texture= combine4("jonez_pebbled_medieval_pavement.png", 32),
		recipe = {
			{'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick_polished', ''},
			{'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick_polished',
				'stairs:slab_marble_brick_polished'},
			{'', 'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick_polished'},
		}
	},
	{name= "jonez:pebbled_gothic_pavement", description= "gotický blok",
		texture= combine4("jonez_pebbled_gothic_pavement.png", 32),
		recipe = {
			{'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick_polished', ''},
			{'', 'stairs:slab_marble_brick_polished', ''},
			{'', 'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick_polished'},
		}
	},
	{name= "jonez:pebbled_wall", description= "zeď z oblázků", texture= combine4("jonez_pebbled_wall.png", 32),
		recipe = {
			{'', 'stairs:slab_marble_brick_polished', ''},
			{'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick_polished',
				'stairs:slab_marble_brick_polished'},
			{'', 'stairs:slab_marble_brick_polished', ''},
		}
	},
	{name= "jonez:gothic_wall", description= "gotická zeď", texture= combine4("jonez_gothic_top_bottom.png", 32),
		recipe = {
			{'', 'stairs:slab_marble_brick', ''},
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick', 'stairs:slab_marble_brick'},
			{'', 'stairs:slab_marble_brick', ''},
		}
	},
	{name= "jonez:pompeiian_wall", description= "pompejská zeď", texture= "jonez_pompeiian_wall.png",
		recipe = {
			{'', 'stairs:slab_marble_brick_polished', ''},
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick'},
			{'', 'stairs:slab_marble_brick_polished', ''},
		}
	},
	{name= "jonez:pompeiian_pavement", description= "pompejský chodník",
		texture= combine4("jonez_pompeiian_pavement.png", 32),
		recipe = {
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick'},
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick'},
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick'},
		}
	},
	{name= "jonez:pompeiian_path", description= "pompejská stezka", texture= combine4("jonez_pompeiian_path.png", 32), colorable = true,
		amount = 4,
		recipe = {
			{'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick', 'stairs:slab_marble_brick_polished'},
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick', 'stairs:slab_marble_brick'},
			{'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick', 'stairs:slab_marble_brick_polished'},
		}
	},
	{name= "jonez:carthaginian_pavement", description= "kartágský chodník",
		texture= combine4("jonez_carthaginian_pavement.png", 32), amount = 4,
		recipe = {
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick'},
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick', 'stairs:slab_marble_brick'},
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick'},
		}
	},
	{name= "jonez:carthaginian_wall", description= "kartágská zeď", texture= "jonez_carthaginian_wall.png",
		amount = 4,
		recipe = {
			{'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick', 'stairs:slab_marble_brick_polished'},
			{'stairs:slab_marble_brick', 'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick'},
			{'stairs:slab_marble_brick_polished', 'stairs:slab_marble_brick', 'stairs:slab_marble_brick_polished'},
		}
	},
	{name= "jonez:nubian_wall", description= "nubijská zeď", texture= "jonez_nubian_wall.png", amount = 9,
		recipe = {
			{'default:sandstonebrick', 'default:sandstonebrick', 'default:sandstonebrick'},
			{'default:sandstonebrick', 'default:sandstonebrick', 'default:sandstonebrick'},
			{'default:sandstonebrick', 'default:sandstonebrick', 'default:sandstonebrick'},
		}
	},
}

for i = 1, #pavements do
	def = colorable_256({
		description = S(pavements[i].description),
		tiles = {pavements[i].texture},
		is_ground_content = true,
		groups = {cracky=3},
		sounds = default.node_sound_stone_defaults(),
	})
	minetest.register_node(pavements[i].name, def)
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
	description = S("kovová mřížka (horní díl)"),
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
	use_texture_alpha = "clip",
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
	description = S("versailský chodník"),
	tiles = {combine4("jonez_versailles_pavement.png", 32)},
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

minetest.register_node("jonez:versailles_tile", colorable_256({
	description = S("versailská dlažba"),
	tiles = {combine4("jonez_versailles_tile.png", 32)},
	is_ground_content = false,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
}))

minetest.register_craft({
	output = 'jonez:versailles_tile 9',
	type = "shapeless",
	recipe = {
		'jonez:diamond_pavement', 'stairs:slab_marble_brick', 'jonez:diamond_pavement',
		'stairs:slab_marble_brick', 'jonez:diamond_pavement', 'stairs:slab_marble_brick',
		'jonez:diamond_pavement', 'stairs:slab_marble_brick', 'jonez:diamond_pavement',
	},
})

--[[
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
]]

minetest.register_node("jonez:censer", colorable_256({
	description = S("kadidelnice"),
    tiles = {"jonez_censer_top.png", "jonez_censer_top.png", "jonez_censer_front.png"},
	use_texture_alpha = "opaque",
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
}))

