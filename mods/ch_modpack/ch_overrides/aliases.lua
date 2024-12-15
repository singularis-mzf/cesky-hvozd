-- ALIASES

-- Remove aloz
if not minetest.get_modpath("aloz") then
	minetest.register_alias("aloz:aluminum_ingot", "default:steel_ingot")
	minetest.register_alias("aloz:stone_with_bauxite", "default:stone_with_iron")
	minetest.register_alias("aloz:trapdoor_aluminum", "xpanes:trapdoor_steel_bar")
	minetest.register_alias("aloz:aluminum_block", "default:steelblock")
	minetest.register_alias("aloz:aluminum_beam", "default:steelblock")
	minetest.register_alias("aloz:bauxite_lump", "default:iron_lump")
	minetest.register_alias("xpanes:aluminum_railing", "streets:fence_chainlink")
	minetest.register_alias("xpanes:aluminum_railing_flat", "streets:fence_chainlink")
	minetest.register_alias("xpanes:aluminum_barbed_wire", "streets:fence_chainlink")
	minetest.register_alias("xpanes:aluminum_barbed_wire_flat", "streets:fence_chainlink")
end

-- Remove bamboo
minetest.register_lbm({
	label = "Remove legacy bamboo nodes",
	name = "ch_overrides:remove_bamboo_nodes",
	nodenames = {"bamboo:leaves", "bamboo:sprout", "bamboo:trunk"},
	run_at_every_load = true,
	action = function(pos, node, dtime_s)
		minetest.remove_node(pos)
	end,
})

if minetest.get_modpath("moretrees") then
	local name
	for category, alternates in pairs(stairsplus.defs) do
		for alternate, _ in pairs(alternates) do
			name = stairsplus:get_shape("default:wood", category, alternate)
			if name ~= nil then
				minetest.register_alias("moretrees:"..category.."_beech_planks"..alternate, name)
			end
			name = stairsplus:get_shape("moreblocks:tree_noface", category, alternate)
			if name ~= nil then
				minetest.register_alias("moretrees:"..category.."_beech_trunk_noface"..alternate, name)
			end
		end
	end
end

if minetest.get_modpath("moretrees") and not minetest.get_modpath("chestnuttree") then
	local list = {
		["chestnuttree:trunk"] = "moretrees:chestnut_tree_trunk",
		["chestnuttree:wood"] = "moretrees:chestnut_tree_planks",
		["chestnuttree:trunk_noface"] = "moretrees:chestnut_tree_trunk_noface",
		["chestnuttree:trunk_allfaces"] = "moretrees:chestnut_tree_trunk_allfaces",
		["chestnuttree:mese_post_light"] = "moretrees:chestnut_tree_mese_post_light",
		["chestnuttree:leaves"] = "moretrees:chestnut_tree_leaves",
		["chestnuttree:sapling"] = "moretrees:chestnut_tree_sapling",
		["chestnuttree:sapling_ongen"] = "moretrees:chestnut_tree_sapling_ongen",
		["chestnuttree:gate_open"] = "moretrees:chestnut_tree_gate_open",
		["chestnuttree:gate_closed"] = "moretrees:chestnut_tree_gate_closed",
		["chestnuttree:fence"] = "moretrees:chestnut_tree_fence",
		["chestnuttree:fence_rail"] = "moretrees:chestnut_tree_fence_rail",
		["chestnuttree:bur"] = "moretrees:bur",
		["chestnuttree:fruit"] = "moretrees:chestnut",
		["doors:door_chestnut_wood"] = "doors:door_luxury_wood",
		["doors:door_chestnut_wood_a"] = "doors:door_luxury_wood_a",
		["doors:door_chestnut_wood_b"] = "doors:door_luxury_wood_b",
		["doors:door_chestnut_wood_c"] = "doors:door_luxury_wood_c",
		["doors:door_chestnut_wood_cd"] = "doors:door_luxury_wood_cd",
		["doors:door_chestnut_wood_cd_a"] = "doors:door_luxury_wood_cd_a",
		["doors:door_chestnut_wood_cd_b"] = "doors:door_luxury_wood_cd_b",
		["doors:door_chestnut_wood_cd_c"] = "doors:door_luxury_wood_cd_c",
		["doors:door_chestnut_wood_cd_d"] = "doors:door_luxury_wood_cd_d",
		["doors:door_chestnut_wood_d"] = "doors:door_luxury_wood_d",
		["advtrains:platform_high_chestnuttree_wood"] = "advtrains:platform_high_chestnut_tree_planks",
		["advtrains:platform_low_chestnuttree_wood"] = "advtrains:platform_low_chestnut_tree_planks",
	}
	for alias, name in pairs(list) do
		if minetest.registered_items[name] ~= nil then
			minetest.register_alias(alias, name)
		end
	end

	-- stairsplus shapes
	local name
	for category, alternates in pairs(stairsplus.defs) do
		for alternate, _ in pairs(alternates) do
			name = stairsplus:get_shape("moretrees:chestnut_tree_planks", category, alternate)
			if name ~= nil then
				minetest.register_alias("chestnuttree:"..category.."_wood"..alternate, name)
			end
			name = stairsplus:get_shape("moretrees:chestnut_tree_trunk_noface", category, alternate)
			if name ~= nil then
				minetest.register_alias("chestnuttree:"..category.."_trunk_noface"..alternate, name)
			end
		end
	end
