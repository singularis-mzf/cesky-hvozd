print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local S = minetest.get_translator("ch_npc")

local player_name_to_node_pos = {}

-- API OBJECT
ch_npc = {
	internal = {
		default_model = "npc.b3d",
		default_textures = "folks_default.png",
		show_formspec = function(node_pos, player_name, formname, formspec)
			player_name_to_node_pos[player_name] = node_pos
			return minetest.show_formspec(player_name, formname, formspec)
		end,
	},
}

local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath.."/privs.lua")
dofile(modpath.."/entities.lua")
dofile(modpath.."/formspecs.lua")
dofile(modpath.."/api.lua")
dofile(modpath.."/nodes.lua")

-- LBM (update entities when nodes are loaded)
minetest.register_lbm({
	label = "Update NPCs",
	name = "ch_npc:update_npcs",
	run_at_every_load = true,
	nodenames = {"ch_npc:npc"},
	action = function(pos, node)
		ch_npc.update_npc(pos, node, minetest.get_meta(pos))
	end,
})

-- on_player_receive_fields
local function on_player_receive_fields(player, formname, fields)
	local player_name = player:get_player_name()
	local pos = player_name_to_node_pos[player_name]
	if not pos or minetest.get_item_group(minetest.get_node(pos).name, "ch_npc_spawner") == 0
	then
		return false
	end

	if formname == "ch_npc:node_formspec" then
		return ch_npc.internal.on_player_receive_fields_node_formspec(pos, player, fields)
	elseif formname == "ch_npc:entity_formspec" then
		return ch_npc.internal.on_player_receive_fields_entity_formspec(pos, player, fields)
	end
	return false
end
minetest.register_on_player_receive_fields(on_player_receive_fields)

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

