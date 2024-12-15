ch_base.open_mod(minetest.get_current_modname())
local slab_width = 1 / 16
local one_and_a_half = 1.5

local tile_groups = {
	solid = {
		description = "barvitelný materiál homogenní",
		tiles = {"solidcolor_white.png"},
		material_groups = {dig_immediate = 2},
		input_material = "bakedclay:white",
		deprecated = true,
	},
	clay = {
		description = "barvitelná omítka",
		tiles = {"solidcolor_clay.png"},
		material_groups = {dig_immediate = 2},
		input_material = "default:clay",
		deprecated = true,
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
		input_material = "default:stonebrick",
	},
	noise = {
		description = "barvitelný texturovaný blok",
		tiles = {"solidcolor_noise.png"},
		material_groups = {cracky = 2},
		input_material = "default:dirt",
	},
}

local node_count = 0

for tile_id, tile_def in pairs(tile_groups) do
	local node_id = "solidcolor:" .. tile_id .. "_block"
	local node_groups = tile_def.material_groups or {}
	node_groups.ud_param2_colorable = 1
	local node_def = {
		description = tile_def.description .. " (blok)\n(nejde otáčet šroubovákem)",
		tiles = tile_def.tiles,
		use_texture_alpha = tile_def.use_texture_alpha,
		is_ground_content = false,
		groups = node_groups,
		sounds = default.node_sound_stone_defaults(),
		paramtype2 = "color",
		palette = "unifieddyes_palette_extended.png",
		on_construct = unifieddyes.on_construct,
		on_dig = unifieddyes.on_dig,
	}
	minetest.register_node(node_id, node_def)
	node_count = node_count + 1

	if not tile_def.deprecated and tile_def.input_material then
		minetest.register_craft({
			output = "solidcolor:"..tile_id.."_block",
			recipe = {
				{tile_def.input_material, "unifieddyes:airbrush", ""},
				{"", "", ""},
				{"", "", ""},
				},
			replacements = {{"unifieddyes:airbrush", "unifieddyes:airbrush"}},
		})
		minetest.register_craft({
			output = tile_def.input_material,
			recipe = {
				{"solidcolor:"..tile_id.."_block", "bucket:bucket_water", ""},
				{"", "", ""},
				{"", "", ""},
			},
			replacements = {{"bucket:bucket_water", "bucket:bucket_water"}},
		})
		minetest.register_craft({
			output = tile_def.input_material,
			recipe = {
				{"solidcolor:"..tile_id.."_block", "bucket:bucket_river_water", ""},
				{"", "", ""},
				{"", "", ""},
			},
			replacements = {{"bucket:bucket_river_water", "bucket:bucket_river_water"}},
		})
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


ch_base.close_mod(minetest.get_current_modname())
