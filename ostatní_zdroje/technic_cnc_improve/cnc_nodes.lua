-- REGISTER MATERIALS AND PROPERTIES FOR NONCUBIC ELEMENTS:
-----------------------------------------------------------

local S=technic.getter
local ethereal = ethereal or {}

-- DIRT
-------
technic.cnc.register_all("default:dirt",
                {snappy=2,choppy=2,oddly_breakable_by_hand=3,not_in_creative_inventory=1},
                {"default_grass.png", "default_dirt.png", "default_grass.png"},
                S("Dirt"))

technic.cnc.register_all("default:glass",
                {snappy=2,choppy=2,oddly_breakable_by_hand=3,not_in_creative_inventory=1},
                {"default_glass.png"},
                S("Glass"))

technic.cnc.register_all("default:obsidian_glass",
                {snappy=2,choppy=2,oddly_breakable_by_hand=3,not_in_creative_inventory=1},
                {"default_obsidian_glass.png"},
                S("Obsidian Glass"))

-- WOOD
-------
technic.cnc.register_all("default:wood",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"default_wood.png"},
                S("Wooden"))

technic.cnc.register_all("default:junglewood",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"default_junglewood.png"},
                S("Junglewood"))

technic.cnc.register_all("default:pine_wood",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"default_pine_wood.png"},
                S("Pine"))

technic.cnc.register_all("default:acacia_wood",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"default_acacia_wood.png"},
                S("Acacia"))

technic.cnc.register_all("default:aspen_wood",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"default_aspen_wood.png"},
                S("Aspen"))

-- STONE
--------
technic.cnc.register_all("default:stone",
                {cracky=3, stone=1, not_in_creative_inventory=1},
                {"default_stone.png"},
                S("Stone"))

technic.cnc.register_all("default:stonebrick",
                {crumbly=2, cracky=3, stone=1, not_in_creative_inventory=1},
                {"default_stone_brick.png"},
                S("Stone Brick"))

technic.cnc.register_all("default:stone_block",
                {crumbly=2, cracky=3, stone=1, not_in_creative_inventory=1},
                {"default_stone_block.png"},
                S("Stone Block"))


technic.cnc.register_all("default:desert_stone",
                {cracky=3, stone=1, not_in_creative_inventory=1},
                {"default_desert_stone.png"},
                S("Desert Stone"))

technic.cnc.register_all("default:desert_stonebrick",
                {crumbly=2, cracky=3, stone=1, not_in_creative_inventory=1},
                {"default_desert_stone_brick.png"},
                S("Desert Stone Brick"))

technic.cnc.register_all("default:desert_stone_block",
                {crumbly=2, cracky=3, stone=1, not_in_creative_inventory=1},
                {"default_desert_stone_block.png"},
                S("Desert Stone Block"))

-- COBBLE
---------
technic.cnc.register_all("default:cobble",
                {cracky=3, stone=1, not_in_creative_inventory=1},
                {"default_cobble.png"},
                S("Cobble"))

technic.cnc.register_all("default:mossycobble",
                {cracky=3, stone=1, not_in_creative_inventory=1},
                {"default_mossycobble.png"},
                S("Mossy Cobblestone"))

technic.cnc.register_all("default:desert_cobble",
                {cracky=3, stone=1, not_in_creative_inventory=1},
                {"default_desert_cobble.png"},
                S("Desert Cobble"))

-- BRICK
--------
technic.cnc.register_all("default:brick",
                {cracky=3, not_in_creative_inventory=1},
                {"default_brick.png"},
                S("Brick"))


-- SANDSTONE
------------
technic.cnc.register_all("default:sandstone",
                {crumbly=2, cracky=3, not_in_creative_inventory=1},
                {"default_sandstone.png"},
                S("Sandstone"))

technic.cnc.register_all("default:sandstonebrick",
                {crumbly=2, cracky=3, not_in_creative_inventory=1},
                {"default_sandstone_brick.png"},
                S("Sandstone Brick"))

technic.cnc.register_all("default:sandstone_block",
                {crumbly=2, cracky=3, not_in_creative_inventory=1},
                {"default_sandstone_block.png"},
                S("Sandstone Block"))


technic.cnc.register_all("default:desert_sandstone",
                {crumbly=2, cracky=3, not_in_creative_inventory=1},
                {"default_desert_sandstone.png"},
                S("Desert Sandstone"))

technic.cnc.register_all("default:desert_sandstone_brick",
                {crumbly=2, cracky=3, not_in_creative_inventory=1},
                {"default_desert_sandstone_brick.png"},
                S("Desert Sandstone Brick"))

