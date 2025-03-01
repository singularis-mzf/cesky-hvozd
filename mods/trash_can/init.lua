ch_base.open_mod(minetest.get_current_modname())
-- standard compatibility switcher block.


local moditems = {}  -- switcher
moditems.iron_item = "default:steel_ingot" -- MTG iron ingot
moditems.coal_item = "default:coalblock"   -- MTG coal block
moditems.green_dye = "dye:dark_green"      -- MTG version of green dye
moditems.sounds = default.node_sound_defaults
moditems.trashcan_infotext = "odpadkový koš"
moditems.dumpster_infotext = "odpadkový kontejner"
moditems.boxart = ""
moditems.trashbin_groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=3}
moditems.dumpster_groups = {cracky=3,oddly_breakable_by_hand=1}

local has_homedecor = minetest.get_modpath("homedecor_trash_cans")

--
-- Functions
--

local fdir_to_front = {
	{x=0, z=1},
	{x=1, z=0},
	{x=0, z=-1},
	{x=-1, z=0}
}
local function checkwall(pos)
	local fdir = minetest.get_node(pos).param2
	local second_node_x = pos.x + fdir_to_front[fdir + 1].x
	local second_node_z = pos.z + fdir_to_front[fdir + 1].z
	local second_node_pos = {x=second_node_x, y=pos.y, z=second_node_z}
	local second_node = minetest.get_node(second_node_pos)
	if not second_node or not minetest.registered_nodes[second_node.name]
	  or not minetest.registered_nodes[second_node.name].buildable_to then
		return true
	end

	return false
end

--
-- Custom Sounds
--
local function get_dumpster_sound()
	local sndtab = {
		footstep = {name="default_hard_footstep", gain=0.4},
		dig = {name="metal_bang", gain=0.6},
		dug = {name="default_dug_node", gain=1.0}
	}
	moditems.sounds(sndtab)
	return sndtab
end
--
-- Nodeboxes
--

local trash_can_nodebox = {
	{-0.375, -0.5, 0.3125, 0.375, 0.5, 0.375},
	{0.3125, -0.5, -0.375, 0.375, 0.5, 0.375},
	{-0.375, -0.5, -0.375, 0.375, 0.5, -0.3125},
	{-0.375, -0.5, -0.375, -0.3125, 0.5, 0.375},
	{-0.3125, -0.5, -0.3125, 0.3125, -0.4375, 0.3125},
}

local dumpster_selectbox = {-0.5, -0.5625, -0.5, 0.5, 0.5, 1.5}

local dumpster_nodebox = {
	-- Main Body
	{-0.4375, -0.375, -0.4375, 0.4375, 0.5, 1.4375},
	-- Feet
	{-0.4375, -0.5, -0.4375, -0.25, -0.375, -0.25},
	{0.25, -0.5, -0.4375, 0.4375, -0.375, -0.25},
	{0.25, -0.5, 1.25, 0.4375, -0.375, 1.4375},
	{-0.4375, -0.5, 1.25, -0.25, -0.375, 1.4375},
	-- Border
	{-0.5, 0.25, -0.5, 0.5, 0.375, 1.5},
}

--
-- Node Registration
--

-- Normal Trash Can
local trash_can_def = {
	drawtype = "mesh",
	tiles = {
		"trash_can_wooden_top.png",
		"trash_can_wooden_top.png",
		"trash_can_wooden.png"
	},
	paramtype = "light",
	groups = moditems.trashbin_groups,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec",
			"size[8,9]" ..
			"button[0,0;2,1;empty;Vyprázdnit]" ..
			"list[context;trashlist;3,1;2,3;]" ..
			"list[current_player;main;0,5;8,4;]" ..
			"listring[]" ..
			moditems.boxart
		)
		meta:set_string("infotext", moditems.trashcan_infotext)
		local inv = meta:get_inventory()
		inv:set_size("main", 8*4)
		inv:set_size("trashlist", 2*3)
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff in trash can at " .. minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff to trash can at " .. minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" takes stuff from trash can at " .. minetest.pos_to_string(pos))
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		if fields.empty then
			if ch_core.check_player_role(sender, {"survival", "admin"}) then
				ch_core.vyhodit_inventar(sender and sender:get_player_name(), minetest.get_meta(pos):get_inventory(), "trashlist", "trash can @ "..minetest.pos_to_string(pos))
			--[[
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			inv:set_list("trashlist", {})
			minetest.sound_play("trash", {to_player=sender:get_player_name(), gain = 1.0})
			minetest.log("action", sender:get_player_name() ..
				" empties trash can at " .. minetest.pos_to_string(pos))
			]]
			else
				ch_core.systemovy_kanal(sender:get_player_name(), "Jen dělnické postavy mohou využívat odpadkové koše!")
			end
		end
	end,
}

local function scale(fixed, c)
	local result = {}
	for i, aabb in ipairs(assert(fixed)) do
		result[i] = {aabb[1] * c, aabb[2] * c, aabb[3] * c, aabb[4] * c, aabb[5] * c, aabb[6] * c}
	end
	return assert(result)
