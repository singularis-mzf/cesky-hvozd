local salt = minetest.get_modpath("farming") and (farming.mod == "redo" or farming.mod == "undo") and "farming:salt"
local meat = {}

if minetest.get_modpath("mobs_animal") then
	table.insert(meat,"mobs:chicken_raw")
	table.insert(meat,"mobs:meat_raw")
	table.insert(meat,"mobs:mutton_raw")
end

if minetest.get_modpath("animalia") then
	table.insert(meat,"animalia:beef_raw")
	table.insert(meat,"animalia:mutton_raw")
	table.insert(meat,"animalia:porkchop_raw")
	table.insert(meat,"animalia:poultry_raw")
	table.insert(meat,"animalia:venison_raw")
end

-- if minetest.get_modpath("mobs_mc") then
-- 	table.insert(meat,"mobs_mc:chicken_raw")
-- 	table.insert(meat,"mobs_mc:beef_raw")
-- 	table.insert(meat,"mobs_mc:porkchop_raw")
-- 	table.insert(meat,"mobs_mc:rabbit_raw")
-- 	table.insert(meat,"mobs_mc:mutton_raw")
-- end

if minetest.get_modpath("mcl_mobitems") then
	table.insert(meat,"mcl_mobitems:mutton")
	table.insert(meat,"mcl_mobitems:beef")
	table.insert(meat,"mcl_mobitems:chicken")
	table.insert(meat,"mcl_mobitems:porkchop")
end

for _,y in ipairs(meat) do
	sausages.log("action","Processing craft groups of " .. y)
	local def = minetest.registered_items[y]
	if def then
		local groups = minetest.registered_items[y].groups or {}
		groups.sausages_meat = 1
		minetest.override_item(y,{ groups = groups })
	end
end

local recipe = {"group:sausages_meat","group:sausages_meat","group:sausages_meat"}
if salt then
	table.insert(recipe,salt)
end

minetest.register_craft({
	type = "shapeless",
	recipe = recipe,
	output = "sausages:sausages_raw 2"
})

minetest.register_craft({
	type = "cooking",
	recipe = "sausages:sausages_raw",
	output = "sausages:sausages_cooked",
	cooktime = minetest.get_modpath("mcl_core") and 10,
})
