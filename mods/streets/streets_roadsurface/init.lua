--[[
	## StreetsMod 2.0 ##
	Submod: roadsurface
	Optional: true
	Category: Roads
]]

local S = minetest.get_translator("streets")

streets.register_road_surface({
	name = "asphalt_red",
	friendlyname = S("červený asfalt"),
	tiles = { "building_blocks_tar_bright.png^[multiply:#9C3336" },
	groups = { cracky = 3, asphalt = 1 },
	sounds = default.node_sound_stone_defaults(),
	register_stairs = true,
	craft = {
		output = "streets:asphalt_red",
		type = "shapeless",
		recipe = {"building_blocks:Tar", "dye:red"},
	},
})

streets.register_road_surface({
	name = "asphalt_blue",
	friendlyname = S("modrý asfalt"),
	tiles = { "building_blocks_tar_bright.png^[multiply:#1C44a6" },
	groups = { cracky = 3, asphalt = 1 },
	sounds = default.node_sound_stone_defaults(),
	register_stairs = true,
	craft = {
		output = "streets:asphalt_blue",
		type = "shapeless",
		recipe = {"building_blocks:Tar", "dye:blue"},
	},
})

streets.register_road_surface({
	name = "asphalt_yellow",
	friendlyname = S("žlutý asfalt"),
	tiles = { "building_blocks_tar_bright.png^[multiply:#bfbb20" },
	groups = { cracky = 3, asphalt = 1 },
	sounds = default.node_sound_stone_defaults(),
	register_stairs = false,
	craft = {
		output = "streets:asphalt_yellow",
		type = "shapeless",
		recipe = {"building_blocks:Tar", "dye:yellow"},
	},
})

-- minetest.register_alias("streets:asphalt", "building_blocks:Tar")
--[[
streets.register_road_surface({
	name = "asphalt",
	friendlyname = "Asphalt",
	tiles = { "streets_asphalt.png" },
	groups = { cracky = 3, asphalt = 1 },
	sounds = default.node_sound_stone_defaults(),
	register_stairs = true,
	craft = {
		output = "streets:asphalt 1",
		type = "cooking",
		recipe = "default:gravel",
		cooktime = 2
	}
}) -- ]]
--[[
streets.register_road_surface({
	name = "asphalt_red",
	friendlyname = "Red Asphalt",
	tiles = { "streets_asphalt_red.png" },
	groups = { cracky = 3, asphalt = 1 },
	sounds = default.node_sound_stone_defaults(),
	register_stairs = true,
	craft = {
		output = "streets:asphalt_red 1",
		type = "shapeless",
		recipe = { "streets:asphalt", "dye:red" }
	}
})
]]
--[[streets.register_road_surface({
	name = "asphalt_yellow",
	friendlyname = "Yellow Asphalt",
	tiles = {"streets_asphalt_yellow.png"},
	groups = {cracky = 3,asphalt = 1},
	sounds = default.node_sound_stone_defaults(),
	craft = {
		output = "streets:asphalt_yellow 1",
		type = "shapeless",
		recipe = {"streets:asphalt", "dye:yellow"}
	}
})
]]

--[[
minetest.register_node("streets:sidewalk", {
	description = "Sidewalk",
	tiles = { "streets_sidewalk.png" },
	groups = { cracky = 3, stone = 1 },
	sounds = default.node_sound_stone_defaults()
})
if minetest.get_modpath("moreblocks") or minetest.get_modpath("stairsplus") then
	stairsplus:register_all("streets", "sidewalk", "streets:sidewalk", {
		description = "Concrete",
		tiles = { "streets_sidewalk.png" },
		groups = { cracky = 3, asphalt = 1 },
		sounds = default.node_sound_stone_defaults()
	})
end

minetest.register_craft({
	output = "streets:sidewalk 1",
	type = "shapeless",
	recipe = { "streets:asphalt", "dye:white" }
})
-- ]]
