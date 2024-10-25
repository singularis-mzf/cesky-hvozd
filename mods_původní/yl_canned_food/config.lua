
yl_canned_food.settings = {}

yl_canned_food.settings.debug = minetest.settings:get_bool("yl_canned_food.debug",false)

yl_canned_food.settings.freeze = minetest.settings:get_bool("yl_canned_food.freeze",false)

yl_canned_food.settings.legacy = minetest.settings:get_bool("yl_canned_food.legacy",false)

yl_canned_food.settings.duration = minetest.settings:get("yl_canned_food.duration") or 600

yl_canned_food.settings.max_light = minetest.settings:get("yl_canned_food.max_light") or 5

yl_canned_food.settings.chance = minetest.settings:get("yl_canned_food.chance") or 33