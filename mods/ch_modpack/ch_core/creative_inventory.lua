ch_core.open_submod("creative_inventory", {lib = true})

local none = {}
local partition_defs = {
	{
		name = "empty_buckets",
		groups = none,
		items = {"bucket:bucket_empty", "bucket_wooden:bucket_empty"},
		mods = none,
	},
	{
		name = "caste_nastroje",
		groups = none,
		items = {"moreblocks:circular_saw", "unifieddyes:airbrush", "bike:painter",
                 "advtrains:trackworker", "wrench:wrench", "replacer:replacer",
                 "ch_extras:total_station", "ch_extras:jumptool", "ch_extras:teleporter_unsellable", "wine:wine_barrel",
                 "technic:mining_drill", "technic:mining_drill_mk2", "technic:mining_drill_mk3",
                 "bridger:scaffolding", "orienteering:builder_compass_1", "ch_extras:lupa", "ch_extras:periskop",
				"binoculars:binoculars"},
		mods = none,
	},
	{
		name = "kladivo_kovadlina",
		groups = none,
		items = none,
		mods = {"anvil"},
	},
	{
		name = "krumpace",
		groups = {"pickaxe"},
		items = none,
		mods = none,
	},
	{
		name = "lopaty",
		groups = {"shovel"},
		items = none,
		mods = none,
	},
	{
		name = "motyky",
		groups = {"hoe"},
		items = none,
		mods = none,
	},
	{
		name = "sekery",
		groups = {"axe"},
		items = none,
		mods = none,
	},
	{
		name = "srpy",
		groups = {"sickle"},
		items = none,
		mods = none,
	},
	{
		name = "mitrkosa",
		groups = none,
		items = {"farming:scythe_mithril"},
		mods = none,
	},
	{
		name = "trojnástroje",
		groups = {"multitool"},
		items = none,
		mods = none,
	},
	{
		name = "klice",
		groups = none,
		items = none,
		mods = {"rotate"},
	},

	{
		name = "cestbudky",
		groups = {"travelnet"},
		items = none,
		mods = none,
	},

	{
		name = "drevo",
		groups = {"wood"},
		items = none,
		mods = none,
		exclude_items = {
			"moreblocks:wood_tile",
			"moreblocks:wood_tile_center",
			"moreblocks:wood_tile_offset",
			"moreblocks:wood_tile_full",
			"pkarcs:acacia_wood_arc",
			"pkarcs:acacia_wood_inner_arc",
			"pkarcs:acacia_wood_outer_arc",
			"pkarcs:acacia_wood_with_arc",
			"pkarcs:aspen_wood_arc",
			"pkarcs:aspen_wood_inner_arc",
			"pkarcs:aspen_wood_outer_arc",
			"pkarcs:aspen_wood_with_arc",
			"pkarcs:junglewood_arc",
			"pkarcs:junglewood_inner_arc",
			"pkarcs:junglewood_outer_arc",
			"pkarcs:junglewood_with_arc",
			"pkarcs:pine_wood_arc",
			"pkarcs:pine_wood_inner_arc",
			"pkarcs:pine_wood_outer_arc",
			"pkarcs:pine_wood_with_arc",
			"pkarcs:wood_arc",
			"pkarcs:wood_inner_arc",
			"pkarcs:wood_outer_arc",
			"pkarcs:wood_with_arc",
		},
		-- not_in_mods = {"pkarcs"},
		-- not_in_mods = {"cottages", "moreblocks", "pkarcs"},
	},
	{
		name = "drevokmeny",
		groups = {"tree"},
		items = none,
		mods = none,
		exclude_items = {"cottages:water_gen", "bamboo:trunk"},
	},
	--[[
	{
		name = "barvy",
		groups = {"basic_dye"},
		items = none,
		mods = none,
	},
	{
		name = "ploty",
		groups = {"fence"},
		items = none,
		mods = none,
		exclude_items = {"technic:insulator_clip_fencepost"},
	}, ]]
	{
		name = "mesesloupky",
		groups = {"mesepost_light"},
		items = none,
		mods = none,
	},
	{
		name = "jil",
		groups = {"bakedclay"},
		items = none,
		mods = none,
	},
	{
		name = "kvetiny",
		groups = {"flower"},
		items = none,
		mods = none,
	},
	{
		name = "vlaky",
		groups = {"at_wagon"},
		items = none,
		mods = none,
	},
	{
		name = "elektrickestroje",
		groups = {"technic_machine"},
		items = none,
		mods = none,
		exclude_items = {"digtron:power_connector"},
	},
	--[[ {
		name = "obleceni",
		groups = {"clothing"},
		items = none,
		mods = none,
	},
	{
		name = "pláště",
		groups = {"cape"},
		items = none,
		mods = none,
	},
	{
		name = "technic_nn",
		groups = {"technic_lv"},
		items = none,
		mods = none,
	},
	{
		name = "technic_sn",
		groups = {"technic_mv"},
		items = none,
		mods = none,
	},
	{
		name = "technic_vn",
		groups = {"technic_hv"},
		items = none,
		mods = none,
	}, ]]
	{
		name = "listy",
		groups = {"leaves"},
		items = none,
		mods = none,
	},
	{
		name = "ingoty",
		groups = none,
		items = {"basic_materials:brass_ingot", "default:bronze_ingot", "default:tin_ingot", "default:copper_ingot", "default:gold_ingot", "default:steel_ingot",
                 "moreores:mithril_ingot", "moreores:silver_ingot", "technic:chromium_ingot", "technic:cast_iron_ingot", "technic:stainless_steel_ingot",
                 "technic:lead_ingot", "technic:carbon_steel_ingot", "technic:mixed_metal_ingot", "technic:zinc_ingot", "technic:uranium0_ingot",
                 "technic:uranium_ingot", "technic:uranium35_ingot",
                 "aloz:aluminum_ingot"},
		mods = none,
	},
	{
		name = "loziska",
		groups = none,
		items = {"default:stone_with_tin", "default:stone_with_diamond", "default:stone_with_mese", "default:stone_with_copper", "default:stone_with_coal",
                 "default:stone_with_gold", "default:stone_with_iron", "denseores:large_tin_ore", "denseores:large_diamond_ore", "denseores:large_mese_ore",
                 "denseores:large_copper_ore", "denseores:large_mithril_ore", "denseores:large_silver_ore", "denseores:large_coal_ore",
                 "denseores:large_gold_ore", "denseores:large_iron_ore", "moreores:mineral_mithril", "moreores:mineral_silver",
                 "technic:mineral_chromium", "technic:mineral_lead", "technic:mineral_sulfur", "technic:mineral_uranium", "technic:mineral_zinc",
                 "aloz:stone_with_bauxite"},
		mods = none,
	},
	{
		name = "sklo",
		groups = none,
		items = {"building_blocks:woodglass", "building_blocks:smoothglass", "cucina_vegana:mushroomlight_glass", "darkage:glow_glass",
                 "darkage:glass", "default:obsidian_glass", "default:glass", "moreblocks:clean_glass", "moreblocks:clean_super_glow_glass",
                 "moreblocks:clean_glow_glass", "moreblocks:iron_glass", "moreblocks:super_glow_glass", "moreblocks:glow_glass", "moreblocks:coal_glass"},
		mods = none,
	},
	{
		name = "kombinace",
		groups = none,
		items = none,
		mods = {"comboblock"},
	},
	{
		name = "clothing_singlecolor",
		groups = {"clothing_singlecolor", "cape_singlecolor"},
		items = none,
		mods = none,
	},
	{
		name = "clothing_stripy",
		groups = {"clothing_stripy", "cape_stripy"},
		items = none,
		mods = none,
	},
	{
		name = "clothing_squared",
		groups = {"clothing_squared", "cape_squared"},
		items = none,
		mods = none,
	},
	{
		name = "clothing_fabric_singlecolor",
		groups = {"clothing_fabric_singlecolor"},
		items = none,
		mods = none,
	},
	{
		name = "clothing_fabric_stripy",
		groups = {"clothing_fabric_stripy"},
		items = none,
		mods = none,
	},
	{
		name = "clothing_fabric_squared",
		groups = {"clothing_fabric_squared"},
		items = none,
		mods = none,
	},
	--[[
	{
		name = "trojdesky",
		groups = {"slab"},
		items = none,
		mods = none,
	},
	{
		name = "trojsvahy",
		groups = {"slope"},
		items = none,
		mods = none,
	}, ]]
	{
		name = "vypocetni_technika",
		groups = none,
		items = {
			"homedecor:alarm_clock", "homedecor:digital_clock", "homedecor:dvd_vcr",
			"homedecor:stereo", "homedecor:tv_stand",
		},
		mods = {"computers", "digiterms", "home_workshop_machines"},
	},
}

