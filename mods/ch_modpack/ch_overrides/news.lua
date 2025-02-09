local has_bulletin_boards = minetest.get_modpath("bulletin_boards")

function ch_overrides.novinky(player_name, param)
    local online_charinfo = ch_data.online_charinfo[player_name]
    local oc_role = online_charinfo and online_charinfo.news_role
    if oc_role == nil then
        minetest.log("error", "online_charinfo.news_role not defined for "..(player_name or "nil").."!")
        return false, "Vnitřní chyba: role není definována!"
    end
    if oc_role == "new_player" then
        ch_core.show_new_player_formspec(player_name)
    elseif oc_role == "player" and has_bulletin_boards then
        bulletin_boards.show_welcome_formspec(player_name, false)
    end
    return true
end

local def = {
    params = "",
    description = "Zobrazí úvodní obrazovku, která se vám zobrazila při vstupu do hry.",
    privs = {},
    func = ch_overrides.novinky,
}

minetest.register_chatcommand("novinky", def)
