--[[
--==========================================
-- Candles mod by darkrose
-- Copyright (C) Lisa Milne 2013 <lisa@ltmnet.com>
-- Code: GPL version 2
-- http://www.gnu.org/licenses/>
--==========================================
--]]

minetest.register_node("church_candles:candle_flame", {
	description = "plamen svíčky",
	drawtype = "plantlike",
	tiles = {
		{
			name = "church_candles_candle_flame.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			},
		},
	},
	paramtype = "light",
	light_source = 12,
	walkable = false,
	buildable_to = false,
	pointable = false,
	sunlight_propagates = true,
	damage_per_second = 1,
	groups = {torch = 1, dig_immediate = 3},
	drop = "",
})

minetest.register_node("church_candles:candelabra_flame", {
	description = "plamen svícnu",
	drawtype = "plantlike",
		tiles = {
		{
			name = "church_candles_candelabra_flame.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			},
		},
	},
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 1,
	light_source = 14,
	walkable = false,
	buildable_to = false,
	pointable = false,
	sunlight_propagates = true,
	damage_per_second = 1,
	groups = {torch = 1, dig_immediate = 3},
	drop = "",
	})
