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
	int paper_price -- count of paper items needed to copy the book
	int ink_price -- count of dye items needed to copy the book

Book metadata for books with IČK:
	string ick -- IČK of the book
	string edition -- string description of the edition

Book metadata for books without IČK:
	string text -- text of the book
	int public -- access level for registered players who are not owner of the book or admin
]]

local metadata_keys_int = {
	"public"
}
local metadata_keys_string = {
	"author", "owner", "title", "lastedit", "copyright", "ick", "edition", "style", "text"
}

local player_to_book = {
	-- each player may have one openned book
	-- [player_name] = {pos?, access_level, author, owner, title, lastedit, copyright, ick, edition, public, style, text, page0, page1, ..., page_max}
}

-- Translation support
local S = minetest.get_translator("books")
local F = minetest.formspec_escape

local lpp = 30 -- Lines per book's page
local cpl = 80 -- maximal characters per book's line
local author_color = "#00FF00"
local title_color = "#FFFF00"
local append_limit = 2048
local ap_increase_counter = 8 -- (8 * 15 seconds = 2 minutes)
local paper_minimum_B5 = 6
local paper_minimum_B6 = 4

-- Access levels:
local READ_ONLY = 0 -- player can only read the book
local APPEND_ONLY = 1 -- player can read the book and append a short signed texts
local PREPEND_ONLY = 2 -- player can read the book and prepend a short signed texts
local READ_WRITE = 3 -- player can edit the text of the book only
local FULL_ACCESS = 4 -- player can edit the book fully

local function assert_not_nil(x)
	if x == nil then
		error("Assertion failed: the value is nil!")
	end
	return x
end

local function ifthenelse(condition, true_result, false_result)
	if condition then
		return true_result
	else
		return false_result
	end
end

local description_to_style = {
	[books.styles.default.description] = "default",
}

-- public
function books.register_book_style(name, def)
	if name == nil or name == "" or name == "default" then
		error("[books] Invalid book style name \""..(name or "nil").."\"!")
	end
	local description = def.description
	if description == nil or description == "" then
		error("[books] Invalid book style description!")
	end
	if description_to_style[description] ~= nil then
		error("[books] Duplicit book style description \""..description.."\"!")
	end
	description_to_style[description] = name
	books.styles[name] = def
	return true
end

local style_description_list -- a list of descriptions for a formspec
local style_to_index -- style name to index in the list
local function on_mods_loaded()
	local list = {""}
	for desc, style in pairs(description_to_style) do
		if style ~= "default" then
			table.insert(list, description)
		end
	end
	table.sort(list)
	if list[1] ~= "" then
		error("[books] Internal error: bad description sorting!")
	end
	list[1] = books.styles.default.description
	style_to_index = {}
	for i = 1, #list do
		style_to_index[description_to_style[list[i]]] = i
		list[i] = F(list[i])
	end
	style_description_list = table.concat(list, ",")
end
minetest.register_on_mods_loaded(on_mods_loaded)

--[[
local function copy_book_metadata(frommeta, tometa)
	for _, k in ipairs(metadata_keys) do
		tometa:set_string(k, frommeta:get_string(k))
	end
end
]]

-- public
function books.analyze_book(name, meta)
	local kind = minetest.get_item_group(name, "book")
	local result = {}
	local paper_minimum
	if kind == 5 then
		result.format = "B5"
		paper_minimum = paper_minimum_B5
	elseif kind == 6 then
		result.format = "B6"
		paper_minimum = paper_minimum_B6
	else
		return nil -- not a book or unknown book
	end
	result.ick = meta:get_string("ick")
	result.owner = meta:get_string("owner")
	result.raw_paper_price = meta:get_int("paper_price")
	result.raw_ink_price = meta:get_int("ink_price")
	result.paper_price = math.max(paper_minimum, result.raw_paper_price)
	result.ink_price = math.max(1, result.raw_ink_price)
	return result
end

local function increase_ap(player_name)
	local online_charinfo = player_name and ch_core.online_charinfo[player_name]
	if online_charinfo ~= nil then
		local ap = online_charinfo.ap
		if ap ~= nil then
			ap.book_gen = ap.book_gen + 1
			return true
		end
	end
	return false
