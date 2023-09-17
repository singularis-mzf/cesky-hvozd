local water_nodes = {
	"default:water_source",
	"default:water_flowing",
	"default:river_water_source",
	"default:river_water_flowing",
}
local water_set = table.key_value_swap(water_nodes)

local function dirt_to_mud(pos, node, active_object_count, active_object_count_wider)
	local node_above = minetest.get_node_or_nil(vector.offset(pos, 0, 1, 0))
	if node_above == nil or water_set[node_above.name] == nil then
		return
	end
	node.name = "darkage:mud"
	minetest.set_node(pos, node)
end

local function mud_to_dirt(pos, node, active_object_count, active_object_count_wider)
	local result = minetest.find_node_near(pos, 3, {"group:water"}, false)
	if result == nil then
		node.name = "default:dirt"
		minetest.set_node(pos, node)
	end
end

local def = {
	label = "Dirt to mud",
	nodenames = {
		"default:dirt",
		"default:dirt_with_grass",
		"default:dirt_with_grass_footsteps",
		"default:dirt_with_dry_grass",
		"default:dirt_with_rainforest_litter",
		"default:dirt_with_coniferous_litter",
	},
	neighbors = water_nodes,
	interval = 10.0,
	chance = 4,
	catch_up = true,
	action = dirt_to_mud,
}

minetest.register_abm(def)

def = {
	label = "Mud to dirt",
	nodenames = {"darkage:mud"},
	neighbors = {"air"},
	interval = 10.0,
	chance = 50,
	catch_up = true,
	action = mud_to_dirt,
}

minetest.register_abm(def)

def = {
	tiles = {"darkage_mud.png"},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name = "darkage_mud_footstep", gain = 0.3},
	})
}

minetest.override_item("darkage:mud", def)
