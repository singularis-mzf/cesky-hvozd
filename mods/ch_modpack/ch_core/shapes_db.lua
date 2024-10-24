ch_core.open_submod("shapes_db", {lib = true})

local ifthenelse = ch_core.ifthenelse

local function set(...)
	local i, result, t = 1, {}, {...}
	while t[i] ~= nil do
		result[t[i]] = true
		i = i + 1
	end
	return result
end

local function union(...)
	local i, result, t = 1, {}, {...}
	while t[i] ~= nil do
		for k, v in pairs(t[i]) do
			result[k] = v
		end
		i = i + 1
	end
	return result
end

local materials_kp = set(
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
"building_blocks:smoothglass",
"building_blocks:woodglass",
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
"default:diamondblock",
"default:dirt",
"default:glass",
"default:goldblock",
"default:ice",
"default:junglewood",
"default:meselamp",
"default:obsidian",
"default:obsidian_block",
"default:obsidian_glass",
"default:obsidianbrick",
"default:pine_wood",
"default:sandstone",
"default:sandstone_block",
"default:sandstonebrick",
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
"moreblocks:clean_glass",
"moreblocks:clean_glow_glass",
"moreblocks:clean_super_glow_glass",
"moreblocks:coal_checker",
"moreblocks:coal_glass",
"moreblocks:coal_stone",
"moreblocks:coal_stone_bricks",
"moreblocks:cobble_compressed",
"moreblocks:copperpatina",
"moreblocks:desert_cobble_compressed",
"moreblocks:glow_glass",
"moreblocks:grey_bricks",
"moreblocks:iron_checker",
"moreblocks:iron_glass",
"moreblocks:iron_stone",
"moreblocks:iron_stone_bricks",
"moreblocks:jungletree_allfaces",
"moreblocks:jungletree_noface",
"moreblocks:pine_tree_noface",
"moreblocks:plankstone",
"moreblocks:split_stone_tile",
"moreblocks:stone_tile",
"moreblocks:super_glow_glass",
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
"moretrees:palm_planks",
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
)

local materials_sns = set(
"ch_extras:bright_gravel",
"ch_extras:railway_gravel",
"default:desert_sand",
"default:dirt_with_coniferous_litter",
"default:dirt_with_grass",
"default:dirt_with_rainforest_litter",
"default:dry_dirt",
"default:dry_dirt_with_dry_grass",
"default:gravel",
"default:sand",
"default:silver_sand",
"default:snowblock",
"farming:hemp_block",
"farming:straw",
"mobs:honey_block",
"moretrees:ebony_trunk_allfaces",
"moretrees:poplar_trunk_allfaces",
"summer:sabbia_mare"
)

local materials_wool = set(
"wool:black",
"wool:blue",
"wool:brown",
"wool:cyan",
"wool:dark_green",
"wool:dark_grey",
"wool:green",
"wool:grey",
"wool:magenta",
"wool:orange",
"wool:pink",
"wool:red",
"wool:violet",
"wool:white",
"wool:yellow"
)

local materials_cnc = set(
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
"default:glass",
"default:goldblock",
"default:ice",
"default:junglewood",
"default:leaves",
"default:meselamp",
"default:obsidian_block",
"default:obsidian_glass",
"default:pine_wood",
"default:sandstone",
"default:sandstone_block",
"default:sandstonebrick",
"default:silver_sandstone",
"default:silver_sandstone_block",
"default:silver_sandstone_brick",
"default:steelblock",
"default:stone",
"default:stone_block",
"default:stonebrick",
"default:tree",
"default:wood",
"farming:straw",
"moreblocks:cactus_brick",
"moreblocks:cactus_checker",
"moreblocks:copperpatina",
"moreblocks:glow_glass",
"moreblocks:grey_bricks",
"moreblocks:super_glow_glass",
"technic:blast_resistant_concrete",
"technic:cast_iron_block",
"technic:granite",
"technic:marble",
"technic:warning_block",
"technic:zinc_block"
)

local materials_pillars = set(
	"basic_materials:brass_block",
"basic_materials:cement_block",
"basic_materials:concrete_block",
"ch_extras:marble",
"darkage:basalt",
"darkage:basalt_brick",
"darkage:basalt_cobble",
"darkage:marble",
"darkage:ors_brick",
"darkage:serpentine",
"darkage:stone_brick",
"default:acacia_wood",
"default:aspen_wood",
"default:bronzeblock",
"default:copperblock",
"default:desert_cobble",
"default:desert_sandstone",
"default:desert_sandstone_brick",
"default:desert_stone",
"default:desert_stonebrick",
"default:goldblock",
"default:junglewood",
"default:obsidian",
"default:pine_wood",
"default:sandstone",
"default:sandstonebrick",
"default:silver_sandstone",
"default:silver_sandstone_brick",
"default:steelblock",
"default:stone",
"default:stonebrick",
"default:wood",
"moreblocks:copperpatina",
"moretrees:date_palm_planks",
"moretrees:ebony_planks",
"moretrees:plumtree_planks",
"moretrees:poplar_planks",
"moretrees:spruce_planks",
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
"technic:cast_iron_block",
"technic:marble"
)