end

local function ap_increase_tick(player_name, counter, expected_book_gen)
	local online_charinfo = player_name and ch_core.online_charinfo[player_name]
	if counter > 0 and online_charinfo ~= nil then
		local ap = online_charinfo.ap
		if ap ~= nil and ap.book_gen == expected_book_gen then
			local new_book_gen = expected_book_gen + 1
			ap.book_gen = new_book_gen
			if counter > 1 then
				minetest.after(15, ap_increase_tick, player_name, counter - 1, new_book_gen)
			end
		end
	end
end

local function start_ap_increase(player_name, counter)
	if counter <= 0 then
		return
	end
	local online_charinfo = player_name and ch_core.online_charinfo[player_name]
	if online_charinfo == nil then
		return
	end
	local ap = online_charinfo.ap
	if ap == nil then
		return
	end
	return ap_increase_tick(player_name, counter, ap.book_gen)
end

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

--[[
	NOTE: both pos and player_name may be nil! (meta must not be nil)
]]
function books.load_book(meta, pos, player_name)
	local result = {
		pos = pos,
		author = meta:get_string("author"),
		owner = meta:get_string("owner"),
		title = meta:get_string("title"),
		edition = meta:get_string("edition"),
		lastedit = meta:get_string("lastedit"),
		copyright = meta:get_string("copyright"),
		ick = meta:get_string("ick"),
		page = meta:get_int("page"),
		public = meta:get_int("public"),
		style = meta:get_string("style"),
		paper_price = meta:get_int("paper_price"),
		ink_price = meta:get_int("ink_price"),
	}
	if books.styles[result.style] == nil then
		result.style = "default"
	end
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

	lines = ch_core.utf8_wrap(result.text, cpl, {allow_empty_lines = true})
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
	result.page = math.max(0, math.min(result.page_max, result.page))

	-- Access level:
	if player_name == nil then
		-- no player => read-only access
		result.access_level = READ_ONLY
	elseif minetest.check_player_privs(player_name, "protection_bypass") then
		-- admin => full access
		result.access_level = FULL_ACCESS
	elseif not minetest.check_player_privs(player_name, "ch_registered_player") then
		-- a new player => read-only access
		result.access_level = READ_ONLY
	elseif result.owner == "" or player_name == result.owner then
		-- owner => full access
		result.access_level = FULL_ACCESS
	elseif result.public == READ_WRITE or result.public == PREPEND_ONLY or result.public == APPEND_ONLY then
		-- access acording to the "public" setting
		result.access_level = result.public
	else
		result.access_level = READ_ONLY
	end

	minetest.log("action", "load_book()"..
		ifthenelse(player_name ~= nil, " for player "..(player_name or ""), "")..
		ifthenelse(pos ~= nil, pos and (" at "..minetest.pos_to_string(pos)), "")..
		ifthenelse(result.ick ~= "", " with ICK "..result.ick, "")..
		" finished. owner = "..result.owner..", title = "..result.title..", paper_price = "..result.paper_price..", ink_price = "..result.ink_price..", page = "..result.page..", lines_count = "..#lines..", page_max = "..result.page_max..", access_level = "..result.access_level..", public = "..result.public..", style = "..result.style.."."
	)

	return result
end
local load_book = books.load_book

local function player_close_book(player_name)
	local current_book = player_to_book[player_name]
	if current_book ~= nil then
		minetest.log("action", "[books] Player "..player_name..": closing book '"..(current_book.title or "nil").."'"..ifthenelse(current_book.pos ~= nil, " @ "..minetest.pos_to_string(current_book.pos or vector.zero()), "")..".")
		player_to_book[player_name] = nil
		increase_ap(player_name)
	end
end

local function player_open_book(player_name, meta, pos)
	player_close_book(player_name)
	local new_book = load_book(meta, pos, player_name)
	minetest.log("action", "[books] Player "..player_name..": opening book '"..(new_book.title or "nil").."'"..ifthenelse(new_book.pos ~= nil, " @ "..minetest.pos_to_string(new_book.pos or vector.zero()), "").." with access level "..new_book.access_level..".")
	player_to_book[player_name] = new_book
	increase_ap(player_name)
	return new_book
