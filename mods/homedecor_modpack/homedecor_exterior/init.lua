ch_base.open_mod(minetest.get_current_modname())
local S = minetest.get_translator("homedecor_exterior")
homedecor_exterior = {}


local bbq_cbox = {
	type = "fixed",
	fixed = { -0.5, -0.5, -0.3125, 0.5, 0.53125, 0.3125 }
}

homedecor.register("barbecue", {
	description = S("Barbecue"),
	mesh = "homedecor_barbecue.obj",
	tiles = {
		{ name = "homedecor_generic_metal.png" , color = homedecor.color_black },
		{ name = "homedecor_embers.png",
			animation={
				type="vertical_frames",
				aspect_w=16,
				aspect_h=16,
				length=2
			}
		},
		"homedecor_barbecue_meat.png",
	},
	groups = { snappy=3, dig_tree = 2 },
	light_source = 9,
	selection_box = bbq_cbox,
	collision_box = bbq_cbox,
	sounds = default.node_sound_stone_defaults(),
	-- no need for placeholder it appears
	expand = { top="air" },
	crafts = {
		{
			recipe = {
				{ "","homedecor:fence_chainlink","" },
				{ "steel_ingot","fake_fire:embers","steel_ingot" },
				{ "basic_materials:steel_bar","steel_ingot","basic_materials:steel_bar" }
			},
		}
	}
})

minetest.register_alias("homedecor:barbecue_meat", "air")

local wood_tex = homedecor.textures.default_wood

homedecor.register("doghouse", {
	mesh = "homedecor_doghouse.obj",
	tiles = {
		"homedecor_shingles_terracotta.png",
		wood_tex,
		"building_blocks_towel.png"
	},
	description = S("Doghouse"),
	inventory_image = "homedecor_doghouse_inv.png",
	selection_box = homedecor.nodebox.slab_y(1.5),
	collision_box = homedecor.nodebox.slab_y(1.5),
	groups = {snappy=3, dig_tree = 2},
	expand = { top="placeholder" },
	sounds = default.node_sound_wood_defaults(),
	on_rotate = minetest.get_modpath("screwdriver") and screwdriver.rotate_simple or nil,
	crafts = {
		{
			recipe = {
				{"homedecor:shingles_terracotta", "homedecor:shingles_terracotta", "homedecor:shingles_terracotta"},
				{"group:wood", "", "group:wood"},
				{"group:wood", "building_blocks:terrycloth_towel", "group:wood"}
			},
		}
	}
})

minetest.register_alias("homedecor:doghouse_roof", "air")
minetest.register_alias("homedecor:doghouse_base", "homedecor:doghouse")

homedecor.register("stonepath", {
	description = S("Garden stone path"),
	tiles = {
		minetest.registered_nodes["mapgen_stone"].tiles[1],
	},
	inventory_image = "homedecor_stonepath_inv.png",
	groups = { snappy=3, dig_stone = 2 },
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.5, 0.3125, -0.3125, -0.48, 0.4375}, -- NodeBox1
			{-0.25, -0.5, 0.125, 0, -0.48, 0.375}, -- NodeBox2
			{0.125, -0.5, 0.125, 0.4375, -0.48, 0.4375}, -- NodeBox3
			{-0.4375, -0.5, -0.125, -0.25, -0.48, 0.0625}, -- NodeBox4
			{-0.0625, -0.5, -0.25, 0.25, -0.48, 0.0625}, -- NodeBox5
			{0.3125, -0.5, -0.25, 0.4375, -0.48, -0.125}, -- NodeBox6
			{-0.3125, -0.5, -0.375, -0.125, -0.48, -0.1875}, -- NodeBox7
			{0.125, -0.5, -0.4375, 0.25, -0.48, -0.3125}, -- NodeBox8
		}
	},
	selection_box = {
		type = "fixed",
		fixed = { -0.4375, -0.5, -0.4375, 0.4375, -0.4, 0.4375 }
	},
	sounds = default.node_sound_stone_defaults(),
	crafts = {
		{
			output = "homedecor:stonepath 16",
			recipe = {
				{ "slab_stone","","slab_stone" },
				{ "","slab_stone","" },
				{ "slab_stone","","slab_stone" }
			},
		},
		{
			output = "homedecor:stonepath 16",
			recipe = {
				{ "moreblocks:slab_stone","","moreblocks:slab_stone" },
				{ "","moreblocks:slab_stone","" },
				{ "moreblocks:slab_stone","","moreblocks:slab_stone" }
			},
		},
		{
			output = "homedecor:stonepath 3",
			recipe = {
				{ "moreblocks:micro_stone_1","","moreblocks:micro_stone_1" },
				{ "","moreblocks:micro_stone_1","" },
				{ "moreblocks:micro_stone_1","","moreblocks:micro_stone_1" }
			},
		}
	}
})

