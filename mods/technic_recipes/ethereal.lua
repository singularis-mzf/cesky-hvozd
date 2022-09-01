if minetest.get_modpath("dye") then
    technic.register_extractor_recipe({input = {"ethereal:coral2"}, output = "dye:cyan 4"})
    technic.register_extractor_recipe({input = {"ethereal:coral3"}, output = "dye:orange 4"})
    technic.register_extractor_recipe({input = {"ethereal:coral4"}, output = "dye:pink 4"})
    technic.register_extractor_recipe({input = {"ethereal:coral5"}, output = "dye:green 4"})
    technic.register_extractor_recipe({input = {"ethereal:dry_shrub"}, output = "dye:red 1"})
    technic.register_extractor_recipe({input = {"ethereal:seaweed"}, output = "dye:dark_green 4"})
    technic.register_extractor_recipe({input = {"ethereal:snowygrass"}, output = "dye:grey 1"})
    technic.register_extractor_recipe({input = {"ethereal:crystalgrass"}, output = "dye:blue 1"})
    technic.register_extractor_recipe({input = {"ethereal:fern"}, output = "dye:green 1"})
end

technic.register_grinder_recipe({input = {"ethereal:fire_flower"}, output = "ethereal:fire_dust 3"})
technic.register_grinder_recipe({input = {"ethereal:charcoal_lump 5"}, output = "technic:coal_dust"})
