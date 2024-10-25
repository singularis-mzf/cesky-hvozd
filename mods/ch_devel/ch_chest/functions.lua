local internal = ...

local has_pipeworks = minetest.get_modpath("pipeworks")
local has_unifieddyes = minetest.get_modpath("unifieddyes")
local NOT_GIVEN = internal.NOT_GIVEN
local GIVEN_OPENLY = internal.GIVEN_OPENLY
local GIVEN_ANONYMOUSLY = internal.GIVEN_ANONYMOUSLY

local ifthenelse = ch_core.ifthenelse

local right_to_index = {
	view = 1,
	sort = 4,
	put = 7,
	take = 10,
	dig = 13,
	set = 16,
}

local player_to_current_inventory = {}

local function get_player_category(meta, player_name)
	local is_owner, is_group = false, false

	if player_name == nil then
		return {
			player_role = "none",
			admin = false,
			owner = false,
			group = false,
		}, 3
	else
		if meta:get_int("ch_given") ~= 0 then
			is_owner = meta:get_string("ch_given_by") == player_name or meta:get_string("ch_given_to") == player_name
		else
			is_owner = meta:get_string("owner") == player_name
		end

		if not is_owner then
			is_group = string.find(meta:get_string("agroup"), "|"..string.lower(player_name).."|") ~= nil
		end

		local player_role = ch_core.get_player_role(player_name)
		local result = {
			player_role = player_role,
			admin = player_role == "admin",
			owner = is_owner,
			group = is_group,
		}
		if player_role == "new" or player_role == "admin" then
			return result, 0
		elseif is_owner then
			return result, 1
		elseif is_group then
			return result, 2
		else
			return result, 3
		end
	end
end

local function check_right(meta, player_name, right)
	local category, shift = get_player_category(meta, player_name)
	print("DEBUG: "..dump2({category = category, shift = shift, player_name = player_name}))
	if shift == 0 then
		return category.admin
	end
	local rights = meta:get_string("rights")
	shift = shift + right_to_index[right] - 1
	local result = rights:sub(shift, shift) ~= "0"
	print("DEBUG: check_right: "..(player_name or "nil").."/"..right.."="..ifthenelse(result, "true", "false"))
	return result
end

local function get_rights(meta, player_name)
	local result, shift = get_player_category(meta, player_name)
	if shift == 0 then
		for k, _ in pairs(right_to_index) do
			result[k] = result.admin
		end
	else
		shift = shift - 1
		local rights = meta:get_string("rights")
		for k, i in pairs(right_to_index) do
			result[k] = rights:sub(i + shift, i + shift) ~= "0"
		end
	end
	return result
end

internal.get_player_category = get_player_category
internal.check_right = check_right
internal.get_rights = get_rights

function internal.new_chest_id()
	local next_id = internal.mod_storage:get_int("next_chest_id")
	if next_id ~= 0 then
		internal.mod_storage:set_int("next_chest_id", next_id + 1)
		return next_id
	else
		internal.mod_storage:set_int("next_chest_id", 1002)
		return 1001
	end
end

function internal.update_chest_infotext(meta)
	local ch_given = meta:get_int("ch_given")
	if ch_given == GIVEN_ANONYMOUSLY then
		meta:set_string("infotext", meta:get_string("title").."\ntruhla pro: "..ch_core.prihlasovaci_na_zobrazovaci(meta:get_string("ch_given_to")))
	elseif ch_given == GIVEN_OPENLY then
		meta:set_string("infotext", meta:get_string("title").."\ntruhla pro: "..ch_core.prihlasovaci_na_zobrazovaci(meta:get_string("ch_given_to")).."\ndar od: "..ch_core.prihlasovaci_na_zobrazovaci(meta:get_string("ch_given_by")))
	else
		meta:set_string("infotext", meta:get_string("title").."\ntruhlu vlastní: "..ch_core.prihlasovaci_na_zobrazovaci(meta:get_string("owner")))
	end
end

function ch_chest.init(pos, node, width, height, title, owner)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	if width < 1 or height < 1 then
		error("Invalid chest size!")
	end
	inv:set_size("main", width * height)
	inv:set_size("qmove", 1)
	inv:set_size("trash", 1)
	inv:set_size("upgrades", 5)
	meta:set_int("width", width)
	meta:set_int("height", height)
	meta:set_int("chest_id", internal.new_chest_id())
	if title ~= nil then
		meta:set_string("title", title)
	end
	if owner ~= nil then
		meta:set_string("owner", owner)
	end
	meta:set_string("rights", "111111111111111111")
	internal.update_chest_infotext(meta)
end

function internal.on_construct(pos)
	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	if ndef ~= nil then
		ch_chest.init(pos, node, 8, 4, ndef.description or "truhla")
	end