function ch_core.overridable.is_clothing(item_name)
	return minetest.get_item_group(item_name, "clothing") > 0 or
		minetest.get_item_group(item_name, "cape") > 0
end

function ch_core.overridable.is_stairsplus_shape(item_name, item_def)
	return false
end

function ch_core.overridable.is_cnc_shape(item_name, item_def)
	return false
end

function ch_core.overridable.is_other_shape(item_name, groups)
	return
		(groups.fence and item_name ~= "technic:insulator_clip_fencepost") or
		groups.gravestone or
		groups.streets_manhole or
		groups.streets_stormdrain or
		item_name:sub(1, 7) == "pkarcs:" or
		item_name:sub(1, 8) == "pillars:"
end

local function is_experimental(name, groups)
	return name:sub(1, 8) == "ch_test:" or (groups.experimental or 0) > 0
end

local function is_streets_signs(name, groups)
	return name:sub(1, 8) == "streets:" and (groups.streets_tool or groups.sign)
end

local categories = {
	{
		description = "výchozí paleta předmětů",
		condition = function(itemstring, name, def, groups, palette_index)
			local o = ch_core.overridable
			return
				not o.is_clothing(name) and
				not o.is_stairsplus_shape(name, def) and
				not o.is_cnc_shape(name, def) and
				not o.is_other_shape(name, groups) and
				not is_experimental(name, groups) and
				not is_streets_signs(name, groups) and
				(not groups.dye or groups.basic_dye) and
				not groups.platform and
				name:sub(1, 16) ~= "clothing:fabric_" and
				name:sub(1, 15) ~= "letters:letter_"
		end,
		icon = {
			{image = "ui_category_all.png^[resize:24x24", item = "unified_inventory:bag_large"},
		},
	},
	{
		description = "tvary",
		condition = function(itemstring, name, def, groups, palette_index)
			local o = ch_core.overridable
			return o.is_stairsplus_shape(name, def) or
				o.is_cnc_shape(name, def) or
				o.is_other_shape(name, groups)
		end,
		icon = {
			{image = "[combine:120x120:-4,-4=technic_cnc_bannerstone.png^[resize:20x20", item = "technic:cnc"},
		},
	},
	{
		description = "barvitelné předměty",
		condition = function(itemstring, name, def, groups, palette_index)
			return (groups.ud_param2_colorable or 0) > 0 and not is_experimental(name, groups)
		end,
		icon = {
			{image = "lrfurn_armchair_inv.png^[resize:24x24", item = "lrfurn:armchair"},
		},
	},
	{
		description = "barviva",
		condition = function(itemstring, name, def, groups, palette_index)
			return groups.dye ~= nil
		end,
		icon = {
			{image = "dye_green.png^[resize:24x24", item = "dye:green"},
		},
	},
	{
		description = "dopravní značení",
		condition = function(itemstring, name, def, groups, palette_index)
			return is_streets_signs(name, groups) or name == "streets:smallpole" or name == "streets:bigpole" or name == "streets:bigpole_short"
		end,
		icon = {
			{image = "streets_sign_eu_50.png^[resize:24x24", item = "streets:sign_eu_50"},
		},
	},
	{
		description = "jídlo a pití",
		condition = function(itemstring, name, def, groups, palette_index)
			return groups.ch_food ~= nil or groups.drink ~= nil or groups.ch_poison ~= nil
		end,
		icon = {
			{image = "ch_extras_parekvrohliku.png^[resize:24x24", item = "ch_extras:parekvrohliku"},
		},
	},
	{
		description = "látky (na šaty)",
		condition = function(itemstring, name, def, groups, palette_index)
			return name:sub(1, 16) == "clothing:fabric_"
		end,
		icon = {
			{
				image = "(clothing_fabric.png^[multiply:#f8f7f3)^(((clothing_fabric.png^clothing_inv_second_color.png)^[makealpha:0,0,0)^[multiply:#00b4e8)^[resize:24x24",
				item = "clothing:fabric_white",
			},
		},
	},
	{
		description = "oblečení a obuv",
		condition = function(itemstring, name, def, groups, palette_index)
			return ch_core.overridable.is_clothing(name)
		end,
		icon = {
			{image = "(clothing_inv_shirt.png^[multiply:#98cd61)^[resize:24x24", item = "clothing:shirt_green"},
		},
	},
	{
		description = "nástupiště",
		condition = function(itemstring, name, def, groups, palette_index)
			return (groups.platform or 0) > 0
		end,
		icon = {
			{image = "basic_materials_cement_block.png^[resize:128x128^advtrains_platform.png^[resize:16x16", item = "advtrains:platform_low_cement_block"}
		},
	},
	{
		description = "všechny předměty",
		condition = function(itemstring, name, ndef, groups, palette_index)
			return true
		end,
		icon = {
			{image = "[combine:40x40:-11,-3=letters_pattern.png\\^letters_star_overlay.png\\^[makealpha\\:255,126,126^[resize:16x16", item = "letters:letter_star"},
		},
	},
	{
		description = "experimentální předměty",
		condition = function(itemstring, name, ndef, groups, palette_index)
			return is_experimental(name, groups)
		end,
		icon = {
			{image = "ch_test_4dir_1.png^[resize:16x16", item = "ch_test:test_color"},
		},
	},
	{
		description = "test: svítící bloky",
		condition = function(itemstring, name, def, groups, palette_index)
			return minetest.registered_nodes[name] ~= nil and def.paramtype == "light" and (def.light_source or 0) > 0
		end,
		icon = {
			{image = "default_fence_pine_wood.png^default_mese_post_light_side.png^[makealpha:0,0,0^[resize:16x16", item = "default:mese_post_light_pine_wood"},
		},
	},
	{
		description = "test: nástroje",
		condition = function(itemstring, name, def, groups, palette_index)
			return minetest.registered_tools[name] ~= nil
		end,
		icon = {
			{image = "moreores_tool_mithrilpick.png^[resize:24x24", item = "moreores:pick_mithril"},
			{image = "default_tool_mesepick.png", item = "default:pick_mese"},
		},
	},
}

