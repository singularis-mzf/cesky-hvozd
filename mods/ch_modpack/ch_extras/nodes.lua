local def, nbox

local ifthenelse = ch_core.ifthenelse
local has_solidcolor = minetest.get_modpath("solidcolor")

local function degrotate_after_place_node(pos, placer, itemstack, pointed_thing)
	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	if ndef and ndef.paramtype2 == "degrotate" then
		node.param2 = math.random(0, 239)
		minetest.swap_node(pos, node)
	end
end

local function degrotate_on_rotate(pos, node, user, mode, new_param2)
	if mode == screwdriver.ROTATE_FACE then
		if node.param2 == 239 then
			node.param2 = 0
		else
			node.param2 = node.param2 + 1
		end
	else
		if node.param2 == 0 then
			node.param2 = 239
		else
			node.param2 = node.param2 - 1
		end
	end
	minetest.swap_node(pos, node)
	return true
end

-- ch_extras:czech_flag
---------------------------------------------------------------
def = {
	description = "vlajka České republiky",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.333333, 7/16, 0.5, 0.333333, 0.5}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.333333, 7/16, 0.5, 0.333333, 0.5}
	},
	-- top, bottom, right, left, back, front
	tiles = {"ch_core_white_pixel.png^[multiply:#ffffff",
             "ch_core_white_pixel.png^[multiply:#d7141a",
             "ch_extras_cz_flag.png",
             "ch_core_white_pixel.png^[multiply:#11457e",
             "ch_extras_cz_flag.png^[transformFX",
             "ch_extras_cz_flag.png",},
	inventory_image = "ch_extras_cz_flag_inv.png",
	wield_image = "ch_extras_cz_flag_inv.png",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	groups = {choppy = 2, dig_immediate = 2},
	legacy_wallmounted = true,
	sounds = default.node_sound_wood_defaults(),
}

minetest.register_node("ch_extras:czech_flag", def)
minetest.register_craft({
	output = "ch_extras:czech_flag",
	recipe = {
		{"", "dye:white", ""},
		{"dye:blue", "", ""},
		{"", "dye:red", ""},
	},
})
minetest.register_alias("ch_core:czech_flag", "ch_extras:czech_flag")

-- ch_extras:slovak_flag
---------------------------------------------------------------
def = table.copy(def)
def.description = "vlajka Slovenska"
def.tiles = {"ch_core_white_pixel.png^[multiply:#ffffff",
             "ch_core_white_pixel.png^[multiply:#d7141a",
             "ch_extras_sk_flag.png",
             "ch_extras_sk_flag.png",
             "ch_extras_sk_flag.png^[transformFX",
             "ch_extras_sk_flag.png",}
def.inventory_image = "ch_extras_sk_flag_inv.png"
def.wield_image = "ch_extras_sk_flag_inv.png"

minetest.register_node("ch_extras:slovak_flag", def)
minetest.register_craft({
	output = "ch_extras:slovak_flag",
	recipe = {
		{"dye:white", "", ""},
		{"", "dye:blue", ""},
		{"dye:red", "", ""},
	},
})
minetest.register_alias("ch_core:slovak_flag", "ch_extras:slovak_flag")

-- ch_extras:marker_{red_white,yellow_black}
---------------------------------------------------------------
local function marker_update(pos, meta)
	if not meta then
		meta = minetest.get_meta(pos)
	end
	local owner = meta:get_string("owner")
	local date = meta:get_string("date")
	local view_name
	if owner ~= "" then
		view_name = ch_core.prihlasovaci_na_zobrazovaci(owner)
	else
		view_name = "neznámá postava"
	end
	meta:set_string("infotext", string.format("%s\ntyč umístil/a: %s\n%s", minetest.pos_to_string(pos), view_name, date))
end

local function marker_after_place_node(pos, placer, itemstack, pointed_thing)
	local meta = minetest.get_meta(pos)
	local player_name = placer and placer.get_player_name and placer:get_player_name()
	local cas = ch_core.aktualni_cas()
	if player_name then
		meta:set_string("owner", player_name)
	end
	meta:set_string("date", string.format("%d. %d. %d", cas.den, cas.mesic, cas.rok))
	marker_update(pos, meta)
end

local function marker_check_for_pole(pos, node, def, pole_pos, pole_node, pole_def)
	if (0 <= pole_node.param2 and pole_node.param2 <= 3) or (20 <= pole_node.param2 and pole_node.param2 <= 23) then
		return true
	else
		return false
	end
end

def = {
	description = "značkovací tyč červeno-bílá",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-1/16, -8/16, -1/16, 1/16, 24/16, 1/16},
	},
	tiles = {
		"ch_extras_crvb_pruhy.png^[verticalframe:16:1",
		"ch_extras_crvb_pruhy.png^[verticalframe:16:5",
		"ch_extras_crvb_pruhy.png",
	},
	paramtype = "light",
	paramtype2 = "colorwallmounted",
	is_ground_content = false,
	sunlight_propagates = true,
	light_source = 3,
	groups = {oddly_breakable_by_hand = 2, ch_marker = 1},
	check_for_pole = marker_check_for_pole,
	after_place_node = marker_after_place_node,
	preserve_metadata = function(pos, oldnode, oldmeta, drops)
		for _, stack in ipairs(drops) do
			stack:get_meta():set_string("palette_index", "")
		end
	end,
}
minetest.register_node("ch_extras:marker_red_white", table.copy(def))

def.description = "značkovací tyč žluto-černá"
def.tiles = {
	"ch_extras_czl_pruhy.png^[verticalframe:16:1",
	"ch_extras_czl_pruhy.png^[verticalframe:16:5",
	"ch_extras_czl_pruhy.png",
}
minetest.register_node("ch_extras:marker_yellow_black", def)

minetest.register_lbm({
	label = "Marker updates",
	name = "ch_extras:marker_updates",
	nodenames = {"group:ch_marker"},
	run_at_every_load = true,
	action = function(pos, node)
		marker_update(pos)
	end,
})

minetest.register_craft({
	output = "ch_extras:marker_red_white 64",
	recipe = {
		{"", "default:steel_ingot", "dye:red"},
		{"", "default:steel_ingot", "dye:white"},
		{"", "default:steel_ingot", ""},
	}
})
minetest.register_craft({
	output = "ch_extras:marker_yellow_black 64",
	recipe = {
		{"", "default:steel_ingot", "dye:yellow"},
		{"", "default:steel_ingot", "dye:black"},
		{"", "default:steel_ingot", ""},
	}
})

