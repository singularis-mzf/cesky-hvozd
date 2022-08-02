minetest.register_on_mods_loaded(function()
	io.output(minetest.get_worldpath() .. "/testlist.txt")
	local sand = minetest.registered_nodes["default:sand"];
	for k, v in pairs(sand) do
		io.write("key[", k, "]\n")
	end
	for k, v in pairs(minetest.registered_nodes) do
		local groups = v.groups
		local groupstext = ""
		if groups then
			for k2 in pairs(groups) do
				groupstext = groupstext .. "," .. k2
			end
		end
		io.write(k, "\t\"", string.gsub(v.description or "No description", "[\t\r\n]", " "), "\"\t", string.sub(groupstext, 2), "\n")
	end
	io.flush()
	end)

print("[Mujtest] Loaded!")
