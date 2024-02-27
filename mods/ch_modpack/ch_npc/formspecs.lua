local internal = ...
local internal = ...
local F = minetest.formspec_escape
local S = minetest.get_translator("ch_npc")
local has_clothing = minetest.get_modpath("clothing")
local ifthenelse = ch_core.ifthenelse

local i_to_model, model_to_i, model_list

minetest.register_on_mods_loaded(function()
	i_to_model = {""}
	for model, _ in pairs(ch_npc.registered_npcs) do
		if model ~= "default" then
			table.insert(i_to_model, model)
		end
	end
	table.sort(i_to_model)
	i_to_model[1] = "default"
	model_to_i = table.key_value_swap(i_to_model)
	model_list = table.concat(i_to_model, ",")
end)

-- NODE FORMSPEC (for admin)
function internal.get_node_formspec(custom_state)
	local pos = custom_state.pos
	local meta = minetest.get_meta(pos)
	-- local enabled = meta:get_string("enabled")
	local npc_model = meta:get_string("npc_model")
	local npc_name = meta:get_string("npc_name")
	local npc_dialog = meta:get_string("npc_dialog")
	local npc_infotext = meta:get_string("npc_infotext")

	local parts = {
		ch_core.formspec_header{
			formspec_version = 7,
			size = {16,12},
			position = {0,0},
			anchor = {0,0},
			bgcolor = {"#00000020", "false", ""},
			no_prepend = true,
		},
		ifthenelse(has_clothing, "list[nodemeta:"..pos.x.."\\,"..pos.y.."\\,"..pos.z..";clothes;0.25,0.25;12,1;]", ""),
		"list[current_player;main;6,1.75;8,4;]",
		"textlist[0.25,1.5;5.5,5;npc_model;", model_list, ";", model_to_i[npc_model] or "1", ";false]",
		"field[0.25,7.0;6,0.5;npc_name;Jméno postavy;", F(npc_name), "]"..
		"field[0.25,8;6,0.5;npc_dialog;Dialog postavy;", F(npc_dialog), "]"..
		"textarea[0.25,9;6,2;npc_infotext;Infotext postavy:;", F(npc_infotext), "]"..
		"button_exit[6.5,10.75;3,0.75;zobrazit;Zobrazit postavu]",
		"button_exit[9.5,10.75;3,0.75;skryt;Skrýt postavu]",
		"button_exit[12.5,10.75;3,0.75;odstranit;Odstranit]",
	}
	return table.concat(parts)
end

function internal.formspec_callback(custom_state, player, formname, fields)
	local pos = custom_state.pos
	local player_name = player:get_player_name()

	if not minetest.check_player_privs(player_name, "spawn_npc") then
		return false
	end

	--[[ if fields.zobrazit or fields.skryt then
		ch_npc.internal.show_formspec(pos, player_name, "ch_npc:node_formspec", "") -- close formspec
	end ]]
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)

	if fields.odstranit then
		meta:set_string("enabled", "false")
		ch_npc.update_npc(pos, node, meta)
		minetest.remove_node(pos)
		minetest.close_formspec(player_name, formname)
		return
	end
	if fields.zobrazit then
		meta:set_string("enabled", "true")
	end
	if fields.skryt then
		meta:set_string("enabled", "false")
	end
	if fields.npc_model then
		local event = minetest.explode_textlist_event(fields.npc_model)
		if event.type == "CHG" or event.type == "DCL" then
			local new_model = assert(tonumber(event.index))
			meta:set_string("npc_model", i_to_model[new_model] or "default")
		end
	end
	if fields.npc_name then
		meta:set_string("npc_name", fields.npc_name)
	end
	if fields.npc_dialog then
		meta:set_string("npc_dialog", fields.npc_dialog)
	end
	if fields.npc_infotext then
		meta:set_string("npc_infotext", fields.npc_infotext)
	end

	ch_npc.update_npc(pos, node, meta)
	return true
end
