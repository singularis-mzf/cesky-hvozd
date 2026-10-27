local default_sounds = {
    -- text, {name, length [, parameters (gain, pitch, fade, start_time)] [, replacement_from [, replacement_to]]}
    -- length = jak dlouho má systém očekávat, že zvuk bude hrát
    -- Linka S1 (cílové vedení)
    {"Český hvozd hl. nádr.", {{name = "ch_say_pz_hln", start_time = 1.45, length = 4.1}}},
    {"Výstaviště", {{name = "ch_say_pz_vys", start_time = 1.35, length = 2.35}}},
    {"Dvořákův dvůr", {{name = "ch_say_pz_dvd", start_time = 1.35, length = 3}}},
    {"Český hvozd, střed", {{name = "ch_say_pz_str", start_time = 1.35, length = 3.15}}},
    -- Linka S2 (cílové vedení)
    {"Tyršovo náměstí", {{name = "ch_say_pz_tyr", start_time = 1.35, length = 2.75}}},
    {"Pískoviště, hotel", {{name = "ch_say_pz_pih", start_time = 1.35, length = 3.8}}},
    {"Pískoviště", {{name = "ch_say_pz_pis", start_time = 1.35, length = 3.05}}},
    {"Rasterdam", {{name = "ch_say_pz_ras", start_time = 1.35, length = 2.85, sk = true, replacement_from = "Koncová zastávka", replacement_to = "Koncová zastávka (sk)"}}},
    {"Hrošie jazero", {{name = "ch_say_pz_hrj", start_time = 1.35, length = 3.15, sk = true}}},
    {"Severka", {{name = "ch_say_pz_sev", start_time = 1.35, length = 2.30, sk = true, replacement_from = "Koncová zastávka", replacement_to = "Koncová zastávka (sk)"}}},
    -- Linka S3
    {"Březová Pila", {{name = "ch_say_pz_brp", start_time = 1.35, length = 2.5}}},
    {"Rajská zahrada", {{name = "ch_say_pz_rz", start_time = 1.35, length = 2.85}}},
    {"Česká Amazonie", {{name = "ch_say_pz_cas", start_time = 1.35, length = 3}}},
    {"Klárský průsmyk", {{name = "ch_say_pz_klp", start_time = 1.35, length = 2.85}}},
    {"Jižní Kaštan", {{name = "ch_say_pz_jka", start_time = 1.35, length = 2.8}}},
    {"Most Vzkříšení", {{name = "ch_say_pz_mvz", start_time = 1.35, length = 2.9}}},
    {"Vánoční ostrov", {{name = "ch_say_pz_vo", start_time = 1.35, length = 3.0}}},
    -- Linka S4
    {"Meziřečí", {{name = "ch_say_pz_mez", start_time = 1.35, length = 2.45}}}, 
    {"Česká", {{name = "ch_say_pz_ces", start_time = 1.35, length = 2.2}}},
    {"Květná", {{name = "ch_say_pz_kve", start_time = 1.35, length = 2.05}}},
    {"Králiky", {{name = "ch_say_pz_kra", start_time = 1.35, length = 2.30}}},
    {"Třešňová", {{name = "ch_say_pz_tre", start_time = 1.35, length = 2.25}}},
    {"Lhota pod Točnou", {{name = "ch_say_pz_lpt", start_time = 1.35, length = 2.9}}},
    {"Věčný Jeseník", {{name = "ch_say_pz_vej", start_time = 1.35, length = 2.6}}},
    {"Duhový most", {name = "ch_say_pz_duhm", start_time = 1.35, length = 2.5}},
    {"Úskalí", {name = "ch_say_pz_usk", start_time = 1.35, length = 2.20}},
    -- Linka S5
    {"Tunel Koniklec", {{name = "ch_say_pz_kon", start_time = 1.35, length = 3.1}}},
    {"Mariánský hájek", {{name = "ch_say_pz_mha", start_time = 1.35, length = 2.9}}},
    {"Kamenný most", {{name = "ch_say_pz_kmo", start_time = 1.35, length = 2.5}}},
    {"Hlavní výpočetní středisko", {{name = "ch_say_pz_hvs", start_time = 1.35, length = 3.5}}},
    -- Linka P1
    {"Červený písek", {{name = "ch_say_pz_cep", start_time = 1.35, length = 3.25}}},
    {"Útulná skrýš", {{name = "ch_say_pz_uskr", start_time = 1.35, length = 3.1}}},
    {"Česká Amazonie - výzkumná stanice", {{name = "ch_say_pz_cav", start_time = 1.35, length = 5}}},
    {"Úhlopříčný průplav", {{name = "ch_say_pz_uhp", start_time = 1.35, length = 3.15}}},
    {"Ostrov Zikmunda a Hanzelky", {{name = "ch_say_pz_ozh", start_time = 1.35, length = 3.75}}},
    {"Úzké hrdlo", {{name = "ch_say_pz_uhr", start_time = 1.35, length = 2.55}}},
    {"Mys Dobré snídaně", {{name = "ch_say_pz_mds", start_time = 1.35, length = 3}}},
    {"Zátoka Dobré večeře", {{name = "ch_say_pz_zdv", start_time = 1.35, length = 3.1}}},
    {"Tichý západ", {{name = "ch_say_pz_tiz", start_time = 1.35, length = 2.75}}},
    -- Linka 101
    {"Haškova", {{name = "ch_say_pz_has", start_time = 1.35, length = 2.4}}},
    {"Gumová", {{name = "ch_say_pz_gum", start_time = 1.35, length = 2.4}}},
    {"Serengeti", {{name = "ch_say_pz_ser", start_time = 1.35, length = 2.4}}},
    {"Serengeti, točna", {{name = "ch_say_pz_sert", start_time = 1.35, length = 3.5}}},
    -- Linka 1 (Rasterdam)
    {"Slovenská", {{name = "ch_say_pz_rslo", start_time = 1.35, length = 2.5, sk = true}}},
    {"Merveillská", {{name = "ch_say_pz_rmer", start_time = 1.35, length = 3, sk = true}}},
    {"Brdárska", {{name = "ch_say_pz_rbrd", start_time = 1.35, length = 2.55, sk = true}}},
    {"Solárna", {{name = "ch_say_pz_rsol", start_time = 1.35, length = 2.4, sk = true}}},
    -- Linka 2 (Rasterdam)
    {"Zajačí vrch", {{name = "ch_say_pz_rzav", start_time = 1.35, length = 2.85, sk = true}}},
    {"Veterná", {{name = "ch_say_pz_rvet", start_time = 1.35, length = 3.1, sk = true}}},
    --

    -- Linka S1 (cílové vedení)
    {"Příští zastávka: Český hvozd hl. nádr.", {{name = "ch_say_pz_hln", length = 4.1}}},
    {"Příští zastávka: Výstaviště", {{name = "ch_say_pz_vys", length = 2.35}}},
    {"Příští zastávka: Dvořákův dvůr", {{name = "ch_say_pz_dvd", length = 3}}},
    {"Příští zastávka: Český hvozd, střed", {{name = "ch_say_pz_str", length = 3.15}}},
    -- Linka S2 (cílové vedení)
    {"Příští zastávka: Tyršovo náměstí", {{name = "ch_say_pz_tyr", length = 2.75}}},
    {"Příští zastávka: Pískoviště, hotel", {{name = "ch_say_pz_pih", length = 3.8}}},
    {"Příští zastávka: Pískoviště", {{name = "ch_say_pz_pis", length = 3.05}}},
    {"Příští zastávka: Rasterdam", {{name = "ch_say_pz_ras", length = 2.85, sk = true, replacement_from = "Koncová zastávka", replacement_to = "Koncová zastávka (sk)"}}},
    {"Příští zastávka: Hrošie jazero", {{name = "ch_say_pz_hrj", length = 3.15, sk = true}}},
    {"Příští zastávka: Severka", {{name = "ch_say_pz_sev", length = 2.4, sk = true, replacement_from = "Koncová zastávka", replacement_to = "Koncová zastávka (sk)"}}},
    -- Linka S3
    {"Příští zastávka: Březová Pila", {{name = "ch_say_pz_brp", length = 2.5}}},
    {"Příští zastávka: Rajská zahrada", {{name = "ch_say_pz_rz", length = 2.85}}},
    {"Příští zastávka: Česká Amazonie", {{name = "ch_say_pz_cas", length = 3}}},
    {"Příští zastávka: Klárský průsmyk", {{name = "ch_say_pz_klp", length = 2.85}}},
    {"Příští zastávka: Jižní Kaštan", {{name = "ch_say_pz_jka", length = 2.8}}},
    {"Příští zastávka: Most Vzkříšení", {{name = "ch_say_pz_mvz", length = 2.9}}},
    {"Příští zastávka: Vánoční ostrov", {{name = "ch_say_pz_vo", length = 3.0}}},
    -- Linka S4
    {"Příští zastávka: Meziřečí", {{name = "ch_say_pz_mez", length = 2.45}}}, 
    {"Příští zastávka: Česká", {{name = "ch_say_pz_ces", length = 2.2}}},
    {"Příští zastávka: Květná", {{name = "ch_say_pz_kve", length = 2.05}}},
    {"Příští zastávka: Králiky", {{name = "ch_say_pz_kra", length = 2.30}}},
    {"Příští zastávka: Třešňová", {{name = "ch_say_pz_tre", length = 2.25}}},
    {"Příští zastávka: Lhota pod Točnou", {{name = "ch_say_pz_lpt", length = 2.9}}},
    {"Příští zastávka: Věčný Jeseník", {{name = "ch_say_pz_vej", length = 2.6}}},
    {"Příští zastávka: Duhový most", {name = "ch_say_pz_duhm", length = 2.5}},
    {"Příští zastávka: Úskalí", {name = "ch_say_pz_usk", length = 2.20}},
    -- Linka S5
    {"Příští zastávka: Tunel Koniklec", {{name = "ch_say_pz_kon", length = 3.1}}},
    {"Příští zastávka: Mariánský hájek", {{name = "ch_say_pz_mha", length = 2.9}}},
    {"Příští zastávka: Kamenný most", {{name = "ch_say_pz_kmo", length = 2.5}}},
    {"Příští zastávka: Hlavní výpočetní středisko", {{name = "ch_say_pz_hvs", length = 3.5}}},
    -- Linka P1
    {"Příští zastávka: Červený písek", {{name = "ch_say_pz_cep", length = 3.25}}},
    {"Příští zastávka: Útulná skrýš", {{name = "ch_say_pz_uskr", length = 3.1}}},
    {"Příští zastávka: Česká Amazonie - výzkumná stanice", {{name = "ch_say_pz_cav", length = 5}}},
    {"Příští zastávka: Úhlopříčný průplav", {{name = "ch_say_pz_uhp", length = 3.15}}},
    {"Příští zastávka: Ostrov Zikmunda a Hanzelky", {{name = "ch_say_pz_ozh", length = 3.75}}},
    {"Příští zastávka: Úzké hrdlo", {{name = "ch_say_pz_uhr", length = 2.55}}},
    {"Příští zastávka: Mys Dobré snídaně", {{name = "ch_say_pz_mds", length = 3}}},
    {"Příští zastávka: Zátoka Dobré večeře", {{name = "ch_say_pz_zdv", length = 3.1}}},
    {"Příští zastávka: Tichý západ", {{name = "ch_say_pz_tiz", length = 2.75}}},
    -- Linka 101
    {"Příští zastávka: Haškova", {{name = "ch_say_pz_has", length = 2.4}}},
    {"Příští zastávka: Gumová", {{name = "ch_say_pz_gum", length = 2.4}}},
    {"Příští zastávka: Serengeti", {{name = "ch_say_pz_ser", length = 2.4}}},
    {"Příští zastávka: Serengeti, točna", {{name = "ch_say_pz_sert", length = 3.5}}},
    -- Linka 1 (Rasterdam)
    {"Příští zastávka: Slovenská", {{name = "ch_say_pz_rslo", length = 2.5, sk = true}}},
    {"Příští zastávka: Merveillská", {{name = "ch_say_pz_rmer", length = 3, sk = true}}},
    {"Příští zastávka: Brdárska", {{name = "ch_say_pz_rbrd", length = 2.55, sk = true}}},
    {"Příští zastávka: Solárna", {{name = "ch_say_pz_rsol", length = 2.4, sk = true}}},
    -- Linka 2 (Rasterdam)
    {"Příští zastávka: Zajačí vrch", {{name = "ch_say_pz_rzav", length = 2.85, sk = true}}},
    {"Příští zastávka: Veterná", {{name = "ch_say_pz_rvet", length = 3.1, sk = true}}},
    --
    {"Koncová zastávka", {{name = "ch_say_koncova_zastavka_cz", length = 1.5}}},
    {"Koncová zastávka (sk)", {{name = "ch_say_koncova_zastavka_sk", length = 2.05}}},
    {"Zastávka je na znamení", {{name = "ch_say_zas_na_znam_cz", length = 1.9}}},
    {"Zastávka je na znamenie", {{name = "ch_say_zas_na_znam_sk", length = 1.95}}},
    -- TODO: {"Zastávka je na znamení"},
    -- pauza
    {"__pauza__", {{name = "", length = 1.0}}},
}

local set = {}

for _, s in ipairs(default_sounds) do
    local text = s[1]
    local options = s[2]
    for i, option in ipairs(options) do
        if option.sk and option.replacement_from == nil then
            option.replacement_from = "Zastávka je na znamení"
            option.replacement_to = "Zastávka je na znamenie"
        end
    end
    ch_say.register_sound(text, options)
end
