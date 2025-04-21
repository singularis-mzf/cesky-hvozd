local epsilon = 0.010

local corner_nbox = {
	type = "fixed",
	fixed = {-0.5, -0.5, -0.5, 0.5, -0.5 + epsilon, 0.5},
}
local corner_sbox = {
	type = "fixed",
	fixed = {0.0, -0.5, -0.5, 0.5, -0.5 + 1/32, 0.0},
}
local corner_cbox = corner_sbox

local icorner_nbox = corner_nbox
local icorner_sbox = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.5, 0.5, -0.5 + 1/32, 0.0},
		{0.0, -0.5, 0.0, 0.5, -0.5 + 1/32, 0.5},
	},
}
local icorner_cbox = icorner_sbox

local edge_nbox = corner_nbox
local edge_sbox = {
	type = "fixed",
	fixed = {-0.5, -0.5, -0.5, 0.5, -0.5 + 1/32, 0.0},
}
local edge_cbox = edge_sbox

local diag_nbox = corner_nbox
local diag_sbox = {
	type = "fixed",
	fixed = {-0.5, -0.5, -0.5, 0.5, -0.5 + 1/32, 0.5},
}
local diag_cbox = diag_sbox

local empty_tile = {name = "ch_core_empty.png", backface_culling = true}

local def_template = {
	-- description
	-- tiles
	use_texture_alpha = "clip",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	-- node_box = corner_nbox,
	-- selection_box = corner_sbox,
	-- collision_box = corner_cbox,
	buildable_to = true,
	floodable = true,
	walkable = false,
	sunlight_propagates = true,
	groups = {snappy = 3, flammable = 1, falling_node = 1, attached_node = 1, not_blocking_trains = 1, ch_cover = 1},
	sounds = default.node_sound_leaves_defaults(),
}

-- => cropped_texture, full_texture
local function generate_textures(texture, texture_size, mask)
	local t = texture.."^[mask:"..mask
	if (texture_size or 32) ~= 32 then
		t = t.."\\^[resize\\:"..texture_size.."x"..texture_size
	end
	return {name = t, backface_culling = false}, {name = texture, backface_culling = true}
end

local function register_recipes(name, material, recipe_force)
	recipe_force = recipe_force or {}
	minetest.register_craft({
		output = "ch_extras:"..name.."_corner 3",
		recipe = recipe_force[1] or {
			{material, material},
			{material, ""}
		},
	})
	minetest.register_craft({
		output = "ch_extras:"..name.."_icorner 3",
		recipe = recipe_force[2] or {
			{"", material},
			{material, material}
		},
	})
	minetest.register_craft({
		output = "ch_extras:"..name.."_edge 2",
		recipe = recipe_force[3] or {
			{material, material},
			{"", ""},
		},
	})
	minetest.register_craft({
		output = "ch_extras:"..name.."_diag 2",
		recipe = recipe_force[4] or {
			{"", material},
			{material, ""}
		},
	})
	minetest.register_craft({
		output = "ch_extras:"..name.."_diag 2",
		recipe = recipe_force[5] or {
			{material, ""},
			{"", material}
		},
	})
end

local function register_cover(name, cover_def) --  texture, description, groups, sounds
	local template = table.copy(def_template)
	if cover_def.groups ~= nil then
		template.groups = cover_def.groups
	end
	if cover_def.sounds ~= nil then
		template.sounds = cover_def.sounds
	end
	if cover_def.item ~= nil then
		template.drop = cover_def.item
	end

	local ctex, etex, ftex
	etex = empty_tile -- empty texture
	ctex = generate_textures(cover_def.texture, cover_def.texture_size, "ch_extras_cover_corner.png") -- cropped, full

	local def = table.copy(template)
	def.description = "pokrývka: "..cover_def.description..": roh"
	def.tiles = {ctex, etex, etex, etex, etex, etex}
	def.inventory_image = ctex.name
	def.wield_image = ctex.name
	def.node_box = corner_nbox
	def.selection_box = corner_sbox
	def.collision_box = corner_cbox
	minetest.register_node("ch_extras:"..name.."_corner", def)

	ctex, ftex = generate_textures(cover_def.texture, cover_def.texture_size, "ch_extras_cover_inner_corner.png")
	def = table.copy(template)
	def.description = "pokrývka: "..cover_def.description..": vnitřní roh"
	def.tiles = {ctex, etex, ftex, etex, etex, ftex}
	def.inventory_image = ctex.name
	def.wield_image = ctex.name
	def.node_box = icorner_nbox
	def.selection_box = icorner_sbox
	def.collision_box = icorner_cbox
	minetest.register_node("ch_extras:"..name.."_icorner", def)

	ctex, ftex = generate_textures(cover_def.texture, cover_def.texture_size, "ch_extras_cover_edge.png")
	def = table.copy(template)
	def.description = "pokrývka: "..cover_def.description..": okraj"
	def.tiles = {ctex, etex, etex, etex, etex, ftex}
	def.inventory_image = ctex.name
	def.wield_image = ctex.name
	def.node_box = edge_nbox
	def.selection_box = edge_sbox
	def.collision_box = edge_cbox
	minetest.register_node("ch_extras:"..name.."_edge", def)

	ctex, ftex = generate_textures(cover_def.texture, cover_def.texture_size, "ch_extras_cover_diag.png")
	def = table.copy(template)
	def.description = "pokrývka: "..cover_def.description..": úhlopříčný díl"
	def.tiles = {ctex, etex, ftex, etex, etex, ftex}
	def.inventory_image = ctex.name
	def.wield_image = ctex.name
	def.node_box = diag_nbox
	def.selection_box = diag_sbox
	def.collision_box = diag_cbox
	minetest.register_node("ch_extras:"..name.."_diag", def)

	if cover_def.item ~= nil then
		register_recipes(name, cover_def.item)
	end
