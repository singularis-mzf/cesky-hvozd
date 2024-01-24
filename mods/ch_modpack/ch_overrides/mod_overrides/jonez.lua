-- JONEZ
local override = {
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		default.dig_up(pos, oldnode, digger)
	end,
}

local ivy_nodes = {
	["jonez:swedish_ivy"] = {
		grows_on_type = "stone",
	},
	["ebony:creeper"] = {
		grows_on_type = "tree_or_wood",
	},
	["ebony:creeper_leaves"] = {
		grows_on_type = "tree_or_wood",
	},
	["jonez:ruin_vine"] = {
		grows_on_type = "stone",
	},
	["jonez:climbing_rose"] = {
		grows_on_type = "stone",
	},
	["jonez:ruin_creeper"] = {
		grows_on_type = "stone",
	},
}

for name, _info in pairs(ivy_nodes) do
	if minetest.registered_nodes[name] ~= nil then
		if minetest.registered_nodes[name].paramtype2 ~= "facedir" then
			error("Only facedir ivy nodes are currently supported! ("..name..")")
		end
		minetest.override_item(name, override)
	else
		minetest.log("warning", "Expected ivy node "..name.." not registered!")
	end
end

local function cmp_node(node_a, node_b)
	return node_a.name == node_b.name and node_a.param2 == node_b.param2
end

local function get_grow_ivy_function(grows_on_test)
	return function(pos, node)
		local pos_below = vector.offset(pos, 0, -1, 0)
		local node_below = minetest.get_node(pos_below)
		if minetest.get_item_group(node_below.name, "soil") == 0 then
			return
		end
		local i = 1
		local pos_above = vector.offset(pos, 0, i, 0)
		local node_above = minetest.get_node(pos_above)
		while cmp_node(node, node_above) do
			i = i + 1
			if i >= 8 then
				return
			end
			pos_above.y = pos_above.y + 1
			node_above = minetest.get_node(pos_above)
		end
		if node_above.name == "air" or (minetest.registered_nodes[node_above.name] or {}).buildable_to == true then
			local dir = minetest.facedir_to_dir(node.param2)
			local pos_beside = vector.add(pos_above, dir)
			local node_beside = minetest.get_node(pos_beside)
			if grows_on_test(node_beside) then
				minetest.set_node(pos_above, node)
			end
			return true
		end
	end
end

local function get_nodenames_by_grows_on_type(grows_on_type)
	if grows_on_type == nil then
		return
	end
	local result = {}
	for name, info in pairs(ivy_nodes) do
		if info.grows_on_type == grows_on_type and minetest.registered_nodes[name] ~= nil then
			table.insert(result, name)
		end
	end
	return result
end

local ivy_grow_interval, ivy_grow_chance = 15, 63

local abm = {
	label = "Grow ivy (on stone)",
	nodenames = get_nodenames_by_grows_on_type("stone"),
	neighbors = {"group:soil"},
	interval = ivy_grow_interval,
	chance = ivy_grow_chance,
	action = get_grow_ivy_function(function(node)
		return minetest.get_item_group(node.name, "stone") > 0
	end),
}

minetest.register_abm(abm)

abm = {
	label = "Grow ivy (on wood)",
	nodenames = get_nodenames_by_grows_on_type("tree_or_wood"),
	neighbors = {"group:soil"},
	interval = ivy_grow_interval,
	chance = ivy_grow_chance,
	action = get_grow_ivy_function(function(node)
		return minetest.get_item_group(node.name, "tree") > 0 or minetest.get_item_group(node.name, "wood") > 0
	end),
}

minetest.register_abm(abm)
