--[[ Placeable Books by everamzah
	Copyright (C) 2016 James Stevenson
	Copyright (C) 2023 Singularis
	LGPLv2.1+
	See LICENSE for more information ]]

ch_core.clear_crafts("books", {
	{output = "default:book"},
	-- {output = "default:bookshelf"},
})
-- minetest.unregister_item("default:book")
-- minetest.unregister_item("default:book_written")

minetest.override_item("default:book", {
	groups = {not_in_creative_inventory = 1},
	description = "[zastaralý předmět!]",
})

minetest.register_craft{
	output = "books:book_b5_closed_grey",
	recipe = {
		{"default:paper", "default:paper", ""},
		{"default:paper", "default:paper", ""},
		{"default:paper", "default:paper", ""},
	},
}
minetest.register_craft{
	output = "books:book_b6_closed_grey",
	recipe = {
		{"default:paper", "default:paper"},
		{"default:paper", "default:paper"},
	},
}

--[[
local colors = unifieddyes.HUES_WITH_GREY
for _, hue in ipairs(unifieddyes.HUES_WITH_GREY) do
	local name = "books:book_b5_closed_"..hue
	minetest.register_craft({output = name, recipe = {{name}}})
	name = "books:book_b6_closed_"..hue
	minetest.register_craft({output = name, recipe = {{name}}})
end
]]
