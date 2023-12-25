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

--[[
if minetest.settings:get_bool("books.editor", true) then
	minetest.register_privilege("editor", S("Allow player to edit books with the Admin Pencil"))

	minetest.register_craftitem("books:admin_pencil", {
		description = S("Admin Pencil"),
		inventory_image = "books_admin_pencil.png",
	})
]]
	--[[ MAKE IT EXPENSIVE
	minetest.register_craft({
		output = "books:admin_pencil",
		recipe = {
			{"group:stick"},
			{"default:mese_crystal_fragment"},
			{"default:obsidian_shard"},
		}
	}) ]]
--end

local function lm_on_constuct(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_size("input", 1)
	inv:set_size("paper", 4)
	inv:set_size("dye", 4)
	inv:set_size("output", 8)
end

local function lm_get_formspec(pos)
	local spos = pos.x.."\\,"..pos.y.."\\,"..pos.z
	local formspec = {
		"formspec_version[6]",
		"size[14,13.5]",
		default.gui_bg,
		default.gui_bg_img,
		"item_image[0.375,0.375;1,1;books:machine]",
		"label[1.6,0.9;Knihovní stroj]",
		"button_exit[13,0.25;0.75,0.75;zavrit;X]",
		"label[0.5,2.5;Vstup (kniha):]",
		"list[nodemeta:", spos, ";input;2.5,2;1,1;]",
		"label[0.5,3.75;Papír:]",
		"list[nodemeta:", spos, ";paper;2.5,3.25;4,1;]",
		"label[0.5,5;Černá barva:]",
		"list[nodemeta:", spos, ";dye;2.5,4.5;4,1;]",
		"label[0.5,6.25;Výstup:]",
		"list[nodemeta:", spos, ";output;2.5,5.75;8,1;]",
		"label[0.5,7.5;Inventář:]",
		"list[current_player;main;2.5,8;8,4;]",
		"label[3.75,2.5;Vydání:]",
		"field[5,2.25;2.5,0.5;edition;;1. vyd.]",
		"button[7.75,2.15;5.5,0.75;vydat;permanentně vydat knihu]",
		"button[7.75,3;5.5,0.75;kopie;kopírovat knihu, jak je]",
		"button[7.75,3.85;5.5,0.75;upravit;získat upravitelnou kopii vydané knihy]",
	}
	-- button[7.75,4.7;5.5,0.75;test;test]
	-- label[2.5,7.5;Chyba: Nastala neznámá chyba.]
	return table.concat(formspec)
end

local function lm_formspec_callback(custom_state, player, formname, fields)

end

local function lm_on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	local player_name = clicker and clicker:get_player_name()
	if not player_name then
		return itemstack
	end
	local formspec = lm_get_formspec(pos)
	ch_core.show_formspec(clicker, "books:machine", formspec, lm_formspec_callback, {}, {})
	return itemstack
end

local function lm_allow_metadata_inventory_player(player)
	local role = ch_core.get_player_role(player)
	return role ~= nil and role ~= "new"
end

local function lm_allow_metadata_inventory_put(pos, listname, index, stack, player)
	if not lm_allow_metadata_inventory_player(player) then
		return 0
	end
	local name = stack:get_name()
	if listname == "input" then
		-- only books are allowed
		if minetest.get_item_group(name, "book") == 0 then
			return 0
		end
	elseif listname == "dye" then
		-- only black dye is allowed
		if name ~= "dye:black" then
			return 0
		end
	elseif listname == "paper" then
		-- only paper is allowed
		if name ~= "default:paper" then
			return 0
		end
	elseif listname == "output" then
		return 0 -- only output
	end
	return stack:get_count()
end

local function lm_allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local inv = minetest.get_meta(pos):get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	stack:set_count(count)
	return lm_allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function lm_allow_metadata_inventory_take(pos, listname, index, stack, player)
	if not lm_allow_metadata_inventory_player(player) then
		return 0
	end
	return stack:get_count()
end

local def = {
	description = S("Library Machine"),
	tiles = {
		{name = "ch_core_white_pixel.png", backface_culling = true},
	},
	param2 = "facedir",
	groups = {cracky = 1},
	sounds = default.node_sound_defaults(),
	allow_metadata_inventory_move = lm_allow_metadata_inventory_move,
	allow_metadata_inventory_put = lm_allow_metadata_inventory_put,
	allow_metadata_inventory_take = lm_allow_metadata_inventory_take,
	on_construct = lm_on_constuct,
	on_rightclick = lm_on_rightclick,
}

minetest.register_node("books:machine", def)