-- ch_extras:cracks
---------------------------------------------------------------
nbox = {
	type = "fixed",
	fixed = {-0.4, -0.5, -0.4, 0.4, -7/16, 0.4},
}
def = {
	description = "praskliny (jen vodorovně)",
	drawtype = "mesh",
	mesh = "ch_extras_cracks.obj",
	selection_box = nbox,
	--[[
	-- top, bottom, right, left, back, front
	tiles = {"ch_extras_praskliny.png",
             "ch_extras_praskliny.png",
             "ch_core_empty.png",
             "ch_core_empty.png",
             "ch_core_empty.png",
             "ch_core_empty.png",
             }, ]]
	tiles = {"ch_extras_praskliny.png^[opacity:192"},
	use_texture_alpha = "blend",
	inventory_image = "ch_core_white_pixel.png^[invert:rgb^ch_extras_praskliny.png",
	wield_image = "ch_extras_praskliny.png",
	paramtype = "light",
	paramtype2 = "degrotate",
	sunlight_propagates = true,
	groups = {choppy = 2, dig_immediate = 2},
	buildable_to = true,
	floodable = true,
	walkable = false,
	after_place_node = degrotate_after_place_node,
	on_rotate = degrotate_on_rotate,
}

minetest.register_node("ch_extras:cracks", def)
minetest.register_craft({
	output = "ch_extras:cracks 16",
	recipe = {
		{"", "default:cobble"},
		{"default:cobble", ""},
	},
})

-- ch_extras:fence_hv
---------------------------------------------------------------
if minetest.get_modpath("technic") then
default.register_fence("ch_extras:fence_hv", {
	description = "výstražný plot",
	texture = "technic_hv_cable.png^[colorize:#91754d:40",
	inventory_image = "default_fence_overlay.png^technic_hv_cable.png^[colorize:#91754d:40^default_fence_overlay.png^[makealpha:255,126,126",
	wield_image = "default_fence_overlay.png^technic_hv_cable.png^[colorize:#91754d:40^default_fence_overlay.png^[makealpha:255,126,126",
	material = "technic:hv_cable",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, technic_hv_cablelike = 1},
	sounds = default.node_sound_wood_defaults(),
	check_for_pole = true,
	connects_to = {"group:fence", "group:wood", "group:tree", "group:wall", "group:technic_hv_cable"},
})

default.register_fence_rail("ch_extras:fence_rail_hv", {
	description = "výstražné zábradlí",
	texture = "technic_hv_cable.png^[colorize:#91754d:40",
	inventory_image = "default_fence_rail_overlay.png^technic_hv_cable.png^[colorize:#91754d:40^default_fence_rail_overlay.png^[makealpha:255,126,126",
	wield_image = "default_fence_rail_overlay.png^technic_hv_cable.png^[colorize:#91754d:40^default_fence_rail_overlay.png^[makealpha:255,126,126",
	material = "technic:hv_cable",
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
	sounds = default.node_sound_wood_defaults(),
})

end

-- ch_extras:mirror
---------------------------------------------------------------
nbox = {
	type = "fixed",
	fixed = {-0.5 + 1/16, -0.5, 0.5 - 2/16, 0.5 - 1/16, 0.5, 0.5},
}
def = {
	description = "zrcadlo",
	drawtype = "nodebox",
	collision_box = nbox,
	selection_box = nbox,
	node_box = nbox,
	tiles = {
		{name = "ch_core_white_pixel.png", color = "#744f27"},
		{name = "ch_core_white_pixel.png", color = "#744f27"},
		{name = "ch_core_white_pixel.png", color = "#744f27"},
		{name = "ch_core_white_pixel.png", color = "#744f27"},
		{name = "ch_core_white_pixel.png", color = "#9a8167"},
		{name = "[combine:64x64:4,0=ch_extras_mirror.jpg\\^[resize\\:56x64", color = "white"},
	},
	use_texture_alpha = "opaque",
	inventory_image = "ch_extras_mirror.jpg",
	wield_image = "ch_extras_mirror.jpg",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2, oddly_breakable_by_hand = 2},
	sounds = default.node_sound_glass_defaults(),
}
minetest.register_node("ch_extras:mirror", def)

minetest.register_craft({
	output = "ch_extras:mirror",
	recipe = {
		{"default:stick", "default:stick", "default:stick"},
		{"default:stick", "xpanes:pane_flat", "default:stick"},
		{"default:stick", "default:stick", "default:stick"},
	},
})

-- historic:
minetest.register_alias("mirrors:mirror", "ch_extras:mirror")

-- ch_extras:spina
---------------------------------------------------------------

nbox = {
	type = "fixed",
	fixed = {-0.1, -0.5, -0.1, 0.1, -7/16, 0.1},
}
def = {
	description = "špína (jen vodorovně)",
	drawtype = "mesh",
	mesh = "ch_extras_cracks.obj",
	selection_box = nbox,
	tiles = {"ch_extras_spina.png"},
	use_texture_alpha = "blend",
	inventory_image = "ch_core_white_pixel.png^[multiply:#cccccc^ch_extras_spina.png^ch_extras_spina.png",
	wield_image = "ch_extras_spina.png",
	paramtype = "light",
	paramtype2 = "degrotate",
	sunlight_propagates = true,
	groups = {choppy = 2, dig_immediate = 2},
	buildable_to = true,
	floodable = true,
	walkable = false,
	after_place_node = degrotate_after_place_node,
	on_rotate = degrotate_on_rotate,
}

minetest.register_node("ch_extras:spina", def)
minetest.register_craft({
	output = "ch_extras:spina 16",
	recipe = {{"darkage:silt_lump"}},
})

minetest.register_craft({
	output = "ch_extras:spina 64",
	recipe = {{"default:dirt", ""}, {"default:sand", ""}},
})

-- ch_extras:railway_gravel
---------------------------------------------------------------
def = table.copy(minetest.registered_nodes["default:gravel"])
def.description = "železniční štěrk"
def.tiles = {
	"default_gravel.png^[multiply:#956338"
}
def.drop = nil
minetest.register_node("ch_extras:railway_gravel", def)

minetest.register_craft({
	output = "ch_extras:railway_gravel 2",
	type = "shapeless",
	recipe = {"default:gravel", "default:gravel", "default:iron_lump"},
})

minetest.register_craft({
	output = "ch_extras:railway_gravel",
	type = "shapeless",
	recipe = {"default:gravel", "technic:wrought_iron_dust"},
})
minetest.register_alias("ch_core:railway_gravel", "ch_extras:railway_gravel")

