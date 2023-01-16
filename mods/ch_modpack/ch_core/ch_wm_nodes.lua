ch_core.open_submod("ch_wm_nodes", {lib = true})

-- CH-wallmounted nodes

local allowed_box_types = {fixed = true, leveled = true, connected = true}

local function process_node_box(box, r)
	if box == nil then
		return
	end
	if type(box) ~= "table" then
		error("Table expected, "..type(box).." found.")
	end
	local result = {}
	for k, v in pairs(box) do
		if type(v) ~= "table" then
			result[k] = v
		elseif (type(v[1]) == "table") then
			local subresult = {}
			for i, sbox in ipairs(v) do
				subresult[i] = ch_core.rotate_aabb(sbox, r)
			end
			result[k] = subresult
		else
			-- simple box
			result[k] = ch_core.rotate_aabb(v, r)
		end
	end
	return result
end

function ch_core.register_ch_wallmounted_nodes(name_prefix, def)
	if def.drawtype ~= "nodebox" or def.node_box == nil then
		error("ch_core.register_ch_wallmounted_nodes() requires node to have a node box of type fixed, leveled or connected")
	end
	if def.drop ~= nil then
		error("Custom drops for ch_wallmounted_nodes are not supported!")
	end

	local raw_name = name_prefix:gsub("^:", "")
	local ch_wallmounted_nodes = {
		[0] = raw_name.."_0",
		[1] = raw_name.."_1",
		[2] = raw_name.."_2",
		[3] = raw_name.."_3",
		[4] = raw_name.."_4",
		[5] = raw_name.."_5",
	}
	local groups = {ch_wallmounted_node = 1}
	if def.groups ~= nil then
		groups = ch_core.override_groups(def.groups, groups)
	end
	local groups_not_in_ci = groups
	if (groups_not_in_ci.not_in_creative_inventory or 0) <= 0 then
		groups_not_in_ci = ch_core.override_groups(groups_not_in_ci, {not_in_creative_inventory = 1})
	end
	for i = 0, 5 do
		local new_def = table.copy(def)
		new_def.groups = groups_not_in_ci
		if i == 0 then
			new_def.groups = groups
		end
		local nb = new_def.node_box
		new_def.node_box = process_node_box(nb)
		nb = new_def.selection_box
		if nb ~= nil then
			new_def.selection_box = process_node_box(nb)
		end
		nb = new_def.collision_box
		if nb ~= nil then
			new_def.collision_box = process_node_box(nb)
		end
		new_def.drop = ch_wallmounted_nodes[0]
		new_def.ch_wallmounted_nodes = ch_wallmounted_nodes

		minetest.register_node(ch_wallmounted_nodes[i], new_def)
	end
end

ch_core.close_submod("ch_wm_nodes")