end

local function translate(fixed, x, y, z)
	local result = {}
	for i, aabb in ipairs(assert(fixed)) do
		result[i] = {aabb[1] + x, aabb[2] + y, aabb[3] + z, aabb[4] + x, aabb[5] + y, aabb[6] + z}
	end
	return assert(result)
end

local box_normal = {type = "fixed", fixed = trash_can_nodebox}
local box_smallc = {type = "fixed", fixed = translate(scale(trash_can_nodebox, 0.666666), 0, -0.166667, 0)}
local box_small  = {type = "fixed", fixed = translate(scale(trash_can_nodebox, 0.666666), 0, -0.166667, 0.2)}

ch_core.register_nodes(trash_can_def, {
	["trash_can:trash_can_wooden"] = {
		description = "odpadkový koš",
		mesh = "trash_can_normal.obj",
		selection_box = box_normal,
		collision_box = box_normal,
		paramtype2 = "degrotate",
	},
	["trash_can:trash_can_smallc"] = {
		mesh = "trash_can_small_center.obj",
		description = "odpadkový koš malý (vystředěný)",
		selection_box = box_smallc,
		collision_box = box_smallc,
		paramtype2 = "degrotate",
	},
	["trash_can:trash_can_small"] = {
		mesh = "trash_can_small.obj",
		description = "odpadkový koš malý",
		selection_box = box_small,
		collision_box = box_small,
		paramtype2 = "4dir",
	},
})

if has_homedecor then
	minetest.override_item("homedecor:trash_can", {
		groups = trash_can_def.groups,
		on_construct = trash_can_def.on_construct,
		can_dig = trash_can_def.can_dig,
		on_metadata_inventory_move = trash_can_def.on_metadata_inventory_move,
		on_metadata_inventory_put = trash_can_def.on_metadata_inventory_put,
		on_metadata_inventory_take = trash_can_def.on_metadata_inventory_take,
		on_receive_fields = trash_can_def.on_receive_fields,
	})
end

-- Dumpster
minetest.register_node("trash_can:dumpster", {
	description = "odpadkový kontejner",
	paramtype = "light",
	paramtype2 = "facedir",
	inventory_image = "dumpster_wield.png",
	tiles = {
		"dumpster_top.png",
		"dumpster_bottom.png",
		"dumpster_side.png",
		"dumpster_side.png",
		"dumpster_side.png",
		"dumpster_side.png"
	},
	drawtype = "nodebox",
	selection_box = {
		type = "fixed",
		fixed = dumpster_selectbox,
	},
	node_box = {
		type = "fixed",
		fixed = dumpster_nodebox,
	},
	groups = moditems.dumpster_groups,
	sounds = get_dumpster_sound(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec",
			"size[8,9]" ..
			"button[0,0;2,1;empty;Vyprázdnit]" ..
			"list[context;main;1,1;6,3;]" ..
			"list[current_player;main;0,5;8,4;]"..
			"listring[]" ..
			moditems.boxart
		)
		meta:set_string("infotext", moditems.dumpster_infotext)
		local inv = meta:get_inventory()
		inv:set_size("main", 8*4)
	end,
	after_place_node = function(pos, placer, itemstack)
		if checkwall(pos) then
			minetest.set_node(pos, {name = "air"})
			return true
		end
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff in dumpster at " .. minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff to dumpster at " .. minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" takes stuff from dumpster at " .. minetest.pos_to_string(pos))
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		if fields.empty then
			if ch_core.check_player_role(sender, {"survival", "admin"}) then
				ch_core.vyprazdnit_inventar(sender and sender:get_player_name(), minetest.get_meta(pos):get_inventory(), "main", "dumpster @ "..minetest.pos_to_string(pos))
			--[[
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			inv:set_list("main", {})
			minetest.sound_play("trash", {to_player=sender:get_player_name(), gain = 2.0})
			]]
			else
				ch_core.systemovy_kanal(sender:get_player_name(), "Jen dělnické postavy mohou využívat odpadkové koše!")
			end
		end
	end,
})

--
-- Crafting
--

-- Normal Trash Can
minetest.register_craft({
	output = 'trash_can:trash_can_wooden',
	recipe = {
		{'group:wood', '', 'group:wood'},
		{'group:wood', '', 'group:wood'},
		{'group:wood', 'group:wood', 'group:wood'},
	}
})

-- Dumpster
minetest.register_craft({
	output = 'trash_can:dumpster',
	recipe = {
		{moditems.coal_item,moditems.coal_item,moditems.coal_item},
		{moditems.iron_item,moditems.green_dye,moditems.iron_item},
		{moditems.iron_item,moditems.iron_item,moditems.iron_item},
	}
})

ch_core.register_shape_selector_group({
	nodes = {
		{name = "trash_can:trash_can_wooden", param2 = 0},
		{name = "trash_can:trash_can_small", param2 = 0},
		{name = "trash_can:trash_can_smallc", param2 = 0},
	}
})

ch_base.close_mod(minetest.get_current_modname())