local lattice_colors = {
	{ "wood", S("wood"), ".png^[colorize:#704214:180" },
	{ "white_wood", S("white wood"), ".png" },
	{ "wood_vegetal", S("wood, with vegetation"),
		".png^[colorize:#704214:180^homedecor_lattice_vegetal.png" },
	{ "white_wood_vegetal", S("white wood, with vegetation"),
		".png^homedecor_lattice_vegetal.png" },
}

for _, c in ipairs(lattice_colors) do
local name, desc, texture = unpack(c)
homedecor.register("lattice_"..name, {
	description = S("Garden Lattice (@1)", desc),
	tiles = {"homedecor_lattice"..texture},
	inventory_image = "homedecor_lattice"..texture,
	use_texture_alpha = "clip",
	groups = { snappy=3, dig_tree = 2 },
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.47, 0.5, 0.5, 0.47}, -- NodeBox1
			{-0.5, 0.421875, 0.44, 0.5, 0.5, 0.5}, -- NodeBox2
			{-0.5, -0.5, 0.44, 0.5, -0.421875, 0.5}, -- NodeBox3
			{0.421875, -0.5, 0.44, 0.5, 0.5, 0.5}, -- NodeBox4
			{-0.5, -0.5, 0.44, -0.421875, 0.5, 0.5} -- NodeBox5
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 0.44, 0.5, 0.5, 0.5}
	},
	sounds = default.node_sound_wood_defaults(),
})
end

homedecor.register("swing", {
	description = S("Tree's swing"),
	tiles = {
		"homedecor_swing_top.png",
		"homedecor_swing_top.png^[transformR180",
		"homedecor_swing_top.png"
	},
	inventory_image = "homedecor_swing_inv.png",
	use_texture_alpha = "clip",
	groups = { snappy=3, oddly_breakable_by_hand=3, dig_tree = 2 },
	sounds = default.node_sound_wood_defaults(),
	walkable = false,
	on_rotate = minetest.get_modpath("screwdriver") and screwdriver.disallow or nil,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, 0.33, -0.125,  0.3125, 0.376, 0.1875}, -- NodeBox1
			{-0.3125, 0.376, 0.025, -0.3,    0.5,   0.0375}, -- NodeBox2
			{ 0.3,    0.376, 0.025,  0.3125, 0.5,   0.0375}, -- NodeBox3
		}
	},
	selection_box = {
		type = "fixed",
		fixed = { -0.3125, 0.33, -0.125, 0.3125, 0.5, 0.1875 }
	},
	hint = {
		place_on = "bottom"
	},
	on_place = function(itemstack, placer, pointed_thing)
		local placer_name = placer:get_player_name() or ""
		local isceiling, pos = homedecor.find_ceiling(itemstack, placer, pointed_thing)
		if isceiling then
			local height = 0

			for i = 0, 4 do	-- search up to 5 spaces downward from the ceiling for the first non-buildable-to node...
				height = i
				local testpos = { x=pos.x, y=pos.y-i-1, z=pos.z }
				local testnode = minetest.get_node_or_nil(testpos)
				local testreg = testnode and core.registered_nodes[testnode.name]

				if not testreg or not testreg.buildable_to then
					if i < 1 then
						minetest.chat_send_player(placer_name, S("No room under there to hang a swing."))
						return itemstack
					else
						break
					end
				end
			end

			local fdir = minetest.dir_to_facedir(placer:get_look_dir())
			for j = 0, height do -- then fill that space with ropes...
				local testpos = { x=pos.x, y=pos.y-j, z=pos.z }
				minetest.set_node(testpos, { name = "homedecor:swing_rope", param2 = fdir })
			end

			minetest.set_node({ x=pos.x, y=pos.y-height, z=pos.z }, { name = "homedecor:swing", param2 = fdir })

			if not minetest.is_creative_enabled(placer_name) then
				itemstack:take_item()
			end
		else
			minetest.chat_send_player(placer_name,
				S("You have to point at the bottom side of an overhanging object to place a swing."))
		end
		return itemstack
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		for i = 0, 4 do
			local testpos = { x=pos.x, y=pos.y+i+1, z=pos.z }
			if minetest.get_node(testpos).name == "homedecor:swing_rope" then
				minetest.remove_node(testpos)
			else
				return
			end
		end
	end,
	crafts = {
		{
			recipe = {
				{ "string","","string" },
				{ "string","","string" },
				{ "string","slab_wood","string" }
			},
		},
		{
			recipe = {
				{ "string","","string" },
				{ "string","","string" },
				{ "string","moreblocks:slab_wood","string" }
			},
		},
		{
			recipe = {
				{ "string","","string" },
				{ "string","","string" },
				{ "string","moreblocks:panel_wood_1","string" }
			},
		}
	}
})