local materials_for_bank_slopes = set(
	"basic_materials:cement_block",
	"default:dirt",
	"default:gravel",
	"default:sand",
	"summer:sabbia_mare"
)

local materials_roof = set(
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
)

local materials_zdlazba = set(
	"ch_extras:cervzdlazba",
	"ch_extras:zdlazba"
)

local materials_all = union(materials_cnc, materials_kp, materials_sns, materials_wool, materials_roof, materials_zdlazba)

local alts_micro = set("", "_1", "_2", "_4", "_12", "_15")

local alts_panel = set("", "_1", "_2", "_4", "_12", "_15",
	"_special", -- vychýlená tyč I
	"_l", -- vychýlená tyč L
	"_l1", -- rohový panel do tvaru L
	"_wide",
	"_wide_1")

local alts_slab = set("", "_quarter", "_three_quarter", "_1", "_2", "_14", "_15",
	"_two_sides", --deska L (dvě strany)
	"_three_sides", -- deska rohová (tři strany)
	"_three_sides_u", -- deska U (tři strany)
	"_triplet", -- trojitá deska
	"_cube", -- kvádr
	"_two_sides_half", -- deska L (dvě strany, seříznutá)
	"_three_sides_half") -- deska rohová (tři strany, seříznutá)

local alts_slope = set("", "_half", "_half_raised",
	"_inner", "_inner_half", "_inner_half_raised", "_inner_cut", "_inner_cut_half", "_inner_cut_half_raised",
	"_outer", "_outer_half", "_outer_half_raised", "_outer_cut", "_outer_cut_half", "_cut",
	"_slab", -- trojúhelník
	"_tripleslope",
	"_cut2" -- šikmá hradba
)

local alts_stair = set("", "_inner", "_outer", "_alt", "_alt_1", "_alt_2", "_alt_4",
	"_triple", -- schody (schod 1/3 m)
	"_chimney", -- úzký komín
	"_wchimney") -- široký komín

local alts_cnc = set(
	"technic_cnc_stick",
"technic_cnc_element_end_double",
"technic_cnc_element_cross_double",
"technic_cnc_element_t_double",
"technic_cnc_element_edge_double",
"technic_cnc_element_straight_double",
"technic_cnc_element_end",
"technic_cnc_element_cross",
"technic_cnc_element_t",
"technic_cnc_element_edge",
"technic_cnc_element_straight",
"technic_cnc_oblate_spheroid",
"technic_cnc_sphere",
"technic_cnc_cylinder_horizontal",
"technic_cnc_cylinder",
"technic_cnc_twocurvededge",
"technic_cnc_onecurvededge",
"technic_cnc_spike",
"technic_cnc_pyramid",
"technic_cnc_arch216",
"technic_cnc_arch216_flange",
-- "technic_cnc_d45_slope_216",
"technic_cnc_sphere_half",
"technic_cnc_block_fluted",
"technic_cnc_diagonal_truss",
"technic_cnc_diagonal_truss_cross",
"technic_cnc_opposedcurvededge",
"technic_cnc_cylinder_half",
"technic_cnc_cylinder_half_corner",
"technic_cnc_circle",
"technic_cnc_oct",
"technic_cnc_peek",
"technic_cnc_valley",
"technic_cnc_bannerstone"
)

local wool_panels = set("", "_1", "_2", "_4", "_l", "_special")

local wool_slabs = set("", "_quarter", "_three_quarter", "_1", "_2", "_14", "_15")

local sns_slabs = wool_slabs

local sns_slopes = set("", "_half", "_half_raised",
	"_inner", "_inner_half", "_inner_half_raised", "_inner_cut", "_inner_cut_half", "_inner_cut_half_raised",
	"_outer", "_outer_half", "_outer_half_raised", "_outer_cut", "_outer_cut_half", "_cut",
	"_slab", -- trojúhelník
	"_tripleslope")

local wool_slopes = set("", "_half", "_half_raised", "_slab")

local roof_slopes = set("_roof22", "_roof22_raised", "_roof22_3", "_roof22_raised_3", "_roof45", "_roof45_3")

local bank_slopes = set("", "_cut", "_half", "_half_raised",
"_inner", "_inner_half", "_inner_half_raised", "_inner_cut", "_inner_cut_half", "_inner_cut_half_raised",
"_outer", "_outer_half", "_outer_half_raised")

