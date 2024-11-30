--[[
	## StreetsMod 2.0 ##
	Submod: streetsapi
	Optional: false
	Category: Init
]]

local S = minetest.get_translator("streets")

local register_surface_nodes = function(friendlyname, name, tiles, groups, sounds, craft, register_stairs)
	minetest.register_node(":streets:" .. name, {
		description = friendlyname,
		tiles = tiles,
		groups = groups,
		sounds = sounds
	})
	minetest.register_craft(craft)
	if minetest.get_modpath("moreblocks") and register_stairs then
		stairsplus:register_all("streets", name, "streets:" .. name, {
			description = friendlyname,
			tiles = tiles,
			groups = groups,
			sounds = sounds
		})
	end
end

local mesh_types = {
	normal = {
		normal_mesh = "sign.obj",
		center_mesh = "sign_center.obj",
		polemount_mesh = "sign_polemount.obj",
	},
	larger = {
		normal_mesh = "sign_larger.obj",
		center_mesh = "sign_center_larger.obj",
		polemount_mesh = "sign_polemount_larger.obj",
	},
	big = {
		normal_mesh = "sign_big.obj",
		center_mesh = "sign_center_big.obj",
		polemount_mesh = "sign_polemount_big.obj",
	},
	wide = {
		normal_mesh = "sign_wide.obj",
		center_mesh = "sign_center_wide.obj",
		polemount_mesh = "sign_polemount_wide.obj",
	},
	small = {
		normal_mesh = "sign_small.obj",
		center_mesh = "sign_center_small.obj",
		polemount_mesh = "sign_polemount_small.obj",
	},
}

