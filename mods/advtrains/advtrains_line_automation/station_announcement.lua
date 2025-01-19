local def
local F = core.formspec_escape
local ifthenelse = assert(ch_core.ifthenelse)

local PAGE_SETUP_1 = 1
local PAGE_SETUP_2 = 2
local PAGE_IMPORT = 3
local PAGE_HELP = 4
local PAGE_OWNERSHIP = 5

local hl_texty = {
    {
        id = "vcpp",
        sample = "Vážení cestující, prosíme pozor!",
        default = "",
    }, {
        id = "tvl",
        sample = "{TYPVLAKU}",
    }, {
        id = "vlk",
        sample = "Vlak",
    }, {
        id = "lnky",
        sample = "linky {LINKA}",
    }, {
        id = "jmvlku",
        sample = "{JMVLAKU}",
    }, {
        id = "zesm",
        sample = "ze směru {VYCHOZI}",
    }, {
        id = "prijnk",
        sample = "přijíždí na kolej {KOLEJ}.",
    }, {
        id = "prisnk",
        sample = "bude přistaven na kolej {KOLEJ}.",
    }, {
        id = "zpoz",
        sample = "Vlak má {ZPOZDENI} sekund zpoždění.",
        default = "",
    }, {
        id = "zpozz",
        sample = "Vlak má -{ZPOZDENI} sekund zpoždění.",
        default = "",
    }, {
        id = "vkonc",
        sample = "Vlak zde jízdu končí.",
    }, {
        id = "pokrnc",
        sample = "Vlak dále pokračuje směr {NASL} a {CIL}",
    }, {
        id = "pokrc",
        sample = "Vlak pokračuje směr {CIL}",
    }, {
        id = "ozasek",
        sample = ", odjezd za {ODJZA} sekund.",
    }, {
        id = "dek",
        sample = "Děkujeme, že používáte naše služby.",
        default = "",
    }
}
local hl_texty_id_to_idx = function()
    local result = {}
    for i, def in ipairs(hl_texty) do
        local id = assert(def.id)
        if result[id] ~= nil then
            error("Duplicity: id = "..id.."!")
        end
        def.fs_sample = F(def.sample)
        def.fs_default = F(def.default or def.sample)
        result[id] = i
    end
    return result
end
hl_texty_id_to_idx = hl_texty_id_to_idx()

local function dist2(a, b)
    local x, y, z = a.x - b.x, a.y - b.y, a.z - b.z
    return x * x + y * y + z * z
end

--[[
    Vrací:
    - success = bool
    - min = int or nil (pro success == false vždy nil)
    - max = int or nil (pro success == false vždy nil)
]]
local function lengths_from_string(s)
    if s == "" or s == "-" then
        return true, nil, nil
    end
    local n = s:match("^%d+$")
    if n ~= nil then
        n = assert(tonumber(n))
        if n > 256 then
            n = 256
        end
        return true, n, n
    end
    local min, max = s:match("^(%d*)-(%d*)$")
    if min == nil then
        return false, nil, nil -- bad format
    end
    min, max = tonumber(min), tonumber(max)
    if min ~= nil and min > 256 then min = 256 end
    if max ~= nil and max > 256 then max = 256 end
    if min ~= nil and max ~= nil and min > max then
        min = max
    end
    return true, min, max
end

local function lengths_to_string(min, max)
    if min == nil then
        if max ~= nil then
            return "-"..max
        else
            return ""
        end
    elseif max == nil then
        return min.."-"
    elseif min == max then
        return tostring(min)
    else
        return min.."-"..max
    end
end

