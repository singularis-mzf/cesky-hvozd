local ifthenelse = ch_core.ifthenelse

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
		ui_generate_palette_items = 16,
	},
	colorfacedir = {
		param2_max = 255,
		palette = "unifieddyes_palette_mulberrys.png",
		ui_generate_palette_items = 16,
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
local default_groups = {
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
	local groups = table.copy(default_groups)
	if ptdef.ud_param2_colorable ~= nil then
		groups.ud_param2_colorable = ptdef.ud_param2_colorable
	end
	if ptdef.ui_generate_palette_items ~= nil then
		groups.ui_generate_palette_items = ptdef.ui_generate_palette_items
	end
	def.groups = groups
	minetest.register_node("ch_test:test_"..paramtype2, def)
end

local red_tile = {name = "ch_core_white_pixel.png", color = "#AA0000", backface_culling = true}

local def = {
	description = "test: označník [EXPERIMENTÁLNÍ]",
	drawtype = "nodebox",
	tiles = {
		red_tile,
		red_tile,
		red_tile,
		red_tile,
		{name = "[combine:128x128:16,0=ch_test_ozn.png", backface_culling = true},
		{name = "[combine:128x128:48,0=ch_test_ozn.png", backface_culling = true},
	}, -- {{name = "tiles.png", align_style = "world", backface_culling = true}},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {oddly_breakable_by_hand = 3},
	is_ground_content = false,
	visual_scale = 3,
	node_box = {
		type = "fixed",
		fixed = {-0.375/3, -1.5/3, -0.05/3, 0.375/3, 1.5/3, 0.05/3},
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.375, -1.5, -0.05, 0.375, 1.5, 0.05},
	},
	collision_box = {
		type = "fixed",
		fixed = {-0.375, -1.5, -0.05, 0.375, 1.5, 0.05},
	},
	--[[
	on_punch = function(pos, node, puncher, pointed_thing)
		node.param2 = ifthenelse(node.param2 < 239, node.param2 + 1, 0)
		minetest.swap_node(pos, node)
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		node.param2 = ifthenelse(node.param2 > 0, node.param2 - 1, 239)
		minetest.swap_node(pos, node)
	end, ]]
}

minetest.register_node("ch_test:oznacnik", def)

--[[
if minetest.get_modpath("unifieddyes") then
	local w = 1.0/16
	local s = 0.5
	local l = 1.0
	local function f(x_min, x_max, y_min, y_max, z_min, z_max)
		return {x_min, y_min, z_min, x_max, y_max, z_max}
	end
	def = {
		description = "TEST: regál [EXPERIMENTÁLNÍ]",
		drawtype = "nodebox",
		tiles = {{name = "default_wood.png^[transformR90^[colorize:#f0f0f0:192", backface_culling = true}},
		paramtype2 = "color4dir",
		palette = "unifieddyes_palette_color4dir.png",
		node_box = {
			type = "fixed",
			fixed = {
				f(-0.5, 0.5, -0.5, 1.5, 0.5 - w, 0.5), -- zadní stěna
				f(-0.5, 0.5, -0.5, -0.5 + w, s - 0.5, 0.5 - w), -- spodní stěna
				f(-0.5, 0.5, 1.5 - w, 1.5, s - 0.5, 0.5 - w), -- horní stěna
				f(-0.5, -0.5 + w, -0.5 + w, 1.5 - w, s - 0.5, 0.5 - w), -- levá stěna
				f(0.5 - w, 0.5, -0.5 + w, 1.5 - w, s - 0.5, 0.5 - w), -- pravá stěna

				f(-0.5 + w, 0.5 - w, 1.2, 1.2 + w / 2, 0.2, 0.2 + w ), -- tyč
			},
		},
		groups = {oddly_breakable_by_hand = 2, ud_param2_colorable = 1},
		is_ground_content = false,
		on_construct = function(pos)
			minetest.get_meta(pos):set_string("infotext", "TEST:\nvracení šatů a obuvi po 	vyzkoušení\n(pravý klik => dostanete zpět plnou cenu)")
			unifieddyes.on_construct(pos)
		end,
	}

	minetest.register_node("ch_test:regal", def)
end
]]

--[[
def = {
	description = "test otáčení"
}

ch_core.register_4dir_nodes("ch_test:fdt", {tiles = true, node_box = true, drop = true},
	{
		-- common definition
		drawtype = "nodebox",
		tiles = {
			{name = "ch_test_4dir_1.png", backface_culling = true},
			{name = "ch_test_4dir_2.png", backface_culling = true},
			{name = "ch_test_4dir_3.png", backface_culling = true},
			{name = "ch_test_4dir_4.png", backface_culling = true},
			{name = "ch_test_4dir_5.png", backface_culling = true},
			{name = "ch_test_4dir_6.png", backface_culling = true},
		},
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, -0.4, -0.3, -0.2},
			},
		},
		groups = {oddly_breakable_by_hand = 3},
	}
]]
