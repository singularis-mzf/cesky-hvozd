local def, nbox

local function degrotate_after_place_node(pos, placer, itemstack, pointed_thing)
	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	if ndef and ndef.paramtype2 == "degrotate" then
		node.param2 = math.random(0, 239)
		minetest.swap_node(pos, node)
	end
end

local function degrotate_on_rotate(pos, node, user, mode, new_param2)
	if mode == screwdriver.ROTATE_FACE then
		if node.param2 == 239 then
			node.param2 = 0
		else
			node.param2 = node.param2 + 1
		end
	else
		if node.param2 == 0 then
			node.param2 = 239
		else
			node.param2 = node.param2 - 1
		end
	end
	minetest.swap_node(pos, node)
	return true
end

-- ch_extras:czech_flag
---------------------------------------------------------------
def = {
	description = "vlajka České republiky",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.333333, 7/16, 0.5, 0.333333, 0.5}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.333333, 7/16, 0.5, 0.333333, 0.5}
	},
	-- top, bottom, right, left, back, front
	tiles = {"ch_core_white_pixel.png^[multiply:#ffffff",
             "ch_core_white_pixel.png^[multiply:#d7141a",
             "ch_extras_cz_flag.png",
             "ch_core_white_pixel.png^[multiply:#11457e",
             "ch_extras_cz_flag.png^[transformFX",
             "ch_extras_cz_flag.png",},
	inventory_image = "ch_extras_cz_flag_inv.png",
	wield_image = "ch_extras_cz_flag_inv.png",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	groups = {choppy = 2, dig_immediate = 2},
	legacy_wallmounted = true,
	sounds = default.node_sound_wood_defaults(),
}

minetest.register_node("ch_extras:czech_flag", def)
minetest.register_craft({
	output = "ch_extras:czech_flag",
	recipe = {
		{"", "dye:white", ""},
		{"dye:blue", "", ""},
		{"", "dye:red", ""},
	},
})
minetest.register_alias("ch_core:czech_flag", "ch_extras:czech_flag")

-- ch_extras:slovak_flag
---------------------------------------------------------------
def = table.copy(def)
def.description = "vlajka Slovenska"
def.tiles = {"ch_core_white_pixel.png^[multiply:#ffffff",
             "ch_core_white_pixel.png^[multiply:#d7141a",
             "ch_extras_sk_flag.png",
             "ch_extras_sk_flag.png",
             "ch_extras_sk_flag.png^[transformFX",
             "ch_extras_sk_flag.png",}
def.inventory_image = "ch_extras_sk_flag_inv.png"
def.wield_image = "ch_extras_sk_flag_inv.png"

minetest.register_node("ch_extras:slovak_flag", def)
minetest.register_craft({
	output = "ch_extras:slovak_flag",
	recipe = {
		{"dye:white", "", ""},
		{"", "dye:blue", ""},
		{"dye:red", "", ""},
	},
})
minetest.register_alias("ch_core:slovak_flag", "ch_extras:slovak_flag")

-- ch_extras:marker_{red_white,yellow_black}
---------------------------------------------------------------
local function marker_update(pos, meta)
	if not meta then
		meta = minetest.get_meta(pos)
	end
	local owner = meta:get_string("owner")
	local date = meta:get_string("date")
	local view_name
	if owner ~= "" then
		view_name = ch_core.prihlasovaci_na_zobrazovaci(owner)
	else
		view_name = "neznámá postava"
	end
	meta:set_string("infotext", string.format("%s\ntyč umístil/a: %s\n%s", minetest.pos_to_string(pos), view_name, date))
end

local function marker_after_place_node(pos, placer, itemstack, pointed_thing)
	local meta = minetest.get_meta(pos)
	local player_name = placer and placer.get_player_name and placer:get_player_name()
	local cas = ch_core.aktualni_cas()
	if player_name then
		meta:set_string("owner", player_name)
	end
	meta:set_string("date", string.format("%d. %d. %d", cas.den, cas.mesic, cas.rok))
	marker_update(pos, meta)
end

local function marker_check_for_pole(pos, node, def, pole_pos, pole_node, pole_def)
	if (0 <= pole_node.param2 and pole_node.param2 <= 3) or (20 <= pole_node.param2 and pole_node.param2 <= 23) then
		return true
	else
		return false
	end
end

