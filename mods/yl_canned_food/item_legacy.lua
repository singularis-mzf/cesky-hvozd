if (yl_canned_food.settings.legacy ~= true) then
    return
end

local origin = "canned_food"

local foods = {
    apple_jam = {
        source = "apple_jam",
        target = "apple_jam_plus",
        source_desc = "jablečná marmeláda",
        target_desc = "jablečná marmeláda"
    },
    banana_jam = {
        source = "banana_jam",
        target = "banana_jam_plus",
        source_desc = "banánový džem",
        target_desc = "banánový džem",
    },
    blackberry_jam = {
        source = "blackberry_jam",
        target = "blackberry_jam_plus",
        source_desc = "ostružinová marmeláda",
        target_desc = "ostružinová marmeláda"
    },
    blueberry_jam = {
        source = "blueberry_jam",
        target = "blueberry_jam_plus",
        source_desc = "borůvková marmeláda",
        target_desc = "borůvková marmeláda"
    },
    canned_beans = {
        source = "canned_beans",
        target = "canned_beans_plus",
        source_desc = "nakládané fazole",
        target_desc = "nakládané fazole"
    },
    canned_beetroot = {
        source = "canned_beetroot",
        target = "canned_beetroot_plus",
        source_desc = "zavařená červená řepa",
        target_desc = "zavařená červená řepa"
    },
    canned_cabbage = {
        source = "canned_cabbage",
        target = "canned_cabbage_plus",
        source_desc = "zavařená kapusta",
        target_desc = "zavařená kapusta"
    },
    canned_carrot = {
        source = "canned_carrot",
        target = "canned_carrot_plus",
        source_desc = "nakládané mrkve",
        target_desc = "nakládané mrkve"
    },
    canned_chili_pepper = {
        source = "canned_chili_pepper",
        target = "canned_chili_pepper_plus",
        source_desc = "nakládané čili papričky",
        target_desc = "nakládané čili papričky"
    },
    canned_coconut = {
        source = "canned_coconut",
        target = "canned_coconut_plus",
        source_desc = "nakládaný kokos",
        target_desc = "nakládaný kokos"
    },
    canned_corn = {
        source = "canned_corn",
        target = "canned_corn_plus",
        source_desc = "nakládané kukuřičné klasy",
        target_desc = "nakládané kukuřičné klasy"
    },
    canned_cucumber = {
        source = "canned_cucumber",
        target = "canned_cucumber_plus",
        source_desc = "nakládané okurky",
        target_desc = "nakládané okurky"
    },
    canned_garlic_cloves = {
        source = "canned_garlic_cloves",
        target = "canned_garlic_cloves_plus",
        source_desc = "nakládaný česnek",
        target_desc = "nakládaný česnek"
    },
    canned_mushrooms = {
        source = "canned_mushrooms",
        target = "canned_mushrooms_plus",
        source_desc = "zavařené žampiony",
        target_desc = "zavařené žampiony"
    },
    canned_onion = {
        source = "canned_onion",
        target = "canned_onion_plus",
        source_desc = "nakládaná cibule",
        target_desc = "nakládaná cibule"
    },
    canned_peas = {
        source = "canned_peas",
        target = "canned_peas_plus",
        source_desc = "zavařený hrášek",
        target_desc = "zavařený hrášek"
    },
    canned_pineapple = {
        source = "canned_pineapple",
        target = "canned_pineapple_plus",
        source_desc = "zavařené ananasové kroužky",
        target_desc = "zavařené ananasové kroužky"
    },
    canned_potato = {
        source = "canned_potato",
        target = "canned_potato_plus",
        source_desc = "nakládané brambory",
        target_desc = "nakládané brambory"
    },
    canned_pumpkin = {
        source = "canned_pumpkin",
        target = "canned_pumpkin_plus",
        source_desc = "dýňová marmeláda",
        target_desc = "dýňová marmeláda"
    },
    canned_tomato = {
        source = "canned_tomato",
        target = "canned_tomato_plus",
        source_desc = "zavařená rajčata",
        target_desc = "zavařená rajčata"
    },
    dandelion_jam = {
        source = "dandelion_jam",
        target = "dandelion_jam_plus",
        source_desc = "pampelišková marmeláda",
        target_desc = "pampelišková marmeláda"
    },
    grape_jam = {
        source = "grape_jam",
        target = "grape_jam_plus",
        source_desc = "hroznová marmeláda",
        target_desc = "hroznová marmeláda"
    },
    honey_jar = {
        source = "honey_jar",
        target = "honey_jar_plus",
        source_desc = "sklenice medu",
        target_desc = "sklenice medu"
    },
    lemon_jam = {
        source = "lemon_jam",
        target = "lemon_jam_plus",
        source_desc = "citrónová marmeláda",
        target_desc = "citrónová marmeláda"
    },
    melon_jam = {
        source = "melon_jam",
        target = "melon_jam_plus",
        source_desc = "melounová marmeláda",
        target_desc = "melounová marmeláda"
    },
    orange_jam = {
        source = "orange_jam",
        target = "orange_jam_plus",
        source_desc = "pomerančová marmeláda",
        target_desc = "pomerančová marmeláda"
    },
    pine_nuts_jar = {
        source = "pine_nuts_jar",
        target = "pine_nuts_jar_plus",
        source_desc = "zavařené smrkové šišky",
        target_desc = "zavařené smrkové šišky"
    },
    raspberry_jam = {
        source = "raspberry_jam",
        target = "raspberry_jam_plus",
        source_desc = "malinová marmeláda",
        target_desc = "malinová marmeláda"
    },
    rhubarb_jam = {
        source = "rhubarb_jam",
        target = "rhubarb_jam_plus",
        source_desc = "rebarborová marmeláda",
        target_desc = "rebarborová marmeláda"
    },
    rose_jam = {
        source = "rose_jam",
        target = "rose_jam_plus",
        source_desc = "růžová marmeláda",
        target_desc = "růžová marmeláda"
    },
    strawberry_jam = {
        source = "strawberry_jam",
        target = "strawberry_jam_plus",
        source_desc = "jahodová marmeláda",
        target_desc = "jahodová marmeláda"
    }
}

for _,v in pairs(foods) do
    local itemstring = {v.source, v.target}
    local itemdesc = {v.source_desc, v.target_desc}
    yl_canned_food.register_food(itemstring, itemdesc, origin)
end