local function get_default_categories()
	local descriptions, icons = {}, {}
	for i, category_def in ipairs(categories) do
		descriptions[i] = category_def.description.." [0]"
		icons[i] = "unknown_item.png^[resize:16x16"
	end
	return { descriptions = descriptions, filter = {}, icons = icons }
end

local function compute_categories(itemstrings)
	local counts = {}
	local descriptions = {}
	local filter = {}
	local icons = {}
	local itemstrings_set = {}
	local registered_items = minetest.registered_items
	local string_cache = {}

	for i = 1, #categories do
		counts[i] = 0
	end

	for _, itemstring in ipairs(itemstrings) do
		if not itemstrings_set[itemstring] then
			itemstrings_set[itemstring] = true
			local stack = ItemStack(itemstring)
			local name = stack:get_name()
			local def = registered_items[name]
			if def ~= nil then
				local groups = def.groups or none
				local palette_index
				if name ~= itemstring then
					palette_index = stack:get_meta():get_int("palette_index")
				end
				local mask = ""
				for i, category_def in ipairs(categories) do
					if category_def.condition(itemstring, name, def, groups, palette_index) then
						mask = mask.."1"
						counts[i] = counts[i] + 1
					else
						mask = mask.."0"
					end
				end
				if string_cache[mask] ~= nil then
					mask = string_cache[mask]
				else
					string_cache[mask] = mask
				end
				filter[itemstring] = mask
			end
		end
	end
	for i, category_def in ipairs(categories) do
		descriptions[i] = category_def.description.." ["..counts[i].."]"
		icons[i] = "unknown_item.png^[resize:16x16"
		for _, icon_def in ipairs(category_def.icon) do
			if icon_def.item == nil or minetest.registered_items[icon_def.item] ~= nil then
				icons[i] = assert(icon_def.image)
				break
			end
		end
	end
	return { descriptions = descriptions, filter = filter, icons = icons }
