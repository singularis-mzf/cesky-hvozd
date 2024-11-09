local def, nbox

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

-- legacy:
if not minetest.get_modpath("mirrors") then
    minetest.register_alias("mirrors:mirror", "ch_extras:mirror")
end
