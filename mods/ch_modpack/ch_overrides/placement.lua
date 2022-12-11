-- PLACEMENT

if not minetest.get_modpath("moreblocks") then
	return
end

local function on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type == "node" then
		local old_node = minetest.get_node(pointed_thing.under)
		if minetest.get_item_group(old_node.name, "panel") == 19 then
			return minetest.item_place(itemstack, placer, pointed_thing, old_node.param2)
		end
	end
	return stairsplus.rotate_node_aux(itemstack, placer, pointed_thing)
end

local override = {on_place = on_place}

for _, recipeitem in ipairs(stairsplus:get_recipeitems()) do
	local itemname = stairsplus:get_shape(recipeitem, "panel", "_special")
	if itemname then
		minetest.override_item(itemname, override)
	end
end
