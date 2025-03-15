-- COLORABLE GLASS (colorable alternative nodes)

if not minetest.get_modpath("unifieddyes") then
	return
end

local keys_to_transfer = {
	description = false,
	color = false,
	palette = false,
	post_effect_color = false,
	post_effect_color_shaded = false,
	paramtype = false,
	paramtype2 = false,
	name = false,
	mod_origin = false,
	type = false,
	groups = false,
}

local function register_colorable_alternative_node(new_node_name, old_node_name, new_description, custom_overrides)
	local old_def = minetest.registered_nodes[old_node_name]
	if old_def == nil then
		error(old_node_name.." not defined!")
	end
	if old_def.airbrush_replacement_node ~= nil then
		error("airbrush_replacement_node of "..old_node_name.." is already set to: "..old_def.airbrush_replacement_node.."!")
	end
	if new_description == nil then
		new_description = (old_def.description or "").." (lakovaný blok)"
	end
	local new_def = {
		description = new_description,
		paramtype = "light",
		paramtype2 = "color",
		palette = "unifieddyes_palette_extended.png",
		on_construct = unifieddyes.on_construct,
	}
	for k, v in pairs(old_def) do
		if keys_to_transfer[k] ~= false and type(v) ~= "function" then
			new_def[k] = v
		end
	end
	-- handle drops:
	if new_def.drop == nil then
		new_def.drop = {
			items = {{
				items = {old_node_name},
				inherit_color = false,
			}},
		}
	end
	-- handle groups
	local groups = old_def.groups
	if groups ~= nil then
		groups = table.copy(groups)
	else
		groups = {}
	end
	groups.ud_param2_colorable = 1
	local new_groups_for_old_item = table.copy(groups)
	groups.not_in_creative_inventory = 1
	new_def.groups = groups
	new_def.description = new_description
	if custom_overrides ~= nil then
		for k, v in pairs(custom_overrides) do
			new_def[k] = v
		end
	end
	minetest.register_node(new_node_name, new_def)
	minetest.override_item(old_node_name, {
		airbrush_replacement_node = new_node_name,
		_ch_ud_palette = "unifieddyes_palette_extended.png",
		groups = new_groups_for_old_item,
	})
end

local function extract_tile_name(node_name, tile_index)
	local ndef = assert(core.registered_nodes[node_name])
	local tile = assert(ndef.tiles[tile_index])
	if type(tile) == "table" then
		return assert(tile.name)
	elseif type(tile) == "string" then
		return tile
	else
		error(node_name..".tiles["..tile_index.."]: invalid tile type: "..type(tile).."!")
	end
end

register_colorable_alternative_node("ch_overrides:glass_colorable", "default:glass", "sklo (lakované)", {
	tiles = {
		{name = extract_tile_name("default:glass", 1)},
		{name = extract_tile_name("default:glass", 2), color = "white"},
	},
})
register_colorable_alternative_node("ch_overrides:glow_glass_colorable", "moreblocks:glow_glass", "svítící sklo (lakované)", {
	tiles = {
		{name = extract_tile_name("moreblocks:glow_glass", 1)},
		{name = extract_tile_name("moreblocks:glow_glass", 2), color = "white"},
	},
})
register_colorable_alternative_node("ch_overrides:super_glow_glass_colorable", "moreblocks:super_glow_glass", "supersvítící sklo (lakované)", {
	tiles = {
		{name = extract_tile_name("moreblocks:super_glow_glass", 1)},
		{name = extract_tile_name("moreblocks:super_glow_glass", 2), color = "white"},
	},
})

register_colorable_alternative_node("ch_overrides:clean_glass_colorable", "moreblocks:clean_glass", "čisté sklo (lakované)")
register_colorable_alternative_node("ch_overrides:clean_glow_glass_colorable", "moreblocks:clean_glow_glass", "čisté svítící sklo (lakované)", {
	tiles = minetest.registered_nodes["moreblocks:clean_glass"].tiles,
})
register_colorable_alternative_node("ch_overrides:clean_super_glow_glass_colorable", "moreblocks:clean_super_glow_glass", "čisté supersvítící sklo (lakované)", {
	tiles = minetest.registered_nodes["moreblocks:clean_glass"].tiles,
})
