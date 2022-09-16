ch_core.open_submod("nodes")

local def

-- ch_core.light_{0..15}
---------------------------------------------------------------
local box = {
	type = "fixed",
	fixed = {-1/16, -8/16, -1/16, 1/16, -7/16, 1/16}
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
	def.description = "administrátorské světlo "..i
	if i > 0 then
		def.groups = {ch_core_light = i}
		def.light_source = i
	end
	minetest.register_node("ch_core:"..name, table.copy(def))
	if i > 0 and minetest.get_modpath("wielded_light") then
		wielded_light.register_item_light("ch_core:"..name, i, false)
	end
end
minetest.register_alias("ch_core:light_max", "ch_core:light_"..minetest.LIGHT_MAX)

ch_core.close_submod("nodes")
