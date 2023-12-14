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
                 "bridger:scaffolding"},
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
			"pkarcs:aspen_wood_arc",
			"pkarcs:aspen_wood_inner_arc",
			"pkarcs:aspen_wood_outer_arc",
			"pkarcs:junglewood_arc",
			"pkarcs:junglewood_inner_arc",
			"pkarcs:junglewood_outer_arc",
			"pkarcs:pine_wood_arc",
			"pkarcs:pine_wood_inner_arc",
			"pkarcs:pine_wood_outer_arc",
			"pkarcs:wood_arc",
			"pkarcs:wood_inner_arc",
			"pkarcs:wood_outer_arc",
		},
		-- not_in_mods = {"cottages", "moreblocks", "pkarcs"},
	},
	{
		name = "drevokmeny",
		groups = {"tree"},
		items = none,
		mods = none,
		exclude_items = {"cottages:water_gen", "bamboo:trunk"},
	},
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
	},
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
                 "technic:uranium_ingot", "technic:uranium35_ingot"},
		mods = none,
	},
	{
		name = "loziska",
		groups = none,
		items = {"default:stone_with_tin", "default:stone_with_diamond", "default:stone_with_mese", "default:stone_with_copper", "default:stone_with_coal",
                 "default:stone_with_gold", "default:stone_with_iron", "denseores:large_tin_ore", "denseores:large_diamond_ore", "denseores:large_mese_ore",
                 "denseores:large_copper_ore", "denseores:large_mithril_ore", "denseores:large_silver_ore", "denseores:large_coal_ore",
                 "denseores:large_gold_ore", "denseores:large_iron_ore", "moreores:mineral_mithril", "moreores:mineral_silver",
                 "technic:mineral_chromium", "technic:mineral_lead", "technic:mineral_sulfur", "technic:mineral_uranium", "technic:mineral_zinc"},
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
	},
}

ch_core.creative_inventory = {
	items_by_order = {},
	partitions_by_name = {
		others = {
			name = "others",
			items_by_order = {},
		},
	},
	not_initialized = true,
}

local function sort_items(items, group_by_mod)
	-- items is expected to be a sequence of item names, e. g. {"default:cobble", "default:stick", ...}
	-- the original list is not changed; the new list is returned
	local counter_nil, counter_same, counter_diff = 0, 0, 0
	local item_to_key = {}

	for _, item in ipairs(items) do
		local def = minetest.registered_items[item]
		local desc = (def and def.description) or ""
		local tdesc = minetest.get_translated_string("cs", desc)
		if tdesc == nil then
			counter_nil = counter_nil + 1
			tdesc = ""
		else
			if tdesc == desc then
				counter_same = counter_same + 1
				minetest.log("info", "a description \""..desc.."\" not changed in the translation") -- DEBUG
			else
				counter_diff = counter_diff + 1
			end
		end
		if group_by_mod then
			local index = item:find(":")
			if index then
				tdesc = item:sub(1, index)..tdesc
			end
		end
		item_to_key[item] = ch_core.utf8_radici_klic(tdesc, false)
	end

	local result = table.copy(items)
	table.sort(result, function(a, b) return item_to_key[a] < item_to_key[b] end)
	minetest.log("info", "sort_items() stats: "..counter_diff.." differents, "..counter_same.." same, "..counter_nil.." nil, "..(counter_diff + counter_same + counter_nil).." total, count = "..#result..".")
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
	local not_in_mods = {} -- [partition.."/"..mod]
	local partition_to_exclude_items = {others = none}
	for order, part_def in ipairs(partition_defs) do
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
				local mod, subname = name:match("^([^:]*):([^:]*)$")
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
				existing_partitions[partition] = {name}
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
	for order, part_def in ipairs(partition_defs) do
		local partition_list = existing_partitions[part_def.name]
		if partition_list then
			table.insert(partitions_in_order, { name = part_def.name, items_by_order = partition_list })
			existing_partitions[part_def.name] = nil
		end
	end
	local remaining_partitions = {}
	for part_name, item_list in pairs(existing_partitions) do
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

	for order, part_info in pairs(partitions_in_order) do
		partitions_by_name[part_info.name] = part_info.items_by_order
		table.insert_all(items_by_order, part_info.items_by_order)
		partitions_by_name_count = partitions_by_name_count + 1
	end

	-- commit
	local new_ci = {
		items_by_order = items_by_order,
		partitions_by_name = partitions_by_name,
	}
	ch_core.creative_inventory = new_ci
	minetest.log("action", "ch_core creative_inventory updated: "..#items_by_order.." items in "..partitions_by_name_count.." partitions")
	creative_inventory_initialized = true
	return new_ci
end

ch_core.close_submod("creative_inventory")