technic.cnc.register_all("default:desert_sandstone_block",
                {crumbly=2, cracky=3, not_in_creative_inventory=1},
                {"default_desert_sandstone_block.png"},
                S("Desert Sandstone Block"))


technic.cnc.register_all("default:silver_sandstone",
                {crumbly=2, cracky=3, not_in_creative_inventory=1},
                {"default_silver_sandstone.png"},
                S("Silver Sandstone"))

technic.cnc.register_all("default:silver_sandstone_brick",
                {crumbly=2, cracky=3, not_in_creative_inventory=1},
                {"default_silver_sandstone_brick.png"},
                S("Silver Sandstone Brick"))

technic.cnc.register_all("default:silver_sandstone_block",
                {crumbly=2, cracky=3, not_in_creative_inventory=1},
                {"default_silver_sandstone_block.png"},
                S("Silver Sandstone Block"))



-- TREES
--------
technic.cnc.register_all("default:tree",
                {snappy=1, choppy=2, oddly_breakable_by_hand=2, flammable=3, wood=1, not_in_creative_inventory=1},
                {"default_tree.png"},
                S("Tree"))
technic.cnc.register_all("default:acacia_tree",
                {snappy=1, choppy=2, oddly_breakable_by_hand=2, flammable=3, wood=1, not_in_creative_inventory=1},
                {"default_acacia_tree.png"},
                S("Acacia Tree"))
technic.cnc.register_all("default:aspen_tree",
                {snappy=1, choppy=2, oddly_breakable_by_hand=2, flammable=3, wood=1, not_in_creative_inventory=1},
                {"default_aspen_tree.png"},
                S("Aspen Tree"))
technic.cnc.register_all("default:jungletree",
                {snappy=1, choppy=2, oddly_breakable_by_hand=2, flammable=3, wood=1, not_in_creative_inventory=1},
                {"default_jungletree.png"},
                S("Jungle Tree"))
technic.cnc.register_all("default:pine_tree",
                {snappy=1, choppy=2, oddly_breakable_by_hand=2, flammable=3, wood=1, not_in_creative_inventory=1},
                {"default_pine_tree.png"},
                S("Pine Tree"))

-- ICE
-------
technic.cnc.register_all("default:ice",
                {cracky=3, puts_out_fire=1, cools_lava=1, not_in_creative_inventory=1},
                {"default_ice.png"},
                S("Ice"))


-- OBSIDIAN
-----------
technic.cnc.register_all("default:obsidian_block",
                {cracky=1, level=2, not_in_creative_inventory=1},
                {"default_obsidian_block.png"},
                S("Obsidian"))


-- WROUGHT IRON
---------------
technic.cnc.register_all("default:steelblock",
                {cracky=1, level=2, not_in_creative_inventory=1},
                {"technic_wrought_iron_block.png"},
                S("Wrought Iron"))

-- Bronze
--------
technic.cnc.register_all("default:bronzeblock",
                {cracky=1, level=2, not_in_creative_inventory=1},
                {"default_bronze_block.png"},
                S("Bronze"))

-- Zinc
--------
technic.cnc.register_all("technic:zinc_block",
                {cracky=1, level=2, not_in_creative_inventory=1},
                {"technic_zinc_block.png"},
                S("Zinc"))

-- Cast Iron
------------
technic.cnc.register_all("technic:cast_iron_block",
                {cracky=1, level=2, not_in_creative_inventory=1},
                {"technic_cast_iron_block.png"},
                S("Cast Iron"))

-- Stainless Steel
------------------
technic.cnc.register_all("technic:stainless_steel_block",
                {cracky=1, level=2, not_in_creative_inventory=1},
                {"technic_stainless_steel_block.png"},
                S("Stainless Steel"))

-- Carbon steel
---------------
technic.cnc.register_all("technic:carbon_steel_block",
                {cracky=1, level=2, not_in_creative_inventory=1},
                {"technic_carbon_steel_block.png"},
                S("Carbon Steel"))

-- Brass
--------
technic.cnc.register_all("technic:brass_block",
                {cracky=1, level=2, not_in_creative_inventory=1},
                {"technic_brass_block.png"},
                S("Brass"))

-- Copper
---------
technic.cnc.register_all("default:copperblock",
                {cracky=1, level=2, not_in_creative_inventory=1},
                {"default_copper_block.png"},
                S("Copper"))

-- Tin
------
technic.cnc.register_all("default:tinblock",
                {cracky=1, level=2, not_in_creative_inventory=1},
                {"default_tin_block.png"},
                S("Tin"))

