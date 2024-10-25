-- Setting a configuration, switch the order in which the settings shall take precedence. First valid one taken.
yl_canned_food_mtg.settings = {}

yl_canned_food_mtg.settings.debug = minetest.settings:get_bool(
                                        "yl_canned_food_mtg.debug", false)

yl_canned_food_mtg.settings.enable_recipes =
    minetest.settings:get_bool("yl_canned_food_mtg.enable_recipes", true)

yl_canned_food_mtg.settings.enable_eat =
    minetest.settings:get_bool("yl_canned_food_mtg.enable_eat", true)

yl_canned_food_mtg.settings.enable_unified_inventory =
    minetest.settings:get_bool("yl_canned_food_mtg.enable_unified_inventory",
                               true)

yl_canned_food_mtg.settings.data_source =
    minetest.settings:get("yl_canned_food_mtg.data_source") or "default"

yl_canned_food_mtg.settings.save_path = minetest.settings:get("yl_scheduler.yl_canned_food_mtg") or "yl_canned_food_mtg"