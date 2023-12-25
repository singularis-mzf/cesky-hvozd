-- internationalization boilerplate
local S = minetest.get_translator(minetest.get_current_modname())

----Aluminum Basics

minetest.register_node("aloz:stone_with_bauxite", {
	description = S("Bauxite Ore"),
	tiles = {"default_stone.png^aloz_mineral_bauxite.png"},
	groups = {cracky = 2, aluminum = 1},
	drop = "aloz:bauxite_lump 10",
	sounds = default.node_sound_stone_defaults(),
})

function default.register_ores()
	minetest.register_ore({
		ore_type = "scatter",
		ore = "aloz:stone_with_bauxite",
		wherein = "default:stone",
		clust_scarcity = 25 * 25 * 25,
		clust_num_ores = 3,
		clust_size = 3,
		y_max = -48,
		y_min = -512,
	})
end

minetest.register_craftitem("aloz:bauxite_lump", {
	description = S("Bauxite Lump"),
	inventory_image = "aloz_bauxite_lump.png"
})

--Aluminum Ingot

minetest.register_craftitem("aloz:aluminum_ingot", {
	description = S("Aluminum Ingot"),
	inventory_image = "aloz_aluminum_ingot.png"
})

minetest.register_craft({
	type = "cooking",
	output = "aloz:aluminum_ingot",
	recipe = "aloz:bauxite_lump",
    cooktime = 10,
})

--Aluminum Block

