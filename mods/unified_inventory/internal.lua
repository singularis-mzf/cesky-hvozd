local S = minetest.get_translator("unified_inventory")
local F = minetest.formspec_escape
local ui = unified_inventory

-- This pair of encoding functions is used where variable text must go in
-- button names, where the text might contain formspec metacharacters.
-- We can escape button names for the formspec, to avoid screwing up
-- form structure overall, but they then don't get de-escaped, and so
-- the input we get back from the button contains the formspec escaping.
-- This is a game engine bug, and in the anticipation that it might be
-- fixed some day we don't want to rely on it.  So for safety we apply
-- an encoding that avoids all formspec metacharacters.

function ui.mangle_for_formspec(str)
	return string.gsub(str, "([^A-Za-z0-9])", function (c) return string.format("_%d_", string.byte(c)) end)
end
function ui.demangle_for_formspec(str)
	return string.gsub(str, "_([0-9]+)_", function (v) return string.char(v) end)
end

-- Get the player-specific unified_inventory style
function ui.get_per_player_formspec(player_name)
	local draw_lite_mode = ui.lite_mode and not minetest.check_player_privs(player_name, {ui_full=true})
	draw_lite_mode = false

	local style = table.copy(draw_lite_mode and ui.style_lite or ui.style_full)
	style.is_lite_mode = draw_lite_mode
	return style
end

-- Creates an item image or regular image button with a tooltip
local function formspec_button(ui_peruser, name, image, offset, pos, scale, label)
	local element = 'image_button'
	if minetest.registered_items[image] then
		element = 'item_image_button'
	elseif image:find(":", 1, true) then
		image = "unknown_item.png"
	end
	local spc = (1-scale)*ui_peruser.btn_size/2
	local size = ui_peruser.btn_size*scale
	return string.format("%s[%f,%f;%f,%f;%s;%s;]", element,
		(offset.x or offset[1]) + ( ui_peruser.btn_spc * (pos.x or pos[1]) ) + spc,
		(offset.y or offset[2]) + ( ui_peruser.btn_spc * (pos.y or pos[2]) ) + spc,
		size, size, image, name) ..
		string.format("tooltip[%s;%s]", name, F(label or name))
end

