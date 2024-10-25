-- Use this file to initialize variables once after server start and check everything is in place

local function run_each_serverstart()
    assert(yl_canned_food_mtg.check_settings_match(),yl_canned_food_mtg.t("settings_dont_match"))
    yl_canned_food_mtg.data = yl_canned_food_mtg.get_data()
end

run_each_serverstart()
