ch_base.open_mod(minetest.get_current_modname())
-- Glue and fiber
minetest.register_craftitem("mesecons_materials:glue", {
	image = "mesecons_glue.png",
	on_place_on_ground = minetest.craftitem_place_item,
	description="lepidlo",
})

minetest.register_craftitem("mesecons_materials:fiber", {
	image = "mesecons_fiber.png",
	on_place_on_ground = minetest.craftitem_place_item,
	description="vláknina",
})

minetest.register_craft({
	output = "mesecons_materials:glue 2",
	type = "cooking",
	recipe = "group:sapling",
	cooktime = 2
})

minetest.register_craft({
	output = "mesecons_materials:fiber 6",
	type = "cooking",
	recipe = "mesecons_materials:glue",
	cooktime = 4
})

-- Silicon
-- minetest.register_alias("mesecons_materials:silicon", "basic_materials:silicon")
--[[
minetest.register_craftitem("mesecons_materials:silicon", {
	image = "mesecons_silicon.png",
	on_place_on_ground = minetest.craftitem_place_item,
	description="křemík (mesespoje)",
})
]]
minetest.register_craft({
	output = "mesecons_materials:silicon 4",
	recipe = {
		{"group:sand", "group:sand"},
		{"group:sand", "mesecons_gamecompat:steel_ingot"},
	}
})

ch_base.close_mod(minetest.get_current_modname())
