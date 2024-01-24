local paramtypes = {
	facedir = {
		param2_max = 23,
	},
	--[[ flowingliquid = {
		param2_max = 13,
		drawtype = "flowingliquid",
		liquidtype = "flowing",
	}, ]]
	degrotate = {
		param2_max = 239,
		drawtype = "mesh",
		mesh = "ch_core_normal.obj",
	},
	wallmounted = {
		param2_max = 5,
	},
	["4dir"] = {
		param2_max = 3,
	},
	leveled = {
		drawtype = "nodebox",
		node_box = { --
			type = "leveled",
			fixed = {
				{-0.5,  -0.5, -0.5,  -0.25, 0.5, -0.25},
				{ 0.25, -0.5, -0.5,   0.5,  0.5, -0.25},
				{-0.5,  -0.5,  0.25, -0.25, 0.5,  0.5},
				{ 0.25, -0.5,  0.25,  0.5,  0.5,  0.5},
			},
		},
		param2_max = 127,
	},
	meshoptions = {
		param2_max = 63,
		drawtype = "plantlike",
	},
	color = {
		param2_max = 255,
		palette = "unifieddyes_palette_extended.png",
		ud_param2_colorable = 1,
	},
	colorfacedir = {
		param2_max = 255,
		palette = "unifieddyes_palette_mulberrys.png",
	},
	color4dir = {
		param2_max = 255,
		palette = "unifieddyes_palette_color4dir.png",
		ud_param2_colorable = 1,
	},
	colorwallmounted = {
		param2_max = 255,
		palette = "unifieddyes_palette_colorwallmounted.png",
		ud_param2_colorable = 1,
	},
	glasslikeliquidlevel = {
		param2_max = 255,
		drawtype = "glasslike_framed",
		tiles = {
			{name = "ch_core_white_pixel.png^[opacity:10", backface_culling = true},
		},
		use_texture_alpha = "blend",
		special_tiles = {
			{name = "ch_test_4dir_1.png^[opacity:200", color = "#ff3333", backface_culling = true},
			{name = "ch_test_4dir_2.png^[opacity:200", color = "#ff3333", backface_culling = true},
			{name = "ch_test_4dir_3.png^[opacity:200", color = "#ff3333", backface_culling = true},
			{name = "ch_test_4dir_4.png^[opacity:200", color = "#ff3333", backface_culling = true},
			{name = "ch_test_4dir_5.png^[opacity:200", color = "#ff3333", backface_culling = true},
			{name = "ch_test_4dir_6.png^[opacity:200", color = "#ff3333", backface_culling = true},
		},
	},
	colordegrotate = {
		param2_max = 255,
		drawtype = "mesh",
		mesh = "ch_core_normal.obj",
		palette = "unifieddyes_palette_mulberrys.png",
	},
	none = {
		param2_max = 255,
	},
}

local tiles = {
	{name = "ch_test_4dir_1.png", backface_culling = true},
	{name = "ch_test_4dir_2.png", backface_culling = true},
	{name = "ch_test_4dir_3.png", backface_culling = true},
	{name = "ch_test_4dir_4.png", backface_culling = true},
	{name = "ch_test_4dir_5.png", backface_culling = true},
	{name = "ch_test_4dir_6.png", backface_culling = true},
}
local groups = {
	oddly_breakable_by_hand = 1,
}
local paramtype_to_next_param2 = {}

local function get_prev_param2(param2, param2_min, param2_max)
	if param2 <= param2_min then return param2_max else return param2 - 1 end
end

local function get_next_param2(param2, param2_min, param2_max)
	if param2 >= param2_max then return param2_min else return param2 + 1 end
end

local function get_infotext(paramtype2, param2)
	return string.format("%d (0x%02x) <%s>", param2, param2, paramtype2)
end

local function after_place_node(pos, placer, itemstack, pointed_thing)
	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	local paramtype2 = ndef.paramtype2
	local param2_max = paramtypes[paramtype2].param2_max
	node.param2 = paramtype_to_next_param2[paramtype2]
	paramtype_to_next_param2[paramtype2] = get_next_param2(node.param2, 0, param2_max)
	minetest.swap_node(pos, node)
	minetest.get_meta(pos):set_string("infotext", get_infotext(paramtype2, node.param2))
end

local function on_punch(pos, node, puncher, pointed_thing)
	-- increase param2
	local ndef = minetest.registered_nodes[node.name]
	local paramtype2 = ndef.paramtype2
	local param2_max = paramtypes[paramtype2].param2_max
	node.param2 = get_next_param2(node.param2, 0, param2_max)
	minetest.swap_node(pos, node)
	minetest.get_meta(pos):set_string("infotext", get_infotext(paramtype2, node.param2))
end

