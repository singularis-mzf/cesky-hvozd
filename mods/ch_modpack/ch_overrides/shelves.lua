--[[
SHELVES
]]

local F = minetest.formspec_escape

local empty_shelf_texture = "moreblocks_empty_shelf.png" -- 32x32
local shelf_width = 10
local MODE_NORMAL = 0
local MODE_LIBRARY = 1
local MODE_PRIVATE = 2
local title_color = "#00FF00"
local mode_dropdown = ch_core.make_dropdown({"normální", "knihovní", "soukromý"})
local dropdown_index_to_mode_number = {MODE_NORMAL, MODE_LIBRARY, MODE_PRIVATE}
local dropdown_index_from_mode_number = table.key_value_swap(dropdown_index_to_mode_number)

local shelf_types = {
	[""] = {
		description = "prázdná",
		-- texture_full = "moreblocks_empty_shelf.png", -- 32x32
		texture_upper = "ch_core_white_pixel.png^[invert:a",
		texture_lower = "ch_core_white_pixel.png^[invert:a",
	},
	books = {
		description = "knihy",
		-- texture_full = "default_bookshelf.png", -- 32x32
		texture_upper = "default_bookshelf.png^[mask:ch_overrides_overlay_bo_top.png",
		texture_lower = "default_bookshelf.png^[mask:ch_overrides_overlay_bo_bottom.png",
		required_item_group = "book",
		slot_image = "default_bookshelf_slot.png",
	},
	vessels = {
		description = "nádoby",
		-- texture_full = "vessels_shelf.png", -- 64x64
		texture_upper = "vessels_shelf.png^[mask:ch_overrides_overlay_vs_top.png",
		texture_lower = "vessels_shelf.png^[mask:ch_overrides_overlay_vs_bottom.png",
		required_item_group = "vessel",
		slot_image = "vessels_shelf_slot.png",
	},
}

local types_to_shelf = {
	[""] = {
		[""] = "moreblocks:empty_shelf",
		books = "ch_overrides:shelf_empty_books",
		vessels = "ch_overrides:shelf_empty_vessels",
	},
	books = {
		[""] = "ch_overrides:shelf_books_empty",
		books = "default:bookshelf",
		vessels = "ch_overrides:shelf_books_vessels",
	},
	vessels = {
		[""] = "ch_overrides:shelf_vessels_empty",
		books = "ch_overrides:shelf_vessels_books",
		vessels = "vessels:shelf",
	},
}

local shelves_names = {}
local shelves_to_types = {}

for type1, tab in pairs(types_to_shelf) do
	for type2, name in pairs(tab) do
		shelves_to_types[name] = {type1, type2}
		table.insert(shelves_names, name)
	end
end

local function get_shelf_type_by_item_name(item_name)
	if item_name == nil or item_name == "" then
		return ""
	end
	for shelf_type, def in pairs(shelf_types) do
		if def.required_item_group ~= nil and minetest.get_item_group(item_name, def.required_item_group) ~= 0 then
			return shelf_type
		end
	end
end

local function get_shelf_type_by_list_index(node, index)
	local types = shelves_to_types[node.name]
	if types == nil then
		minetest.log("warning", "get_shelf_type_by_list_index() called for "..node.name.." and index "..index..", but the shelf is not known!")
		return ""
	end
	if index <= shelf_width then
		return types[1]
	else
		return types[2]
	end
end

local function get_shelf_type_from_inventory(inv, index_min, index_max)
	for i = index_min, index_max do
		local stack = inv:get_stack("items", i)
		if not stack:is_empty() then
			local item_name = stack:get_name()
			local result_type = get_shelf_type_by_item_name(item_name)
			if result_type ~= nil then
				return result_type
			end
		end
	end
	return ""
end

