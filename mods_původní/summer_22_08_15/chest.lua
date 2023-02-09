local chest_formspec =
	"size[16,9]" ..
	default.gui_bg ..
	default.gui_bg_img ..
	default.gui_slots ..
	"list[current_name;main;0,0.3;16,4;]" ..
	"list[current_player;main;0,4.95;8,1;]" ..
	"list[current_player;main;0,6.09;8,3;8]" ..
	"listring[current_name;main]" ..
	"listring[current_player;main]" ..
	default.get_hotbar_bg(0,4.95)

local function get_locked_chest_formspec(pos)
	local spos = pos.x .. "," .. pos.y .. "," .. pos.z
	local formspec =
		"size[16,9]" ..
		default.gui_bg ..
		default.gui_bg_img ..
		default.gui_slots ..
		"list[nodemeta:" .. spos .. ";main;0,0.3;16,4;]" ..
		"list[current_player;main;0,4.95;8,1;]" ..
		"list[current_player;main;0,6.09;8,3;8]" ..
		"listring[nodemeta:" .. spos .. ";main]" ..
		"listring[current_player;main]" ..
		default.get_hotbar_bg(0,4.95)
 return formspec
end

local function has_locked_chest_privilege(meta, player)
	local name = ""
	if player then
		if minetest.check_player_privs(player, "protection_bypass") then
			return true
		end
		name = player:get_player_name()
	end
	if name ~= meta:get_string("owner") then
		return false
	end
	return true
end
local chest_list = {
	{ "Red chest", "red"},
	{ "Orange chest", "orange"},
    { "Black chest", "black"},
	{ "Yellow chest", "yellow"},
	{ "Green chest", "green"},
	{ "Blue chest", "blue"},
	{ "Violet chest", "violet"},
}

for i in ipairs(chest_list) do
	local chestdesc = chest_list[i][1]
	local colour = chest_list[i][2]
    
minetest.register_node("summer:chest"..colour.."", {
	description = chestdesc..colour.."",
	tiles = {"chest_top_"..colour..".png", "chest_top_"..colour..".png", "chest_side_"..colour..".png",
		"chest_side_"..colour..".png", "chest_side_"..colour..".png", "chest_front_"..colour..".png"},
--inventory_image = "chest_front_"..colour.."_inv.png",
	    
--wield_image  = {"chest_front_"..colour..".png",
	--    },
	paramtype2 = "facedir",
	groups = {choppy = 2, oddly_breakable_by_hand = 2,tubedevice = 1, tubedevice_receiver = 1},
	tube = {
		insert_object = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return inv:add_item("main", stack)
		end,
		can_insert = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return inv:room_for_item("main", stack)
		end,
		input_inventory = "main",
		connect_sides = {left = 1, right = 1, back = 1, front = 1, bottom = 1, top = 1}
},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", chest_formspec)
		meta:set_string("infotext", "Chest")
		local inv = meta:get_inventory()
		inv:set_size("main", 16*4)
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index,
			to_list, to_index, count, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff in chest at " .. minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" moves " .. stack:get_name() ..
			" to chest at " .. minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" takes " .. stack:get_name() ..
			" from chest at " .. minetest.pos_to_string(pos))
	end,
	on_blast = function(pos)
		local drops = {}
		default.get_inventory_drops(pos, "main", drops)
		drops[#drops+1] = "summer:chest"..colour..""
		minetest.remove_node(pos)
		return drops
	end,
})
local lockchest_list = {
	{ "Red lockchest", "red"},
	{ "Orange lockchest", "orange"},
    { "Black lockchest", "black"},
	{ "Yellow lockchest", "yellow"},
	{ "Green lockchest", "green"},
	{ "Blue lockchest", "blue"},
	{ "Violet lockchest", "violet"},
}

for i in ipairs(lockchest_list) do
	local lockchestdesc = lockchest_list[i][1]
	local colour = lockchest_list[i][2]

    minetest.register_node("summer:chest_lock"..colour.."", {
	description = lockchestdesc.."",
	tiles = {"chest_top_"..colour..".png", "chest_top_"..colour..".png", "chest_side_"..colour..".png",
		"chest_side_"..colour..".png", "chest_side_"..colour..".png", "chest_lock_"..colour..".png"},
--inventory_image = "chest_lock_"..colour.."_inv.png",
	    
--wield_image  = {"chest_lock_"..colour.."_inv.png",
	--    },
	paramtype2 = "facedir",
	groups = {choppy = 2, oddly_breakable_by_hand = 2,tubedevice = 1, tubedevice_receiver = 1},
	tube = {
		insert_object = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return inv:add_item("main", stack)
		end,
		can_insert = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return inv:room_for_item("main", stack)
		end,
		input_inventory = "main",
		connect_sides = {left = 1, right = 1, back = 1, front = 1, bottom = 1, top = 1}
},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),

	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", placer:get_player_name() or "")
		meta:set_string("infotext", "Locked Chest (owned by " ..
				meta:get_string("owner") .. ")")
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Locked Chest")
		meta:set_string("owner", "")
		local inv = meta:get_inventory()
		inv:set_size("main", 16 * 4)
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main") and has_locked_chest_privilege(meta, player)
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index,
			to_list, to_index, count, player)
		local meta = minetest.get_meta(pos)
		if not has_locked_chest_privilege(meta, player) then
			return 0
		end
		return count
	end,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		if not has_locked_chest_privilege(meta, player) then
			return 0
		end
		return stack:get_count()
	end,
    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		if not has_locked_chest_privilege(meta, player) then
			return 0
		end
		return stack:get_count()
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" moves " .. stack:get_name() ..
			" to locked chest at " .. minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" takes " .. stack:get_name()  ..
			" from locked chest at " .. minetest.pos_to_string(pos))
	end,
	on_rightclick = function(pos, node, clicker)
		local meta = minetest.get_meta(pos)
		if has_locked_chest_privilege(meta, clicker) then
			minetest.show_formspec(
				clicker:get_player_name(),
				"summer:chest_lock"..colour.."",
				get_locked_chest_formspec(pos)
			)
		end
	end,
	on_blast = function() end,
})
end
end