def = {
	description = "značkovací tyč červeno-bílá",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-1/16, -8/16, -1/16, 1/16, 24/16, 1/16},
	},
	tiles = {
		"ch_extras_crvb_pruhy.png^[verticalframe:16:1",
		"ch_extras_crvb_pruhy.png^[verticalframe:16:5",
		"ch_extras_crvb_pruhy.png",
	},
	paramtype = "light",
	paramtype2 = "colorwallmounted",
	is_ground_content = false,
	sunlight_propagates = true,
	light_source = 3,
	groups = {oddly_breakable_by_hand = 2, ch_marker = 1},
	check_for_pole = marker_check_for_pole,
	after_place_node = marker_after_place_node,
	preserve_metadata = function(pos, oldnode, oldmeta, drops)
		for _, stack in ipairs(drops) do
			stack:get_meta():set_string("palette_index", "")
		end
	end,
}
minetest.register_node("ch_extras:marker_red_white", table.copy(def))

def.description = "značkovací tyč žluto-černá"
def.tiles = {
	"ch_extras_czl_pruhy.png^[verticalframe:16:1",
	"ch_extras_czl_pruhy.png^[verticalframe:16:5",
	"ch_extras_czl_pruhy.png",
}
minetest.register_node("ch_extras:marker_yellow_black", def)

minetest.register_lbm({
	label = "Marker updates",
	name = "ch_extras:marker_updates",
	nodenames = {"group:ch_marker"},
	run_at_every_load = true,
	action = function(pos, node)
		marker_update(pos)
	end,
})

minetest.register_craft({
	output = "ch_extras:marker_red_white 64",
	recipe = {
		{"", "default:steel_ingot", "dye:red"},
		{"", "default:steel_ingot", "dye:white"},
		{"", "default:steel_ingot", ""},
	}
})
minetest.register_craft({
	output = "ch_extras:marker_yellow_black 64",
	recipe = {
		{"", "default:steel_ingot", "dye:yellow"},
		{"", "default:steel_ingot", "dye:black"},
		{"", "default:steel_ingot", ""},
	}
})

-- ch_extras:cracks
---------------------------------------------------------------
nbox = {
	type = "fixed",
	fixed = {-0.4, -0.5, -0.4, 0.4, -7/16, 0.4},
}
def = {
	description = "praskliny (jen vodorovně)",
	drawtype = "mesh",
	mesh = "ch_extras_cracks.obj",
	selection_box = nbox,
	--[[
	-- top, bottom, right, left, back, front
	tiles = {"ch_extras_praskliny.png",
             "ch_extras_praskliny.png",
             "ch_core_empty.png",
             "ch_core_empty.png",
             "ch_core_empty.png",
             "ch_core_empty.png",
             }, ]]
	tiles = {"ch_extras_praskliny.png^[opacity:192"},
	use_texture_alpha = "blend",
	inventory_image = "ch_core_white_pixel.png^[invert:rgb^ch_extras_praskliny.png",
	wield_image = "ch_extras_praskliny.png",
	paramtype = "light",
	paramtype2 = "degrotate",
	sunlight_propagates = true,
	groups = {choppy = 2, dig_immediate = 2},
	buildable_to = true,
	floodable = true,
	walkable = false,
	after_place_node = degrotate_after_place_node,
	on_rotate = degrotate_on_rotate,
}

minetest.register_node("ch_extras:cracks", def)
minetest.register_craft({
	output = "ch_extras:cracks 16",
	recipe = {
		{"", "default:cobble"},
		{"default:cobble", ""},
	},
})

-- ch_extras:fence_hv
---------------------------------------------------------------
if minetest.get_modpath("technic") then
default.register_fence("ch_extras:fence_hv", {
	description = "výstražný plot",
	texture = "technic_hv_cable.png^[colorize:#91754d:40",
	inventory_image = "default_fence_overlay.png^technic_hv_cable.png^[colorize:#91754d:40^default_fence_overlay.png^[makealpha:255,126,126",
	wield_image = "default_fence_overlay.png^technic_hv_cable.png^[colorize:#91754d:40^default_fence_overlay.png^[makealpha:255,126,126",
	material = "technic:hv_cable",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, technic_hv_cablelike = 1},
	sounds = default.node_sound_wood_defaults(),
	check_for_pole = true,
	connects_to = {"group:fence", "group:wood", "group:tree", "group:wall", "group:technic_hv_cable"},
})

