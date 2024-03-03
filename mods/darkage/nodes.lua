--
-- Naturally spawning blocks
--

local S = minetest.get_translator("darkage")

minetest.register_node("darkage:chalk", {
	description = S("Chalk"),
	tiles = {"darkage_chalk.png"},
	is_ground_content = true,
	drop = "darkage:chalk_powder 4",
	groups = {crumbly=2,cracky=2},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("darkage:marble", {
	description = S("Marble"),
	tiles = {"darkage_marble.png"},
	is_ground_content = true,
	groups = {cracky=3,marble=1},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("darkage:serpentine", {
	description = S("Serpentine"),
	tiles = {"darkage_serpentine.png"},
	is_ground_content = true,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("darkage:mud", {
	description = S("Mud"),
	tiles = {"darkage_mud_top.png", "darkage_mud.png"},
	is_ground_content = true,
	groups = {crumbly=3},
	drop = "darkage:mud_lump 4",
	sounds = default.node_sound_dirt_defaults({
		footstep = "",
	}),
})

minetest.register_node("darkage:schist", {
	description = S("Schist"),
	tiles = {"darkage_schist.png"},
	is_ground_content = true,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("darkage:shale", {
	description = S("Shale"),
	tiles = {"darkage_shale.png","darkage_shale.png","darkage_shale_side.png"},
	is_ground_content = true,
	groups = {crumbly=2,cracky=2},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("darkage:silt", {
	description = S("Silt"),
	tiles = {"darkage_silt.png"},
	is_ground_content = true,
	groups = {crumbly=3},
	drop = "darkage:silt_lump 4",
	sounds = default.node_sound_dirt_defaults({
		footstep = "",
	}),
})

minetest.register_node("darkage:slate", {
	description = S("Slate"),
	tiles = {"darkage_slate.png","darkage_slate.png","darkage_slate_side.png"},
	is_ground_content = true,
	drop = "darkage:slate_cobble",
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("darkage:ors", {
	description = S("Old Red Sandstone"),
	tiles = {"darkage_ors.png"},
	is_ground_content = true,
	drop = "darkage:ors_cobble",
	groups = {crumbly=2,cracky=2},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("darkage:gneiss", {
	description = S("Gneiss"),
	tiles = {"darkage_gneiss.png"},
	is_ground_content = true,
	groups = {cracky=3},
	drop = "darkage:gneiss_cobble",
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("darkage:basalt", {
	description = S("Basalt"),
	tiles = {"darkage_basalt.png"},
	is_ground_content = true,
	drop = "darkage:basalt_cobble",
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults()
})

--
-- Cobble
--

minetest.register_node("darkage:slate_cobble", {
	description = S("Slate Cobble"),
	tiles = {"darkage_slate_cobble.png"},
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("darkage:ors_cobble", {
	description = S("Old Red Sandstone Cobble"),
	tiles = {"darkage_ors_cobble.png"},
	groups = {crumbly=2,cracky=2},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("darkage:gneiss_cobble", {
	description = S("Gneiss Cobble"),
	tiles = {"darkage_gneiss_cobble.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("darkage:basalt_cobble", {
	description = S("Basalt Cobble"),
	tiles = {"darkage_basalt_cobble.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults()
})

--
-- Brick
--

minetest.register_node("darkage:slate_brick", {
	description = S("Slate Brick"),
	tiles = {"darkage_slate_brick.png"},
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("darkage:ors_brick", {
	description = S("Old Red Sandstone Brick"),
	tiles = {"darkage_ors_brick.png"},
	groups = {crumbly=2,cracky=2},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("darkage:gneiss_brick", {
	description = S("Gneiss Brick"),
	tiles = {"darkage_gneiss_brick.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("darkage:basalt_brick", {
	description = S("Basalt Brick"),
	tiles = {"darkage_basalt_brick.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("darkage:stone_brick", {
	description = S("Stone Brick"),
	tiles = {"darkage_stone_brick.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults()
})

--
-- Other Blocks
--
--[[
minetest.register_node("darkage:straw", {
	description = S("Straw"),
	tiles = {"darkage_straw.png"},
	groups = {snappy=3, flammable=2},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("darkage:straw_bale", {
	description = S("Straw Bale"),
	tiles = {"darkage_straw_bale.png"},
	drop = "darkage:straw 4",
	groups = {snappy=2, flammable=2},
	sounds = default.node_sound_leaves_defaults(),
})
]]

minetest.register_node("darkage:slate_tile", {
	description = S("Slate Tile"),
	tiles = {"darkage_slate_tile.png"},
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("darkage:marble_tile", {
	description = S("Marble Tile"),
	tiles = {"darkage_marble_tile.png"},
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("darkage:reinforced_chalk", {
	description = S("Reinforced Chalk"),
	tiles = {"darkage_chalk.png^darkage_reinforce.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults()
})

--[[
minetest.register_node("darkage:adobe", {
	description = S("Adobe"),
	tiles = {"darkage_adobe.png"},
	groups = {crumbly=3},
	sounds = default.node_sound_sand_defaults(),
})
]]

minetest.register_node("darkage:lamp", {
	description = S("Lamp"),
	tiles = {"darkage_lamp.png"},
	paramtype = "light",
	light_source = 14,
	groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3,flammable=1},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("darkage:cobble_with_plaster", {
	description = S("Cobblestone With Plaster"),
	tiles = {"darkage_cobble_with_plaster_D.png", "darkage_cobble_with_plaster_B.png", "darkage_cobble_with_plaster_C.png",
		"darkage_cobble_with_plaster_A.png", "default_cobble.png", "darkage_chalk.png"},
	paramtype2 = "facedir",
	drop = "default:cobble",
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("darkage:darkdirt", {
	description = S("Dark Dirt"),
	tiles = {"darkage_darkdirt.png"},
	groups = {crumbly=2},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("darkage:dry_leaves", {
	description = S("Dry Leaves"),
	tiles = {"darkage_dry_leaves.png"},
	paramtype = "light",
	groups = {snappy=3, flammable=2},
	sounds = default.node_sound_leaves_defaults()
})

--
-- Storage blocks (boxes, shelves, ect.)
--

minetest.register_node("darkage:box", {
	description = S("Box"),
	tiles = { "darkage_box_top.png","darkage_box_top.png","darkage_box.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = true,
	groups = { snappy = 3 },
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec",
				"size[8,8]"..
				"list[current_name;main;0,0;8,3;]"..
				"list[current_player;main;0,4;8,4;]")
		meta:set_string("infotext", S("Box"))
		local inv = meta:get_inventory()
		inv:set_size("main", 16)
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in box at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to box at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from box at "..minetest.pos_to_string(pos))
	end,
})

minetest.register_node("darkage:wood_shelves", {
	description = S("Wooden Shelves"),
	tiles = { "darkage_shelves.png","darkage_shelves.png","darkage_shelves.png",
			"darkage_shelves.png","darkage_shelves.png","darkage_shelves_front.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = true,
	groups = {snappy = 3},
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec",
				"size[8,10]"..
				"list[context;up;0,0;8,3;]"..
				"list[context;down;0,3;8,3;]"..
				"list[current_player;main;0,6;8,4;]")
		meta:set_string("infotext", "Wooden Shelves")
		local inv = meta:get_inventory()
		inv:set_size("up", 16)
		inv:set_size("down", 16)
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("shape") and inv:is_empty("out") and inv:is_empty("water")
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in shelves at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to shelves at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from shelves at "..minetest.pos_to_string(pos))
	end,
})

--
-- Glass / Glow Glass
--

minetest.register_node("darkage:glass", {
	description = S("Medieval Glass"),
	drawtype = "glasslike",
	tiles = {"darkage_glass.png"},
	paramtype = "light",
	sunlight_propagates = true,
	groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("darkage:glow_glass", {
	description = S("Medieval Glow Glass"),
	drawtype = "glasslike",
	tiles = {"darkage_glass.png"},
	paramtype = "light",
	light_source = 14,
	sunlight_propagates = true,
	groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
})

--
-- Reinforced Wood
--

minetest.register_node("darkage:reinforced_wood", {
	description = S("Reinforced Wood"),
	tiles = {"default_wood.png^darkage_reinforce.png"},
	groups = {snappy=2,choppy=3,oddly_breakable_by_hand=3,flammable=3},
	sounds = default.node_sound_wood_defaults()
})

minetest.register_node("darkage:reinforced_wood_left", {
	description = S("Reinforced Wood Left"),
	tiles = {"darkage_reinforced_wood_left.png"},
	groups = {snappy=2,choppy=3,oddly_breakable_by_hand=3,flammable=3},
	sounds = default.node_sound_wood_defaults()
})

minetest.register_node("darkage:reinforced_wood_right", {
	description = S("Reinforced Wood Right"),
	tiles = {"darkage_reinforced_wood_right.png"},
	groups = {snappy=2,choppy=3,oddly_breakable_by_hand=3,flammable=3},
	sounds = default.node_sound_wood_defaults()
})

--
-- Wood based decoration items
--

minetest.register_node("darkage:wood_bars", {
	description = S("Wooden Bars"),
	drawtype = "glasslike",
	tiles = {"darkage_wood_bars.png"},
	inventory_image = "darkage_wood_bars.png",
	wield_image = "darkage_wood_bars.png",
	paramtype = "light",
	sunlight_propagates = true,
	groups = {snappy=1,choppy=2},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("darkage:wood_grille", {
	description = S("Wooden Grille"),
	drawtype = "glasslike",
	tiles = {"darkage_wood_grille.png"},
	inventory_image = "darkage_wood_grille.png",
	wield_image = "darkage_wood_grille.png",
	paramtype = "light",
	sunlight_propagates = true,
	groups = {snappy=1,choppy=2},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("darkage:wood_frame", {
	description = S("Wooden Frame"),
	drawtype = "glasslike",
	tiles = {"darkage_wood_frame.png"},
	inventory_image = "darkage_wood_frame.png",
	wield_image = "darkage_wood_frame.png",
	paramtype = "light",
	sunlight_propagates = true,
	groups = {snappy=1,choppy=2},
	sounds = default.node_sound_stone_defaults()
})

--
-- Metal based decoration items
--

--[[
minetest.register_node("darkage:chain", {
	description = S("Chain"),
	drawtype = "signlike",
	tiles = {"darkage_chain.png"},
	inventory_image = "darkage_chain.png",
	wield_image = "darkage_chain.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	climbable = true,
	selection_box = {
		type = "wallmounted",
	},
	groups = {snappy=1,cracky=2,oddly_breakable_by_hand=2},
	legacy_wallmounted = true
})
]]

minetest.register_node("darkage:iron_bars", {
	description = S("Iron Bars"),
	drawtype = "glasslike",
	tiles = {"darkage_iron_bars.png"},
	inventory_image = "darkage_iron_bars.png",
	wield_image = "darkage_iron_bars.png",
	paramtype = "light",
	sunlight_propagates = true,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("darkage:iron_grille", {
	description = S("Iron Grille"),
	drawtype = "glasslike",
	tiles = {"darkage_iron_grille.png"},
	inventory_image = "darkage_iron_grille.png",
	wield_image = "darkage_iron_grille.png",
	paramtype = "light",
	sunlight_propagates = true,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults()
})
