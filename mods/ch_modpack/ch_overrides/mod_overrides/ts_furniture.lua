-- COLORED CHAIRS

local bakedclay_colors = {
	black = "000000",
	blue =  "1414dc",
	brown = "391a00",
	cyan =  "14dcdc",
	dark_green = "146614",
	dark_grey = "494949",
	green =  "14dc14",
	grey =  "7f7f7f",
	magenta =  "dc14dc",
	-- natural =  "000000",
	orange =  "dc7814",
	pink =  "ff7272",
	red = "dc1414",
	violet =  "7814dc",
	white =  "ffffff",
	yellow = "dcdc14",
}

local furniture_types = {
	"kneeling_bench",
	"small_table",
	"bench",
	"table",
	"tiny_table",
	"chair",
}

local default_chair = minetest.registered_nodes["ts_furniture:default_wood_chair"]
local normal_sounds = default_chair.sounds or default.node_sound_wood_defaults()
local normal_tiles = default_chair.tiles[1]
-- {"baked_clay_" .. clay[1] ..".png"}

for color, color_code in pairs(bakedclay_colors) do
	ts_furniture.register_furniture("bakedclay:"..color, "Colored "..color, normal_tiles.."^[colorize:#"..color_code..":224^[colorize:#606060:32")
	for _, furntype in ipairs(furniture_types) do
		local name = "ts_furniture:bakedclay_"..color.."_"..furntype
		if minetest.registered_nodes[name] then
			minetest.override_item(name, {
			groups = minetest.registered_nodes["ts_furniture:default_wood_"..furntype].groups,
				sounds = normal_sounds,
			})
			ch_core.clear_crafts("ts_furniture", {{output = name}})
			minetest.register_craft({type = "shapeless", output = name, recipe = {"group:ts_"..furntype, "dye:"..color}})
		end
	end
end

-- SITTING

if not minetest.get_modpath("ts_furniture") then
	return
end

-- config {x, y, z, x_max, rotation}

local function sednout(zidle_pos, zidle_node, player, config)
	if not player or not player:is_player() or not zidle_pos or not zidle_node or not default.player_get_animation then
		return false
	end
	local player_name = player:get_player_name()
	local current_anim = default.player_get_animation(player) or ""
	local zero_vector = vector.zero()

	if current_anim == "sit" or current_anim == "sedni" then
		-- postava již sedí => zvednout se
		default.player_attached[player_name] = false
		emote.stop(player)
		player:set_eye_offset(zero_vector, zero_vector)
		return nil
	end

	local zidle_def = minetest.registered_nodes[zidle_node.name]
	if not zidle_def then
		return false -- unknown node
	end

	local paramtype2 = zidle_def.paramtype2 or "normal"
	local zidle_dir, rotation
	if paramtype2 == "facedir" then
		zidle_dir = minetest.facedir_to_dir(zidle_node.param2)
		rotation = vector.dir_to_rotation(zidle_dir)
		rotation.y = rotation.y + math.pi
	elseif paramtype2 == "colorfacedir" then
		zidle_dir = minetest.facedir_to_dir(zidle_node.param2 - minetest.strip_param2_color(zidle_node.param2, paramtype2))
		rotation = vector.dir_to_rotation(zidle_dir)
		rotation.y = rotation.y + math.pi
	elseif paramtype2 == "wallmounted" then
		zidle_dir = minetest.wallmounted_to_dir(zidle_node.param2)
		rotation = vector.dir_to_rotation(zidle_dir)
		rotation.y = rotation.y + math.pi / 2
	elseif paramtype2 == "colorwallmounted" then
		zidle_dir = minetest.wallmounted_to_dir(zidle_node.param2 - minetest.strip_param2_color(zidle_node.param2, paramtype2))
		rotation = vector.dir_to_rotation(zidle_dir)
		rotation.y = rotation.y + math.pi / 2
	else
		zidle_dir = vector.new(0, 0, 1)
	end
	if config.rotation then
		rotation.y = rotation.y + config.rotation
	end
	local sedadlo_offset = vector.new(config.x or 0, config.y or 0, config.z or 0)
	sedadlo_offset = vector.rotate(sedadlo_offset, rotation)
	if config.x and config.x_max then
		local sedadlo_offset_max = vector.new(config.x_max, config.y or 0, config.z or 0)
		sedadlo_offset_max = vector.rotate(sedadlo_offset_max, rotation)
		local line_start = vector.add(zidle_pos, sedadlo_offset)
		local line_end = vector.add(zidle_pos, sedadlo_offset_max)
		-- find the nearest point
		local line_dir = vector.subtract(line_end, line_start)
		local line_length = vector.length(line_dir)
		line_dir = vector.normalize(line_dir)
		local l = math.max(0, math.min(line_length, vector.dot(vector.subtract(player:get_pos(), line_start), line_dir)))
		sedadlo_offset = vector.add(sedadlo_offset, vector.multiply(line_dir, l))
	end
	local sit_pos = vector.add(zidle_pos, sedadlo_offset)

	-- verify position and velocity
	if vector.distance(player:get_pos(), sit_pos) > 2.0 then
		minetest.log("action", "Sit attempt failed for "..player_name.." because the distance is too large.")
		return false
	end
	local velocity = player:get_velocity()
	if vector.length(velocity) > 0.5 then
		minetest.log("action", "Sit attempt failed for "..player_name.." because the velocity is too large.")
		return false
	end
	ts_furniture.sit(sit_pos, zidle_node, player)
	player:set_look_horizontal(rotation.y)
	player:set_look_vertical(config.look_vertical or 0)
	return true
end

local summer_colors = {
	"red", "orange", "black", "yellow", "green", "blue", "violet"
}
local sitting_nodes = {
	{ name = "cottages:bench", x = 0, y = 0, z = -0.3 },
	{ name = "homedecor:deckchair", x = 0, y = -0.2, z = -0.4, look_vertical = -math.pi / 8 },
	{ name = "homedecor:deckchair_striped_blue", x = 0, y = -0.2, z = -0.4, look_vertical = -math.pi / 8 },
	{ name = "homedecor:kitchen_chair_*", name_args = {"wood", "padded"} },
	{ name = "homedecor:bench_large_1", x = -1, x_max = 0, y = 0, z = 0 },
	{ name = "homedecor:bench_large_2", x = -1, x_max = 0, y = -0.1, z = 0 },
	{ name = "homedecor:armchair" },
	{ name = "lrfurn:armchair" },
	{ name = "homedecor:office_chair_*", name_args = {"basic", "upscale"}, x = 0, y = 0.15, z = 0 },
	{ name = "lrfurn:sofa", x = -1, y = -0.05, z = 0, x_max = 0, rotation = math.pi / 2 },
	{ name = "lrfurn:longsofa", x = -1.7, y = -0.05, z = 0, x_max = 0, rotation = math.pi / 2 },
	{ name = "summer:sdraia_*", name_args = summer_colors, x = 0, y = -0.1, z = -0.2 },
}

for _, node_config in ipairs(sitting_nodes) do
	local override = {
		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			sednout(pos, node, clicker, node_config)
		end,
	}
	if node_config.name_args == nil then
		-- single node override
		if minetest.registered_nodes[node_config.name] then
			minetest.override_item(node_config.name, override)
		end
	else
		-- multi-node override
		for _, arg in ipairs(node_config.name_args) do
			local name = node_config.name:gsub("%*", arg)
			if minetest.registered_nodes[name] then
				minetest.override_item(name, override)
			end
		end
	end
end
