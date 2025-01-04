-- BAREVNÉ SKLO

local epsilon = 0.001
local e2 = 1 / 16
local def

local function gen_walldir(args)
	local result = table.copy(args)
	for k, v in pairs(args) do
		result[v] = k
	end
	return result
end

--- DATA
local walldirs = {
	[0] = gen_walldir({front = "-z", back = "+z", left = "-x", right = "+x", top = "+y", bottom = "-y"}),
	[1] = gen_walldir({front = "-x", back = "+x", left = "-z", right = "+z", top = "+y", bottom = "-y"}),
	[2] = gen_walldir({front = "+z", back = "-z", left = "+x", right = "-x", top = "+y", bottom = "-y"}),
	[3] = gen_walldir({front = "+x", back = "-x", left = "+z", right = "-z", top = "+y", bottom = "-y"}),
	[4] = gen_walldir({front = "+y", back = "-y", left = "-x", right = "+x", top = "+z", bottom = "-z"}),
	[5] = gen_walldir({front = "-y", back = "+y", left = "-z", right = "+z", top = "-x", bottom = "+x"}),
}

--[[
local walldir_to_facedir = {1, 2, 3, 13, 15}
walldir_to_facedir[0] = 0

local facedir_to_walldir = {
	1, 2, 3, -- 0 (1)
	4, 1, 5, 3, -- 4
	5, 1, 4, 3, -- 8
	0, 4, 2, 5, -- 12
	0, 5, 2, 4, -- 16
	0, 3, 2, 1, -- 20
}
facedir_to_walldir[0] = 0
if facedir_to_walldir[23] == nil then error("assertion failed") end
]]

local all_sides = {"front", "back", "left", "right", "top", "bottom"}

local function transfer_value(from_v, from_i, to_v, to_i)
	-- example:
	-- transfer_value(from_vector, "+x", to_vector, "-z")
	if #from_i ~= 2 or #to_i ~= 2 then
		error("transfer_value(): invalid input: "..dump2({from_v = from_v, from_i = from_i, to_v = to_v, to_i = to_i}))
	end
	local n = from_v[from_i:sub(2, 2)]
	if to_i:sub(1,1) ~= from_i:sub(1,1) then
		n = -n
	end
	to_v[to_i:sub(2,2)] = n
	return to_v
end

function rotate_boxes_for_walldir(walldir, boxes)
	if type(boxes) ~= "table" then
		error("Boxes must be a table!")
	end
	local walldir_def = walldirs[walldir]
	if walldir_def == nil then
		error("rotate_nodebox_for_walldir(): Invalid walldir value: "..walldir)
	end
	if type(boxes[1]) ~= "table" then
		boxes = {boxes}
	end
	local result = {}
	for i, box in ipairs(boxes) do
		local fmin, fmax = vector.new(box[1], box[2], box[3]), vector.new(box[4], box[5], box[6])
		local min, max = vector.zero(), vector.zero()
		transfer_value(fmin, "+x", min, walldir_def.right)
		transfer_value(fmin, "+y", min, walldir_def.top)
		transfer_value(fmin, "+z", min, walldir_def.back)
		transfer_value(fmax, "+x", max, walldir_def.right)
		transfer_value(fmax, "+y", max, walldir_def.top)
		transfer_value(fmax, "+z", max, walldir_def.back)
		result[i] = {min.x, min.y, min.z, max.x, max.y, max.z}
	end
	return result
end