stairsplus:register_all("ch_extras", "railway_gravel", "ch_extras:railway_gravel", minetest.registered_nodes["ch_extras:railway_gravel"])
stairsplus:register_alias_all("ch_core", "railway_gravel", "ch_extras", "railway_gravel")

-- ch_extras:bright_gravel
---------------------------------------------------------------
def = table.copy(minetest.registered_nodes["default:gravel"])
def.description = "světlý štěrk"
def.tiles = {
	"[combine:128x128:0,0=breccia.png:64,0=breccia.png:0,64=breccia.png:64,64=breccia.png"
}
def.drop = nil
minetest.register_node("ch_extras:bright_gravel", def)

minetest.register_craft({
	output = "ch_extras:bright_gravel 4",
	type = "shapeless",
	recipe = {"default:gravel", "default:gravel", "default:silver_sand", "default:silver_sand"},
})

stairsplus:register_all("ch_extras", "bright_gravel", "ch_extras:bright_gravel", minetest.registered_nodes["ch_extras:bright_gravel"])

-- ch_extras:noise
---------------------------------------------------------------
def = {
	drawtype = "normal",
	description = "šumový blok [EXPERIMENTÁLNÍ]",
	_ch_help = "Tento blok je experimentální. Můžete ho zkoušet, ale nepoužívejte ho bez domluvy na vážně míněných stavbách.",
	tiles = {{name = "ch_extras_noise.png", animation = {
		type = "vertical_frames",
		aspect_w = 64,
		aspect_h = 64,
		length = 0.25,
	}}},
	paramtype = "light",
	paramtype2 = "color",
	palette = "unifieddyes_palette_extended.png",
	light_source = 5,
	groups = {dig_immediate = 2, ud_param2_colorable = 1},
	sounds = default.node_sound_defaults(),
	is_ground_content = false,
}

if minetest.get_modpath("unifieddyes") then
	def.on_construct = unifieddyes.on_construct
	def.on_dig = unifieddyes.on_dig
end

minetest.register_node("ch_extras:noise", def)

-- BAREVNÉ SKLO

local epsilon = 0.001
local e2 = 1 / 16

local function box(x_min, x_max, y_min, y_max, z_min, z_max)
	local result = {x_min or -0.5, y_min or -0.5, z_min or -0.5, x_max or 0.5, y_max or 0.5, z_max or 0.5}
	if result[1] > result[4] or result[2] > result[5] or result[3] > result[6] then
		error("Invalid box generated: "..dump2({x_min = x_min, x_max = x_max, y_min = y_min, y_max = y_max, z_min = z_min, z_max = z_max, result = result}))
	end
	return result
end

-- FULL
local node_box_full = {
	type = "connected",
	disconnected_top = {-0.5, 0.5 - epsilon, -0.5, 0.5, 0.5, 0.5},
	disconnected_bottom = {-0.5, -0.5, -0.5, 0.5, -0.5 + epsilon, 0.5},
	disconnected_front = {-0.5, -0.5, -0.5, 0.5, 0.5, -0.5 + epsilon},
	disconnected_left = {-0.5, -0.5, -0.5, -0.5 + epsilon, 0.5, 0.5},
	disconnected_back = {-0.5, -0.5, 0.5 - epsilon, 0.5, 0.5, 0.5},
	disconnected_right = {0.5 - epsilon, -0.5, -0.5, 0.5, 0.5, 0.5},
}
local cbox_full = {
	type = "fixed",
	fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
}

-- FRONT
local node_box_front = { -- -Z
	type = "connected",
	disconnected_top = box(nil, nil,		0.5 - epsilon, nil,		nil, -0.5 + e2),
	disconnected_bottom = box(nil, nil,		nil, -0.5 + epsilon,	nil, -0.5 + e2),
	fixed = {
		box(nil, nil,		nil, nil,		-0.5, -0.5 + epsilon),
		box(nil, nil,		nil, nil,		-0.5 + e2, -0.5 + e2 + epsilon),
	},
	disconnected_left = box(nil, -0.5 + epsilon,  nil, nil,		nil, -0.5 + e2),
	disconnected_right = box(0.5 - epsilon, nil,  nil, nil,		nil, -0.5 + e2),
}
local cbox_front = {
	type = "fixed",
	fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, -0.5 + 1 / 16},
}

-- CENTER (+- Z)
local node_box_center = {
	type = "connected",
	disconnected_top = box(nil, nil,		0.5 - epsilon, nil,		-e2 / 2, e2 / 2),
	disconnected_bottom = box(nil, nil,		nil, -0.5 + epsilon,	-e2 / 2, e2 / 2),
	fixed = {
		box(nil, nil,		nil, nil,		-e2/2, -e2/2 + epsilon),
		box(nil, nil,		nil, nil,		e2/2 - epsilon, e2/2),
	},
	disconnected_left = box(nil, -0.5 + epsilon,  nil, nil,		-e2 / 2, e2 / 2),
	disconnected_right = box(0.5 - epsilon, nil,  nil, nil,		-e2 / 2, e2 / 2),
}
local cbox_center = {
	type = "fixed",
	fixed = {-0.5, -0.5, -1/32, 0.5, 0.5, 1/32},
}

local tiles_cache = {}

local function get_tiles(opacity)
	opacity = math.floor(opacity)
	if opacity < 0 then
		opacity = 0
	elseif opacity > 255 then
		opacity = 255
	end
	local result = tiles_cache[opacity]
	if result == nil then
		result = {{
			name = "ch_extras_glass.png^[opacity:"..opacity,
			backface_culling = true,
		}}
		tiles_cache[opacity] = result
	end
	return result
end

