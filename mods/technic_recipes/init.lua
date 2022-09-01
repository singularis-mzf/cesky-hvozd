local modpath = minetest.get_modpath("technic_recipes")

if minetest.get_modpath("df_farming") then
    dofile(modpath.."/df_farming.lua")
end

if minetest.get_modpath("bakedclay") then
    dofile(modpath.."/bakedclay.lua")
end

if minetest.get_modpath("bonemeal") then
    dofile(modpath.."/bonemeal.lua")
end

if minetest.get_modpath("doors") then
    dofile(modpath.."/doors.lua")
end

if minetest.get_modpath("ethereal") then
    dofile(modpath.."/ethereal.lua")
end

if minetest.get_modpath("farming") then
    dofile(modpath.."/farming.lua")
end

if minetest.get_modpath("flowers") and minetest.get_modpath("dye") then
    dofile(modpath.."/farming.lua")
end

if minetest.get_modpath("terumet") then
    dofile(modpath.."/terumet.lua")
end

if minetest.get_modpath("xpanes") then
    dofile(modpath.."/xpanes.lua")
end

technic.register_compressor_recipe({input = {"default:papyrus 2"}, output = "default:paper"})

technic.register_grinder_recipe({input = {"basic_materials:chainlink_brass 2"}, output = "technic:brass_dust"})
technic.register_grinder_recipe({input = {"basic_materials:chainlink_steel 2"}, output = "technic:wrought_iron_dust"})
technic.register_grinder_recipe({input = {"basic_materials:chain_brass 3"}, output = "technic:brass_dust"})
technic.register_grinder_recipe({input = {"basic_materials:chain_steel 2"}, output = "technic:wrought_iron_dust"})
technic.register_grinder_recipe({input = {"basic_materials:steel_strip 6"}, output = "technic:wrought_iron_dust"})
technic.register_grinder_recipe({input = {"basic_materials:copper_strip 6"}, output = "technic:copper_dust"})
technic.register_grinder_recipe({input = {"basic_materials:steel_bar 2"}, output = "technic:wrought_iron_dust"})

technic.register_grinder_recipe({input = {"default:sign_wall_steel"}, output = "technic:wrought_iron_dust 2"})

technic.register_grinder_recipe({input = {"pipeworks:pipe_1_empty 2"}, output = "technic:wrought_iron_dust"})

technic.register_grinder_recipe({input = {"technic:carbon_plate"}, output = "technic:coal_dust 12"})
technic.register_grinder_recipe({input = {"technic:copper_plate"}, output = "technic:copper_dust 5"})
