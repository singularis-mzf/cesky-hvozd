-- extra recipes
local def

minetest.register_craft{
	output = "default:permafrost",
	recipe = {
		{"default:ice", "", ""},
		{"default:dirt", "", ""},
		{"", "", ""},
}}

minetest.register_craft{
	output = "default:permafrost_with_moss",
	recipe = {
		{"default:mossycobble", "", ""},
		{"default:permafrost", "", ""},
		{"", "", ""},
}}

minetest.register_craft{
	output = "default:permafrost_with_stones",
	recipe = {
		{"default:cobble", "", ""},
		{"default:permafrost", "", ""},
		{"", "", ""},
}}

minetest.register_craft{
	output = "default:dirt_with_coniferous_litter",
	recipe = {
		{"default:pine_needles", "", ""},
		{"default:dirt", "", ""},
		{"", "", ""},
}}

minetest.register_craft{
	output = "default:dirt_with_dry_grass",
	recipe = {
		{"default:dry_grass_1", "", ""},
		{"default:dirt", "", ""},
		{"", "", ""},
}}

minetest.register_craft{
	output = "default:dirt_with_rainforest_litter",
	recipe = {
		{"default:jungleleaves", "", ""},
		{"default:dirt", "", ""},
		{"", "", ""},
}}

minetest.register_craft{
	output = "default:dirt_with_snow",
	recipe = {
		{"default:snow", "", ""},
		{"default:dirt", "", ""},
		{"", "", ""},
}}

minetest.register_craft{
	output = "default:dry_dirt",
	type = "cooking",
	recipe = "default:dirt",
}

minetest.register_craft{
	output = "default:dry_dirt_with_dry_grass",
	recipe = {
		{"default:dry_grass_1", "", ""},
		{"default:dry_dirt", "", ""},
		{"", "", ""},
}}

minetest.register_craft{
	output = "dye:yellow 16",
	recipe = {
		{"default:iron_lump", "bucket:bucket_water"},
		{"", ""},
	},
	replacements = {
		{"bucket:bucket_water", "bucket:bucket_empty"},
	},
}

minetest.register_craft{
	type = "cooking",
	output = "default:stone 27",
	recipe = "moreblocks:cobble_compressed",
	cooktime = 81,
}

minetest.register_craft{
	type = "cooking",
	output = "default:desert_stone 27",
	recipe = "moreblocks:desert_cobble_compressed",
	cooktime = 81,
}

if minetest.get_modpath("bucket_wooden") then
	minetest.register_craft{
		output = "dye:yellow 16",
		recipe = {
			{"default:iron_lump", "bucket_wooden:bucket_water"},
			{"", ""},
		},
		replacements = {
			{"bucket_wooden:bucket_water", "bucket_wooden:bucket_empty"},
		},
	}
end

if minetest.get_modpath("fireflies") and minetest.get_modpath("vessels") then
	minetest.register_craft{
		output = "fireflies:firefly",
		recipe = {
			{"fireflies:firefly_bottle"},
		},
		replacements = {{"fireflies:firefly_bottle", "vessels:glass_bottle"}},
	}
end

if minetest.get_modpath("jonez") and minetest.get_modpath("technic_worldgen") and minetest.get_modpath("darkage") then
	minetest.register_craft{
		output = "jonez:marble",
		type = "shapeless",
		recipe = {"darkage:marble", "technic:marble"},
		replacements = {{"darkage:marble", "technic:stone_dust"}},
	}
end

if minetest.get_modpath("cottages") then
	minetest.register_craft{
		output = "cottages:red 4",
		recipe = {
			{"", "homedecor:roof_tile_terracotta", ""},
			{"homedecor:roof_tile_terracotta", "default:pine_wood", "homedecor:roof_tile_terracotta"},
			{"", "", ""},
		},
	}

	minetest.register_craft{
		output = "cottages:brown 4",
		recipe = {
			{"", "homedecor:roof_tile_terracotta", ""},
			{"homedecor:roof_tile_terracotta", "default:junglewood", "homedecor:roof_tile_terracotta"},
			{"", "", ""},
		},
	}

	minetest.register_craft{
		output = "cottages:black 4",
		recipe = {
			{"", "building_blocks:Tar", ""},
			{"building_blocks:Tar", "", "building_blocks:Tar"},
			{"", "", ""},
		},
	}
