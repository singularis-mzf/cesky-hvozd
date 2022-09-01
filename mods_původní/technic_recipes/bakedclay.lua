technic.register_extractor_recipe({input = {"bakedclay:delphinium"}, output = "dye:cyan 4"})
technic.register_extractor_recipe({input = {"bakedclay:lazarus"}, output = "dye:pink 4"})
technic.register_extractor_recipe({input = {"bakedclay:mannagrass"}, output = "dye:dark_green 4"})
technic.register_extractor_recipe({input = {"bakedclay:thistle"}, output = "dye:magenta 4"})

local clay = {"white", "grey", "black", "red", "yellow",
                "green", "cyan", "blue", "magenta", "orange", 
                "violet", "brown", "pink", "dark_grey", "dark_green"}

for _,c in ipairs(clay) do
    technic.register_alloy_recipe({input = {"default:clay 8", "dye:" .. c}, output = "bakedclay:" .. c .. " 8"})
end