end

if minetest.get_modpath("moretrees") and not minetest.get_modpath("cherrytree") then
	local list = {
		["cherrytree:trunk"] = "moretrees:cherrytree_trunk",
		["cherrytree:wood"] = "moretrees:cherrytree_planks",
		["cherrytree:trunk_noface"] = "moretrees:cherrytree_trunk_noface",
		["cherrytree:trunk_allfaces"] = "moretrees:cherrytree_trunk_allfaces",
		["cherrytree:mese_post_light"] = "moretrees:cherrytree_mese_post_light",
		["cherrytree:blossom_leaves"] = "moretrees:cherrytree_leaves",
		["cherrytree:leaves"] = "moretrees:cherrytree_leaves",
		["cherrytree:sapling"] = "moretrees:cherrytree_sapling",
		["cherrytree:sapling_ongen"] = "moretrees:cherrytree_sapling_ongen",
		["cherrytree:gate_open"] = "moretrees:cherrytree_gate_open",
		["cherrytree:gate_closed"] = "moretrees:cherrytree_gate_closed",
		["cherrytree:fence"] = "moretrees:cherrytree_fence",
		["cherrytree:fence_rail"] = "moretrees:cherrytree_fence_rail",
		["cherrytree:cherries"] = "moretrees:cherry",
	}
	for alias, name in pairs(list) do
		if minetest.registered_items[name] ~= nil then
			minetest.register_alias(alias, name)
		end
	end

	-- stairsplus shapes
	local name
	for category, alternates in pairs(stairsplus.defs) do
		for alternate, _ in pairs(alternates) do
			name = stairsplus:get_shape("moretrees:cherrytree_planks", category, alternate)
			if name ~= nil then
				minetest.register_alias("cherrytree:"..category.."_wood"..alternate, name)
			end
			name = stairsplus:get_shape("moretrees:cherrytree_trunk_noface", category, alternate)
			if name ~= nil then
				minetest.register_alias("cherrytree:"..category.."_trunk_noface"..alternate, name)
			end
		end
	end
end

