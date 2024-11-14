local required_privs = {server = true}
local F = minetest.formspec_escape
local error_color = ch_core.colors.red

local function get_formspec(custom_state)
    local formspec = {
        ch_core.formspec_header({
            formspec_version = 6,
            size = {12, 12.75},
            auto_background = true,
        }),
        "label[0.5,0.85;Kód jazyka Lua]"..
        "button_exit[11,0.25;0.75,0.75;close;X]"..
        "textarea[0.5,1.75;11,9;program;program:;",
        F(custom_state.text),
        "]"..
        "button[0.25,11.75;11.5,0.75;run;Spustit]",
    }
    return table.concat(formspec)
end

local function formspec_callback(custom_state, player, formname, fields)
    local player_name = player:get_player_name()
    if not minetest.check_player_privs(player, required_privs) then
        minetest.close_formspec(player_name, formname)
        fields.quit = "true"
        ch_core.systemovy_kanal(player_name, error_color.."Nemáte dostatečné oprávnění!")
        return
    end
    if fields.program then
        custom_state.text = fields.program
    end
    if fields.run then
        local func, success, errmsg
        func, errmsg = loadstring(custom_state.text)
        if not func then
            ch_core.systemovy_kanal(player_name, error_color.."Chyba syntaxe: "..(errmsg or "nil"))
        else
            local timestamp = minetest.get_us_time()
            success, errmsg = pcall(func)
            if success then
                ch_core.systemovy_kanal(player_name, "Kód vykonán za "..((minetest.get_us_time() - timestamp) / 1000000).." sekund.")
            else
                ch_core.systemovy_kanal(player_name, error_color.."Chyba: "..(errmsg or "nil"))
            end
        end
    end
    if not fields.quit then
        return get_formspec(custom_state)
    end
end

minetest.register_chatcommand("lua", {
    params = "",
    description = "Otevře rozhraní pro spouštění příkazů jazyka Lua",
    privs = required_privs,
    func = function(player_name, param)
        if ch_core.online_charinfo[player_name] == nil or not minetest.check_player_privs(player_name, required_privs) then
            return false, "Neplatné volání!"
        end
        local custom_state = {
            text = "",
        }
        ch_core.show_formspec(player_name, "ch_test:lua", get_formspec(custom_state), formspec_callback, custom_state, {})
        return true
    end,
})