local function register_sign_node(friendlyname, name, tiles, type, inventory_image, light_source)
	local meshes = mesh_types[type]
	if type == "minetest" then
		tiles[5] = tiles[6] .. "^[colorize:#fff^[mask:(" .. tiles[6] .. "^" .. tiles[5] .. ")"
	elseif meshes ~= nil then
		tiles[2] = tiles[1] .. "^[colorize:#fff^[mask:(" .. tiles[1] .. "^" .. tiles[2] .. ")^[transformFX"
	end
	local def = {}
	def.description = friendlyname
	def.paramtype = "light"
	def.paramtype2 = "facedir"
	def.tiles = tiles
	def.use_texture_alpha = "clip"
	def.light_source = light_source
	def.groups = { cracky = 3, not_in_creative_inventory = 1, sign = 1 }
	def.drop = "streets:" .. name
	if type == "minetest" then
		def.drawtype = "nodebox"
		def.inventory_image = tiles[6]
	elseif meshes ~= nil then
		def.drawtype = "mesh"
		def.inventory_image = tiles[1]
	end

	if inventory_image then
		def.inventory_image = inventory_image
	end

	local normal_def = def
	local center_def = table.copy(def)
	local polemount_def = table.copy(def)

	normal_def.groups = table.copy(normal_def.groups)
	normal_def.groups.not_in_creative_inventory = nil

	if meshes == nil then
		normal_def.node_box = {
			type = "fixed",
			fixed = { -1 / 2, -1 / 2, 0.5, 1 / 2, 1 / 2, 0.45 }
		}
		center_def.node_box = {
			type = "fixed",
			fixed = { -1 / 2, -1 / 2, -0.025, 1 / 2, 1 / 2, 0.025 }
		}
		polemount_def.node_box = {
			type = "fixed",
			fixed = { -1 / 2, -1 / 2, 0.825, 1 / 2, 1 / 2, 0.875 }
		}
	else
		normal_def.mesh = meshes.normal_mesh
		center_def.mesh = meshes.center_mesh
		polemount_def.mesh = meshes.polemount_mesh
	end

	normal_def.selection_box = {
		type = "fixed",
		fixed = { -1 / 2, -1 / 2, 0.5, 1 / 2, 1 / 2, 0.45 }
	}
	center_def.selection_box = {
		type = "fixed",
		fixed = { -1 / 2, -1 / 2, -0.025, 1 / 2, 1 / 2, 0.025 }
	}
	polemount_def.selection_box = {
		type = "fixed",
		fixed = { -1 / 2, -1 / 2, 0.825, 1 / 2, 1 / 2, 0.875 }
	}
	normal_def.collision_box = {
		type = "fixed",
		fixed = { -1 / 2, -1 / 2, 0.5, 1 / 2, 1 / 2, 0.45 }
	}
	center_def.collision_box = {
		type = "fixed",
		fixed = { -1 / 2, -1 / 2, -0.025, 1 / 2, 1 / 2, 0.025 }
	}
	polemount_def.collision_box = {
		type = "fixed",
		fixed = { -1 / 2, -1 / 2, 0.825, 1 / 2, 1 / 2, 0.875 }
	}

	normal_def.after_place_node = function(pos)
		local behind_pos = { x = pos.x, y = pos.y, z = pos.z }
		local node = minetest.get_node(pos)
		local param2 = node.param2
		if param2 == 0 then
			behind_pos.z = behind_pos.z + 1
		elseif param2 == 1 then
			behind_pos.x = behind_pos.x + 1
		elseif param2 == 2 then
			behind_pos.z = behind_pos.z - 1
		elseif param2 == 3 then
			behind_pos.x = behind_pos.x - 1
		end
		local behind_node = minetest.get_node(behind_pos)
		local behind_nodes = {}
		behind_nodes["streets:roadwork_traffic_barrier"] = true
		behind_nodes["streets:roadwork_traffic_barrier_top"] = true
		behind_nodes["streets:concrete_wall"] = true
		behind_nodes["streets:concrete_wall_top"] = true
		behind_nodes["technic:concrete_post"] = true
		local behind_nodes_same_parity = {}
		behind_nodes_same_parity["streets:roadwork_traffic_barrier_straight"] = true
		behind_nodes_same_parity["streets:roadwork_traffic_barrier_top_straight"] = true
		behind_nodes_same_parity["streets:concrete_wall_straight"] = true
		behind_nodes_same_parity["streets:concrete_wall_top_straight"] = true
		local under_pos = { x = pos.x, y = pos.y - 1, z = pos.z }
		local under_node = minetest.get_node(under_pos)
		local under_nodes = {}
		under_nodes["streets:roadwork_traffic_barrier"] = true
		under_nodes["streets:roadwork_traffic_barrier_straight"] = true
		under_nodes["streets:roadwork_traffic_barrier_top"] = true
		under_nodes["streets:roadwork_traffic_barrier_top_straight"] = true
		under_nodes["streets:concrete_wall"] = true
		under_nodes["streets:concrete_wall_straight"] = true
		under_nodes["streets:concrete_wall_top"] = true
		under_nodes["streets:concrete_wall_top_straight"] = true
		under_nodes["technic:concrete_post"] = true
		local upper_pos = { x = pos.x, y = pos.y + 1, z = pos.z }
		local upper_node = minetest.get_node(upper_pos)
		if (minetest.registered_nodes[behind_node.name].groups.bigpole
				and minetest.registered_nodes[behind_node.name].streets_pole_connection[param2][behind_node.param2 + 1] ~= 1)
				or minetest.registered_nodes[behind_node.name].groups.panel_pole
				or behind_nodes[behind_node.name] == true
				or (behind_nodes_same_parity[behind_node.name] and (behind_node.param2 + param2) % 2 == 0) then
			node.name = node.name .. "_polemount"
			minetest.set_node(pos, node)
		elseif (minetest.registered_nodes[under_node.name].groups.bigpole
				and minetest.registered_nodes[under_node.name].streets_pole_connection["t"][under_node.param2 + 1] == 1)
				or under_nodes[under_node.name] then
			node.name = node.name .. "_center"
			minetest.set_node(pos, node)
		elseif minetest.registered_nodes[upper_node.name].groups.bigpole then
			if minetest.registered_nodes[upper_node.name].streets_pole_connection["b"][upper_node.param2 + 1] == 1 then
				node.name = node.name .. "_center"
				minetest.set_node(pos, node)
			end
		end
	end

	minetest.register_node(":streets:" .. name, normal_def)
	minetest.register_node(":streets:" .. name .. "_center", center_def)
	minetest.register_node(":streets:" .. name .. "_polemount", polemount_def)

