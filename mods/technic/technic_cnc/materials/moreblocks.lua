
local S = technic_cnc.getter

--[[
technic_cnc.register_all(
	"moreblocks:stone_tile",
	{stone = 1, cracky = 3, not_in_creative_inventory = 1},
	{"moreblocks_stone_tile.png"},
	S("Stone Tile"))

technic_cnc.register_all(
	"moreblocks:split_stone_tile",
	{stone = 1, cracky = 3, not_in_creative_inventory = 1},
	{"moreblocks_split_stone_tile.png"},
	S("Split Stone Tile")
)

technic_cnc.register_all(
	"moreblocks:checker_stone_tile",
	{stone = 1, cracky = 3, not_in_creative_inventory = 1},
	{"moreblocks_checker_stone_tile.png"},
	S("Checker Stone Tile")
)
]]

technic_cnc.register_all(
	"moreblocks:cactus_checker",
	{stone = 1, cracky = 3, not_in_creative_inventory = 1},
	{"default_stone.png^moreblocks_cactus_checker.png"},
	S("Cactus Checker")
)

technic_cnc.register_all(
	"moreblocks:cactus_brick",
	{cracky = 3, not_in_creative_inventory = 1},
	{"moreblocks_cactus_brick.png"},
	S("Cactus Brick")
)

technic_cnc.register_all(
	"moreblocks:grey_bricks",
	{cracky = 3, not_in_creative_inventory = 1},
	{"moreblocks_grey_bricks.png"},
	S("Grey Bricks")
)

technic_cnc.register_all(
	"moreblocks:copperpatina",
	{cracky = 1, level = 2, not_in_creative_inventory = 1},
	{"moreblocks_copperpatina.png"},
	S("Copper Patina")
)

technic_cnc.register_all(
	"moreblocks:glow_glass",
	{cracky = 1, level = 2, not_in_creative_inventory = 1},
	{"default_glass.png^[colorize:#E9CD61"},
	S("Glow Glass")
)

technic_cnc.register_all(
	"moreblocks:super_glow_glass",
	{cracky = 1, level = 2, not_in_creative_inventory = 1},
	{"default_glass.png^[colorize:#FFFF78"},
	S("Super Glow Glass")
)
