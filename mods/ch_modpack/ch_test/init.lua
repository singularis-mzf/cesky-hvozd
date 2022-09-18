print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local ui = unified_inventory
local F = minetest.formspec_escape

--[[
local function apply_filter(player, formname, fields, menu_def)
	ui.apply_filter(player, menu_def.filter_group, "nochange")
	minetest.sound_play("paperflip2", {to_player = player:get_player_name(), gain = 1.0})
end

local menu_items = {
	{
		id = "na_kp",
		title = "na kotoučovou pilu",
		label = "KP",
		item_for_icon = "moreblocks:circular_saw",
		func = apply_filter,
		filter_group = "group:na_kp",
	},
	{
		id = "na_kp2",
		title = "jen test",
		label = "",
		item_for_icon = "moreblocks:circular_saw",
		func = apply_filter,
		filter_group = "group:seed",
	},
}

ui.register_button("test_form", {
	type = "image",
	image = "ui_craft_icon.png",
	tooltip = "Test Form"
})

local function get_test_form_formspec(player, perplayer_formspec)
	local player_name = player:get_player_name()
	local button_size = perplayer_formspec.btn_size
	local formspec = {
	"label["..perplayer_formspec.form_header_x..","..perplayer_formspec.form_header_y..";"..F("Testovací volby").."]",
		ui.style_full.standard_inv_bg,
	}

	local x_base = perplayer_formspec.form_header_x
	local y_base = perplayer_formspec.form_header_y + 0.5
	local x = 0
	local y = 0
	local scale = button_size * 1.1
	for _, item_def in ipairs(menu_items) do
		if minetest.registered_items[item_def.item_for_icon] then
			table.insert(formspec, string.format("item_image_button[%f,%f;%f,%f;%s;%s;%s]tooltip[%s;%s]",
				x_base + x * scale, y_base + y * scale, button_size, button_size,
				item_def.item_for_icon, "test_form_"..item_def.id, item_def.label or "", "test_form_"..item_def.id, F(item_def.title)))
			x = x + 1
		end
	end
	return {formspec = table.concat(formspec)}
end

ui.register_page("test_form", {get_formspec = get_test_form_formspec})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "" then
		return
	end

	for k, v in pairs(fields) do
		print("Will "..k.." match ^test_form_? ")
		if k:match("^test_form_") then
			local player_name = player:get_player_name()
			for _, item_def in ipairs(menu_items) do
				if k == "test_form_" .. item_def.id then
					if item_def.func then
						item_def.func(player, formname, fields, item_def)
					end
				end
			end
			-- ui.activefilter[player_name] = "group:na_kp"
			-- ui.apply_filter(player, "group:na_kp", "nochange")
			-- ui.set_inventory_formspec(player, ui.current_page[player_name])
			-- return
		else
			print("No match.")
		end
	end
end)
]]





















-- ARRAY STATS

local function array_stats(name, table)
	if not table then
		return name..":nil"
	end

	local count = 0
	local longest = ""
	local count_per_mod = {}
	local i, m, k2

	for k, _ in pairs(table) do
		i = string.find(k, ":")
		if i then
			m = k:sub(1, i - 1)
		else
			m = ""
		end
		count = count + 1
		count_per_mod[m] = (count_per_mod[m] or 0) + 1
		k2 = k..""
		if #k2 > #longest then
			longest = k2
		end
	end

	local mods_count = 0
	local mod_with_most_name = ""
	local mod_with_most_count = 0
	for mod, count in pairs(count_per_mod) do
		mods_count = mods_count + 1
		if count > mod_with_most_count then
			mod_with_most_name = mod
			mod_with_most_count = count
		end
	end

	return name..": "..count.." items of "..mods_count.." mods (most "..mod_with_most_count.." from mod "..mod_with_most_name.."), longest = "..longest
end

local function on_mods_loaded()
	print("Will do registered stats...")
	print(array_stats("registered_nodes", minetest.registered_nodes))
	print("----")
	print(array_stats("registered_items", minetest.registered_items))
	print(array_stats("registered_craftitems", minetest.registered_craftitems))
	print(array_stats("registered_tools", minetest.registered_tools))
	print(array_stats("registered_aliases", minetest.registered_aliases))
	print(array_stats("registered_entities", minetest.registered_entities))
	print(array_stats("registered_abms", minetest.registered_abms))
	print(array_stats("registered_lbms", minetest.registered_lbms))
	print(array_stats("registered_ores", minetest.registered_ores))
	print(array_stats("registered_decorations", minetest.registered_decorations))

	--[[
	print("Starting recipe export...")
	local world_path = minetest.get_worldpath()
	local f = io.open(world_path.."/recipes-export.txt", "w")
	local counter = 0
	local items_processed = {}
	for name, _ in pairs(minetest.registered_items) do
		local true_name = minetest.registered_aliases[name] or name
		if not items_processed[true_name] then
			local counter_orig = counter
			local recipes = minetest.get_all_craft_recipes(name)
			if recipes then
				for _, recipe in ipairs(recipes) do
					local output_str
					if type(recipe.output) == "string" then
						output_str = recipe.output
					else
						output_str = string.gsub(dump(recipe.output), "\t", " ")
					end
					local recipe_method = recipe.method or "nil"
					local recipe_width = recipe.width or -1
					local recipe_items = "1="..(recipe.items[1] or "")..",2="..(recipe.items[2] or "")..",3="..(recipe.items[3] or "")..",4="..(recipe.items[4] or "")..",5="..(recipe.items[5] or "")..",6="..(recipe.items[6] or "")..",7="..(recipe.items[7] or "")..",8="..(recipe.items[8] or "")..",9="..(recipe.items[9] or "")
					-- f:write(string.gsub(output_str.."\t"..recipe_method.."\t"..recipe_width.."\t"..recipe_items, "\n", "|||").."\n")
					counter = counter + 1
				end
			end
			items_processed[true_name] = true
			if counter == counter_orig and minetest.get_item_group(name, "not_in_creative_inventory") == 0 then
				f:write(name.."\n")
			end
		else
			print("item "..name.." with true name "..true_name.." already processed")
		end
	end
	f:close()
	print("Recipe export finished. "..counter.." recipes exported.")
	]]
