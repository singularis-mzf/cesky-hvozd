--[[ Placeable Books by everamzah
	Copyright (C) 2016 James Stevenson
	Copyright (C) 2023 Singularis
	LGPLv2.1+
	See LICENSE for more information ]]

--[[

Book metadata for all books:
	string author -- display name of the authorship of the book
	string owner -- publisher of the book (username)
	string title -- display title of the book
	string lastedit -- the latest timestamp when the book was saved
	string copyright -- license info for the book (if available)
	string style -- appearance style of the book
	int page -- page where the book is currently openned; 0 means the title page

Book metadata for books with IČK:
	string ick -- IČK of the book
	string edition -- string description of the edition

Book metadata for books without IČK:
	string text -- text of the book
	int public -- access level for registered players who are not owner of the book or admin
]]

books = {
	styles = {
		default = {
			description = "výchozí styl"
		},
	},
}

-- Translation support
local S = minetest.get_translator("books")
local F = minetest.formspec_escape

local modpath = minetest.get_modpath("books")
dofile(modpath.."/api.lua")
dofile(modpath.."/nodes.lua")
dofile(modpath.."/machine.lua")
dofile(modpath.."/crafts.lua")

-- unexport private functions:
books.after_place_node = nil
books.load_book = nil
books.preserve_metadata = nil
books.publish_book = nil
books.on_punch = nil
books.on_use = nil
books.closed_on_rightclick = nil
books.open_on_rightclick = nil
books.update_infotext = nil
