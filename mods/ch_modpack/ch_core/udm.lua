ch_core.open_submod("udm", {areas = true, data = true, lib = true})

local color_celoserverovy = minetest.get_color_escape_sequence("#ff8700")
local color_mistni = minetest.get_color_escape_sequence("#fff297")
local color_mistni_zblizka = minetest.get_color_escape_sequence("#64f231") -- 54cc29
local color_soukromy = minetest.get_color_escape_sequence("#ff4cf3")
local color_sepot = minetest.get_color_escape_sequence("#fff297cc")
local color_systemovy = minetest.get_color_escape_sequence("#cccccc")
local color_reset = minetest.get_color_escape_sequence("#ffffff")

function ch_core.udm_catch_chat(player_name, message)
    local pinfo = ch_core.normalize_player(player_name)
    if message == "test" then
        minetest.chat_send_player(player_name, color_mistni..pinfo.viewname..": test "..color_systemovy.."[0 post.]")
        minetest.chat_send_player(player_name, "* Správně! Takto byste napsali zprávu postavám ve vašem okolí. Za zprávou se vypsalo „[0 post.]“, "..
            "což znamená, že ve skutečnosti nikomu nedošla. Kdyby došla, řekněme, na dva další herní klienty, bylo by tam „[2 post.]“.\nNyní zkuste zadat: !test")
    elseif message == "!test" then
        minetest.chat_send_player(player_name, color_celoserverovy..pinfo.viewname..": test "..color_systemovy.."[1 post.]")
        minetest.chat_send_player(player_name, color_celoserverovy.."Fiktivní postava: odpověď "..color_systemovy.."(563 m)")
        minetest.chat_send_player(player_name, "* Správně! Takto byste napsali zprávu na všechny herní klienty připojené k serveru. A rovněž vám odpověděla "..
            "Fiktivní postava (která ve skutečnosti neexistuje, je to jen ukázka). Za její zprávou se ukázalo (563 m), což by znamenalo, že se nachází "..
            "563 metrů od vás.\nNyní zkuste zadat: \"Fik test")
    elseif message == "\"Fik test" or message == "\"Fiktivní_postava test" or message == "\"Fiktivni_postava test" then
        minetest.chat_send_player(player_name, color_soukromy.."-> Fiktivní postava: test")
        minetest.chat_send_player(player_name, color_soukromy.."Fiktivní postava: odpověď 1")
        minetest.chat_send_player(player_name, "* Správně! Právě jste (jako) napsali Fiktivní postavě soukromou zprávu a ona vám odpověděla. "..
            "U další zprávy už můžete předponu jména vynechat, protože systém si pamatuje, komu jste psali soukromou zprávu naposledy.\n"..
            "Nyní tedy zkuste zadat: \" test 2")
    elseif message == "\" test 2" then
        minetest.chat_send_player(player_name, color_soukromy.."-> Fiktivní postava: test 2")
        minetest.chat_send_player(player_name, color_soukromy.."Fiktivní postava: odpověď 2")
        minetest.chat_send_player(player_name, "* Správně!\n"..
            "To je vše, co zatím potřebujete vědět o ovládání četu. Můžete pokročit k dalšímu tématu.")
    else
        minetest.chat_send_player(player_name, "* Napsali jste: „"..message.."“, což není to, co jste měli. Zkuste to, prosím, znovu, nebo opusťte zelený čtverec.")
    end
    minetest.log("action", "UDM chat catched a message: >"..message.."<")
    return true
end

local function nastavit_udm_zachyceni(player_name, area_id)
    local area_id_number = tonumber(area_id)
    if area_id_number == nil or area_id_number ~= math.floor(area_id_number) or area_id_number <= 0 then
        return false, "Chybné ID oblasti!"
    end
    local area = ch_core.areas[area_id_number]
    if area == nil then
        area = {}
        ch_core.areas[area_id_number] = area
        area.udm_catch_chat = true
    elseif area.udm_catch_chat then
        area.udm_catch_chat = false
        ch_core.save_areas()
        return true, "Zachycení zrušeno pro oblast č. "..area_id_number
    else
        area.udm_catch_chat = true
    end
    ch_core.save_areas()
    return true, "Zachycení nastaveno pro oblast č. "..area_id_number
end

local def = {
    params = "<id_oblasti>",
    description = "Pro danou oblast zapne/vypne funkci zachycení četu pro ÚDM",
    privs = {server = true},
    func = nastavit_udm_zachyceni,
}

minetest.register_chatcommand("nastavit_údm_zachycení", def)
minetest.register_chatcommand("nastavit_udm_zachyceni", def)

ch_core.close_submod("udm")
