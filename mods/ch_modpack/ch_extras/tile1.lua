-- ch_extras:tile1
---------------------------------------------------------------
local function tile1_after_place_node(pos, placer, itemstack, pointed_thing)
	local meta_fields = itemstack:get_meta():to_table().fields
	if meta_fields ~= nil and meta_fields.palette_index == nil then
		local node = minetest.get_node(pos)
		node.param2 = math.random(0, 255)
		minetest.swap_node(pos, node)
	end
end

local def = {
	description = "barvitelná mozaika na dlažbu",
	drawtype = "normal",
	tiles = {{name = "ch_extras_tile1.png", backface_culling = true}},
	paramtype = "light",
	paramtype2 = "color",
	palette = "unifieddyes_palette_extended.png",
	groups = {cracky = 2, ud_param2_colorable = 1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	node_placement_prediction = "",

	after_place_node = tile1_after_place_node,
	on_dig = unifieddyes.on_dig,
}
minetest.register_node("ch_extras:tile1", def)

minetest.register_craft{
	output = "ch_extras:tile1 9",
	recipe = {
		{"default:stone", "default:cobble", "default:stone"},
		{"default:cobble", "default:stone", "default:cobble"},
		{"default:stone", "default:cobble", "default:stone"},
	},
}
minetest.register_craft{
	output = "ch_extras:tile1 9",
	recipe = {
		{"default:cobble", "default:stone", "default:cobble"},
		{"default:stone", "default:cobble", "default:stone"},
		{"default:cobble", "default:stone", "default:cobble"},
	},
}

minetest.register_craft{
	output = "ch_extras:tile1", -- to remove color
	recipe = {{"ch_extras:tile1"}},
}

if minetest.get_modpath("solidcolor") then
	local plasters = {
		{name = "white", description6 = "bílé omítce", color = "white"},
		{name = "grey", description6 = "šedé omítce", color = "#ADACAA"},
	}
	local tile_top = {name = "ch_extras_tile1.png", backface_culling = true}
	local tile_no_overlay = {name = ""}

	for _, ldef in ipairs(plasters) do
		local tile_overlay = {name = "solidcolor_clay.png^[opacity:0:^[lowpart:50:solidcolor_clay.png", backface_culling = true, color = ldef.color}
		local tile_bottom = {name = "solidcolor_clay.png", backface_culling = true, color = ldef.color}

		def = {
			description = "barvitelná mozaika na "..ldef.description6.." (nejde otáčet)",
			drawtype = "normal",
			tiles = {
				tile_top, tile_bottom, tile_top, tile_top, tile_top, tile_top,
			},
			overlay_tiles = {
				tile_no_overlay, tile_no_overlay, tile_overlay, tile_overlay, tile_overlay, tile_overlay,
			},
			use_texture_alpha = "clip",
			paramtype = "light",
			paramtype2 = "color",
			palette = "unifieddyes_palette_extended.png",
			groups = {cracky = 2, ud_param2_colorable = 1},
			is_ground_content = false,
			sounds = default.node_sound_stone_defaults(),
			node_placement_prediction = "",
			after_place_node = tile1_after_place_node,
			on_dig = unifieddyes.on_dig,
		}
		minetest.register_node("ch_extras:tile1_onc_plaster_"..ldef.name, def)

		minetest.register_craft{
			output = "ch_extras:tile1_onc_plaster_"..ldef.name.." 2",
			recipe = {
				{"ch_extras:tile1", ""},
				{"solidcolor:plaster_"..ldef.name, ""},
			},
		}
		minetest.register_craft{
			output = "ch_extras:tile1_onc_plaster_"..ldef.name,
			recipe = {{"ch_extras:tile1_onc_plaster_"..ldef.name}},
		}
		minetest.register_craft{
			output = "ch_extras:tile1 2",
			recipe = {
				{"ch_extras:tile1_onc_plaster_"..ldef.name, "ch_extras:tile1_onc_plaster_"..ldef.name},
				{"", ""},
			},
			replacements = {
				{"ch_extras:tile1_onc_plaster_"..ldef.name, "solidcolor:plaster_"..ldef.name.." 2"},
			},
		}
	end
end