homedecor.register("swing_rope", {
	tiles = {
		"homedecor_swingrope_sides.png"
	},
	groups = { not_in_creative_inventory=1 },
	walkable = false,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.5, 0.025, -0.3, 0.5, 0.0375}, -- NodeBox1
			{0.3, -0.5, 0.025, 0.3125, 0.5, 0.0375}, -- NodeBox2
		}
	},
	selection_box = homedecor.nodebox.null
})

local water_tex = "default_water.png"
if not minetest.get_modpath("default") then water_tex = "[combine:16x16^[noalpha^[colorize:#00008b" end
local cobble_tex = minetest.registered_nodes["mapgen_stone"].tiles[1]
local stone_drop = minetest.registered_nodes["mapgen_stone"].drop
if stone_drop and type(stone_drop) == "string" then
	cobble_tex = minetest.registered_nodes[stone_drop].tiles[1]
elseif stone_drop and type(stone_drop) == "table" then
	cobble_tex = minetest.registered_nodes[stone_drop.items[1].items[1]].tiles[1]
end

homedecor.register("well", {
	mesh = "homedecor_well.obj",
	tiles = {
		"homedecor_rope_texture.png",
		{ name = "homedecor_generic_metal.png", color = homedecor.color_med_grey },
		water_tex,
		cobble_tex,
		wood_tex,
		"homedecor_shingles_wood.png"
	},
	inventory_image = "homedecor_well_inv.png",
	description = S("Water well"),
	use_texture_alpha = "clip",
	groups = { snappy = 3, dig_stone = 1 },
	selection_box = homedecor.nodebox.slab_y(2),
	collision_box = homedecor.nodebox.slab_y(2),
	expand = { top="placeholder" },
	sounds = default.node_sound_wood_defaults(),
	on_rotate = minetest.get_modpath("screwdriver") and screwdriver.rotate_simple or nil,
	crafts = {
		{
			recipe = {
				{ "homedecor:shingles_wood", "homedecor:shingles_wood", "homedecor:shingles_wood" },
				{ "group:wood", "group:stick", "group:wood" },
				{ "group:stone", "", "group:stone" }
			},
		}
	}
})

--because the engine of all people cant follow right to a name, need to verify bucket empty
if minetest.get_modpath("bucket") and minetest.registered_items["bucket:bucket_empty"] then
	local original_bucket_on_use = minetest.registered_items["bucket:bucket_empty"].on_use
	minetest.override_item("bucket:bucket_empty", {
		on_use = function(itemstack, user, pointed_thing)
			local inv = user:get_inventory()

			if pointed_thing.type == "node" and minetest.get_node(pointed_thing.under).name == "homedecor:well" then
				if inv:room_for_item("main", "bucket:bucket_water 1") then
					itemstack:take_item()
					inv:add_item("main", "bucket:bucket_water 1")
				else
					minetest.chat_send_player(user:get_player_name(), S("No room in your inventory to add a filled bucket!"))
				end
				return itemstack
			else if original_bucket_on_use then
				return original_bucket_on_use(itemstack, user, pointed_thing)
			else return end
		end
	end
	})
