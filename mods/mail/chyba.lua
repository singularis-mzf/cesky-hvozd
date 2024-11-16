local old_chyba_handler = assert(ch_core.overridable.chyba_handler)

function ch_core.overridable.chyba_handler(player, text)
    old_chyba_handler(player, text)
    local cas = ch_core.aktualni_cas()
    local pos = vector.round(player:get_pos())
    local success, err_message = mail.send({
        from = player:get_player_name(),
        to = "Administrace",
        cc = "",
        bcc = "",
        subject = ch_core.utf8_truncate_right("[hlášení chyby] "..text, 40),
        body = "Nahlásil/a: "..ch_core.prihlasovaci_na_zobrazovaci(player:get_player_name())..
            "\nČas: "..string.format("%04d-%02d-%02d %02d:%02d:%02d (UTC hodina %02d)",
                cas.rok, cas.mesic, cas.den, cas.hodina, cas.minuta, cas.sekunda, cas.utc_hodina)..
            "\nPozice: "..minetest.pos_to_string(pos).."\n/chyba "..text,
    })
    if not success then
        minetest.log("error", "Chyba při odesílání zprávy o chybě: "..(err_message or "nil"))
    end
end