default.register_fence_rail("ch_extras:fence_rail_hv", {
	description = "výstražné zábradlí",
	texture = "technic_hv_cable.png^[colorize:#91754d:40",
	inventory_image = "default_fence_rail_overlay.png^technic_hv_cable.png^[colorize:#91754d:40^default_fence_rail_overlay.png^[makealpha:255,126,126",
	wield_image = "default_fence_rail_overlay.png^technic_hv_cable.png^[colorize:#91754d:40^default_fence_rail_overlay.png^[makealpha:255,126,126",
	material = "technic:hv_cable",
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
	sounds = default.node_sound_wood_defaults(),
})

end

-- ch_extras:spina
---------------------------------------------------------------

nbox = {
	type = "fixed",
	fixed = {-0.1, -0.5, -0.1, 0.1, -7/16, 0.1},
}
def = {
	description = "špína (jen vodorovně)",
	drawtype = "mesh",
	mesh = "ch_extras_cracks.obj",
	selection_box = nbox,
	tiles = {"ch_extras_spina.png"},
	use_texture_alpha = "blend",
	inventory_image = "ch_core_white_pixel.png^[multiply:#cccccc^ch_extras_spina.png^ch_extras_spina.png",
	wield_image = "ch_extras_spina.png",
	paramtype = "light",
	paramtype2 = "degrotate",
	sunlight_propagates = true,
	groups = {choppy = 2, dig_immediate = 2},
	buildable_to = true,
	floodable = true,
	walkable = false,
	after_place_node = degrotate_after_place_node,
	on_rotate = degrotate_on_rotate,
}

minetest.register_node("ch_extras:spina", def)
minetest.register_craft({
	output = "ch_extras:spina 16",
	recipe = {{"darkage:silt_lump"}},
})

minetest.register_craft({
	output = "ch_extras:spina 64",
	recipe = {{"default:dirt", ""}, {"default:sand", ""}},
})

-- ch_extras:railway_gravel
---------------------------------------------------------------
def = table.copy(minetest.registered_nodes["default:gravel"])
def.description = "železniční štěrk"
def.tiles = {
	"default_gravel.png^[multiply:#956338"
}
def.drop = nil
minetest.register_node("ch_extras:railway_gravel", def)

minetest.register_craft({
	output = "ch_extras:railway_gravel 2",
	type = "shapeless",
	recipe = {"default:gravel", "default:gravel", "default:iron_lump"},
})

minetest.register_craft({
	output = "ch_extras:railway_gravel",
	type = "shapeless",
	recipe = {"default:gravel", "technic:wrought_iron_dust"},
})
minetest.register_alias("ch_core:railway_gravel", "ch_extras:railway_gravel")

stairsplus:register_slabs_and_slopes("ch_extras", "railway_gravel", "ch_extras:railway_gravel", minetest.registered_nodes["ch_extras:railway_gravel"])
stairsplus:register_alias_all("ch_core", "railway_gravel", "ch_extras", "railway_gravel")

-- ch_extras:bright_gravel
---------------------------------------------------------------
def = table.copy(minetest.registered_nodes["default:gravel"])
def.description = "světlý štěrk"
def.tiles = {
	"[combine:128x128:0,0=breccia.png:64,0=breccia.png:0,64=breccia.png:64,64=breccia.png"
}
def.drop = nil
minetest.register_node("ch_extras:bright_gravel", def)

minetest.register_craft({
	output = "ch_extras:bright_gravel 4",
	type = "shapeless",
	recipe = {"default:gravel", "default:gravel", "default:silver_sand", "default:silver_sand"},
})

stairsplus:register_slabs_and_slopes("ch_extras", "bright_gravel", "ch_extras:bright_gravel", minetest.registered_nodes["ch_extras:bright_gravel"])

-- ch_extras:noise
---------------------------------------------------------------
def = {
	drawtype = "normal",
	description = "šumový blok [EXPERIMENTÁLNÍ]",
	_ch_help = "Tento blok je experimentální. Můžete ho zkoušet, ale nepoužívejte ho bez domluvy na vážně míněných stavbách.",
	tiles = {{name = "ch_extras_noise.png", animation = {
		type = "vertical_frames",
		aspect_w = 64,
		aspect_h = 64,
		length = 0.25,
	}}},
	paramtype = "light",
	paramtype2 = "color",
	palette = "unifieddyes_palette_extended.png",
	light_source = 5,
	groups = {dig_immediate = 2, ud_param2_colorable = 1},
	sounds = default.node_sound_defaults(),
	is_ground_content = false,
}

if minetest.get_modpath("unifieddyes") then
	def.on_construct = unifieddyes.on_construct
	def.on_dig = unifieddyes.on_dig