-- Gold
-------
technic.cnc.register_all("default:goldblock",
                {cracky=1, level=2, not_in_creative_inventory=1},
                {"default_gold_block.png"},
                S("Gold"))


-- Marble
------------
technic.cnc.register_all("technic:marble",
                {cracky=3, not_in_creative_inventory=1},
                {"technic_marble.png"},
                S("Marble"))

-- Granite
------------
technic.cnc.register_all("technic:granite",
                {cracky=1, not_in_creative_inventory=1},
                {"technic_granite.png"},
                S("Granite"))


if minetest.get_modpath("ethereal") then
	-- Glostone
	------------
	technic.cnc.register_all("ethereal:glostone",
			{cracky=1, not_in_creative_inventory=1, light_source=13},
			{"glostone.png"},
			S("Glo Stone"))

	-- Crystal block
	----------------
	technic.cnc.register_all("ethereal:crystal_block",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"crystal_block.png"},
                S("Crystal"))
	
	-- Ethereal Wood types
	-------------------
	technic.cnc.register_all("ethereal:banana_wood",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"banana_wood.png"},
                S("Banana Wood"))
	technic.cnc.register_all("ethereal:banana_trunk",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"banana_trunk.png"},
                S("Banana Trunk"))
	
	technic.cnc.register_all("ethereal:birch_wood",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"moretrees_birch_wood.png"},
                S("Birch Wood"))
	technic.cnc.register_all("ethereal:birch_trunk",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"moretrees_birch_trunk.png"},
                S("Birch Trunk"))
	
	technic.cnc.register_all("ethereal:frost_wood",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"frost_wood.png"},
                S("Frost Wood"))
	technic.cnc.register_all("ethereal:frost_tree",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"ethereal_frost_tree.png"},
                S("Frost Tree"))
	
	technic.cnc.register_all("ethereal:palm_wood",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"moretrees_palm_wood.png"},
                S("Palm Wood"))
	technic.cnc.register_all("ethereal:palm_trunk",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"moretrees_palm_trunk.png"},
                S("Palm Trunk"))
	
	technic.cnc.register_all("ethereal:willow_wood",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"willow_wood.png"},
                S("Willow Wood"))
	technic.cnc.register_all("ethereal:willow_trunk",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"willow_trunk.png"},
                S("Willow Trunk"))
	
	technic.cnc.register_all("ethereal:yellow_wood",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"yellow_wood.png"},
                S("Healing Tree Wood"))
	technic.cnc.register_all("ethereal:yellow_trunk",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"yellow_tree.png"},
                S("Healing Tree Trunk"))
	
	technic.cnc.register_all("ethereal:redwood_wood",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"redwood_wood.png"},
                S("Redwood"))
	technic.cnc.register_all("ethereal:redwood_trunk",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"redwood_trunk.png"},
                S("Redwood Trunk"))

	technic.cnc.register_all("ethereal:sakura_wood",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"ethereal_sakura_wood.png"},
                S("Sakura"))
	technic.cnc.register_all("ethereal:sakura_trunk",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"ethereal_sakura_trunk.png"},
                S("Sakura Trunk"))

	
	-- Glorious bamboo
	-------------------
	technic.cnc.register_all("ethereal:bamboo_floor",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"bamboo_floor.png"},
                S("Bamboo"))
	
	-- Shaped hedge bush for gardens and parks
	-------------------------------------------
	
	technic.cnc.register_all("ethereal:bush",
		{snappy=3, flamable=2, not_in_creative_inventory=1},
		{"ethereal_bush.png"},
		S("Bush"))
	
	-- if baked clay isn't added and barebones ethereal is used
	
	if not minetest.get_modpath("bakedclay") then
		-- Clay
		------------
		technic.cnc.register_all("bakedclay:red",
				{cracky=3, not_in_creative_inventory=1},
				{"baked_clay_red.png"},
				S("Red Clay"))
		
		technic.cnc.register_all("bakedclay:orange",
				{cracky=3, not_in_creative_inventory=1},
				{"baked_clay_orange.png"},
				S("Orange Clay"))
		
		technic.cnc.register_all("bakedclay:grey",
				{cracky=3, not_in_creative_inventory=1},
				{"baked_clay_grey.png"},
				S("Grey Clay"))
	end
	
	-- undo-specific items
	if ethereal.mod and ethereal.mod == "undo" then
		technic.cnc.register_all("ethereal:olive_wood",
			{snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
			{"olive_wood.png"},
			S("Olive Wood"))
		technic.cnc.register_all("ethereal:olive_trunk",
			{snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
			{"olive_trunk.png"},
			S("Olive Trunk"))
		--lemon trees have default:wood trunks
	end
	
end


if minetest.get_modpath("moreblocks") then
	-- Tiles
	------------
	technic.cnc.register_all("moreblocks:stone_tile",
			{stone=1, cracky=3, not_in_creative_inventory=1},
			{"moreblocks_stone_tile.png"},
			S("Stone Tile"))
	
	technic.cnc.register_all("moreblocks:split_stone_tile",
			{stone=1, cracky=3, not_in_creative_inventory=1},
			{"moreblocks_split_stone_tile.png"},
			S("Split Stone Tile"))
	
	technic.cnc.register_all("moreblocks:checker_stone_tile",
			{stone=1, cracky=3, not_in_creative_inventory=1},
			{"moreblocks_checker_stone_tile.png"},
			S("Checker Stone Tile"))
	
	technic.cnc.register_all("moreblocks:cactus_checker",
			{stone=1, cracky=3, not_in_creative_inventory=1},
			{"moreblocks_cactus_checker.png"},
			S("Cactus Checker"))
	
	-- Bricks
	------------
	technic.cnc.register_all("moreblocks:cactus_brick",
			{cracky=3, not_in_creative_inventory=1},
			{"moreblocks_cactus_brick.png"},
			S("Cactus Brick"))
	
	technic.cnc.register_all("moreblocks:grey_bricks",
			{cracky=3, not_in_creative_inventory=1},
			{"moreblocks_grey_bricks.png"},
			S("Grey Bricks"))
	
	-- Metals
	------------
	technic.cnc.register_all("moreblocks:copperpatina",
			{cracky=1, level=2, not_in_creative_inventory=1},
			{"moreblocks_copperpatina.png"},
			S("Copper Patina"))
	
	-- Glass types
	------------
	
	technic.cnc.register_all("moreblocks:clean_glass",
                {snappy=2,choppy=2,oddly_breakable_by_hand=3,not_in_creative_inventory=1},
                {"moreblocks_clean_glass.png"},
                S("Clean Glass"))
	
	technic.cnc.register_all("moreblocks:coal_glass",
                {snappy=2,choppy=2,oddly_breakable_by_hand=3,not_in_creative_inventory=1},
                {"moreblocks_coal_glass.png"},
                S("Coal Glass"))
	
	technic.cnc.register_all("moreblocks:iron_glass",
                {snappy=2,choppy=2,oddly_breakable_by_hand=3,not_in_creative_inventory=1},
                {"moreblocks_iron_glass.png"},
                S("Iron Glass"))

end

if minetest.get_modpath("technic_worldgen") then
	technic.cnc.register_all("moretrees:rubber_tree_planks",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"technic_rubber_tree_wood.png"},
                S("Rubber Tree Planks"))
end

if minetest.get_modpath("pathv7") then
	-- jungle wood already exists (and hence the CNC'd parts would be identical)
	technic.cnc.register_all("pathv7:bridgewood",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"pathv7_bridgewood.png"},
                S("Bridge Wood"))
end

if minetest.get_modpath("maple") then
	technic.cnc.register_all("maple:maple_wood",
                {snappy=2, choppy=2, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
                {"maple_wood.png"},
                S("Maple"))
end

if minetest.get_modpath("extranodes") then
	technic.cnc.register_all("technic:plastic_clean",
                {dig_immediate = 2, not_in_creative_inventory=1},
                {"technic_plastic_clean.png"},
                S("Plastic Clean"))
end

if minetest.get_modpath("farming") and farming.mod and (farming.mod == "redo" or farming.mod == "undo") then
	technic.cnc.register_all("farming:hemp_block",
                {snappy = 1, oddly_breakable_by_hand = 1, flammable = 2, not_in_creative_inventory=1},
                {"farming_hemp_block.png"},
                S("Hemp Block"))
end

if minetest.get_modpath("bakedclay") then
	
	local clay = {
		{"white", "White"},
		{"grey", "Grey"},
		{"black", "Black"},
		{"red", "Red"},
		{"yellow", "Yellow"},
		{"green", "Green"},
		{"cyan", "Cyan"},
		{"blue", "Blue"},
		{"magenta", "Magenta"},
		{"orange", "Orange"},
		{"violet", "Violet"},
		{"brown", "Brown"},
		{"pink", "Pink"},
		{"dark_grey", "Dark Grey"},
		{"dark_green", "Dark Green"},
	}

	for _,c in ipairs(clay) do
		technic.cnc.register_all("bakedclay:" .. c[1],
				{cracky=3, not_in_creative_inventory=1},
				{"baked_clay_" .. c[1] .. ".png"},
				S(c[2] .. " Clay"))
	end
	
end