function rotate_connected_boxes_for_walldir(walldir, node_box)
	if type(node_box) ~= "table" or node_box.type ~= "connected" then
		error("Invalid arguments: "..dump2({walldir = walldir, node_box = node_box}))
	end
	if node_box.disconnected_sides ~= nil then
		minetest.log("warning", "rotate_connected_boxes_for_walldir(): disconnected_sides not supported!")
	end
	local walldir_def = walldirs[walldir]
	if walldir_def == nil then
		error("rotate_connected_boxes_for_walldir(): Invalid walldir value: "..walldir)
	end
	local result = {
		type = "connected",
	}
	if node_box.disconnected ~= nil then
		result.disconnected = rotate_boxes_for_walldir(walldir, node_box.disconnected)
	end
	for _, side in ipairs(all_sides) do
		local new_side = walldirs[0][walldir_def[side]]
		-- local new_side = walldir_def[walldirs[0][side]]
		-- print("DEBUG: walldir "..walldir..": side "..side.." => "..walldir_def[side].." => "..new_side)
		if node_box["connect_"..side] ~= nil then
			result["connect_"..new_side] = rotate_boxes_for_walldir(walldir, node_box["connect_"..side])
		end
		if node_box["disconnected_"..side] ~= nil then
			result["disconnected_"..new_side] = rotate_boxes_for_walldir(walldir, node_box["disconnected_"..side])
		end
	end
	if node_box.fixed ~= nil then
		result.fixed = rotate_boxes_for_walldir(walldir, node_box.fixed)
	end
	return result
end

--[[
function rotate_connect_sides_for_walldir(walldir, connect_sides)
	-- print("rotate_connect_sides_for_walldir called.")
	local walldir_def = walldirs[walldir]
	if walldir_def == nil then
		error("rotate_connect_sides_for_walldir(): Invalid walldir value: "..walldir)
	end
	local result = {}
	for _, side in ipairs(connect_sides) do
		local new_side_i = walldirs[0][side]
		if new_side_i ~= nil then
			table.insert(result, walldir_def[new_side_i])
		end
	end
	-- print("will return connect_sides = "..dump2(result))
	return result
end
]]

--[[
function on_rotate_walldir(pos, node, user, mode, new_param2)
	local player_name = user and user:get_player_name()
	if not player_name then
		return false
	end
	if minetest.is_protected(pos, player_name) then
		minetest.record_protection_violation(pos, player_name)
		return false
	end
	local ndef = minetest.registered_nodes[node.name]
	local walldir_nodes = ndef and ndef.walldir_nodes
	local result_node = walldir_nodes and walldir_nodes[facedir_to_walldir[new_param2] ]
	if not result_node then
		return false
	end
	if result_node ~= node.name then
		node.name = result_node
		minetest.swap_node(pos, node)
	end
	return true
end
]]

local function box(x_min, x_max, y_min, y_max, z_min, z_max)
	local result = {x_min or -0.5, y_min or -0.5, z_min or -0.5, x_max or 0.5, y_max or 0.5, z_max or 0.5}
	if result[1] > result[4] or result[2] > result[5] or result[3] > result[6] then
		error("Invalid box generated: "..dump2({x_min = x_min, x_max = x_max, y_min = y_min, y_max = y_max, z_min = z_min, z_max = z_max, result = result}))
	end
	return result
end

-- FULL
--[[
local node_box_full = {
	type = "connected",
	disconnected_top = {-0.5, 0.5 - epsilon, -0.5, 0.5, 0.5, 0.5},
	disconnected_bottom = {-0.5, -0.5, -0.5, 0.5, -0.5 + epsilon, 0.5},
	disconnected_front = {-0.5, -0.5, -0.5, 0.5, 0.5, -0.5 + epsilon},
	disconnected_left = {-0.5, -0.5, -0.5, -0.5 + epsilon, 0.5, 0.5},
	disconnected_back = {-0.5, -0.5, 0.5 - epsilon, 0.5, 0.5, 0.5},
	disconnected_right = {0.5 - epsilon, -0.5, -0.5, 0.5, 0.5, 0.5},
}
local cbox_full = {
	type = "fixed",
	fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
}
]]

