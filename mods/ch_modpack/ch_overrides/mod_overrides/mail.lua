ch_core.register_event_type("mail_received", {
    description = "obdržena pošta",
    access = "player_only",
    chat_access = "player_only",
})

local function on_receive(m)
    local recipients = {}
    local od = ch_core.prihlasovaci_na_zobrazovaci(m.from)
    local s = m.to..","..m.cc..","..m.bcc
    for _, name in ipairs(string.split(s, ",", false)) do
        if ch_data.offline_charinfo[name] ~= nil then
            recipients[name] = true
        end
    end
    for name, _ in pairs(recipients) do
        ch_core.add_event("mail_received", "Obdržel/a jste zprávu od "..od..": "..m.subject, name)
    end
end
mail.register_on_receive(on_receive)
