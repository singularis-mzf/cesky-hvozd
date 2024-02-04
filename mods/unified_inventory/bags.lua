--[[
Bags for Minetest

Copyright (c) 2012 cornernote, Brett O'Donnell <cornernote@gmail.com>
Copyright (c) 2023-2024 Singularis <singularis@volny.cz>
License: GPLv3
--]]

local S = minetest.get_translator("unified_inventory")
local F = minetest.formspec_escape
local ui = unified_inventory

local count_alignment = 14
local count_empty_stacks = ch_core.count_empty_stacks
local ifthenelse = ch_core.ifthenelse

function ui.get_bags_info(player)
	if not minetest.is_player(player) then
		return nil
	end
	local player_name = player:get_player_name()
	local inventory = player:get_inventory()
	local meta = player:get_meta()
	local detached = minetest.get_inventory{type = "detached", name = player_name.."_bags"}
	local result = {
		player_name = player_name,
		total_bags = 6,
		current_bags = 0,
		current_bags_slots = 0,
	}
	for i = 1, result.total_bags do
		local item = detached:get_stack("bag"..i, 1)
		if not item:is_empty() then
			local itemname = item:get_name()
			local slots = minetest.get_item_group(itemname, "bagslots")
			if slots > 0 then
				local title = meta:get_string("bag"..i.."_title")
				if title == "" then
					title = "batoh "..i
				end
				result["bag"..i] = {
					title = title,
					slots = slots,
					item = itemname,
					image = minetest.registered_items[itemname].inventory_image,
				}
				result.current_bags = result.current_bags + 1
				result.current_bags_slots = result.current_bags_slots + slots
			end
		end
	end
	return result
end

local function compute_xy_bases(bag_i)
	local x_base
	if bag_i < 4 then
		x_base = 0.25
		bag_i = bag_i - 1
	else
		x_base = 4.5
		bag_i = bag_i - 4
	end
	return x_base, 1.15 + bag_i * 1.25
end

local function get_bags_formspec(bags_info)
	local trash_x, trash_y = 8.75, 3.5
	local formspec = {
		ui.style_full.standard_inv_bg,
		"label[0.3,0.65;"..S("Bags").."]",
		string.format("label[%f,%f;%s]", trash_x, trash_y - 0.25, F(S("Trash:"))),
		ui.make_trash_slot(trash_x, trash_y),
	}
	local player_name = bags_info.player_name
	-- "list[detached:" .. F(bags_info.player_name) .. "_bags;bag1;0.250,1.65;1,1;]",
	for i = 1, 6 do
		local x_base, y_base = compute_xy_bases(i)
		local current_bag = bags_info["bag"..i]
		table.insert(formspec,
			ui.single_slot(x_base - 0.15, y_base - 0.15)..
			"list[detached:"..F(player_name).."_bags;bag"..i..";"..x_base..","..y_base..";1,1;]")
		if current_bag ~= nil then
			table.insert(formspec, "button["..(x_base + 1.15)..","..y_base..";2.5,1.0;bag"..i..";"..F(current_bag.title).."]")
		end
	end
	return table.concat(formspec)
end

ui.register_page("bags", {
	get_formspec = function(player)
		return {
			draw_item_list = false,
			formspec = get_bags_formspec(ui.get_bags_info(player)),
		}
	end,
})

ui.register_button("bags", {
	type = "image",
	image = "ui_bags_icon.png",
	tooltip = S("Bags"),
	hide_lite=true,
	condition = function(player)
		return minetest.check_player_privs(player, "ch_registered_player")
	end,
})

local function get_player_bag_stack(player, i)
	return minetest.get_inventory({
		type = "detached",
		name = player:get_player_name() .. "_bags"
	}):get_stack("bag" .. i, 1)
end

