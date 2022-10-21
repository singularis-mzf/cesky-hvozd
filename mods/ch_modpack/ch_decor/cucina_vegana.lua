local S = minetest.get_translator("ch_decor")

minetest.register_node(":cucina_vegana:mushroomlight_glass", {
	description = S("sklo s motivem hub"),
	drawtype = "glasslike_framed_optional",
	tiles = {"cucina_vegana_mushroom_light.png","cucina_vegana_mushroom_light_detail.png"},
	paramtype = "light",
	light_source = 1,
	paramtype2 = "glasslikeliquidlevel",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_glass_defaults()
})

local clean_glass = "moreblocks:clean_glass"
local dye = "dye:amber" -- from unifieddyes

minetest.register_craft({
	output = "cucina_vegana:mushroomlight_glass 4",
	recipe = {
		{clean_glass, dye, clean_glass},
		{"", clean_glass, ""},
		{"", clean_glass, ""},
	},
})