if minetest.get_modpath("unifieddyes") then

	local colorable_glass_tiles_normal = get_tiles(120)
	local colorable_glass_tiles_thick = get_tiles(220)
	local colorable_glass_tiles_normal_half = get_tiles(70)
	local colorable_glass_tiles_thick_half = get_tiles(120)
	local inventory_image_normal = "[combine:16x16:1,1=ch_extras_glass.png\\^[opacity\\:127\\^[resize\\:14x14"
	local inventory_image_thick = "[combine:16x16:1,1=ch_extras_glass.png\\^[opacity\\:240\\^[resize\\:14x14"

	local colorable_glass_common_def = {
		use_texture_alpha = "blend",
		paramtype = "light",
		light_source = 1,
		paramtype2 = "color",
		palette = "unifieddyes_palette_bright_extended.png",
		_ch_ud_palette = "unifieddyes_palette_extended.png",
		is_ground_content = false,
		sunlight_propagates = true,
		sounds = default.node_sound_glass_defaults(),
	}
	local colorable_glass_common_groups = {
		cracky = 1, glass = 1, ch_colored_glass = 1,
		oddly_breakable_by_hand = 2, ud_param2_colorable = 1,
	}

	-- Tónované sklo (celý blok, normální tloušťka)
	def = table.copy(colorable_glass_common_def)
	def.description = "tónované sklo (blok, barvitelné)"
	def.tiles = colorable_glass_tiles_normal
	def.drawtype = "glasslike"
	def.inventory_image = inventory_image_normal
	def.wield_image = inventory_image_normal
	def.groups = ch_core.override_groups(colorable_glass_common_groups, {ch_colored_glass_full = 1})
	def.on_dig = unifieddyes.on_dig
	minetest.register_node("ch_extras:colorable_glass", table.copy(def))
	minetest.register_craft({
		output = "ch_extras:colorable_glass 6",
		recipe = {
			{"dye:red", "dye:green", "dye:blue"},
			{"building_blocks:smoothglass", "building_blocks:smoothglass", "building_blocks:smoothglass"},
			{"building_blocks:smoothglass", "building_blocks:smoothglass", "building_blocks:smoothglass"},
		},
	})

	-- Tónované sklo (celý blok, tlustší)
	def = table.copy(colorable_glass_common_def)
	def.description = "tlustší tónované sklo (blok, barvitelné)"
	def.tiles = colorable_glass_tiles_thick
	def.drawtype = "glasslike"
	def.inventory_image = "[combine:16x16:1,1=ch_extras_glass.png\\^[opacity\\:240\\^[resize\\:14x14"
	def.wield_image = def.inventory_image
	def.groups = ch_core.override_groups(colorable_glass_common_groups, {ch_colored_glass_full = 1})
	def.on_dig = unifieddyes.on_dig
	minetest.register_node("ch_extras:colorable_glass_thick", def)
	minetest.register_craft({
		output = "ch_extras:colorable_glass_thick",
		recipe = {
			{"ch_extras:colorable_glass", "ch_extras:colorable_glass"},
			{"", ""},
		},
	})

	local function walldir_on_dig(pos, node, digger)
		local ndef = minetest.registered_nodes[node.name]
		local walldir_nodes = ndef and ndef.walldir_nodes
		local base_node = walldir_nodes and walldir_nodes[0]
		if base_node ~= nil then
			node.name = base_node
			minetest.swap_node(pos, node)
		end
		return unifieddyes.on_dig(pos, node, digger)
	end

	-- Tónované sklo (deska, různá tloušťka)
	local walldir_nodes_normal, walldir_nodes_thick = {}, {}
	for i = 0, 5 do
		walldir_nodes_normal[i] = "ch_extras:colorable_glass_front_"..i
		walldir_nodes_thick[i] = "ch_extras:colorable_glass_thick_front_"..i
	end

	local slab_groups = ch_core.override_groups(colorable_glass_common_groups, {ch_colored_glass_slab = 1, walldir = 1})
	def = table.copy(colorable_glass_common_def)
	def.drawtype = "nodebox"
	def.description = "tónované sklo (deska 1/16, barvitelná)"
	def.tiles = colorable_glass_tiles_normal_half
	def.inventory_image = inventory_image_normal
	def.groups = slab_groups
	def.node_box = node_box_front
	def.collision_box = cbox_front
	def.selection_box = cbox_front
	def.connects_to = {"group:ch_colored_glass"}
	def.connect_sides = {"top", "bottom", "left", "right"}

	def.on_dig = walldir_on_dig

	def._facedir = 0
	def.on_rotate = ch_core.on_rotate_walldir
	def.walldir_nodes = walldir_nodes_normal
	minetest.register_node("ch_extras:colorable_glass_front_0", table.copy(def))

	local odef = table.copy(def)
	odef.groups = ch_core.override_groups(def.groups, {not_in_creative_inventory = 1})
	odef.drop = "ch_extras:colorable_glass_front_0"

	for i = 1,5 do
		def = table.copy(odef)
		def.node_box = ch_core.rotate_connected_boxes_for_walldir(i, odef.node_box)
		def.collision_box = {type = "fixed", fixed = ch_core.rotate_boxes_for_walldir(i, cbox_front.fixed)}
		def.selection_box = def.collision_box
		def.connect_sides = ch_core.rotate_connect_sides_for_walldir(i, odef.connect_sides)
		def.walldir_nodes = walldir_nodes_normal
		def._facedir = ch_core.walldir_to_facedir(i)
		minetest.register_node("ch_extras:colorable_glass_front_"..i, table.copy(def))
	end

	odef.description = "tlustší tónované sklo (deska 1/16, barvitelná)"
	odef.tiles = colorable_glass_tiles_thick_half
	odef.inventory_image = inventory_image_thick
	odef.wield_image = inventory_image_thick
	odef.walldir_nodes = walldir_nodes_thick
	odef.groups = slab_groups
	minetest.register_node("ch_extras:colorable_glass_thick_front_0", table.copy(odef))
	odef.groups = ch_core.override_groups(slab_groups, {not_in_creative_inventory = 1})
	odef.drop = "ch_extras:colorable_glass_thick_front_0"

	for i = 1,5 do
		def = table.copy(odef)
		def.node_box = ch_core.rotate_connected_boxes_for_walldir(i, odef.node_box)
		def.collision_box = {type = "fixed", fixed = ch_core.rotate_boxes_for_walldir(i, cbox_front.fixed)}
		def.selection_box = def.collision_box
		def.connect_sides = ch_core.rotate_connect_sides_for_walldir(i, odef.connect_sides)
		def.walldir_nodes = walldir_nodes_normal
		def._facedir = ch_core.walldir_to_facedir(i)
		minetest.register_node("ch_extras:colorable_glass_thick_front_"..i, def)
	end

	minetest.register_craft({
		output = "ch_extras:colorable_glass_front_0 15",
		recipe = {
			{"ch_extras:colorable_glass", ""},
			{"ch_extras:colorable_glass", ""},
		},
	})

	minetest.register_craft({
		output = "ch_extras:colorable_glass_thick_front_0 15",
		recipe = {
			{"ch_extras:colorable_glass_thick", ""},
			{"ch_extras:colorable_glass_thick", ""},
		},
	})

	minetest.register_craft({
		output = "ch_extras:colorable_glass",
		recipe = {
			{"ch_extras:colorable_glass_front_0", "ch_extras:colorable_glass_front_0", "ch_extras:colorable_glass_front_0"},
			{"ch_extras:colorable_glass_front_0", "ch_extras:colorable_glass_front_0", "ch_extras:colorable_glass_front_0"},
			{"ch_extras:colorable_glass_front_0", "ch_extras:colorable_glass_front_0", ""},
		},
	})

	minetest.register_craft({
		output = "ch_extras:colorable_glass_thick",
		recipe = {
			{"ch_extras:colorable_glass_thick_front_0", "ch_extras:colorable_glass_thick_front_0", "ch_extras:colorable_glass_thick_front_0"},
			{"ch_extras:colorable_glass_thick_front_0", "ch_extras:colorable_glass_thick_front_0", "ch_extras:colorable_glass_thick_front_0"},
			{"ch_extras:colorable_glass_thick_front_0", "ch_extras:colorable_glass_thick_front_0", ""},
		},
	})
