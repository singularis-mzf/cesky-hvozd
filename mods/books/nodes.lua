--[[ Placeable Books by everamzah
	Copyright (C) 2016 James Stevenson
	Copyright (C) 2023 Singularis
	LGPLv2.1+
	See LICENSE for more information ]]

local S = minetest.get_translator("books")

local after_place_node = books.after_place_node
local preserve_metadata = books.preserve_metadata
local on_punch = books.on_punch
local on_use = books.on_use
local closed_on_rightclick = books.closed_on_rightclick
local open_on_rightclick = books.open_on_rightclick

local groups_common = {
	snappy = 3, ud_param2_colorable = 1, not_in_creative_inventory = 1
}
local groups_open_b5 = table.copy(groups_common)
local groups_closed_b5 = table.copy(groups_common)
groups_open_b5.book = 5
groups_open_b5.book_open = 1
groups_closed_b5.book = 5
groups_closed_b5.book_closed = 1
groups_closed_b5.oddly_breakable_by_hand = 3
local groups_open_b6 = table.copy(groups_open_b5)
local groups_closed_b6 = table.copy(groups_closed_b5)
groups_open_b6.book = 6
groups_closed_b6.book = 6

local node_box_open = {
	type = "fixed",
		fixed = {
			{-0.375, -0.47, -0.282, 0.375, -0.4125, 0.282}, -- Top
			{-0.4375, -0.5, -0.3125, 0.4375, -0.47, 0.3125},
		}
}
local node_box_closed = {
	type = "fixed",
	fixed = {
		{-0.25, -0.5, -0.3125, 0.25, -0.35, 0.3125},
	}
}

local def_common = {
	use_texture_alpha = "opaque",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "colorfacedir",
	-- palette = "unifieddyes_palette_greys.png",
	sunlight_propagates = true,
	stack_max = 1,
	preserve_metadata = preserve_metadata,
	on_use = on_use,
	sounds = default.node_sound_leaves_defaults(),
}

local def_open = {
	description = "kniha B5",
	tiles = {
		"books_book_open_top.png",	-- Top
		"books_book_open_bottom.png",	-- Bottom
		"books_book_open_side.png",	-- Right
		"books_book_open_side.png",	-- Left
		"books_book_open_front.png",	-- Back
		"books_book_open_front.png"	-- Front
	},
	overlay_tiles = {
		{name = "books_book_open_top_overlay.png", color = "white"},	-- Top
		"",	-- Bottom
		{name = "books_book_open_side_overlay.png", color = "white"},	-- Right
		{name = "books_book_open_side_overlay.png", color = "white"},	-- Left
		{name = "books_book_open_front_overlay.png", color = "white"},	-- Back
		{name = "books_book_open_front_overlay.png", color = "white"},	-- Front
	},
	airbrush_replacement_node = "books:book_open_grey",
	node_box = node_box_open,
	groups = groups_open_b5,
	on_dig = unifieddyes.on_dig,
	on_punch = on_punch, -- close the book
	on_rightclick = open_on_rightclick, -- edit the book
}

local def_closed = {
	description = "kniha B5",
	tiles = {
		"books_book_closed_topbottom.png",	-- Top
		"books_book_closed_topbottom.png",	-- Bottom
		"books_book_closed_right.png",	-- Right
		"books_book_closed_left.png",	-- Left
		"books_book_closed_front.png^[transformFX",	-- Back
		"books_book_closed_front.png"	-- Front
	},
	overlay_tiles = {
		"", -- Top
		"", -- Bottom
		{name = "books_book_closed_right_overlay.png", color = "white"}, -- Right
		"", -- Left
		{name = "books_book_closed_front_overlay.png^[transformFX", color = "white"}, -- Back
		{name = "books_book_closed_front_overlay.png", color = "white"}, -- Front
	},
	node_box = node_box_closed,
	groups = groups_closed_b5,
	on_rightclick = closed_on_rightclick,
	after_place_node = after_place_node,
}

for k, v in pairs(def_common) do
	def_open[k] = def_open[k] or v
	def_closed[k] = def_closed[k] or v
end

-- minetest.register_node("books:book_open_grey", def)
unifieddyes.generate_split_palette_nodes("books:book_b5_open", table.copy(def_open))
unifieddyes.generate_split_palette_nodes("books:book_b5_closed", table.copy(def_closed))
local groups2 = table.copy(groups_closed_b5)
groups2.not_in_creative_inventory = nil
minetest.override_item("books:book_b5_closed_grey", {groups = groups2})

def_open.node_box = nil
def_open.drawtype = "mesh"
def_open.mesh = "homedecor_book_open.obj"
def_open.selection_box = {
	type = "fixed",
	fixed = {-0.35, -0.5, -0.25, 0.35, -0.4, 0.25}
}
def_open.tiles = {
	{name = "homedecor_book_cover.png", backface_culling = true},
	{name = "homedecor_book_edges.png", color = "white", backface_culling = true},
	{name = "homedecor_book_pages.png", color = "white", backface_culling = true}
}
def_open.overlay_tiles = nil
def_open.groups = groups_open_b6
def_open.description = "kniha B6"

def_closed.node_box = nil
def_closed.drawtype = "mesh"
def_closed.mesh = "homedecor_book.obj"
def_closed.selection_box = {
	type = "fixed",
	fixed = {-0.2, -0.5, -0.25, 0.2, -0.35, 0.25}
}
def_closed.tiles = {
	{name = "homedecor_book_cover.png", backface_culling = true},
	{name = "homedecor_book_edges.png", color = "white", backface_culling = true},
}
def_closed.overlay_tiles = {
	{name = "homedecor_book_cover_trim.png", color = "white", backface_culling = true},
	"",
}
def_closed.groups = groups_closed_b6
def_closed.description = "kniha B6"

unifieddyes.generate_split_palette_nodes("books:book_b6_open", def_open)
unifieddyes.generate_split_palette_nodes("books:book_b6_closed", def_closed)
groups2 = table.copy(groups_closed_b6)
groups2.not_in_creative_inventory = nil
minetest.override_item("books:book_b6_closed_grey", {groups = groups2})

if minetest.settings:get_bool("books.editor", true) then
	minetest.register_privilege("editor", S("Allow player to edit books with the Admin Pencil"))

	minetest.register_craftitem("books:admin_pencil", {
		description = S("Admin Pencil"),
		inventory_image = "books_admin_pencil.png",
	})

	--[[ MAKE IT EXPENSIVE
	minetest.register_craft({
		output = "books:admin_pencil",
		recipe = {
			{"group:stick"},
			{"default:mese_crystal_fragment"},
			{"default:obsidian_shard"},
		}
	}) ]]
end