end

if minetest.get_modpath("darkage") then
	minetest.register_craft{
		output = "dye:white 8",
		recipe = {{"darkage:chalk_powder"}},
	}
end

if minetest.get_modpath("pipeworks") then
	minetest.register_craft{
		output = "pipeworks:conductor_direct_tube_off_1",
		type = "shapeless",
		recipe = {"pipeworks:direct_tube", "mesecons:mesecon"},
	}
end

if minetest.get_modpath("technic") then
	minetest.register_craft{
		output = "technic:cast_iron_block",
		type = "cooking",
		cooktime = 10,
		recipe = "default:steelblock",
	}

	minetest.register_craft{
		output = "default:steelblock",
		type = "cooking",
		cooktime = 20,
		recipe = "technic:cast_iron_block",
	}

	technic.register_alloy_recipe({input = {"default:steelblock", "technic:coal_dust 5"}, output = "technic:carbon_steel_block", time = 50})
	technic.register_alloy_recipe({input = {"technic:carbon_steel_block", "technic:coal_dust 5"}, output = "technic:cast_iron_block", time = 50})
	technic.register_alloy_recipe({input = {"default:copperblock 7", "default:tinblock"}, output = "default:bronzeblock 8", time = 120})
	technic.register_alloy_recipe({input = {"technic:carbon_steel_block 4", "technic:chromium_block"}, output = "technic:stainless_steel_block 5", time = 75})
	technic.register_alloy_recipe({input = {"default:copperblock 2", "technic:zinc_block"}, output = "basic_materials:brass_block 3", time = 10})
end

def = {"technic:sawdust", "technic:sawdust", "technic:sawdust"}
minetest.register_craft{
	output = "default:paper 16",
	recipe = {
		def, {"", "mesecons_materials:glue", ""}, def
	},
}

if minetest.get_modpath("moretrees") and minetest.get_modpath("technic") then
	local trunks = {
		"default:jungletree",
		"default:aspen_tree",
		"moretrees:birch_trunk",
		"moretrees:beech_trunk",
		"moretrees:cedar_trunk",
		"moretrees:date_palm_trunk",
		"moretrees:fir_trunk",
		"moretrees:oak_trunk",
		"chestnuttree:trunk",
		"moretrees:rubber_tree_trunk",
		"moretrees:rubber_tree_trunk_empty",
		"moretrees:palm_trunk",
		"moretrees:apple_tree_trunk",
		"moretrees:sequoia_trunk",
		"moretrees:spruce_trunk",
		"moretrees:plumtree_trunk",
		"moretrees:ebony_trunk",
		"moretrees:poplar_trunk",
		"moretrees:cherrytree_trunk",
		"moretrees:willow_trunk",
	}
	local woods = {
		"default:junglewood",
		"default:aspen_wood",
		"moretrees:birch_planks",
		"moretrees:beech_planks",
		"moretrees:cedar_planks",
		"moretrees:date_palm_planks",
		"moretrees:fir_planks",
		"moretrees:oak_planks",
		"moretrees:chestnut_tree_planks",
		"moretrees:rubber_tree_planks",
		"moretrees:rubber_tree_planks_empty",
		"moretrees:palm_planks",
		"moretrees:apple_tree_planks",
		"moretrees:sequoia_planks",
		"moretrees:spruce_planks",
		"moretrees:plumtree_planks",
		"moretrees:ebony_planks",
		"moretrees:poplar_planks",
		"moretrees:cherrytree_planks",
		"moretrees:willow_planks",
	}
	local suffixes = {
		"", "_allfaces", "_noface"
	}
	for _, wood in ipairs(woods) do
		technic.register_grinder_recipe({input = {wood}, output = "technic:common_tree_grindings"})
	end
	for _, trunk in ipairs(trunks) do
		for _, suffix in ipairs(suffixes) do
			local n = trunk .. suffix
			if minetest.registered_items[n] then
				technic.register_grinder_recipe({input = {n}, output = "technic:common_tree_grindings 4"})
			end
		end
	end