end

ch_core.creative_inventory = {
	categories = get_default_categories(),
	--[[
		= {
			descriptions[index] = popisek, -- velikost #descriptions udává počet existujících kategorií
			filter = {
				[itemstring] = "00100[...]", -- maska kategorií pro každý itemstring
			},
			icons[index] = textura, -- ikona kategorie (obrázek)
		}
	]]
	items_by_order = {},
	partitions_by_name = {
		others = {
			name = "others",
			items_by_order = {},
		},
	},
	not_initialized = true,
}

local function generate_palette_itemstrings(name, paramtype2, limit, list_to_add)
	if list_to_add == nil then
		list_to_add = {}
	end
	if limit == nil then
		limit = 256
	end
	local step
	if paramtype2 == "color" then
		step = 1
	elseif paramtype2 == "colorfacedir" or paramtype2 == "colordegrotate" then
		step = 32
	elseif paramtype2 == "color4dir" then
		step = 4
	elseif paramtype2 == "colorwallmounted" then
		step = 8
	else
		table.insert(list_to_add, name)
		return list_to_add
	end
	local i = 0
	while i < limit and i * step < 256 do
		local itemstring = minetest.itemstring_with_palette(name, i * step)
		table.insert(list_to_add, itemstring)
		i = i + 1
	end
	return list_to_add
