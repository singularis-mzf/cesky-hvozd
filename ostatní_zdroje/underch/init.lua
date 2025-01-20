--Hume2's Underground Challenge mod

underch = {}

--Scale all damage by a given factor
underch.damage_scaling_factor = 1

underch.modpath = minetest.get_modpath("underch")

underch.have_advtrains = minetest.get_modpath("advtrains") ~= nil
underch.have_bucket = minetest.get_modpath("bucket") ~= nil
underch.have_stairs = minetest.get_modpath("stairs") ~= nil
underch.have_stairsredo = stairs and stairs.mod and stairs.mod == "redo"
underch.have_moreblocks = minetest.get_modpath("moreblocks") ~= nil

underch.have_moreores = minetest.get_modpath("moreores") ~= nil
underch.have_technic_ores = minetest.get_modpath("technic_worldgen") ~= nil
underch.have_xtraores = minetest.get_modpath("xtraores") ~= nil

underch.use_jit = minetest.settings:get_bool("underch_ores_jit", false)
underch.polynomial_pressure = minetest.settings:get_bool("underch_polynomial_pressure", false)

dofile(underch.modpath .. "/dynamic.lua")
dofile(underch.modpath .. "/functions.lua")

if underch.use_jit then
	dofile(underch.modpath .. "/jit.lua")
else
	underch.jit = {}
	function underch.jit.dig_shadow(pos, oldnode, oldmetadata, digger)
		--ores-JIT not used
	end
end

dofile(underch.modpath .. "/nodes.lua")
dofile(underch.modpath .. "/crafts.lua")
dofile(underch.modpath .. "/stone.lua")
dofile(underch.modpath .. "/gems.lua")
dofile(underch.modpath .. "/slime.lua")
dofile(underch.modpath .. "/mushrooms.lua")
dofile(underch.modpath .. "/dense_ores.lua")

dofile(underch.modpath .. "/worldgen.lua")

if underch.have_stairs or underch.have_stairsredo or underch.have_moreblocks then
	dofile(underch.modpath .. "/moreblocks.lua")
end

--[[minetest.register_ore({
	ore_type        = "blob",
	ore             = "underch:clay",
	wherein         = {"default:stone"},
	clust_scarcity  = 16 * 16 * 16,
	clust_size      = 5,
	y_min           = -93,
	y_max           = 31000,
	noise_threshold = 0.0,
	noise_params    = {
		offset = 0.5,
		scale = 0.2,
		spread = {x = 5, y = 5, z = 5},
		seed = 4913,
		octaves = 1,
		persist = 0.0
	},
})

minetest.register_ore({
	ore_type        = "blob",
	ore             = "underch:mossy_gravel",
	wherein         = {"default:stone"},
	clust_scarcity  = 16 * 16 * 16,
	clust_size      = 5,
	y_min           = -1301,
	y_max           = 31000,
	noise_threshold = 0.0,
	noise_params    = {
		offset = 0.5,
		scale = 0.2,
		spread = {x = 5, y = 5, z = 5},
		seed = 9741,
		octaves = 1,
		persist = 0.0
	}
})


minetest.register_ore({
	ore_type        = "blob",
	ore             = "default:cobble",
	wherein         = {"default:stone"},
	clust_scarcity  = 16 * 16 * 16,
	clust_size      = 5,
	y_min           = -31000,
	y_max           = 31000,
	noise_threshold = 0.0,
	noise_params    = {
		offset = 0.5,
		scale = 0.2,
		spread = {x = 5, y = 5, z = 5},
		seed = 31242,
		octaves = 1,
		persist = 0.0
	},
})--]]

-- override lava cooling function

default.cool_lava = function(pos, node)
	if node.name == "default:lava_source" then
		minetest.set_node(pos, {name = "default:obsidian"})
	else -- Lava flowing
		minetest.set_node(pos, {name = "underch:basalt"})
	end
	minetest.sound_play("default_cool_lava",
		{pos = pos, max_hear_distance = 16, gain = 0.25})
end

-- moss growth

minetest.register_abm({
	label = "Moss growth",
	nodenames = {"group:cobble", "group:cobblestairs", "group:wall"},
	neighbors = {"group:water"},
	interval = 16,
	chance = 200,
	catch_up = false,
	action = function(pos, node)
		for id, s in pairs(underch.stone.defs) do
			if s.mossy_variant then
				if node.name == "underch:" .. id .. "_cobble" then
					minetest.set_node(pos, {name = "underch:" .. id .. "_mossy_cobble"})
				elseif node.name == "stairs:slab_" .. id .. "_cobble" then
					minetest.set_node(pos, {name = "stairs:slab_" .. id .. "_mossy_cobble", param2 = node.param2})
				elseif node.name == "stairs:stair_" .. id .. "_cobble" then
					minetest.set_node(pos, {name = "stairs:stair_" .. id .. "_mossy_cobble", param2 = node.param2})
				elseif node.name == "underch:" .. id .. "_cobble_wall" then
					minetest.set_node(pos, {name = "underch:" .. id .. "_mossy_cobble_wall", param2 = node.param2})
				end
			end
		end
	end
})