local function get_infotext(pos, node, meta)
	local types = shelves_to_types[node.name]
	if types == nil then
		return ""
	end
	local title = meta:get_string("title")
	if types[1] == "" and types[2] == "" then
		return title
	end
	if title ~= "" then
		title = title.."\n"
	end
	local inv = meta:get_inventory():get_list("items")
	local count1, count2 = 0, 0
	for i = 1, shelf_width do
		if not inv[i]:is_empty() then
			count1 = count1 + 1
		end
	end
	for i = shelf_width + 1, 2 * shelf_width do
		if not inv[i]:is_empty() then
			count2 = count2 + 1
		end
	end
	local desc1 = shelf_types[types[1]].description
	if types[1] ~= "" then
		desc1 = "("..count1..") "..desc1
	end
	local desc2 = shelf_types[types[2]].description
	if types[2] ~= "" then
		desc2 = "("..count2..") "..desc2
	end
	return title..desc1.."\n"..desc2
end

local function meta_get_bool_string(meta, name)
	if meta:get_int(name) ~= 0 then
		return "true"
	else
		return "false"
	end
end

local function get_formspec(player_name, pos, node, meta, do_edit)
	local types = shelves_to_types[node.name]
	if types == nil then
		return ""
	end
	local player_role = ch_core.get_player_role(player_name)
	local invlist = meta:get_inventory():get_list("items")
	local mode = meta:get_int("mode")
	local owner = meta:get_string("owner")
	local has_owner_rights = owner == player_name or player_role == "admin"
	local title = meta:get_string("title")
	if title == "" then
		title = "Skříňka na knihy a nádoby"
	end
	local formspec = {
		"formspec_version[5]",
		"size[13,10.25]",
	}

	-- shelf title
	if do_edit then
		table.insert(formspec,
			"field[0.375,0.3;10,0.5;title;;"..F(title).."]"..
			"button[10.5,0.3;2.25,0.5;ulozit;uložit titulek]")
	else
		table.insert(formspec,
			"tableoptions[background=#00000000;highlight=#00000000;border=false]"..
			"tablecolumns[color;text]"..
			"table[0.25,0.25;12.5,0.5;;#00FF00,"..F(title)..";]")
		if has_owner_rights then
			table.insert(formspec,
				"button[10.5,0.3;2.25,0.5;upravit;upravit titulek]")
		end
	end

	-- shelf owner
	if do_edit and player_role == "admin" then
		table.insert(formspec,
			"label[0.375,1;vlastník/ice skříňky:]"..
			"field[3.15,0.75;3,0.5;owner;;"..ch_core.prihlasovaci_na_zobrazovaci(F(meta:get_string("owner"))).."]")
	else
		table.insert(formspec,
			"label[0.375,1;vlastník/ice skříňky: "..ch_core.prihlasovaci_na_zobrazovaci(F(meta:get_string("owner"))).."]")
	end

	-- shelf mode
	if do_edit then
		table.insert(formspec,
			"label[6.5,1;režim: "..mode_dropdown:get_value_from_index(dropdown_index_from_mode_number[mode], 1) .."]")
	elseif has_owner_rights then
		table.insert(formspec,
			"label[6.5,1;režim:]"..
			"dropdown[7.5,0.75;3,0.5;rezim;"..
			mode_dropdown.formspec_list..";"..
			(dropdown_index_from_mode_number[mode] or 1)..
			";true]")
	elseif mode == MODE_PRIVATE then
		table.insert(formspec,
			"label[0.375,1.5;Tato skříňka je v soukromém režimu. Obsah je přístupný jen vlastníkovi/ici skříňky či Administraci.]")
	elseif mode == MODE_LIBRARY then
		table.insert(formspec,
			"label[0.375,1.5;Tato skříňka je v knihovním režimu. Knihy z ní si mohou brát všechny postavy včetně nových, dostanou kopii.]")
	end

	-- player inventory:
	table.insert(formspec,
		"list[current_player;main;1.625,5;8,1;]" ..
		"list[current_player;main;1.625,6.25;8,3;8]")
	-- shelf inventory:
	if mode ~= MODE_PRIVATE or has_owner_rights then
		local context = "nodemeta:"..pos.x.."\\,"..pos.y.."\\,"..pos.z
		table.insert(formspec, "list["..context..";items;0.375,2;10,2;]"..
			"listring["..context..";items]"..
			"listring[current_player;main]")
		-- shelf icons:
		local x, y = 0.375, 2.0
		local current_type = shelf_types[types[1]]
		local current_slot_image = current_type.slot_image
		for i = 1, 2 * shelf_width do
			if (not invlist[i] or invlist[i]:is_empty()) and current_slot_image ~= nil then
				table.insert(formspec, "image["..x..","..y..";1,1;"..current_slot_image.."]")
			end
			if i == shelf_width then
				-- switch to the second line
				x = 0.375
				y = y + 1.25
				current_type = shelf_types[types[2]]
				current_slot_image = current_type.slot_image
			else
				x = x + 1.25
			end
		end

		if mode == MODE_LIBRARY and (types[1] == "books" or types[2] == "books") then
			table.insert(formspec,
				"tooltip[0.3,4.6;1.2,1.2;vracení knih (jen knihy s IČK);#000000;#ffffff]"..
				"box[0.3,4.6;1.2,1.2;#339933]"..
				"list["..context..";returns;0.4,4.7;1,1;0]"..
				"listring["..context..";returns]")
		end
	end

	return table.concat(formspec)
