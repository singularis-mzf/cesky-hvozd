ch_core.open_submod("creative_inventory", {lib = true})

local fixed_partitions = {
	{ name = "empty_buckets", in_creative_inventory = true },
}

ch_core.creative_inventory = {
	items_by_order = {},
	-- partitions_by_order = {},
	partitions_by_name = {
		others = {
			name = "others",
			in_creative_inventory = true,
			items_by_order = {},
		},
	},
	candidates = {}, -- item_name => partition
	not_initialized = true,
}
ch_core.creative_inventory.partitions_by_order = { ch_core.creative_inventory.partitions_by_name.others }

local function sort_items(items)
	-- items is expected to be a sequence of item names, e. g. {"default:cobble", "default:stick", ...}
	-- the original list is not changed; the new list is returned
	local key_to_item = {}
	local keys = {}
	for _, item in ipairs(items) do
		local def = minetest.registered_items[item]
		local desc = def and def.description
		-- print("description = <<"..desc..">>, translated to <<"..(minetest.get_translated_string("cs", desc) or "nil")..">>")
		local tdesc = string.lower(ch_core.odstranit_diakritiku(minetest.get_translated_string("cs", desc) or ""))
		while key_to_item[tdesc] ~= nil do
			tdesc = tdesc .. "_"
		end
		key_to_item[tdesc] = item
		table.insert(keys, tdesc)
	end
	table.sort(keys)
	local count = #keys
	for i = 1, count do
		keys[i] = key_to_item[keys[i]]
		if not keys[i] then
			minetest.log("error", "Internal error of sort_items() at index "..i.."!")
		end
	end
	return keys
end

--[[
local function get_sorted_sequence(items)
	-- items are expected to be a map: sorting key => item name
	-- items will be unchanged
	-- returns a sequence of values (item names) ordered by keys
	local result = {}
	for key, _ in pairs(items) do
		table.insert(result, key)
	end
	table.sort(result)
	local count = #result
	for i = 1, count do
		result[i] = items[result[i] ]
	

	end
	return result
end ]]

function ch_core.set_ci_partition(item, partition)
	ch_core.creative_inventory.candidates[item] = partition
	return true
end

-- should be called when the first player logs in
function ch_core.update_creative_inventory()
	local old_ci = ch_core.creative_inventory
	local item_to_partition = {} -- item => partition
	local timestamps = {minetest.get_us_time()}

	-- 1. vlož do seznamu pevné oddíly
	local partitions_by_name = {}
	local partitions_by_order = {}
	for _, partition_def in ipairs(fixed_partitions) do
		local new_partition = {
			name = partition_def.name,
			in_creative_inventory = partition_def.in_creative_inventory or false,
			items_by_order = {},
		}
		partitions_by_name[partition_def.name] = new_partition
		table.insert(partitions_by_order, new_partition)
	end
	table.insert(timestamps, minetest.get_us_time())

	-- 2. vyplň do „item_to_partition“ aktuální partition pro každý předmět (itemname => partition_name)
	for partition_name, partition_def in pairs(old_ci.partitions_by_name) do
		if partition_name ~= "others" then
			for _, item in ipairs(partition_def.items_by_order) do
				item_to_partition[item] = partition_name
			end
		end
	end
	for item_name, partition_name in pairs(old_ci.candidates) do
		if partition_name ~= "others" and minetest.registered_items[item_name] then
			item_to_partition[item_name] = partition_name
		end
	end
	table.insert(timestamps, minetest.get_us_time())

	-- 3. každý předmět z „item_to_partition“ zařaď to příslušných partitions; pokud nějaká chybí, doplň ji nakonec
	for item, partition_name in pairs(item_to_partition) do
		local partition = partitions_by_name[partition_name]
		if not partition then
			partition = {
				name = partition_name,
				in_creative_inventory = true,
				items_by_order = {},
			}
			partitions_by_name[partition_name] = partition
			table.insert(partitions_by_order, partition)
		end
		table.insert(partition.items_by_order, item)
	end
	table.insert(timestamps, minetest.get_us_time())

	-- 4. vytvoř partition „others“ a vlož do ní všechny zbylé předměty, které nejsou not_in_creative_inventory
	local other_items = {}
	partitions_by_name.others = {
		name = "others",
		in_creative_inventory = true,
		items_by_order = other_items,
	}
	table.insert(partitions_by_order, partitions_by_name.others)
	for item_name, item_def in pairs(minetest.registered_items) do
		if not item_to_partition[item_name] and item_def.description and item_def.description ~= "" and (not item_def.groups or not item_def.groups.not_in_creative_inventory) then
			table.insert(other_items, item_name)
		end
	end
	table.insert(timestamps, minetest.get_us_time())

	-- 5. seřaď předměty v každém oddílu v pořadí a spoj je do kompletního pole items_by_order
	local items_by_order = {}
	for _, partition in ipairs(partitions_by_order) do
		partition.items_by_order = sort_items(partition.items_by_order)
		table.insert_all(items_by_order, partition.items_by_order)
	end

	local new_ci = {
		items_by_order = items_by_order,
		partitions_by_name = partitions_by_name,
		partitions_by_order = partitions_by_order,
		candidates = {},
	}
	table.insert(timestamps, minetest.get_us_time())
	minetest.log("warning", "update_creative_inventory() timestamps: "..dump(timestamps))

	-- commit
	ch_core.creative_inventory = new_ci
	minetest.log("action", "ch_core creative_inventory updated: "..#items_by_order.." items in "..#partitions_by_order.." partitions")
	return new_ci
end

ch_core.close_submod("creative_inventory")
