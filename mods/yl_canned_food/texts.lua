local S = minetest.get_translator(yl_canned_food.modname)

local texts = {}

function yl_canned_food.t(key, ...) return S(texts[key], ...) or "" end

-- Fixed texts

texts["log_prefix"] = "[MOD] @1 : @2"

-- Translateable texts

texts["information_additional"] = "Adds canned food"

-- Errormessages

texts["error_not_a_string"] = "@1 not a string"
texts["error_player_not_online"] = "@1 not an online player"
texts["error_not_a_colorspec"] = "@1 not a ColorSpec"
texts["error_not_a_position"] = "@1 not a position"
texts["error_function_not_available"] = "@1 not available"

texts["error_cannot_open_file"] = "Error opening file: @1"
texts["error_cannot_read_file"] = "Error reading file: @1"

texts["error_name_not_found"] = "Name not found: @1"
texts["error_priv_not_found"] = "Priv not found: @1"