if minetest.get_modpath("moretrees") and not minetest.get_modpath("ebony") then
	local list = {
		["ebony:trunk"] = "moretrees:ebony_trunk",
		["ebony:wood"] = "moretrees:ebony_planks",
		["ebony:trunk_noface"] = "moretrees:ebony_trunk_noface",
		["ebony:trunk_allfaces"] = "moretrees:ebony_trunk_allfaces",
		["ebony:mese_post_light"] = "moretrees:ebony_mese_post_light",
		["ebony:leaves"] = "moretrees:ebony_leaves",
		["ebony:sapling"] = "moretrees:ebony_sapling",
		["ebony:sapling_ongen"] = "moretrees:ebony_sapling_ongen",
		["ebony:gate_open"] = "moretrees:ebony_gate_open",
		["ebony:gate_closed"] = "moretrees:ebony_gate_closed",
		["ebony:fence"] = "moretrees:ebony_fence",
		["ebony:fence_rail"] = "moretrees:ebony_fence_rail",
	}
	for alias, name in pairs(list) do
		if minetest.registered_items[name] ~= nil then
			minetest.register_alias(alias, name)
		end
	end

	-- stairsplus shapes
	local name
	for category, alternates in pairs(stairsplus.defs) do
		for alternate, _ in pairs(alternates) do
			name = stairsplus:get_shape("moretrees:ebony_planks", category, alternate)
			if name ~= nil then
				minetest.register_alias("ebony:"..category.."_wood"..alternate, name)
			end
			name = stairsplus:get_shape("moretrees:ebony_trunk_allfaces", category, alternate)
			if name ~= nil then
				minetest.register_alias("ebony:"..category.."_trunk_allfaces"..alternate, name)
			end
			name = stairsplus:get_shape("moretrees:ebony_trunk_noface", category, alternate)
			if name ~= nil then
				minetest.register_alias("ebony:"..category.."_trunk_noface"..alternate, name)
			end
		end
	end

	-- nodes to remove
	minetest.register_lbm({
		label = "Remove legacy ebony nodes",
		name = "ch_overrides:remove_ebony_nodes",
		nodenames = {"ebony:persimmon", "ebony:creeper", "ebony:creeper_leaves", "ebony:liana"},
		run_at_every_load = true,
		action = function(pos, node, dtime_s)
			minetest.remove_node(pos)
		end,
	})
end

-- Remove jonez
if not minetest.get_modpath("jonez") and minetest.get_modpath("darkage") then
	local lbm_replacements = {
		["jonez:blossom_pavement"] = {name = "solidcolor:stoneblock_block"},
		["jonez:carthaginian_pavement"] = {name = "moreblocks:iron_stone_bricks", param2 = 0},
		["jonez:climbing_rose"] = {name = "air"},
		["jonez:diamond_pavement"] = {name = "ch_decor:wood_tile"},
		["jonez:industrial_base"] = {name = "darkage:ors_brick", param2 = 0},
		["jonez:industrial_shaft"] = {name = "darkage:ors_brick", param2 = 0},
		["jonez:minoan_shaft"] = {name = "ch_extras:shaft"},
		["jonez:mosaic_pavement"] = {name = "moreblocks:iron_stone_bricks", param2 = 0},
		["jonez:pompeiian_capital"] = {name = "solidcolor:stoneblock_block", param2 = 194},
		["jonez:pompeiian_pavement"] = {name = "ch_decor:wood_tile"},
		["jonez:romantic_shaft"] = {name = "ch_extras:shaft"},
		["jonez:ruin_creeper"] = {name = "air"},
		["jonez:ruin_vine"] = {name = "air"},
		["jonez:swedish_ivy"] = {name = "air"},
		["jonez:tuscan_architrave"] = {name = "solidcolor:stoneblock_block"},
		["jonez:versailles_architrave"] = {name = "default:obsidian_block", param2 = 0},
		["jonez:versailles_base"] = {name = "ch_extras:shaft"},
		["jonez:versailles_capital"] = {name = "ch_extras:shaft"},
		["jonez:versailles_shaft"] = {name = "ch_extras:shaft"},
	}
	for i = 1, 14 do
		for j = 0, 1 do
			lbm_replacements["tombs:jonez_marble_"..i.."_"..j] = {name = "tombs:ch_extras_marble_"..i.."_"..j}
		end
	end
	local nodenames = {}
	for k, _ in pairs(lbm_replacements) do
		table.insert(nodenames, k)
	end

	minetest.register_lbm({
		label = "Upgrade jonez 1",
		name = "ch_overrides:upgrade_jonez_1",
		nodenames = nodenames,
		run_at_every_load = true,
		action = function(pos, node)
			local r = lbm_replacements[node.name]
			node.name = r.name
			node.param2 = r.param2 or node.param2
			minetest.set_node(pos, node)
		end,
	})
end


