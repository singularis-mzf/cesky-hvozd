technic.register_grinder_recipe({input = {"df_farming:cave_wheat_seed"}, output = "df_farming:cave_flour"})
technic.register_grinder_recipe({input = {"df_farming:cave_wheat 4"}, output = "df_farming:cave_flour"})
technic.register_grinder_recipe({input = {"df_farming:sweet_pods"}, output = "df_farming:sugar"})

if minetest.get_modpath("dye") then
    technic.register_extractor_recipe({input = {"df_farming:dimple_cup_harvested"}, output = "dye:blue 4"})
end