for bag_i = 1, 6 do
	ui.register_page("bag" .. bag_i, {
		get_formspec = function(player)
			local bags_info = ui.get_bags_info(player)
			local bags_info_without_current = table.copy(bags_info)
			bags_info_without_current["bag"..bag_i] = nil
			local current_bag = bags_info["bag"..bag_i] or
				{title = S("Bag @1", bag_i), slots = 0, itemname = "unified_inventory:bag_small", image = minetest.registered_items["unified_inventory:bag_small"].inventory_image}

			local x_base, y_base = compute_xy_bases(bag_i)
			local baginv_x, baginv_y = 11, 0.25
			local formspec = {
				get_bags_formspec(bags_info_without_current),
				"field["..(x_base + 1.15)..","..y_base..";2.5,0.5;bag"..bag_i.."title;;"..F(current_bag.title).."]",
				"button["..(x_base + 1.15)..","..(y_base + 0.6)..";2.5,0.5;bag"..bag_i.."savetitle;"..S("Save Title").."]",
				ui.make_inv_img_grid(baginv_x, baginv_y, 5, math.ceil(current_bag.slots/5)),
				"image[9.75,0.4;1,1;" .. current_bag.image .. "]",
				"tooltip[9.75,0.4;1,1;"..F(current_bag.title).."]",
				-- "label[0.3,0.65;" .. F(current_bag.title) .. "]",
				"listcolors[#00000000;#00000000]",
				"listring[current_player;main]",
				string.format("list[current_player;bag%icontents;%f,%f;5,9;]", bag_i, baginv_x + ui.list_img_offset, baginv_y + ui.list_img_offset),
				"listring[current_name;bag" .. bag_i .. "contents]",
				--[[ TODO: implement
				"dropdown[11,11.5;4.25,0.5;sorttype;test 1,test 2,test3,podle popisu (vzestupně);1;true]",
				"button[15.5,11.5;2,0.5;sortbag;seřadit batoh]",
				]]
			}
			return {
				draw_item_list = false,
				formspec = table.concat(formspec)
			}
		end,
	})
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "" then
		return
	end
	for i = 1, 6 do
		if fields["bag" .. i] then
			local stack = get_player_bag_stack(player, i)
			if not stack:get_definition().groups.bagslots then
				return
			end
			ui.set_inventory_formspec(player, "bag" .. i)
			return
		elseif fields["bag"..i.."savetitle"] then
			local meta = player:get_meta()
			meta:set_string("bag"..i.."_title", fields["bag"..i.."title"] or "")
			return
		end
	end
end)

local function update_bag_metadata(player_inv, bags_inv, bag_i, change_hint)
	local bag_item = bags_inv:get_stack("bag"..bag_i, 1)
	if bag_item:is_empty() then
		return
	end
	local bag_item_meta = bag_item:get_meta()
	if change_hint ~= nil then
		local count, size = bag_item_meta:get_string("count_meta"):match("^(%d+)/(.*)$")
		if tonumber(count) ~= nil and size ~= nil then
			count = tonumber(count) + change_hint
			if 0 <= count and count <= 65535 then
				bag_item_meta:set_string("count_meta", count.."/"..size)
				bags_inv:set_stack("bag"..bag_i, 1, bag_item)
				return true
			end
		end
	end
	-- full update:
	local items_in_bag = player_inv:get_list("bag"..bag_i.."contents") or {}
	local size = player_inv:get_size("bag"..bag_i.."contents")
	local count = size - count_empty_stacks(items_in_bag)
	bag_item_meta:set_string("count_meta", count.."/"..size)
	bags_inv:set_stack("bag"..bag_i, 1, bag_item)
end

local function nahlasit_batohy(player, bags_inv)
	local ch_bank = ui.ch_bank
	if ch_bank then
		local player_inv = player:get_inventory()
		local player_meta = player:get_meta()
		local info_for_ch_bank = {}

		for i = 1, 6 do
			local listname = "bag"..i.."contents"
			local bag_size = player_inv:get_size(listname)
			if bag_size > 0 then
				local title = player_meta:get_string("bag"..i.."_title")
				if title == "" then
					title = S("Bag @1", i)
				end
				table.insert(info_for_ch_bank, {
					listname = listname,
					title = title,
					width = 5,
					height = math.ceil(bag_size / 5),
				})
			end
		end
		ch_bank.nahlasit_batohy(player, info_for_ch_bank)
	end
end

local function save_bags_metadata(player, bags_inv)
	local is_empty = true
	local bags = {}
	for i = 1, 6 do
		local bag = "bag" .. i
		if not bags_inv:is_empty(bag) then
			-- Stack limit is 1, otherwise use stack:to_string()
			bags[i] = bags_inv:get_stack(bag, 1):get_name()
			is_empty = false
		end
	end
	local meta = player:get_meta()
	if is_empty then
		meta:set_string("unified_inventory:bags", nil)
	else
		meta:set_string("unified_inventory:bags",
			minetest.serialize(bags))
	end
	nahlasit_batohy(player, bags_inv)
end