end

-- Geocache sign and cache

local ch_help = "Značka geokešingu pro umístění na cedule a směrovky existuje ve dvou variantách,\njedna pro normální cedule a druhá pro cedule na tyčích.\nZnačka se ve skutečnosti uloží do bloku 2 m před tyčí/pokladem a lze ji otáčet klíčem nebo šroubovákem.\nPozor na neintuitivní umístění výběrového kvádru značky! Značku je možno skombinovat s nápisem na ceduli."

def = {
	description = "značka geokešingu (pro umístění na cedule a směrovky)",
	drawtype = "nodebox",
	tiles = {
		"ch_core_empty.png",
		"ch_core_empty.png",
		"ch_core_empty.png",
		"ch_core_empty.png",
		"ch_core_empty.png",
		{name = "ch_extras_geocaching.png", backface_culling = true},
	},
	use_texture_alpha = "clip",
	inventory_image = "ch_extras_geocaching.png",
	wield_image = "ch_extras_geocaching.png",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	groups = {dig_immediate = 2, geocache_mark = 1},
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 1.425 * 4, 0.5, 0.5, 1.425 * 4},
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.125, -0.125, 1.4, 0.125, 0.125, 1.45},
	},
	visual_scale = 0.25,
	walkable = false,
	legacy_wallmounted = true,
	sounds = default.node_sound_leaves_defaults(),
	_ch_help_group = "gcache_mark",
	_ch_help = ch_help,
}
minetest.register_node("ch_extras:geocache_sign", def)

local pos = 1.8

def = table.copy(def)
def.description = "značka geokešingu (pro umístění na cedule a směrovky na tyčích)"
def.node_box = {
	type = "fixed",
	fixed = {-0.5, -0.5, pos * 4, 0.5, 0.5, pos * 4},
}
function def.on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local node = minetest.get_node(pointed_thing.under)
		local ndef = minetest.registered_nodes[node.name]
		if ndef ~= nil and ndef.paramtype2 == "facedir" then
			local v = minetest.facedir_to_dir(node.param2)
			pointed_thing.above = vector.subtract(pointed_thing.under, v)
		end
	end
	return minetest.item_place(itemstack, placer, pointed_thing)
end
minetest.register_node("ch_extras:geocache_sign2", def)

minetest.register_craft({
	output = "ch_extras:geocache_sign",
	recipe = {
		{"", "dye:black", ""},
		{"dye:black", "", "dye:black"},
		{"", "dye:black", "dye:black"},
	},
})
minetest.register_craft({
	output = "ch_extras:geocache_sign",
	recipe = {{"ch_extras:geocache_sign2"}},
})
minetest.register_craft({
	output = "ch_extras:geocache_sign2",
	recipe = {{"ch_extras:geocache_sign"}},
})

local box = {
	type = "fixed",
	fixed = {-0.375, -0.5, -0.375, 0.375, 0.25, 0.375},
}

def = {
	description = "geokeš",
	drawtype = "mesh",
	mesh = "ch_extras_geocache.obj",
	tiles = {
		"[combine:64x64:0,0=default_chest_top.png\\^[resize\\:64x64:8,8=ch_extras_geocaching.png\\^[resize\\:48x48",
		"default_chest_top.png",
		"default_chest_side.png^[transformFX",
		"default_chest_side.png",
		"default_chest_side.png",
		"[combine:64x64:0,0=default_chest_front.png\\^[resize\\:64x64:16,32=ch_extras_geocaching.png\\^[resize\\:32x32",
	},
	paramtype = "light",
	paramtype2 = "4dir",
	groups = {dig_immediate = 2},
	selection_box = box,
	collision_box = box,
	sounds = default.node_sound_wood_defaults(),
}

minetest.register_node("ch_extras:geocache", def)

for _, chest in ipairs({"default:chest", "default:chest_locked"}) do
	minetest.register_craft({
		output = "ch_extras:geocache",
		recipe = {{"group:geocache_mark", ""}, {chest, ""}},
	})
end

