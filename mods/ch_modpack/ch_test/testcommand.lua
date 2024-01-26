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



--

local color = minetest.get_color_escape_sequence("#FFCC9980")
local color2 = minetest.get_color_escape_sequence("#FFCC99")

local function escape_hypertext(s)
	local e = s:find("[][><\\,;]")
	if e == nil then
		return s
	end
	local result = {}
	local b = 1
	while e ~= nil do
		if b < e then
			table.insert(result, s:sub(b, e - 1))
		end
		local c = s:sub(e, e)
		if c == "\\" then
			table.insert(result, "\\\\\\")
		elseif c == "<" or c == ">" then
			table.insert(result, "\\\\")
		else
			table.insert(result, "\\")
		end
		b = e
		e = s:find("[][><\\,;]", b + 1)
	end
	if b < #s then
		table.insert(result, s:sub(b, -1))
	end
	return table.concat(result)
end

local escape_hypertext_replacements = {
	["\\"] = "\\\\\\\\",
	["<"] = "\\\\<",
	[">"] = "\\\\>",
	[";"] = "\\;",
	[","] = "\\,",
	["["] = "\\[",
	["]"] = "\\]",
}

local function escape_hypertext2(s)
	local result  = s:gsub("[][><\\,;]", escape_hypertext_replacements)
	return result
end

-- \\ => \\\\\\\\
-- < => \\\\<
-- ; => \\;
-- , => \\,
-- ] => \\]
-- [ => \\[

local function command(player_name, param)
	local formspec = {
		"formspec_version[5]",
		"size[13,15]",
		"padding[0,0]",
		"no_prepend[]",
		"bgcolor[#333333;both;#00000033]",
		"background[0,0;3,3;air]",
		"tabheader[0.5,3;12,0.75;theader;Caption 1,Caption 2,Caption 3 is very long;2;false;true]",
		"tooltip[password;Tooltip ",color,"text;#003300;#ffffff]",
		"scroll_container[0,5;12,5;scname;vertical]",
		"listcolors[#333333;#666666;#ff0000;#003300;#ffffff]",
		"list[current_player;main;0.5,0;8,4;0]",
		"image[0.5,5;1,1;air]",
		"item_image[2,5;1,1;air]",
		"pwdfield[0.5,6.5;4,0.5;password;He",color,"slo:]",
		"field[0.5,7.5;4,0.5;field;Fie",color,"ld:;...]",
		"field_close_on_enter[field;false]",
		"textarea[0.5,8.5;6,4;tarea;Text",color,"area:;Text v ",color,"textarea.]",
		"label[7,6;Jen ", color, "label..., ale může mít\ndruhý řádek.]",
		"hypertext[0.5,13;10,4;htext;A",color,"B"..escape_hypertext2("(!)(\")(#)($)(%)(&)(')(*)(+)(,)(-)(.)(/)(:)(;)(<)(=)(>)(?)(@)([)(\\)(])(^)(_)(`)({)(|)(})(~).").."]",
		"vertlabel[10,8.5;Vertical label...]",
		"button[0.5,15;3,3;buton;Clicka",color,"ble Button\ndalší?]",
		"image_button[5.5,15;1,1;air;ibutton;Imag",color,"e Button;Label;true;true]",
		"textlist[0.5,20;5,5;tlist;elem 1,elem 2,#3300FFelem 3, elem 4,elem 5,elem 6;2;true]",
		"textarea[0.5,26;6,4;;;Text v ",color,"textarea bez názvu.]",
		"scroll_container_end[]",
		"scrollbaroptions[max=1000;arrows=default]",
		"scrollbar[12,5;0.5,5;vertical;scname;0]",
	}
	formspec = table.concat(formspec)
	minetest.show_formspec(player_name, "ch_test:test", formspec)
end










def = {
	params = "[text]",
	description = "spustí právě testovanou akci pro účely vývoje serveru (jen pro Administraci)",
	privs = {server = true},
	func = command,
}
minetest.register_chatcommand("test", def)
