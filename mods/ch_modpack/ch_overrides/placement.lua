-- PLACEMENT

if not minetest.get_modpath("moreblocks") then
	return
end

local function after_place_node(pos, placer, itemstack, pointed_thing)
	if pointed_thing.type == "node" then
		local old_node = minetest.get_node(pointed_thing.under)
		local recipeitem, category, alternate = stairsplus:analyze_shape(old_node.name)
		if recipeitem and category == "panel" and alternate == "_special" then
			local new_node = minetest.get_node(pos)
			if new_node.param2 ~= old_node.param2 then
				new_node.param2 = old_node.param2
				minetest.swap_node(pos, new_node)
			end
		end
	end
end

local override = {after_place_node = after_place_node}

for _, recipeitem in ipairs(stairsplus:get_recipeitems()) do
	local itemname = stairsplus:get_shape(recipeitem, "panel", "_special")
	if itemname then
		minetest.override_item(itemname, override)
	end
end
