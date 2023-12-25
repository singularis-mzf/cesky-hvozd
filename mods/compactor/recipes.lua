-- recipe overrides

local recipes_to_clear = {}

recipes_to_clear.coalblock_fuel = {type = "fuel", recipe = "default:coalblock"}
if minetest.get_modpath("charcoal") then
	recipes_to_clear.charcoal_block_fuel = {type = "fuel", recipe = "charcoal:charcoal_block"}
end
ch_core.clear_crafts("compactor_recipes", recipes_to_clear)
compactor.register_block_recipes_override("basic_materials:brass_ingot", 10, "basic_materials:brass_block")
compactor.register_block_recipes_override("default:bronze_ingot", 10, "default:bronzeblock")
compactor.register_block_recipes_override("default:coal_lump", 10, "default:coalblock") -- [ ] navýšit dobu hoření
compactor.register_block_recipes_override("default:copper_ingot", 10, "default:copperblock")
compactor.register_block_recipes_override("default:gold_ingot", 10, "default:goldblock")
compactor.register_block_recipes_override("default:steel_ingot", 10, "default:steelblock") -- [ ] navýšit dobu hoření
compactor.register_block_recipes_override("default:tin_ingot", 10, "default:tinblock")
compactor.register_block_recipes_override("technic:carbon_steel_ingot", 10, "technic:carbon_steel_block")
compactor.register_block_recipes_override("technic:cast_iron_ingot", 10, "technic:cast_iron_block")
compactor.register_block_recipes_override("technic:chromium_ingot", 10, "technic:chromium_block")
compactor.register_block_recipes_override("technic:lead_ingot", 10, "technic:lead_block")
compactor.register_block_recipes_override("technic:stainless_steel_ingot", 10, "technic:stainless_steel_block")
compactor.register_block_recipes_override("technic:uranium0_ingot", 10, "technic:uranium0_block")
compactor.register_block_recipes_override("technic:uranium35_ingot", 10, "technic:uranium35_block")
compactor.register_block_recipes_override("technic:uranium_ingot", 10, "technic:uranium_block")
compactor.register_block_recipes_override("technic:zinc_ingot", 10, "technic:zinc_block")

minetest.register_craft({type = "fuel", recipe = "default:coalblock", burntime = 420})

if minetest.get_modpath("moreblocks") then
	compactor.register_block_recipes_override("default:cobble", 27, "moreblocks:cobble_compressed")
	compactor.register_compactor_recipe({input = {"default:stone 27"}, output = "moreblocks:cobble_compressed"})
	compactor.register_block_recipes_override("default:desert_cobble", 27, "moreblocks:desert_cobble_compressed")
	compactor.register_compactor_recipe({input = {"default:desert_stone 27"}, output = "moreblocks:desert_cobble_compressed"})
	compactor.register_block_recipes_override("default:dirt", 4, "moreblocks:dirt_compressed")
end

compactor.register_compactor_recipe({input = {"default:clay_brick 4"}, output = "default:brick"})
compactor.register_compactor_recipe({input = {"default:clay_lump 4"}, output = "default:clay"})
-- compactor.register_compactor_recipe({input = {"default:diamond 9"}, output = "default:diamondblock"})

if minetest.get_modpath("charcoal") then
	compactor.register_block_recipes_override("charcoal:charcoal", 10, "charcoal:charcoal_block") -- [ ] navýšit dobu hoření
	minetest.register_craft({type = "fuel", recipe = "charcoal:charcoal_block", burntime = 315})
end

if minetest.get_modpath("farming") and farming.mod and farming.mod == "redo" then
	compactor.register_block_recipes_override("farming:hemp_fibre", 10, "farming:hemp_block")
	compactor.register_block_recipes_override("farming:salt", 10, "farming:salt_crystal", {not_craft_block_to_ingots = true})
end

if minetest.get_modpath("moreores") then
	compactor.register_block_recipes_override("moreores:mithril_ingot", 10, "moreores:mithril_block")
	compactor.register_block_recipes_override("moreores:silver_ingot", 10, "moreores:silver_block")
end

if minetest.get_modpath("aloz") then
	compactor.register_block_recipes_override("aloz:aluminum_ingot", 10, "aloz:aluminum_block")
end
