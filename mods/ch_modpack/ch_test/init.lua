print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local function array_stats(name, table)
	if not table then
		return name..":nil"
	end

	local count = 0
	local longest = ""
	local count_per_mod = {}
	local i, m, k2

	for k, _ in pairs(table) do
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
end

minetest.register_on_mods_loaded(on_mods_loaded)

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