end

minetest.register_node("ch_extras:noise", def)

-- BAREVNÉ SKLO

--[[
local glass_colors = {
	black = {color = "#000000", name = "černé"},
	blue = {color = "#0000ff", name = "modré"},
	cyan = {color = "#00ffff", name = "tyrkysové"},
	dark_green = {color = "#009900", name = "tmavě zelené"},
	dark_grey = {color = "#333333", name = "tmavě šedé"},
	grey = {color = "#999999", name = "šedé"},
	green = {color = "#00ff00", name = "zelené"},
	magenta = {color = "#ff00ff", name = "purpurové"},
	orange = {color = "#ff6002", name = "oranžové"},
	red = {color = "#ff0000", name = "červené"},
	violet = {color = "#800080", name = "fialové"},
	white = {color = "#ffffff", name = "bílé"},
	yellow = {color = "#ffff00", name = "žluté"},
}
]]

local epsilon = 0.001
-- local e2 = 1 / 16

--[[
local function box(x_min, x_max, y_min, y_max, z_min, z_max)
	return {x_min or -0.5, y_min or -0.5, z_min or -0.5, x_max or 0.5, y_max or 0.5, z_max or 0.5}
end
]]

local node_box_full = {
	type = "connected",
	disconnected_top = {-0.5, 0.5 - epsilon, -0.5, 0.5, 0.5, 0.5},
	disconnected_bottom = {-0.5, -0.5, -0.5, 0.5, -0.5 + epsilon, 0.5},
	disconnected_front = {-0.5, -0.5, -0.5, 0.5, 0.5, -0.5 + epsilon},
	disconnected_left = {-0.5, -0.5, -0.5, -0.5 + epsilon, 0.5, 0.5},
	disconnected_back = {-0.5, -0.5, 0.5 - epsilon, 0.5, 0.5, 0.5},
	disconnected_right = {0.5 - epsilon, -0.5, -0.5, 0.5, 0.5, 0.5},
}
--[[
local node_box_front = { -- +Z
	type = "connected",
	disconnected_top = box(nil, nil,		0.5 - epsilon, nil,		0.5 - e2, nil),
	disconnected_bottom = box(nil, nil,		nil, -0.5 + epsilon,	0.5 - e2, nil),
	fixed = {
		box(nil, nil,		nil, nil,		0.5 - epsilon, 0.5),
		box(nil, nil,		nil, nil,		0.5 - e2, 0.5 - e2 + epsilon),
	},
	disconnected_left = box(nil, -0.5 + epsilon,  nil, nil,		0.5 - e2, nil),
	disconnected_right = box(0.5 - epsilon, nil,  nil, nil,		0.5 - e2, nil),
}
]]

local cbox_full = {
	type = "fixed",
	fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
}
--[[local cbox_front = {
	type = "fixed",
	fixed = {-0.5, -0.5, 0.5 - 1/16, 0.5, 0.5, 0.5},
} ]]
--[[
for color_name, color_def in pairs(glass_colors) do
	local image = "ch_extras_glass.png^[colorize:"..color_def.color..":128^[opacity:127"
	def = {
		drawtype = "nodebox",
		description = color_def.name.." sklo",
		tiles = {{
			name = image,
			backface_culling = true,
		}},
		use_texture_alpha = "blend",
		paramtype = "light",
		light_source = 1,
		paramtype2 = "facedir",
		is_ground_content = false,
		sunlight_propagates = true,
		inventory_image = image,
		wield_image = image,
		sounds = default.node_sound_glass_defaults(),
		groups = {cracky = 1, glass = 1, ch_colored_glass = 1},
		node_box = node_box_full,
		collision_box = cbox_full,
		selection_box = cbox_full,
		connects_to = {"group:ch_colored_glass"},
		connect_sides = {"top", "bottom", "front", "left", "back", "right"},
	}
	minetest.register_node("ch_extras:"..color_name.."_glass", def)
	minetest.register_craft({
		output = "ch_extras:"..color_name.."_glass",
		recipe = {
			{"dye:"..color_name, ""},
			{"default:glass", ""},
		},
	})

	def = {
		drawtype = "nodebox",
		description = color_def.name.." sklo (vepředu)",
		tiles = {{
			name = image,
			-- backface_culling = false,
		}},
		use_texture_alpha = "blend",
		paramtype = "light",
		light_source = 1,
		paramtype2 = "facedir",
		is_ground_content = false,
		sunlight_propagates = true,
		inventory_image = image,
		wield_image = image,
		sounds = default.node_sound_glass_defaults(),
		groups = {cracky = 1, glass = 1, ch_colored_glass = 1},
		node_box = node_box_front,
		collision_box = cbox_front,
		selection_box = cbox_front,
		connects_to = {"group:ch_colored_glass"},
		connect_sides = {"top", "bottom", "front", "left", "right"},
	}
	minetest.register_node("ch_extras:"..color_name.."_glass_front", def)
end
]]

