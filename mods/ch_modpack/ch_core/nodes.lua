ch_core.open_submod("nodes")

local def

-- ch_core.light_{0..15}
---------------------------------------------------------------
local box = {
	type = "fixed",
	fixed = {{-1/16, -8/16, -1/16, 1/16, -7/16, 1/16}}
}
def = {
	description = "0",
	drawtype = "nodebox",
	node_box = box,
	selection_box = box,
	-- top, bottom, right, left, back, front
	tiles = {"ch_core_white_pixel.png^[opacity:0"},
	use_texture_alpha = "clip",
	inventory_image = "default_invisible_node_overlay.png",
	wield_image = "default_invisible_node_overlay.png",
	paramtype = "light",
	paramtype2 = "none",
	light_source = 0,

	sunlight_propagates = true,
	walkable = false,
	pointable = true,
	buildable_to = true,
	floodable = true,
	drop = ""
}

for i = 0, minetest.LIGHT_MAX do
	local name = "light_"
	if i < 10 then
		name = name.."0"
	end
	name = name..i
	def.description = string.format("administrátorské světlo %02d", i)
	if i > 0 then
		def.groups = {ch_core_light = i}
		def.light_source = i
	end
	local image = "ch_core_white_pixel.png^[resize:16x16^[multiply:#eeeeaa^[colorize:#000000:"..math.floor((minetest.LIGHT_MAX - i) / minetest.LIGHT_MAX * 255).."^default_invisible_node_overlay.png^ch_core_"..math.min(i, 15)..".png"
	def.inventory_image = image
	def.wield_image = image

	minetest.register_node("ch_core:"..name, table.copy(def))
	if i > 0 and minetest.get_modpath("wielded_light") then
		wielded_light.register_item_light("ch_core:"..name, i, false)
	end
end
minetest.register_alias("ch_core:light_max", "ch_core:light_"..minetest.LIGHT_MAX)

-- Glass overrides:

local tex_edge = "ch_core_white_pixel.png^[multiply:#bbbbbb"
local tex_glass = "ch_core_white_pixel.png^[opacity:40"
local tex_framedglass = tex_glass.."^[resize:32x32^(ch_core_white_frame32.png^[multiply:#bbbbbb)"
local tile_edge = {name = tex_edge, backface_culling = true}
local tile_framedglass = {name = tex_framedglass, backface_culling = true}


-- DEBUG test:
tile_framedglass.name = tex_glass



core.override_item("default:glass", {
	tiles = {tex_framedglass, tex_glass},
	use_texture_alpha = "blend",
})


local override = {use_texture_alpha = "blend"}
for _, c in ipairs({"a", "b", "c", "d", "cd_a", "cd_b", "cd_c", "cd_d"}) do
	local n = "doors:door_glass_"..c
	if core.registered_nodes[n] ~= nil then
		core.override_item(n, override)
	end
end

for _, n in ipairs({"xpanes:pane_flat", "xpanes:pane"}) do
	local t = assert(core.registered_nodes[n].tiles)
	for i, tile in ipairs(t) do
		if type(tile) == "string" and tile == "default_glass.png" then
			t[i] = "ch_core_white_pixel.png^[opacity:20^[resize:32x32^(ch_core_white_frame32.png^[multiply:#bbbbbb)"
		end
	end
	core.override_item(n, {tiles = t, use_texture_alpha = "blend"})
end

ch_core.close_submod("nodes")
