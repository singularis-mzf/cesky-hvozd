--[[
SHELVES
]]

local F = minetest.formspec_escape

local empty_shelf_texture = "moreblocks_empty_shelf.png" -- 32x32

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

local shelves_to_types = {}

for type1, tab in pairs(types_to_shelf) do
	for type2, name in pairs(tab) do
		shelves_to_types[name] = {type1, type2}
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
	if index <= 8 then
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
	if types == nil or (types[1] == "" and types[2] == "") then
		return ""
	end
	local inv = meta:get_inventory():get_list("items")
	local count1, count2 = 0, 0
	for i = 1, 8 do
		if not inv[i]:is_empty() then
			count1 = count1 + 1
		end
	end
	for i = 9, 16 do
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
	return desc1.."\n"..desc2
end

local function meta_get_bool_string(meta, name)
	if meta:get_int(name) ~= 0 then
		return "true"
	else
		return "false"
	end
end

local function get_formspec(pos, node, meta)
	local types = shelves_to_types[node.name]
	if types == nil then
		return ""
	end
	local invlist = meta:get_inventory():get_list("items")
	local formspec = {
		"size[8,8]",
		"label[0,0;Vlastník/ice skříňky: ",
			F(ch_core.prihlasovaci_na_zobrazovaci(meta:get_string("owner"))), "]",
		"checkbox[0,0.5;locked;zamykatelná;", meta_get_bool_string(meta, "locked"), "]",
		"checkbox[3,0.5;library;knihovní;", meta_get_bool_string(meta, "library"), "]",
		"list[context;items;0,1.5;8,2;]",
		"list[current_player;main;0,3.90;8,1;]",
		"list[current_player;main;0,5.00;8,3;8]",
		"listring[context;items]",
		"listring[current_player;main]",
		default.get_hotbar_bg(0, 3.90),
	}
	local x, y = 0, 1.5
	local current_type = shelf_types[types[1]]
	local current_slot_image = current_type.slot_image

	for i = 1, 16 do
		if (not invlist[i] or invlist[i]:is_empty()) and current_slot_image ~= nil then
			table.insert(formspec, "image["..x..","..y..";1,1;"..current_slot_image.."]")
		end
		if i == 8 then
			-- switch to the second line
			x = 0
			y = y + 1
			current_type = shelf_types[types[2]]
			current_slot_image = current_type.slot_image
		else
			x = x + 1
		end
	end

	return table.concat(formspec)
end

local function on_construct(pos)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_size("items", 8 * 2)
	local infotext = get_infotext(pos, node, meta)
	meta:set_string("infotext", infotext)
	local formspec = get_formspec(pos, node, meta)
	meta:set_string("formspec", formspec)
end

local function after_place_node(pos, placer, itemstack, pointed_thing)
	local player_name = placer and placer:get_player_name()
	if player_name ~= nil then
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", player_name)
	end
end

local function get_correct_nodename(inv)
	local type1, type2 = get_shelf_type_from_inventory(inv, 1, 8), get_shelf_type_from_inventory(inv, 9, 16)
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
	local player_name = player and player:get_player_name()
	if not player_name or listname ~= "items" or not minetest.check_player_privs(player_name, "ch_registered_player") then
		return 0 -- invalid or new player (no right to put)
	end
	local node = minetest.get_node(pos)
	local shelf_type = get_shelf_type_by_list_index(node, index)
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")

	if player_name ~= owner and not minetest.check_player_privs(player_name, "protection_bypass") then
		if meta:get_int("locked") ~= 0 then
			return 0 -- no right to put anything there
		elseif meta:get_int("library") ~= 0 and (shelf_type == "books" or (shelf_type == "" and get_shelf_type_by_item_name(stack:get_name()) == "books")) then
			return 0 -- no right to put books to the library shelf
		end
	end
	local item_shelf_type = get_shelf_type_by_item_name(stack:get_name())
	if item_shelf_type == nil or (shelf_type ~= "" and item_shelf_type ~= shelf_type) then
		return 0
	end

	return stack:get_count()
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	local player_name = player and player:get_player_name()
	if not player_name or listname ~= "items" then
		return 0 -- invalid player or list
	end
	local node = minetest.get_node(pos)
	local shelf_type = get_shelf_type_by_list_index(node, index)
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")

	if player_name ~= owner and not minetest.check_player_privs(player_name, "protection_bypass") then
		if shelf_type == "books" and meta:get_int("library") ~= 0 then
			local book_level = minetest.get_item_group(stack:get_name(), "book")
			if book_level ~= 0 then
				-- activate library-functionality
				local is_new_player = not minetest.check_player_privs(player_name, "ch_registered_player")
				local has_give = minetest.check_player_privs(player_name, "give")
				local has_creative = minetest.check_player_privs(player_name, "creative")
				if not (is_new_player or has_give or has_creative) then
					local inv = player:get_inventory()
					local i = find_empty_book_in_inventory(inv, "main", book_level)
					if i == nil then
						-- an empty book in the inventory is required!
						ch_core.systemovy_kanal(player_name, "Abyste dostali výtisk této knihy, musíte mít v inventáři alespoň jednu prázdnou knihu stejného formátu!")
						return 0
					end
				end
			end
		elseif meta:get_int("locked") ~= 0 then
			return 0 -- locked, no right to access
		end
	end

	return stack:get_count()
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	if from_list ~= "items" or to_list ~= "items" then return 0 end -- invalid list
	local node = minetest.get_node(pos)
	local shelf_type_from = get_shelf_type_by_list_index(node, from_index)
	local shelf_type_to = get_shelf_type_by_list_index(node, to_index)
	if shelf_type_to == "" or shelf_type_to == shelf_type_from then
		return count
	else
		return 0
	end
