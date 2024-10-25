local S = minetest.get_translator(yl_canned_food_mtg.modname)

local texts = {}

--function yl_canned_food_mtg.t(key, ...) return S(texts[key], ...) or "" end
function yl_canned_food_mtg.t(key, ...)
    if (texts[key] == nil) then
        minetest.log("warning","key " .. (key or "") .. " does not exist")
        return key
    end
    return S(texts[key], ...) or ""
end

-- Fixed texts

texts["log_prefix"] = "[MOD] @1 : @2"

-- Translateable texts

texts["information_additional"] = "Craft and eat yl_canned_food in mtg"

texts["unified_inventory_register_craft_type_description"] = "Place in a dark room"


texts["chatcommand_admin_description"] = "Admin Chatcommand description"
texts["chatcommand_admin_parameters"] = "<name> <privilege>"
texts["chatcommand_admin_success_message"] = "Sucess message"
texts["chatcommand_admin_fail_message"] = "Fail message"

texts["chatcommand_player_description"] = "Player Chatcommand description"
texts["chatcommand_player_parameters"] = "<name> <privilege>"
texts["chatcommand_player_success_message"] = "Sucess message"
texts["chatcommand_player_fail_message"] = "Fail message"

texts["api_sent_x_to_y"] = "Sent @1 to @2"

texts["privs_example_description"] = "Can do example task"
texts["privs_example_grant_logmessage"] = "User @1 granted priv @2 to user @3"
texts["privs_example_revoke_logmessage"] =
    "User @1 revoked priv @2 from user @3"

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
