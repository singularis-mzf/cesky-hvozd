-- Dirt drop

local dirt_drop = minetest.registered_nodes["default:dirt"].drop

if type(dirt_drop) == "table" then
	local drop_items = dirt_drop.items
	if type(drop_items) ~= "table" then
			error("Table expected as default:dirt drop.drop_items!")
	end
	drop_items = table.copy(drop_items)
	local n = #drop_items
	local empty_table = {}
	local last_dirt_i
	for i, v in ipairs(drop_items) do
		if (v.items or empty_table)[1] == "default:dirt" then
			last_dirt_i = i
		end
	end
	if last_dirt_i ~= nil then
		for i = last_dirt_i, n do
			drop_items[i] = drop_items[i + 1]
		end
		n = n - 1
	end
	for i = n + 1, n + 3 do
		drop_items[i] = {items = {"default:dirt"}, rarity = 2}
	end
	n = n + 3
	if minetest.get_modpath("ch_extras") then
		drop_items[n] = {items = {"ch_extras:clean_dirt"}, rarity = 5}
		-- n = n + 1
	end
	minetest.override_item("default:dirt", {drop = dirt_drop})
else
	minetest.log("warning", "Drop of default:dirt not overriden, because it's not a table!")
end

-- Grass selection box

local grass_prefixes = {"default:dry_grass_", "default:grass_"}

for i = 1, 5 do
	local t = ((i - 1) / 4 + 1) * (2 / 16)
	local override = {
		selection_box = {
			type = "fixed",
			fixed = {-t, -8/16, -t, t, -6/16, t},
		},
	}
	for _, prefix in pairs(grass_prefixes) do
		minetest.override_item(prefix..i, override)
	end
end

-- Remove apples near default:leaves
minetest.register_lbm({
	label = "Remove apples near default:leaves",
	name = "ch_overrides:remove_apples",
	nodenames = {"default:apple"},
	action = function(pos, node, dtime_s)
		if #minetest.find_nodes_in_area(vector.offset(pos, -2, -2, -2), vector.offset(pos, 2, 2, 2), {"default:leaves"}, false) > 0 then
			minetest.remove_node(pos)
		end
	end,
})