end

local function on_construct(pos)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_size("items", 10 * 2)
	inv:set_size("returns", 1)
	local infotext = get_infotext(pos, node, meta)
	meta:set_string("infotext", infotext)
end

local function after_place_node(pos, placer, itemstack, pointed_thing)
	local player_name = placer and placer:get_player_name()
	if player_name ~= nil then
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", player_name)
	end
end

local function get_correct_nodename(inv)
	local type1, type2 = get_shelf_type_from_inventory(inv, 1, shelf_width), get_shelf_type_from_inventory(inv, shelf_width + 1, 2 * shelf_width)
	return types_to_shelf[type1][type2]
end

local function find_empty_book_in_inventory(inv, list, book_level)
	if book_level == nil or book_level == 0 then
		error("Incorrect call to find_empty_book_in_inventory()!")
	end
	local contents = inv:get_list(list)
	for i = 1, #contents do
		local stack = contents[i]
		if not stack:is_empty() and minetest.get_item_group(stack:get_name(), "book") == book_level then
			local meta = stack:get_meta()
			if meta:get_string("text") == "" and meta:get_string("ick") == "" then
				return i
			end
		end
	end
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	-- print("DEBUG: allow_metadata_inventory_put")
	local player_name = player and player:get_player_name()
	if not player_name or not minetest.check_player_privs(player_name, "ch_registered_player") then
		return 0 -- invalid or new player (no right to put)
	end
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	local mode = meta:get_int("mode")
	local types = shelves_to_types[node.name]
	if types == nil then
		return 0
	end
	if listname == "returns" then
		if mode ~= MODE_LIBRARY then
			return 0
		end
		local book_info = books.analyze_book(stack:get_name(), stack:get_meta())
		if book_info == nil or book_info.ick == "" then
			return 0
		end
		local from, to
		if types[1] == "books" then
			if types[2] == "books" then
				from, to = 1, 2 * shelf_width
			else
				from, to = 1, shelf_width
			end
		elseif types[2] == "books" then
			from, to = shelf_width + 1, 2 * shelf_width
		else
			return 0
		end
		local inv = meta:get_inventory():get_list("items")
		for i = from, to do
			local istack = inv[i]
			if not istack:is_empty() and minetest.get_item_group(istack:get_name(), "book") ~= 0 and istack:get_meta():get_string("ick") == book_info.ick then
				-- a book found
				return stack:get_count()
			end
		end
		ch_core.systemovy_kanal(player_name, "Knihy lze vrátit jen do skříňky, kam patří. Kniha s IČK "..book_info.ick.." nepatří do této skříňky.")
		return 0
	elseif listname == "items" then
		local shelf_type = get_shelf_type_by_list_index(node, index)
		local owner = meta:get_string("owner")
		local has_owner_rights = player_name == owner or minetest.check_player_privs(player_name, "protection_bypass")
		local item_shelf_type = get_shelf_type_by_item_name(stack:get_name())

		if mode == MODE_PRIVATE and not has_owner_rights then
			return 0
		end
		if mode == MODE_LIBRARY and (shelf_type == "books" or (shelf_type == "" and item_shelf_type == "books")) then
			return 0  -- no right to put books to the library shelf
		end
		if item_shelf_type == nil or (shelf_type ~= "" and item_shelf_type ~= shelf_type) then
			return 0
		end
		return stack:get_count()
	else
		minetest.log("warning", "Unknown list "..listname.." for a node "..minetest.get_node(pos).name.." at "..minetest.pos_to_string(pos).."!")
		return 0
	end
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	-- print("DEBUG: allow_metadata_inventory_take")
	if listname == "returns" then
		minetest.get_meta(pos):get_inventory():set_stack("returns", index, ItemStack())
		return 0
	end
	local player_name = player and player:get_player_name()
	if not player_name or listname ~= "items" then
		return 0 -- invalid player or list
	end
	local player_role = ch_core.get_player_role(player_name)
	local node = minetest.get_node(pos)
	local shelf_type = get_shelf_type_by_list_index(node, index)
	local meta = minetest.get_meta(pos)
	local mode = meta:get_int("mode")
	local owner = meta:get_string("owner")
	local has_owner_rights = player_name == owner or minetest.check_player_privs(player_name, "protection_bypass")
	local book_level = minetest.get_item_group(stack:get_name(), "book")

	-- special exception:
	if mode == MODE_LIBRARY and shelf_type == "books" and book_level ~= 0 then
		-- activate library functionality
		local has_creative = minetest.check_player_privs(player_name, "creative")
		if player_role ~= "new" and not has_creative then
			local inv = player:get_inventory()
			local i = find_empty_book_in_inventory(inv, "main", book_level)
			if i == nil then
				ch_core.systemovy_kanal(player_name, "Abyste dostali výtisk této knihy, musíte mít v inventáři alespoň jednu prázdnou knihu stejného formátu!")
				return 0
			else
				-- take an empty book
				local player_stack = inv:get_stack("main", i)
				player_stack:set_count(player_stack:get_count() - 1)
				inv:set_stack("main", i, player_stack)
			end
		end
		return stack:get_count()
	end

	if player_role == "new" then
		return 0
	end

	if mode == MODE_PRIVATE and not has_owner_rights then
		return 0
	end

	return stack:get_count()
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	-- print("DEBUG: allow_metadata_inventory_move(): "..dump2({pos = pos, from_list = from_list, from_index = from_index, to_list = to_list, to_index = to_index, count = count, player_name = player:get_player_name()}))
	if to_list == "returns" then
		return 0
	end
	local player_name = player and player:get_player_name()
	if not player_name or from_list ~= "items" or to_list ~= "items" then
		return 0 -- invalid player or list
	end
	if ch_core.get_player_role(player_name) == "new" then
		return 0 -- no moving for new players
	end
	local meta = minetest.get_meta(pos)
	local mode = meta:get_int("mode")
	local owner = meta:get_string("owner")
	local has_owner_rights = player_name == owner or minetest.check_player_privs(player_name, "protection_bypass")

	if not has_owner_rights and (mode == MODE_LIBRARY or mode == MODE_PRIVATE) then
		return 0
	end
	local node = minetest.get_node(pos)
	local shelf_type_from = get_shelf_type_by_list_index(node, from_index)
	local shelf_type_to = get_shelf_type_by_list_index(node, to_index)
	-- only move to an empty shelf or shelf of the same type
	if shelf_type_to == "" or shelf_type_to == shelf_type_from then
		return count
	else
		return 0
	end
