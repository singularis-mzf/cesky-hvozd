--[[
UNDERWATER DIG
]]

local is_liquid_source = {
	["default:lava_source"] = true,
	["default:river_water_source"] = true,
	["default:water_source"] = true,
}

local function on_dignode(pos, oldnode, digger)
	local old_node_name = oldnode.name
	if is_liquid_source[old_node_name] then return end
	local pos_above = vector.offset(pos, 0, 1, 0)
	local node_above = minetest.get_node(pos_above)
	local node_name_above = node_above.name
	if is_liquid_source[node_name_above] then
		local newnode = minetest.get_node(pos)
		if newnode.name == "air" then
			minetest.set_node(pos, node_above)
			minetest.set_node(pos_above, newnode)
			print("DEBUG: nodes exchanged on dig at "..minetest.pos_to_string(pos))
		end
	end
end

minetest.register_on_dignode(on_dignode)
