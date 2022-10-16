-- DYNAMIC WATER AND LAVA
local find_nodes_in_area = minetest.find_nodes_in_area
local get_node = minetest.get_node
local swap_node = minetest.swap_node
-- local remove_node = minetest.remove_node
local random = PseudoRandom(3456)
local shifts_below = {
	vector.new(-1, -1, 0),
	vector.new(0, -1, -1),
	vector.new(1, -1, 0),
	vector.new(0, -1, 1),
}
local function water_func(pos, node, active_object_count, active_object_count_wider)
	local pos_below = vector.new(pos.x, pos.y - 1, pos.z)
	local node_below = get_node(pos_below)

	if node_below.name == "default:water_flowing" then
		swap_node(pos_below, node)
		swap_node(pos, node_below)
	else
		local rnd = random:next(1, 16)
		if rnd < 5 and node_below.name ~= "default:water_source" then
			pos_below = vector.add(pos, shifts_below[rnd])
			node_below = get_node(pos_below)
			if node_below.name == "default:water_flowing" then
				swap_node(pos_below, node)
				swap_node(pos, node_below)
			end
		elseif rnd < 7 then
			local nodes = find_nodes_in_area(vector.new(pos.x - 1, pos.y, pos.z - 1), vector.new(pos.x + 1, pos.y, pos.z + 1), "default:water_flowing")
			if #nodes == 8 then
				node.name = "default:water_flowing"
				swap_node(pos, node)
			end
		end
	end
end

local function lava_func(pos, node, active_object_count, active_object_count_wider)
	local pos_below = vector.new(pos.x, pos.y - 1, pos.z)
	local node_below = get_node(pos_below)

	if node_below.name == "default:lava_flowing" then
		swap_node(pos_below, node)
		swap_node(pos, node_below)
	else
		local rnd = random:next(1, 16)
		if rnd < 5 then
			pos_below = vector.add(pos, shifts_below[rnd])
			node_below = get_node(pos_below)
			if node_below.name == "default:lava_flowing" then
				swap_node(pos_below, node)
				swap_node(pos, node_below)
			end
		elseif rnd < 7 then
			if get_node(vector.new(pos.x - 1, pos.y, pos.z)).name == "default:lava_flowing"
			and get_node(vector.new(pos.x + 1, pos.y, pos.z)).name == "default:lava_flowing"
			and get_node(vector.new(pos.x, pos.y, pos.z - 1)).name == "default:lava_flowing"
			and get_node(vector.new(pos.x, pos.y, pos.z + 1)).name == "default:lava_flowing" then
				node.name = "default:lava_flowing"
				swap_node(pos, node)
			end
		end
	end
end

local abm_def = {
	label = "CH dynamic water",
	nodenames = {"default:water_source"},
	neighbors = {"default:water_flowing"},
	interval = 2,
	chance = 1,
	catch_up = false,
	action = water_func,
}
minetest.register_abm(abm_def)
abm_def = {
	label = "CH dynamic lava",
	nodenames = {"default:lava_source"},
	neighbors = {"default:lava_flowing"},
	interval = 2,
	chance = 2,
	catch_up = false,
	action = lava_func,
}
minetest.register_abm(abm_def)