local cbox_front = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, -0.5 + e2}}
local cbox_left = {type = "fixed", fixed = {-0.5, -0.5, -0.5, -0.5 + e2, 0.5, 0.5}}
local cbox_back = {type = "fixed", fixed = {-0.5, -0.5, 0.5 - e2, 0.5, 0.5, 0.5}}
local cbox_right = {type = "fixed", fixed = {0.5 - e2, -0.5, -0.5, 0.5, 0.5, 0.5}}
local cbox_top = {type = "fixed", fixed = {-0.5, 0.5 - e2, -0.5, 0.5, 0.5, 0.5}}
local cbox_bottom = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, -0.5 + e2, 0.5}}

local node_box_front = { -- -Z
	type = "connected",
	fixed = {
		box(nil, nil,		nil, nil,		-0.5, -0.5 + epsilon),
		box(nil, nil,		nil, nil,		-0.5 + e2, -0.5 + e2 + epsilon),
	},
	disconnected_top = box(nil, nil,		0.5 - epsilon, nil,		nil, -0.5 + e2),
	disconnected_bottom = box(nil, nil,		nil, -0.5 + epsilon,	nil, -0.5 + e2),
	disconnected_left = box(nil, -0.5 + epsilon,  nil, nil,		nil, -0.5 + e2),
	disconnected_right = box(0.5 - epsilon, nil,  nil, nil,		nil, -0.5 + e2),
}

local node_box_left = rotate_connected_boxes_for_walldir(1, node_box_front)
local node_box_back = rotate_connected_boxes_for_walldir(2, node_box_front)
local node_box_right = rotate_connected_boxes_for_walldir(3, node_box_front)
local node_box_top = rotate_connected_boxes_for_walldir(4, node_box_front)
local node_box_bottom = rotate_connected_boxes_for_walldir(5, node_box_front)

local tiles_cache = {}

local function get_tiles(opacity)
	opacity = math.floor(opacity)
	if opacity < 0 then
		opacity = 0
	elseif opacity > 255 then
		opacity = 255
	end
	local result = tiles_cache[opacity]
	if result == nil then
		result = {{
			name = "ch_extras_glass.png^[opacity:"..opacity,
			backface_culling = true,
		}}
	    tiles_cache[opacity] = result
    end
    return result
end

local colorable_glass_tiles_normal = get_tiles(120)
local colorable_glass_tiles_thick = get_tiles(220)
local colorable_glass_tiles_normal_half = get_tiles(70)
local colorable_glass_tiles_thick_half = get_tiles(120)
local inventory_image_normal = "[combine:16x16:1,1=ch_extras_glass.png\\^[opacity\\:127\\^[resize\\:14x14"
local inventory_image_thick = "[combine:16x16:1,1=ch_extras_glass.png\\^[opacity\\:240\\^[resize\\:14x14"
local colorable_glass_common_groups = {
	cracky = 1, glass = 1, ch_colored_glass = 1,
	oddly_breakable_by_hand = 2, ud_param2_colorable = 1,
}

local function walldir_on_dig(pos, node, digger)
	local ndef = minetest.registered_nodes[node.name]
	local walldir_nodes = ndef and ndef.walldir_nodes
	local base_node = walldir_nodes and walldir_nodes[0]
	if base_node ~= nil then
		node.name = base_node
		minetest.swap_node(pos, node)
	end
	return unifieddyes.on_dig(pos, node, digger)
end

local walldir_nodes_normal, walldir_nodes_thick = {}, {}
for i = 0, 5 do
	walldir_nodes_normal[i] = "ch_extras:colorable_glass_front_"..i
	walldir_nodes_thick[i] = "ch_extras:colorable_glass_thick_front_"..i
end

local common_def = {
	-- common defs:
	drawtype = "glasslike",
	use_texture_alpha = "blend",
	paramtype = "light",
	light_source = 1,
	paramtype2 = "color",
	palette = "unifieddyes_palette_bright_extended.png",
	_ch_ud_palette = "unifieddyes_palette_extended.png",
	is_ground_content = false,
	sunlight_propagates = true,
	sounds = default.node_sound_glass_defaults(),
}

