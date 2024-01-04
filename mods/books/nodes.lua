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

local function union(a, b, c, d, e)
	local result = {}
	if a ~= nil then
		for k, v in pairs(a) do
			result[k] = v
		end
	end
	if b ~= nil then
		for k, v in pairs(b) do
			result[k] = v
		end
	end
	if c ~= nil then
		for k, v in pairs(c) do
			result[k] = v
		end
	end
	if d ~= nil then
		for k, v in pairs(d) do
			result[k] = v
		end
	end
	if e ~= nil then
		error("So many arguments not supported!")
	end
	return result
end

-- Groups:
local groups_common = {
	not_in_creative_inventory = 1,
	snappy = 3,
	ud_param2_colorable = 1,
}
local groups_open = {
	book_open = 1,
}
local groups_closed = {
	book_closed = 1,
	oddly_breakable_by_hand = 3,
}
local groups_b5 = {
	book = 5
}
local groups_b6 = {
	book = 6
}

local def_common = {
	use_texture_alpha = "opaque",
	paramtype = "light",
	paramtype2 = "colorfacedir",
	-- palette = "unifieddyes_palette_greys.png",
	sunlight_propagates = true,
	stack_max = 1,
	preserve_metadata = preserve_metadata,
	on_dig = unifieddyes.on_dig,
	on_use = on_use,
	sounds = default.node_sound_leaves_defaults(),
}
local def_open = {
	on_punch = on_punch, -- close the book
	on_rightclick = open_on_rightclick, -- edit the book
}
local def_closed = {
	after_place_node = after_place_node,
	on_rightclick = closed_on_rightclick,
}
local def_b5 = {
	description = "kniha B5",
	drawtype = "nodebox",
	inventory_image = "books_book_b5_inv.png",
	inventory_overlay = "books_book_b5_inv_overlay.png",
	wield_image = "books_book_b5_inv.png",
	wield_overlay = "books_book_b5_inv_overlay.png",
}
local def_b6 = {
	description = "kniha B6",
	drawtype = "mesh",
	inventory_image = "books_book_b6_inv.png",
	inventory_overlay = "books_book_b6_inv_overlay.png",
	wield_image = "books_book_b6_inv.png",
	wield_overlay = "books_book_b6_inv_overlay.png",
}



-- B5 open books:
-- ======================================================
local def_b5_open = {
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
	-- ? airbrush_replacement_node = "books:book_open_grey",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.47, -0.282, 0.375, -0.4125, 0.282}, -- Top
			{-0.4375, -0.5, -0.3125, 0.4375, -0.47, 0.3125},
		},
	},
	groups = union(groups_common, groups_open, groups_b5),
}
def_b5_open = union(def_common, def_open, def_b5, def_b5_open)

-- B5 closed books:
-- ======================================================
local def_b5_closed = {
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
	node_box = {
		type = "fixed",
		fixed = {
			{-0.25, -0.5, -0.3125, 0.25, -0.35, 0.3125},
		},
	},
	groups = union(groups_common, groups_closed, groups_b5),
}
def_b5_closed = union(def_common, def_closed, def_b5, def_b5_closed)

-- B6 open books:
-- ======================================================
local box = {
	type = "fixed",
	fixed = {-0.35, -0.5, -0.25, 0.35, -0.4, 0.25}
}
local def_b6_open = {
	mesh = "homedecor_book_open.obj",
	tiles = {
		{name = "homedecor_book_cover.png", backface_culling = true},
		{name = "homedecor_book_edges.png", color = "white", backface_culling = true},
		{name = "homedecor_book_pages.png", color = "white", backface_culling = true},
	},
	selection_box = box,
	collision_box = box,
	groups = union(groups_common, groups_open, groups_b6),
}
def_b6_open = union(def_common, def_open, def_b6, def_b6_open)

-- B6 closed books:
-- ======================================================
box = {
	type = "fixed",
	fixed = {-0.2, -0.5, -0.25, 0.2, -0.35, 0.25}
}
local def_b6_closed = {
	mesh = "homedecor_book.obj",
	tiles = {
		{name = "homedecor_book_cover.png", backface_culling = true},
		{name = "homedecor_book_edges.png", color = "white", backface_culling = true},
	},
	overlay_tiles = {
		{name = "homedecor_book_cover_trim.png", color = "white", backface_culling = true},
		"",
	},
	selection_box = box,
	collision_box = box,
	groups = union(groups_common, groups_closed, groups_b6),
}
def_b6_closed = union(def_common, def_closed, def_b6, def_b6_closed)

unifieddyes.generate_split_palette_nodes("books:book_b5_open", def_b5_open)
unifieddyes.generate_split_palette_nodes("books:book_b5_closed", def_b5_closed)
unifieddyes.generate_split_palette_nodes("books:book_b6_open", def_b6_open)
unifieddyes.generate_split_palette_nodes("books:book_b6_closed", def_b6_closed)

local items_to_creative_inventory = {
	["books:book_b5_closed_grey"] = true,
	["books:book_b6_closed_grey"] = true,
}

-- Overrides (palette, not_in_creative_inventory):
-- ======================================================
for _, prefix in ipairs({"books:book_"}) do
	local hue_names = {
		"red",
		"vermilion",
		"orange",
		"amber",
		"yellow",
		"lime",
		"chartreuse",
		"harlequin",
		"green",
		"malachite",
		"spring",
		"turquoise",
		"cyan",
		"cerulean",
		"azure",
		"sapphire",
		"blue",
		"indigo",
		"violet",
		"mulberry",
		"magenta",
		"fuchsia",
		"rose",
		"crimson",
		"grey",
	}
	local palette_to_override = {}
	for _, infix in ipairs({"b5_open", "b5_closed", "b6_open", "b6_closed"}) do
		for _, hue in ipairs(hue_names) do
			local name = prefix..infix.."_"..hue
			local ndef = minetest.registered_nodes[name]
			if ndef == nil then
				error(name.."does not exist!")
			end
			local current_palette = ndef.palette
			if current_palette == nil then
				error(name.." has no palette!")
			end
			local override = palette_to_override[current_palette]
			if override == nil then
				override = {
					_ch_ud_palette = current_palette,
					palette = "unifieddyes_palette_bright_"..hue.."s.png"
				}
				palette_to_override[current_palette] = override
			end
			if items_to_creative_inventory[name] then
				override = table.copy(override)
				override.groups = table.copy(ndef.groups)
				override.groups.not_in_creative_inventory = nil
			end
			minetest.override_item(name, override)
		end
	end
end