end

local function formspec_callback(custom_state, player, formname, fields)
	if fields.quit then
		return
	end
	local meta = minetest.get_meta(custom_state.pos)
	local has_owner_rights = custom_state.has_owner_rights
	if not has_owner_rights then
		return
	end
	local mode = custom_state.mode
	local do_edit = false
	if fields.upravit then
		do_edit = true
	elseif fields.ulozit then
		if fields.title then
			meta:set_string("title", ch_core.utf8_truncate_right(fields.title, 80))
		end
		if fields.owner and ch_core.get_player_role(player) == "admin" then
			meta:set_string("owner", ch_core.jmeno_na_prihlasovaci(fields.owner))
		end
		meta:set_string("infotext", get_infotext(custom_state.pos, minetest.get_node(custom_state.pos), meta))
	elseif fields.rezim then
		-- change mode
		local new_mode = dropdown_index_to_mode_number[tonumber(fields.rezim) or 0]
		if new_mode ~= nil then
			if new_mode ~= mode then
				local meta = minetest.get_meta(custom_state.pos)
				meta:set_int("mode", new_mode)
				mode = new_mode
			end
		else
			minetest.log("warning", "Unknown fields.rezim '"..(fields.rezim or "nil").."' in formspec_callback for a shelf!")
		end
	else
		return
	end
	return get_formspec(player:get_player_name(), custom_state.pos, minetest.get_node(custom_state.pos), meta, do_edit)
