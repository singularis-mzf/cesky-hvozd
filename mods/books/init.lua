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
	int page -- stránka, na které je kniha otevřená, nebo 0, pokud je otevřená na titulní stránce (nekopíruje se)
	int page_max -- počet stránek v knize (nekopíruje se)

Book metadata for books with IČK:
	string ick -- IČK of the book
	string edition -- string description of the edition

Book metadata for books without IČK:
	string text -- text of the book
]]

books = {}

local metadata_keys = {
	"author", "owner", "title", "lastedit", "copyright", "ick", "edition", "text"
}

local player_to_book = {
	-- each player may have one openned book
	-- [player_name] = {pos?, bool can_edit, author, owner, title, lastedit, copyright, ick, edition, text, page0, page1, ..., page_max}
}

-- Translation support
local S = minetest.get_translator("books")
local F = minetest.formspec_escape

local lpp = 30 -- Lines per book's page
local author_color = "#00FF00"
local title_color = "#FFFF00"

local function ifthenelse(condition, true_result, false_result)
	if condition then
		return true_result
	else
		return false_result
	end
end

--[[
local function copy_book_metadata(frommeta, tometa)
	for _, k in ipairs(metadata_keys) do
		tometa:set_string(k, frommeta:get_string(k))
	end
end
]]

