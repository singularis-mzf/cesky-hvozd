--[[ Placeable Books by everamzah
	Copyright (C) 2016 James Stevenson
	Copyright (C) 2023 Singularis
	LGPLv2.1+
	See LICENSE for more information ]]

local F = minetest.formspec_escape
local S = minetest.get_translator("books")

local get_book_price = books.get_book_price
local load_book = books.load_book
local publish_book = books.publish_book
local update_infotext = books.update_infotext

local function on_constuct(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_size("input", 1)
	inv:set_size("paper", 4)
	inv:set_size("dye", 4)
	inv:set_size("output", 8)
	meta:set_string("infotext", S("Library Machine"))
end

local function get_formspec(pos, message)
	local spos = pos.x.."\\,"..pos.y.."\\,"..pos.z
	local formspec = {
		"formspec_version[5]",
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
		"box[3.625,2.0;9.825,1;#006600FF]", -- pozadí pod vydání
		"label[3.75,2.5;Vydání:]",
		"field[5,2.25;2.5,0.5;edition;;1. vyd.]",
		"button[7.75,2.15;5.5,0.75;vydat;permanentně vydat knihu]",
		"button[7.75,3.85;5.5,0.75;kopie;kopírovat knihu, jak je]",
		"button[7.75,4.7;5.5,0.75;upravit;získat upravitelnou kopii vydané knihy]",
		"listring[nodemeta:", spos, ";output]",
		"listring[current_player;main]",
		"listring[nodemeta:", spos, ";input]",
		"listring[current_player;main]",
		"listring[nodemeta:", spos, ";paper]",
		"listring[current_player;main]",
		"listring[nodemeta:", spos, ";dye]",
		"listring[current_player;main]",
	}
	if message ~= nil then
		formspec[#formspec + 1] = "label[2.5,7.5;"..F(message).."]"
	end
	-- button[7.75,4.7;5.5,0.75;test;test]
	-- label[2.5,7.5;Chyba: Nastala neznámá chyba.]
	return table.concat(formspec)
end

local function allow_metadata_inventory_player(player)
	local role = ch_core.get_player_role(player)
	return role ~= nil and role ~= "new"
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if not allow_metadata_inventory_player(player) then
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

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local inv = minetest.get_meta(pos):get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	stack:set_count(count)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if not allow_metadata_inventory_player(player) then
		return 0
	end
	return stack:get_count()
end

local function formspec_callback(custom_state, player, formname, fields)
	if not allow_metadata_inventory_player(player) or fields.quit then
		return
	end
	local player_role = ch_core.get_player_role(player)
	if player_role == "new" then
		return
	end
	local inv = minetest.get_meta(custom_state.pos):get_inventory()
	local input = inv:get_stack("input", 1)
	if input:is_empty() then
		return -- no input book
	end
	local formspec
	local input_name = input:get_name()
	local book_kind = minetest.get_item_group(input_name, "book")
	if book_kind == 0 then
		-- no book
		return
	end
	if fields.vydat then
		-- publish the book
		if not inv:room_for_item("output", input) then
			return get_formspec(custom_state.pos, "Chyba: Ve výstupním inventáři není dost místa!")
		end
		local meta = input:get_meta()
		local ick = meta:get_string("ick")
		if ick ~= "" then
			return get_formspec(custom_state.pos, "Chyba: Tato kniha již byla vydána pod IČK "..ick.."!")
		end
		local owner = meta:get_string("owner")
		if owner ~= player:get_player_name() then
			if owner == "" then
				return get_formspec(custom_state.pos, "Chyba: Vydat můžete pouze knihu, kterou spravujete. Tuto knihu nespravuje nikdo!")
			else
				return get_formspec(custom_state.pos, "Chyba: Vydat můžete pouze knihu, kterou spravujete. Tuto knihu spravuje "..ch_core.prihlasovaci_na_zobrazovaci(owner).."!")
			end
		end
		local message
		ick, message = publish_book(input, fields.edition or "")
		if message ~= nil then
			return get_formspec(custom_state.pos, "Chyba: "..message)
		end
		if ick == nil or ick == "" then
			error("books.publish_book() returned nil or empty ICK, but no error message!")
		end
		if inv:add_item("output", input):is_empty() then
			inv:set_stack("input", 1, ItemStack())
			return get_formspec(custom_state.pos, "Kniha byla úspěšně vydána pod IČK "..ick..".")
		else
			return get_formspec(custom_state.pos, "Chyba: Kniha se zasekla ve stroji!")
		end
	elseif fields.kopie then
		-- make an exact copy of the book
		local paper, ink
		if not inv:room_for_item("output", input) then
			return get_formspec(custom_state.pos, "Chyba: Ve výstupním inventáři není dost místa!")
		end
		if not minetest.is_creative_enabled(player:get_player_name()) then
			paper, ink = get_book_price(input_name, input:get_meta())
			local paper_stack = ItemStack("default:paper "..paper)
			local ink_stack = ItemStack("dye:black "..ink)
			if not inv:contains_item("paper", paper_stack) or not inv:contains_item("dye", ink_stack) then
				return get_formspec(custom_state.pos, "Chyba: Kopírování této knihy vyžaduje "..paper.." listů papíru a "..ink.." ks černé barvy!")
			end
			inv:remove_item("paper", paper_stack)
			inv:remove_item("dye", ink_stack)
		end
		inv:add_item("output", input)
		return get_formspec(custom_state.pos, "Kniha byla úspěšně zkopírována.")
	elseif fields.upravit then
		-- make an editable copy of the published book
		if not inv:room_for_item("output", input) then
			return get_formspec(custom_state.pos, "Chyba: Ve výstupním inventáři není dost místa!")
		end
		local meta = input:get_meta()
		local ick = meta:get_string("ick")
		if ick == "" then
			return get_formspec(custom_state.pos, "Chyba: Kniha nemá IČK!")
		end
		local owner = meta:get_string("owner")
		if owner ~= player:get_player_name() then
			if owner == "" then
				return get_formspec(custom_state.pos, "Chyba: Knihu musíte spravovat, tuto knihu nespravuje nikdo!")
			else
				return get_formspec(custom_state.pos, "Chyba: Knihu musíte spravovat, tuto knihu spravuje "..ch_core.prihlasovaci_na_zobrazovaci(owner).."!")
			end
		end
		local paper, ink
		if not minetest.is_creative_enabled(player:get_player_name()) then
			paper, ink = books.get_book_price(input_name, meta)
			local paper_stack = ItemStack("default:paper "..paper)
			local ink_stack = ItemStack("dye:black "..ink)
			if not inv:contains_item("paper", paper_stack) or not inv:contains_item("dye", ink_stack) then
				return get_formspec(custom_state.pos, "Chyba: Kopírování této knihy vyžaduje "..paper.." listů papíru a "..ink.." ks černé barvy!")
			end
			inv:remove_item("paper", paper_stack)
			inv:remove_item("dye", ink_stack)
		end
		local book = load_book(meta, nil, nil)
		meta:set_string("text", book.text)
		meta:set_string("ick", "")
		meta:set_string("edition", "")
		book.ick = ""
		book.edition = ""
		update_infotext(meta, "item", book)
		inv:add_item("output", input)
		return get_formspec(custom_state.pos, "Kniha byla úspěšně zkopírována.")
	end
end

local function on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	local player_name = clicker and clicker:get_player_name()
	if not player_name then
		return itemstack
	end
	local formspec = get_formspec(pos)
	ch_core.show_formspec(clicker, "books:machine", formspec, formspec_callback, {pos = pos}, {})
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
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	on_construct = on_constuct,
	on_rightclick = on_rightclick,
}

minetest.register_node("books:machine", def)