end

local function update_after_metadata_inventory_action(pos)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	local correct_nodename = get_correct_nodename(meta:get_inventory())
	if node.name ~= correct_nodename then
		node.name = correct_nodename
		minetest.swap_node(pos, node)
	end
	meta:set_string("formspec", get_formspec(pos, node, meta))
	meta:set_string("infotext", get_infotext(pos, node, meta))
end

local function on_receive_fields(pos, formname, fields, sender)
	local player_name = sender and sender:get_player_name()
	if not player_name then
		return
	end
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	if player_name ~= owner and not minetest.check_player_privs(player_name, "protection_bypass") then
		return
	end
	local changed = false
	if fields.locked ~= nil then
		meta:set_int("locked", fields.locked == "true" and 1 or 0)
		changed = true
	end
	if fields.library ~= nil then
		meta:set_int("library", fields.library == "true" and 1 or 0)
		changed = true
	end
	if changed then
		meta:set_string("formspec", get_formspec(pos, minetest.get_node(pos), minetest.get_meta(pos)))
	end
end

-- local function on_metadata_inventory_put(pos, listname, index, stack, player)
-- local function on_metadata_inventory_take(pos, listname, index, stack, player)
-- local function on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
local on_metadata_inventory_move = update_after_metadata_inventory_action
local on_metadata_inventory_put = update_after_metadata_inventory_action

local function on_metadata_inventory_take(pos, listname, index, stack, player)
	local player_name = player and player:get_player_name()
	if not player_name or listname ~= "items" then
		return -- invalid player or list
	end
	local node = minetest.get_node(pos)
	local shelf_type = get_shelf_type_by_list_index(node, index)
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")

	if player_name ~= owner and not minetest.check_player_privs(player_name, "protection_bypass") and shelf_type == "books" and meta:get_int("library") ~= 0 then
		local book_level = minetest.get_item_group(stack:get_name(), "book")
		if book_level ~= 0 then
			-- activate library-functionality
			meta:get_inventory():set_stack(listname, index, stack)

			-- take an empty book...
			local is_new_player = not minetest.check_player_privs(player_name, "ch_registered_player")
			local has_give = minetest.check_player_privs(player_name, "give")
			local has_creative = minetest.check_player_privs(player_name, "creative")
			if not (is_new_player or has_give or has_creative) then
				local inv = player:get_inventory()
				local i = find_empty_book_in_inventory(inv, "main", book_level)
				if i ~= nil then
					local stack = inv:get_stack("main", i)
					stack:set_count(stack:get_count() - 1)
					inv:set_stack("main", i, stack)
				end
			end
		end
	end

	update_after_metadata_inventory_action(pos)
end

local function can_dig(pos, player)
	return minetest.get_meta(pos):get_inventory():is_empty("items")
end

local function preserve_metadata(oldpos, oldnode, oldmeta, drops)
	drops[1] = ItemStack(types_to_shelf[""][""])
end

local def = {
	description = "skříňka na knihy a nádoby",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 3, shelf = 1, not_in_creative_inventory = 1},
	drop = "", -- preserve_metadata will fill the drops
	sounds = default.node_sound_wood_defaults(),

	on_construct = on_construct,
	after_place_node = after_place_node,
	can_dig = can_dig,
	preserve_metadata = preserve_metadata,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	on_metadata_inventory_move = on_metadata_inventory_move,
	on_metadata_inventory_put = on_metadata_inventory_put,
	on_metadata_inventory_take = on_metadata_inventory_take,
	on_receive_fields = on_receive_fields,
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
			ch_core.clear_crafts("ch_overrides:shelves", {{output = name}})
		else
			minetest.register_node(name, ndef)
		end
	end
end

local groups_in_ci = table.copy(def.groups)
groups_in_ci.not_in_creative_inventory = nil
minetest.override_item(types_to_shelf[""][""], {groups = groups_in_ci})

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
			formspec = wrench.META_TYPE_STRING,
			locked = wrench.META_TYPE_INT,
			library = wrench.META_TYPE_INT,
		},
		owned = true,
	}
	for item, _ in pairs(shelves_to_types) do
		wrench.register_node(item, def)
	end
end