local alphanum_chars_set = {
    ["a"] = true, ["A"] = true, ["á"] = true, ["Á"] = true, ["ä"] = true, ["Ä"] = true, ["b"] = true, ["B"] = true, ["č"] = true,
    ["Č"] = true, ["d"] = true, ["D"] = true, ["ď"] = true, ["Ď"] = true, ["e"] = true, ["E"] = true, ["é"] = true, ["É"] = true,
    ["ě"] = true, ["Ě"] = true, ["f"] = true, ["F"] = true, ["g"] = true, ["G"] = true, ["h"] = true, ["H"] = true, ["i"] = true,
    ["I"] = true, ["í"] = true, ["Í"] = true, ["j"] = true, ["J"] = true, ["k"] = true, ["K"] = true, ["l"] = true, ["L"] = true,
    ["ĺ"] = true, ["Ĺ"] = true, ["ľ"] = true, ["Ľ"] = true, ["m"] = true, ["M"] = true, ["n"] = true, ["N"] = true, ["ň"] = true,
    ["Ň"] = true, ["o"] = true, ["O"] = true, ["ó"] = true, ["Ó"] = true, ["ô"] = true, ["Ô"] = true, ["p"] = true, ["P"] = true,
    ["q"] = true, ["Q"] = true, ["r"] = true, ["R"] = true, ["ŕ"] = true, ["Ŕ"] = true, ["ř"] = true, ["Ř"] = true, ["s"] = true,
    ["S"] = true, ["š"] = true, ["Š"] = true, ["t"] = true, ["T"] = true, ["ť"] = true, ["Ť"] = true, ["u"] = true, ["U"] = true,
    ["ú"] = true, ["Ú"] = true, ["ů"] = true, ["Ů"] = true, ["v"] = true, ["V"] = true, ["w"] = true, ["W"] = true, ["x"] = true,
    ["X"] = true, ["y"] = true, ["Y"] = true, ["ý"] = true, ["Ý"] = true, ["z"] = true, ["Z"] = true, ["ž"] = true, ["Ž"] = true,
    ["0"] = true, ["1"] = true, ["2"] = true, ["3"] = true, ["4"] = true, ["5"] = true, ["6"] = true, ["7"] = true, ["8"] = true,
    ["9"] = true,
}

local function dosadit(format, data, defaults)
    assert(type(format) == "string")
    assert(type(data) == "table")
    if defaults == nil then
        defaults = {}
    end
    local result = {}
    local i = 1
    local e = 0
    local b = format:find("{", e + 1, true)
    while b ~= nil do
        if e < b - 1 then
            table.insert(result, format:sub(e + 1, b - 1))
        end
        e = format:find("}", b + 1, true)
        if e == nil then
            core.log("warning", "[advtrains_line_automation] dosadit(): invalid format: <"..format..">")
            table.insert(result, format:sub(b, -1))
            break
        end
        local tag = format:sub(b + 1, e - 1)
        local tagfmt, tagalt = ""
        local j = tag:find("|", 1, true)
        if j ~= nil then
            tagalt = tag:sub(j + 1, -1)
            tag = tag:sub(1, j - 1)
        end
        j = tag:find(":", 1, true)
        if j ~= nil then
            tagfmt = tag:sub(j + 1, -1)
            tag = tag:sub(1, j - 1)
        end
        local min, max
        if tagfmt ~= "" then
            local success
            success, min, max = lengths_from_string(tagfmt)
        end
        if tag:len() < 4 and ch_core.utf8_length(tag) == 1 and alphanum_chars_set[tag] == nil then
            -- speciální případ: zopakovat znak alespoň min-krát
            if min ~= nil then
                table.insert(result, string.rep(tag, min))
            else
                table.insert(result, tag)
            end
        else
            local value = data[tag] or tagalt or defaults[tag] or "ERR"
            local len = ch_core.utf8_length(value)
            if min ~= nil and len < min then
                table.insert(result, value)
                table.insert(result, string.rep(" ", min - len))
            elseif max ~= nil and len > max then
                table.insert(result, ch_core.utf8_truncate_right(value, max))
            else
                table.insert(result, value)
            end
        end
        b = format:find("{", e + 1, true)
    end
    table.insert(result, format:sub(e + 1, -1))
    return table.concat(result)
end

