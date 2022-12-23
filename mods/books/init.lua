--[[ Placeable Books by everamzah
	Copyright (C) 2016 James Stevenson
	LGPLv2.1+
	See LICENSE for more information ]]

-- Translation support
local S = minetest.get_translator("books")
local F = minetest.formspec_escape

local lpp = 14 -- Lines per book's page

local function copy_book_metadata(frommeta, tometa)
	tometa:set_string("owner", frommeta:get_string("owner"))
	tometa:set_string("title", frommeta:get_string("title"))
	tometa:set_string("text", frommeta:get_string("text"))
end

-- if pos is nil, expects that the wielded item is a book and edit it
local function get_book_formspec(player_name, pos)
	-- Courtesy of minetest_game/mods/default/craftitems.lua
	local meta, owner, title, text --, page, page_max, lines, string

	local player = minetest.get_player_by_name(player_name)
	local wielded_item = player and player:get_wielded_item()

	if wielded_item == nil then
		minetest.log("warning", "get_book_formspec(): not a player!")
		return -- not a player
	end

	if pos ~= nil then
		meta = minetest.get_meta(pos)
	elseif minetest.get_item_group(wielded_item:get_name(), "book") > 0 then
		meta = wielded_item:get_meta()
	else
		return -- not a book
	end

	owner = meta:get_string("owner")
	if owner == "" then
		owner = player_name
	end
	title = meta:get_string("title")
	text = meta:get_string("text")

	local formspec = {
		"size[8,8]",
		default.gui_bg,
		default.gui_bg_img,
	}
	if owner == player_name or wielded_item:get_name() == "books:admin_pencil" then
		table.insert(formspec, "field[-4,-4;0,0;owner;"..F(S("Owner:"))..";" .. ch_core.prihlasovaci_na_zobrazovaci(owner) .. "]")
		table.insert(formspec, "field[0.5,1;7.5,0;title;"..F(S("Title:"))..";" .. F(title) .. "]")
		table.insert(formspec, "textarea[0.5,1.5;7.5,7;text;"..F(S("Contents:"))..";" .. F(text) .. "]")
		table.insert(formspec, "button_exit[2.5,7.5;3,1;save;"..F(S("Save")).."]")
	else
		local page, page_max
		local lines = {}
		for str in (text .. "\n"):gmatch("([^\n]*)[\n]") do
			table.insert(lines, str)
		end

		local page = meta:get_int("page")
		local string = ""
		if page > 0 then
			page_max = meta:get_int("page_max")
			for i = (lpp * page - lpp + 1), lpp * page do
				if lines[i] == nil then break end
				string = string..lines[i].."\n"
			end
		else
			page = 1
			page_max = 1
		end

		table.insert(formspec, "label[0.5,0.5;by " .. ch_core.prihlasovaci_na_zobrazovaci(owner) .. "]")
		table.insert(formspec, "tablecolumns[color;text]")
		table.insert(formspec, "tableoptions[background=#00000000;highlight=#00000000;border=false]")
		table.insert(formspec, "table[0.4,0;7,0.5;title;#FFFF00," .. F(title) .. "]")
		table.insert(formspec, "textarea[0.5,1.5;7.5,7;;" ..F(string ~= "" and string or text) .. ";]")
		table.insert(formspec, "button[2.4,7.6;0.8,0.8;book_prev;<]")
		table.insert(formspec, "label[3.2,7.7;"..F(S("Page @1 of @2", page, page_max)) .. "]")
		table.insert(formspec, "button[4.9,7.6;0.8,0.8;book_next;>]")
	end
	return table.concat(formspec)
end

local function compute_infotext(book_meta)
	local meta = book_meta
	if meta:get_string("owner") ~= "" then
		return S("@1\n\nby @2", meta:get_string("title"), ch_core.prihlasovaci_na_zobrazovaci(meta:get_string("owner")))
	else
		return ""
	end
end

local function update_infotext(book_meta)
	book_meta:set_string("infotext", compute_infotext(book_meta))
end

local function open_book(pos)
	local node = minetest.get_node(pos)
	if minetest.get_item_group(node.name, "book_closed") == 0 then
		return false
	end
	node.name = node.name:gsub("_closed", "_open")
	minetest.swap_node(pos, node)
	local meta = minetest.get_meta(pos)
	meta:set_string("infotext", meta:get_string("text"))
	return true
end

local function close_book(pos)
	local node = minetest.get_node(pos)
	if minetest.get_item_group(node.name, "book_open") == 0 then
		return false
	end
	node.name = node.name:gsub("_open", "_closed")
	minetest.swap_node(pos, node)
	update_infotext(minetest.get_meta(pos))
	return true
end