end

function internal.preserve_metadata(pos, oldnode, oldmeta, drops)
end

function internal.after_place_node(pos, placer, itemstack, pointed_thing)
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	if owner == "" then
		owner = placer and placer:get_player_name()
		if owner ~= nil then
			meta:set_string("owner", owner)
		end
	end
	internal.update_chest_infotext(meta)
end

function internal.after_dig_node(pos, oldnode, oldmetadata, digger)
end

function internal.can_dig(pos, player)
	if player == nil then
		return false
	end
	if internal.check_right(minetest.get_meta(pos), player:get_player_name(), "dig") then
		return true
	end
	return false
end

function internal.on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	local player_name = clicker and clicker:get_player_name()
	if player_name == nil then
		return
	end
	local meta = minetest.get_meta(pos)
	if internal.check_right(meta, player_name, "view") then
		internal.show_formspec(clicker, pos, meta)
	end
end

local function quick_move(src_inv, src_listname, src_stack, dst_inv, dst_listname)
	local src_list = src_inv:get_list(src_listname)
	for i = 1, #src_list do
		local stack = src_list[i]
		if not stack:is_empty() and stack:get_name() == src_stack:get_name() then
			stack = dst_inv:add_item(dst_listname, stack)
			src_list[i] = stack
			if not stack:is_empty() then
				break
			end
		end
	end
	src_inv:set_list(src_listname, src_list)
end

function internal.allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local player_name = player and player:get_player_name()
	if player_name == nil then return 0 end
	local meta = minetest.get_meta(pos)

	if from_list == to_list then
		return ifthenelse(from_list == "main" and internal.check_right(meta, player_name, "sort"), count, 0)
	elseif from_list == "main" and to_list == "qmove" then
		if internal.check_right(meta, player_name, "take") then
			local destination = internal.player_to_current_inventory[player_name]
			if destination ~= nil then
				local node_inv = meta:get_inventory()
				quick_move(node_inv, "main", node_inv:get_stack(from_list, from_index), destination.inv, destination.listname)
			end
		end
	elseif from_list == "main" and to_list == "trash" then
		return ifthenelse(internal.check_right(meta, player_name, "take"), count, 0)
	end
	return 0
end

