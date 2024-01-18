--[[ Placeable Books by everamzah
	Copyright (C) 2016 James Stevenson
	Copyright (C) 2023 Singularis
	LGPLv2.1+
	See LICENSE for more information ]]

local F = minetest.formspec_escape
local S = minetest.get_translator("books")
local shared = ...

local load_book = books.load_book
local publish_book = shared.publish_book
local update_infotext = books.update_infotext

local player_name_to_custom_state = {}

local function assert_not_nil(x)
	if x == nil then
		error("Assertion failed: the value is nil!")
	end
	return x
end

local function on_constuct(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_size("input", 1)
	inv:set_size("paper", 4)
	inv:set_size("dye", 4)
	inv:set_size("output", 8)
	inv:set_size("recycle", 2)
	meta:set_string("infotext", S("Library Machine"))
end

local formspec_header = ch_core.formspec_header({
	formspec_version = 5,
	size = {14, 14},
	auto_background = true,
}).."item_image[0.375,0.375;1,1;books:machine]"..
	"label[1.6,0.9;Knihovní stroj]"..
	"button_exit[13,0.25;0.75,0.75;zavrit;X]"..
	"label[0.5,9;Inventář:]"..
	"list[current_player;main;2.5,8.5;8,4;]"

--[[
custom_state = {
	message = "",
	player_name,
	pos,
	recycle_type = 1,
	tabname = "copying",
	paper_price = 0,
	ink_price = 0,
}
]]

local function get_formspec(custom_state)
	local player_name = assert_not_nil(custom_state.player_name)
	local pos = assert_not_nil(custom_state.pos)
	local node_inventory = "nodemeta:"..pos.x.."\\,"..pos.y.."\\,"..pos.z
	local inv = minetest.get_meta(pos):get_inventory()
	local is_admin = minetest.check_player_privs(player_name, "protection_bypass")
	local message = custom_state.message or ""

	local formspec = {
		formspec_header,
		"tabheader[0.25,2.5;13,0.75;tab;kopírování,vydávání,recyklace",
	}
	if is_admin then
		table.insert(formspec, ",pro Administraci")
	end
	table.insert(formspec, ";")

	if custom_state.tabname == "publishing" then
		table.insert(formspec, "2;false;true]"..
			"label[0.5,3.25;Vstup (kniha):]"..
			"list["..node_inventory..";input;2.5,2.75;1,1;]"..
			"field[0.5,4.25;2.5,0.5;edition;Vydání:;1. vyd.]"..
			"textarea[3.75,2.75;9.5,2.25;;;Před vydáním si knihu důkladně zkontrolujte. Vydáváte-li nové vydání již dříve vydané knihy\\, vyplňte prosím pole „Vydání“\\, aby šlo snadno rozlišit jednotlivá vydání.]"..
			"textarea[6.25,4.25;7.5,1;;;"..F(message).."]"..
			"label[0.5,7;Výstup:]"..
			"list["..node_inventory..";output;2.5,6.5;8,1;]"..
			"button[0.5,5.25;5.5,1;vydat;permanentně vydat knihu]"..
			"button[7.0,5.25;5.5,1;stahnout;stáhnout knihu\ntěsně po vydání]"..
			"tooltip[stahnout;Stáhnout můžete pouze knihu\\, kterou jste vydal/a vy\\,\nod jejíhož vydání uplynulo méně než 12 hodin a nebyl restartován server\na z níž nevzniklo víc než 5 výtisků s IČK\\, přičemž povinné výtisky se nepočítají.]"..
			"listring["..node_inventory..";output]"..
			"listring[current_player;main]"..
			"listring["..node_inventory..";input]")

	elseif custom_state.tabname == "recyclation" then
		table.insert(formspec, "3;false;true]"..
			"label[0.5,3.25;Vstup:]"..
			"list["..node_inventory..";recycle;2.5,2.75;2,1;]"..
			"textarea[5,2.75;8.5,2.25;;;Recyklace umožňuje z dvou libovolných knih stejného formátu získat jednu čistou\\, nepopsanou\\ nebo z 1-2 libovolných knih odpovídající množství papíru.]"..
			"label[0.5,4.5;Recyklovat na:]"..
			"textlist[2.75,4.35;6,2;recyklna;knihu (barvu podle první knihy),knihu (barvu podle druhé knihy),knihu (bílou),papír;"..custom_state.recycle_type..";false]"..
			"label[0.5,7;Výstup:]"..
			"list["..node_inventory..";output;2.5,6.5;8,1;]"..
			"button[9,4.35;3.25,1;recyklovat;recyklovat]"..
			"label[0.5,8;"..F(message).."]"..
			"listring["..node_inventory..";output]"..
			"listring[current_player;main]"..
			"listring["..node_inventory..";recycle]")

	elseif custom_state.tabname == "admin" and is_admin then
		local paper_price, ink_price
		local input = inv:get_stack("input", 1)
		local book_info
		if not input:is_empty() then
			book_info = books.analyze_book(input:get_name(), input:get_meta())
		end
		if book_info ~= nil then
			paper_price, ink_price = book_info.paper_price, book_info.ink_price
		else
			paper_price, ink_price = 0, 0
		end
		table.insert(formspec, "4;false;true]"..
			"label[0.5,3.25;Vstup (kniha):]"..
			"list["..node_inventory..";input;2.5,2.75;1,1;]"..
			"button[4,2.75;2,1;analyzovat;Analyzovat]"..
			"textarea[0.5,4;13,4;analyza;;"..F(message).."]"..
			"field[6.5,3;1.25,0.5;paper_price;papírů:;"..paper_price.."]"..
			"field[8,3;1.25,0.5;ink_price;inkoustu:;"..ink_price.."]"..
			"button[9.5,2.75;2,1;zmenit;Změnit]"..
			"listring["..node_inventory..";input]"..
			"listring[current_player;main]"..
			"listring["..node_inventory..";input]")
	else
		custom_state.tabname = "copying"
		table.insert(formspec, "1;false;true]"..
			"label[0.5,3.25;Vstup (kniha):]"..
			"list["..node_inventory..";input;2.5,2.75;1,1;]"..
			"label[0.5,4.5;Papír:]"..
			"list["..node_inventory..";paper;2.5,4;4,1;]"..
			"label[0.5,5.75;Černá barva:]"..
			"list["..node_inventory..";dye;2.5,5.25;4,1;]"..
			"label[0.5,7;Výstup:]"..
			"list["..node_inventory..";output;2.5,6.5;8,1;]"..
			"button[7.75,4;5.5,1;kopie;kopírovat knihu, jak je]"..
			"listring["..node_inventory..";output]"..
			"listring[current_player;main]"..
			"listring["..node_inventory..";input]"..
			"listring[current_player;main]"..
			"listring["..node_inventory..";paper]"..
			"listring[current_player;main]"..
			"listring["..node_inventory..";dye]"..
			"listring[current_player;main]")
		-- conditional elements:
		local input = inv:get_stack("input", 1)
		local book_info = books.analyze_book(input:get_name(), input:get_meta())
		if book_info ~= nil then
			if book_info.ick ~= "" and (book_info.owner == player_name or is_admin) then
				table.insert(formspec, "button[7.75,5.25;5.5,1;ukopie;získat upravitelnou kopii vydané knihy\n(jen vaše knihy)]")
			end
			if minetest.is_creative_enabled(player_name) then
				message = "Máte právo usnadnění hry (kopírování zdarma)"
			else
				message = "Kopírování bude vyžadovat: papír ("..book_info.paper_price.." ks), černá barva ("..book_info.ink_price.." ks)"
			end
		end
		if custom_state.message ~= "" then
			message = custom_state.message
		end
		if message ~= nil then
			table.insert(formspec, "label[3.75,3.25;"..F(message).."]")
		end
	end
	return table.concat(formspec)
end

local function allow_metadata_inventory_player(player)
	local role = ch_core.get_player_role(player)
	return role ~= nil and role ~= "new"
end

local function formspec_callback(custom_state, player, formname, fields)
	local player_role = ch_core.get_player_role(custom_state.player_name)
	if fields.quit then
		player_name_to_custom_state[custom_state.player_name] = nil
		return
	end
	if player_role == nil then
		return -- unknown player
	end
	-- allow switching tabs even for new players
	if fields.tab then
		local change = custom_state.message ~= ""
		if fields.tab == "1" and custom_state.tabname ~= "copying" then
			change = true
			custom_state.tabname = "copying"
		elseif fields.tab == "2" and custom_state.tabname ~= "publishing" then
			change = true
			custom_state.tabname = "publishing"
		elseif fields.tab == "3" and custom_state.tabname ~= "recyclation" then
			change = true
			custom_state.tabname = "recyclation"
		elseif fields.tab == "4" and player_role == "admin" then
			change = true
			custom_state.tabname = "admin"
		end
		if change then
			custom_state.message = ""
			return get_formspec(custom_state)
		else
			return true
		end
	end
	if player_role == "new" then
		return
	end
	if fields.recyklna and fields.recyklna:sub(1, 4) == "CHG:" then
		local new_number = tonumber(fields.recyklna:sub(5,-1))
		if new_number ~= nil then
			custom_state.recycle_type = math.max(1, math.min(4, new_number))
		end
		return
	end
	local inv = minetest.get_meta(custom_state.pos):get_inventory()
	local input = inv:get_stack("input", 1)
	local input_name = input:get_name()
	local input_book
	if not input:is_empty() then
		input_book = books.analyze_book(input_name, input:get_meta())
	end
	if fields.vydat then
		-- publish the book
		if input_book == nil then
			return true
		end
		if not inv:room_for_item("output", input) then
			custom_state.message = "Chyba: Ve výstupním inventáři není dost místa!"
			return get_formspec(custom_state)
		end
		local ick = input_book.ick
		if ick ~= "" then
			custom_state.message = "Chyba: Tato kniha již byla vydána pod IČK "..ick.."!"
			return get_formspec(custom_state)
		end
		local owner = input_book.owner
		if owner ~= custom_state.player_name then
			if owner == "" then
				custom_state.message = "Chyba: Vydat můžete pouze knihu, kterou spravujete. Tuto knihu nespravuje nikdo!"
			else
				custom_state.message = "Chyba: Vydat můžete pouze knihu, kterou spravujete. Tuto knihu spravuje "..ch_core.prihlasovaci_na_zobrazovaci(owner).."!"
			end
			return get_formspec(custom_state)
		end
		local message
		ick, message = publish_book(input, fields.edition or "")
		if message ~= nil then
			custom_state.message = "Chyba: "..message
			return get_formspec(custom_state)
		end
		if ick == nil or ick == "" then
			error("books.publish_book() returned nil or empty ICK, but no error message!")
		end
		if inv:add_item("output", input):is_empty() then
			inv:set_stack("input", 1, ItemStack())
			custom_state.message = "Kniha byla úspěšně vydána pod IČK "..ick.."."
		else
			custom_state.message = "Chyba: Kniha se zasekla ve stroji!"
		end
		return get_formspec(custom_state)
	elseif fields.stahnout then
		-- cancel the book
		if input_book == nil then
			return true
		end
		local ick = input_book.ick
		if ick == "" then
			custom_state.message = "Chyba: Tato kniha nemá IČK!"
			return get_formspec(custom_state)
		end
		local owner = input_book.owner
		if owner ~= custom_state.player_name then
			custom_state.message = "Chyba: Stáhnout můžete pouze knihu, kterou jste vydal/a!"
			return get_formspec(custom_state)
		end
		if not inv:room_for_item("output", input) then
			custom_state.message = "Chyba: Ve výstupním inventáři není dost místa!"
			return get_formspec(custom_state)
		end
		local new_stack = ItemStack(input)
		local new_meta = new_stack:get_meta()
		local book = load_book(new_meta, nil, nil)
		new_meta:set_string("text", book.text)
		new_meta:set_string("ick", "")
		new_meta:set_string("edition", "")
		book.ick = ""
		book.edition = ""
		update_infotext(new_meta, "item", book)
		local success, message = shared.cancel_published_book(ick)
		if not success then
			custom_state.message = "Chyba: "..(message or "neznámá chyba")
			return get_formspec(custom_state)
		end
		if inv:add_item("output", new_stack):is_empty() then
			inv:set_stack("input", 1, ItemStack())
			custom_state.message = "Kniha vydaná pod IČK "..ick.." byla úspěšně stažena."
		else
			custom_state.message = "Chyba: Kniha se zasekla ve stroji!"
		end
		return get_formspec(custom_state)
	elseif fields.recyklovat then
		local input1, input2 = inv:get_stack("recycle", 1), inv:get_stack("recycle", 2)
		local book1, book2
		if not input1:is_empty() then
			book1 = books.analyze_book(input1:get_name(), input1:get_meta())
		end
		if not input2:is_empty() then
			book2 = books.analyze_book(input2:get_name(), input2:get_meta())
		end
		if book1 == nil then
			if book2 == nil then
				custom_state.message = "Chyba: není co recyklovat"
				return get_formspec(custom_state)
			end
			book1, input1 = book2, input2
			book2, input2 = nil, nil
		end
		-- assert_not_nil(book1)
		if custom_state.recycle_type ~= 4 then
			if book2 == nil or book1.format ~= book2.format then
				custom_state.message = "Chyba: recyklace na knihu vyžaduje dvě knihy stejného formátu (na barvě nezáleží!"
				return get_formspec(custom_state)
			end
			if not inv:room_for_item("output", input1) then
				custom_state.message = "Chyba: Ve výstupním inventáři není dost místa!"
				return get_formspec(custom_state)
			end
		end

		local new_stack
		if custom_state.recycle_type == 1 then
			-- empty book, color according to the first book
			new_stack = ItemStack(input1:get_name())
			new_stack:get_meta():set_int("palette_index", input1:get_meta():get_int("palette_index"))
		elseif custom_state.recycle_type == 2 then
			-- empty book, color according to the second book
			new_stack = ItemStack(input2:get_name())
			new_stack:get_meta():set_int("palette_index", input2:get_meta():get_int("palette_index"))
		elseif custom_state.recycle_type == 3 then
			-- white book
			if book1.format == "B5" then
				new_stack = ItemStack("books:book_b5_closed_grey")
			else
				new_stack = ItemStack("books:book_b6_closed_grey")
			end
		else
			-- papers
			local output_count = book1.paper_price
			if book2 ~= nil then
				output_count = math.floor((output_count + book2.paper_price) / 2)
			end
			if output_count == 0 then
				inv:set_list("recycle", {})
				custom_state.message = "Vstup byl spotřebován, ale nevyprodukoval žádný papír."
				return get_formspec(custom_state)
			end
			if output_count > 65535 then
				output_count = 65535
			end
			new_stack = ItemStack("default:paper "..output_count)
			if not inv:room_for_item("output", new_stack) then
				custom_state.message = "Chyba: Ve výstupním inventáři není dost místa pro "..output_count.." papírů!"
				return get_formspec(custom_state)
			end
		end
		inv:set_list("recycle", {})
		inv:add_item("output", new_stack)
		custom_state.message = ""
		return get_formspec(custom_state)

	elseif fields.kopie or fields.ukopie then
		-- make a copy of the book
		if input_book == nil then
			return true
		end
		if fields.ukopie then
			if input_book.ick == "" then
				custom_state.message = "Chyba: Kniha nemá IČK!"
				return get_formspec(custom_state)
			end
			if input_book.owner == "" then
				custom_state.message = "Chyba: Knihu musíte spravovat, tuto knihu nespravuje nikdo!"
				return get_formspec(custom_state)
			end
			if input_book.owner ~= custom_state.player_name then
				custom_state.message = "Chyba: Knihu musíte spravovat, tuto knihu spravuje "..ch_core.prihlasovaci_na_zobrazovaci(input_book.owner).."!"
				return get_formspec(custom_state)
			end
		end
		if not inv:room_for_item("output", input) then
			custom_state.message = "Chyba: Ve výstupním inventáři není dost místa!"
			return get_formspec(custom_state)
		end
		if not minetest.is_creative_enabled(custom_state.player_name) then
			local paper_stack = ItemStack("default:paper "..input_book.paper_price)
			local ink_stack = ItemStack("dye:black "..input_book.ink_price)
			if not inv:contains_item("paper", paper_stack) or not inv:contains_item("dye", ink_stack) then
				custom_state.message = "Chyba: Kopírování této knihy vyžaduje "..input_book.paper_price.." listů papíru a "..input_book.ink_price.." ks černé barvy!"
				return get_formspec(custom_state)
			end
			inv:remove_item("paper", paper_stack)
			inv:remove_item("dye", ink_stack)
		end
		local new_stack
		if fields.ukopie then
			new_stack = ItemStack(input)
			local new_meta = new_stack:get_meta()
			local book = load_book(new_meta, nil, nil)
			new_meta:set_string("text", book.text)
			new_meta:set_string("ick", "")
			new_meta:set_string("edition", "")
			book.ick = ""
			book.edition = ""
			update_infotext(new_meta, "item", book)
		else
			new_stack = input
			books.announce_book_copy(new_stack)
		end
		inv:add_item("output", new_stack)
		custom_state.message = "Kniha byla úspěšně zkopírována."
		return get_formspec(custom_state)
	elseif fields.analyzovat and player_role == "admin" then
		if input_book == nil then
			custom_state.message = ""
		end
		custom_state.message = dump2(input:get_meta():to_table())
		return get_formspec(custom_state)
	elseif fields.zmenit and player_role == "admin" then
		if input_book == nil then
			custom_state.message = ""
			return true
		end
		local paper_price, ink_price = input_book.paper_price, input_book.ink_price
		if fields.paper_price and tonumber(fields.paper_price) ~= nil then
			paper_price = math.max(1, tonumber(fields.paper_price))
		end
		if fields.ink_price and tonumber(fields.ink_price) ~= nil then
			ink_price = math.max(1, tonumber(fields.ink_price))
		end
		custom_state.paper_price = paper_price
		custom_state.ink_price = ink_price
		local meta = input:get_meta()
		meta:set_int("paper_price", paper_price)
		meta:set_int("ink_price", ink_price)
		inv:set_stack("input", 1, input)
		return get_formspec(custom_state)
	end
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if not allow_metadata_inventory_player(player) then
		return 0
	end
	local name = stack:get_name()
	if listname == "input" then
		-- only books are allowed
		if books.analyze_book(name, stack:get_meta()) == nil then
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

local function on_metadata_inventory_put(pos, listname, index, stack, player)
	local player_name = player and player:get_player_name()
	local custom_state = player_name and player_name_to_custom_state[player_name]
	if not custom_state then
		return
	end
	if listname == "input" then
		-- a book inserted to the input, update formspec
		assert_not_nil(custom_state.player_name)
		ch_core.show_formspec(player, "books:machine", get_formspec(custom_state), formspec_callback, custom_state, {})
	end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local inv = minetest.get_meta(pos):get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	stack:set_count(count)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local inv = minetest.get_meta(pos):get_inventory()
	local stack = inv:get_stack(to_list, to_index)
	stack:set_count(count)
	return on_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if not allow_metadata_inventory_player(player) then
		return 0
	end
	return stack:get_count()
end

local function on_metadata_inventory_take(pos, listname, index, stack, player)
	local player_name = player and player:get_player_name()
	local custom_state = player_name and player_name_to_custom_state[player_name]
	if not custom_state then
		return
	end
	if listname == "input" then
		-- a book removed from the input, update formspec
		assert_not_nil(custom_state.player_name)
		ch_core.show_formspec(player, "books:machine", get_formspec(custom_state), formspec_callback, custom_state, {})
	end
end

local function on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	local player_name = clicker and clicker:get_player_name()
	if not player_name then
		return itemstack
	end
	local custom_state = {
		message = "",
		player_name = assert_not_nil(player_name),
		pos = pos,
		recycle_type = 1,
		tabname = "copying",
		paper_price = 0,
		ink_price = 0,
	}
	player_name_to_custom_state[player_name] = custom_state
	local formspec = get_formspec(custom_state)
	ch_core.show_formspec(clicker, "books:machine", formspec, formspec_callback, custom_state, {})
	return itemstack
end

local empty_tile = {name = "ch_core_white_pixel.png", backface_culling = true}
local front_tile = {name = "ch_core_white_pixel.png^[resize:32x32^(default_book.png^[resize:32x32)", backface_culling = true}
local def = {
	description = S("Library Machine"),
	tiles = {
		empty_tile, empty_tile,
		empty_tile, empty_tile,
		empty_tile, front_tile,
	},
	paramtype2 = "facedir",
	is_ground_content = false,
	stack_max = 1,
	groups = {cracky = 1},
	sounds = default.node_sound_defaults(),

	on_construct = on_constuct,
	on_rightclick = on_rightclick,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	on_metadata_inventory_move = on_metadata_inventory_move,
	on_metadata_inventory_put = on_metadata_inventory_put,
	on_metadata_inventory_take = on_metadata_inventory_take,
}

minetest.register_node("books:machine", def)