local function sestavit_hlaseni(settings, settings_override, data, defaults)
    local parts = {}
    local function a(s)
        table.insert(parts, s)
    end
    local function t(id)
        if id == nil then
            return ""
        end
        local key = "tx_"..id
        local result = settings_override[key] or settings[key]
        if result == nil then
            local def = assert(hl_texty_id_to_idx[id])
            result = assert(def.default or def.sample)
        end
        return result
    end
    assert(settings)
    if settings_override == nil then
        settings_override = {}
    end
    assert(data)
    a(t("vcpp"))
    a("{SEP}")
    a(t(ifthenelse(data.TYPVLAKU ~= nil, "tvl", "vlk")))
    a("{SEP}")
    if data.LINKA ~= nil then
        a(t("lnky"))
        a("{SEP}")
    end
    if data.VYCHOZI ~= nil then
        a(t("zesm"))
        a(t("prijnk"))
    else
        a(t("prisnk"))
    end
    a("{SEP}")
    if data.typ_zpozdeni == "+" then
        a(t("zpoz"))
        a("{SEP}")
    elseif data.typ_zpozdeni == "-" then
        a(t("zpozz"))
        a("{SEP}")
    end
    if not data.CIL then
        a(t("vkonc"))
    elseif data.NASL then
        a(t("pokrnc"))
    else
        a(t("pokrc"))
    end
    if data.ODJZA then
        a(t("ozasek"))
    else
        a(".")
    end
    a("{SEP}")
    a(t("dek"))
    data = table.copy(data)
    data.SEP = "{SEP}"
    local s = table.concat(parts)
    s = assert(dosadit(s, data, defaults))
    s = s:gsub(" *{SEP} *", "{SEP}")
    while true do
        t = s:gsub("{SEP}{SEP}", "{SEP}")
        if t:len() == s:len() then
            break
        end
        s = t
    end
    s = s:gsub("^{SEP}", "")
    s = s:gsub("{SEP}$", "")
    return s
end

local function get_or_add_anns(stn)
    local station = advtrains.lines.stations[stn]
    if station == nil then
        return nil -- dopravna neexistuje!
    end
    local anns = station.anns
    if anns == nil then
        anns = {}
        station.anns = anns
    end
    return anns
end

local function get_ann_data(stn, epos, make_copy)
    local anns = get_or_add_anns(stn)
    if anns == nil then
        return {}
    end
    local ann = anns[epos]
    if ann == nil then
        return {}
    end
    if make_copy then
        return table.copy(ann)
    else
        return ann
    end
end

local function set_ann_data(stn, epos, data)
    local anns = get_or_add_anns(stn)
    if anns == nil then
        return false
    end
    local ann = anns[epos]
    if ann ~= nil then
        for k, v in pairs(data) do
            ann[k] = v
        end
    else
        anns[epos] = table.copy(data)
    end
    print("DEBUG: set_ann_data() => "..dump2({stn = stn, epos = epos, ann = anns[epos]}))
    return true
end

local function init_formspec_callback(custom_state, player, formname, fields)
    local player_name = player:get_player_name()
    local pos = custom_state.pos
    local node = core.get_node(pos)
    if node.name ~= "advtrains_line_automation:stanicni_rozhlas" then
        core.chat_send_player(player_name, "CHYBA: staniční rozhlas nenalezen!")
        return
    end
    if not core.check_player_privs(player, "railway_operator") then
        core.chat_send_player(player_name, "*** K instalaci staničního rozhlasu je nutné právo railway_operator!")
        return
    end
    if fields.dopravna then
        local event = core.explode_textlist_event(fields.dopravna)
        local new_index = tonumber(event.index)
        if new_index ~= nil and custom_state.list[new_index] ~= nil then
            custom_state.selection_index = new_index
        end
        if event.type == "DCL" then
            fields.zvolit_dopravnu = "true"
        end
    end
    if fields.zvolit_dopravnu and custom_state.selection_index  ~= nil then
        local stn = assert(custom_state.list[custom_state.selection_index].stn)
        local stdata = advtrains.lines.stations[stn]
        if stdata ~= nil then
            print("DEBUG: C")
            local meta = core.get_meta(pos)
            meta:set_string("infotext", "staniční rozhlas ("..(stdata.name or "???")..")")
            meta:set_string("owner", player_name)
            meta:set_string("stn", stn)
            local anns = stdata.anns
            if anns == nil then
                anns = {}
                stdata.anns = anns
            end
            anns[custom_state.epos] = {}
            core.chat_send_player(player_name, "*** Úspěšně nastaveno.")
            print("DEBUG: D")
        end
    end