local function load_bags_metadata(player, bags_inv)
	local player_inv = player:get_inventory()
	local meta = player:get_meta()
	local bags_meta = meta:get("unified_inventory:bags")
	local bags = bags_meta and minetest.deserialize(bags_meta) or {}
	local dirty_meta = false
	if not bags_meta then
		-- Backwards compatiblity
		for i = 1, 6 do
			local bag = "bag" .. i
			if not player_inv:is_empty(bag) then
				-- Stack limit is 1, otherwise use stack:to_string()
				bags[i] = player_inv:get_stack(bag, 1):get_name()
				dirty_meta = true
			end
		end
	end
	-- Fill detached slots
	for i = 1, 6 do
		local bag = "bag" .. i
		bags_inv:set_size(bag, 1)
		if bags[i] ~= nil then
			local expected_size = minetest.get_item_group(bags[i], "bagslots")
			local bag_item = ItemStack(bags[i])
			bag_item:get_meta():set_int("count_alignment", 14) -- bottom middle
			bags_inv:set_stack(bag, 1, bag_item)
			if player_inv:get_size(bag.."contents") < expected_size then
				player_inv:set_size(bag.."contents", expected_size)
			end
			update_bag_metadata(player_inv, bags_inv, i)
		else
			bags_inv:set_stack(bag, 1, ItemStack())
		end
	end

	local bags_info = ui.get_bags_info(player)

	-- Upgrade bag-system
	if bags[7] ~= nil or bags[8] ~= nil or player_inv:get_size("bag7contents") > 0 or player_inv:get_size("bag8contents") > 0 then
		minetest.log("action", "Will upgrade bags: "..dump2({
			player_name = player:get_player_name(),
			main = player_inv:get_list("main"),
			craft = player_inv:get_list("craft"),
			bag1 = player_inv:get_list("bag1contents"),
			bag2 = player_inv:get_list("bag2contents"),
			bag3 = player_inv:get_list("bag3contents"),
			bag4 = player_inv:get_list("bag4contents"),
			bag5 = player_inv:get_list("bag5contents"),
			bag6 = player_inv:get_list("bag6contents"),
			bag7 = player_inv:get_list("bag7contents"),
			bag8 = player_inv:get_list("bag8contents"),
		}))
		for i = 1, 6 do
			local current_bag = bags_info["bag"..i]
			if current_bag ~= nil then
				player_inv:set_size("bag"..i.."contents", current_bag.slots)
				update_bag_metadata(player_inv, bags_inv, i)
			end
		end
		local output_i = 1
		local items_to_return = {}
		for i = 7, 8 do
			if player_inv:get_size("bag"..i.."contents") > 0 then
				table.insert_all(items_to_return, player_inv:get_list("bag"..i.."contents"))
				player_inv:set_size("bag"..i.."contents", 0)
			end
			if bags[i] ~= nil then
				table.insert(items_to_return, ItemStack(bags[i]))
			end
		end
		if ui.ch_bank then
			ui.ch_bank.give_items_to_player(player, player_inv, items_to_return)
		else
			minetest.log("warning", "Player "..player:get_player_name().." lost items during bag-upgrade: "..dump2(items_to_return))
		end
		bags[8] = nil
		bags[7] = nil
		dirty_meta = true
	end

	if dirty_meta then
		-- Requires detached inventory to be set up
		save_bags_metadata(player, bags_inv)
	else
		nahlasit_batohy(player, bags_inv)
	end

	-- Clean up deprecated garbage after saving
	for i = 1, 6 do
		local bag = "bag" .. i
		player_inv:set_size(bag, 0)
	end
end

local function bags_on_put(inv, listname, index, stack, player)
	local player_inv = player:get_inventory()
	player_inv:set_size(listname .. "contents",
		stack:get_definition().groups.bagslots)
	stack:get_meta():set_int("count_alignment", count_alignment)
	inv:set_stack(listname, index, stack)
	update_bag_metadata(player_inv, inv, tonumber(listname:sub(4, 4)))
	save_bags_metadata(player, inv)
	ui.set_inventory_formspec(player, "bags")
end

local function bags_allow_put(inv, listname, index, stack, player)
	local new_slots = stack:get_definition().groups.bagslots
	if not new_slots then
		return 0
	end
	local player_inv = player:get_inventory()
	local old_slots = player_inv:get_size(listname .. "contents")

	if new_slots >= old_slots then
		return 1
	end

	-- using a smaller bag, make sure it fits
	local old_list = player_inv:get_list(listname .. "contents")
	local new_list = {}
	local slots_used = 0
	local use_new_list = false

	for i, v in ipairs(old_list) do
		if v and not v:is_empty() then
			slots_used = slots_used + 1
			use_new_list = i > new_slots
			new_list[slots_used] = v
		end
	end
	if new_slots >= slots_used then
		if use_new_list then
			player_inv:set_list(listname .. "contents", new_list)
		end
		return 1
	end
	-- New bag is smaller: Disallow inserting
	return 0