-- Add registered buttons (tabs)
local function formspec_tab_buttons(player, formspec, style)
	local n = #formspec + 1

	-- Main buttons

	local filtered_inv_buttons = {}

	for i, def in pairs(ui.buttons) do
		if not (style.is_lite_mode and def.hide_lite) then
			table.insert(filtered_inv_buttons, def)
		end
	end

	local needs_scrollbar = #filtered_inv_buttons > style.main_button_cols * style.main_button_rows

	formspec[n] = ("scroll_container[%g,%g;%g,%g;tabbtnscroll;vertical]"):format(
		style.main_button_x, style.main_button_y, -- position
		style.main_button_cols * style.btn_spc, style.main_button_rows -- size
	)
	n = n + 1

	for i, def in pairs(filtered_inv_buttons) do
		local pos_x =           ((i - 1) % style.main_button_cols) * style.btn_spc
		local pos_y = math.floor((i - 1) / style.main_button_cols) * style.btn_spc

		if def.type == "image" then
			if (def.condition == nil or def.condition(player) == true) then
				formspec[n] = string.format("image_button[%g,%g;%g,%g;%s;%s;]",
					pos_x, pos_y, style.btn_size, style.btn_size,
					F(def.image),
					F(def.name))
				formspec[n+1] = "tooltip["..F(def.name)..";"..(def.tooltip or "").."]"
				n = n+2
			else
				formspec[n] = string.format("image[%g,%g;%g,%g;%s^[colorize:#808080:alpha]",
					pos_x, pos_y, style.btn_size, style.btn_size,
					def.image)
				n = n+1
			end
		end
	end
	formspec[n] = "scroll_container_end[]"
	if needs_scrollbar then
		formspec[n+1] = ("scrollbaroptions[max=%i;arrows=hide]"):format(
			-- This calculation is not 100% accurate but "good enough"
			math.ceil((#filtered_inv_buttons - 1) / style.main_button_cols) * style.btn_spc * 5
		)
		formspec[n+2] = ("scrollbar[%g,%g;0.4,%g;vertical;tabbtnscroll;0]"):format(
			style.main_button_x + style.main_button_cols * style.btn_spc - 0.1, -- x pos
			style.main_button_y, -- y pos
			style.main_button_rows * style.btn_spc -- height
		)
		formspec[n+3] = "scrollbaroptions[max=1000;arrows=default]"
	end
end

-- Add category GUI elements (top right)
local function formspec_add_categories(player, formspec, ui_peruser)
	local n = #formspec + 1
	local x, y = ui_peruser.page_x, ui_peruser.page_y - 1.5
	local category_descs = ch_core.creative_inventory.categories.descriptions
	local category_icons = ch_core.creative_inventory.categories.icons
	local category_count = #category_descs
	assert(#category_descs == #category_icons)

	--[[
	formspec[n] = "dropdown["..x..","..y..";6.75,0.5;ui_category;"
	n = n + 1
	formspec[n] = minetest.formspec_escape(category_descs[1])
	n = n + 1
	for i = 2, #category_descs do
		formspec[n] = ","..minetest.formspec_escape(category_descs[i])
		n = n + 1
	end
	formspec[n] = ";"..(ui.current_category[player:get_player_name()] or "1")..";true]"
	]]

	formspec[n] = "tablecolumns[image"
	for i = 1, category_count do
		formspec[n + i] = ","..(i - 1).."="..minetest.formspec_escape(category_icons[i])
	end
	n = n + category_count + 1
	formspec[n] = ";text]"
	formspec[n + 1] = "table["..x..","..y..";6.7,1.4;ui_category;0,"..minetest.formspec_escape(category_descs[1])
	for i = 2, category_count do
		formspec[n + i] = ","..(i - 1)..","..minetest.formspec_escape(category_descs[i])
	end
	n = n + category_count + 1
	formspec[n] = ";"..(ui.current_category[player:get_player_name()] or "1").."]"
	-- return nil
--[[
	local player_name = player:get_player_name()
	local n = #formspec + 1

	local categories_pos = {
		ui_peruser.page_x,
		ui_peruser.page_y-ui_peruser.btn_spc-0.5
	}
	local categories_scroll_pos = {
		ui_peruser.page_x,
		ui_peruser.form_header_y - (ui_peruser.is_lite_mode and 0 or 0.2)
	}

	formspec[n] = string.format("background9[%f,%f;%f,%f;%s;false;16]",
		ui_peruser.page_x-0.15, categories_scroll_pos[2],
		(ui_peruser.btn_spc * ui_peruser.pagecols) + 0.2, 1.4 + (ui_peruser.is_lite_mode and 0 or 0.2),
		"ui_smallbg_9_sliced.png")
	n = n + 1

	formspec[n] = string.format("label[%f,%f;%s]",
		ui_peruser.page_x,
		ui_peruser.form_header_y + (ui_peruser.is_lite_mode and 0.3 or 0.2), F(S("Category:")))
	n = n + 1

	local scroll_offset = 0
	local category_count = #ui.category_list
	if category_count > ui_peruser.pagecols then
		scroll_offset = ui.current_category_scroll[player_name]
	end

	for index, category in ipairs(ui.category_list) do
		local column = index - scroll_offset
		if column > 0 and column <= ui_peruser.pagecols then
			local scale = 0.8
			if ui.current_category[player_name] == category.name then
				scale = 1
			end
			formspec[n] = formspec_button(ui_peruser, "category_"..category.name, category.symbol, categories_pos, {column-1, 0}, scale, category.label)
			n = n + 1
		end
	end
	if category_count > ui_peruser.pagecols and scroll_offset > 0 then
		-- prev
		formspec[n] = formspec_button(ui_peruser, "prev_category", "ui_left_icon.png", categories_scroll_pos, {ui_peruser.pagecols - 2, 0}, 0.8, S("Scroll categories left"))
		n = n + 1
	end
	if category_count > ui_peruser.pagecols and category_count - scroll_offset > ui_peruser.pagecols then
		-- next
		formspec[n] = formspec_button(ui_peruser, "next_category", "ui_right_icon.png", categories_scroll_pos, {ui_peruser.pagecols - 1, 0}, 0.8, S("Scroll categories right"))
	end
]]
end

local function formspec_add_search_box(player, formspec, ui_peruser)
	local player_name = player:get_player_name()
	local n = #formspec + 1

	formspec[n] = "field_close_on_enter[searchbox;false]"

	formspec[n+1] = string.format("field[%f,%f;%f,%f;searchbox;;%s]",
		ui_peruser.page_buttons_x, ui_peruser.page_buttons_y,
		ui_peruser.searchwidth - 0.1, ui_peruser.btn_size,
		F(ui.current_searchbox[player_name]))
	formspec[n+2] = string.format("image_button[%f,%f;%f,%f;ui_search_icon.png;searchbutton;]",
		ui_peruser.page_buttons_x + ui_peruser.searchwidth, ui_peruser.page_buttons_y,
		ui_peruser.btn_size,ui_peruser.btn_size)
	formspec[n+3] = "tooltip[searchbutton;" ..F(S("Search")) .. "]"
	formspec[n+4] = string.format("image_button[%f,%f;%f,%f;ui_reset_icon.png;searchresetbutton;]",
		ui_peruser.page_buttons_x + ui_peruser.searchwidth + ui_peruser.btn_spc,
		ui_peruser.page_buttons_y,
		ui_peruser.btn_size, ui_peruser.btn_size)
	formspec[n+5] = "tooltip[searchresetbutton;"..F(S("Reset search and display everything")).."]"

	--[[ if ui.activefilter[player_name] ~= "" then
		formspec[n+6] = string.format("label[%f,%f;%s: %s]",
			ui_peruser.page_x, ui_peruser.page_y - 0.25,
			F(S("Filter")), F(ui.activefilter[player_name]))
	end ]]
end

local function formspec_add_item_browser(player, formspec, ui_peruser)
	local player_name = player:get_player_name()
	local n = #formspec + 1

	-- Controls to flip items pages

	local btnlist = {
		{ "ui_skip_backward_icon.png", "start_list", S("First page") },
		{ "ui_doubleleft_icon.png",    "rewind3",    S("Back three pages") },
		{ "ui_left_icon.png",          "rewind1",    S("Back one page") },
		{ "ui_right_icon.png",         "forward1",   S("Forward one page") },
		{ "ui_doubleright_icon.png",   "forward3",   S("Forward three pages") },
		{ "ui_skip_forward_icon.png",  "end_list",   S("Last page") },
	}

	if ui_peruser.is_lite_mode then
		btnlist[2] = nil
		btnlist[5] = nil
	end

	local bn = 0
	for _, b in pairs(btnlist) do
		formspec[n] =  string.format("image_button[%f,%f;%f,%f;%s;%s;]",
			ui_peruser.page_buttons_x + ui_peruser.btn_spc*bn,
			ui_peruser.page_buttons_y + ui_peruser.btn_spc,
			ui_peruser.btn_size, ui_peruser.btn_size,
			b[1],b[2])
		formspec[n+1] = "tooltip["..b[2]..";"..F(b[3]).."]"
		bn = bn + 1
		n = n + 2
	end

	-- Items list
	if #ui.filtered_items_list[player_name] == 0 then
		local no_matches = S("No matching items")
		if ui_peruser.is_lite_mode then
			no_matches = S("No matches.")
		end

		formspec[n] = "label["..ui_peruser.page_x..","..(ui_peruser.page_y+0.15)..";" .. F(no_matches) .. "]"
		return
	end

	local dir = ui.active_search_direction[player_name]
	local list_index = ui.current_index[player_name]
	local page2 = math.floor(list_index / (ui_peruser.items_per_page) + 1)
	local pagemax = math.floor(
		(#ui.filtered_items_list[player_name] - 1)
			/ (ui_peruser.items_per_page) + 1)
	for y = 0, ui_peruser.pagerows - 1 do
		for x = 0, ui_peruser.pagecols - 1 do
			local itemstring = ui.filtered_items_list[player_name][list_index]
			if itemstring then
				local stack = ItemStack(itemstring)
				local name = stack:get_name()
				local item = minetest.registered_items[name]
				-- Clicked on current item: Flip crafting direction
				if name == ui.get_current_item(player_name, false) then
					local cdir = ui.current_craft_direction[player_name]
					if cdir == "recipe" then
						dir = "usage"
					elseif cdir == "usage" then
						dir = "recipe"
					end
				else
				-- Default: use active search direction by default
					dir = ui.active_search_direction[player_name]
				end

				local button_name = "item_button_" .. dir .. "_"
					.. ui.mangle_for_formspec(itemstring)
				formspec[n] = ("item_image_button[%f,%f;%f,%f;%s;%s;]"):format(
					ui_peruser.page_x + x * ui_peruser.btn_spc,
					ui_peruser.page_y + y * ui_peruser.btn_spc,
					ui_peruser.btn_size, ui_peruser.btn_size,
					minetest.formspec_escape(itemstring), button_name
				)
				local tooltip = item.description
				local color = stack:get_meta():get_int("palette_index")
				if color > 0 then
					tooltip = tooltip.." [barva "..color.."]"
				end
				--[[ if item.mod_origin then
					-- "mod_origin" may not be specified for items that were
					-- registered in a callback (during or before ServerEnv init)
					tooltip = tooltip .. " [" .. item.mod_origin .. "]"
				end ]]
				if item._ch_help then
					tooltip = tooltip.."\n"..minetest.get_color_escape_sequence("#f6ff00")..item._ch_help
				end
				formspec[n + 1] = ("tooltip[%s;%s]"):format(
					button_name, minetest.formspec_escape(tooltip)
				)
				n = n + 2
				list_index = list_index + 1
			end
		end
	end
	local label_text = S("Page").." "..S("@1 of @2",page2,pagemax)
	if ui.activefilter[player_name] ~= "" then
		label_text = label_text.." ("..S("Filter")..": "..ui.activefilter[player_name]..")"
	end
	formspec[n] = string.format("label[%f,%f;%s]",
		ui_peruser.page_buttons_x + ui_peruser.btn_spc * (ui_peruser.is_lite_mode and 1 or 2),
		ui_peruser.page_buttons_y + 0.1 + ui_peruser.btn_spc * 2,
		F(label_text))
end

function ui.get_formspec(player, page)

	if not player then
		return ""
	end

	local player_name = player:get_player_name()
	local ui_peruser = ui.get_per_player_formspec(player_name)

	ui.current_page[player_name] = page
	local pagedef = ui.pages[page]

	if not pagedef then
		return "" -- Invalid page name
	end

	local fs = {
		"formspec_version[6]",
		"size["..ui_peruser.formw..","..ui_peruser.formh.."]",
		pagedef.formspec_prepend and "" or "no_prepend[]",
		ui.standard_background
	}

	local perplayer_formspec = ui.get_per_player_formspec(player_name)
	local fsdata = pagedef.get_formspec(player, perplayer_formspec)

	fs[#fs + 1] = fsdata.formspec

	formspec_tab_buttons(player, fs, ui_peruser)

	if fsdata.draw_inventory ~= false then
		-- Player inventory
		local has_extended_inventory = ch_data.offline_charinfo[player_name].extended_inventory == 1

		if has_extended_inventory then
			fs[#fs + 1] = string.format("scroll_container[%f,%f;%f,%f;ui_sb_main_inv;vertical]",
				ui_peruser.std_inv_x + ui.list_img_offset, ui_peruser.std_inv_y + ui.list_img_offset,
				8 * ui.imgscale, 4 * ui.imgscale)
			fs[#fs + 1] = string.format("box[0,%f;10,10;#00000099]", 4 * ui.imgscale + 0 * ui.list_img_offset)
		else
			fs[#fs + 1] =  string.format("container[%f,%f]", ui_peruser.std_inv_x + ui.list_img_offset, ui_peruser.std_inv_y + ui.list_img_offset)
		end
		fs[#fs + 1] = ui.make_inv_img_grid(0, 0, 8, 1, true)
		if has_extended_inventory then
			fs[#fs + 1] = ui.make_inv_img_grid(0, 0 + ui.imgscale, 8, 7)
		else
			fs[#fs + 1] = ui.make_inv_img_grid(0, 0 + ui.imgscale, 8, 3)
		end
		fs[#fs + 1] = "listcolors[#00000000;#00000000]"
		if has_extended_inventory then
			fs[#fs + 1] = string.format("list[current_player;main;%f,%f;8,8;]", ui.list_img_offset, ui.list_img_offset)
			fs[#fs + 1] = "scroll_container_end[]"..
				"scrollbaroptions[max=50]"..
				string.format("scrollbar[%f,%f;0.25,%f;vertical;ui_sb_main_inv;0]",
					ui_peruser.std_inv_x + ui.list_img_offset - 0.25, ui_peruser.std_inv_y + 0.2, 4 * ui.imgscale - 0.1)..
				"tooltip[ui_sb_main_inv;Tip: k přístupu do skryté části vašeho inventáře\nmůžete použít také kolečko myši.]"
		else
			fs[#fs + 1] = string.format("list[current_player;main;%f,%f;8,4;]", ui.list_img_offset, ui.list_img_offset)
			fs[#fs + 1] = "container_end[]"
		end
		local ch_bank = ui.ch_bank
		if ch_bank then
			fs[#fs + 1] = ch_bank.get_zustatek_formspec(player_name, ui_peruser.money_x, ui_peruser.money_y, 10, "penize", "hcs", "kcs", "zcs")
		end
	end

	if fsdata.draw_item_list == false then
		return table.concat(fs, "")
	end

	formspec_add_categories(player, fs, ui_peruser)
	formspec_add_search_box(player, fs, ui_peruser)
	formspec_add_item_browser(player, fs, ui_peruser)

	return table.concat(fs)
end

function ui.set_inventory_formspec(player, page)
	if player then
		player:set_inventory_formspec(ui.get_formspec(player, page))
	end
end

local function valid_def(def)
	return (not def.groups.not_in_creative_inventory
			or def.groups.not_in_creative_inventory == 0)
		and def.description
		and def.description ~= ""
end

local filter_translate = {
	["typ:barvitelné"] = "group:ud_param2_colorable",
	["typ:barvy"] = "group:basic_dye",
	["typ:cestbudky"] = "group:travelnet",
	["typ:oblečení"] = "group:clothing", -- vše oblékatelné včetně obuvi, ale kromě plášťů
	["typ:kmeny"] = "group:tree",
	["typ:květiny"] = "group:flower", -- včetně bonsají
	["typ:lakované"] = "group:ud_param2_colorable",
	["typ:listí_a_jehličí"] = "group:leaves", -- včetně břečťanu a liány
	["typ:lokomotivy"] = "group:at_loco",
	["typ:na_cnc"] = "group:na_cnc",
	["typ:na_cnc_i_kp"] = "group:na_cnc,na_kp",
	["typ:na_kp"] = "group:na_kp",
	["typ:na_kp_i_cnc"] = "group:na_cnc,na_kp",
	["typ:pláště"] = "group:cape",
	["typ:roury"] = "group:pipeworks",
	["typ:vlaky"] = "group:at_wagon", -- všechny typy vagonů, lokomotiv, apod.
	["typ:všechny_barvy"] = "group:dye",
	["typ:zvířata"] = "group:spawn_egg",
}

for k, v in pairs(table.copy(filter_translate)) do
	local k2 = ch_core.odstranit_diakritiku(k)
	if k2 ~= k then
		if filter_translate[k2] then
			error("filter_translate conflict: "..k2)
		end
		filter_translate[k2] = v
	end
end

--apply filter to the inventory list (create filtered copy of full one)
function ui.apply_filter(player, filter, search_dir)
	if not player then
		return false
	end
	local player_name, contains_extended, lower, lfilter, ffilter

	player_name = player:get_player_name()
	contains_extended = filter ~= ch_core.odstranit_diakritiku(filter)
	if contains_extended then
		-- pattern contains extended characters
		lower = ch_core.na_mala_pismena
		lfilter = lower(filter)
	else
		-- pattern does not contain extended characters
		-- => remove extended characters from tested strings
		lower = function(s)
			return string.lower(ch_core.odstranit_diakritiku(s))
		end
		lfilter = string.lower(filter)
	end

	if filter_translate[lfilter] then
		lfilter = filter_translate[lfilter]
	end

	if lfilter:sub(1, 6) == "group:" then
		local groups = lfilter:sub(7):split(",")
		ffilter = function(itemstring, name, def)
			for _, group in ipairs(groups) do
				local vgroup = ch_core.try_read_vgroup(group)
				if vgroup then
					if not vgroup[name] then
						return false
					end
				elseif not def.groups[group] or def.groups[group] <= 0 then
					return false
				end
			end
			return true
		end
	else
		local player_info = minetest.get_player_information(player_name)
		local lang = player_info and player_info.lang_code or ""

		ffilter = function(itemstring, name, def)
			if string.find(lower(name), lfilter, 1, true)
			or string.find(lower(def.description), lfilter, 1, true) then
				return true
			end
			local llocaldesc = minetest.get_translated_string
				and lower(minetest.get_translated_string(lang, def.description))
			return llocaldesc and string.find(llocaldesc, lfilter, 1, true)
		end
	end

	local category = ui.current_category[player_name] or 1
	local category_filter = assert(ch_core.creative_inventory.categories.filter)

	local filtered_items_list = {}

	for _, itemstring in ipairs(ch_core.creative_inventory.items_by_order) do
		local name = ItemStack(itemstring):get_name()
		local def = minetest.registered_items[name]
		if string.sub(category_filter[itemstring], category, category) == "1" and ffilter(itemstring, name, def) then
			table.insert(filtered_items_list, itemstring)
		end
	end
	-- ui.filtered_items_list[player_name] = filtered_items_list
	--[[if category == 'all' then
		for name, def in pairs(minetest.registered_items) do
			if valid_def(def)
			and ffilter(name, def) then
				table.insert(ui.filtered_items_list[player_name], name)
			end
		end
	elseif category == 'uncategorized' then
		for name, def in pairs(minetest.registered_items) do
			if (not ui.find_category(name))
			and valid_def(def)
			and ffilter(name, def) then
				table.insert(ui.filtered_items_list[player_name], name)
			end
		end
	else
		for name,exists in pairs(ui.registered_category_items[category]) do
			local def = minetest.registered_items[name]
			if exists and def
			and valid_def(def)
			and ffilter(name, def) then
				table.insert(ui.filtered_items_list[player_name], name)
			end
		end
	end
	table.sort(ui.filtered_items_list[player_name])
	]]
	ui.filtered_items_list[player_name] = filtered_items_list
	ui.filtered_items_list_size[player_name] = #filtered_items_list
	ui.current_index[player_name] = 1
	ui.activefilter[player_name] = filter
	ui.active_search_direction[player_name] = search_dir
	ui.set_inventory_formspec(player, ui.current_page[player_name])
end

-- Inform players about potential visual issues
minetest.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	local info = minetest.get_player_information(player_name)
	if info and (info.formspec_version or 0) < 6 then
		minetest.chat_send_player(player_name, S("Unified Inventory: Your game version is too old"
			.. " and does not support the GUI requirements. You might experience visual issues."))
	end
end)