function internal.allow_metadata_inventory_put(pos, listname, index, stack, player)
	local player_name = player and player:get_player_name()
	if player_name == nil then return 0 end
	local meta = minetest.get_meta(pos)

	if listname == "main" then
		if internal.check_right(meta, player_name, "put") then
			return stack:get_count()
		else
			return 0
		end

	elseif listname == "qmove" then
		local source = internal.player_to_current_inventory[player_name]
		if source ~= nil then
			quick_move(source.inv, source.listname, stack, meta:get_inventory(), "main")
		end
		return 0

	elseif listname == "trash" then
		return stack:get_count()

	elseif listname == "upgrades" then
		-- postava musí mít právo "set"
		if not internal.check_right(meta, player_name, "set") then
			return 0
		end
		-- předchozí slot (existuje-li) musí být plný
		local inv = meta:get_inventory()
		if index > 1 and inv:get_stack("upgrades", index - 1):is_empty() then
			return 0
		end
		-- tento a následující slot (existuje-li) musejí být prázdné
		if not inv:get_stack("upgrades", index):is_empty() or
		   (index < #internal.upgrades and not inv:get_stack("upgrades", index + 1):is_empty())
		then
			return 0
		end
		-- musí jít o očekávaný předmět
		local upgrade = internal.upgrades[index]
		if upgrade == nil then
			return 0
		end
		return ifthenelse(table.indexof(upgrade.items, stack:get_name()) ~= -1, 1, 0)

	else
		return 0
	end
end

function internal.allow_metadata_inventory_take(pos, listname, index, stack, player)
	local player_name = player and player:get_player_name()
	if player_name == nil then return 0 end
	local meta = minetest.get_meta(pos)

	if listname == "main" then
		if internal.check_right(meta, player_name, "take") then
			return stack:get_count()
		else
			return 0
		end

	elseif listname == "trash" or listname == "qmove" then
		return stack:get_count()

	elseif listname == "upgrades" then
		-- postava musí mít právo "set"
		if not internal.check_right(meta, player_name, "set") then
			return 0
		end
		-- následující slot (existuje-li) musí být prázdný
		local inv = meta:get_inventory()
		if index < #internal.upgrades and not inv:get_stack("upgrades", index + 1):is_empty() then
			return 0
		end
		-- ztrácené přihrádky musejí být neobsazené
		local new_count
		if index == 1 then
			new_count = internal.default_width * internal.default_height
		else
			local upgrade = internal.upgrades[index - 1]
			new_count = upgrade.width * upgrade.height
		end
		for i = new_count + 1, inv:get_size("main") do
			if not inv:get_stack("main", i):is_empty() then
				return 0
			end
		end
		return 1

	else
		return 0
	end
end

function internal.on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	if to_list == "trash" then
		ch_core.vyhodit_inventar(player:get_player_name(), minetest.get_meta(pos):get_inventory(), to_list, "koš truhly")
	end
end

function internal.on_metadata_inventory_put(pos, listname, index, stack, player)
	if listname == "trash" then
		ch_core.vyhodit_inventar(player:get_player_name(), minetest.get_meta(pos):get_inventory(), listname, "koš truhly")

	elseif listname == "upgrades" then
		local upgrade = assert(internal.upgrades[index])
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		meta:set_int("width", upgrade.width)
		meta:set_int("height", upgrade.height)
		inv:set_size("main", upgrade.width * upgrade.height)
		internal.update_chest_infotext(meta)
	end
end

function internal.on_metadata_inventory_take(pos, listname, index, stack, player)
	if listname == "upgrades" then
		local upgrade = assert(internal.upgrades[index])
		local new_upgrade = internal.upgrades[index - 1]
		local new_width, new_height
		if new_upgrade ~= nil then
			new_width, new_height = new_upgrade.width, new_upgrade.height
		else
			new_width, new_height = internal.default_width, internal.default_height
		end
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		meta:set_int("width", new_width)
		meta:set_int("height", new_height)
		inv:set_size("main", new_width * new_height)
		internal.update_chest_infotext(meta)
	end
end

function internal.insert_object(pos, node, stack)
	local meta = minetest.get_meta(pos)
	if internal.check_right(meta, nil, "put") then
		-- TODO: log
		return meta:get_inventory():add_item("main", stack)
	else
		return stack
	end
end

function internal.can_insert(pos, node, stack)
	local meta = minetest.get_meta(pos)
	if internal.check_right(meta, nil, "put") then
		if meta:get_int("splitstacks") == 1 and stack:get_count() > 1 then
			stack = ItemStack(stack)
			stack:set_count(1)
		end
		-- TODO: log
		return meta:get_inventory():room_for_item("main", stack)
	else
		return false
	end
end

function internal.remove_items(pos, node, stack, dir, count, list, index)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local items = stack:take_item(count)
	inv:set_stack(list, index, stack)
	-- TODO: log
	return items
end

function internal.set_group_members(meta, input)
	local comments, members, set = {}, {}, {}
	for s1 in input:gmatch("[^\n]+") do
		local s2 = s1:gsub("^%s*", "")
		s2 = s2:gsub("%s*$", "")
		s2 = ch_core.jmeno_na_prihlasovaci(s2)
		if minetest.player_exists(s2) then
			if set[s2] == nil then
				set[s2] = true
				table.insert(members, s2)
			end
		elseif s2:sub(1,1) == "#" then
			table.insert(comments, s2)
		else
			table.insert(comments, "#"..s2)
		end
	end
	table.sort(members)
	local agroup, agroup_raw
	if #members == 0 then
		agroup = ""
	else
		agroup = "|"..table.concat(members, "|").."|"
	end
	agroup_raw = table.concat(members, "\n").."\n"..table.concat(comments, "\n")
	meta:set_string("agroup", agroup)
end

function internal.move_ex(src_inv, src_listname, dst_inv, dst_listname)
	local filter = {}
	local list = dst_inv:get_list(dst_listname)
	for _, stack in ipairs(list) do
		if not stack:is_empty() then
			filter[stack:get_name()] = true
		end
	end
	list = src_inv:get_list(src_listname)
	for i, stack in ipairs(list) do
		if not stack:is_empty() and filter[stack:get_name()] then
			src_inv:set_stack(src_listname, i, dst_inv:add_item(dst_listname, stack))
		end
	end
end

function internal.move_all(src_inv, src_listname, dst_inv, dst_listname)
	local list = src_inv:get_list(src_listname)
	for i, stack in ipairs(list) do
		if not stack:is_empty() then
			src_inv:set_stack(src_listname, i, dst_inv:add_item(dst_listname, stack))
		end
	end
end

local function si_lt(a, b)
	-- 1. prázdné dávky jsou větší než cokoliv
	if b:is_empty() and not a:is_empty() then
		return true
	end
	if not b:is_empty() and a:is_empty() then
		return false
	end

	return a:get_name() < b:get_name()
end

function internal.sort_inventory(sort_mode, inv, listname)
	local list = inv:get_list(listname)
	-- TODO: [ ] sort_mode support
	table.sort(list, si_lt)
	inv:set_list(listname, list)
end