end

if minetest.get_modpath("drinks") and minetest.get_modpath("farming") and minetest.get_modpath("mobs_animal") and minetest.get_modpath("wine") then
	local alcohol_items = {
		"wine:glass_brandy",
		"wine:glass_rum",
		"wine:glass_vodka",
	}
	for _, extra_item in ipairs({"", "farming:vanilla_extract"}) do
		for _, alcohol_item in ipairs(alcohol_items) do
			def = {
				output = "drinks:jcu_vajliker",
				recipe = {
					{"", extra_item, ""},
					{"farming:sugar", alcohol_item, "farming:sugar"},
					{"mobs:egg", "mobs:glass_milk", "mobs:egg"},
				},
			}
			minetest.register_craft(def)
		end
	end
end

if minetest.get_modpath("farming") and minetest.get_modpath("wine") then
	for _, extra_item in ipairs({"", "farming:vanilla_extract"}) do
		def = {
			output = "wine:glass_rum 4",
			recipe = {
				{"farming:glass_water", extra_item, "farming:glass_water"},
				{"farming:glass_water", "farming:bottle_ethanol", "farming:glass_water"},
				{"farming:caramel", "farming:caramel", "farming:caramel"},
			},
			replacements = {
				{"farming:bottle_ethanol", "vessels:glass_bottle"},
			},
		}
		minetest.register_craft(def)
	end
end
local plaster_colors = {
	"blue", "cyan", "dark_green", "dark_grey", "green", "grey", "medium_amber_s50", "orange", "pink", "red", "white", "yellow"
}
local source_items = {
	"darkage:ors_brick",
	"darkage:stone_brick",
	"default:desert_sandstone_brick",
	"default:desert_stonebrick",
	"default:sandstonebrick",
	"default:silver_sandstone_brick",
	"default:stonebrick",
	"moreblocks:cactus_brick",
	"moreblocks:coal_stone_bricks",
	"moreblocks:grey_bricks",
	"moreblocks:iron_stone_bricks"
}
local plaster_source_items = {
	"default:brick",
}
local brick_row = {"default:brick", "default:brick", "default:brick"}
local has_moreblocks = minetest.get_modpath("moreblocks")
for _, name in ipairs(source_items) do
	if minetest.registered_nodes[name] ~= nil then
		local def = {
			output = "default:brick",
			recipe = {{name}},
		}
		minetest.register_craft({
			output = "default:brick",
			recipe = {{name}},
		})
	end
end
if has_moreblocks then
	minetest.register_craft({
		output = "moreblocks:cactus_brick 8",
		recipe = {
			brick_row,
			{"default:brick", "dye:green", "default:brick"},
			brick_row,
		},
	})
	minetest.register_craft({
		output = "moreblocks:grey_bricks 8",
		recipe = {
			brick_row,
			{"default:brick", "dye:grey", "default:brick"},
			brick_row,
		},
	})
	table.insert(plaster_source_items, "moreblocks:cactus_brick")
	table.insert(plaster_source_items, "moreblocks:grey_bricks")
end
for _, name in ipairs(plaster_source_items) do
	brick_row = {name, name, name}
	for _, color in ipairs(plaster_colors) do
		minetest.register_craft({
			output = "ch_core:plaster_"..color.." 3",
			recipe = {
				{"", "dye:"..color, ""},
				brick_row,
				{"", "", ""},
			}
		})
	end
end
