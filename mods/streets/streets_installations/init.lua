--[[
	## StreetsMod 2.0 ##
	Submod: installations
	Optional: true
]]

local S = minetest.get_translator("streets")
local surfaces = table.copy(streets.surfaces.surfacetypes)

local materials = {
	"artdeco:1a",
"artdeco:1b",
"artdeco:1c",
"artdeco:1d",
"artdeco:1e",
"artdeco:1f",
"artdeco:1g",
"artdeco:1h",
"artdeco:1i",
"artdeco:1j",
"artdeco:1k",
"artdeco:1l",
"artdeco:2a",
"artdeco:2b",
"artdeco:2c",
"artdeco:2d",
"artdeco:tile1",
"artdeco:tile2",
"artdeco:tile3",
"artdeco:tile4",
"artdeco:tile5",
"artdeco:brownwalltile",
"artdeco:greenwalltile",
"artdeco:ceilingtile",
"artdeco:decoblock1",
"artdeco:decoblock2",
"artdeco:decoblock3",
"artdeco:decoblock4",
"artdeco:decoblock5",
"artdeco:decoblock6",
"artdeco:stonewall",
"bakedclay:black",
"bakedclay:blue",
"bakedclay:brown",
"bakedclay:cyan",
"bakedclay:dark_green",
"bakedclay:dark_grey",
"bakedclay:green",
"bakedclay:grey",
"bakedclay:magenta",
"bakedclay:natural",
"bakedclay:orange",
"bakedclay:pink",
"bakedclay:red",
"bakedclay:violet",
"bakedclay:white",
"bakedclay:yellow",
"basic_materials:brass_block",
"basic_materials:cement_block",
"basic_materials:concrete_block",
"bridger:block_green",
"bridger:block_red",
"bridger:block_steel",
"bridger:block_white",
"bridger:block_yellow",
"building_blocks:Adobe",
"building_blocks:Tar",
"building_blocks:fakegrass",
"building_blocks:grate",
"ch_extras:marble",
"ch_extras:particle_board_grey",
"ch_extras:scorched_tree",
"ch_extras:scorched_tree_noface",
"cottages:black",
"cottages:brown",
"cottages:red",
"cottages:reet",
"darkage:basalt",
"darkage:basalt_brick",
"darkage:basalt_cobble",
"darkage:chalk",
"darkage:glass",
"darkage:glow_glass",
"darkage:gneiss",
"darkage:gneiss_brick",
"darkage:gneiss_cobble",
"darkage:marble",
"darkage:marble_tile",
"darkage:ors",
"darkage:ors_brick",
"darkage:ors_cobble",
"darkage:schist",
"darkage:serpentine",
"darkage:slate",
"darkage:slate_brick",
"darkage:slate_cobble",
"darkage:slate_tile",
"darkage:stone_brick",
"default:acacia_wood",
"default:aspen_wood",
"default:brick",
"default:bronzeblock",
"default:cobble",
"default:copperblock",
"default:coral_skeleton",
"default:desert_cobble",
"default:desert_sandstone",
"default:desert_sandstone_block",
"default:desert_sandstone_brick",
"default:desert_stone",
"default:desert_stone_block",
"default:desert_stonebrick",
"default:dirt",
"default:goldblock",
"default:ice",
"default:junglewood",
"default:meselamp",
"default:obsidian",
"default:obsidian_block",
"default:obsidianbrick",
"default:pine_wood",
"default:silver_sandstone",
"default:silver_sandstone_block",
"default:silver_sandstone_brick",
"default:steelblock",
"default:stone",
"default:stone_block",
"default:stonebrick",
"default:wood",
"moreblocks:acacia_tree_noface",
"moreblocks:aspen_tree_noface",
"moreblocks:cactus_brick",
"moreblocks:cactus_checker",
"moreblocks:checker_stone_tile",
"moreblocks:circle_stone_bricks",
"moreblocks:coal_checker",
"moreblocks:coal_stone",
"moreblocks:coal_stone_bricks",
"moreblocks:cobble_compressed",
"moreblocks:copperpatina",
"moreblocks:desert_cobble_compressed",
"moreblocks:grey_bricks",
"moreblocks:iron_checker",
"moreblocks:iron_stone",
"moreblocks:iron_stone_bricks",
"moreblocks:jungletree_allfaces",
"moreblocks:jungletree_noface",
"moreblocks:pine_tree_noface",
"moreblocks:plankstone",
"moreblocks:stone_tile",
"moreblocks:tree_allfaces",
"moreblocks:tree_noface",
"moreblocks:wood_tile",
"moreblocks:wood_tile_center",
"moreblocks:wood_tile_full",
"moretrees:apple_tree_planks",
"moretrees:apple_tree_trunk_noface",
"moretrees:birch_planks",
"moretrees:birch_trunk_noface",
"moretrees:cedar_planks",
"moretrees:cedar_trunk_noface",
"moretrees:cherrytree_planks",
"moretrees:cherrytree_trunk_noface",
"moretrees:chestnut_tree_planks",
"moretrees:chestnut_tree_trunk_noface",
"moretrees:date_palm_planks",
"moretrees:date_palm_trunk_noface",
"moretrees:ebony_planks",
"moretrees:ebony_trunk_noface",
"moretrees:fir_planks",
"moretrees:fir_trunk_noface",
"moretrees:oak_planks",
"moretrees:oak_trunk_noface",
"moretrees:palm_trunk_noface",
"moretrees:plumtree_planks",
"moretrees:plumtree_trunk_noface",
"moretrees:poplar_planks",
"moretrees:poplar_trunk_noface",
"moretrees:rubber_tree_planks",
"moretrees:rubber_tree_trunk_noface",
"moretrees:sequoia_planks",
"moretrees:sequoia_trunk_noface",
"moretrees:spruce_planks",
"moretrees:spruce_trunk_noface",
"moretrees:willow_planks",
"moretrees:willow_trunk_noface",
"solidcolor:plaster_blue",
"solidcolor:plaster_cyan",
"solidcolor:plaster_dark_green",
"solidcolor:plaster_dark_grey",
"solidcolor:plaster_green",
"solidcolor:plaster_grey",
"solidcolor:plaster_medium_amber_s50",
"solidcolor:plaster_orange",
"solidcolor:plaster_pink",
"solidcolor:plaster_red",
"solidcolor:plaster_white",
"solidcolor:plaster_yellow",
"streets:asphalt_blue",
"streets:asphalt_red",
"summer:granite",
"summer:graniteA",
"summer:graniteB",
"summer:graniteBC",
"summer:graniteP",
"summer:graniteR",
"technic:blast_resistant_concrete",
"technic:carbon_steel_block",
"technic:cast_iron_block",
"technic:granite",
"technic:marble",
"technic:marble_bricks",
"technic:warning_block",
"technic:zinc_block",
"xdecor:wood_tile"
}

