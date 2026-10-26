local default_sounds = {
    -- text, {name, length [, parameters (gain, pitch, fade, start_time)]}
    -- length = jak dlouho má systém očekávat, že zvuk bude hrát
    -- Linka S3
    {"Český hvozd hl. nádr.", {{name = "ch_say_pz_hln", start_time = 1.35, length = 4.1 - 1.35}}},
    {"Březová Pila", {{name = "ch_say_pz_brp", start_time = 1.35, length = 2.5 - 1.35}}},
    {"Rajská zahrada", {{name = "ch_say_pz_rz", start_time = 1.35, length = 2.85 - 1.35}}},
    {"Česká Amazonie", {{name = "ch_say_pz_cas", start_time = 1.35, length = 3 - 1.35}}},
    {"Klárský průsmyk", {{name = "ch_say_pz_klp", start_time = 1.35, length = 2.85 - 1.35}}},
    {"Jižní Kaštan", {{name = "ch_say_pz_jka", start_time = 1.35, length = 2.8 - 1.35}}},
    {"Most Vzkříšení", {{name = "ch_say_pz_mvz", start_time = 1.35, length = 2.9 - 1.35}}},
    {"Vánoční ostrov", {{name = "ch_say_pz_vo", start_time = 1.35, length = 3.0 - 1.35}}},
    {"Příští zastávka: Český hvozd hl. nádr.", {{name = "ch_say_pz_hln", length = 4.1}}},
    {"Příští zastávka: Březová Pila", {{name = "ch_say_pz_brp", length = 2.5}}},
    {"Příští zastávka: Rajská zahrada", {{name = "ch_say_pz_rz", length = 2.85}}},
    {"Příští zastávka: Česká Amazonie", {{name = "ch_say_pz_cas", length = 3}}},
    {"Příští zastávka: Klárský průsmyk", {{name = "ch_say_pz_klp", length = 2.85}}},
    {"Příští zastávka: Jižní Kaštan", {{name = "ch_say_pz_jka", length = 2.8}}},
    {"Příští zastávka: Most Vzkříšení", {{name = "ch_say_pz_mvz", length = 2.9}}},
    {"Příští zastávka: Vánoční ostrov", {{name = "ch_say_pz_vo", length = 3.0}}},
    -- pauza
    {"__pauza__", {{name = "", length = 1.0}}},
}

local set = {}

for _, s in ipairs(default_sounds) do
    local text = s[1]
    ch_say.register_sound(text, s[2])
end