end

homedecor_exterior.shrub_colors = {
	["green"] = S("green"),
	["red"] = S("red"),
	["yellow"] = S("yellow"),
}

local shrub_cbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 }

for color, color_loc in pairs(homedecor_exterior.shrub_colors) do
	minetest.register_node(":homedecor:shrubbery_large_"..color, {
		description = S("Shrubbery (large, @1)", color_loc),
		drawtype = "mesh",
		mesh = "homedecor_cube.obj",
		tiles = {"homedecor_shrubbery_"..color..".png"},
		paramtype = "light",
		is_ground_content = false,
		use_texture_alpha = "clip",
		groups = {snappy=3, flammable=2, dig_tree = 3},
		sounds = default.node_sound_leaves_defaults(),
		crafts = {
			{
				type = "shapeless",
				recipe = {
					"homedecor:shrubbery_"..color
				}
			}
		}
	})

	minetest.register_node(":homedecor:shrubbery_"..color, {
		description = S("Shrubbery (@1)", color_loc),
		drawtype = "mesh",
		mesh = "homedecor_shrubbery.obj",
		tiles = {
			"homedecor_shrubbery_"..color..".png",
			"homedecor_shrubbery_"..color.."_bottom.png",
			"homedecor_shrubbery_roots.png"
		},
		paramtype = "light",
		is_ground_content = false,
		use_texture_alpha = "clip",
		groups = {snappy=3, flammable=2, dig_tree = 3},
		sounds = default.node_sound_leaves_defaults(),
		selection_box = shrub_cbox,
		collision_box = shrub_cbox,
		crafts = {
			{
				type = "shapeless",
				recipe = {
					"homedecor:shrubbery_large_"..color
				}
			}
		}
	})

	if color ~= "green" then
		minetest.register_craft({
			type = "shapeless",
			output = "homedecor:shrubbery_large_"..color,
			recipe = {
				"homedecor:shrubbery_large_green",
				homedecor.materials["dye_"..color]
			}
		})

		minetest.register_craft({
			type = "shapeless",
			output = "homedecor:shrubbery_"..color,
			recipe = {
				"homedecor:shrubbery_green",
				homedecor.materials["dye_"..color]
			}
		})

	end
end

-- crafting

minetest.register_craft({
	output = "homedecor:lattice_wood 8",
	recipe = {
		{"group:stick", "group:wood", "group:stick"},
		{"group:wood", "", "group:wood"},
		{"group:stick", "group:wood", "group:stick"},
	},
})

minetest.register_craft({
	output = "homedecor:lattice_white_wood 8",
	recipe = {
		{"group:stick", "group:wood", "group:stick"},
		{"group:wood", homedecor.materials["dye_white"], "group:wood"},
		{"group:stick", "group:wood", "group:stick"},
	},
})

minetest.register_craft({
	output = "homedecor:lattice_wood_vegetal 8",
	recipe = {
		{"group:stick", "group:wood", "group:stick"},
		{"group:wood", "group:leaves", "group:wood"},
		{"group:stick", "group:wood", "group:stick"},
	},
})

minetest.register_craft({
	output = "homedecor:lattice_white_wood_vegetal 8",
	recipe = {
		{"group:stick", "group:wood", "group:stick"},
		{"group:wood", "group:leaves", "group:wood"},
		{"group:stick", homedecor.materials["dye_white"], "group:stick"},
	},
})


minetest.register_craft({
	output = "homedecor:shrubbery_green 3",
	recipe = {
		{ "group:leaves", "group:leaves", "group:leaves" },
		{ "group:leaves", "group:leaves", "group:leaves" },
		{ "group:stick", "group:stick", "group:stick" }
	}
})

-- aliases

minetest.register_alias("homedecor:well_top", "air")
minetest.register_alias("homedecor:well_base", "homedecor:well")

minetest.register_alias("gloopblocks:shrubbery", "homedecor:shrubbery_green")
minetest.register_alias("gloopblocks:shrubbery_large", "homedecor:shrubbery_large_green")

ch_base.close_mod(minetest.get_current_modname())