local function on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	-- decrease param2
	local ndef = minetest.registered_nodes[node.name]
	local paramtype2 = ndef.paramtype2
	local param2_max = paramtypes[paramtype2].param2_max
	node.param2 = get_prev_param2(node.param2, 0, param2_max)
	minetest.swap_node(pos, node)
	minetest.get_meta(pos):set_string("infotext", get_infotext(paramtype2, node.param2))
end

local optional_fields = {
	"collision_box",
	"liquidtype",
	"mesh",
	"node_box",
	"palette",
	"selection_box",
	"special_tiles",
	"tiles",
	"use_texture_alpha",
}

for paramtype2, ptdef in pairs(paramtypes) do
	paramtype_to_next_param2[paramtype2] = 0
	local def = {
		description = "testovací blok: "..paramtype2,
		drawtype = ptdef.drawtype or "normal",
		tiles = tiles,
		paramtype = ptdef.paramtype or "none",
		paramtype2 = paramtype2,
		groups = groups,
		is_ground_content = false,
		after_place_node = after_place_node,
		on_punch = on_punch,
		on_rightclick = on_rightclick,
	}
	for _, field in ipairs(optional_fields) do
		if ptdef[field] ~= nil then
			def[field] = ptdef[field]
		end
	end
	if ptdef.ud_param2_colorable ~= nil then
		local groups = table.copy(groups)
		groups.ud_param2_colorable = ptdef.ud_param2_colorable
		def.groups = groups
	end
	minetest.register_node("ch_test:test_"..paramtype2, def)
end


-- Woodpiles:

local function generate_pile_textures()
	local indices = {0, 32, 64}
	local indices2 = {0,}
	local top_pile = {"[combine:96x96"}
	local side_pile = {"[combine:96x96"}

	for i = 0, 64, 32 do
		for j = 0, 64, 32 do
			table.insert(top_pile, ":"..i..","..j.."=@side\\^[resize\\:32x32")
			table.insert(side_pile, ":"..i..","..j.."=@top\\^[resize\\:32x32") -- \\^(@side\\^[resize\\:32x32\\^[transformR90\\^[mask\\:ch_test_pile_mask.png)
		end
	end
	for i = 0, 64, 32 do
		table.insert(top_pile, ":"..i..",0=ch_test_pile_overlay.png")
		table.insert(side_pile, ":"..i..",0=ch_test_pile_overlay.png")
	end
	for i = 0, 64, 32 do
		for j = 0, 64, 32 do
			table.insert(side_pile, ":"..i..","..j.."=(@side\\^[resize\\:32x32\\^[transformR90\\^[mask\\:ch_test_pile_mask.png)")
		end
	end
	table.insert(side_pile, "^[transformR90^[combine:96x96")
	for i = 0, 80, 16 do
		table.insert(side_pile, ":"..i..",0=ch_test_pile_overlay.png")
	end
	table.insert(side_pile, "^[transformR270")
	return table.concat(top_pile), table.concat(side_pile)
end

local top_pile, side_pile = generate_pile_textures()

top_pile = top_pile:gsub("@top", "default_jungletree_top.png"):gsub("@side", "default_jungletree.png")
side_pile = side_pile:gsub("@top", "default_jungletree_top.png"):gsub("@side", "default_jungletree.png")

local tile_top = {name = top_pile, backface_culling = true}
local tile_top_R90 = {name = top_pile.."^[transformR90", backface_culling = true}
local tile_top_R270 = {name = top_pile.."^[transformR270", backface_culling = true}
local tile_side = {name = side_pile, backface_culling = true}
local tile_side_R180 = {name = side_pile.."^[transformR180", backface_culling = true}

local tiles_even = {
	tile_top, -- top (+Y)
	tile_top_R90, -- bottom (-Y)
	tile_side, -- front (+X)
	tile_side, -- back (-X)
	tile_side_R180, -- right (+Z)
	tile_side_R180, -- left (-Z)
}
local tiles_odd = {
	tile_top_R270, -- top (+Y)
	tile_top_R90, -- bottom (-Y)
	tile_side, -- front (+X)
	tile_side, -- back (-X)
	tile_side_R180, -- right (+Z)
	tile_side_R180, -- left (-Z)
}
local common_def = {
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "4dir", -- => color4dir
	groups = {oddly_breakable_by_hand = 1, wood_pile = 1},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
}

for i = 1, 6 do
	local box = {
		type = "fixed",
		fixed =  {-0.5, -0.5, -0.5, 0.5, -0.5 + i / 6, 0.5},
	}
	local def = table.copy(common_def)
	def.description = "testovací hromada dřeva "..i.." [EXPERIMENTÁLNÍ]"
	if i % 2 == 0 then
		def.tiles = tiles_even
	else
		def.tiles = tiles_odd
	end
	def.node_box = box
	def.selection_box = box
	def.collision_box = box
	minetest.register_node("ch_test:test_woodpile_"..i, def)
end
