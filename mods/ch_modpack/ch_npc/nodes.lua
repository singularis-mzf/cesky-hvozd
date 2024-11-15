local internal = ...

-- NODE DEFINITION

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	return count
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if player ~= nil and minetest.check_player_privs(player, "spawn_npc") then
		return stack:get_count()
	else
		return 0
	end
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if player ~= nil and minetest.check_player_privs(player, "spawn_npc") then
		return stack:get_count()
	else
		return 0
	end
end

local function on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	ch_npc.update_npc(pos, minetest.get_node(pos), minetest.get_meta(pos))
end

local function on_metadata_inventory_put(pos, listname, index, stack, player)
	ch_npc.update_npc(pos, minetest.get_node(pos), minetest.get_meta(pos))
end

local on_metadata_inventory_take = on_metadata_inventory_put

local function can_dig(pos, player)
	return minetest.is_player(player) and minetest.check_player_privs(player, "spawn_npc")
end

local function on_construct(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	meta:set_string("infotext", "pozice pro nehráčskou postavu")
	inv:set_size("clothes", internal.clothes_inv_size)
end

local function on_place(itemstack, placer, pointed_thing)
	if placer == nil then
		return
	end
	if minetest.check_player_privs(placer, "spawn_npc") then
		return minetest.item_place(itemstack, placer, pointed_thing)
	end
	if minetest.is_player(placer) then
		local player_name = placer:get_player_name()
		ch_core.systemovy_kanal(player_name, "Pozice pro nehráčské postavy mohou umísťovat pouze hráči/ky s právem spawn_npc.\n"..
			"Pro umístění nehráčské postavy se, prosím, domluv s Administrací.")
	end
end

local function on_punch(pos, node, clicker, itemstack)
	return ch_npc.update_npc(pos, node)
end

local function on_rightclick(pos, node, clicker, itemstack)
	if minetest.is_player(clicker) and minetest.check_player_privs(clicker, "spawn_npc") then
		local player_name = clicker:get_player_name()
		local custom_state = {
			pos = pos,
		}
		ch_core.show_formspec(clicker, "ch_npc:admin", assert(internal.get_node_formspec(custom_state)), assert(internal.formspec_callback), custom_state, {})
	end
end

local npc_node_box = {
	type = "fixed",
	fixed = {-0.01, -0.5, -0.01, 0.01, -0.49, 0.01}
}
local npc_selection_box = {
	type = "fixed",
	fixed = {-0.5, -0.5, -0.5, 0.5, 1/16 - 0.5, 0.5}
}

ch_core.register_nodes({
	drawtype = "nodebox",
	selection_box = npc_selection_box,
	inventory_image = "default_invisible_node_overlay.png",
	wield_image = "default_invisible_node_overlay.png",
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = false,
	pointable = true,
	can_dig = can_dig,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	on_construct = on_construct,
	on_place = on_place,
	on_punch = on_punch,
	on_metadata_inventory_move = on_metadata_inventory_move,
	on_metadata_inventory_put = on_metadata_inventory_put,
	on_metadata_inventory_take = on_metadata_inventory_take,
	on_rightclick = on_rightclick,
}, {
	["ch_npc:npc"] = {
		description = "nehráčská postava (zobrazená)",
		tiles = {"ch_core_white_pixel.png^[opacity:0"},
		use_texture_alpha = "clip",
		node_box = npc_node_box,
		light_source = 1,
		groups = {ch_npc_spawner = 1, not_in_creative_inventory = 1},
	},
	["ch_npc:npc_hidden"] = {
		description = "nehráčská postava",
		tiles = {"ch_core_white_pixel.png^[opacity:16"},
		use_texture_alpha = "blend",
		node_box = npc_selection_box,
		light_source = 5,
		groups = {ch_npc_spawner = 2},
	},
})

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
