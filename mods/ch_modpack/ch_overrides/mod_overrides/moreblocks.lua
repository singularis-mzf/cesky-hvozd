if minetest.get_modpath("technic") then
	stairsplus:register_all("technic", "warning_block", "technic:warning_block", {
		description = "varovný blok",
		tiles = {"technic_hv_cable.png"},
		groups = {cracky = 1},
		sounds = default.node_sound_wood_defaults(),
	})
end

-- PLACEMENT
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
