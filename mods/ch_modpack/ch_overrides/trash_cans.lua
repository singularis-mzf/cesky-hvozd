-- size = 6 or 18
local trash_cans = {
	["homedecor:trash_can"] = 6,
	["homedecor:trash_can_green_open"] = 6,
	["trash_can:dumpster"] = 18,
	["trash_can:trash_can_small"] = 6,
	["trash_can:trash_can_smallc"] = 6,
	["trash_can:trash_can_wooden"] = 6,
}

local F = minetest.formspec_escape
local ifthenelse = ch_core.ifthenelse

local function on_construct(pos)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local inv_size = trash_cans[node.name] or 6
	meta:set_string("infotext", ifthenelse(inv_size ~= 18, "odpadkový koš", "odpadkový kontejner"))
	inv:set_size("survival", inv_size)
	inv:set_size("creative", inv_size)
	inv:set_size("new", inv_size)
end

local function get_formspec(pos, role)
	if role ~= "survival" and role ~= "creative" and role ~= "admin" then
		minetest.log("warning", "Invalid role: "..(role or "nil").."!")
		return ""
	end
	local node = minetest.get_node(pos)
	local inv_size = minetest.get_meta(pos):get_inventory():get_size("survival")
	local context = "nodemeta:"..pos.x.."\\,"..pos.y.."\\,"..pos.z
	local formspec = {
		"formspec_version[5]",
		ifthenelse(role ~= "admin", "size[10.75,11]", "size[15.75,11]"),
		"item_image[0.375,0.375;1,1;", F(node.name), "]",
		"button[2,0.375;8,1;empty;vyprázdnit]",
	}
	local list_size = ifthenelse(inv_size == 18, "6,3", "2,3")
	if role == "admin" then
		-- two lists
		table.insert(formspec,
			"list["..context..";survival;0.375,1.75;"..list_size..";]"..
			"box[7.75,1.75;0.1,3.5;#000000]"..
			"list["..context..";creative;8,1.75;"..list_size..";]"..
			"list[current_player;main;2.9,5.75;8,4;]"..
			"listring["..context..";creative]"..
			"listring[current_player;main]"..
			"listring["..context..";survival]"..
			"listring[current_player;main]")
	else
		table.insert(formspec,
			"list["..context..";"..role..";"..ifthenelse(inv_size == 18, "1.75", "4.25")..",1.75;"..list_size..";]"..
			"list[current_player;main;0.5,5.75;8,4;]"..
			"listring[]")
	end
	return table.concat(formspec)
end

local function formspec_callback(custom_state, player, formname, fields)
	local player_name = player:get_player_name()
	local player_role = ch_core.get_player_role(player_name)
	if player_role == "new" and fields.quit then
		minetest.get_meta(custom_state.pos):get_inventory():set_list("new", {})
		return
	end
	if not fields.empty then
		return
	end
	if player_role ~= "new" and minetest.is_protected(custom_state.pos, player_name) then
		minetest.record_protection_violation(custom_state.pos, player_name)
		return
	end
	local inv = minetest.get_meta(custom_state.pos):get_inventory()
	if player_role == "admin" then
		if not inv:is_empty("survival") then
			ch_core.vyhodit_inventar(player_name, inv, "survival", "survival trash can "..minetest.get_node(custom_state.pos).name.." @ "..minetest.pos_to_string(custom_state.pos))
		end
		if not inv:is_empty("creative") then
			ch_core.vyhodit_inventar(player_name, inv, "creative", "creative trash can "..minetest.get_node(custom_state.pos).name.." @ "..minetest.pos_to_string(custom_state.pos))
		end
	else
		ch_core.vyhodit_inventar(player_name, inv, player_role, player_role.." trash can "..minetest.get_node(custom_state.pos).name.." @ "..minetest.pos_to_string(custom_state.pos))
	end
end

local function on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	local player_role = ch_core.get_player_role(clicker)
	if player_role == "survival" or player_role == "creative" or player_role == "admin" or player_role == "new" then
		ch_core.show_formspec(clicker, "ch_overrides:trash_can", get_formspec(pos, player_role), formspec_callback, {pos = pos}, {})
	end
end

local function can_dig(pos, player)
	local role = ch_core.get_player_role(player)
	local inv = minetest.get_meta(pos):get_inventory()
	if role == "admin" then
		return inv:is_empty("survival") and inv:is_empty("creative")
	elseif role == "survival" or role == "creative" then
		return inv:is_empty(role)
	else
		return false
	end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local player_role = ch_core.get_player_role(player)
	if player_role == "admin" or (from_list == to_list and from_list == player_role) then
		return count
	else
		return 0
	end
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	local player_role = ch_core.get_player_role(player)
	if player_role == "admin" or player_role == listname then
		return stack:get_count()
	else
		return 0
	end
end

local allow_metadata_inventory_take = allow_metadata_inventory_put

local function on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	minetest.log("action", player:get_player_name().." moves stuff in trash can("..from_list..":"..from_index.."/"..to_list..":"..to_index..") at "..minetest.pos_to_string(pos))
end
local function on_metadata_inventory_put(pos, listname, index, stack, player)
	minetest.log("action", player:get_player_name().." puts "..stack:get_name().." to trash can("..listname..") at "..minetest.pos_to_string(pos))
end
local function on_metadata_inventory_take(pos, listname, index, stack, player)
	minetest.log("action", player:get_player_name().." takes "..stack:get_name().."from trash can("..listname..") at "..minetest.pos_to_string(pos))
end
local function on_receive_fields(pos, formname, fields, sender)
	return
end

local override = {
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	can_dig = can_dig,
	on_construct = on_construct,
	on_metadata_inventory_move = on_metadata_inventory_move,
	on_metadata_inventory_put = on_metadata_inventory_put,
	on_metadata_inventory_take = on_metadata_inventory_take,
	on_rightclick = on_rightclick,
	on_receive_fields = on_receive_fields,
}

local trash_node_names = {}

for item_name, _inv_size in pairs(trash_cans) do
	if minetest.registered_nodes[item_name] then
		minetest.override_item(item_name, override)
		table.insert(trash_node_names, item_name)
	end
end

local function on_lbm(pos, node, dtime_s)
	-- local inv_size = trash_cans[node.name] or 6
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local context_description = "Trash can LBM @ "..minetest.pos_to_string(pos)

	if inv:get_size("survival") == 0 then
		meta:set_string("formspec", "")
		meta:set_string("infotext", "")
		inv:set_size("main", 0)
		inv:set_size("trashlist", 0)
		on_construct(pos)
		minetest.log("action", "Trash can "..node.name.." at "..minetest.pos_to_string(pos).." upgraded.")
	end
	ch_core.vyhodit_inventar(nil, inv, "survival", context_description)
	ch_core.vyhodit_inventar(nil, inv, "creative", context_description)
	ch_core.vyhodit_inventar(nil, inv, "new", context_description)
end

local lbm_def = {
	label = "Load trash cans",
	name = "ch_overrides:load_trash_can",
	nodenames = trash_node_names,
	run_at_every_load = true,
	action = on_lbm,
}

minetest.register_lbm(lbm_def)
