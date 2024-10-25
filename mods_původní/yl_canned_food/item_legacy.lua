if (yl_canned_food.settings.legacy ~= true) then
    return
end

local origin = "canned_food"

local foods = {
    apple_jam = {
        source = "apple_jam",
        target = "apple_jam_plus",
        source_desc = "Apple jam",
        target_desc = "Old Apple jam"
    },
    banana_jam = {
        source = "banana_jam",
        target = "banana_jam_plus",
        source_desc = "Banana jam",
        target_desc = "Old Banana jam"
    },
    blackberry_jam = {
        source = "blackberry_jam",
        target = "blackberry_jam_plus",
        source_desc = "Blackberry jam",
        target_desc = "Old Blackberry jam"
    },
    blueberry_jam = {
        source = "blueberry_jam",
        target = "blueberry_jam_plus",
        source_desc = "Blueberry jam",
        target_desc = "Old blueberry jam"
    },
    canned_beans = {
        source = "canned_beans",
        target = "canned_beans_plus",
        source_desc = "Canned beans",
        target_desc = "Pickled beans"
    },
    canned_beetroot = {
        source = "canned_beetroot",
        target = "canned_beetroot_plus",
        source_desc = "Canned beetroot",
        target_desc = "Pickled beetroot"
    },
    canned_cabbage = {
        source = "canned_cabbage",
        target = "canned_cabbage_plus",
        source_desc = "Canned cabbage",
        target_desc = "Sauerkraut"
    },
    canned_carrot = {
        source = "canned_carrot",
        target = "canned_carrot_plus",
        source_desc = "Canned carrots",
        target_desc = "Pickled carrot sticks"
    },
    canned_chili_pepper = {
        source = "canned_chili_pepper",
        target = "canned_chili_pepper_plus",
        source_desc = "Canned chili pepper",
        target_desc = "Pickled chili pepper"
    },
    canned_coconut = {
        source = "canned_coconut",
        target = "canned_coconut_plus",
        source_desc = "Canned coconut",
        target_desc = "Pickled coconut"
    },
    canned_corn = {
        source = "canned_corn",
        target = "canned_corn_plus",
        source_desc = "Canned corn",
        target_desc = "Pickled corn"
    },
    canned_cucumber = {
        source = "canned_cucumber",
        target = "canned_cucumber_plus",
        source_desc = "Canned cucumbers",
        target_desc = "Pickles"
    },
    canned_garlic_cloves = {
        source = "canned_garlic_cloves",
        target = "canned_garlic_cloves_plus",
        source_desc = "Canned Garlic Cloves",
        target_desc = "Pickled Garlic Cloves"
    },
    canned_mushrooms = {
        source = "canned_mushrooms",
        target = "canned_mushrooms_plus",
        source_desc = "Canned mushrooms",
        target_desc = "Salted mushrooms"
    },
    canned_onion = {
        source = "canned_onion",
        target = "canned_onion_plus",
        source_desc = "Canned onions",
        target_desc = "Pickled onions"
    },
    canned_peas = {
        source = "canned_peas",
        target = "canned_peas_plus",
        source_desc = "Canned peas",
        target_desc = "Pickled peas"
    },
    canned_pineapple = {
        source = "canned_pineapple",
        target = "canned_pineapple_plus",
        source_desc = "Canned pineapple rings",
        target_desc = "Pickled pineapple rings"
    },
    canned_potato = {
        source = "canned_potato",
        target = "canned_potato_plus",
        source_desc = "Canned potatoes",
        target_desc = "Mexican pickled potatoes"
    },
    canned_pumpkin = {
        source = "canned_pumpkin",
        target = "canned_pumpkin_plus",
        source_desc = "Canned pumpkin puree",
        target_desc = "Pickled pumpkin puree"
    },
    canned_tomato = {
        source = "canned_tomato",
        target = "canned_tomato_plus",
        source_desc = "Canned tomatoes",
        target_desc = "Marinated tomatoes"
    },
    dandelion_jam = {
        source = "dandelion_jam",
        target = "dandelion_jam_plus",
        source_desc = "Dandelion jam",
        target_desc = "Old dandelion jam"
    },
    grape_jam = {
        source = "grape_jam",
        target = "grape_jam_plus",
        source_desc = "Grape jam",
        target_desc = "Old Grape jam"
    },
    honey_jar = {
        source = "honey_jar",
        target = "honey_jar_plus",
        source_desc = "A jar of honey",
        target_desc = "A jar of aged honey"
    },
    lemon_jam = {
        source = "lemon_jam",
        target = "lemon_jam_plus",
        source_desc = "Lemon jam",
        target_desc = "Old lemon jam"
    },
    melon_jam = {
        source = "melon_jam",
        target = "melon_jam_plus",
        source_desc = "Melon jam",
        target_desc = "Old melon jam"
    },
    orange_jam = {
        source = "orange_jam",
        target = "orange_jam_plus",
        source_desc = "Orange jam",
        target_desc = "Old orange jam"
    },
    pine_nuts_jar = {
        source = "pine_nuts_jar",
        target = "pine_nuts_jar_plus",
        source_desc = "A jar of pine nuts",
        target_desc = "A jar of salted pine nuts"
    },
    raspberry_jam = {
        source = "raspberry_jam",
        target = "raspberry_jam_plus",
        source_desc = "Raspberry jam",
        target_desc = "Old raspberry jam"
    },
    rhubarb_jam = {
        source = "rhubarb_jam",
        target = "rhubarb_jam_plus",
        source_desc = "Rhubarb jam",
        target_desc = "Old rhubarb jam"
    },
    rose_jam = {
        source = "rose_jam",
        target = "rose_jam_plus",
        source_desc = "Rose petal jam",
        target_desc = "Old rose petal jam"
    },
    strawberry_jam = {
        source = "strawberry_jam",
        target = "strawberry_jam_plus",
        source_desc = "Strawberry jam",
        target_desc = "Old strawberry jam"
    }
}

for _,v in pairs(foods) do
    local itemstring = {v.source, v.target}
    local itemdesc = {v.source_desc, v.target_desc}
    yl_canned_food.register_food(itemstring, itemdesc, origin)
end
