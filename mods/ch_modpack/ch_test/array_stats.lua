-- ARRAY STATS

local function array_stats(name, tbl)
	if not tbl then
		return name..":nil"
	end

	local count = 0
	local longest = ""
	local count_per_mod = {}
	local i, m, k2

	for k, _ in pairs(tbl) do
		i = string.find(k, ":")
		if i then
			m = k:sub(1, i - 1)
		else
			m = ""
		end
		count = count + 1
		count_per_mod[m] = (count_per_mod[m] or 0) + 1
		k2 = k..""
		if #k2 > #longest then
			longest = k2
		end
	end

	local mods_count = 0
	local mod_with_most_name = ""
	local mod_with_most_count = 0
	for mod, count in pairs(count_per_mod) do
		mods_count = mods_count + 1
		if count > mod_with_most_count then
			mod_with_most_name = mod
			mod_with_most_count = count
		end
	end

	if name == "registered_nodes" then
		local t = {}
		for m, c in pairs(count_per_mod) do
			if c >= 100 then
				table.insert(t, {name = m, count = c})
			end
		end
		table.sort(t, function(a, b) return a.count < b.count end)
		for _, row in ipairs(t) do
			print("registered_nodes: ["..row.name.."] = "..row.count.." nodes")
		end
	end

	return name..": "..count.." items of "..mods_count.." mods (most "..mod_with_most_count.." from mod "..mod_with_most_name.."), longest = "..longest
end

local function on_mods_loaded()
	print("Will do registered stats...")
	print(array_stats("registered_nodes", minetest.registered_nodes))
	print("----")
	print(array_stats("registered_items", minetest.registered_items))
	print(array_stats("registered_craftitems", minetest.registered_craftitems))
	print(array_stats("registered_tools", minetest.registered_tools))
	print(array_stats("registered_aliases", minetest.registered_aliases))
	print(array_stats("registered_entities", minetest.registered_entities))
	print(array_stats("registered_abms", minetest.registered_abms))
	print(array_stats("registered_lbms", minetest.registered_lbms))
	print(array_stats("registered_ores", minetest.registered_ores))
	print(array_stats("registered_decorations", minetest.registered_decorations))

	print("-- times = "..dump2({
		timeofday = minetest.get_timeofday() or "nil",
		gametime = minetest.get_gametime() or "nil",
		day_count = minetest.get_day_count() or "nil",
		uptime = minetest.get_server_uptime() or "nil",
		ustime = minetest.get_us_time() or "nil",
		os_clock = os.clock() or "nil",
		os_time = os.time() or "nil",
	}))
	minetest.after(2, function()
		print("-- times = "..dump2({
			timeofday = minetest.get_timeofday() or "nil",
			gametime = minetest.get_gametime() or "nil",
			day_count = minetest.get_day_count() or "nil",
			uptime = minetest.get_server_uptime() or "nil",
			ustime = minetest.get_us_time() or "nil",
			os_clock = os.clock() or "nil",
			os_time = os.time() or "nil",
		}))
	end)

	--[[
	local world_path = minetest.get_worldpath()
	local f = io.open(world_path.."/export_nodes.txt", "w")
	f:write(dump2(minetest.registered_nodes))
	f:close() ]]

	--[[
	print("Starting recipe export...")
	local world_path = minetest.get_worldpath()
	local f = io.open(world_path.."/recipes-export.txt", "w")
	local counter = 0
	local items_processed = {}
	for name, _ in pairs(minetest.registered_items) do
		local true_name = minetest.registered_aliases[name] or name
		if not items_processed[true_name] then
			local counter_orig = counter
			local recipes = minetest.get_all_craft_recipes(name)
			if recipes then
				for _, recipe in ipairs(recipes) do
					local output_str
					if type(recipe.output) == "string" then
						output_str = recipe.output
					else
						output_str = string.gsub(dump(recipe.output), "\t", " ")
					end
					local recipe_method = recipe.method or "nil"
					local recipe_width = recipe.width or -1
					local recipe_items = "1="..(recipe.items[1] or "")..",2="..(recipe.items[2] or "")..",3="..(recipe.items[3] or "")..",4="..(recipe.items[4] or "")..",5="..(recipe.items[5] or "")..",6="..(recipe.items[6] or "")..",7="..(recipe.items[7] or "")..",8="..(recipe.items[8] or "")..",9="..(recipe.items[9] or "")
					-- f:write(string.gsub(output_str.."\t"..recipe_method.."\t"..recipe_width.."\t"..recipe_items, "\n", "|||").."\n")
					counter = counter + 1
				end
			end
			items_processed[true_name] = true
			if counter == counter_orig and minetest.get_item_group(name, "not_in_creative_inventory") == 0 then
				f:write(name.."\n")
			end
		else
			print("item "..name.." with true name "..true_name.." already processed")
		end
	end
	f:close()
	print("Recipe export finished. "..counter.." recipes exported.")
	]]
end

minetest.register_on_mods_loaded(on_mods_loaded)
