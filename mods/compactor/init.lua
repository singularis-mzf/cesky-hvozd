local modpath = minetest.get_modpath("compactor")
compactor = {}

technic.register_recipe_type("compacting", {description = "Compacting"})

function compactor.register_compactor_recipe(data)
    data.time = data.time or 1
    technic.register_recipe("compacting", data)
end

function compactor.register_compactor(data)
    data.typename = "compacting"
    data.machine_name = "compactor"
    data.machine_desc = "%s Compactor"
    technic.register_base_machine(data)
end

compactor.register_compactor({tier = "LV", demand = {100}, speed = 1})

minetest.register_craft({
    output = "compactor:lv_compactor",
    recipe = {
        {"technic:marble", "basic_materials:motor", "technic:granite"},
        {"pipeworks:autocrafter", "technic:machine_casing", "mesecons:piston"},
        {"basic_materials:brass_ingot", "technic:lv_cable", "default:bronze_ingot"},
    },
})

compactor.register_compactor({tier = "MV", demand = {300, 250, 200}, speed = 2, upgrade = 1, tube = 1})

minetest.register_craft({
    output = "compactor:mv_compactor",
    recipe = {
        {"technic:stainless_steel_ingot", "compactor:lv_compactor", "technic:stainless_steel_ingot"},
        {"pipeworks:tube_1", "technic:mv_transformer", "pipeworks:tube_1"},
        {"technic:stainless_steel_ingot", "technic:mv_cable", "technic:stainless_steel_ingot"},
    },
})

dofile(modpath.."/recipes.lua")
