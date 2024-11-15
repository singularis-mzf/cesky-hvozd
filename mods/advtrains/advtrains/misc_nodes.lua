--all nodes that do not fit in any other category

local diagonalbox = {
	type = "fixed",
	fixed = {
		{-0.5,  -0.5, 0.5, -0.25, 0.5, -0.8 },
		{-0.25, -0.5, 0.5 , 0,    0.5, -0.55},
		{0,     -0.5, 0.5 , 0.25, 0.5, -0.3 },
		{0.25 , -0.5, 0.5,  0.5,  0.5, -0.05}
	}
}

local diagonalbox_low = {
	type = "fixed",
	fixed = {
		{-0.5,  -0.5, 0.5, -0.25, 0, -0.8 },
		{-0.25, -0.5, 0.5 , 0,    0, -0.55},
		{0,     -0.5, 0.5 , 0.25, 0, -0.3 },
		{0.25 , -0.5, 0.5,  0.5,  0, -0.05}
	}
}

local nodename_override = {
	["darkage:marble"] = "darkage_marble",
	["technic:marble"] = "technic_marble",
}

function advtrains.register_platform(modprefix, preset, use_full_nodename)
	local ndef=minetest.registered_nodes[preset]
	if not ndef then 
		minetest.log("warning", " register_platform couldn't find preset node "..preset)
		return
	end
	local btex=ndef.tiles
	if type(btex)=="table" then
		btex=btex[1]
		if type(btex) == "table" then
			btex = btex.name
			if type(btex) ~= "string" then
				error("Error in tiles when registering a platform for "..preset.."!")
			end
		end
	end
	local desc=ndef.description or ""
	local nodename = nodename_override[preset]

	if nodename == nil then
		nodename = string.match(preset, ":(.+)$")
	end
	-- minetest.log("action", "DEBUG: will register platforms for "..preset.." using nodename = ("..nodename..")")

	if ch_core.is_shape_allowed(preset, "advtrains", "platform_low") then
		minetest.register_node(modprefix .. ":platform_low_"..nodename, {
			description = attrans("@1 Platform (low)", desc),
			tiles = {btex.."^advtrains_platform.png", btex, btex, btex, btex, btex},
			groups = {cracky = 1, not_blocking_trains = 1, platform=1},
			sounds = ndef.sounds,
			drawtype = "nodebox",
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5, -0.1, -0.1, 0.5,  0  , 0.5},
					{-0.5, -0.5,  0  , 0.5, -0.1, 0.5}
				},
			},
			paramtype2="facedir",
			paramtype = "light",
			sunlight_propagates = true,
		})
		minetest.register_craft({
			type="shapeless",
			output = modprefix .. ":platform_low_"..nodename.." 4",
			recipe = {
				"dye:yellow", preset
			},
		})
		end

	if ch_core.is_shape_allowed(preset, "advtrains", "platform_high") then
		minetest.register_node(modprefix .. ":platform_high_"..nodename, {
			description = attrans("@1 Platform (high)", desc),
			tiles = {btex.."^advtrains_platform.png", btex, btex, btex, btex, btex},
			groups = {cracky = 1, not_blocking_trains = 1, platform=2},
			sounds = ndef.sounds,
			drawtype = "nodebox",
			node_box = {
				type = "fixed",
				fixed = {
					{-0.5,  0.3, 0, 0.5,  0.5, 0.5},
					{-0.5, -0.5, 0.1  , 0.5,  0.3, 0.5}
				},
			},
			paramtype2="facedir",
			paramtype = "light",
			sunlight_propagates = true,
		})
		minetest.register_craft({
			type="shapeless",
			output = modprefix .. ":platform_high_"..nodename.." 4",
			recipe = {
				"dye:yellow", preset, preset
			},
		})
	end

	if ch_core.is_shape_allowed(preset, "advtrains", "platform_45_high") then
		minetest.register_node(modprefix..":platform_45_"..nodename, {
			description = attrans("@1 Platform (45 degree)", desc),
			groups = {cracky = 1, not_blocking_trains = 1, platform=2},
			sounds = ndef.sounds,
			drawtype = "mesh",
			mesh = "advtrains_platform_diag.b3d",
			selection_box = diagonalbox,
			collision_box = diagonalbox,
			tiles = {btex, btex.."^advtrains_platform_diag.png"},
			paramtype2 = "facedir",
			paramtype = "light",
			sunlight_propagates = true,
		})
		minetest.register_craft({
			type="shapeless",
			output = modprefix .. ":platform_45_"..nodename.." 2",
			recipe = {
				"dye:yellow", preset, preset, preset
			}
		})
	end

	if ch_core.is_shape_allowed(preset, "advtrains", "platform_45_low") then
		minetest.register_node(modprefix..":platform_45_low_"..nodename, {
			description = attrans("@1 Platform (low, 45 degree)", desc),
			groups = {cracky = 1, not_blocking_trains = 1, platform=2},
			sounds = ndef.sounds,
			drawtype = "mesh",
			mesh = "advtrains_platform_diag_low.b3d",
			selection_box = diagonalbox_low,
			collision_box = diagonalbox_low,
			tiles = {btex, btex.."^advtrains_platform_diag.png"},
			paramtype2 = "facedir",
			paramtype = "light",
			sunlight_propagates = true,
		})
		minetest.register_craft({
			type="shapeless",
			output = modprefix .. ":platform_45_low_"..nodename.." 2",
			recipe = { modprefix .. ":platform_45_"..nodename },
		})
	end
