--[[
If the given item is a shape of any craftitem, returns:
craftitem, category, alternate. Otherwise returns nil.
]]
function stairsplus:analyze_shape(item)
	local ndef = minetest.registered_nodes[item]
	if not ndef or not ndef._stairsplus_recipeitem then
		return
	end
	return ndef._stairsplus_recipeitem, ndef._stairsplus_category, ndef._stairsplus_alternate
end

--[[
Gets the list of valid recipeitems.
]]
function stairsplus:get_recipeitems()
	local result = {}
	for recipeitem, _ in pairs(stairsplus.recipeitems_list) do
		table.insert(result, recipeitem)
	end
	return result
end

--[[
Determines, whether given item is a registered recipeitem.
]]
function stairsplus:is_recipeitem(item)
	if item and stairsplus.recipeitems_list[item] then
		return true
	else
		return false
	end
end

--[[
If the given combination forms a valid shape, returns its node name.
Otherwise returns nil.
]]
function stairsplus:get_shape(recipeitem, category, alternate)
	local name_parts = circular_saw.known_nodes[recipeitem or ""]
	if not name_parts then
		return nil -- invalid combination
	end
	local modname  = name_parts[1] or ""
	local material = name_parts[2] or ""
	local node_name = modname..":"..category.."_"..material..alternate
	if minetest.registered_nodes[node_name] then
		return node_name
	else
		return
	end
end
