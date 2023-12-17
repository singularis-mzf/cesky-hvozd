local F = minetest.formspec_escape
local S = minetest.get_translator("ch_npc")

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
function ch_npc.internal.get_node_formspec(meta)
	-- local enabled = meta:get_string("enabled")
	local npc_model = meta:get_string("npc_model")
	local npc_name = meta:get_string("npc_name")
	local npc_dialog = meta:get_string("npc_dialog")

	local parts = {
		"formspec_version[5]",
		"size[10,10]",
		"textlist[1,0.5;6,6;npc_model;", model_list, ";", model_to_i[npc_model] or "1", ";false]",
		"field[1,7;8,0.5;npc_name;Jméno postavy;", F(npc_name), "]",
		"field[1,8;8,0.5;npc_dialog;Dialog postavy;", F(npc_dialog), "]",
		"button_exit[1,9;2,0.5;zobrazit;Zobrazit postavu]",
		"button_exit[5,9;2,0.5;skryt;Skrýt postavu]",
	}
	return table.concat(parts)
end

function ch_npc.internal.on_player_receive_fields_node_formspec(pos, player, fields)
	local player_name = player:get_player_name()

	if not minetest.check_player_privs(player_name, "spawn_npc") then
		return false
	end

	--[[ if fields.zobrazit or fields.skryt then
		ch_npc.internal.show_formspec(pos, player_name, "ch_npc:node_formspec", "") -- close formspec
	end ]]
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)

	if fields.zobrazit then
		meta:set_string("enabled", "true")
	end
	if fields.skryt then
		meta:set_string("enabled", "false")
	end
	if fields.npc_model then
		local new_model = fields.npc_model:sub(5, -1)
		-- print("DEBUG: Will set npc_model to ("..new_model..") => ("..tonumber(new_model)..") => ("..(i_to_model[tonumber(new_model)] or "nil=default")..")")
		meta:set_string("npc_model", i_to_model[tonumber(new_model)] or "default")
	end
	if fields.npc_name then
		meta:set_string("npc_name", fields.npc_name)
	end
	if fields.npc_dialog then
		meta:set_string("npc_dialog", fields.npc_dialog)
	end

	ch_npc.update_npc(pos, node, meta)
	return true
end

--[[ ENTITY FORMSPEC
function ch_npc.internal.get_entity_formspec(meta)
	-- local enabled = meta:get_string("enabled")
	-- local model = meta:get_string("model")
	-- local texture = meta:get_string("texture")
	local npc_name = meta:get_string("npc_name")
	local npc_text = meta:get_string("npc_text")
	local npc_program = meta:get_string("npc_program")

	local parts = {
		"formspec_version[5]",
		"size[8,10]",
		"bgcolor[#00000000]",
		"background[0,0;8,10;signs_poster_formspec.png]",
		"style_type[textarea;textcolor=#111111]",
		"style_type[textarea;font=mono]",
		"textarea[0.3,0.5;7.5,0.5;;;", F(npc_name),"]",
		"style_type[textarea;font=normal]",
		"textarea[0.3,1.0;7.5,8;;;", F(npc_text),"]",
		"button_exit[3.5,9.25;2,0.5;exit;", S("Close"), "]",
	}
	return table.concat(parts)
end

function ch_npc.internal.on_player_receive_fields_entity_formspec(pos, player, fields)
	return true
end
]]