end

local marking_normal_selection_box = {
	type = "fixed",
	fixed = { -1 / 2, -1 / 2, -1 / 2, 1 / 2, -1 / 2 + 1 / 16, 1 / 2 }
}

local marking_normal_node_box = {
	type = "fixed",
	fixed = { -0.5, -0.5, -0.5, 0.5, -0.499, 0.5 }
}

local marking_node_variants = {
	slope_lower = {
		description = "svah, spodní polovina",
		mesh = "streets_road_marking_slope_lower.obj",
		selection_box = {
			type = "fixed",
			fixed = { -1 / 2, -5 / 4, -1 / 4, 1 / 2, -5 / 4 + 1 / 16, 1 / 4 }
		},
	},
	slope_upper = {
		description = "svah, horní polovina",
		mesh = "streets_road_marking_slope_upper.obj",
		selection_box = {
			type = "fixed",
			fixed = { -1 / 2, -3 / 4, -1 / 4, 1 / 2, -3 / 4 + 1 / 16, 1 / 4 }
		},
	},
	slope_triple = {
		description = "svah, trojitý",
		mesh = "streets_road_marking_slope_triple.obj",
		selection_box = {
			type = "fixed",
			fixed = { -1 / 2, -1, -1 / 4, 1 / 2, -1 + 1 / 16, 1 / 4 }
		},
	},
}

local marker_colors = {
	{"white", "bílý", "#ffffff"},
	{"yellow", "žlutý", "#ecb100"},
	{"black", "černý", "#000000"},
	{"red", "červený", "#ec1313"},
	{"green", "zelený", "#318c0b"},
	{"violet", "fialový", "#8c2086"},
	{"brown", "hnědý", "#5a3000"},
	{"blue", "modrý", "#01245f"},
}

local marker_ch_help_group = "str_marker"
local marker_ch_help = "Pravým klikem na rovnou podlahu, svah na dva metry či svah na tři metry nakreslí na podklad značku.\nNelze opravovat (musí se vyrobit nový).\nNefunguje na svah 45°.\nAux1+pravý klik na jakýkoliv blok pro změnu kreslené značky."
local marker_on_place = dofile(minetest.get_modpath("streets") .. "/roadmarkings_placer.lua")

local legacy_yellow_marking_nodes = {}