end

local function update_after_metadata_inventory_action(pos, player)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	local correct_nodename = get_correct_nodename(meta:get_inventory())
	if node.name ~= correct_nodename then
		node.name = correct_nodename
		minetest.swap_node(pos, node)
	end
	meta:set_string("infotext", get_infotext(pos, node, meta))
	local player_name = player and player:get_player_name()
	if player_name ~= nil and player_name ~= "" then
		local custom_state = {
			pos = pos,
			mode = meta:get_int("mode"),
			has_owner_rights = player_name == meta:get_string("owner") or minetest.check_player_privs(player_name, "protection_bypass"),
		}
		local formspec = get_formspec(player_name, pos, node, meta)
		ch_core.show_formspec(player, "ch_overrides:shelf", formspec, formspec_callback, custom_state, {})
	end
end

local function on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	local player_name = clicker and clicker:get_player_name()
	if player_name ~= nil and player_name ~= "" then
		-- function ch_core.show_formspec(player_name_or_player, formname, formspec, callback, custom_state, options)
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		if owner == "" then
			minetest.log("warning", "A shelf "..node.name.." with no owner at "..minetest.pos_to_string(pos).."! Will set to "..player_name..".")
			meta:set_string("owner", player_name)
			owner = player_name
		end
		local custom_state = {
			pos = pos,
			mode = meta:get_int("mode"),
			has_owner_rights = player_name == owner or minetest.check_player_privs(player_name, "protection_bypass"),
		}
		local formspec = get_formspec(player_name, pos, node, meta)
		ch_core.show_formspec(clicker, "ch_overrides:shelf", formspec, formspec_callback, custom_state, {})
	end
	return itemstack
end

local function on_metadata_inventory_put(pos, listname, index, stack, player)
	local inv = minetest.get_meta(pos):get_inventory()
	if listname == "items" then
		local new_stack = inv:get_stack(listname, index)
		if stack:get_count() == new_stack:get_count() then
			-- new stack
			return update_after_metadata_inventory_action(pos, player)
		end
	elseif listname == "returns" then
		local book_info
		if not minetest.is_creative_enabled(player:get_player_name()) then
			book_info = books.analyze_book(stack:get_name(), stack:get_meta())
			if book_info ~= nil then
				local new_stack
				if book_info.format == "B5" then
					new_stack = ItemStack("books:book_b5_closed_grey")
				else -- B6
					new_stack = ItemStack("books:book_b6_closed_grey")
				end
				player:get_inventory():add_item("main", new_stack)
			end
		end
		inv:set_stack("returns", 1, ItemStack())
	end
end

local function on_metadata_inventory_take(pos, listname, index, stack, player)
	local player_name = player and player:get_player_name()
	if not player_name or listname ~= "items" then
		return -- invalid player or list
	end
	local node = minetest.get_node(pos)
	local shelf_type = get_shelf_type_by_list_index(node, index)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local mode = meta:get_int("mode")
	local owner = meta:get_string("owner")
	local book_level = minetest.get_item_group(stack:get_name(), "book")
	if mode == MODE_LIBRARY and shelf_type == "books" and book_level ~= 0 then
		-- activate library-functionality
		inv:set_stack(listname, index, stack)
		return
	end
	if inv:get_stack(listname, index):is_empty() then
		return update_after_metadata_inventory_action(pos, player)
	end
end

local function on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local inv = minetest.get_meta(pos):get_inventory()
	if inv:get_stack(from_list, from_index):is_empty() or inv:get_stack(to_list, to_index):get_count() == count then
		return update_after_metadata_inventory_action(pos, player)
	end
