print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
local slab_width = 1 / 16
local one_and_a_half = 1.5

local tile_groups = {
	solid = {
		description = "barvitelný materiál homogenní",
		tiles = {"solidcolor_white.png"},
		material_groups = {dig_immediate = 2},
		input_material = "bakedclay:white",
	},
	clay = {
		description = "barvitelná omítka",
		tiles = {"solidcolor_clay.png"},
		material_groups = {dig_immediate = 2},
		input_material = "default:clay",
	},
	cobble = {
		description = "barvitelný dlažební kámen",
		tiles = {"default_cobble.png"},
		material_groups = {cracky = 3, stone = 2},
		input_material = "default:cobble",
	},
	stoneblock = {
		description = "barvitelný kamenný blok",
		tiles = {"solidcolor_stone_block.png"},
		material_groups = {cracky = 2, stone = 1},
		input_material = "default:stone_block",
	},
	stonebrick = {
		description = "barvitelné kamenné cihly",
		tiles = {"default_stone_brick.png^[brighten"},
		material_groups = {cracky = 2, stone = 1},
		input_material = "default:stone_brick",
	},
	noise = {
		description = "barvitelný texturovaný blok",
		tiles = {"solidcolor_noise.png"},
		material_groups = {cracky = 2},
		input_material = "default:dirt",
	},
}

local shape_groups = {
	block = {
		description = "blok"
	},
	slab_down = {
		description = "deska dole (-Y)",
		node_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, slab_width - 0.5, 0.5}},
		group = "slabs",
	},
	slab_up = {
		description = "deska nahoře (+Y)",
		node_box = {type = "fixed", fixed = {-0.5, 0.5 - slab_width, -0.5, 0.5, 0.5, 0.5}},
		group = "slabs",
	},
	slab_east = {
		description = "deska na východ (+X)",
		node_box = {type = "fixed", fixed = {0.5 - slab_width, -0.5, -0.5, 0.5, 0.5, 0.5}},
		group = "slabs",
	},
	slab_west = {
		description = "deska na západ (-X)",
		node_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, slab_width - 0.5, 0.5, 0.5}},
		group = "slabs",
	},
	slab_north = {
		description = "deska na sever (+Z)",
		node_box = {type = "fixed", fixed = {-0.5, -0.5, 0.5 - slab_width, 0.5, 0.5, 0.5}},
		group = "slabs",
	},
	slab_south = {
		description = "deska na jih (-Z)",
		node_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, slab_width - 0.5}},
		group = "slabs",
	},
	slab_down_x3 = {
		description = "deska dole (-Y) trojitá západ-východ",
		node_box = {type = "fixed", fixed = {-one_and_a_half, -0.5, -0.5, one_and_a_half, slab_width - 0.5, 0.5}},
		group = "slabs3",
	},
	slab_down_z3 = {
		description = "deska dole (-Y) trojitá sever-jih",
		node_box = {type = "fixed", fixed = {-0.5, -0.5, -one_and_a_half, 0.5, slab_width - 0.5, one_and_a_half}},
		group = "slabs3",
	},
	slab_up_x3 = {
		description = "deska nahoře (+Y) trojitá západ-východ",
		node_box = {type = "fixed", fixed = {-one_and_a_half, 0.5 - slab_width, -0.5, one_and_a_half, 0.5, 0.5}},
		group = "slabs3",
	},
	slab_up_z3 = {
		description = "deska nahoře (+Y) trojitá sever-jih",
		node_box = {type = "fixed", fixed = {-0.5, 0.5 - slab_width, -one_and_a_half, 0.5, 0.5, one_and_a_half}},
		group = "slabs3",
	},
	slab_east_y3 = {
		description = "deska na východ (+X) svisle trojitá",
		node_box = {type = "fixed", fixed = {0.5 - slab_width, -one_and_a_half, -0.5, 0.5, one_and_a_half, 0.5}},
		group = "slabs3",
	},
	--[[slab_east_z3 = {
		description = "deska na východ (+X) trojitá vlevo-vpravo",
		node_box = {type = "fixed", fixed = {0.5 - slab_width, -0.5, -one_and_a_half, 0.5, 0.5, one_and_a_half}},
		group = "slabs3",
	},]]
	slab_west_y3 = {
		description = "deska na západ (-X) svisle trojitá",
		node_box = {type = "fixed", fixed = {-0.5, -one_and_a_half, -0.5, slab_width - 0.5, one_and_a_half, 0.5}},
		group = "slabs3",
	},
	--[[slab_west_z3 = {
		description = "deska na západ (-X) trojitá vlevo-vpravo",
		node_box = {type = "fixed", fixed = {-0.5, -0.5, -one_and_a_half, slab_width - 0.5, 0.5, one_and_a_half}},
		group = "slabs3",
	},
	slab_north_x3 = {
		description = "deska na sever (+Z) trojitá vlevo-vpravo",
		node_box = {type = "fixed", fixed = {-one_and_a_half, -0.5, 0.5 - slab_width, one_and_a_half, 0.5, 0.5}},
		group = "slabs3",
	},]]
	slab_north_y3 = {
		description = "deska na sever (+Z) svisle trojitá",
		node_box = {type = "fixed", fixed = {-0.5, -one_and_a_half, 0.5 - slab_width, 0.5, one_and_a_half, 0.5}},
		group = "slabs3",
	},
	slab_south_y3 = {
		description = "deska na jih (-Z) svisle trojitá",
		node_box = {type = "fixed", fixed = {-0.5, -one_and_a_half, -0.5, 0.5, one_and_a_half, slab_width - 0.5}},
		group = "slabs3",
	},
	--[[slab_south_x3 = {
		description = "deska na jih (-Z) vodorovně trojitá",
		node_box = {type = "fixed", fixed = {-one_and_a_half, -0.5, -0.5, one_and_a_half, 0.5, slab_width - 0.5}},
		group = "slabs3",
	},]]
}