-- Doors: ch_extras:*
---------------------------------------------------------------
def = {
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

-- ch_extras:builder
---------------------------------------------------------------
local xyz = {"x", "y", "z"}
local function builder_callback(custom_state, player, formname, fields)
	local pos = custom_state.pos
	local node = minetest.get_node(pos)
	if node.name ~= "ch_extras:builder" or not fields.save then
		return
	end
	local meta = minetest.get_meta(pos)
	for _, coord in ipairs(xyz) do
		local n = fields["shift_"..coord]
		if n ~= nil then
			n = tonumber(n)
			if n ~= nil then
				n = math.floor(n)
				if -2 <= n and n <= 2 then
					meta:set_int("shift_"..coord, n)
				end
			end
		end
		n = fields["hl_"..coord]
		if n ~= nil then
			n = tonumber(n)
			if n ~= nil then
				n = math.floor(n)
				if -2 <= n and n <= 2 then
					meta:set_int("hl_"..coord, n)
				end
			end
		end
	end
end

local function builder_on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	local player_name = clicker and clicker:get_player_name()
	if player_name == nil then
		minetest.log("warning", "null clicker right-clicked to the builder "..node.name.." at "..minetest.pos_to_string(pos).."!")
		return
	end
	if minetest.is_protected(pos, player_name) then
		minetest.record_protection_violation(pos, player_name)
		return
	end
	local meta = minetest.get_meta(pos)
	if clicker:get_player_control().aux1 then
		-- show the formspec
		local formspec = {
			"formspec_version[4]",
			"size[6,6]",
			"label[0.5,0.5;Univerzální stavební modul]",
			"label[0.5,1.0;Posun po stavbě:]",
			"field[0.5,1.5;0.9,0.5;shift_x;X;",
			tostring(meta:get_int("shift_x")),
			"]",
			"field[1.5,1.5;0.9,0.5;shift_y;Y;",
			tostring(meta:get_int("shift_y")),
			"]",
			"field[2.5,1.5;0.9,0.5;shift_z;Z;",
			tostring(meta:get_int("shift_z")),
			"]",
			"label[0.5,2.5;Umístění stavební hlavice vůči modulu:]",
			"field[0.5,3.0;0.9,0.5;hl_x;X;",
			tostring(meta:get_int("hl_x")),
			"]",
			"field[1.5,3.0;0.9,0.5;hl_y;Y;",
			tostring(meta:get_int("hl_y")),
			"]",
			"field[2.5,3.0;0.9,0.5;hl_z;Z;",
			tostring(meta:get_int("hl_z")),
			"]",
			"button_exit[1.5,4.5;2.25,0.75;save;Uložit]",
		}
		formspec = table.concat(formspec)
		ch_core.show_formspec(clicker, "ch_extras:builder_settings", formspec, builder_callback, {pos = pos}, {})
	else
		-- build
		local hlavice_under = vector.offset(pos, meta:get_int("hl_x"), meta:get_int("hl_y"), meta:get_int("hl_z"))
		local hlavice_above = vector.copy(hlavice_under)
		for _, coord in ipairs({"y", "x", "z", ""}) do
			if coord == "" then
				hlavice_above.y = hlavice_above.y + 1
				break
			elseif hlavice_under[coord] < pos[coord] then
				hlavice_above[coord] = hlavice_above[coord] + 1
				break
			elseif hlavice_under[coord] > pos[coord] then
				hlavice_above[coord] = hlavice_above[coord] - 1
				break
			end
		end
		print("LADĚNÍ: "..dump2({
			pos = pos,
			hlavice_under = minetest.pos_to_string(hlavice_under),
			hlavice_above = minetest.pos_to_string(hlavice_above),
			}))
		local ndef = minetest.registered_items[itemstack:get_name()]
		if not ndef then
			minetest.log("warning", "Builder module used with unknown item '"..itemstack:get_name().."'!")
			return
		end
		local place_result = (ndef.on_place or minetest.item_place)(itemstack, clicker, {
			type = "node", above = hlavice_above, under = hlavice_under})
		print("LADĚNÍ: place_result = "..dump2(place_result))
		-- [ ] TODO: ...
	end
end

def = {
	description = "univerzální stavební modul (experimentální)",
	tiles = {"ch_core_white_pixel.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {dig_immediate = 2},
	sounds = default.node_sound_stone_defaults(),
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local player_name = placer and placer:get_player_name()
		local meta = minetest.get_meta(pos)
		if player_name ~= nil then
			meta:set_string("owner", player_name)
		end
		meta:set_int("hl_y", -1)
	end,
	-- on_rightclick = builder_on_rightclick,
}

-- minetest.register_node("ch_extras:builder", def)

--[[ PLAKÁTY
local box = {
		type = "fixed",
		-- fixed = {-0.5, -0.5, 7/16, 0.5, 0.5, 8/16}
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
}
def = {
	description = "plakát 1: levý díl",
	drawtype = "normal",
	-- node_box = box,
	-- selection_box = box,
	tiles = {"ch_core_plakat_yf1.png"},
	inventory_image = "ch_core_plakat_yf1.png",
	wield_image = "ch_core_plakat_yf1.png",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = false,
	groups = {choppy = 2, dig_immediate = 2},
	legacy_wallmounted = true,
	sounds = default.node_sound_leaves_defaults(),
}

minetest.register_node("ch_core:plakat_yf_left", table.copy(def))
def.description = "plakát 1: pravý díl"
def.tiles = {"ch_core_plakat_yf2.png"}
def.inventory_image = "ch_core_plakat_yf2.png"
def.weild_image = "ch_core_plakat_yf2.png"
minetest.register_node("ch_core:plakat_yf_right", table.copy(def))
]]

-- ch_extras:particle_board
---------------------------------------------------------------
def = {
	description = "dřevotříska",
	tiles = {"ch_extras_particle_board.png"},
	drawtype = "normal",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy = 2, oddly_breakable_by_hand = 3, ud_param2_colorable = 1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
}
local def2 = table.copy(def)
def2.paramtype2 = "colorfacedir"
def2.palette = "unifieddyes_palette_greys.png"
-- def2.airbrush_replacement_node = "ch_extras:particle_board_grey"
def2.groups = table.copy(def.groups)
def2.groups.ud_param2_colorable = nil
def2.groups.not_in_creative_inventory = 1
def2.on_dig = unifieddyes.on_dig

unifieddyes.generate_split_palette_nodes("ch_extras:particle_board", def2)
minetest.register_alias("ch_extras:particle_board", "ch_extras:particle_board_grey")
minetest.override_item("ch_extras:particle_board_grey", {groups = def.groups})
stairsplus:register_all("ch_extras", "particle_board", "ch_extras:particle_board_grey", def)

minetest.register_craft({
	output = "ch_extras:particle_board 4",
	recipe = {
		{"technic:common_tree_grindings", "technic:common_tree_grindings", "technic:common_tree_grindings"},
		{"technic:common_tree_grindings", "mesecons_materials:glue", "technic:common_tree_grindings"},
		{"technic:common_tree_grindings", "technic:common_tree_grindings", "technic:common_tree_grindings"},
	}
})

minetest.register_craft({
	output = "ch_extras:particle_board 4",
	recipe = {
		{"technic:rubber_tree_grindings", "technic:rubber_tree_grindings", "technic:rubber_tree_grindings"},
		{"technic:rubber_tree_grindings", "mesecons_materials:glue", "technic:rubber_tree_grindings"},
		{"technic:rubber_tree_grindings", "technic:rubber_tree_grindings", "technic:rubber_tree_grindings"},
	}
})

-- ch_extras:tile1
---------------------------------------------------------------
local function tile1_after_place_node(pos, placer, itemstack, pointed_thing)
	local meta_fields = itemstack:get_meta():to_table().fields
	if meta_fields ~= nil and meta_fields.palette_index == nil then
		local node = minetest.get_node(pos)
		node.param2 = math.random(0, 255)
		minetest.swap_node(pos, node)
	end
end

def = {
	description = "barvitelná mozaika na dlažbu",
	drawtype = "normal",
	tiles = {{name = "ch_extras_tile1.png", backface_culling = true}},
	paramtype = "light",
	paramtype2 = "color",
	palette = "unifieddyes_palette_extended.png",
	groups = {cracky = 2, ud_param2_colorable = 1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	node_placement_prediction = "",

	after_place_node = tile1_after_place_node,
	on_dig = unifieddyes.on_dig,
}
minetest.register_node("ch_extras:tile1", def)

minetest.register_craft{
	output = "ch_extras:tile1 9",
	recipe = {
		{"default:stone", "default:cobble", "default:stone"},
		{"default:cobble", "default:stone", "default:cobble"},
		{"default:stone", "default:cobble", "default:stone"},
	},
}
minetest.register_craft{
	output = "ch_extras:tile1 9",
	recipe = {
		{"default:cobble", "default:stone", "default:cobble"},
		{"default:stone", "default:cobble", "default:stone"},
		{"default:cobble", "default:stone", "default:cobble"},
	},
}

minetest.register_craft{
	output = "ch_extras:tile1", -- to remove color
	recipe = {{"ch_extras:tile1"}},
}

if has_solidcolor then
	local plasters = {
		{name = "white", description6 = "bílé omítce", color = "white"},
		{name = "grey", description6 = "šedé omítce", color = "#ADACAA"},
	}
	local tile_top = {name = "ch_extras_tile1.png", backface_culling = true}
	local tile_no_overlay = {name = ""}

	for _, ldef in ipairs(plasters) do
		local tile_overlay = {name = "solidcolor_clay.png^[opacity:0:^[lowpart:50:solidcolor_clay.png", backface_culling = true, color = ldef.color}
		local tile_bottom = {name = "solidcolor_clay.png", backface_culling = true, color = ldef.color}

		def = {
			description = "barvitelná mozaika na "..ldef.description6.." (nejde otáčet)",
			drawtype = "normal",
			tiles = {
				tile_top, tile_bottom, tile_top, tile_top, tile_top, tile_top,
			},
			overlay_tiles = {
				tile_no_overlay, tile_no_overlay, tile_overlay, tile_overlay, tile_overlay, tile_overlay,
			},
			use_texture_alpha = "clip",
			paramtype = "light",
			paramtype2 = "color",
			palette = "unifieddyes_palette_extended.png",
			groups = {cracky = 2, ud_param2_colorable = 1},
			is_ground_content = false,
			sounds = default.node_sound_stone_defaults(),
			node_placement_prediction = "",
			after_place_node = tile1_after_place_node,
			on_dig = unifieddyes.on_dig,
		}
		minetest.register_node("ch_extras:tile1_onc_plaster_"..ldef.name, def)

		minetest.register_craft{
			output = "ch_extras:tile1_onc_plaster_"..ldef.name.." 2",
			recipe = {
				{"ch_extras:tile1", ""},
				{"solidcolor:plaster_"..ldef.name, ""},
			},
		}
		minetest.register_craft{
			output = "ch_extras:tile1_onc_plaster_"..ldef.name,
			recipe = {{"ch_extras:tile1_onc_plaster_"..ldef.name}},
		}
		minetest.register_craft{
			output = "ch_extras:tile1 2",
			recipe = {
				{"ch_extras:tile1_onc_plaster_"..ldef.name, "ch_extras:tile1_onc_plaster_"..ldef.name},
				{"", ""},
			},
			replacements = {
				{"ch_extras:tile1_onc_plaster_"..ldef.name, "solidcolor:plaster_"..ldef.name.." 2"},
			},
		}
	end
end

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

-- Scorched tree:

def = {
	description = "ohořelý kmen",
	tiles = {
		{name = "ch_extras_scorched_tree_top.png", backface_culling = true},
		{name = "ch_extras_scorched_tree_top.png", backface_culling = true},
		{name = "ch_extras_scorched_tree.png", backface_culling = true},
	},
	paramtype2 = "facedir",
	groups = {choppy = 2, tree = 1, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
	on_place = minetest.rotate_node,
}
minetest.register_node("ch_extras:scorched_tree", def)

minetest.register_craft{
	output = "ch_extras:scorched_tree",
	recipe = {
		{"group:tree", ""},
		{"default:torch", ""},
	},
}

minetest.register_craft{
	type = "fuel",
	recipe = "ch_extras:scorched_tree",
	burntime = 30,
}

def = {
	description = "plot z ohořelého kmene",
	texture = "ch_extras_scorched_tree.png",
	material = "ch_extras:scorched_tree",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	sounds = default.node_sound_wood_defaults(),
}
default.register_fence("ch_extras:scorched_tree_fence", table.copy(def))
def.description = "zábradlí z ohořelého kmene"
default.register_fence_rail("ch_extras:scorched_tree_fence_rail", table.copy(def))
def.description = "branka z ohořelého kmene"
doors.register_fencegate("ch_extras:scorched_tree_fence_gate", def)
default.register_mesepost("ch_extras:scorched_tree_mese_post_light", {
	description = "ohořelý sloupek s meseovým světlem",
	texture = "ch_extras_scorched_tree.png",
	material = "ch_extras:scorched_tree",
})

stairsplus:register_all("ch_extras", "scorched_tree", "ch_extras:scorched_tree", {
	description = "ohořelý kmen",
	tiles = {"ch_extras_scorched_tree.png"},
	groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 3},
})
stairsplus:register_noface_trunk("ch_extras", "scorched_tree_noface", "ch_extras:scorched_tree")
stairsplus:register_allfaces_trunk("ch_extras", "scorched_tree_allfaces", "ch_extras:scorched_tree")

-- Colorable fence

def = {
	description = "barvitelný plot",
	texture = "ch_extras_colorable_fence.png",
	material = "solidcolor:noise_block",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, ud_param2_colorable = 1},
	sounds = default.node_sound_wood_defaults(),
}
if not minetest.get_modpath("ch_npc") then
	def.texture = "default_fence_wood.png"
end

default.register_fence("ch_extras:colorable_fence", table.copy(def))
def.description = "barvitelné zábradlí"
default.register_fence_rail("ch_extras:colorable_fence_rail", table.copy(def))
def.description = "barvitelný plot: branka"
doors.register_fencegate("ch_extras:colorable_fence_gate_v1", def)

def = {
	paramtype2 = "color",
	palette = "unifieddyes_palette_extended.png",
	on_dig = unifieddyes.on_dig,
}
minetest.override_item("ch_extras:colorable_fence", def)
minetest.override_item("ch_extras:colorable_fence_rail", def)
def.paramtype2 = "color4dir"
def.palette = "unifieddyes_palette_color4dir.png"
for _, item in ipairs({"ch_extras:colorable_fence_gate_v1_open", "ch_extras:colorable_fence_gate_v1_closed"}) do
	def.groups = ch_core.override_groups(minetest.registered_nodes[item].groups, {ud_param2_colorable = 1})
	minetest.override_item(item, def)
end

-- regál na vracení šatů
def = {
	description = "regál na vracení šatů",
	drawtype = "nodebox",
	tiles = {{name = "default_wood.png^[transformR90^[colorize:#f0f0f0:192", backface_culling = true}},
	paramtype2 = "color4dir",
	palette = "unifieddyes_palette_color4dir.png",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.5 - 1/16, 0.5, 1.5, 0.5}, -- zadní stěna
			{-0.5, -0.5, 0.0, 0.5, -0.5 + 1 /16, 0.5 - 1/16}, -- spodní stěna
			{-0.5, 1.5 - 1/16, 0.0, 0.5, 1.5, 0.5 - 1/16}, -- horní stěna
			{-0.5, -0.5 + 1/16, 0.0, -0.5 + 1/16, 1.5 - 1/16, 0.5 - 1/16}, -- levá stěna
			{0.5 - 1/16, -0.5 + 1/16, 0.0, 0.5, 1.5 - 1/16, 0.5 - 1/16}, -- pravá stěna
			{-0.5 + 1/16, 1.2, 0.2, 0.5 - 1/16, 1.2 + 1/32, 0.2 + 1/16}, -- tyč
		},
	},
	groups = {oddly_breakable_by_hand = 2, ud_param2_colorable = 1, flammable = 2},
	is_ground_content = false,
	on_construct = function(pos)
		minetest.get_meta(pos):set_string("infotext", "vracení šatů a obuvi po vyzkoušení\n(pravý klik => dostanete zpět plnou cenu)")
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if not minetest.is_player(clicker) then
			return
		end
		local player_name = clicker:get_player_name()
		if itemstack:get_count() ~= 1 then
			return
		end
		local name = itemstack:get_name()
		if minetest.get_item_group(name, "clothing") == 0 and minetest.get_item_group(name, "cape") == 0 then
			return -- není oblečení
		end
		local meta = itemstack:get_meta()
		if meta:get_int("ch_buy_id") == 0 then
			ch_core.systemovy_kanal(player_name, "Tyto šaty nejsou označeny k vyzkoušení.")
			return
		end
		local now = ch_core.aktualni_cas().znamka32
		local buy_timestamp = meta:get_int("ch_buy_timestamp")
		if now - buy_timestamp > 600 then
			ch_core.systemovy_kanal(player_name, "Na vrácení je příliš pozdě. Tyto šaty byly vydány obchodním terminálem před "..math.floor((now - buy_timestamp) / 60).." minutami.")
			return
		end
		-- vrátit peníze
		local price = meta:get_int("ch_buy_price")
		if price > 0 then
			local success, errors = ch_core.pay_to(player_name, price, {label = "vrácení vyzkoušených šatů"})
			if not success then
				ch_core.systemovy_kanal(player_name, "Vrácení peněz selhalo.")
				minetest.log("warning", "ch_core.pay_to() failed to pay "..price.." to "..player_name.."!\n"..dump2(errors))
				return
			end
		end
		itemstack:get_meta():set_string("description", "")
		ch_core.systemovy_kanal(player_name, "Vráceno: "..(itemstack:get_description() or ""))
		return ItemStack()
	end,
}
minetest.register_node("ch_extras:vraceni_satu", def)
minetest.register_craft{
	output = "ch_extras:vraceni_satu",
	recipe = {
		{"homedecor:wardrobe", "default:mese_crystal_fragment"},
		{"default:mese_crystal_fragment", ""},
	},
}