end

local function can_dig(pos, player)
	local meta = minetest.get_meta(pos)
	if not meta:get_inventory():is_empty("items") then
		return false
	end
	local mode = meta:get_int("mode")
	local owner = meta:get_string("owner")
	local player_name = (player and player:get_player_name()) or ""
	local has_owner_rights = player_name ~= "" and (player_name == owner or minetest.check_player_privs(player_name, "protection_bypass"))
	return mode == MODE_NORMAL or has_owner_rights
end

local function preserve_metadata(oldpos, oldnode, oldmeta, drops)
	drops[1] = ItemStack(types_to_shelf[""][""])
end

local def = {
	description = "skříňka na knihy a nádoby",
	paramtype2 = "4dir",
	is_ground_content = false,
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 3, shelf = 1, not_in_creative_inventory = 1},
	drop = "", -- preserve_metadata will fill the drops
	sounds = default.node_sound_wood_defaults(),

	on_construct = on_construct,
	after_place_node = after_place_node,
	can_dig = can_dig,
	preserve_metadata = preserve_metadata,
	on_rightclick = on_rightclick,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	on_metadata_inventory_move = on_metadata_inventory_move,
	on_metadata_inventory_put = on_metadata_inventory_put,
	on_metadata_inventory_take = on_metadata_inventory_take,
}

for type1, tab in pairs(types_to_shelf) do
	for type2, name in pairs(tab) do
		local ndef = table.copy(def)
		local texture = "("..empty_shelf_texture..")^[resize:64x64^(("..shelf_types[type1].texture_upper..")^[resize:64x64)^(("..shelf_types[type2].texture_lower..")^[resize:64x64)"
		ndef.tiles = {
			"default_wood.png", "default_wood.png", "default_wood.png",
			"default_wood.png", texture, texture
		}
		if minetest.registered_nodes[name] then
			minetest.override_item(name, ndef)
			-- ch_core.clear_crafts("ch_overrides:shelves", {{output = name}})
		else
			minetest.register_node(name, ndef)
		end
	end
end

local groups_in_ci = table.copy(def.groups)
groups_in_ci.not_in_creative_inventory = nil
minetest.override_item(types_to_shelf[""][""], {groups = groups_in_ci, paramtype2 = "4dir"})

-- Crafts
minetest.register_craft{
	output = types_to_shelf[""][""],
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"", "", ""},
		{"group:wood", "group:wood", "group:wood"},
	},
}

-- Register for wrench
if minetest.get_modpath("wrench") then
	local def = {
		lists = {"items"},
		metas = {
			owner = wrench.META_TYPE_STRING,
			infotext = wrench.META_TYPE_STRING,
			mode = wrench.META_TYPE_INT,
			title = wrench.META_TYPE_STRING,
		},
		owned = true,
	}
	for item, _ in pairs(shelves_to_types) do
		wrench.register_node(item, def)
	end
end

-- LBM
local function on_lbm(pos, node, dtime_s)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if inv:get_size("items") == 8 * 2 then
		-- perform upgrade
		meta:set_string("formspec", "")
		inv:set_size("items", 20)
		local list = inv:get_list("items")
		for i = 20, 11, -1 do
			list[i] = list[i - 2]
		end
		list[9] = ItemStack()
		list[10] = ItemStack()
		inv:set_list("items", list)
		if meta:get_int("locked") ~= 0 then
			meta:set_int("mode", MODE_PRIVATE)
		elseif meta:get_int("library") ~= 0 then
			meta:set_int("mode", MODE_LIBRARY)
		else
			meta:set_int("mode", MODE_NORMAL)
		end
		meta:set_int("locked", 0)
		meta:set_int("library", 0)
	end
	if inv:get_size("returns") == 0 then
		-- perform upgrade
		inv:set_size("returns", 1)
		minetest.log("action", "A shelf "..node.name.." at "..minetest.pos_to_string(pos).." upgraded to version 3.")
	end
end

minetest.register_lbm({
	label = "Upgrade shelves 3",
	name = "ch_overrides:shelves_upgrade_3",
	nodenames = shelves_names,
	run_at_every_load = false,
	action = on_lbm,
})