end

local function get_book_read_formspec(player_name)
	local book = player_to_book[player_name]
	if book == nil then
		error("get_book_edit_formspec() called for "..player_name.." without any book openned!")
	end
	local style = assert_not_nil(books.styles[book.style] or books.styles["default"])
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
	}
	if book.ick ~= "" then
		table.insert(formspec, "label[11.25,13.15;IČK: "..book.ick.."]")
	else
		if book.access_level == FULL_ACCESS then
			table.insert(formspec, "button[8,12.75;3,0.8;book_edit;upravit knihu]")
		elseif book.access_level == READ_WRITE then
			table.insert(formspec, "button[8,12.75;3,0.8;book_edit;upravit text]")
		elseif book.access_level == APPEND_ONLY or book.access_level == PREPEND_ONLY then
			table.insert(formspec, "button[8,12.75;3,0.8;book_edit;připojit úryvek]")
		end
	end
	return table.concat(formspec)
end

local function get_book_edit_formspec(player_name, access_level)
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
		"textarea[0.375,11.6;12.75,3;;;Texty knih nejsou soukromé. Uložením knihy souhlasíte, že vložený obsah může být s kopií herního světa předán kterémukoliv hráči/ce, který na Českém hvozdu hrál, hraje či bude hrát. Nevkládejte prosím obsah, k němuž nemůžete takové oprávnění poskytnout.]"
	}
	local s
	if access_level == nil then
		access_level = book.access_level
	end
	if access_level == FULL_ACCESS then
		s = "Úprava knihy"
	elseif access_level == READ_WRITE then
		s = "Úprava textu"
	elseif access_level == APPEND_ONLY or access_level == PREPEND_ONLY then
		s = "Připojení úryvku"
	else
		s = "Připojení úryvku"
		access_level = APPEND_ONLY
	end
	table.insert(formspec, "label[0.375,0.5;"..s.."]")
	if access_level == APPEND_ONLY or access_level == PREPEND_ONLY then
		table.insert_all(formspec, {
			"textarea[1,1;12,3;;;Upozornění: Správce/yně této knihy vám umožňuje do této knihy připsat krátký příspěvek (max. ",
			append_limit,
			" znaků). Vámi vložený příspěvek se označí jménem postavy a časem vložení a po vložení ho již nebudete moci upravit ani smazat. Bude-li to potřeba\\, obraťte se na správce/yni knihy, což je ",
			F(ch_core.prihlasovaci_na_zobrazovaci(book.owner)),
			"].",
		})
	elseif access_level == FULL_ACCESS then
		table.insert_all(formspec, {
			"field[0.375,1.25;9.75,0.5;author;Autor/ka (jak má být uveden/a):;",
			F(ifthenelse(book.author ~= "", book.author, ch_core.prihlasovaci_na_zobrazovaci(player_name))),
			"]"
		})
	end
	if minetest.check_player_privs(player_name, "protection_bypass") then
		table.insert_all(formspec, {
			"field[10.375,1.25;3,0.5;owner;Správce/yně knihy:;",
			F(book.owner),
			"]"
		})
	else
		table.insert_all(formspec, {
			"textarea[10.375,1.25;3,0.5;;Správce/yně knihy:;",
			F(ch_core.prihlasovaci_na_zobrazovaci(book.owner)),
			"]"
		})
	end
	if access_level == FULL_ACCESS then
		table.insert_all(formspec, {
			"field[0.375,2.25;13,0.5;title;Titul (popř. podtitul) knihy:;",
			F(book.title),
			"]",
			--[[
			"field[10.375,2.25;3,0.5;edition;Vydání:;",
			F(ifthenelse(book.edition ~= "", book.edition, "1. vyd.")),
			"]", ]]
			"textarea[0.375,3.25;13,0.6666;copyright;Copyright (jen je-li potřeba uvést):;",
			F(book.copyright),
			"]",
			"label[0.375,4.25;Styl knihy:]",
			"dropdown[2,4.0;5.4,0.5;style;",
			style_description_list,
			";", style_to_index[book.style] or 1, ";false]",
			"label[7.5,4.25;Ostatní mohou text]",
			"dropdown[10.15,4.0;3.25,0.5;public;jen číst,připisovat na začátek,připisovat na konec,upravovat;"
		})
		if book.public == READ_WRITE then
			table.insert(formspec, "4")
		elseif book.public == APPEND_ONLY then
			table.insert(formspec, "3")
		elseif book.public == PREPEND_ONLY then
			table.insert(formspec, "2")
		else
			table.insert(formspec, "1")
		end
		table.insert(formspec, ";true]")
	end
	table.insert_all(formspec, {
		"label[0.375,4.7;Poslední úprava knihy: ",
		F(ifthenelse(book.lastedit ~= "", book.lastedit, "nikdy")),
		"]",
		"textarea[0.375,5.25;13,6.25;text;"})
	if access_level == APPEND_ONLY or access_level == PREPEND_ONLY then
		table.insert(formspec, "Text k připojení:;]")
	else
		table.insert_all(formspec, {"Text knihy:;", F(book.text), "]"})
	end
	--[[ if book.ick ~= "" then
		table.insert(formspec, "label[2.5,13.35;IČK knihy: "..F(book.ick).."]")
	elseif access_level == FULL_ACCESS then
		table.insert(formspec, "button_exit[0.5,13;6.25,0.75;publish;vydat knihu (přidělí IČK)]")
	end ]]
	if access_level == FULL_ACCESS then
		table.insert(formspec,
		             "button[0.375,13;3,0.75;zacatek;vkládání na začátek...]"..
		             "button[3.5,13;3,0.75;konec;vkládání na konec...]")
	end
	table.insert(formspec, "button_exit[7.0,13;6.25,0.75;save;uložit změny]")
	return table.concat(formspec)
