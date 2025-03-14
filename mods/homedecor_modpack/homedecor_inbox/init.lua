ch_base.open_mod(minetest.get_current_modname())
local S = minetest.get_translator("inbox")


local inbox = {}

local mb_cbox = {
	type = "fixed",
	fixed = { -5/16, -8/16, -8/16, 5/16, 2/16, 8/16 }
}

homedecor.register("inbox", {
	paramtype = "light",
	drawtype = "mesh",
	mesh = "homedecor_inbox_mailbox.obj",
	description = S("Mailbox"),
	tiles = {
		"homedecor_inbox_red_metal.png",
		"homedecor_inbox_white_metal.png",
		"homedecor_inbox_grey_metal.png",
	},
	inventory_image = "homedecor_mailbox_inv.png",
	selection_box = mb_cbox,
	collision_box = mb_cbox,
	paramtype2 = "facedir",
	groups = {choppy=2,oddly_breakable_by_hand=2},
	sounds = default.node_sound_wood_defaults(),
	on_rotate = minetest.get_modpath("screwdriver") and screwdriver.rotate_simple or nil,
	after_place_node = function(pos, placer, itemstack)
		local meta = minetest.get_meta(pos)
		local owner = placer:get_player_name()
		meta:set_string("owner", owner)
		meta:set_string("infotext", S("@1's Mailbox", owner))
		local inv = meta:get_inventory()
		inv:set_size("main", 8*4)
		inv:set_size("drop", 1)
	end,
	on_rightclick = function(pos, node, clicker, itemstack)
		local meta = minetest.get_meta(pos)
		local player = clicker:get_player_name()
		local owner  = meta:get_string("owner")
		if owner == player or
				minetest.check_player_privs(player, "protection_bypass") and
				clicker:get_player_control().aux1 then
			minetest.show_formspec(
				player,
				"inbox:mailbox",
				inbox.get_inbox_formspec(pos))
		else
			minetest.show_formspec(
				player,
				"inbox:mailbox",
				inbox.get_inbox_insert_formspec(pos))
		end
		return itemstack
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local name = player and player:get_player_name()
		local owner = meta:get_string("owner")
		local inv = meta:get_inventory()
		return name == owner and inv:is_empty("main")
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if listname == "drop" and inv:room_for_item("main", stack) then
			inv:remove_item("drop", stack)
			inv:add_item("main", stack)
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "main" then
			return 0
		end
		if listname == "drop" then
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			if inv:room_for_item("main", stack) then
				return -1
			else
				return 0
			end
		end
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		if player:get_player_name() == owner or
				minetest.check_player_privs(player, "protection_bypass") and
				player:get_player_control().aux1 then
			return stack:get_count()
		end
		return 0
	end,
	allow_metadata_inventory_move = function(pos)
		return 0
	end,
	crafts = {
		{
			recipe = {
				{"","steel_ingot",""},
				{"steel_ingot","","steel_ingot"},
				{"steel_ingot","steel_ingot","steel_ingot"}
			}
		}
	}
})

minetest.register_alias("inbox:empty", "homedecor:inbox")

function inbox.get_inbox_formspec(pos)
	local spos = pos.x .. "," .. pos.y .. "," ..pos.z
	local formspec =
		"size[8,9]"..
		"list[nodemeta:".. spos .. ";main;0,0;8,4;]"..
		"list[current_player;main;0,5;8,4;]" ..
		"listring[]"
	return formspec
end

function inbox.get_inbox_insert_formspec(pos)
	local spos = pos.x .. "," .. pos.y .. "," ..pos.z
	local formspec =
		"size[8,9]"..
		"list[nodemeta:".. spos .. ";drop;3.5,2;1,1;]"..
		"list[current_player;main;0,5;8,4;]"..
		"listring[]"
	return formspec
end

ch_base.close_mod(minetest.get_current_modname())