if minetest.get_modpath("unifieddyes") then
	local inventory_image = "[combine:16x16:1,1=ch_extras_glass.png\\^[opacity\\:127\\^[resize\\:14x14"
	def = {
		description = "tónované sklo (blok, barvitelné)",
		tiles = {{
			name = "ch_extras_glass.png^[opacity:120",
			backface_culling = true,
		}},
		use_texture_alpha = "blend",

		drawtype = "glasslike",
		--[[ collision_box = cbox_full,
		selection_box = cbox_full, ]]

		paramtype = "light",
		light_source = 1,
		paramtype2 = "color",
		palette = "unifieddyes_palette_extended.png",
		is_ground_content = false,
		sunlight_propagates = true,
		inventory_image = inventory_image,
		wield_image = inventory_image,
		sounds = default.node_sound_glass_defaults(),
		groups = {
			cracky = 1, glass = 1, ch_colored_glass = 1, ch_colored_glass_full = 1,
			oddly_breakable_by_hand = 2, ud_param2_colorable = 1,
		},
		--[[ connects_to = {"group:ch_colored_glass_full"},
		connect_sides = {"top", "bottom", "front", "left", "back", "right"}, ]]
		on_dig = unifieddyes.on_dig,
	}
	minetest.register_node("ch_extras:colorable_glass", def)
	minetest.register_craft({
		output = "ch_extras:colorable_glass 6",
		recipe = {
			{"dye:red", "dye:green", "dye:blue"},
			{"building_blocks:smoothglass", "building_blocks:smoothglass", "building_blocks:smoothglass"},
			{"building_blocks:smoothglass", "building_blocks:smoothglass", "building_blocks:smoothglass"},
		},
	})

	--[[
	def = {
		drawtype = "nodebox",
		description = "sklo (barvitelné, deska)",
		tiles = {{
			name = "ch_extras_glass.png^[opacity:127",
			backface_culling = true,
		}},
		use_texture_alpha = "blend",
		paramtype = "light",
		light_source = 1,
		paramtype2 = "colorwallmounted",
		palette = "unifieddyes_palette_colorwallmounted.png",
		is_ground_content = false,
		sunlight_propagates = true,
		inventory_image = "ch_extras_glass.png^[opacity:127",
		wield_image = "ch_extras_glass.png^[opacity:127",
		sounds = default.node_sound_glass_defaults(),
		groups = {cracky = 1, glass = 1, ch_colored_glass = 1, ud_param2_colorable = 1},
		node_box = node_box_front,
		collision_box = cbox_front,
		selection_box = cbox_front,
		connects_to = {"group:ch_colored_glass"},
		connect_sides = {"top", "bottom", "front", "left", "back", "right"},

		on_dig = unifieddyes.on_dig,
		after_place_node = unifieddyes.fix_rotation,
	}
	minetest.register_node("ch_extras:colorable_glass_front", def)
	]]
end

--[[ PLAKÁTY
local box = {
		type = "fixed",
		-- fixed = {-0.5, -0.5, 7/16, 0.5, 0.5, 8/16}
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
}
def = {
	description = "plakát 1: levý díl",
	drawtype = "normal",
	-- node_box = box,
	-- selection_box = box,
	tiles = {"ch_core_plakat_yf1.png"},
	inventory_image = "ch_core_plakat_yf1.png",
	wield_image = "ch_core_plakat_yf1.png",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = false,
	groups = {choppy = 2, dig_immediate = 2},
	legacy_wallmounted = true,
	sounds = default.node_sound_leaves_defaults(),
}

minetest.register_node("ch_core:plakat_yf_left", table.copy(def))
def.description = "plakát 1: pravý díl"
def.tiles = {"ch_core_plakat_yf2.png"}
def.inventory_image = "ch_core_plakat_yf2.png"
def.weild_image = "ch_core_plakat_yf2.png"
minetest.register_node("ch_core:plakat_yf_right", table.copy(def))
]]


