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
		local panel_group = minetest.get_item_group(old_node.name, "panel")
		if panel_group == 19 or panel_group == 20 then
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
	itemname = stairsplus:get_shape(recipeitem, "panel", "_l")
	if itemname then
		minetest.override_item(itemname, override)
	end
end

-- REMOVE PATINA BY AXE
local function on_punch(pos, node, puncher, pointed_thing)
	local player_name = puncher and puncher:get_player_name()
	if player_name == nil or player_name == "" then
		return
	end
	local wielded_item = puncher:get_wielded_item()
	if wielded_item:is_empty() or minetest.get_item_group(wielded_item:get_name(), "axe") == 0 then
		return
	end
	if minetest.is_protected(pos, player_name) then
		minetest.record_protection_violation(pos, player_name)
		return
	end
	if node.name == "moreblocks:copperpatina" then
		node.name = "default:copperblock"
	else
		local recipeitem, category, alternate = stairsplus:analyze_shape(node.name)
		if recipeitem == nil then
			minetest.log("error", "Shape analysis of "..node.name.." failed!")
		end
		local new_node_name = stairsplus:get_shape("default:copperblock", category, alternate)
		if new_node_name == nil then
			minetest.log("warning", "Expected shape "..category.."/"..alternate.." of default:copperblock not found!")
			return
		end
		node.name = new_node_name
	end
	minetest.swap_node(pos, node)
	minetest.sound_play({name = "default_dig_metal", gain = 0.5}, {pos = pos}, true)
end

override = {on_punch = on_punch}
minetest.override_item("moreblocks:copperpatina", override)
for _, shapedef in ipairs(stairsplus.shapes_list) do
	local category, alternate = shapedef[1]:sub(1,-2), shapedef[2]
	local item = stairsplus:get_shape("moreblocks:copperpatina", category, alternate)
	if item ~= nil then
		minetest.override_item(item, override)
	end
end
