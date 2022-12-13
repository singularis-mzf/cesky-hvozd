local modpath, S = ...

assert(loadfile(modpath .. "/misc/mount.lua"))() --Load the mount engine
assert(loadfile(modpath .. "/misc/nodes.lua"))(modpath, S) --Load the nodes
assert(loadfile(modpath .. "/misc/items.lua"))(S) --Load the items
assert(loadfile(modpath .. "/misc/chests.lua"))(S) --Load the chests
assert(loadfile(modpath .. "/misc/food.lua"))(S) --Load the food items
assert(loadfile(modpath .. "/misc/hunger.lua"))(modpath, S)
assert(loadfile(modpath .. "/misc/tools.lua"))(S)
assert(loadfile(modpath .. "/misc/wagon.lua"))(S) --Wagon
--assert(loadfile(modpath .. "/misc/parchment.lua"))(S) --Load the food items
if petz.settings["lycanthropy"] then
	assert(loadfile(modpath .. "/misc/lycanthropy.lua"))(S) --Load the food items
end
if minetest.get_modpath("3d_armor") ~= nil then --Armors (optional)
	assert(loadfile(modpath .. "/misc/armors.lua"))(S)
end
assert(loadfile(modpath .. "/misc/weapons.lua"))(S) --Load the spawn engine
--Bonemeal support
if minetest.get_modpath("bonemeal") ~= nil then
	assert(loadfile(modpath .. "/misc/bonemeal.lua"))() --Bonemeal support
end
--if minetest.get_modpath("awards") ~= nil then
	--assert(loadfile(modpath .. "/misc/awards.lua"))(modpath, S) --Load the awards
--end
