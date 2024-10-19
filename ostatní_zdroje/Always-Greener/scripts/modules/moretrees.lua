
local leaves = {
	'moretrees:apple_tree_leaves',
	'moretrees:beech_leaves',
	'moretrees:birch_leaves',
	'moretrees:cedar_leaves',
	'moretrees:date_palm_leaves',
	'moretrees:fir_leaves',
	'moretrees:fir_leaves_bright',
	'moretrees:jungletree_leaves_red',
	'moretrees:jungletree_leaves_yellow',
	'moretrees:oak_leaves',
	'moretrees:palm_leaves',
	'moretrees:poplar_leaves',
	'moretrees:rubber_tree_leaves',
	'moretrees:sequoia_leaves',
	'moretrees:spruce_leaves',
	'moretrees:willow_leaves'
}

local function leaves_after_place (pos, placer, itemstack, pointed_thing)
	local node = minetest.get_node(pos)
	node.param2 = math.random(0, 239)
	minetest.swap_node(pos, node)
end

if minetest.settings: get_bool('awg.tree_leaves', true) then
	for i = 1, #leaves do
		local tile = minetest.registered_nodes[leaves[i]].tiles[1]
		
		minetest.override_item(leaves[i], {
			tiles = {tile .. '^[mask:awg_leaves_round_mask.png'},
			drawtype = 'mesh',
			use_texture_alpha = 'clip',
			mesh = 'awg_tree_leaves.obj',
			paramtype2 = 'degrotate',
			after_place_node = leaves_after_place,
			visual_scale = 0.95
		})
	end
end

if minetest.settings: get_bool('awg.tree_leaves_climbable', true) then
	for i = 1, #leaves do
		local tile = minetest.registered_nodes[leaves[i]].tiles[1]
		
		minetest.override_item(leaves[i], {
			walkable = false,
			climbable = true,
			move_resistance = 4
		})
	end
end
