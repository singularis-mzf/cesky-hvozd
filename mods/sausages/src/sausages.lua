local S = sausages.S

local on_secondary_use =

minetest.register_craftitem("sausages:sausages_raw",{
	description = S("Raw Sausages"),
	inventory_image = "food_sausage_raw.png",
	groups = { food = 3, eatable = 3, smoker_cookable = 1, ch_food = 3 },
	on_use = ch_core.item_eat(),
	_mcl_saturation = 1.5,
})


minetest.register_craftitem("sausages:sausages_cooked",{
	description = S("Cooked Sausages"),
	inventory_image = "food_sausage_cooked.png",
	groups = { food = 8, eatable = 8, ch_food = 8 },
	on_use = ch_core.item_eat(),
	_mcl_saturation = 9.2,
})

if minetest.get_modpath("mcl_core") then
	minetest.override_item("sausages:sausages_raw",{
		on_use = function() end,
		on_place = minetest.item_eat(3),
		on_secondary_use = minetest.item_eat(3),
	})
	minetest.override_item("sausages:sausages_cooked",{
		on_use = function() end,
		on_place = minetest.item_eat(8),
		on_secondary_use = minetest.item_eat(8),
	})
end