-- CELÉ BLOKY:
ch_core.register_nodes(common_def, {
	-- Tónované sklo (celý blok, normální tloušťka)
	["ch_extras:colorable_glass"] = {
		description = "tónované sklo (blok, barevné)",
		tiles = colorable_glass_tiles_normal,
		inventory_image = inventory_image_normal,
		wield_image = inventory_image_normal,
		groups = ch_core.assembly_groups(colorable_glass_common_groups, {ch_colored_glass_full = 1}),
		on_dig = unifieddyes.on_dig,
	},
	-- Tónované sklo (celý blok, tlustší)
	["ch_extras:colorable_glass_thick"] = {
		description = "tlustší tónované sklo (blok, barevné)",
		tiles = colorable_glass_tiles_thick,
		inventory_image = inventory_image_thick,
		wield_image = inventory_image_thick,
		groups = ch_core.assembly_groups(colorable_glass_common_groups, {ch_colored_glass_full = 1}),
		on_dig = unifieddyes.on_dig,
	},
}, {
	-- crafts:
	{
		output = "ch_extras:colorable_glass 6",
		recipe = {
			{"dye:red", "dye:green", "dye:blue"},
			{"building_blocks:smoothglass", "building_blocks:smoothglass", "building_blocks:smoothglass"},
			{"building_blocks:smoothglass", "building_blocks:smoothglass", "building_blocks:smoothglass"},
		},
	}, {
		output = "ch_extras:colorable_glass_thick",
		recipe = {
			{"ch_extras:colorable_glass", "ch_extras:colorable_glass"},
			{"", ""},
		},
	},
})

-- DESKY:
common_def.drawtype = "nodebox"
common_def.connects_to = {"group:ch_colored_glass"}
-- common_def.on_rotate = on_rotate_walldir
common_def.groups = ch_core.assembly_groups(colorable_glass_common_groups, {
	ch_colored_glass_slab = 1,
	not_blocking_trains = 1,
	not_in_creative_inventory = 1,
})

local def_0 = {
	groups = ch_core.assembly_groups(common_def.groups, {not_in_creative_inventory = 0}),
	node_box = node_box_front,
	collision_box = cbox_front,
	selection_box = cbox_front,
	connect_sides = {"top", "bottom", "left", "right"},
	-- _facedir = 0,
}
local def_1 = {
	node_box = node_box_left,
	collision_box = cbox_left,
	selection_box = cbox_left,
	connect_sides = {"top", "bottom", "front", "back"},
	-- _facedir = walldir_to_facedir[1],
}
local def_2 = {
	node_box = node_box_back,
	collision_box = cbox_back,
	selection_box = cbox_back,
	connect_sides = {"top", "bottom", "left", "right"},
	-- _facedir = walldir_to_facedir[2],
}
local def_3 = {
	node_box = node_box_right,
	collision_box = cbox_right,
	selection_box = cbox_right,
	connect_sides = {"top", "bottom", "front", "back"},
	-- _facedir = walldir_to_facedir[3],
}
local def_4 = {
	node_box = node_box_top,
	collision_box = cbox_top,
	selection_box = cbox_top,
	connect_sides = {"front", "back", "left", "right"},
	-- _facedir = walldir_to_facedir[4],
}

local def_5 = {
	node_box = node_box_bottom,
	collision_box = cbox_bottom,
	selection_box = cbox_bottom,
	connect_sides = {"front", "back", "left", "right"},
	-- _facedir = walldir_to_facedir[5],
}

-- DESKY / NORMÁLNÍ TLOUŠŤKA:
common_def.description = "tónované sklo (deska 1/16, barevné)"
common_def.tiles = colorable_glass_tiles_normal_half
common_def.inventory_image = inventory_image_normal
-- common_def.walldir_nodes = walldir_nodes_normal
common_def.drop = {items = {{items = {"ch_extras:colorable_glass_front_0"}, inherit_color = true}}}