-- pás na potvrzení nákupu šatů

local tile
if minetest.get_modpath("bakedclay") then
	tile = {name = "baked_clay_black.png", backface_culling = true}
else
	tile = {name = "default_clay.png", color = "#202020", backface_culling = true}
end

local fields = {
	"ch_buy_id",
	"ch_buy_price",
	"ch_buy_timestamp",
	"count_alignment",
	"count_meta",
	"description",
}

def = {
	description = "pás na potvrzení nákupu šatů",
	drawtype = "nodebox",
	tiles = {tile},
	paramtype2 = "leveled",
	node_box = {
		type = "leveled",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.5 + 2/16, 0.5},
	},
	groups = {cracky = 2},
	is_ground_content = false,
	place_param2 = 4,
	on_construct = function(pos)
		minetest.get_meta(pos):set_string("infotext", "potvrzení nákupu šatů a obuvi\n(pravý klik => potvrdíte nákup)")
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if not minetest.is_player(clicker) then
			return
		end
		local player_name = clicker:get_player_name()
		if itemstack:get_count() ~= 1 then
			return
		end
		local name = itemstack:get_name()
		if minetest.get_item_group(name, "clothing") == 0 and minetest.get_item_group(name, "cape") == 0 then
			return -- není oblečení
		end
		local meta = itemstack:get_meta()
		if meta:get_int("ch_buy_id") == 0 then
			ch_core.systemovy_kanal(player_name, "Tyto šaty nejsou označeny k vyzkoušení.")
			return
		end
		local meta_table = meta:to_table()
		local meta_fields = meta_table.fields
		for _, key in ipairs(fields) do
			meta_fields[key] = nil
		end
		meta:from_table(meta_table)
		ch_core.systemovy_kanal(player_name, "Nákup potvrzen: "..(itemstack:get_description() or ""))
		return itemstack
	end,
}