-- ============================================================================
local rules = {
	-- {materials, categories, alternates, true/false [, comment]}
	-- materials, categories and alternates may be:
	--	a) string (exact match)
	--  b) table (query)
	--  c) "*" (always match)
	{"*", "slab", "_1", true}, -- "slab/_1 pro všechny materiály"
	{"default:wood", "*", "*", true}, -- dřevo je referenční materiál, musí podporovat všechny tvary
	{materials_kp, "micro", alts_micro, true},
	{materials_kp, "panel", alts_panel, true},
	{materials_kp, "slab", alts_slab, true},
	{materials_kp, "slope", alts_slope, true},
	{materials_kp, "stair", alts_stair, true},
	{materials_sns, "slab", sns_slabs, true},
	{materials_sns, "slope", sns_slopes, true},
	{materials_wool, "panel", wool_panels, true},
	{materials_wool, "slab", wool_slabs, true},
	{materials_wool, "slope", wool_slopes, true},
	{materials_wool, "stair", "", true},
	{materials_roof, "slope", roof_slopes, true}, -- roofs
	{materials_zdlazba, "micro", set("_1", "_2", "", "_15"), true },
	{materials_zdlazba, "panel", set("_1", "_special", "_wide_1"), true},
	{materials_zdlazba, "slab", sns_slabs, true },
	{materials_zdlazba, "slope", alts_slope, true },
	{materials_zdlazba, "stair", "_alt_1", true },
	{materials_for_bank_slopes, "bank_slope", bank_slopes, true},
	{materials_pillars, "pillar", "*", true },

-- CNC:
	{"default:dirt", "cnc",
		set("technic_cnc_oblate_spheroid", "technic_cnc_slope_upsdown", "technic_cnc_edge", "technic_cnc_inner_edge",
		"technic_cnc_slope_edge_upsdown", "technic_cnc_slope_inner_edge_upsdown", "technic_cnc_stick", "technic_cnc_cylinder_horizontal"),
		false}, -- zakázat vybrané tvary z hlíny
	{materials_cnc, "cnc", alts_cnc, true}, -- výchozí pravidlo pro CNC
-- catch-all rules:
	{materials_all, set("micro", "panel", "slab", "slope", "stair", "cnc", "bank_slope"), "*", false},
}
-- ============================================================================


-- Cache in format:
-- [category.."@"..alternate] = {[material] = true, ...}
local query_cache = {}

local custom_list_shapes -- list of shapes for More Blocks

function ch_core.get_stairsplus_custom_shapes(recipeitem)
	if custom_list_shapes == nil then
		error("custom_list_shapes are not initialized yet!")
	end
	if recipeitem == nil then
		-- special case: return all possible shapes
		return table.copy(custom_list_shapes)
	end
	local result = {}
	for _, shape in ipairs(custom_list_shapes) do
		if ch_core.is_shape_allowed(recipeitem, shape[1], shape[2]) then
			table.insert(result, shape)
		end
	end
	-- print("ch_core.get_stairsplus_custom_shapes(): "..#result.." shapes generated for "..recipeitem)
	return result
end

function ch_core.init_stairsplus_custom_shapes(defs)
	local set = {}
	custom_list_shapes = {}
	for category, cdef in pairs(defs) do
		for alternate, _ in pairs(cdef) do
			local key = category.."/"..alternate
			if set[key] == nil then
				set[key] = true
				table.insert(custom_list_shapes, {category, alternate})
			end
		end
	end
end

local function is_match(s, pattern)
	if type(pattern) == "string" then
		return pattern == "*" or s == pattern
	elseif type(pattern) == "table" then
		return pattern[s] ~= nil
	elseif type(pattern) == "number" then
		return s == tostring(pattern)
	else
		error("Invalid pattern type '"..type(pattern).."'!")
	end
end

function ch_core.is_shape_allowed(recipeitem, category, alternate)
	if type(recipeitem) ~= "string" or type(category) ~= "string" or type(alternate) ~= "string" then
		error("Invalid argument type: "..dump2({
			func = "ch_core.is_shape_allowed",
			recipeitem = recipeitem, category = category, alternate = alternate,
			["type(recipeitem)"] = type(recipeitem),
			["type(category)"] = type(category),
			["type(alternate)"] = type(alternate),
		}))
	end
	local shapeinfo = query_cache[category.."@"..alternate]
	local result
	if shapeinfo ~= nil then
		result = shapeinfo[recipeitem]
		if result ~= nil then
			return result
		end
	end
	-- perform full resolution:
	for _, rule in ipairs(rules) do
		if is_match(category, rule[2]) and is_match(recipeitem, rule[1]) and is_match(alternate, rule[3]) then
			-- match
			result = ifthenelse(rule[4], true, false)
			break
		end
	end
	if result == nil then
		error("Shapes DB resolution failed for "..recipeitem.."/"..category.."/"..alternate.."!")
		-- result = true
		-- minetest.log("warning", "Shapes DB resolution failed for "..recipeitem.."/"..category.."/"..alternate.."! Will allow the shape.")
	end
	if shapeinfo == nil then
		shapeinfo = {}
		query_cache[category.."@"..alternate] = shapeinfo
	end
	shapeinfo[recipeitem] = result
	return result
end

function ch_core.get_comboblock_index(v1, v2)
	error("not implemented yet")
end

ch_core.close_submod("shapes_db")