ch_core.register_nodes(common_def,
{
	["ch_extras:colorable_glass_front_0"] = def_0,
	["ch_extras:colorable_glass_front_1"] = def_1,
	["ch_extras:colorable_glass_front_2"] = def_2,
	["ch_extras:colorable_glass_front_3"] = def_3,
	["ch_extras:colorable_glass_front_4"] = def_4,
	["ch_extras:colorable_glass_front_5"] = def_5,
}, {
	{
		output = "ch_extras:colorable_glass_front_0 15",
		recipe = {
			{"ch_extras:colorable_glass", ""},
			{"ch_extras:colorable_glass", ""},
		},
	}, {
		output = "ch_extras:colorable_glass",
		recipe = {
			{"ch_extras:colorable_glass_front_0", "ch_extras:colorable_glass_front_0", "ch_extras:colorable_glass_front_0"},
			{"ch_extras:colorable_glass_front_0", "ch_extras:colorable_glass_front_0", "ch_extras:colorable_glass_front_0"},
			{"ch_extras:colorable_glass_front_0", "ch_extras:colorable_glass_front_0", ""},
		},
	},
})

-- DESKY / VĚTŠÍ TLOUŠŤKA:
common_def.description = "tlustší tónované sklo (deska 1/16, barevné)"
common_def.tiles = colorable_glass_tiles_thick_half
common_def.inventory_image = inventory_image_thick
common_def.wield_image = inventory_image_thick
-- common_def.walldir_nodes = walldir_nodes_thick
common_def.drop = {items = {{items = {"ch_extras:colorable_glass_thick_front_0"}, inherit_color = true}}}

ch_core.register_nodes(common_def, {
	["ch_extras:colorable_glass_thick_front_0"] = def_0,
	["ch_extras:colorable_glass_thick_front_1"] = def_1,
	["ch_extras:colorable_glass_thick_front_2"] = def_2,
	["ch_extras:colorable_glass_thick_front_3"] = def_3,
	["ch_extras:colorable_glass_thick_front_4"] = def_4,
	["ch_extras:colorable_glass_thick_front_5"] = def_5,
}, {
	{
		output = "ch_extras:colorable_glass_thick_front_0 15",
		recipe = {
			{"ch_extras:colorable_glass_thick", ""},
			{"ch_extras:colorable_glass_thick", ""},
		},
	}, {
		output = "ch_extras:colorable_glass_thick",
		recipe = {
			{"ch_extras:colorable_glass_thick_front_0", "ch_extras:colorable_glass_thick_front_0", "ch_extras:colorable_glass_thick_front_0"},
			{"ch_extras:colorable_glass_thick_front_0", "ch_extras:colorable_glass_thick_front_0", "ch_extras:colorable_glass_thick_front_0"},
			{"ch_extras:colorable_glass_thick_front_0", "ch_extras:colorable_glass_thick_front_0", ""},
		},
	},
})

for _, prefix in ipairs({"ch_extras:colorable_glass_front_", "ch_extras:colorable_glass_thick_front_"}) do
	ch_core.register_nodedir_group({
		[0] = prefix.."5", -- bottom
		[1] = prefix.."5", -- bottom
		[2] = prefix.."5", -- bottom
		[3] = prefix.."5", -- bottom
		[4] = prefix.."0", -- front
		[5] = prefix.."0", -- front
		[6] = prefix.."0", -- front
		[7] = prefix.."0", -- front
		[8] = prefix.."2", -- back
		[9] = prefix.."2", -- back
		[10] = prefix.."2", -- back
		[11] = prefix.."2", -- back
		[12] = prefix.."1", -- left
		[13] = prefix.."1", -- left
		[14] = prefix.."1", -- left
		[15] = prefix.."1", -- left
		[16] = prefix.."3", -- right
		[17] = prefix.."3", -- right
		[18] = prefix.."3", -- right
		[19] = prefix.."3", -- right
		[20] = prefix.."4", -- top
		[21] = prefix.."4", -- top
		[22] = prefix.."4", -- top
		[23] = prefix.."4", -- top
	})
end