local function add_surface(node_name)
	local ndef = minetest.registered_nodes[node_name]
	local tiles = table.copy(ndef.tiles)
	local tiles_count = #tiles
	local counter = 0
	for i = 1, #tiles do
		if type(tiles[i]) == "table" then
			tiles[i] = tiles[i].name
			counter = counter + 1
		end
	end
	if counter > 0 then
		ndef = table.copy(ndef)
		ndef.tiles = tiles
	end
	surfaces[node_name] = ndef
end

--[[
add_surface("building_blocks:Tar")
add_surface("default:desert_sandstone")
add_surface("default:stone")
add_surface("default:stone_block")
]]
for _, name in ipairs(materials) do
	if minetest.registered_nodes[name] then
		add_surface(name)
	end
end

for surface_name, surface_data in pairs(surfaces) do
	local allow_manhole = ch_core.is_shape_allowed(surface_name, "streets", "manhole")
	local allow_stormdrain = ch_core.is_shape_allowed(surface_name, "streets", "stormdrain")

	if allow_manhole then
	minetest.register_node(":streets:" .. surface_name:sub(2, -1):split(":")[2] .. "_manhole", {
		description = S("průlez v: @1", surface_data.friendlyname or minetest.registered_nodes[surface_name].description),
		tiles = { surface_data["tiles"][1] .. "^streets_manhole.png", surface_data.tiles[1] },
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = { cracky = 3, streets_manhole = 1 },
		on_rightclick = function(pos, node, name)
			local player_name = name:get_player_name()
			if minetest.is_protected(pos, player_name) and not minetest.check_player_privs(player_name, { protection_bypass = true }) then
				minetest.record_protection_violation(pos, player_name)
				return
			end
			node.name = node.name .. "_open"
			minetest.set_node(pos, node)
		end,
		sunlight_propagates = true,
		node_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.5, 0.5, 0.5, -0.375 }, -- F
				{ -0.5, -0.5, 0.375, 0.5, 0.5, 0.5 }, -- B
				{ -0.5, -0.5, -0.4375, -0.375, 0.5, 0.4375 }, -- Lsurface_data.friendlyname or
				{ 0.375, -0.5, -0.4375, 0.5, 0.5, 0.4375 }, -- R
				{ -0.25, 0.4375, -0.25, 0.25, 0.5, 0.25 }, -- CenterPlate
				{ -0.5, 0.4375, -0.0625, 0.5, 0.5, 0.0625 }, -- CenterLR
				{ -0.0625, 0.4375, -0.5, 0.0625, 0.5, 0.5 }, -- CenterFR
			}
		},
	})

	minetest.register_node(":streets:" .. surface_name:sub(2, -1):split(":")[2] .. "_manhole_open", {
		tiles = { surface_data["tiles"][1] .. "^streets_manhole.png", surface_data.tiles[1] },
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		climbable = true,
		drop = "streets:" .. surface_name:sub(2, -1):split(":")[2] .. "_manhole",
		groups = { cracky = 3, not_in_creative_inventory = 1, streets_manhole = 2 },
		on_rightclick = function(pos, node, name)
			local player_name = name:get_player_name()
			if minetest.is_protected(pos, player_name) and not minetest.check_player_privs(player_name, { protection_bypass = true }) then
				minetest.record_protection_violation(pos, player_name)
				return
			end
			node.name = string.sub(node.name, 1, -6)
			minetest.set_node(pos, node)
		end,
		sunlight_propagates = true,
		node_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.5, 0.5, 0.5, -0.375 }, -- F
				{ -0.5, -0.5, 0.375, 0.5, 0.5, 0.5 }, -- B
				{ -0.5, -0.5, -0.4375, -0.375, 0.5, 0.4375 }, -- L
				{ 0.375, -0.5, -0.4375, 0.5, 0.5, 0.4375 }, -- R
			}
		},
	})

	minetest.register_craft({
		output = "streets:" .. surface_name:sub(2, -1):split(":")[2] .. "_manhole 4",
		recipe = {
			{ surface_name, surface_name, surface_name },
			{ surface_name, "default:steel_ingot", surface_name },
			{ surface_name, surface_name, surface_name },
		}
	})
	end

	if allow_stormdrain then
	minetest.register_node(":streets:" .. surface_name:sub(2, -1):split(":")[2] .. "_stormdrain", {
		description = S("kanalizační vpusť v: @1", surface_data.friendlyname or minetest.registered_nodes[surface_name].description),
		tiles = { surface_data["tiles"][1] .. "^streets_stormdrain.png", surface_data.tiles[1] },
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = { cracky = 3, streets_stormdrain = 1 },
		sunlight_propagates = true,
		node_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.5, 0.5, 0.5, -0.4375 }, -- F
				{ -0.5, -0.5, 0.4375, 0.5, 0.5, 0.5 }, -- B
				{ -0.5, -0.5, -0.4375, -0.375, 0.5, 0.4375 }, -- L
				{ 0.375, -0.5, -0.4375, 0.5, 0.5, 0.4375 }, -- R
				{ -0.4375, 0.4375, 0, 0.4375, 0.5, 0.4375 }, -- T1
				{ -0.3125, 0.4375, -0.4375, -0.25, 0.5, 0 }, -- S1
				{ 0.25, 0.4375, -0.4375, 0.3125, 0.5, 0 }, -- S2
				{ -0.1875, 0.4375, -0.4375, -0.125, 0.5, 0 }, -- S3
				{ 0.125, 0.4375, -0.4375, 0.1875, 0.5, 0 }, -- S4
				{ -0.0625, 0.4375, -0.3125, 0.0625, 0.5, 0 }, -- S5
				{ -0.125, 0.4375, -0.375, 0.125, 0.5, -0.3125 }, -- S6
			}
		},
		selection_box = {
			type = "regular"
		}
	})

	minetest.register_craft({
		output = "streets:" .. surface_name:sub(2, -1):split(":")[2] .. "_stormdrain 3",
		recipe = {
			{ "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" },
			{ surface_name, surface_name, surface_name },
		}
	})
	end
end