local function formspec_callback(custom_state, player, formname, fields)
	local owner = custom_state.owner
	local pos = custom_state.pos
	local item
	local meta
	if pos == nil then
		item = player:get_wielded_item()
		meta = item:get_meta()
	else
		meta = minetest.get_meta(pos)
	end

	if fields.save and fields.title ~= "" and fields.text ~= "" then
		meta:set_string("title", fields.title)
		meta:set_string("text", fields.text)
		meta:set_string("owner", owner)
		meta:set_int("text_len", fields.text:len())
		meta:set_int("page", 1)
		meta:set_int("page_max", math.ceil((fields.text:gsub("[^\n]", ""):len() + 1) / lpp))

		if pos == nil then
			-- item
			meta:set_string("description", compute_infotext(meta))
			player:set_wielded_item(item)
		else
			-- node (open book)
			meta:set_string("infotext", fields.text)
		end
	elseif fields.book_next or fields.book_prev then
		if fields.book_next then
			meta:set_int("page", meta:get_int("page") + 1)
			if meta:get_int("page") > meta:get_int("page_max") then
				meta:set_int("page", 1)
			end
		elseif fields.book_prev then
			meta:set_int("page", meta:get_int("page") - 1)
			if meta:get_int("page") == 0 then
				meta:set_int("page", meta:get_int("page_max"))
			end
		end

		if pos == nil then
			player:set_weilded_item(item)
		end

		return get_book_formspec(player:get_player_name(), pos)
	end
end

local function closed_on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	open_book(pos)
end

local function open_on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	if clicker then
		local player_name = clicker:get_player_name()
		local formspec = get_book_formspec(player_name, pos)
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		if owner == "" then
			owner = clicker:get_player_name()
		end
		ch_core.show_formspec(clicker, "books:book", formspec, formspec_callback, {
			type = "pos",
			pos = pos,
			owner = owner,
		}, {})
	end
end

local function on_punch(pos, node, puncher, pointed_thing)
	close_book(pos)
end

-- minetest.override_item("default:book", override)
-- minetest.override_item("default:book_written", override)

local function preserve_metadata(pos, oldnode, oldmeta, drops)
	local item = drops[1]
	if item == nil then
		return
	end
	if drops[2] ~= nil then
		minetest.log("warning", "preserve_metadata() called for a book, but drops contains more than one item: "..dump2(drops))
	end

	local itemname = item:get_name()
	if minetest.get_item_group(itemname, "book_closed") == 0 then
		minetest.log("warning", "Openned book "..itemname.." was dug!")
		item:set_name(itemname:gsub("_open", "_closed"))
	end

	local itemmeta = item:get_meta()
	itemmeta:set_string("owner", oldmeta.owner or "")
	itemmeta:set_string("title", oldmeta.title or "")
	itemmeta:set_string("text", oldmeta.text or "")
	itemmeta:set_string("description", compute_infotext(itemmeta))
end

local function after_place_node(pos, placer, itemstack, pointed_thing)
	local itemmeta = itemstack:get_meta()
	if itemmeta then
		local nodemeta = minetest.get_meta(pos)
		nodemeta:from_table(itemmeta:to_table())
		update_infotext(nodemeta)
	end
end

local function on_use(itemstack, user, pointed_thing)
	local player_name = user and user:get_player_name()
	if player_name then
		local meta = itemstack:get_meta()
		local owner = meta:get_string("owner")
		if owner == "" then
			owner = player_name
		end
		local formspec = get_book_formspec(player_name)
		if formspec ~= nil then
			ch_core.show_formspec(user, "books:book", formspec, formspec_callback, {
				type = "item",
				owner = owner,
			}, {})
			return itemstack
		end
	end
end

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

-- CRAFTS
ch_core.clear_crafts("books", {
	{output = "default:book"},
	{output = "default:bookshelf"},
})
-- minetest.unregister_item("default:book")
-- minetest.unregister_item("default:book_written")

minetest.override_item("default:book", {
	groups = {not_in_creative_inventory = 1},
	description = "[zastaralý předmět!]",
})

minetest.register_craft({
	output = "books:book_b5_closed_grey",
	recipe = {
		{"default:paper", "default:paper", ""},
		{"default:paper", "default:paper", ""},
		{"default:paper", "default:paper", ""},
	},
})
minetest.register_craft({
	output = "books:book_b6_closed_grey",
	recipe = {
		{"default:paper", "default:paper"},
		{"default:paper", "default:paper"},
	},
})

--[[
local colors = unifieddyes.HUES_WITH_GREY
for _, hue in ipairs(unifieddyes.HUES_WITH_GREY) do
	local name = "books:book_b5_closed_"..hue
	minetest.register_craft({output = name, recipe = {{name}}})
	name = "books:book_b6_closed_"..hue
	minetest.register_craft({output = name, recipe = {{name}}})
end
]]
