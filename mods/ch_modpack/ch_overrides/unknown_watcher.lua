--[[
UNKNOWN WATCHER
]]

local worldpath = minetest.get_worldpath()

local function load_names() -- => map
	local f = io.open(worldpath.."/ch_item_types.txt", "r")
	if f ~= nil then
		local json = f:read("*a")
		f:close()
		return assert(minetest.parse_json(json))
	else
		return {}
	end
end

local function save_names(map)
	local s = assert(minetest.write_json(map, true))
	minetest.safe_file_write(worldpath.."/ch_item_types.txt", s)
end

local function on_mods_loaded()
	local us_time = minetest.get_us_time()
	local old_items = load_names()
	local new_items = {}
	local changes_added, changes_changed, changes_removed = {}, {}, {}
	local craftitems, tools, nodes, others, aliases, unknowns = 0, 0, 0, 0, 0, 0
	local first_run = next(old_items) == nil

	for name, def in pairs(minetest.registered_items) do
		if def.type ~= "none" then
			new_items[name] = def.type
			if def.type == "craft" then
				craftitems = craftitems + 1
			elseif def.type == "tool" then
				tools = tools + 1
			elseif def.type == "node" then
				nodes = nodes + 1
			else
				others = others + 1
			end
			if old_items[name] == nil then
				table.insert(changes_added, "- added: "..name.." = "..def.type)
			else
				if old_items[name] ~= def.type then
					table.insert(changes_changed, "- changed: "..name..": "..old_items[name].." => "..def.type)
				end
				old_items[name] = nil
			end
		end
	end
	for name, _ in pairs(minetest.registered_aliases) do
		new_items[name] = "alias"
		aliases = aliases + 1
		if old_items[name] == nil then
			table.insert(changes_added, "- added: "..name.." = alias")
		else
			if old_items[name] ~= "alias" then
				table.insert(changes_changed, "- changed: "..name..": "..old_items[name].." => alias")
			end
			old_items[name] = nil
		end
	end
	for name, t in pairs(old_items) do
		new_items[name] = "unknown"
		unknowns = unknowns + 1
		if t ~= "unknown" then
			table.insert(changes_removed, "- removed: "..name.." (was "..t..")")
		end
	end
	minetest.log("action", "[ch_overrides/unknown_watcher] "..nodes.." nodes, "..craftitems.." craftitems, "..tools.." tools, "..others.." others, "..aliases.." aliases, "..unknowns.." unknowns")
	if not first_run and #changes_added > 0 then
		minetest.log("action", #changes_added.." items added:\n"..table.concat(changes_added, "\n"))
	end
	if #changes_changed > 0 then
		minetest.log("action", #changes_changed.." items changed:\n"..table.concat(changes_changed, "\n"))
	end
	if #changes_removed > 0 then
		minetest.log("action", #changes_removed.." items removed:\n"..table.concat(changes_removed, "\n"))
	end
	save_names(new_items)
	print("[ch_overrides/unknown_watcher] finished in "..((minetest.get_us_time() - us_time) / 1000).." ms.")
end

minetest.register_on_mods_loaded(on_mods_loaded)
