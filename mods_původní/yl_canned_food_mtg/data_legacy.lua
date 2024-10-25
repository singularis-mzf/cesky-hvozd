if (yl_canned_food_mtg.settings.data_source ~= "legacy") then
    return false
end

yl_canned_food_mtg.legacy_recipes = {
    {
        additives = {},
        nutrition = 6,
        out = "canned_food:canned_mushrooms",
        base_mod = "flowers",
        base_item = "mushroom_brown",
        base_amount = 5
    }, {
        additives = {},
        nutrition = 20,
        out = "canned_food:honey_jar",
        base_mod = "mobs",
        base_item = "honey",
        base_amount = 4
    }, {
        additives = {},
        nutrition = 6,
        out = "canned_food:canned_potato",
        base_mod = "farming",
        base_item = "potato",
        base_amount = 5
    }, {
        additives = {},
        nutrition = 6,
        out = "canned_food:canned_beetroot",
        base_mod = "farming",
        base_item = "beetroot",
        base_amount = 5
    }, {
        additives = {},
        nutrition = 6,
        out = "canned_food:canned_pineapple",
        base_mod = "farming",
        base_item = "pineapple_ring",
        base_amount = 5
    }, {
        additives = {},
        nutrition = 15,
        out = "canned_food:canned_cucumber",
        base_mod = "farming",
        base_item = "cucumber",
        base_amount = 3
    }, {
        additives = {},
        nutrition = 10,
        out = "canned_food:pine_nuts_jar",
        base_mod = "ethereal",
        base_item = "pine_nuts",
        base_amount = 8
    }, {
        additives = {},
        nutrition = 5,
        out = "canned_food:canned_onion",
        base_mod = "farming",
        base_item = "onion",
        base_amount = 4
    }, {
        additives = {"group:food_sugar"},
        nutrition = 7,
        out = "canned_food:strawberry_jam",
        base_mod = "ethereal",
        base_item = "strawberry",
        base_amount = 5
    }, {
        additives = {},
        nutrition = 15,
        out = "canned_food:canned_tomato",
        base_mod = "farming",
        base_item = "tomato",
        base_amount = 3
    }, {
        additives = {},
        nutrition = 5,
        out = "canned_food:canned_garlic_cloves",
        base_mod = "farming",
        base_item = "garlic_clove",
        base_amount = 8
    }, {
        additives = {},
        nutrition = 8,
        out = "canned_food:blueberry_jam",
        base_mod = "default",
        base_item = "blueberries",
        base_amount = 7
    },{
        additives = {"group:food_sugar"},
        nutrition = 8,
        out = "canned_food:blueberry_jam",
        base_mod = "farming",
        base_item = "blueberries",
        base_amount = 5
    }, {
        additives = {},
        nutrition = 7,
        out = "canned_food:canned_pumpkin",
        base_mod = "farming",
        base_item = "pumpkin_slice",
        base_amount = 3
    }, {
        additives = {},
        nutrition = 11,
        out = "canned_food:canned_corn",
        base_mod = "farming",
        base_item = "corn",
        base_amount = 3
    }, {
        additives = {"group:food_sugar"},
        nutrition = 8,
        out = "canned_food:blackberry_jam",
        base_mod = "farming",
        base_item = "blackberry",
        base_amount = 6
    }, {
        additives = {},
        nutrition = 10,
        out = "canned_food:canned_peas",
        base_mod = "farming",
        base_item = "peas",
        base_amount = 8
    }, {
        additives = {},
        nutrition = 7,
        out = "canned_food:canned_beans",
        base_mod = "farming",
        base_item = "beans",
        base_amount = 6
    }, {
        additives = {"group:food_sugar"},
        nutrition = 8,
        out = "canned_food:raspberry_jam",
        base_mod = "farming",
        base_item = "raspberries",
        base_amount = 6
    }, {
        additives = {},
        nutrition = 7,
        out = "canned_food:apple_jam",
        base_mod = "default",
        base_item = "apple",
        base_amount = 3
    }, {
        additives = {},
        nutrition = 7,
        out = "canned_food:canned_chili_pepper",
        base_mod = "farming",
        base_item = "chili_pepper",
        base_amount = 6
    }, {
        additives = {"group:food_sugar"},
        nutrition = 11,
        out = "canned_food:grape_jam",
        base_mod = "farming",
        base_item = "grapes",
        base_amount = 4
    }, {
        additives = {},
        nutrition = 6,
        out = "canned_food:canned_coconut",
        base_mod = "ethereal",
        base_item = "coconut_slice",
        base_amount = 5
    }, {
        additives = {},
        nutrition = 15,
        out = "canned_food:canned_carrot",
        base_mod = "farming",
        base_item = "carrot",
        base_amount = 3
    }, {
        additives = {"group:food_sugar"},
        nutrition = 8,
        out = "canned_food:rhubarb_jam",
        base_mod = "farming",
        base_item = "rhubarb",
        base_amount = 6
    }, {
        additives = {"group:food_sugar"},
        nutrition = 7,
        out = "canned_food:banana_jam",
        base_mod = "ethereal",
        base_item = "banana",
        base_amount = 5
    }, {
        additives = {},
        nutrition = 6,
        out = "canned_food:dandelion_jam",
        base_mod = "flowers",
        base_item = "dandelion_yellow",
        base_amount = 5
    }, {
        additives = {"group:food_sugar"},
        nutrition = 8,
        out = "canned_food:melon_jam",
        base_mod = "farming",
        base_item = "melon_slice",
        base_amount = 3
    }, {
        additives = {},
        nutrition = 6,
        out = "canned_food:rose_jam",
        base_mod = "flowers",
        base_item = "rose",
        base_amount = 5
    }, {
        additives = {"group:food_sugar"},
        nutrition = 8,
        out = "canned_food:orange_jam",
        base_mod = "ethereal",
        base_item = "orange",
        base_amount = 3
    }, {
        additives = {},
        nutrition = 6,
        out = "canned_food:canned_cabbage",
        base_mod = "farming",
        base_item = "cabbage",
        base_amount = 5
    }, {
        additives = {"group:food_sugar"},
        nutrition = 6,
        out = "canned_food:lemon_jam",
        base_mod = "ethereal",
        base_item = "lemon",
        base_amount = 6
    }
}