if minetest.get_modpath("moretrees") and not minetest.get_modpath("plumtree") then
	local list = {
		["plumtree:trunk"] = "moretrees:plumtree_trunk",
		["plumtree:wood"] = "moretrees:plumtree_planks",
		["plumtree:leaves"] = "moretrees:plumtree_leaves",
		["plumtree:trunk_noface"] = "moretrees:plumtree_trunk_noface",
		["plumtree:trunk_allfaces"] = "moretrees:plumtree_trunk_allfaces",
		["plumtree:mese_post_light"] = "moretrees:plumtree_mese_post_light",
		["plumtree:blossom_leaves"] = "moretrees:plumtree_leaves",
		["plumtree:sapling"] = "moretrees:plumtree_sapling",
		["plumtree:sapling_ongen"] = "moretrees:plumtree_sapling_ongen",
		["plumtree:gate_open"] = "moretrees:plumtree_gate_open",
		["plumtree:gate_closed"] = "moretrees:plumtree_gate_closed",
		["plumtree:fence"] = "moretrees:plumtree_fence",
		["plumtree:fence_rail"] = "moretrees:plumtree_fence_rail",
		["plumtree:plum"] = "moretrees:plum",
	}
	for alias, name in pairs(list) do
		if minetest.registered_items[name] ~= nil then
			minetest.register_alias(alias, name)
		end
	end

	-- stairsplus shapes
	local name
	for category, alternates in pairs(stairsplus.defs) do
		for alternate, _ in pairs(alternates) do
			name = stairsplus:get_shape("moretrees:plumtree_planks", category, alternate)
			if name ~= nil then
				minetest.register_alias("plumtree:"..category.."_wood"..alternate, name)
			end
			name = stairsplus:get_shape("moretrees:plumtree_trunk_noface", category, alternate)
			if name ~= nil then
				minetest.register_alias("plumtree:"..category.."_trunk_noface"..alternate, name)
			end
		end
	end
end

if minetest.get_modpath("moretrees") and not minetest.get_modpath("willow") then
	local list = {
		["willow:trunk"] = "moretrees:willow_trunk",
		["willow:wood"] = "moretrees:willow_planks",
		["willow:trunk_noface"] = "moretrees:willow_trunk_noface",
		["willow:trunk_allfaces"] = "moretrees:willow_trunk_allfaces",
		["willow:mese_post_light"] = "moretrees:willow_mese_post_light",
		["willow:leaves"] = "moretrees:willow_leaves",
		["willow:sapling"] = "moretrees:willow_sapling",
		["willow:sapling_ongen"] = "moretrees:willow_sapling_ongen",
		["willow:gate_open"] = "moretrees:willow_gate_open",
		["willow:gate_closed"] = "moretrees:willow_gate_closed",
		["willow:fence"] = "moretrees:willow_fence",
		["willow:fence_rail"] = "moretrees:willow_fence_rail",
	}
	for alias, name in pairs(list) do
		if minetest.registered_items[name] ~= nil then
			minetest.register_alias(alias, name)
		end
	end

	-- stairsplus shapes
	local name
	for category, alternates in pairs(stairsplus.defs) do
		for alternate, _ in pairs(alternates) do
			name = stairsplus:get_shape("moretrees:willow_planks", category, alternate)
			if name ~= nil then
				minetest.register_alias("willow:"..category.."_wood"..alternate, name)
			end
			name = stairsplus:get_shape("moretrees:willow_trunk_noface", category, alternate)
			if name ~= nil then
				minetest.register_alias("willow:"..category.."_trunk_noface"..alternate, name)
			end
		end
	end
end

-- LBM to upgrade roofs:

local old_roof_materials = {
	"bakedclay:black",
	"bakedclay:blue",
	"cottages:black",
	"cottages:brown",
	"cottages:red",
	"cottages:reet",
	"darkage:slate_tile",
	"default:acacia_wood",
	"default:aspen_wood",
	"default:copperblock",
	"default:junglewood",
	"default:obsidian_glass",
	"default:pine_wood",
	"default:steelblock",
	"default:wood",
	"farming:straw",
	"moreblocks:cactus_checker",
	"moreblocks:copperpatina",
	"technic:cast_iron_block",
	"technic:zinc_block"
}

-- Upgrade old roofs:

local old_roof_translation_table = {}
local old_roof_nodenames = {}