end

local function sort_items(itemstrings, group_by_mod)
	-- items is expected to be a sequence of item strings, e. g. {"default:cobble", "default:stick", ...}
	-- the original list is not changed; the new list is returned
	local counter_nil, counter_same, counter_diff = 0, 0, 0
	local itemstring_to_key = {}

	for _, itemstring in ipairs(itemstrings) do
		local stack = ItemStack(itemstring)
		local name = stack:get_name()
		local desc = stack:get_description() or ""
		local tdesc = minetest.get_translated_string("cs", desc)
		if tdesc == nil then
			counter_nil = counter_nil + 1
			tdesc = ""
		else
			if tdesc == desc then
				counter_same = counter_same + 1
			else
				counter_diff = counter_diff + 1
			end
		end
		if group_by_mod then
			local index = name:find(":")
			if index then
				tdesc = name:sub(1, index)..tdesc
			end
		end
		local palette_index = stack:get_meta():get_int("palette_index")
		if palette_index > 0 then
			tdesc = string.format("%s/%03d", tdesc, palette_index)
		end
		itemstring_to_key[itemstring] = ch_core.utf8_radici_klic(tdesc, false)
	end

	local result = table.copy(itemstrings)
	table.sort(result, function(a, b) return itemstring_to_key[a] < itemstring_to_key[b] end)
	-- minetest.log("info", "sort_items() stats: "..counter_diff.." differents, "..counter_same.." same, "..counter_nil.." nil, "..(counter_diff + counter_same + counter_nil).." total, count = "..#result..".")
	return result
end

local creative_inventory_initialized = false

-- should be called when any player logs in
function ch_core.update_creative_inventory(force_update)
	if creative_inventory_initialized and not force_update then
		minetest.log("verbose", "will not update_creative_inventory(): "..(creative_inventory_initialized and "true" or "false").." "..(force_update and "true" or "false"))
		return false
	end
	minetest.log("verbose", "will update_creative_inventory()")

	-- 1. naplň překladové tabulky
	local name_to_partition = {}
	local group_to_partition = {}
	local mod_to_partition = {}
	local partition_to_exclude_items = {others = none}
	for _ --[[order]], part_def in ipairs(partition_defs) do
		if (part_def.exclude_items or none)[1] then
			local set = {}
			partition_to_exclude_items[part_def.name] = set
			for _, name in ipairs(part_def.exclude_items) do
				set[name] = true
			end
		else
			partition_to_exclude_items[part_def.name] = none
		end
		for _, name in ipairs(part_def.items or none) do
			if name_to_partition[name] then
				minetest.log("warning", "ERROR in creative_inventory! Item "..name.." has been already set to partition "..name_to_partition[name].." while it is also set to partition "..part_def.name.."!")
			else
				name_to_partition[name] = part_def.name
			end
		end
		for _, group in ipairs(part_def.groups or none) do
			if group_to_partition[group] then
				minetest.log("warning", "ERROR in creative_inventory! Group "..group.." has been already set to partition "..group_to_partition[group].." while it is also set to partition "..part_def.name.."!")
			else
				group_to_partition[group] = part_def.name
			end
		end
		for _, mod in ipairs(part_def.mods or none) do
			if mod_to_partition[mod] then
				minetest.log("warning", "ERROR in creative_inventory! Mod "..mod.." has been already set to partition "..mod_to_partition[mod].." while it is also set to partition "..part_def.name.."!")
			else
				mod_to_partition[mod] = part_def.name
			end
		end
	end

	-- 2. projdi registrované předměty a zařaď je do příslušných oddílů
	local existing_partitions = {}

	for name, def in pairs(minetest.registered_items) do
		local groups = def.groups or none
		local nici = groups.not_in_creative_inventory
		if (def.description or "") ~= "" and (nici == nil or nici <= 0) then -- not_in_creative_inventory => skip
			local partition = "others"
			if def._ch_partition then
				partition = def._ch_partition
			elseif name_to_partition[name] then
				partition = name_to_partition[name]
			else
				local mod --[[, subname]] = name:match("^([^:]*):([^:]*)$")
				local success = false
				for group, rank in pairs(groups) do
					if rank > 0 and group_to_partition[group] and not partition_to_exclude_items[group_to_partition[group]][name] then
						partition = group_to_partition[group]
						success = true
						break
					end
				end
				if not success then
					if mod and mod_to_partition[mod] and not partition_to_exclude_items[mod_to_partition[mod]][name] then
						partition = mod_to_partition[mod]
					end
				end
			end

			if partition_to_exclude_items[partition][name] then
				partition = "others"
			end

			local partition_list = existing_partitions[partition]
			if not partition_list then
				partition_list = {}
				existing_partitions[partition] = partition_list
			end
			if groups.ui_generate_palette_items ~= nil and groups.ui_generate_palette_items > 0 then
				generate_palette_itemstrings(name, def.paramtype2, groups.ui_generate_palette_items, partition_list)
			else
				table.insert(partition_list, name)
			end
		end
	end

	-- 3. vyjmi oddíl "others" pro samostatné zpracování
	local partition_others_list = existing_partitions.others
	existing_partitions.others = nil

	-- 4. seřaď předměty v oddílech
	for partition_name, item_list in pairs(table.copy(existing_partitions)) do
		existing_partitions[partition_name] = sort_items(item_list, false)
	end
	if partition_others_list ~= nil then
		partition_others_list = sort_items(partition_others_list, true)
	end

	-- 5. seřaď oddíly
	local partitions_in_order = {}
	for _, part_def in ipairs(partition_defs) do
		local partition_list = existing_partitions[part_def.name]
		if partition_list then
			table.insert(partitions_in_order, { name = part_def.name, items_by_order = partition_list })
			existing_partitions[part_def.name] = nil
		end
	end
	local remaining_partitions = {}
	for part_name, _ in pairs(existing_partitions) do
		table.insert(remaining_partitions, part_name)
	end
	table.sort(remaining_partitions)
	for _, part_name in ipairs(remaining_partitions) do
		table.insert(partitions_in_order, { name = part_name, items_by_order = existing_partitions[part_name]})
	end
	if partition_others_list then
		table.insert(partitions_in_order, { name = "others", items_by_order = partition_others_list})
	end

	-- 6. sestav z nich partitions_by_name a items_by_order
	local partitions_by_name = {}
	local items_by_order = {}
	local partitions_by_name_count = 0

	for _, part_info in pairs(partitions_in_order) do
		partitions_by_name[part_info.name] = part_info.items_by_order
		table.insert_all(items_by_order, part_info.items_by_order)
		partitions_by_name_count = partitions_by_name_count + 1
	end

	-- 7. přidej kategorie
	local ci_categories = compute_categories(items_by_order)

	-- commit
	local new_ci = {
		categories = ci_categories,
		items_by_order = items_by_order,
		partitions_by_name = partitions_by_name,
	}
	ch_core.creative_inventory = new_ci
	minetest.log("action", "ch_core creative_inventory updated: "..#items_by_order.." items in "..partitions_by_name_count.." partitions")
	creative_inventory_initialized = true
	return new_ci
end

local ifthenelse = ch_core.ifthenelse
local function cmp_true_first(a, b)
	if a then
		return ifthenelse(b, 0, -1)
	else
		return ifthenelse(b, 1, 0)
	end
end
local function cmp_str(a, b)
	if a < b then
		return -1
	elseif a > b then
		return 1
	else
		return 0
	end
end
local function cmp_inv(f)
	return function(a, b, options)
		return -f(a, b, options)
	end
end

local comparisons = {
	{
		name = "empty_last",
		description_asc = "prázdná pole na konec",
		description_desc = "prázdná pole první",
		cmp = function(a, b)
			local count_a, count_b = a:get_count(), b:get_count()
			return cmp_true_first(count_a > 0, count_b > 0)
		end,
	},
	{
		name = "by_description",
		description_asc = "podle popisku (vzestupně)",
		description_desc = "podle popisku (sestupně)",
		cmp = function(a, b, options)
			local s_a, s_b = a:get_description(), b:get_description()
			local lang_code = options.lang_code
			if s_a ~= nil then
				if lang_code ~= nil then
					s_a = minetest.get_translated_string(lang_code, s_a)
				end
			else
				s_a = a:get_name()
			end
			if s_b ~= nil then
				if lang_code ~= nil then
					s_b = minetest.get_translated_string(lang_code, s_b)
				end
			else
				s_b = b:get_name()
			end
			return cmp_str(ch_core.utf8_radici_klic(s_a, true), ch_core.utf8_radici_klic(s_b, true))
		end,
	},
	{
		name = "by_modname",
		description_asc = "podle módu (vzestupně)",
		description_desc = "podle módu (sestupně)",
		cmp = function(a, b)
			local sa = a:get_name():match("^([^:]*):.*") or ""
			local sb = b:get_name():match("^([^:]*):.*") or ""
			return cmp_str(sa, sb)
		end,
	},
	{
		name = "by_itemname",
		description_asc = "podle technického názvu (vzestupně)",
		description_desc = "podle technického názvu (sestupně)",
		cmp = function(a, b)
			local sa = a:get_name():match("^[^:]*:(.*)$") or a:get_name()
			local sb = b:get_name():match("^[^:]*:(.*)$") or b:get_name()
			return cmp_str(sa, sb)
		end,
	},
	{
		name = "by_count",
		description_asc = "podle počtu (od nejmenšího)",
		description_desc = "podle počtu (od největšího)",
		cmp = function(a, b)
			return a:get_count() - b:get_count()
		end,
	},
	{
		name = "tools_first",
		description_asc = "nástroje první",
		description_desc = "nástroje na konec",
		cmp = function(a, b)
			return cmp_true_first(minetest.registered_tools[a:get_name()], minetest.registered_tools[b:get_name()])
		end,
	},
	{
		name = "tools_by_wear",
		description_asc = "nástroje podle opotřebení (od nejmenšího)",
		description_desc = "nástroje podle opotřebení (od největšího)",
		cmp = function(a, b)
			if minetest.registered_tools[a:get_name()] and minetest.registered_tools[b:get_name()]then
				return a:get_wear() - b:get_wear()
			else
				return 0
			end
		end,
	},
	{
		name = "books_by_ick",
		description_asc = "knihy podle IČK (vzestupně)",
		description_desc = "knihy podle IČK (sestupně)",
		cmp = function(a, b)
			if a:is_empty() or b:is_empty() then
				return 0
			end
			local a_name, b_name = a:get_name(), b:get_name()
			if minetest.get_item_group(a_name, "book") == 0 or minetest.get_item_group(b_name, "book") == 0 then
				return 0
			end
			local a_meta, b_meta = a:get_meta(), b:get_meta()
			local a_ick = ("0000000000000000"..a_meta:get_string("ick")):sub(-16, -1)
			local b_ick = ("0000000000000000"..b_meta:get_string("ick")):sub(-16, -1)
			return cmp_str(a_ick, b_ick)
		end,
	},
	{
		name = "books_first",
		description_asc = "knihy první",
		description_desc = "knihy na konec",
		cmp = function(a, b)
			return cmp_true_first(not a:is_empty() and minetest.get_item_group(a:get_name(), "book") ~= 0, not b:is_empty() and minetest.get_item_group(b:get_name(), "book") ~= 0)
		end,
	},
	{
		name = "books_by_author",
		description_asc = "knihy podle autorství (vzestupně)",
		description_desc = "knihy podle autorství (sestupně)",
		cmp = function(a, b)
			if a:is_empty() or minetest.get_item_group(a:get_name(), "book") == 0 or b:is_empty() or minetest.get_item_group(b:get_name(), "book") == 0 then
				return 0
			end
			return cmp_str(ch_core.utf8_radici_klic(a:get_meta():get_string("author"), false), ch_core.utf8_radici_klic(b:get_meta():get_string("author"), false))
		end,
	},
	{
		name = "books_by_title",
		description_asc = "knihy podle názvu (vzestupně)",
		description_desc = "knihy podle názvu (sestupně)",
		cmp = function(a, b)
			if a:is_empty() or minetest.get_item_group(a:get_name(), "book") == 0 or b:is_empty() or minetest.get_item_group(b:get_name(), "book") == 0 then
				return 0
			end
			return cmp_str(ch_core.utf8_radici_klic(a:get_meta():get_string("title"), false), ch_core.utf8_radici_klic(b:get_meta():get_string("title"), false))
		end,
	},
}

local name_to_comparison_index = {}
local choices = {}
for i, cmp_def in ipairs(comparisons) do
	name_to_comparison_index[cmp_def.name] = i
	if cmp_def.description_asc ~= nil then
		table.insert(choices, {name = cmp_def.name, desc = false, description = cmp_def.description_asc})
	end
	if cmp_def.description_desc ~= nil then
		table.insert(choices, {name = cmp_def.name, desc = true, description = cmp_def.description_desc})
	end
end

function ch_core.sort_itemstacks(stacks, order_types, lang_code)
	local cmps = {}
	for _, otype in ipairs(order_types) do
		local cmp_index = name_to_comparison_index[otype.name]
		if cmp_index == nil then
			error("Invalid order type '"..otype.name.."'!")
		end
		if otype.desc then
			table.insert(cmps, cmp_inv(comparisons[cmp_index].cmp))
		else
			table.insert(cmps, comparisons[cmp_index].cmp)
		end
	end
	local options = {lang_code = lang_code}
	table.sort(stacks, function(a, b)
			local result
			for i = 1, #cmps do
				result = cmps[i](a, b, options)
				if result < 0 then
					return true
				elseif result > 0 then
					return false
				end
			end
			return 0
		end)
end

--[[
Příklad:
	local stacks = inv:get_list("main")
	ch_core.sort_itemstacks(stacks, {
		{name = "empty_last"},
		{name = "tools_first", desc = true},
		{name = "by_description"},
		{name = "by_modname"},
		{name = "by_itemname"},
		{name = "by_count", desc = true},
		}, ch_core.online_charinfo[player_name].lang_code)
]]

ch_core.close_submod("creative_inventory")