end

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

local function generate_random_book_color(old_name, old_param2)
	-- => new_name, new_param2
	-- => nil, nil
	if minetest.get_item_group(old_name, "book") == 0 then
		return
	end
	local old_hue = old_name:match("[^_]+$")
	if old_hue == nil or old_hue == "" then
		return
	end
	local old_facedir = old_param2 % 32
	local new_hue = hue_names[math.random(1, #hue_names)]
	local new_color_index
	if new_hue ~= "grey" then
		new_color_index = math.random(1, 8) - 1
	else
		new_color_index = math.random(1, 5)
	end
	local new_name = old_name:sub(1, -(1 + #old_hue))..new_hue
	return new_name, old_facedir + 32 * new_color_index
end

local function initialize_book_item(itemstack, itemstack_meta)
	local name, palette_index = itemstack:get_name(), itemstack_meta:get_int("palette_index")
	if name:match("_grey$") and palette_index == 0 then
		name, palette_index = generate_random_book_color(name, palette_index)
		if name ~= nil then
			itemstack:set_name(name)
			itemstack_meta:set_int("palette_index", palette_index)
			return true
		else
			return false
		end
	end
	return true
end

local function initialize_book_node(pos, node, node_meta)
	local name, param2 = node.name, node.param2
	if name:match("_grey$") and (param2 - param2 % 32) == 0 then
		name, param2 = generate_random_book_color(name, param2)
		if name ~= nil then
			node.name = name
			node.param2 = param2
			minetest.swap_node(pos, node)
		else
			return false
		end
	end
	return true
end

-- infotext_type in {openned, closed, item}
local function compute_infotext(book_meta, infotext_type, book_data_hint)
	if book_data_hint == nil then
		book_data_hint = {}
	end
	local meta = book_meta
	local owner = book_data_hint.owner or meta:get_string("owner")
	local author = book_data_hint.author or meta:get_string("author")
	local title = book_data_hint.title or meta:get_string("title")
	local ick = book_data_hint.ick or meta:get_string("ick")
	local edition = book_data_hint.edition or meta:get_string("edition")
	local public = book_data_hint.public or meta:get_int("public")
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
		local book_data = book_data_hint
		if book_data.page1 == nil then
			book_data = load_book(meta, nil, nil)
		end
		local page_text = book_data["page"..(book_data.page or 1)]
		if page_text ~= nil then
			result[1] = page_text:gsub("\n", " ")
		else
			result[1] = ""
		end
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
		if owner ~= "" then
			table.insert(result, "\nknihu spravuje: "..ch_core.prihlasovaci_na_zobrazovaci(owner))
		else
			table.insert(result, "\nkniha je volná")
		end
	else
		return ""
	end
	if infotext_type == "item" or infotext_type == "closed" then
		if public == READ_WRITE then
			table.insert(result, "\n(otevřená kniha - reg. postavy mohou upravovat text)")
		elseif public == APPEND_ONLY or public == PREPEND_ONLY then
			table.insert(result, "\n(otevřená kniha - reg. postavy mohou připisovat)")
		end
	end
	return table.concat(result)
end

function books.update_infotext(book_meta, infotext_type, book_data_hint)
	if infotext_type ~= "item" then
		book_meta:set_string("infotext", compute_infotext(book_meta, infotext_type, book_data_hint))
	elseif book_meta:get_string("owner") ~= "" then -- only update infotext for owned books
		book_meta:set_string("description", compute_infotext(book_meta, "item", book_data_hint))
	end
end
local update_infotext = books.update_infotext

function books.publish_book(book_item, edition) -- => IČK, error_message
	if minetest.get_item_group(book_item:get_name(), "book") == 0 then
		return nil, "Zadaný předmět není kniha!"
	end
	local meta = book_item:get_meta()
	local owner = meta:get_string("owner")
	if owner == "" then
		return nil, "Zadaná kniha nemá správce/yni!"
	end
	local ick = meta:get_string("ick")
	if ick ~= "" then
		return nil, "Kniha již byla vydána pod IČK "..ick.."!"
	end
	local author = meta:get_string("author")
	local title = meta:get_string("title")
	edition = ch_core.utf8_truncate_right(edition or "", 256)
	local worldpath = minetest.get_worldpath()
	local global_data = ch_core.global_data
	local ick = global_data.pristi_ick
	global_data.pristi_ick = ick + 1
	local cas = ch_core.aktualni_cas()
	local metadata = {
		"IČK: <"..ick..">\n",
		"Titul: <"..title..">\n",
		"Vydání: <"..edition..">\n",
		"Autor/ka: <"..author..">\n",
		"Knihu vydal/a: <"..ch_core.prihlasovaci_na_zobrazovaci(owner).."> ("..owner..")\n",
		"Copyright: <"..meta:get_string("copyright")..">\n",
		string.format("Čas vydání: %04d-%02d-%02dT%02d:%02d:%02d%s\n", cas.rok, cas.mesic, cas.den, cas.hodina, cas.minuta, cas.sekunda, cas.posun_text),
	}
	local text = meta:get_string("text").. "\n\n\n----\n"..table.concat(metadata)
	table.insert(metadata, "Délka textu v bajtech: "..#text.."\n")
	metadata = table.concat(metadata)
	ch_core.save_global_data("pristi_ick")
	minetest.mkdir(worldpath.."/knihy")
	minetest.safe_file_write(worldpath.."/knihy/"..ick..".txt", text)
	minetest.safe_file_write(worldpath.."/knihy/"..ick..".meta", metadata)

	-- update metadata: add edition, add ICK, strip public, strip text
	meta:set_string("edition", edition)
	meta:set_string("ick", ick)
	meta:set_int("public", 0)
	meta:set_string("text", "")
	update_infotext(meta, "item")

	-- Povinné výtisky:
	local pos = global_data.povinne_vytisky
	local listname = global_data.povinne_vytisky_listname
	if listname ~= nil and listname ~= "" then
		minetest.load_area(pos)
		local node = minetest.get_node(pos)
		if node.name:match(":") == nil then
			minetest.log("error", "Povinne vytisky failed, because the node is "..node.name.."!")
		else
			local node_inv = minetest.get_meta(pos):get_inventory()
			if node_inv:get_size(listname) == 0 then
				minetest.log("error", "Povinne vytisky failed, because the node "..node.name.." doesn't have a list "..listname.."!")
			end
			local leftover = node_inv:add_item(listname, book_item)
			if leftover:is_empty() then
				minetest.log("action", "Povinne vytisky: book with ICK "..ick.." stored to the chest "..node.name.." at "..minetest.pos_to_string(pos))
			else
				local chests = minetest.find_nodes_in_area(vector.offset(pos, -2, -2, -2), vector.offset(pos, 2, 2, 2), {node.name}, false)
				local chests_positions = {}
				local pos2_used
				for _, pos2 in ipairs(chests) do
					table.insert(chests_positions, minetest.pos_to_string(pos2))
					node_inv = minetest.get_meta(pos2):get_inventory()
					leftover = node_inv:add_item(listname, book_item)
					if leftover:is_empty() then
						pos2_used = pos2
						break
					end
				end
				if pos2_used ~= nil then
					minetest.log("warning", "Povinne vytisky: book ICK "..ick.." placed to the chest at "..minetest.pos_to_string(pos2_used)..", because the main chest "..node.name.." at "..minetest.pos_to_string(pos).." is full.")
				else
					minetest.log("error", "Povinne vytisky failed, because "..#chests.." chests of type "..node.name.." near "..minetest.pos_to_string(pos).." are full! Book with ICK "..ick.." is lost! ("..table.concat(chests_positions, ", ")..")")
				end
			end
		end
	end

	-- Oznámit:
	minetest.log("action", "[books] "..owner.." published a book '"..title.."' (edition="..edition..") under ICK "..ick)
	ch_core.systemovy_kanal("", "Oznámení Knihovny Českého hvozdu: "..ch_core.prihlasovaci_na_zobrazovaci(owner).." vydal/a knihu '"..title.."' ("..edition..", autorství: "..author..") pod IČK "..ick..".")
	return ick, nil
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
	if fields.text and #fields.text > 1048576 then
		minetest.log("warning", "Book formspec_callback(): fields.text of length "..#fields.text.." bytes!")
		ch_core.systemovy_kanal(player_name, minetest.get_color_escape_sequence("#ff0000").."Text knihy je příliš dlouhý! Limit je 1 MB. Použijte kratší text.")
		return
	end
	local pos = custom_state.pos
	local item, meta
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
	local owner = custom_state.owner

	if (fields.key_enter and fields.key_enter_field == "page" and fields.page) or fields.book_titlepage or fields.book_pageone or fields.book_prev or fields.book_next or fields.book_last then
		-- change page:
		local current_page = book.page
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
		if book.page ~= current_page then
			start_ap_increase(player_name, ap_increase_counter)
		end
		if pos == nil then
			player:set_wielded_item(item)
		elseif minetest.get_item_group(minetest.get_node(pos).name, "book_open") ~= 0 then
			update_infotext(meta, "openned", book)
		end
		return get_book_read_formspec(player_name)
	elseif fields.book_edit and book.access_level ~= READ_ONLY then
		return get_book_edit_formspec(player_name)
	elseif book.access_level == FULL_ACCESS and (fields.zacatek or fields.konec) then
		if fields.zacatek then
			custom_state.access_level = PREPEND_ONLY
		else
			custom_state.access_level = APPEND_ONLY
		end
		return get_book_edit_formspec(player_name, custom_state.access_level)
	elseif fields.save then
		-- author, owner, title, edition, copyright, style, public, text
		local access_level = custom_state.access_level
		if access_level == READ_ONLY then
			return -- access violation
		end
		if access_level == FULL_ACCESS then
			if fields.owner and fields.owner ~= owner and minetest.check_player_privs(player_name, "protection_bypass") then
				owner = fields.owner
				meta:set_string("owner", owner)
			elseif owner == "" then
				owner = player_name
				meta:set_string("owner", owner)
			end
			if fields.author then
				book.author = ch_core.utf8_truncate_right(fields.author, 256)
				meta:set_string("author", book.author)
			end
			if fields.title then
				book.title = ch_core.utf8_truncate_right(fields.title, 256)
				meta:set_string("title", book.title)
			end
			if fields.copyright then
				book.copyright = fields.copyright
				meta:set_string("copyright", book.copyright)
			end
			if fields.style then
				if books.styles[fields.style] == nil then
					fields.style = "default"
				end
				book.style = fields.style
				meta:set_string("style", book.style)
			end
			if fields.public then
				local new_public_value = tonumber(fields.public) or 0
				if new_public_value == 1 then
					book.public = READ_ONLY
				elseif new_public_value == 2 then
					book.public = PREPEND_ONLY
				elseif new_public_value == 3 then
					book.public = APPEND_ONLY
				elseif new_public_value == 4 then
					book.public = READ_WRITE
				end
				meta:set_int("public", book.public)
			end
		end
		if meta:get_string("ick") ~= "" then
			-- strip ICK and edition
			meta:set_string("ick", "")
			meta:set_string("edition", "")
			book.ick = ""
			book.edition = ""
		end
		local cas = ch_core.aktualni_cas()
		local last_edit = string.format("%d. %s %d (%s)", cas.den, cas.nazev_mesice_2, cas.rok, cas.den_v_tydnu_nazev)
		if player_name == owner then
			meta:set_string("lastedit", last_edit)
		else
			meta:set_string("lastedit", last_edit.." ("..ch_core.prihlasovaci_na_zobrazovaci(player_name)..")")
		end
		if access_level == APPEND_ONLY or access_level == PREPEND_ONLY then
			local old_text = book.text
			local new_text = string.format("%s\n-- %s / %d. %s %d %02d:%02d:%02d %s",
				ch_core.utf8_truncate_right(fields.text or "", 2048), -- limit for appending
				ch_core.prihlasovaci_na_zobrazovaci(player_name),
				cas.den, cas.nazev_mesice_2, cas.rok, cas.hodina, cas.minuta, cas.sekunda,
				cas.posun_text)
			if #old_text == 0 then
				book.text = new_text -- no old text
			elseif access_level == APPEND_ONLY then
				book.text = old_text.."\n\n"..new_text
			else -- PREPEND_ONLY
				book.text = new_text.."\n\n"..old_text
			end
		else
			book.text = fields.text or ""
		end
		meta:set_string("text", book.text)

		-- compute the amount of paper and ink
		local lines = ch_core.utf8_wrap(book.text, cpl, {allow_empty_lines = true})
		local i = 1
		local pages = 0
		while i ~= nil do
			pages = pages + 1
			local x
			x, i = read_book_page(lines, i, pages == 1)
		end
		local item_name
		if pos ~= nil then
			item_name = minetest.get_node(pos).name
		else
			item_name = item:get_name()
		end
		local book_kind = minetest.get_item_group(item_name, "book")
		local paper_minimum
		if book_kind == 5 then
			paper_minimum = paper_minimum_B5
		elseif book_kind == 6 then
			paper_minimum = paper_minimum_B6
		else
			error("A book with unknown item kind ("..item_name..", book_lind = "..book_kind..")!")
		end
		book.paper_price = math.max(paper_minimum, 1 + math.ceil(pages / 2))
		book.ink_price = 1 + pages
		meta:set_int("paper_price", book.paper_price)
		meta:set_int("ink_price", book.ink_price)
		if player_to_book[player_name] == nil then
			error("Unknown error when saving a book (book == nil)!")
		end
		if pos == nil then
			-- item
			update_infotext(meta, "item", book)
			player:set_wielded_item(item)
		elseif minetest.get_item_group(minetest.get_node(pos).name, "book_open") ~= 0 then
			-- node (open book)
			player_open_book(player_name, meta, pos)
			book = player_to_book[player_name] or book
			update_infotext(meta, "openned", book)
		else
			-- node (closed book) (should not happen)
			minetest.log("warning", "Book save called for a closed book "..minetest.get_node(pos).name.." at "..minetest.pos_to_string(pos).."!")
			update_infotext(meta, "closed", book)
		end
		local message = {
			"Player ", player_name, " saved book with author '", meta:get_string("author"), "' and title '", meta:get_string("title"), "'",
			ifthenelse(pos ~= nil, " at "..minetest.pos_to_string(pos or vector.zero()), ""), " with access_level == "..access_level.." and price = ",
			book.paper_price, " papers and ", book.ink_price, " ink. Text length is ", #book.text,
		}
		message = table.concat(message)
		minetest.log("action", message)
		player_close_book(player_name)
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
			initialize_book_node(pos, node, meta)
			meta:set_int("page", 1)
		end
		player_open_book(player_name, meta, pos)
		local formspec = get_book_read_formspec(player_name)
		ch_core.show_formspec(clicker, "books:book", formspec, formspec_callback, {
			type = "pos",
			pos = pos,
			owner = owner,
			access_level = assert_not_nil(player_to_book[player_name].access_level),
		}, {})
		start_ap_increase(player_name, ap_increase_counter)
	end
end

function books.on_punch(pos, node, puncher, pointed_thing)
	close_book(pos)
end

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
	for _, k in ipairs(metadata_keys_int) do
		itemmeta:set_int(k, oldmeta[k] or 0)
	end
	for _, k in ipairs(metadata_keys_string) do
		itemmeta:set_string(k, oldmeta[k] or "")
	end
	update_infotext(itemmeta, "item")
end

function books.after_place_node(pos, placer, itemstack, pointed_thing)
	local itemmeta = itemstack:get_meta()
	if itemmeta then
		local player_name = (placer and placer:get_player_name()) or "Administrace"
		local nodemeta = minetest.get_meta(pos)
		nodemeta:from_table(itemmeta:to_table())
		if nodemeta:get_string("owner") == "" then
			initialize_book_node(pos, minetest.get_node(pos), nodemeta)
		end
		update_infotext(nodemeta, "closed")
	end
end

function books.on_use(itemstack, user, pointed_thing)
	local player_name = user and user:get_player_name()
	if player_name then
		local meta = itemstack:get_meta()
		local owner = meta:get_string("owner")
		if owner == "" then
			initialize_book_item(itemstack, meta, player_name)
		end
		player_to_book[player_name] = load_book(meta, nil, player_name)
		local formspec = get_book_read_formspec(player_name)
		if formspec ~= nil then
			ch_core.show_formspec(user, "books:book", formspec, formspec_callback, {
				type = "item",
				owner = owner,
				-- pos = nil,
				access_level = assert_not_nil(player_to_book[player_name].access_level),
			}, {})
			start_ap_increase(player_name, ap_increase_counter)
			return itemstack
		end
	end
end

local function nastavit_povinne_vytisky(player_name, param)
	local x, y, z, listname = param:match("^(-?%d+),(-?%d+),(-?%d+) (.+)$")
	x, y, z = tonumber(x), tonumber(y), tonumber(z)
	if type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" or
			x < -30000 or x > 30000 or y < -30000 or y > 30000 or z < -30000 or
			z > 30000 or listname == nil or listname == "" then
		return false, "Chybné zadání!"
	end
	local pos = vector.new(x, y, z)
	minetest.load_area(pos)
	local node = minetest.get_node_or_nil(pos)
	if node == nil or node.name == "ignore" or node.name == "air" then
		return false, "Nemohu načíst blok na pozici "..minetest.pos_to_string(pos).."!"
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local lists = inv:get_lists()
	local count = 0
	local has_list = false
	local list_names = {}
	for k, v in pairs(lists) do
		count = count + 1
		table.insert(list_names, k)
		if k == listname then
			has_list = true
		end
	end
	if count == 0 then
		return false, "Blok "..node.name.." na pozici "..minetest.pos_to_string(pos).." neobsahuje žádné inventáře!"
	elseif not has_list then
		return false, "Blok "..node.name.." na pozici "..minetest.pos_to_string(pos).." neobsahuje inventář "..listname.."! Obsahuje "..count.." inventářů: "..table.concat(list_names, ",")
	end
	ch_core.global_data.povinne_vytisky = pos
	ch_core.global_data.povinne_vytisky_listname = listname
	ch_core.save_global_data({"povinne_vytisky", "povinne_vytisky_listname"})
	return true, "Úspěšně nastaven cíl povinných výtisků."
end

local def = {
	params = "<x>,<y>,<z> <listname>",
	description = "nastaví truhlu, kam se budou ukládat povinné výtisky nově vydaných knih",
	privs = {server = true},
	func = nastavit_povinne_vytisky,
}
minetest.register_chatcommand("povinne_vytisky", def)
minetest.register_chatcommand("povinné_výtisky", def)
