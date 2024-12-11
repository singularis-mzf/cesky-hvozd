local internal = ...

local get_feature = internal.get_feature
-- local ifthenelse = ch_core.ifthenelse

function ch_chest.on_construct(pos)
	local meta = core.get_meta(pos)
	local node = core.get_node(pos)
	local inv = meta:get_inventory()
	local width, height = get_feature(node.name, meta, "width"), get_feature(node.name, meta, "height")
	inv:set_size("main", width * height)
	if get_feature(node.name, meta, "qmove") then
		inv:set_size("qmove", 1)
	end
	if get_feature(node.name, meta, "trash") then
		inv:set_size("trash", 1)
	end
	-- inv:set_size("upgrades", 5)
	-- meta:set_int("chest_id", internal.new_chest_id())
end

function ch_chest.after_place_node(pos, placer, itemstack, pointed_thing)
	local meta = core.get_meta(pos)
	local node = core.get_node(pos)
	local ownership = get_feature(node.name, meta, "ownership")
	if ownership == "owner" and meta:get_string("owner") == "" then
		meta:set_string("owner", (placer and placer:get_player_name()) or "")
		ch_chest.update_chest_infotext(node, meta)
	end
end

function ch_chest.after_dig_node(pos, oldnode, oldmetadata, digger)
end

function ch_chest.preserve_metadata(pos, oldnode, oldmeta, drops)
end

function ch_chest.can_dig(pos, player)
	if player == nil then
		return false
	end
	local player_name = player:get_player_name()
	if core.is_protected(pos, player_name) then
		core.record_protection_violation(pos, player_name)
		return false
	end
	-- if internal.check_right(core.get_meta(pos), player:get_player_name(), "dig") then
	return true
end

function ch_chest.on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	if to_list == "trash" then
		ch_core.vyhodit_inventar(player:get_player_name(), core.get_meta(pos):get_inventory(), to_list, "koš truhly")
	end
end

function ch_chest.on_metadata_inventory_put(pos, listname, index, stack, player)
	if listname == "trash" then
		ch_core.vyhodit_inventar(player:get_player_name(), core.get_meta(pos):get_inventory(), listname, "koš truhly")
	--[[
	elseif listname == "upgrades" then
		local upgrade = assert(internal.upgrades[index])
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		meta:set_int("width", upgrade.width)
		meta:set_int("height", upgrade.height)
		inv:set_size("main", upgrade.width * upgrade.height)
		internal.update_chest_infotext(node, meta)
		]]
	end
end

function ch_chest.on_metadata_inventory_take(pos, listname, index, stack, player)
	--[[
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
		internal.update_chest_infotext(node, meta)
	end
	]]
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

function ch_chest.allow_metadata_inventory_put(pos, listname, index, stack, player)
	local player_name = player and player:get_player_name()
	if player_name == nil then return 0 end
	local meta = core.get_meta(pos)
	local node = core.get_node(pos)

	if listname == "main" then
		if internal.check_right(node.name, meta, player_name, "put") then
			return stack:get_count()
		else
			return 0
		end

	elseif listname == "qmove" then
		quick_move(player:get_inventory(), "main", stack, meta:get_inventory(), "main")
		return 0

	elseif listname == "trash" then
		return stack:get_count()
	--[[
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
		]]

	else
		return 0
	end
end

function ch_chest.allow_metadata_inventory_take(pos, listname, index, stack, player)
	local player_name = player and player:get_player_name()
	if player_name == nil then return 0 end
	local meta = core.get_meta(pos)

	if listname == "main" then
		if internal.check_right(meta, player_name, "take") then
			return stack:get_count()
		else
			return 0
		end

	elseif listname == "trash" or listname == "qmove" then
		return stack:get_count()

	--[[
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
		]]

	else
		return 0
	end
end

function ch_chest.on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	local player_name = clicker and clicker:get_player_name()
	if player_name == nil then
		return
	end
	local meta = core.get_meta(pos)
	if internal.can_view(node.name, meta, player_name) then
		internal.show_formspec(clicker, pos, node, meta)
	end
end

function ch_chest.can_insert(pos, node, stack)
	local meta = core.get_meta(pos)
	if not get_feature(node.name, meta, "pipeworks") or not internal.can_put(node.name, meta) then
		return false
	end
	if meta:get_int("splitstacks") == 1 and stack:get_count() > 1 then
		stack = ItemStack(stack)
		stack:set_count(1)
	end
	-- TODO: log
	return meta:get_inventory():room_for_item("main", stack)
end

function ch_chest.insert_object(pos, node, stack)
	local meta = core.get_meta(pos)
	if get_feature(node.name, meta, "pipeworks") and internal.can_put(node.name, meta) then
		-- TODO: log
		return meta:get_inventory():add_item("main", stack)
	else
		return stack
	end
end

function ch_chest.remove_items(pos, node, stack, dir, count, list, index)
	local meta = core.get_meta(pos)
	local inv = meta:get_inventory()
	local items = stack:take_item(count)
	inv:set_stack(list, index, stack)
	-- TODO: log
	return items
end

function ch_chest.on_blast()
end
























--[[




local right_to_index = {
	view = 1,
	sort = 4,
	put = 7,
	take = 10,
	dig = 13,
	set = 16,
}

local player_to_current_inventory = {}

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
]]

--[[
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
]]

function ch_chest.update_chest_infotext(node, meta)
    local has_title = internal.get_feature(node.name, meta, "has_title")
    local ownership = internal.get_feature(node.name, meta, "ownership")
    local result = {}
    if has_title then
        table.insert(result, meta:get_string("title"))
    end
    if ownership == "owner" then
        table.insert(result, "truhlu vlastní: "..ch_core.prihlasovaci_na_zobrazovaci(meta:get_string("owner")))
    end
    if #result > 0 then
        result = table.concat(result, "\n")
    else
        result = ""
    end
    meta:set_string("infotext", result)
end
