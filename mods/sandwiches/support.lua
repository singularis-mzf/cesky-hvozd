
if minetest.registered_craftitems["ethereal:strawberry"] and minetest.registered_nodes["ethereal:banana"] then
	dofile(sandwiches.path .. "/luas/ethereal.lua")
end

if minetest.get_modpath ("moretrees") then
    dofile(sandwiches.path .. "/luas/nutella.lua")
end

if minetest.get_modpath ("cucina_vegana") then
    dofile(sandwiches.path .. "/luas/cucina_vegana.lua")
	minetest.register_alias("sandwiches:peanuts","cucina_vegana:peanut")
	minetest.register_alias("sandwiches:peanut_seed","cucina_vegana:peanut_seed")
end

if minetest.get_modpath ("bbq") then
    dofile(sandwiches.path .. "/luas/bbq.lua")
end