local node_count = 0
local r000 = {"", "", ""}

for tile_id, tile_def in pairs(tile_groups) do
	for shape_id, shape_def in pairs(shape_groups) do
		local node_id = "solidcolor:" .. tile_id .. "_" .. shape_id
		local node_groups = tile_def.material_groups or {}
		node_groups.ud_param2_colorable = 1
		if shape_def.group then
			node_groups = table.copy(node_groups)
			node_groups["solidcolor_"..tile_id.."_"..shape_def.group] = 1
			node_groups["solidcolor_"..shape_def.group] = 1
		end
		local node_def = {
			description = tile_def.description .. " (" .. shape_def.description .. ")\n(nejde otáčet šroubovákem)",
			tiles = tile_def.tiles,
			use_texture_alpha = tile_def.use_texture_alpha,
			is_ground_content = false,
			groups = node_groups,
			sounds = default.node_sound_stone_defaults(),
			paramtype = "light",
			paramtype2 = "color",
			palette = "unifieddyes_palette_extended.png",
			on_construct = unifieddyes.on_construct,
			on_dig = unifieddyes.on_dig,
		}
		if shape_def.node_box then
			node_def.drawtype = "nodebox"
			node_def.node_box = shape_def.node_box
		end
		minetest.register_node(node_id, node_def)
		node_count = node_count + 1
	end

	if tile_def.input_material then
		minetest.register_craft({
			output = "solidcolor:"..tile_id.."_block",
			recipe = {
				{tile_def.input_material, "unifieddyes:airbrush", ""},
				{"", "", ""},
				{"", "", ""},
			},
			replacements = {{"unifieddyes:airbrush", "unifieddyes:airbrush"}},
		})
	end

	local slabs_group = "group:solidcolor_"..tile_id.."_slabs"
	local r100, r010, r001 = {slabs_group, "", ""}, {"", slabs_group, ""}, {"", "", slabs_group}
	minetest.register_craft({
		output = "solidcolor:"..tile_id.."_slab_down 8",
		recipe = {{"solidcolor:"..tile_id.."_block"}}})
	minetest.register_craft({output = "solidcolor:"..tile_id.."_slab_up 2", recipe = {{slabs_group, slabs_group, ""}, r000, r000}})
	minetest.register_craft({output = "solidcolor:"..tile_id.."_slab_down 2", recipe = {r100, r000, r010}})
	minetest.register_craft({output = "solidcolor:"..tile_id.."_slab_west 2", recipe = {r100, r010, r000}})
	minetest.register_craft({output = "solidcolor:"..tile_id.."_slab_east 2", recipe = {r100, r001, r000}})
	minetest.register_craft({output = "solidcolor:"..tile_id.."_slab_north 2", recipe = {{slabs_group, "", slabs_group}, r000, r000}})
	minetest.register_craft({output = "solidcolor:"..tile_id.."_slab_south 2", recipe = {r100, r000, r001}})
	for dir, coord in pairs({
		up = {"x3", "z3"},
		down = {"x3", "z3"},
		east = {"y3", "z3"},
		west = {"y3", "z3"},
		north = {"x3", "y3"},
		south = {"x3", "y3"},}) do
		-- join slabs to three-part slabs:
		minetest.register_craft({output = "solidcolor:"..tile_id.."_slab_"..dir.."_"..coord[1], recipe = {r000, {"solidcolor:"..tile_id.."_slab_"..dir, "solidcolor:"..tile_id.."_slab_"..dir, "solidcolor:"..tile_id.."_slab_"..dir}, r000}})
		local tmp = {"", "solidcolor:"..tile_id.."_slab_"..dir, ""}
		minetest.register_craft({output = "solidcolor:"..tile_id.."_slab_"..dir.."_"..coord[2], recipe = {tmp, tmp, tmp}})
		-- separate three-part slabs:
		minetest.register_craft({output = "solidcolor:"..tile_id.."_slab_"..dir.." 3", recipe = {{"solidcolor:"..tile_id.."_slab_"..dir.."_"..coord[1]}}})
		minetest.register_craft({output = "solidcolor:"..tile_id.."_slab_"..dir.." 3", recipe = {{"solidcolor:"..tile_id.."_slab_"..dir.."_"..coord[2]}}})
	end
end
print(string.format("[solidcolor] generated %d node types", node_count))

--[[
minetest.register_node("solidcolor:block", {
	description = "Barevný blok bez textury",
	tiles = {"solidcolor_white.png"},
	is_ground_content = false,
	groups = {dig_immediate=2,ud_param2_colorable=1},
	sounds = (default and default.node_sound_stone_defaults()),
	paramtype2 = "color",
	palette = "unifieddyes_palette_extended.png",
	on_construct = unifieddyes.on_construct,
	on_dig = unifieddyes.on_dig,
})
--]]

minetest.register_craft( {
	output = "solidcolor:solid_block",
	recipe = {
			{ "dye:white", "dye:white"},
			{ "dye:white", "dye:white"},
	},
})


--[[
unifieddyes.register_color_craft({
	output = "solidcolor:solid_block",
	palette = "extended",
	type = "shapeless",
	neutral_node = "solidcolor:solid_block",
	recipe = {
		"NEUTRAL_NODE",
		"MAIN_DYE"
	}
})
]]
print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