minetest.register_node("ch_extras:potvrzeni_nakupu_satu", def)

minetest.register_craft{
	output = "ch_extras:potvrzeni_nakupu_satu",
	recipe = {
		{"bakedclay:black", "bakedclay:black"},
		{"", ""},
	},
}


-- ch_extras:nehodiv
---------------------------------------------------------------
def = {
	description = "nehodivský mramor",
	tiles = {{name = "ch_extras_nehodiv.png"}},
	groups = {cracky = 2, stone = 1},
}

minetest.register_node("ch_extras:marble", table.copy(def))
minetest.register_alias("jonez:marble", "ch_extras:marble")

stairsplus:register_all("ch_extras", "marble", "ch_extras:marble", def)

-- ch_extras:shaft
---------------------------------------------------------------
def = {
	description = "dřík kamenného sloupu",
	tiles = {
		{name = "ch_extras_shaft_top.png"},
		{name = "ch_extras_shaft_top.png"},
		{name = "ch_extras_shaft.png"},
	},
	paramtype2 = "colorwallmounted",
	palette = "unifieddyes_palette_colorwallmounted.png",
	groups = {cracky = 3, ud_param2_colorable = 1},
	is_ground_content = false,
	on_construct = unifieddyes.on_construct,
	on_dig = unifieddyes.on_dig,
}

minetest.register_node("ch_extras:shaft", def)