end

local function get_setup_formspec(custom_state)
    local player_name = assert(custom_state.player_name)
    local is_admin = assert(custom_state.is_admin)
    local page = assert(custom_state.page)
    local stations = assert(custom_state.stations)
    local stn = custom_state.stn
    local data = custom_state.data

    local formspec = {
        "formspec_version[6]"..
        "size[15,16.5]"..
        -- "style_type[textarea;font=mono]"..
        "tabheader[0,0;0.75;tab;Nastavení 1,Nastavení 2,Import/export nastavení,Nápověda",
        ifthenelse(is_admin, ",Vlastnictví;", ";"),
        custom_state.page..";false;true]"..
        "button_exit[14,0.25;0.75,0.75;close;X]"..
        "item_image[0.5,0.5;1,1;advtrains_line_automation:stanicni_rozhlas]"..
        "label[1.75,1;staniční rozhlas]"..
        "label[9,0.75;vlastník/ice:\n",
        ch_core.prihlasovaci_na_zobrazovaci(custom_state.owner),
        "]",
    }
    local function a(x)
        if type(x) == "table" then
            for _, s in ipairs(x) do
                table.insert(formspec, s)
            end
        else
            table.insert(formspec, x)
        end
    end
    if page == PAGE_SETUP_1 then
        a(  "container[0.5,1.5]"..
            "label[0,0.5;dopravna:]"..
            "dropdown[1.75,0.2;5,0.6;dopravna;")
        for i, station in ipairs(stations) do
            a(ifthenelse(i ~= 1, ",", "")..F(station.stn).." | "..F(station.name))
        end
        a{";"..custom_state.station_index..";true]"..
            "label[7,0.5;omezit jen na koleje:]"..
            "field[10,0.2;4,0.6;koleje;;",
            data.fs_koleje or "",
            "]container_end[]",
            -- ----
            "container[0.5,2.75]"..
            "label[0,0.25;Formátování na cedule ({1}, {2} atd.):]"..
            "checkbox[5.5,0.25;fn_firstupper;první písmeno řádky vždy velké;",
            ifthenelse(ifthenelse(custom_state.fn_firstupper ~= nil, custom_state.fn_firstupper, data.fn_firstupper), "true", "false"),
            "]textarea[0,1;13.25,1.5;fmt_radek;formát řádků s odjezdem:;",
        }
        if data.fmt_radek ~= nil then
            a(F(table.concat(data.fmt_radek, "\n")))
        end
        a("]textarea[0,3;13.25,1.5;fmt_prradek;formát prázdných řádků:;")
        if data.fmt_prradek ~= nil then
            a(F(table.concat(data.fmt_prradek, "\n")))
        end
        a{"]tooltip[fmt_radek;Uvedete-li více řádků\\, každý se použije jako formát pro odpovídající značku {N}\n"..
            "ve formátu cedule a poslední se použije i pro všechny následující.]"..
            "tooltip[fmt_prradek;V tomto poli se nenahrazují značky\\, text musí být uvedený tak\\, jak má být použit.\n"..
            "Uvedete-li více řádků\\, každý se použije pro odpovídající značku {N} ve formátu cedule\n"..
            "a poslední se použije i pro všechny následující.]"..
            "container_end[]"..
            "container[0.5,7.5]"..
            "label[0,0;formát záp. zpoždění (lze {}):]"..

            "field[0,0.25;3.25,0.75;fmt_negdelay;formát záp. zpoždění (lze {}):;",
            F(data.fmt_negdelay or "-{}"),
            "tooltip[fmt_negdelay;Formát v tomto poli se použije pro záporné zpoždění.\n"..
            "Značka {} se nahradí absolutní hodnotou záporného zpoždění.]"..
            "textarea[0,1;13.25,2;;;",
            F("Značky, které můžete použít ve formátu řádků s odjezdem: {LINKA}, {VYCHOZI}, {CIL}, {KOLEJ}, {PRIJZA}, {ODJZA}, "..
            "{ZPOZDENI}, {PREDCH}, {NASL}, {JMVLAKU}, {TYP}, {TYPVLAKU}. "..
            "Příklady stanovení délky: {LINKA:4} (pevná délka), {LINKA:4-} (min. délka), {LINKA:-4} (max. délka), {LINKA:2-4} "..
            "(délka v rozmezí). Příklady náhradního textu: {LINKA|-}, {LINKA:3|-}. Zopakování symbolu (symbol nesmí být písmeno, "..
            "číslice, {, }, : ani |, lze použít i ve formátu prázdných řádků: {.:7}, { :4}.)"),
            "]container_end[]"..
            "container[0.5,10.5]"..
            "box[0,0.15;14,0.05;#000000FF]"..
            "label[7,0.5;dosah hlášení v četu \\[m\\] (0=vyp):]"..
            "field[11.5,0.25;2,0.5;chat_dosah;;",
            tostring(custom_state.chat_dosah or data.chat_dosah or "50"),
            "]"..
            "tooltip[chat_dosah;Dosah je současně limitován doslechem jednotlivých hráčských postav.]"..
            "label[0,0.5;texty pro hlášení příjezdu/přistavení vlaku v četu:]"..
            "tablecolumns[text;text]"..
            "table[0,0.75;14,2;texty;"}
        for _, def in ipairs(hl_texty) do
            local id = "tx_"..def.id
            a(def.fs_sample)
            a(",")
            a(F(custom_state[id] or data[id] or def.default or def.sample))
            a(",")
        end
        formspec[#formspec] = ";"..(custom_state.tx_index or "").."]"
        a("label[0.1,3.125;text:]".."field[0.75,2.75;10,0.75;preklad;;")
        if custom_state.tx_index ~= nil then
            local def = assert(hl_texty[custom_state.tx_index])
            local id = "tx_"..def.id
            local s = custom_state[id] or data[id]
            if s ~= nil then
                a(F(s))
            else
                a(def.fs_default)
            end
        end
        a(  "]"..
            "button[11,2.75;3,0.75;preklad_set;nastavit]"..
            "tooltip[preklad;V levém sloupci tabulky jsou vzorové texty\\, v pravém sloupci jsou texty\\,\n"..
            "které budou na jejich místě použity pro tento staniční rozhlas (ty můžete měnit).]"..
            "textarea[0,3.5;14,1;;;příklad: ")
        local hlaseni = sestavit_hlaseni(data, custom_state, {
            LINKA = "S1",
            VYCHOZI = "Praha hl. n.",
            typ_zpozdeni = "+",
            CIL = "Bratislava hl. st.",
            NASL = "Pardubice hl. n.",
            ODJZA = "60",
            ZPOZDENI = "13",
            JMVLAKU = "Testovací expres",
            KOLEJ = "A",
        })
        a(F(hlaseni))
        a("]container_end[]"--[[..
            -- ----
            "container[0.5,9.25]"..
            "label[0,0.25;Formáty řádků ({1}, {2} atd.):]"..
            "container_end[]" ]]
        )
        a("button[0.5,15;14,1;btn_save;Uložit]")
    elseif page == PAGE_SETUP_2 then
    elseif page == PAGE_IMPORT then
    elseif page == PAGE_HELP then
    elseif is_admin and page == PAGE_OWNERSHIP then
    end
    return table.concat(formspec)
end

local function setup_formspec_callback(custom_state, player, formname, fields)
    print("DEBUG: setup_formspec_callback(): "..dump2({custom_state = custom_state, fields = fields, player_name = custom_state.player_name}))
    assert(player:get_player_name() == custom_state.player_name)
    local is_admin = custom_state.is_admin
    local page = custom_state.page
    local stn = custom_state.stn
    local data = custom_state.data

    if page == PAGE_SETUP_1 then
        if
            fields.dopravna and
            fields.dopravna ~= tostring(custom_state.station_index) and
            tonumber(fields.dopravna) ~= nil and
            custom_state.stations[tonumber(fields.dopravna)] ~= nil
        then
            -- přepnout dopravnu
            custom_state.station_index = tonumber(fields.dopravna)
        end

        -- zaškrtávací pole:
        if fields.fn_firstupper then
            data.fn_firstupper = ifthenelse(fields.fn_firstupper == "true", true, false)
        end

        -- koleje:
        if fields.koleje and F(fields.koleje) ~= data.fs_koleje then
            local parts = string.split(fields.koleje, ",", false)
            local list, set = {}, {}
            for _, part in ipairs(parts) do
                if not set[part] then
                    set[part] = true
                    table.insert(list, part)
                end
            end
            table.sort(list, function(a, b) return a < b end)
            data.koleje = set
            data.fs_koleje = F(table.concat(list, ","))
        end
        if fields.fmt_negdelay then
            data.fmt_negdelay = fields.fmt_negdelay
        end
        local fmt_ml_keys = {
            "fmt_radek", "fmt_prradek",
        }
        for _, key in ipairs(fmt_ml_keys) do
            local lines = fields[key]
            if lines then
                lines = string.split(lines, "\n", true)
                assert(type(lines[1]) == "string")
                data[key] = lines
            end
        end

        -- uložit?
        if fields.btn_save then
            local new_stn = custom_state.stations[custom_state.station_index].stn
            if new_stn ~= stn then
                -- přesunout rozhlas na jinou dopravnu
                local old_anns = get_or_add_anns(stn)
                local new_anns = get_or_add_anns(new_stn)
                if old_anns ~= nil and new_anns ~= nil then
                    local epos = custom_state.epos
                    new_anns[epos] = old_anns[epos]
                    old_anns[epos] = nil
                    print("DEBUG: rozhlas moved from "..stn.." to "..new_stn)
                    stn = new_stn
                    custom_state.stn = new_stn
                end
            end
            set_ann_data(stn, custom_state.epos, data)
        end
    elseif page == PAGE_SETUP_2 then
    elseif page == PAGE_IMPORT then
    elseif page == PAGE_HELP then
    elseif page == PAGE_OWNERSHIP then
        if is_admin then
            -- TODO
        end
    end
    if fields.tab then
        -- přepnout stránku
        local new_tab = tonumber(fields.tab)
        if new_tab ~= nil and new_tab ~= page and (
            new_tab == PAGE_SETUP_1 or new_tab == PAGE_SETUP_2 or new_tab == PAGE_IMPORT or new_tab == PAGE_HELP or
            (is_admin and new_tab == PAGE_OWNERSHIP)
        ) then
            custom_state.page = new_tab
        end
        return get_setup_formspec(custom_state)
    end
    if not fields.quit then
        return get_setup_formspec(custom_state)
    end
end

local function can_dig(pos, player)
    if player ~= nil and core.is_player(player) then
        local owner = core.get_meta(pos):get_string("owner")
        local player_name = player:get_player_name()
        return owner == "" or owner == player_name or core.check_player_privs(player_name, "protection_bypass")
    end
    return false
end

local function on_construct(pos)
    local meta = core.get_meta(pos)
    meta:set_string("infotext", "staniční rozhlas")
end

local function on_destruct(pos)
    local meta = core.get_meta(pos)
    local stn = meta:get_string("stn")
    if stn ~= "" then
        local epos = advtrains.encode_pos(pos)
        local stdata = advtrains.lines.stations[stn]
        if stdata ~= nil then
            (stdata.anns or {})[epos] = nil -- odstranit data staničního rozhlasu
        end
    end
end

local function on_dig(pos, node, digger)
    -- TODO?
    return core.node_dig(pos, node, digger)
end

local function on_rightclick(pos, node, clicker, itemstack, pointed_thing)
    if clicker == nil or not clicker:is_player() then
        return
    end
    local player_name = assert(clicker:get_player_name())
    local meta = core.get_meta(pos)
    local owner = meta:get_string("owner")
    local stn = meta:get_string("stn")
    if owner == "" or stn == "" then
        if not core.check_player_privs(clicker, "railway_operator") then
            core.chat_send_player(player_name, "*** K instalaci staničního rozhlasu je nutné právo railway_operator!")
            return
        end
        local player_pos = vector.round(clicker:get_pos())
        local limit = 256 * 256
        local stations = advtrains.lines.load_stations_for_formspec()
        local list = {}
        for i, station_data in ipairs(stations) do
            local d2 = limit
            for _, stop in ipairs(station_data.tracks) do
                local d2new = dist2(player_pos, stop.pos)
                if d2new < d2 then
                    d2 = d2new
                end
            end
            if d2 < limit then
                table.insert(list, {
                    stn = assert(station_data.stn),
                    name = assert(station_data.name),
                    distance = math.floor(math.sqrt(d2)),
                })
            end
        end
        table.sort(list, function(a, b) return a.distance < b.distance end)
        local custom_state = {
            pos = pos,
            epos = advtrains.encode_pos(pos),
            list = list,
        }
        local formspec = {
            "formspec_version[6]"..
            "size[15,8]"..
            "button_exit[14,0.25;0.75,0.75;close;X]"..
            "item_image[0.5,0.5;1,1;advtrains_line_automation:stanicni_rozhlas]"..
            "label[1.75,1;staniční rozhlas]"..
            "label[0.5,2.25;vyberte dopravnu:]"..
            "button_exit[0.5,6.75;14,1;zvolit_dopravnu;Zvolit]"..
            "textlist[0.5,2.5;14,4;dopravna;",
        }
        if #list > 0 then
            for i, candidate in ipairs(list) do
                if i ~= 1 then
                    table.insert(formspec, ",")
                end
                table.insert(formspec, F(candidate.stn.." | "..candidate.name.." ("..candidate.distance.." m)"))
            end
            table.insert(formspec, ";1]")
        else
            table.insert(formspec, ";]")
        end
        ch_core.show_formspec(clicker, "advtrains_line_automation:init_rozhlas", table.concat(formspec), init_formspec_callback, custom_state, {})
        return
    end
    if player_name ~= owner and not core.check_player_privs(player_name, "protection_bypass") then -- train_admin?
        core.chat_send_player(player_name, "Nemáte oprávnění nastavovat tento staniční rozhlas!")
        return
    end
    local epos = advtrains.encode_pos(pos)
    local stdata = advtrains.lines.stations[stn]
    if stdata == nil or stdata.anns == nil or stdata.anns[epos] == nil then
        core.chat_send_player(player_name, "CHYBA: data dopravny nenalezena!")
        return
    end
    local stations = advtrains.lines.load_stations_for_formspec()
    local selection_index
    for i, station in ipairs(stations) do
        if station.stn == stn then
            selection_index = i
            break
        end
    end
    if selection_index == nil then
        core.log("error", "Cannot determine selection index for the station '"..stn.."' in the list of stations!")
        core.chat_send_player(player_name, "CHYBA: Vnitřní chyba: dopravna nenalezena ve výpisu!")
        return
    end
    local custom_state = {
        player_name = player_name,
        is_admin = ch_core.get_player_role(player_name) == "admin",
        pos = pos,
        epos = epos,
        owner = owner,
        stn = assert(stn), -- kam byl staniční rozhlas dosud přiřazen
        stations = stations, -- pro dropdown[]
        station_index = selection_index, -- pro dropdown[]
        data = assert(get_ann_data(stn, epos, true)),
        page = PAGE_SETUP_1,
    }
    ch_core.show_formspec(clicker, "advtrains_line_automation:rozhlas", get_setup_formspec(custom_state),
        setup_formspec_callback, custom_state, {})
end

def = {
    description = "staniční rozhlas",
    tiles = {{name = "blank.png^[noalpha"}}, -- TODO
    drawtype = "normal",
    paramtype = "light",
    paramtype2 = "facedir", -- TODO: => colorfacedir
    can_dig = can_dig,
    on_dig = on_dig,
    on_construct = on_construct,
    on_destruct = on_destruct,
    on_rightclick = on_rightclick,
}
core.register_node("advtrains_line_automation:stanicni_rozhlas", def)