local function get_text_by_ick(ick)
	if ick == nil then
		minetest.log("error", "get_text_by_ick() called wil nil ICK!")
		return ""
	end
	local replacement = "<Text byl ztracen. Upozorněte prosím Administraci a poskytněte jí číslo "..ick..", aby mohl být identifikován problém.>"
	local worldpath = minetest.get_worldpath()
	local f = io.open(worldpath.."/knihy/"..ick..".txt")
	if not f then
		return replacement
	end
	local result = f:read("*a") or replacement
	f:close()
	minetest.log("info", "get_text_by_ick("..ick.."): "..#result.." bytes loaded.")
	return result
end

local function read_book_page(lines, start_index, allow_empty_lines_on_start) -- => page_text, new_start_index or nil
	local buffer = {}
	local i = start_index
	if i > #lines then
		return "", nil
	end
	-- skip empty lines on start
	if not allow_empty_lines_on_start then
		while lines[i] == "" do
			i = i + 1
			if i > #lines then
				return "", nil
			end
		end
	end
	while #buffer < lpp do
		if i + 1 < #lines and lines[i] == "" and lines[i + 1] == "" then
			-- two empty lines => force a page break
			i = i + 2
			break
		end
		table.insert(buffer, lines[i])
		i = i + 1
		if i > #lines then
			i = nil -- nothing more to read
			break
		end
	end
	return table.concat(buffer, "\n"), i
end

local function load_book(meta, pos, can_edit)
	local result = {
		pos = pos,
		can_edit = can_edit,
		author = meta:get_string("author"),
		owner = meta:get_string("owner"),
		title = meta:get_string("title"),
		edition = meta:get_string("edition"),
		lastedit = meta:get_string("lastedit"),
		copyright = meta:get_string("copyright"),
		ick = meta:get_string("ick"),
		page = meta:get_int("page")
	}
	if result.ick == "" then
		result.text = meta:get_string("text")
	else
		result.text = get_text_by_ick(result.ick)
	end
	minetest.log("info", "load_book(): "..#result.text.." bytes read.")

	-- Assembly the title page
	local lines = {
		ifthenelse(result.author ~= "", result.author, "<Bez autora/ky>"),
		"\n\n",
		ifthenelse(result.title ~= "", result.title, "<Bez názvu>"),
		"\n\n",
		"Poslední úprava: "..ifthenelse(result.lastedit ~= "", result.lastedit, "nikdy"),
		"\n\n",
		ifthenelse(result.copyright ~= "", result.copyright.."\n\n" , ""),
		ifthenelse(result.ick ~= "", "IČK: "..result.ick.." ("..result.edition..")", ""),
	}
	result.page0 = table.concat(lines)

	lines = ch_core.utf8_wrap(result.text, 80, {allow_empty_lines = true})
	local page = 0
	local i = 1
	while i ~= nil do
		page = page + 1
		result["page"..page], i = read_book_page(lines, i, page == 1)
	end
	if #lines == 0 then
		result.page1 = ""
		result.page_max = 1
	else
		result.page_max = page
	end
	if result.page < 0 or result.page > result.page_max then
		result.page = 1
		meta:set_int("page", 1)
	end
	return result
end

local function player_close_book(player_name)
	local current_book = player_to_book[player_name]
	if current_book ~= nil then
		minetest.log("action", "[books] Player "..player_name..": closing book '"..(current_book.title or "nil").."'"..ifthenelse(current_book.pos ~= nil, " @ "..minetest.pos_to_string(current_book.pos or vector.zero()), "")..".")
		player_to_book[player_name] = nil
	end
end

local function player_open_book(player_name, meta, pos, can_edit)
	player_close_book(player_name)
	local new_book = load_book(meta, pos, can_edit)
	minetest.log("action", "[books] Player "..player_name..": opening book '"..(new_book.title or "nil").."'"..ifthenelse(new_book.pos ~= nil, " @ "..minetest.pos_to_string(new_book.pos or vector.zero()), "")..".")
	player_to_book[player_name] = new_book
	return new_book
end

local function get_book_read_formspec(player_name)
	local book = player_to_book[player_name]
	if book == nil then
		error("get_book_edit_formspec() called for "..player_name.." without any book openned!")
	end
	local formspec = {
		"formspec_version[4]",
		"size[14,14]",
		default.gui_bg,
		default.gui_bg_img,
		"tableoptions[background=#00000000;highlight=#00000000;border=false]",
		"tablecolumns[color;text;color;text]",
		"table[0.375,0.5;12.5,0.5;;", author_color, ",",
		F(ifthenelse(book.author ~= "", book.author, "<Bez autora/ky>")),
		":,", title_color, ",",
		F(ifthenelse(book.title ~= "", book.title, "<Bez názvu>")),
		";]",
		"box[0.375,1.0;12.5,0.025;#FFFFFF]",
		"button_exit[13,0.25;0.8,0.8;close;X]",
		-- "style_type[textarea;font=mono]",
		"textarea[1.375,1.75;12,10;;;",
		F(book["page"..book.page]),
		"]",
		ifthenelse(book.page ~= 0, "button[1,12.75;0.8,0.8;book_titlepage;tit.]", ""),
		ifthenelse(book.page > 1, "button[2,12.75;0.8,0.8;book_pageone;<<]", ""),
		ifthenelse(book.page ~= 0, "button[3,12.75;0.8,0.8;book_prev;<]", ""),
		"field[4,12.75;0.8,0.8;page;str.;"..book.page.."]",
		"field_close_on_enter[page;false]",
		"label[4.9,13.15;z "..book.page_max.."]",
		ifthenelse(book.page ~= book.page_max, "button[5.75,12.75;0.8,0.8;book_next;>]", ""),
		ifthenelse(book.page ~= book.page_max, "button[6.75,12.75;0.8,0.8;book_last;>>]", ""),
		ifthenelse(book.can_edit, "button[8,12.75;3,0.8;book_edit;upravit knihu]", ""),
		ifthenelse(book.ick ~= "", "label[11.25,13.15;IČK: "..book.ick.."]", ""),
	}
	return table.concat(formspec)
end

local function get_book_edit_formspec(player_name)
	local book = player_to_book[player_name]
	if book == nil then
		error("get_book_edit_formspec() called for "..player_name.." without any book openned!")
	end
	local formspec = {
		"formspec_version[4]",
		"size[14,14]",
		default.gui_bg,
		default.gui_bg_img,
		"button_exit[13,0.25;0.8,0.8;close;X]",
		"textarea[0.375,11.6;12.75,3;;;Texty knih nejsou soukromé. Uložením či vydáním knihy souhlasíte, že vložený obsah může být s kopií herního světa předán kterémukoliv hráči/ce, který na Českém hvozdu hrál, hraje či bude hrát. Nevkládejte prosím obsah, k němuž nemůžete takové oprávnění poskytnout.]",
		"label[0.375,0.5;Úprava knihy]",
		"field[0.375,1.25;9.75,0.5;author;Autor/ka (jak má být uveden/a):;",
		F(ifthenelse(book.author ~= "", book.author, ch_core.prihlasovaci_na_zobrazovaci(player_name))),
		"]",
		ifthenelse(
			minetest.check_player_privs(player_name, "protection_bypass"),
			"field[10.375,1.25;3,0.5;owner;Vlastní:;"..F(book.owner).."]",
			""),
		"field[0.375,2.25;9.75,0.5;title;Titul (popř. podtitul) knihy:;",
		F(book.title),
		"]",
		"field[10.375,2.25;3,0.5;edition;Vydání:;",
		F(ifthenelse(book.edition ~= "", book.edition, "1. vyd.")),
		"]",
		"textarea[0.375,3.25;13,1;copyright;Copyright (jen je-li potřeba uvést):;",
		F(book.copyright),
		"]",
		"label[0.375,4.5;Poslední úprava knihy: ",
		F(ifthenelse(book.lastedit ~= "", book.lastedit, "nikdy")),
		"]",
		-- "style_type[textarea;font=mono]",
		"textarea[0.375,5.25;13,6.25;text;Text knihy:;",
		F(book.text),
		"]",
		ifthenelse(book.ick == "",
			"button_exit[0.5,13;6.25,0.75;publish;vydat knihu (přidělí IČK)]",
			"label[2.5,13.35;IČK knihy: "..F(book.ick).."]"),
		"button_exit[7.0,13;6.25,0.75;save;uložit změny]",
	}
	return table.concat(formspec)
end

-- infotext_type in {openned, closed, item}
local function compute_infotext(book_meta, infotext_type)
	local meta = book_meta
	local owner = meta:get_string("owner")
	local author = meta:get_string("author")
	local title = meta:get_string("title")
	local ick = meta:get_string("ick")
	local edition = meta:get_string("edition")
	local result = {}

	if author == "" then
		author = "<Bez autora>"
	end
	if title == "" then
		title = "<Bez názvu>"
	end
	if infotext_type == "item" then
		result[1] = minetest.get_color_escape_sequence(author_color)
		result[2]  = author
		result[3] = ":\n"
		result[4] = minetest.get_color_escape_sequence(title_color)
		result[5] = title
		result[6] = minetest.get_color_escape_sequence("#FFFFFF")
		if ick ~= "" then
			result[7] = "\n(IČK "
			result[8] = ick
			result[9] = ifthenelse(edition ~= "", ", "..edition, "")
			result[10] = ")"
		end
	elseif infotext_type == "openned" then
		local book = load_book(meta, nil, false)
		result[1] = book["page"..(book.page or 1)]
	elseif infotext_type == "closed" then
		result[1] = minetest.get_color_escape_sequence(author_color)
		result[2] = author or "<Bez autora>"
		result[3] = ":\n"
		result[4] = minetest.get_color_escape_sequence(title_color)
		result[5] = title or "<Bez názvu>"
		result[6] = minetest.get_color_escape_sequence("#FFFFFF")
		if ick ~= "" then
			result[7] = " (IČK "
			result[8] = ick
			result[9] = ifthenelse(edition ~= "", ", "..edition, "")
			result[10] = ")"
		end
		table.insert(result, "\nprávo upravovat má: "..ch_core.prihlasovaci_na_zobrazovaci(owner))
	else
		return ""
	end
	return table.concat(result)
end

local function update_infotext(book_meta, infotext_type)
	if infotext_type ~= "item" then
		book_meta:set_string("infotext", compute_infotext(book_meta, infotext_type))
	else
		book_meta:set_string("description", compute_infotext(book_meta, "item"))
	end
end

local function open_book(pos)
	local node = minetest.get_node(pos)
	if minetest.get_item_group(node.name, "book_closed") == 0 then
		return false
	end
	node.name = node.name:gsub("_closed", "_open")
	minetest.swap_node(pos, node)
	local meta = minetest.get_meta(pos)
	local ick = meta:get_string("ick")
	local text
	if ick == "" then
		text = meta:get_string("text")
	else
		text = get_text_by_ick(ick) or ""
	end
	update_infotext(meta, "openned")
	return true
end

local function close_book(pos)
	local node = minetest.get_node(pos)
	if minetest.get_item_group(node.name, "book_open") == 0 then
		return false
	end
	node.name = node.name:gsub("_open", "_closed")
	minetest.swap_node(pos, node)
	update_infotext(minetest.get_meta(pos), "closed")
	return true
end

local function formspec_callback(custom_state, player, formname, fields)
	local player_name = player:get_player_name()
	local cas = ch_core.aktualni_cas()
	local owner = custom_state.owner
	local pos = custom_state.pos
	local item
	local meta

	if fields.text and #fields.text > 1048576 then
		minetest.log("warning", "Book formspec_callback(): fields.text of length "..#fields.text.." bytes!")
		ch_core.systemovy_kanal(player_name, minetest.get_color_escape_sequence("#ff0000").."Text knihy je příliš dlouhý! Limit je 1 MB. Použijte kratší text.")
		return
	end

	if pos == nil then
		item = player:get_wielded_item()
		meta = item:get_meta()
	else
		meta = minetest.get_meta(pos)
	end
	local book = player_to_book[player_name]
	if book == nil then
		minetest.log("warning", "Unexpected callback from form "..formname.."! (dump = "..dump2(fields)..")")
		return
	end

	if (fields.key_enter and fields.key_enter_field == "page" and fields.page) or fields.book_titlepage or fields.book_pageone or fields.book_prev or fields.book_next or fields.book_last then
		if fields.key_enter and fields.key_enter_field == "page" and fields.page then
			local new_page = tonumber(fields.page)
			if 0 <= new_page and new_page <= book.page_max then
				book.page = new_page
			end
		elseif fields.book_titlepage then
			book.page = 0
		elseif fields.book_pageone then
			book.page = 1
		elseif fields.book_prev then
			book.page = math.max(0, book.page - 1)
		elseif fields.book_next then
			book.page = math.min(book.page + 1, book.page_max)
		else -- if fields.book_last then
			book.page = book.page_max
		end
		meta:set_int("page", book.page)
		if pos == nil then
			player:set_wielded_item(item)
		elseif minetest.get_item_group(minetest.get_node(pos).name, "book_open") ~= 0 then
			update_infotext(meta, "openned")
		end
		return get_book_read_formspec(player_name)
	elseif fields.book_edit and book.can_edit then
		return get_book_edit_formspec(player_name)
	elseif fields.save or fields.publish then
		-- author, owner, title, edition, copyright, text
		if fields.owner and fields.owner ~= owner and minetest.check_player_privs(player:get_player_name(), "protection_bypass") then
			meta:set_string("owner", fields.owner)
			owner = fields.owner
		end
		if fields.author then
			meta:set_string("author", ch_core.utf8_truncate_right(fields.author, 256))
		end
		if fields.title then
			meta:set_string("title", ch_core.utf8_truncate_right(fields.title, 256))
		end
		if fields.copyright then
			meta:set_string("copyright", fields.copyright)
		end
		if meta:get_string("ick") ~= "" then
			-- strip ICK and edition
			meta:set_string("ick", "")
			meta:set_string("edition", "")
		end
		meta:set_string("lastedit", string.format("%d. %s %d (%s)", cas.den, cas.nazev_mesice_2, cas.rok, cas.den_v_tydnu_nazev))
		meta:set_string("text", fields.text or "")
		if fields.publish then
			-- PUBLISH THE BOOK
			local worldpath = minetest.get_worldpath()
			local global_data = ch_core.global_data
			local ick = global_data.pristi_ick
			global_data.pristi_ick = ick + 1

			if fields.edition then
				meta:set_string("edition", ch_core.utf8_truncate_right(fields.edition, 256))
			end
			local metadata = {
				"IČK: <"..ick..">\n",
				"Titul: <"..meta:get_string("title")..">\n",
				"Vydání: <"..meta:get_string("edition")..">\n",
				"Autor/ka: <"..meta:get_string("author")..">\n",
				"Vložil/a/vydal/a: <"..ch_core.prihlasovaci_na_zobrazovaci(owner).."> ("..owner..")\n",
				"Copyright: <"..meta:get_string("copyright")..">\n",
				string.format("Čas vydání: %04d-%02d-%02dT%02d:%02d:%02d%s\n", cas.rok, cas.mesic, cas.den, cas.hodina, cas.minuta, cas.sekunda, cas.posun_text),
			}
			local text = meta:get_string("text").. "\n\n\n----\n"..table.concat(metadata)
			table.insert(metadata, "Délka textu v bajtech: "..#text.."\n")
			metadata = table.concat(metadata)
			ch_core.save_global_data("pristi_ick")
			minetest.safe_file_write(worldpath.."/knihy/"..ick..".txt", text)
			minetest.safe_file_write(worldpath.."/knihy/"..ick..".meta", metadata)
			meta:set_string("ick", ick)
			meta:set_string("text", "")
		end
		if pos == nil then
			-- item
			update_infotext(meta, "item")
			player:set_wielded_item(item)
		elseif minetest.get_item_group(minetest.get_node(pos).name, "book_open") ~= 0 then
			-- node (open book)
			update_infotext(meta, "openned")
		else
			-- node (closed book)
			update_infotext(meta, "closed")
		end
	elseif fields.close or fields.quit then
		player_close_book(player_name)
	end
end

function books.closed_on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	open_book(pos)
end

function books.open_on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	if clicker then
		local player_name = clicker:get_player_name()
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		if owner == "" then
			owner = clicker:get_player_name()
			meta:set_string("owner", owner)
			meta:set_int("page", 1)
		end
		player_open_book(player_name, meta, pos, owner == player_name or minetest.check_player_privs(player_name, "protection_bypass"))
		local formspec = get_book_read_formspec(player_name)
		ch_core.show_formspec(clicker, "books:book", formspec, formspec_callback, {
			type = "pos",
			pos = pos,
			owner = owner,
		}, {})
	end
end

function books.on_punch(pos, node, puncher, pointed_thing)
	close_book(pos)
end

-- minetest.override_item("default:book", override)
-- minetest.override_item("default:book_written", override)

function books.preserve_metadata(pos, oldnode, oldmeta, drops)
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
	for _, k in ipairs(metadata_keys) do
		itemmeta:set_string(k, oldmeta[k] or "")
	end
	update_infotext(itemmeta, "item")
end

function books.after_place_node(pos, placer, itemstack, pointed_thing)
	local itemmeta = itemstack:get_meta()
	if itemmeta then
		local nodemeta = minetest.get_meta(pos)
		nodemeta:from_table(itemmeta:to_table())
		update_infotext(nodemeta, "closed")
	end
end

function books.on_use(itemstack, user, pointed_thing)
	local player_name = user and user:get_player_name()
	if player_name then
		local meta = itemstack:get_meta()
		local owner = meta:get_string("owner")
		if owner == "" then
			owner = player_name
			meta:set_string("owner", player_name)
		end
		player_to_book[player_name] = load_book(meta, nil, player_name == owner or minetest.check_player_privs(player_name, "protection_bypass"))
		local formspec = get_book_read_formspec(player_name)
		if formspec ~= nil then
			ch_core.show_formspec(user, "books:book", formspec, formspec_callback, {
				type = "item",
				owner = owner,
			}, {})
			return itemstack
		end
	end
end

local modpath = minetest.get_modpath("books")
dofile(modpath.."/nodes.lua")
dofile(modpath.."/crafts.lua")

books = {}
