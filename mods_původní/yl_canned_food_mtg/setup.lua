if yl_canned_food_mtg.settings.data_source ~= "json" then
    return false
end

local mkdir = minetest.mkdir
local save_path = yl_canned_food_mtg.settings.save_path

local function run_once()
    local path = yl_canned_food_mtg.worldpath .. DIR_DELIM .. save_path
    local file = io.open(path, "r")
    if not file then
        mkdir(path)
    else
        file:close()
    end

end

run_once()