minetest.register_node("aloz:aluminum_block", {
	description = S("Aluminum Block"),
	tiles = {"aloz_aluminum_block.png"},
	is_ground_content = false,
	groups = {cracky = 1, level = 2, aluminum = 1},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_craft({
	output = "default:aluminum_ingot 9",
	recipe = {
		{"aloz:aluminum_block"},
	}
})

--Beam
minetest.register_node("aloz:aluminum_beam", {
	description = S("Aluminum Beam"),
	tiles = {"aloz_beam_top.png", "aloz_beam_top.png", "aloz_beam_side.png"},
	groups = {cracky = 3, level= 3, aluminum = 1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	type= "shaped",
	output = "default:aluminum_beam",
	recipe = {
		{"", "aloz:aluminum_block", ""},
		{"", "aloz:aluminum_block", ""},
		{"", "aloz:aluminum_block", ""}
	}
})

--Doors

if minetest.get_modpath("doors") ~= nil then
	doors.register("door_aluminum", {
			tiles = {{ name = "aloz_door_aluminum.png", backface_culling = true }},
			description = S("Aluminum Door"),
			inventory_image = "aloz_door_aluminum_inv.png",
			groups = {node = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
			recipe = {
				{"aloz:aluminum_ingot", "xpanes:pane_flat"},
				{"aloz:aluminum_ingot", "aloz:aluminum_ingot"},
				{"aloz:aluminum_ingot", "aloz:trapdoor"},
			}
	})

	doors.register("door_green_aluminum", {
			tiles = {{ name = "aloz_door_green_aluminum.png", backface_culling = true }},
			description = S("Green Aluminum Door"),
			inventory_image = "aloz_door_green_aluminum_inv.png",
			groups = {node = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
			recipe = {
				{"aloz:door_aluminum", "dye:green"},
			}
	})

	doors.register("door_red_aluminum", {
			tiles = {{ name = "aloz_door_red_aluminum.png", backface_culling = true }},
			description = S("Red Aluminum Door"),
			inventory_image = "aloz_door_red_aluminum_inv.png",
			groups = {node = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
			recipe = {
				{"aloz:door_aluminum", "dye:red"},
			}
	})

	doors.register_trapdoor("aloz:trapdoor_aluminum", {
		description = S("Aluminum Trapdoor"),
		inventory_image = "aloz_trapdoor_aluminum.png",
		wield_image = "aloz_trapdoor_aluminum.png",
		tile_front = "aloz_trapdoor_aluminum.png",
		tile_side = "aloz_trapdoor_aluminum_side.png",
		protected = true,
		sounds = default.node_sound_metal_defaults(),
		sound_open = "doors_steel_door_open",
		sound_close = "doors_steel_door_close",
		gain_open = 0.2,
		gain_close = 0.2,
		groups = {cracky = 1, level = 2, door = 1},
	})

	minetest.register_craft({
		output = "aloz:trapdoor_aluminum 2",
		recipe = {
			{"default:aluminum_ingot", "default:aluminum_ingot", "default:aluminum_ingot"},
			{"default:aluminum_ingot", "default:aluminum_ingot", "default:aluminum_ingot"},
			{"", "", ""},
		}
	})
end

local function register_pane(name, def)
	for i = 1, 15 do
		minetest.register_alias("xpanes:" .. name .. "_" .. i, "xpanes:" .. name .. "_flat")
	end

	local flatgroups = table.copy(def.groups)
	flatgroups.pane = 1
	minetest.register_node(":xpanes:" .. name .. "_flat", {
		description = def.description,
		drawtype = "nodebox",
		paramtype = "light",
		is_ground_content = false,
		sunlight_propagates = true,
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		paramtype2 = "facedir",
		tiles = {
			def.textures[3],
			def.textures[3],
			def.textures[2],
			def.textures[2],
			def.textures[1],
			def.textures[1]
		},
		groups = flatgroups,
		drop = "xpanes:" .. name .. "_flat",
		sounds = def.sounds,
		use_texture_alpha = def.use_texture_alpha and "blend" or "clip",
		node_box = {
			type = "fixed",
			fixed = {{-1/2, -1/2, -1/32, 1/2, 1/2, 1/32}},
		},
		selection_box = {
			type = "fixed",
			fixed = {{-1/2, -1/2, -1/32, 1/2, 1/2, 1/32}},
		},
		connect_sides = { "left", "right" },
	})

	local groups = table.copy(def.groups)
	groups.pane = 1
	groups.not_in_creative_inventory = 1
	minetest.register_node(":xpanes:" .. name, {
		drawtype = "nodebox",
		paramtype = "light",
		is_ground_content = false,
		sunlight_propagates = true,
		description = def.description,
		tiles = {
			def.textures[3],
			def.textures[2],
			def.textures[1]
		},
		groups = groups,
		drop = "xpanes:" .. name .. "_flat",
		sounds = def.sounds,
		use_texture_alpha = def.use_texture_alpha and "blend" or "clip",
		node_box = {
			type = "connected",
			fixed = {{-1/32, -1/2, -1/32, 1/32, 1/2, 1/32}},
			connect_front = {{-1/32, -1/2, -1/2, 1/32, 1/2, -1/32}},
			connect_left = {{-1/2, -1/2, -1/32, -1/32, 1/2, 1/32}},
			connect_back = {{-1/32, -1/2, 1/32, 1/32, 1/2, 1/2}},
			connect_right = {{1/32, -1/2, -1/32, 1/2, 1/2, 1/32}},
		},
		connects_to = {"group:pane", "group:stone", "group:glass", "group:wood", "group:tree"},
	})

	minetest.register_craft({
		output = "xpanes:" .. name .. "_flat 16",
		recipe = def.recipe
	})
end


	register_pane("aluminum_railing", {
		description = S("Aluminum Railing"),
		textures = {"aloz_aluminum_railing.png", "aloz_aluminum_railing_rl.png", "aloz_aluminum_railing_tb.png"},
		inventory_image = "aloz_aluminum_railing.png",
		wield_image = "aloz_aluminum_railing.png",
		groups = {cracky=2},
		sounds = default.node_sound_metal_defaults(),
		recipe = {
			{"aloz:aluminum_ingot", "", "aloz:aluminum_ingot"},
			{"", "aloz:aluminum_ingot", ""},
			{"aloz:aluminum_ingot", "", "aloz:aluminum_ingot"}
		}
	})
	register_pane("aluminum_barbed_wire", {
		description = S("Aluminum Barbed Wire"),
		textures = {"aloz_barbed_wire.png", "aloz_barbed_wire_rl.png", "aloz_barbed_wire_tb.png"},
		inventory_image = "aloz_barbed_wire.png",
		wield_image = "aloz_barbed_wire.png",
		groups = {cracky=2},
		sounds = default.node_sound_metal_defaults(),
		recipe = {
			{"aloz:aluminum_ingot", "xpanes:aluminum_railing", ""}
		}
	})