end

register_cover("snow", {
	description = "sněhová pokrývka",
	texture = "default_snow.png",
	texture_size = 32,
	groups = {crumbly = 3, falling_node = 1, attached_node = 1, snowy = 1, ch_snow = 1, not_blocking_trains = 1, ch_cover = 1},
	sounds = default.node_sound_snow_defaults(),
	item = "default:snow",
})
register_recipes("snow", "group:ch_snow")

register_cover("grass", {
	description = "tráva",
	texture = "default_grass.png",
	texture_size = 128,
	item = "default:grass_1",
})

register_cover("dry_grass", {
	description = "suchá tráva",
	texture = "default_dry_grass.png",
	texture_size = 64,
	item = "default:dry_grass_1",
})

register_cover("rainforest", {
	description = "džunglová pokrývka",
	texture = "default_rainforest_litter.png",
	texture_size = 64,
	item = "default:junglegrass",
})

register_cover("coniferous", {
	description = "jehličí",
	texture = "default_coniferous_litter.png",
	texture_size = 64,
	item = "default:pine_needles",
})

register_recipes("coniferous", "default:pine_bush_needles")
register_recipes("coniferous", "moretrees:cedar_leaves")
register_recipes("coniferous", "moretrees:fir_leaves")
register_recipes("coniferous", "moretrees:fir_leaves_bright")
register_recipes("coniferous", "moretrees:spruce_leaves")

register_cover("dirt", {
	description = "hlína",
	texture = "default_dirt.png",
	texture_size = 64,
	sounds = default.node_sound_dirt_defaults(),
	groups = {crumbly = 3, falling_node = 1, attached_node = 1, not_blocking_trains = 1, ch_cover = 1},
	item = "default:dirt",
})

register_cover("sand", {
	description = "žlutý písek",
	texture = "default_sand.png",
	texture_size = 64,
	groups = {crumbly = 3, sand = 1, falling_node = 1, attached_node = 1, not_blocking_trains = 1, ch_cover = 1},
	sounds = default.node_sound_sand_defaults(),
	item = "default:sand",
})

register_cover("silver_sand", {
	description = "bílý písek",
	texture = "default_silver_sand.png",
	texture_size = 64,
	groups = {crumbly = 3, sand = 1, falling_node = 1, attached_node = 1, not_blocking_trains = 1, ch_cover = 1},
	sounds = default.node_sound_sand_defaults(),
	item = "default:silver_sand",
})

register_cover("desert_sand", {
	description = "pouštní písek",
	texture = "default_desert_sand.png",
	texture_size = 64,
	groups = {crumbly = 3, sand = 1, falling_node = 1, attached_node = 1, not_blocking_trains = 1, ch_cover = 1},
	sounds = default.node_sound_sand_defaults(),
	item = "default:desert_sand",
})

if minetest.get_modpath("summer") then
	register_cover("sabbia_mare", {
		description = "plážový písek",
		texture = "sabbia_mare_2.png",
		texture_size = 64,
		groups = {crumbly = 3, sand = 1, falling_node = 1, attached_node = 1, not_blocking_trains = 1, ch_cover = 1},
		sounds = default.node_sound_sand_defaults(),
		item = "summer:sabbia_mare",
	})
end

register_cover("gravel", {
	description = "štěrk",
	texture = "default_gravel.png",
	texture_size = 64,
	groups = {crumbly = 2, falling_node = 1, attached_node = 1, not_blocking_trains = 1, ch_cover = 1},
	sounds = default.node_sound_gravel_defaults(),
	item = "default:gravel",
})

register_cover("railway_gravel", {
	description = "železniční štěrk",
	texture = "ch_extras_gravel.png",
	texture_size = 64,
	groups = {crumbly = 2, falling_node = 1, attached_node = 1, not_blocking_trains = 1, ch_cover = 1},
	sounds = default.node_sound_gravel_defaults(),
	item = "ch_extras:railway_gravel",
})

register_cover("dry_dirt", {
	description = "hlína ze savany",
	texture = "default_dry_dirt.png",
	texture_size = 64,
	sounds = default.node_sound_dirt_defaults(),
	groups = {crumbly = 3, falling_node = 1, attached_node = 1, not_blocking_trains = 1, ch_cover = 1},
	item = "default:dry_dirt",
})

-- --------------------------------------------------------------------------

minetest.register_craft({
	output = "default:dirt",
	recipe = {{"default:dirt_with_snow"}},
	replacements = {
		{"default:dirt_with_snow", "default:snow"},
	},
})
