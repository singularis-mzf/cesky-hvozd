local F = minetest.formspec_escape
local S = minetest.get_translator("ch_npc")

-- NODE FORMSPEC (for admin)
function ch_npc.internal.get_node_formspec(meta)
	-- local enabled = meta:get_string("enabled")
	local model = meta:get_string("model")
	local texture = meta:get_string("texture")
	local npc_name = meta:get_string("npc_name")
	local npc_text = meta:get_string("npc_text")
	local npc_program = meta:get_string("npc_program")

	local parts = {
		"formspec_version[5]",
		"size[10,10]",
		"field[1,1;8,0.5;model;", S("Model"), ";", F(model), "]",
		"field[1,2;8,0.5;texture;", S("Textures"), ";", F(texture), "]",
		"field[1,3;8,0.5;npc_name;", S("NPC name"), ";", F(npc_name), "]",
		"field[1,4;8,0.5;npc_program;", S("NPC program"), ";", F(npc_program), "]",
		"textarea[1,5;8,2;npc_text;", S("NPC text") .. ";", F(npc_text), "]",
		"button[1,7.5;2,0.5;zobrazit;", S("Show NPC"), "]",
		"button[5,7.5;2,0.5;skryt;", S("Hide NPC"), "]",
	}
	return table.concat(parts)
end

function ch_npc.internal.on_player_receive_fields_node_formspec(pos, player, fields)
	local player_name = player:get_player_name()

	if not minetest.check_player_privs(player_name, "spawn_npc") then
		return false
	end

	if not (fields.zobrazit or fields.skryt) then
		return true -- do not process, unless clicked the button
	end
	ch_npc.internal.show_formspec(pos, player_name, "ch_npc:node_formspec", "") -- close formspec
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)

	if fields.zobrazit then
		meta:set_string("enabled", "true")
	end
	if fields.skryt then
		meta:set_string("enabled", "false")
	end
	meta:set_string("model", fields.model)
	meta:set_string("texture", fields.texture)
	meta:set_string("npc_name", fields.npc_name)
	meta:set_string("npc_text", fields.npc_text)
	meta:set_string("npc_program", fields.npc_program)

	ch_npc.update_npc(pos, node, meta)
	return true
end

-- ENTITY FORMSPEC
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
