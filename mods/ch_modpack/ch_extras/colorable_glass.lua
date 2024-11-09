-- BAREVNÉ SKLO

local epsilon = 0.001
local e2 = 1 / 16
local def

local function box(x_min, x_max, y_min, y_max, z_min, z_max)
	local result = {x_min or -0.5, y_min or -0.5, z_min or -0.5, x_max or 0.5, y_max or 0.5, z_max or 0.5}
	if result[1] > result[4] or result[2] > result[5] or result[3] > result[6] then
		error("Invalid box generated: "..dump2({x_min = x_min, x_max = x_max, y_min = y_min, y_max = y_max, z_min = z_min, z_max = z_max, result = result}))
	end
	return result
end

-- FULL
--[[
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
]]

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
--[[
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
]]

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
def.groups = ch_core.assembly_groups(colorable_glass_common_groups, {ch_colored_glass_full = 1})
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
def.groups = ch_core.assembly_groups(colorable_glass_common_groups, {ch_colored_glass_full = 1})
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
local slab_groups = ch_core.assembly_groups(colorable_glass_common_groups, {ch_colored_glass_slab = 1, walldir = 1})
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
odef.groups = ch_core.assembly_groups(def.groups, {not_in_creative_inventory = 1})
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
odef.groups = ch_core.assembly_groups(slab_groups, {not_in_creative_inventory = 1})
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