for i, name in ipairs(old_roof_materials) do
	local modname, itemname = name:match("([^:]*):([^:]*)")
	if modname == nil or itemname == nil then error("Invalid item name: "..name) end
	local old_name = modname..":"..itemname.."_technic_cnc_d45_slope_216"
	if modname == "default" then modname = "moreblocks" end
	local new_name = modname..":slope_"..itemname.."_roof45"
	table.insert(old_roof_nodenames, old_name)
	table.insert(old_roof_nodenames, old_name.."_3")
	old_roof_translation_table[old_name] = new_name
	old_roof_translation_table[old_name.."_3"] = new_name.."_3"
end

local lbm_def = {
	label = "Upgrade old roof nodes",
	name = "ch_overrides:upgrade_roofs",
	nodenames = old_roof_nodenames,
	action = function(pos, node, dtime_s)
		local debug_old_name, debug_old_param2 = node.name, node.param2
		node.name = old_roof_translation_table[node.name]
		if node.name ~= nil then
			node.param2 = bit.bor(bit.band(node.param2, 255 - 3), bit.band(node.param2 + 3, 3))
			minetest.swap_node(pos, node)
			-- minetest.log("action", "[DEBUG] would upgrade "..debug_old_name.."/"..debug_old_param2.." to "..node.name.."/"..node.param2)
		else
			error("Update roof called on unsupported node at "..minetest.pos_to_string(pos).."!")
		end
	end,
}
minetest.register_lbm(lbm_def)

-- Node upgrades:
local cnc_materials = {
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
-- "basic_materials:brass_block",
-- "basic_materials:cement_block",
-- "basic_materials:concrete_block",
"building_blocks:fakegrass",
"cottages:black",
"cottages:brown",
"cottages:red",
"cottages:reet",
"darkage:slate_tile",
"default:acacia_wood",
"default:aspen_wood",
"default:brick",
"default:bronzeblock",
"default:cobble",
"default:copperblock",
"default:desert_cobble",
"default:desert_sandstone",
"default:desert_sandstone_block",
"default:desert_sandstone_brick",
"default:desert_stone",
"default:desert_stone_block",
"default:desert_stonebrick",
"default:dirt",
-- "default:glass",
"default:goldblock",
"default:ice",
"default:junglewood",
-- "default:leaves",
"default:meselamp",
"default:obsidian_block",
-- "default:obsidian_glass",
"default:pine_wood",
"default:silver_sandstone",
"default:silver_sandstone_block",
"default:silver_sandstone_brick",
"default:steelblock",
"default:stone",
"default:stone_block",
"default:stonebrick",
-- "default:tree",
"default:wood",
"moreblocks:cactus_brick",
"moreblocks:cactus_checker",
"moreblocks:copperpatina",
-- "moreblocks:glow_glass",
"moreblocks:grey_bricks",
-- "moreblocks:super_glow_glass",
"technic:blast_resistant_concrete",
"technic:cast_iron_block",
"technic:granite",
"technic:marble",
"technic:warning_block",
"technic:zinc_block",
}

local upgrade_map = {
	["moretrees:panel_palm_planks_l"] = "moretrees:panel_oak_planks_l",
	["moretrees:panel_palm_planks_special"] = "moretrees:panel_oak_planks_special",
	["default:tree_technic_cnc_stick"] = "moreblocks:panel_tree_noface_pole_flat",
	["ch_overrides:concrete_arcade"] = "technic:slab_concrete_arcade",
	["walls:cobble"] = "moreblocks:panel_cobble_wall",
	["walls:mossycobble"] = "moreblocks:panel_cobble_wall",
	["walls:desertcobble"] = "moreblocks:panel_desert_cobble_wall",
	["default:dirt_technic_cnc_valley"] = "moreblocks:slope_dirt_valley",
	["default:wood_technic_cnc_valley"] = "moreblocks:slope_wood_valley",
}
local upgrade_list = {}

for _, recipeitem in ipairs(cnc_materials) do
	local from = recipeitem.."_technic_cnc_stick"
	local to = recipeitem:gsub("^default:", "moreblocks:")
	to = to:gsub(":", ":panel_")
	to = to.."_pole_flat"
	if minetest.registered_nodes[to] ~= nil then
		upgrade_map[from] = to
	else
		minetest.log("warning", "Expected node not registered: "..to)
	end
end

for n, _ in pairs(upgrade_map) do
	table.insert(upgrade_list, n)
end

