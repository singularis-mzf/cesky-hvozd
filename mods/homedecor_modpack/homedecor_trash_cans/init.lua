ch_base.open_mod(minetest.get_current_modname())
local S = minetest.get_translator("homedecor_trash_cans")


local tg_cbox = {
	type = "fixed",
	fixed = { -0.35, -0.5, -0.35, 0.35, 0.4, 0.35 }
}

local trashcan_green = 0x00006000

homedecor.register("trash_can_green", {
	drawtype = "mesh",
	mesh = "homedecor_trash_can_green.obj",
	tiles = { { name = "homedecor_generic_plastic.png", color = trashcan_green } },
	inventory_image = "homedecor_trash_can_green_inv.png",
	description = S("Green Trash Can"),
	groups = {snappy=3, dig_stone=3},
	selection_box = tg_cbox,
	collision_box = tg_cbox,
	on_punch = function(pos, node, puncher, pointed_thing)
		minetest.set_node(pos, {name = "homedecor:trash_can_green_open", param2 = node.param2})
	end,
	crafts = {
		{
			recipe = {
				{ "basic_materials:plastic_sheet", "", "basic_materials:plastic_sheet" },
				{ "basic_materials:plastic_sheet", "dye_green", "basic_materials:plastic_sheet" },
				{ "basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet" }
			},
		}
	}
})

homedecor.register("trash_can_green_open", {
	drawtype = "mesh",
	mesh = "homedecor_trash_can_green_open.obj",
	tiles = { { name = "homedecor_generic_plastic.png", color = trashcan_green } },
	groups = {snappy=3, not_in_creative_inventory=1, dig_stone=3},
	selection_box = tg_cbox,
	collision_box = tg_cbox,
	drop = "homedecor:trash_can_green",
	on_punch = function(pos, node, puncher, pointed_thing)
		minetest.set_node(pos, {name = "homedecor:trash_can_green", param2 = node.param2})
	end,
	infotext=S("Trash Can"),
	inventory= {
		size = 9,
		formspec = "size[8,9]"..
		"button[2.5,3.8;3,1;empty;" .. S("Empty Trash") .. "]"..
		"list[context;main;2.5,0.5;3,3;]"..
		"list[current_player;main;0,5;8,4;]" ..
		"listring[]",
	},
	on_receive_fields = function(pos, formname, fields, sender)
		if fields.empty then
			if ch_core.check_player_role(sender, {"survival", "admin"}) then
				ch_core.vyhodit_inventar(sender and sender:get_player_name(), minetest.get_meta(pos):get_inventory(), "main", "trash can @ "..minetest.pos_to_string(pos))
                                           --[[
			local meta = minetest.get_meta(pos)
			meta:get_inventory():set_list("main", {})
			minetest.sound_play("homedecor_trash_all", {to_player=sender:get_player_name(), gain = 1.0})
                                           ]]
			else
				ch_core.systemovy_kanal(sender:get_player_name(), "Jen dělnické postavy mohou využívat odpadkové koše!")
			end
		end
	end
})

local trash_cbox = {
	type = "fixed",
	fixed = { -0.25, -0.5, -0.25, 0.25, 0.125, 0.25 }
}

homedecor.register("trash_can", {
	drawtype = "mesh",
	mesh = "homedecor_trash_can.obj",
	tiles = { "homedecor_trash_can.png" },
	inventory_image = "homedecor_trash_can_inv.png",
	description = S("Small Trash Can"),
	use_texture_alpha = "clip",
	groups = {snappy=3, dig_stone=3},
	selection_box = trash_cbox,
	collision_box = trash_cbox,
	crafts = {
		{
			output = "homedecor:trash_can 3",
			recipe = {
				{ "basic_materials:steel_wire", "", "basic_materials:steel_wire" },
				{ "steel_ingot", "steel_ingot", "steel_ingot" }
			},
		},
	}
})

ch_base.close_mod(minetest.get_current_modname())
