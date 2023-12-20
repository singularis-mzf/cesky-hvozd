local def
local param2_next_color4dir = 0
local param2_next_degrotate = 0

local function get_prev_param2(param2, param2_min, param2_max)
	if param2 <= param2_min then
		return param2_max
	else
		return param2 - 1
	end
end
local function get_next_param2(param2, param2_min, param2_max)
	if param2 >= param2_max then
		return param2_min
	else
		return param2 + 1
	end
end

local testblock_tiles = {
	{name = "ch_test_4dir_1.png", backface_culling = true},
	{name = "ch_test_4dir_2.png", backface_culling = true},
	{name = "ch_test_4dir_3.png", backface_culling = true},
	{name = "ch_test_4dir_4.png", backface_culling = true},
	{name = "ch_test_4dir_5.png", backface_culling = true},
	{name = "ch_test_4dir_6.png", backface_culling = true},
}
local testblock_groups = {
	oddly_breakable_by_hand = 1,
}

local def = {
	description = "testovací blok: color4dir",
	drawtype = "normal",
	tiles = testblock_tiles,
	paramtype = "none",
	paramtype2 = "color4dir",
	groups = testblock_groups,
	palette = "ch_test_color4dir.png",
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local node = minetest.get_node(pos)
		node.param2 = param2_next_color4dir
		param2_next_color4dir = get_next_param2(param2_next_color4dir, 0, 255)
		minetest.swap_node(pos, node)
		minetest.get_meta(pos):set_string("infotext", node.param2)
	end,
	on_punch = function(pos, node, puncher, pointed_thing)
		-- increase param2
		print("DEBUG: on_punch")
		node.param2 = get_next_param2(node.param2, 0, 255)
		minetest.swap_node(pos, node)
		minetest.get_meta(pos):set_string("infotext", node.param2)
		return true
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		-- decrease param2
		print("DEBUG: on_rightclick")
		node.param2 = get_prev_param2(node.param2, 0, 255)
		minetest.swap_node(pos, node)
		minetest.get_meta(pos):set_string("infotext", node.param2)
		return itemstack
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		param2_next_color4dir = 0
	end,
}
minetest.register_node("ch_test:color4dirtest", table.copy(def))

def = {
	description = "testovací blok: degrotate",
	drawtype = "mesh",
	mesh = "ch_core_normal.obj",
	tiles = testblock_tiles,
	paramtype = "none",
	paramtype2 = "degrotate",
	groups = testblock_groups,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local node = minetest.get_node(pos)
		node.param2 = param2_next_degrotate
		param2_next_degrotate = get_next_param2(param2_next_degrotate, 0, 239)
		minetest.swap_node(pos, node)
		minetest.get_meta(pos):set_string("infotext", node.param2)
	end,
	on_punch = function(pos, node, puncher, pointed_thing)
		-- increase param2
		print("DEBUG: on_punch")
		node.param2 = get_next_param2(node.param2, 0, 239)
		minetest.swap_node(pos, node)
		minetest.get_meta(pos):set_string("infotext", node.param2)
		return true
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		-- decrease param2
		print("DEBUG: on_rightclick")
		node.param2 = get_prev_param2(node.param2, 0, 239)
		minetest.swap_node(pos, node)
		minetest.get_meta(pos):set_string("infotext", node.param2)
		return itemstack
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		param2_next_degrotate = 0
	end,
}
minetest.register_node("ch_test:test_degrotate", table.copy(def))