local lbm_def = {
	label = "Upgrade nodes",
	name = "ch_overrides:node_upgrade_v2",
	nodenames = upgrade_list,
	action = function(pos, node)
		node.name = upgrade_map[node.name]
		if node.name ~= nil then
			minetest.swap_node(pos, node)
		end
	end,
}
minetest.register_lbm(lbm_def)

local legacy_plaster_nodes = {
"solidcolor:micro_plaster_red_4",
"solidcolor:micro_plaster_white_1",
"solidcolor:panel_plaster_medium_amber_s50",
"solidcolor:panel_plaster_red_4",
"solidcolor:panel_plaster_white",
"solidcolor:panel_plaster_white_1",
"solidcolor:panel_plaster_white_l",
"solidcolor:panel_plaster_white_special",
"solidcolor:panel_plaster_yellow",
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
"solidcolor:slab_plaster_blue",
"solidcolor:slab_plaster_blue_1",
"solidcolor:slab_plaster_blue_2",
"solidcolor:slab_plaster_blue_quarter",
"solidcolor:slab_plaster_blue_triplet",
"solidcolor:slab_plaster_blue_two_sides",
"solidcolor:slab_plaster_cyan",
"solidcolor:slab_plaster_cyan_1",
"solidcolor:slab_plaster_cyan_2",
"solidcolor:slab_plaster_cyan_quarter",
"solidcolor:slab_plaster_cyan_triplet",
"solidcolor:slab_plaster_cyan_two_sides",
"solidcolor:slab_plaster_dark_green",
"solidcolor:slab_plaster_dark_green_1",
"solidcolor:slab_plaster_dark_green_2",
"solidcolor:slab_plaster_dark_green_quarter",
"solidcolor:slab_plaster_dark_green_triplet",
"solidcolor:slab_plaster_dark_green_two_sides",
"solidcolor:slab_plaster_dark_grey",
"solidcolor:slab_plaster_dark_grey_1",
"solidcolor:slab_plaster_dark_grey_2",
"solidcolor:slab_plaster_dark_grey_quarter",
"solidcolor:slab_plaster_dark_grey_triplet",
"solidcolor:slab_plaster_dark_grey_two_sides",
"solidcolor:slab_plaster_green",
"solidcolor:slab_plaster_green_1",
"solidcolor:slab_plaster_green_2",
"solidcolor:slab_plaster_green_quarter",
"solidcolor:slab_plaster_green_triplet",
"solidcolor:slab_plaster_green_two_sides",
"solidcolor:slab_plaster_grey",
"solidcolor:slab_plaster_grey_1",
"solidcolor:slab_plaster_grey_2",
"solidcolor:slab_plaster_grey_quarter",
"solidcolor:slab_plaster_grey_triplet",
"solidcolor:slab_plaster_grey_two_sides",
"solidcolor:slab_plaster_medium_amber_s50",
"solidcolor:slab_plaster_medium_amber_s50_1",
"solidcolor:slab_plaster_medium_amber_s50_15",
"solidcolor:slab_plaster_medium_amber_s50_2",
"solidcolor:slab_plaster_medium_amber_s50_quarter",
"solidcolor:slab_plaster_medium_amber_s50_triplet",
"solidcolor:slab_plaster_medium_amber_s50_two_sides",
"solidcolor:slab_plaster_orange",
"solidcolor:slab_plaster_orange_1",
"solidcolor:slab_plaster_orange_2",
"solidcolor:slab_plaster_orange_quarter",
"solidcolor:slab_plaster_orange_triplet",
"solidcolor:slab_plaster_orange_two_sides",
"solidcolor:slab_plaster_pink",
"solidcolor:slab_plaster_pink_1",
"solidcolor:slab_plaster_pink_2",
"solidcolor:slab_plaster_pink_quarter",
"solidcolor:slab_plaster_pink_triplet",
"solidcolor:slab_plaster_pink_two_sides",
"solidcolor:slab_plaster_red",
"solidcolor:slab_plaster_red_1",
"solidcolor:slab_plaster_red_2",
"solidcolor:slab_plaster_red_quarter",
"solidcolor:slab_plaster_red_triplet",
"solidcolor:slab_plaster_red_two_sides",
"solidcolor:slab_plaster_white",
"solidcolor:slab_plaster_white_1",
"solidcolor:slab_plaster_white_2",
"solidcolor:slab_plaster_white_quarter",
"solidcolor:slab_plaster_white_triplet",
"solidcolor:slab_plaster_white_two_sides",
"solidcolor:slab_plaster_yellow",
"solidcolor:slab_plaster_yellow_1",
"solidcolor:slab_plaster_yellow_2",
"solidcolor:slab_plaster_yellow_quarter",
"solidcolor:slab_plaster_yellow_triplet",
"solidcolor:slab_plaster_yellow_two_sides",
"solidcolor:slope_plaster_blue",
"solidcolor:slope_plaster_blue_half",
"solidcolor:slope_plaster_blue_half_raised",
"solidcolor:slope_plaster_blue_slab",
"solidcolor:slope_plaster_cyan",
"solidcolor:slope_plaster_cyan_half",
"solidcolor:slope_plaster_cyan_half_raised",
"solidcolor:slope_plaster_cyan_slab",
"solidcolor:slope_plaster_dark_green",
"solidcolor:slope_plaster_dark_green_half",
"solidcolor:slope_plaster_dark_green_half_raised",
"solidcolor:slope_plaster_dark_green_slab",
"solidcolor:slope_plaster_dark_green_tripleslope",
"solidcolor:slope_plaster_dark_grey",
"solidcolor:slope_plaster_dark_grey_half",
"solidcolor:slope_plaster_dark_grey_half_raised",
"solidcolor:slope_plaster_dark_grey_slab",
"solidcolor:slope_plaster_dark_grey_tripleslope",
"solidcolor:slope_plaster_green",
"solidcolor:slope_plaster_green_half",
"solidcolor:slope_plaster_green_half_raised",
"solidcolor:slope_plaster_green_slab",
"solidcolor:slope_plaster_grey",
"solidcolor:slope_plaster_grey_half",
"solidcolor:slope_plaster_grey_half_raised",
"solidcolor:slope_plaster_grey_slab",
"solidcolor:slope_plaster_medium_amber_s50",
"solidcolor:slope_plaster_medium_amber_s50_half",
"solidcolor:slope_plaster_medium_amber_s50_half_raised",
"solidcolor:slope_plaster_medium_amber_s50_slab",
"solidcolor:slope_plaster_orange",
"solidcolor:slope_plaster_orange_half",
"solidcolor:slope_plaster_orange_half_raised",
"solidcolor:slope_plaster_orange_slab",
"solidcolor:slope_plaster_pink",
"solidcolor:slope_plaster_pink_half",
"solidcolor:slope_plaster_pink_half_raised",
"solidcolor:slope_plaster_pink_slab",
"solidcolor:slope_plaster_red",
"solidcolor:slope_plaster_red_half",
"solidcolor:slope_plaster_red_half_raised",
"solidcolor:slope_plaster_red_slab",
"solidcolor:slope_plaster_white",
"solidcolor:slope_plaster_white_half",
"solidcolor:slope_plaster_white_half_raised",
"solidcolor:slope_plaster_white_inner_half",
"solidcolor:slope_plaster_white_inner_half_raised",
"solidcolor:slope_plaster_white_outer_half",
"solidcolor:slope_plaster_white_outer_half_raised",
"solidcolor:slope_plaster_white_slab",
"solidcolor:slope_plaster_yellow",
"solidcolor:slope_plaster_yellow_half",
"solidcolor:slope_plaster_yellow_half_raised",
"solidcolor:slope_plaster_yellow_slab",
"solidcolor:stair_plaster_medium_amber_s50",
"solidcolor:stair_plaster_white_chimney",
}
lbm_def = {
	label = "Upgrade legacy solidcolor nodes",
	name = "ch_overrides:solidcolor_upgrade_v1",
	nodenames = legacy_plaster_nodes,
	action = function(pos, node)
		node.name = "ch_core"..node.name:sub(11,-1)
		if core.registered_nodes[node.name] then
			core.swap_node(pos, node)
		else
			core.log("error", "Upgrade legacy plaster nodes failed: node "..node.name.." not defined!")
		end
	end,
}
minetest.register_lbm(lbm_def)
