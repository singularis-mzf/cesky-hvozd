
if minetest.settings: get_bool('awg.bushes', true) then
	minetest.override_item('default:blueberry_bush_leaves', {
		drawtype = 'mesh',
		use_texture_alpha = 'clip',
		mesh = 'awg_bush_leaves.obj',
		tiles = {'awg_blueberry_bush.png', 'awg_blueberry_bush_extra.png'}
	})

	minetest.override_item('default:blueberry_bush_leaves_with_berries', {
		drawtype = 'mesh',
		use_texture_alpha = 'clip',
		mesh = 'awg_bush_leaves_berries.obj',
		tiles = {'awg_blueberry_bush.png', 'awg_blueberry_bush_extra.png', 'awg_blueberry.png'}
	})

	minetest.override_item('default:bush_leaves', {
		drawtype = 'mesh',
		use_texture_alpha = 'clip',
		mesh = 'awg_bush_leaves.obj',
		tiles = {'awg_bush.png', 'awg_bush_extra.png'}
	})

	minetest.override_item('default:acacia_bush_leaves', {
		drawtype = 'mesh',
		use_texture_alpha = 'clip',
		mesh = 'awg_bush_leaves.obj',
		tiles = {'awg_acacia_bush.png', 'awg_acacia_bush_extra.png'}
	})

	minetest.override_item('default:pine_bush_needles', {
		drawtype = 'mesh',
		use_texture_alpha = 'clip',
		mesh = 'awg_bush_leaves.obj',
		tiles = {'awg_pine_bush.png', 'awg_pine_bush_extra.png'}
	})
end

local function leaves_after_place (pos, placer, itemstack, pointed_thing)
	local node = minetest.get_node(pos)
	node.param2 = math.random(0, 239)
	minetest.swap_node(pos, node)
end

if minetest.settings: get_bool('awg.tree_leaves', true) then
	minetest.override_item('default:leaves', {
		tiles = {'awg_leaves.png'},
		drawtype = 'mesh',
		use_texture_alpha = 'clip',
		mesh = 'awg_tree_leaves.obj',
		paramtype2 = 'degrotate',
		after_place_node = leaves_after_place,
		visual_scale = 0.95
	})
	
	minetest.override_item('default:acacia_leaves', {
		tiles = {'awg_acacia_leaves.png'},
		drawtype = 'mesh',
		use_texture_alpha = 'clip',
		mesh = 'awg_tree_leaves.obj',
		paramtype2 = 'degrotate',
		after_place_node = leaves_after_place,
		visual_scale = 0.95
	})
	
	minetest.override_item('default:aspen_leaves', {
		tiles = {'awg_aspen_leaves.png'},
		drawtype = 'mesh',
		use_texture_alpha = 'clip',
		mesh = 'awg_tree_leaves.obj',
		paramtype2 = 'degrotate',
		after_place_node = leaves_after_place,
		visual_scale = 0.95
	})
	
	minetest.override_item('default:pine_needles', {
		tiles = {'awg_pine_needles.png'},
		drawtype = 'mesh',
		use_texture_alpha = 'clip',
		mesh = 'awg_tree_leaves.obj',
		paramtype2 = 'degrotate',
		after_place_node = leaves_after_place,
		visual_scale = 0.95
	})
	
	minetest.override_item('default:jungleleaves', {
		tiles = {'awg_jungle_leaves.png'},
		drawtype = 'mesh',
		use_texture_alpha = 'clip',
		mesh = 'awg_tree_leaves.obj',
		paramtype2 = 'degrotate',
		after_place_node = leaves_after_place,
		visual_scale = 0.95
	})
end

if minetest.settings: get_bool('awg.tree_leaves_climbable', true) then
	minetest.override_item('default:leaves', {
		walkable = false,
		climbable = true,
		move_resistance = 4
	})
	
	minetest.override_item('default:acacia_leaves', {
		walkable = false,
		climbable = true,
		move_resistance = 4
	})
	
	minetest.override_item('default:aspen_leaves', {
		walkable = false,
		climbable = true,
		move_resistance = 4
	})
	
	minetest.override_item('default:pine_needles', {
		walkable = false,
		climbable = true,
		move_resistance = 4
	})
	
	minetest.override_item('default:jungleleaves', {
		walkable = false,
		climbable = true,
		move_resistance = 4
	})
end
