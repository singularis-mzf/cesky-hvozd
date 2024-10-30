-- walls/init.lua

walls = {}

local fence_collision_extra = minetest.settings:get_bool("enable_fence_tall") and 3/8 or 0

-- Load support for MT game translation.
local S = minetest.get_translator("walls")


walls.register = function(wall_name, wall_desc, wall_texture_table, wall_mat, wall_sounds)
	--make wall_texture_table paramenter backwards compatible for mods passing single texture
	if type(wall_texture_table) ~= "table" then
		wall_texture_table = { wall_texture_table }
	end
	local y_min, y_max = -0.501, 0.5
	local node_box = {
		type = "connected",
		fixed = {-2/16, -1/2, -2/16, 2/16, 1/2, 2/16},
		-- connect_bottom =
		connect_front = {-2/16, y_min, -1/2,  2/16, y_max, -2/16},
		connect_left = {-1/2, y_min, -2/16, -2/16, y_max,  2/16},
		connect_back = {-2/16, y_min,  2/16,  2/16, y_max,  1/2},
		connect_right = { 2/16, y_min, -2/16,  1/2, y_max,  2/16},
	}
	-- inventory node, and pole-type wall start item
	minetest.register_node(wall_name, {
		description = wall_desc,
		drawtype = "nodebox",
		node_box = node_box,
		connects_to = { "group:wall", "group:stone", "group:fence" },
		paramtype = "light",
		is_ground_content = false,
		tiles = wall_texture_table,
		walkable = true,
		groups = { cracky = 3, wall = 1, stone = 2 },
		sounds = wall_sounds,
	})

	-- crafting recipe
	minetest.register_craft({
		output = wall_name .. " 6",
		recipe = {
			{ "", "", "" },
			{ wall_mat, wall_mat, wall_mat},
			{ wall_mat, wall_mat, wall_mat},
		}
	})

end

walls.register("walls:cobble", S("Cobblestone Wall"), {"default_cobble.png"},
		"default:cobble", default.node_sound_stone_defaults())

walls.register("walls:mossycobble", S("Mossy Cobblestone Wall"), {"default_mossycobble.png"},
		"default:mossycobble", default.node_sound_stone_defaults())

walls.register("walls:desertcobble", S("Desert Cobblestone Wall"), {"default_desert_cobble.png"},
		"default:desert_cobble", default.node_sound_stone_defaults())