end

for _, material in ipairs(ch_core.get_materials_from_shapes_db("advtrains")) do
	if minetest.registered_nodes[material] then
		advtrains.register_platform("advtrains", material)
	end
end

-- advtrains.register_platform("advtrains", "default:stonebrick")
-- advtrains.register_platform("advtrains", "default:sandstonebrick")

--[[
local platform_materials = {
	"basic_materials:cement_block",
	"basic_materials:concrete_block",
	"building_blocks:Tar",
	"darkage:basalt",
	"darkage:basalt_brick",
	-- "darkage:basalt_cobble",
	--"darkage:gneiss",
	"darkage:gneiss_brick",
	--"darkage:gneiss_cobble",
	{"darkage:marble"},
	-- "darkage:ors",
	"darkage:ors_brick",
	-- "darkage:ors_cobble",
	"darkage:serpentine",
	-- "darkage:slate",
	"darkage:slate_brick",
	-- "darkage:slate_cobble",
	"darkage:stone_brick",
	"default:acacia_wood",
	"default:aspen_wood",
	"default:desert_stone",
	"default:desert_stone_block",
	"default:junglewood",
	"default:pine_wood",
	"default:steelblock",
	"default:stone",
	"default:stonebrick",
	"default:stone_block",
	"default:wood",
	"moretrees:cedar_planks",
	"moretrees:cherrytree_planks",
	"moretrees:chestnut_tree_planks",
	"moretrees:date_palm_planks",
	"moretrees:birch_planks",
	-- "moretrees:beech_planks",
	"moretrees:apple_tree_planks",
	"moretrees:ebony_planks",
	"moretrees:fir_planks",
	"moretrees:oak_planks",
	"moretrees:palm_planks",
	"moretrees:plumtree_planks",
	"moretrees:rubber_tree_planks",
	"moretrees:sequoia_planks",
	"moretrees:spruce_planks",
	"moretrees:poplar_planks",
	"moretrees:willow_planks",
	"moreblocks:wood_tile_center",
	"moreblocks:wood_tile_full",
	{"technic:marble"},
}
for _, name in ipairs(platform_materials) do
	local nodename, use_full_nodename
	if type(name) == "string" then
		nodename = name
	else
		nodename = name[1]
		use_full_nodename = true
	end

	if minetest.registered_nodes[nodename] then
		advtrains.register_platform("advtrains", nodename, use_full_nodename)
	else
		minetest.log("warning", nodename.." not find as a node to build a platform")
	end
end
]]
