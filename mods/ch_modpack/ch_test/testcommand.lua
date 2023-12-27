local def

local function zero()
	return 0
end

minetest.create_detached_inventory("ch_test_watch_inventory", {
	allow_move = zero, allow_put = zero, allow_take = zero
})

local function update_inventory(player_name, listname)
	local watch_inv = minetest.get_inventory({type = "detached", name = "ch_test_watch_inventory"})
	local player = minetest.get_player_by_name(player_name)
	local player_inv, new_size
	if player then
		player_inv = player:get_inventory()
		new_size = player_inv:get_size(listname)
		watch_inv:set_size("main", new_size)
		print("[ch_test] size of detached:ch_test_watch_inventory/main set to "..new_size)
		if new_size > 0 then
			watch_inv:set_list("main", player_inv:get_list(listname))
		end
	else
		new_size = 0
		watch_inv:set_size("main", new_size)
		print("[ch_test] size of detached:ch_test_watch_inventory/main set to "..new_size)
	end
	return new_size
end

local dropdown = ch_core.make_dropdown({
	"main",
	"craft",
	"bag1",
	"bag2",
	"bag3",
	"bag4",
	"bag5",
	"bag6",
	"bag7",
	"bag8",
})

local count_to_size = {
	[1] = "1,1",
	[4] = "2,2",
	[9] = "3,3",
	[16] = "4,4",
	[32] = "8,4",
}

local function get_formspec(player_name, inventory_index)
	local watch_inv = minetest.get_inventory({type = "detached", name = "ch_test_watch_inventory"})
	local size = watch_inv:get_size("main")
	local formspec = {
		"formspec_version[5]",
		"size[14,13.5]",
		"dropdown[1,0.375;2,0.5;inventory;", dropdown.formspec_list, ";"..inventory_index..";true]",
		"list[current_player;main;2.5,8;8,4;]",
	}
	if size ~= 0 then
		table.insert(formspec, "list[detached:ch_test_watch_inventory;main;2.5,1;"..(count_to_size[size] or "8,4")..";]")
	end
	return table.concat(formspec)
end

local function formspec_callback(custom_state, player, formname, fields)
	if fields.quit then
		local watch_inv = minetest.get_inventory({type = "detached", name = "ch_test_watch_inventory"})
		watch_inv:set_size("main", 0)
		return
	end
	if fields.inventory then
		local new_inventory = dropdown.get_value_from_index(fields.inventory, 1)
		print("new_inventory = "..(new_inventory or "nil"))
		update_inventory(custom_state.player_name, new_inventory)
		custom_state.inventory_index = dropdown.value_to_index[new_inventory]
	end
	print("DEBUG: formspec_callback called: "..dump2(fields))
	return get_formspec(player:get_player_name(), custom_state.inventory_index)
end

local function command(player_name, param)
	local player = minetest.get_player_by_name(player_name)
	if not player then
		error("Player object '"..player_name.."' not found!")
	end

	--[[
	local another_player = minetest.get_player_by_name(param)
	if another_player == nil then
		return false, "Postava '"..param.."' není ve hře!"
	end
	local inv = another_player:get_inventory()
	print("Inventory location = "..dump2({location = inv:get_location(), player_name = param}))
	]]

	local inventory_index = 1
	update_inventory(param, dropdown.index_to_value[inventory_index])
	local formspec = get_formspec(player_name, inventory_index)
	ch_core.show_formspec(player, "ch_test:test_command", formspec, formspec_callback, {
		player_name = param,
		inventory_index = inventory_index,
	}, {})
end

def = {
	params = "[text]",
	description = "spustí právě testovanou akci pro účely vývoje serveru (jen pro Administraci)",
	privs = {server = true},
	func = command,
}
minetest.register_chatcommand("test", def)
