-- Dirt drop

local dirt_drop = minetest.registered_nodes["default:dirt"].drop

if type(dirt_drop) ~= "table" then
	error("Table expected as default:dirt drop!")
end

local drop_items = dirt_drop.items

if type(drop_items) ~= "table" then
	error("Table expected as default:dirt drop items!")
end

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
	n = n + 1
end
minetest.override_item("default:dirt", {drop = dirt_drop})