end

minetest.register_on_mods_loaded(on_mods_loaded)

local function on_player_inventory_action(player, action, inventory, inventory_info)
	local message = "player_inventory_action("..player:get_player_name().." @ "..minetest.pos_to_string(vector.round(player:get_pos())).."): "
	if action == "move" then
		local destination_stack = inventory:get_stack(inventory_info.to_list, inventory_info.to_index)
		message = message.."move "..inventory_info.count.." of "..destination_stack:get_name().." from "..inventory_info.from_list.."/"..inventory_info.from_index.." to "..inventory_info.to_list.."/"..inventory_info.to_index
	elseif action == "put" or action == "take" then
		if action == "put" then
			message = message.." put to "
		else
			message = message.." take from "
		end
		
		message = message..inventory_info.listname.."/"..inventory_info.index.." ("..inventory_info.stack:get_count().." of "..inventory_info.stack:get_name()..")"
	else
		message = message..action
	end

	minetest.log("action", message)
end

minetest.register_on_player_inventory_action(on_player_inventory_action)



-- DYNAMIC WATER AND LAVA
local find_nodes_in_area = minetest.find_nodes_in_area
local get_node = minetest.get_node
local swap_node = minetest.swap_node
-- local remove_node = minetest.remove_node
local random = PseudoRandom(3456)
local shifts_below = {
	vector.new(-1, -1, 0),
	vector.new(0, -1, -1),
	vector.new(1, -1, 0),
	vector.new(0, -1, 1),
}
local function water_func(pos, node, active_object_count, active_object_count_wider)
	local pos_below = vector.new(pos.x, pos.y - 1, pos.z)
	local node_below = get_node(pos_below)

	if node_below.name == "default:water_flowing" then
		swap_node(pos_below, node)
		swap_node(pos, node_below)
	else
		local rnd = random:next(1, 16)
		if rnd < 5 and node_below.name ~= "default:water_source" then
			pos_below = vector.add(pos, shifts_below[rnd])
			node_below = get_node(pos_below)
			if node_below.name == "default:water_flowing" then
				swap_node(pos_below, node)
				swap_node(pos, node_below)
			end
		elseif rnd < 7 then
			local nodes = find_nodes_in_area(vector.new(pos.x - 1, pos.y, pos.z - 1), vector.new(pos.x + 1, pos.y, pos.z + 1), "default:water_flowing")
			if #nodes == 8 then
				node.name = "default:water_flowing"
				swap_node(pos, node)
			end
		end
	end
end

local function lava_func(pos, node, active_object_count, active_object_count_wider)
	local pos_below = vector.new(pos.x, pos.y - 1, pos.z)
	local node_below = get_node(pos_below)

	if node_below.name == "default:lava_flowing" then
		swap_node(pos_below, node)
		swap_node(pos, node_below)
	else
		local rnd = random:next(1, 16)
		if rnd < 5 then
			pos_below = vector.add(pos, shifts_below[rnd])
			node_below = get_node(pos_below)
			if node_below.name == "default:lava_flowing" then
				swap_node(pos_below, node)
				swap_node(pos, node_below)
			end
		elseif rnd < 7 then
			if get_node(vector.new(pos.x - 1, pos.y, pos.z)).name == "default:lava_flowing"
			and get_node(vector.new(pos.x + 1, pos.y, pos.z)).name == "default:lava_flowing"
			and get_node(vector.new(pos.x, pos.y, pos.z - 1)).name == "default:lava_flowing"
			and get_node(vector.new(pos.x, pos.y, pos.z + 1)).name == "default:lava_flowing" then
				node.name = "default:lava_flowing"
				swap_node(pos, node)
			end
		end
	end
end

local abm_def = {
	label = "CH dynamic water",
	nodenames = {"default:water_source"},
	neighbors = {"default:water_flowing"},
	interval = 2,
	chance = 1,
	catch_up = false,
	action = water_func,
}
minetest.register_abm(abm_def)
abm_def = {
	label = "CH dynamic lava",
	nodenames = {"default:lava_source"},
	neighbors = {"default:lava_flowing"},
	interval = 2,
	chance = 2,
	catch_up = false,
	action = lava_func,
}
minetest.register_abm(abm_def)

























print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