local register_marking_nodes = function(friendlyname, name, tex, r)
	local rotation_friendly = ""
	if r == "r90" then
		rotation_friendly = " (R90)"
		tex = tex .. "^[transformR90"
	elseif r == "r180" then
		rotation_friendly = " (R180)"
		tex = tex .. "^[transformR180"
	elseif r == "r270" then
		rotation_friendly = " (R270)"
		tex = tex .. "^[transformR270"
	end

	if r ~= "" then
		r = "_" .. r
	end
	local white_name = name:gsub("{color}", "white")
	local function on_place(itemstack, placer, pointed_thing)
		return marker_on_place(itemstack, placer, pointed_thing, white_name, r)
	end
	for color, colordef in ipairs(marker_colors) do
		local colorname, colordesc = colordef[1], colordef[2]
		local colored_tex = tex.."^[multiply:"..colordef[3]
		local toolname = "streets:tool_" .. name:gsub("{color}", colorname) .. r
		minetest.register_tool(toolname, {
			description = S("značkovač @1: ", colordesc) .. friendlyname .. rotation_friendly,
			groups = { streets_tool = color, not_repairable = 1, },
			inventory_image = colored_tex,
			wield_image = colored_tex,
			on_place = on_place,
			_ch_help = marker_ch_help,
			_ch_help_group = marker_ch_help_group,
		})
	end

	local node_name_base = "streets:mark_" .. white_name

	local common_def = {
		drawtype = "mesh",
		tiles = { { name = tex, backface_culling = true } },
		use_texture_alpha = "clip",
		paramtype = "light",
		paramtype2 = "colorfacedir",
		palette = "streets_roadmarkings_palette.png",
		groups = { snappy = 3, streets_mark = 1, oddly_breakable_by_hand = 1, not_in_creative_inventory = 1, not_blocking_trains = 1 },
		sunlight_propagates = true,
		buildable_to = true,
		floodable = true,
		walkable = false,
		inventory_image = tex,
		wield_image = tex,
		drop = "",
	}
	local def = table.copy(common_def)
	def.description = S("značka: ") .. friendlyname .. rotation_friendly
	def.tiles = { tex, "streets_transparent.png" }
	def.drawtype = "nodebox"
	def.node_box = marking_normal_node_box
	def.selection_box = marking_normal_selection_box

	minetest.register_node(node_name_base .. r, table.copy(def))
	table.insert(legacy_yellow_marking_nodes, "streets:mark_" .. name:gsub("{color}", "yellow") .. r)

	for variant_name, variant_def in pairs(marking_node_variants) do
		def = table.copy(common_def)
		def.description = S("značka: ") .. friendlyname .. rotation_friendly .. " (" .. variant_def.description .. ")"
		def.mesh = variant_def.mesh
		def.selection_box = variant_def.selection_box

		minetest.register_node(":" .. node_name_base .. "_" .. variant_name .. r, def)

		table.insert(legacy_yellow_marking_nodes, "streets:mark_" .. name:gsub("{color}", "yellow").."_"..variant_name..r)
	end
end

if streets.surfaces.surfacetypes then
	for _, v in pairs(streets.surfaces.surfacetypes) do
		register_surface_nodes(v.friendlyname, v.name, v.tiles, v.groups, v.sounds, v.craft, v.register_stairs)
	end
end
if streets.labels.labeltypes then
	for _, w in pairs(streets.labels.labeltypes) do
		register_marking_nodes(w.friendlyname, w.name, w.tex, "")
		if not streets.only_basic_stairsplus and w.rotation then
			if w.rotation.r90 then
				register_marking_nodes(w.friendlyname, w.name, w.tex, "r90")
			end
			if w.rotation.r180 then
				register_marking_nodes(w.friendlyname, w.name, w.tex, "r180")
			end
			if w.rotation.r270 then
				register_marking_nodes(w.friendlyname, w.name, w.tex, "r270")
			end
		elseif streets.only_basic_stairsplus and w.basic_rotation then
			if w.basic_rotation.r90 then
				register_marking_nodes(w.friendlyname, w.name, w.tex, "r90")
			end
			if w.basic_rotation.r180 then
				register_marking_nodes(w.friendlyname, w.name, w.tex, "r180")
			end
			if w.basic_rotation.r270 then
				register_marking_nodes(w.friendlyname, w.name, w.tex, "r270")
			end
		end
	end
end

if streets.signs.signtypes then
	for _, v in pairs(streets.signs.signtypes) do
		register_sign_node(v.friendlyname, v.name, v.tiles, v.type, v.inventory_image, v.light_source)
	end
end

for _, colordef in ipairs(marker_colors) do
	minetest.register_craft({
		output = "streets:tool_solid_"..colordef[1].."_center_line",
		recipe = {{"dye:"..colordef[1]}, {"darkage:chalk_powder"}, {"default:stick"}},
	})
	minetest.register_craft({
		output = "streets:tool_solid_"..colordef[1].."_center_line_wide",
		recipe = {{"dye:"..colordef[1], ""}, {"darkage:chalk_powder", ""}, {"default:stick", "default:stick"}},
	})
end

minetest.register_lbm({
	label = "Upgrade legacy yellow roadmarks",
	name = "streets:update_legacy_yellow_roadmarks",
	nodenames = legacy_yellow_marking_nodes,
	action = function(pos, node, dtime_s)
		node.name = node.name:gsub("yellow", "white")
		node.param2 = node.param2 + 32
		minetest.swap_node(pos, node)
	end,
})