end

local function bags_allow_take(inv, listname, index, stack, player)
	if player:get_inventory():is_empty(listname .. "contents") then
		stack:get_meta():from_table(false) -- clear metadata
		inv:set_stack(listname, index, stack)
		return 1
	end
	return 0
end

local function bags_on_take(inv, listname, index, stack, player)
	player:get_inventory():set_size(listname .. "contents", 0)
	save_bags_metadata(player, inv)
	ui.set_inventory_formspec(player, "bags")
end

local function bags_allow_move()
	return 0
end

local bags_callbacks = {
	allow_move = bags_allow_move,
	allow_put = bags_allow_put,
	allow_take = bags_allow_take,
	on_put = bags_on_put,
	on_take = bags_on_take,
}

minetest.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	local bags_inv = minetest.create_detached_inventory(player_name .. "_bags", bags_callbacks, player_name)
	load_bags_metadata(player, bags_inv)
end)

local bag_pattern = "^bag[123456]contents$"
minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
	local take_list, take_stack_after, put_list, put_count_before
	if action == "move" then
		local from_list, to_list = inventory_info.from_list, inventory_info.to_list
		local from_index, to_index, count = inventory_info.from_index, inventory_info.to_index, inventory_info.count
		if from_list:match(bag_pattern) then
			take_list = from_list
			take_stack_after = inventory:get_stack(from_list, from_index)
		end
		if to_list:match(bag_pattern) then
			put_list = to_list
			put_count_before = inventory:get_stack(to_list, to_index):get_count() - count
		end
	elseif action == "put" and inventory_info.listname:match(bag_pattern) then
		put_list = inventory_info.listname
		put_count_before = inventory:get_stack(inventory_info.listname, inventory_info.index):get_count() - inventory_info.stack:get_count()
	elseif action == "take" and inventory_info.listname:match(bag_pattern) then
		take_list = inventory_info.listname
		take_stack_after = inventory:get_stack(inventory_info.listname, inventory_info.index)
	end
	if take_list ~= nil and not take_stack_after:is_empty() then
		take_list = nil
	end
	if put_list ~= nil and put_count_before ~= 0 then
		put_list = nil
	end
	if take_list ~= nil or put_list ~= nil then
		local bags_inv = minetest.get_inventory{type = "detached", name = player:get_player_name().."_bags"}
		if take_list == put_list then
			return
		end
		if take_list ~= nil then
			update_bag_metadata(inventory, bags_inv, assert(tonumber(take_list:sub(4, 4))), -1)
		end
		if put_list ~= nil then
			update_bag_metadata(inventory, bags_inv, assert(tonumber(put_list:sub(4, 4))), 1)
		end
	end
end)

-- register bag tools
local ch_help = "Batohy slouží k rozšíření hlavního inventáře. Když je vložíte na příslušné místo v okně inventáře,\nmůžete si pak do nich odkládat věci, které by se vám jinak do inventáře nevešly,\nale přesto je chcete mít stále po ruce. Batohy existují ve třech velikostech."
local ch_help_group = "bag"
minetest.register_tool("unified_inventory:bag_small", {
	description = S("Small Bag"),
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
	inventory_image = "bags_small.png",
	groups = {bagslots=15},
})

minetest.register_tool("unified_inventory:bag_medium", {
	description = S("Medium Bag"),
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
	inventory_image = "bags_medium.png",
	groups = {bagslots=30},
})

minetest.register_tool("unified_inventory:bag_large", {
	description = S("Large Bag"),
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
	inventory_image = "bags_large.png",
	groups = {bagslots=45},
})

-- register bag crafts
if minetest.get_modpath("farming") ~= nil then
	minetest.register_craft({
		output = "unified_inventory:bag_small",
		recipe = {
			{"",           "farming:string", ""},
			{"group:wool", "group:wool",     "group:wool"},
			{"group:wool", "group:wool",     "group:wool"},
		},
	})

	minetest.register_craft({
		output = "unified_inventory:bag_medium",
		recipe = {
			{"",               "",                            ""},
			{"farming:string", "unified_inventory:bag_small", "farming:string"},
			{"farming:string", "unified_inventory:bag_small", "farming:string"},
		},
	})

	minetest.register_craft({
		output = "unified_inventory:bag_large",
		recipe = {
			{"",               "",                             ""},
			{"farming:string", "unified_inventory:bag_medium", "farming:string"},
			{"farming:string", "unified_inventory:bag_medium", "farming:string"},
	    },
	})
end
