ch_core.open_submod("inv_inspector", {data = true, formspec = true, lib = true, chat = true})

local required_privs = {protection_bypass = true}

local admin_to_custom_state = {}

local detached_inventory_callbacks = {
	allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
		return 0
	end,
	allow_put = function(inv, listname, index, stack, player)
		return 0
--[[
		if ch_core.get_player_role(player) ~= "admin" then
			return 0
		end
		local admin_name = player:get_player_name()
		local custom_state = admin_to_custom_state[admin_name]
		if custom_state == nil then
			return 0
		end
		local tplayer = minetest.get_player_by_name(custom_state.tplayer_name)
		if tplayer == nil then
			return 0
		end
		local remains = tplayer:get_inventory():add_item(custom_state.open_listname, stack)
		ch_core.systemovy_kanal(player:get_player_name(), "Dávka úspěšně vložena do inventáře.")
		return -1
]]
	end,
	allow_take = function(inv, listname, index, stack, player)
		return 0
--[[
		if ch_core.get_player_role(player) ~= "admin" then
			return 0
		end
		local admin_name = player:get_player_name()
		local custom_state = admin_to_custom_state[admin_name]
		if custom_state == nil then
			return 0
		end
		local tplayer = minetest.get_player_by_name(custom_state.tplayer_name)
		if tplayer == nil then
			return 0
		end
		local remains = tplayer:get_inventory():add_item(custom_state.open_listname, stack)
		ch_core.systemovy_kanal(player:get_player_name(), "Dávka úspěšně vložena do inventáře.")
		return -1
]]
	end,
}

local inv = minetest.create_detached_inventory("ch_core_inv_manager", detached_inventory_callbacks)

local function get_formspec(custom_state)
	local formspec = {
		"formspec_version[4]",
		"size[20,16]",
		"label[0.3,0.65;Inventáře:]",
		"label[0.5,1.4;Postava:]",
		"dropdown[2.25,1;5,0.75;postavy;A,B,C;1;false]",
		"label[8,1.4;Inventář:]",
		"dropdown[9.75,1;5,0.75;inventare;A,B,C;1;false]",
		"button[15,0.75;4,1;nacist;načíst]",
		
		list[current_player;main;1,2.5;14,1;]
box[0.9,3.75;17.5,0.1;#000000]
list[current_player;main;1,4;1,9;]

		"list[current_player;main;1,2.5;14,4;]",
		-- list[current_player;main;1,2.5;1,10;]"
	}
	
	
	return table.concat(formspec)
end

local function formspec_callback(custom_state, player, formname, fields)
	if fields.postavy then
		local event = minetest.expode_dropdown_event(fields.postavy)
	end
	if not fields.nacist then
		return
	end
	
end

local function on_chat_command(admin_name, _)
	local custom_state = {
		admin_name = admin_name,
		-- [ ] TODO
	}
	admin_to_custom_state[admin_name] = custom_state
	ch_core.show_formspec(admin_name, "ch_core:inspekce_inv", get_formspec(custom_state), formspec_callback, custom_state, {})
end

minetest.register_chatcommand("inspekceinv", {
	params = "",
	description = "provede inspekci inventářů připojených klientů",
	privs = required_privs,
	func = on_chat_command,
})

ch_core.close_submod("inv_inspector")
