-- The functions and variables in this file are only for use in the mod itself.
-- Those that do real work should be local and wrapped in public functions
local function log(text)
    local logmessage = yl_canned_food_mtg.t("log_prefix", yl_canned_food_mtg.modname, text)
    if yl_canned_food_mtg.settings.debug then minetest.log("action", logmessage) end
    return logmessage
end

function yl_canned_food_mtg.log(text) return log(text) end

local function get_savepath()
    local savepath = yl_canned_food_mtg.worldpath .. yl_canned_food_mtg.settings.save_path
    log(yl_canned_food_mtg.t("log_prefix", dump(savepath), ""))
    return savepath
end

local function get_filepath(filename)
    local path_to_file = get_savepath() .. DIR_DELIM .. filename .. ".json"
    log(yl_canned_food_mtg.t("get_filepath", dump(filename), dump(path_to_file)))
    return path_to_file
end

local function save_json(filename, content)
    if type(filename) ~= "string" or type(content) ~= "table" then
        return false
    end
    local savepath = get_filepath(filename)
    local savecontent = minetest.write_json(content)
    return minetest.safe_file_write(savepath, savecontent)
end

local function load_json(path)
    local file = io.open(path, "r")
    if not file then
        return false, yl_canned_food_mtg.t("error_cannot_open_file", dump(path))
    end

    local content = file:read("*all")
    file:close()

    if not content then
        return false, yl_canned_food_mtg.t("error_cannot_read_file", dump(path))
    end

    return true, minetest.parse_json(content)
end

-- Public functions wrap the private ones, so they can be exchanged easily

function yl_canned_food_mtg.get_filepath(filename)
    return get_filepath(filename)
end

function yl_canned_food_mtg.load(filename, ...) return load_json(filename, ...) end

function yl_canned_food_mtg.save(filename, content, ...)
    return save_json(filename, content, ...)
end

-- Read data
--

local function get_data()

    local filename = yl_canned_food_mtg.settings.save_path
    local filepath = yl_canned_food_mtg.get_filepath(filename)
    yl_canned_food_mtg.json_recipes = yl_canned_food_mtg.load(filepath) or {}

    return yl_canned_food_mtg.legacy_recipes or yl_canned_food_mtg.default_recipes or yl_canned_food_mtg.json_recipes
end

function yl_canned_food_mtg.get_data()
    return get_data()
end

-- Check sttings match
--

local function check_settings_match()
    if (yl_canned_food.settings.legacy == true) and (yl_canned_food_mtg.settings.data_source == "legacy") then
        -- legacy: Nodenames looke like canned_food:apple_jam
        return true
    elseif (yl_canned_food.settings.legacy == false) and (yl_canned_food_mtg.settings.data_source == "default") then
        -- default: Nodenames looke like yl_canned_food:apple_jam
        return true
    elseif (yl_canned_food_mtg.settings.data_source == "json") then
        -- json: It's the user's responsibility to adjust the nodenames in the json
        return true
    else
        return false
    end
end

function yl_canned_food_mtg.check_settings_match()
    return check_settings_match()
end