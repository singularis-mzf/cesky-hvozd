local al = advtrains.lines
local F = core.formspec_escape
local ifthenelse = assert(ch_core.ifthenelse)
local rwt = assert(advtrains.lines.rwt)
local def
local function CF(s)
    if s ~= nil then return F(s) else return "" end
end
local has_signs_api = core.get_modpath("signs_api")
local has_unifieddyes = core.get_modpath("unifieddyes")
local rozhlas_node_name = "advtrains_line_automation:stanicni_rozhlas_experimental"

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

local punch_context = {--[[
    [player_name] = {
        stn = string,
        epos = string,
        i = int,
    }
]]}

local function dist2(a, b)
    local x, y, z = a.x - b.x, a.y - b.y, a.z - b.z
    return x * x + y * y + z * z
end

local function goa(t, k) -- goa = get or add
    local result = t[k]
    if result == nil then
        result = {}
        t[k] = result
    end
    return result
end

--[[
    Vrací:
    - success = bool
    - min = int or nil (pro success == false vždy nil)
    - max = int or nil (pro success == false vždy nil)
    - align = "left" or "right" or "center"
]]
local function lengths_from_string(s)
    if s == "" or s == "-" then
        return true, nil, nil
    end
    local l = #s
    s = s:gsub("^ +", "")
    local left = #s < l
    l = #s
    s = s:gsub(" +$", "")
    local right = #s < l
    local align
    if not left then
        align = "left" -- mezery vpravo, nebo žádné mezery
    elseif right then
        align = "center" -- mezery na obou stranách
    else
        align = "right" -- mezery jen vlevo
    end
    local n = s:match("^%d+$")
    if n ~= nil then
        n = assert(tonumber(n))
        if n > 256 then
            n = 256
        end
        return true, n, n, align
    end
    local min, max = s:match("^(%d*)-(%d*)$")
    if min == nil then
        return false, nil, nil, nil -- bad format
    end
    min, max = tonumber(min), tonumber(max)
    if min ~= nil and min > 256 then min = 256 end
    if max ~= nil and max > 256 then max = 256 end
    if min ~= nil and max ~= nil and min > max then
        min = max
    end
    return true, min, max, align
end

--[[ (obsolete)
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
]]

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
        local tag_name = tag
        local tagfmt, tagalt = ""
        local b2 = tag:find("[:|]")
        if b2 == nil then
            tag_name, tagfmt = tag, ""
        else
            tag_name = tag:sub(1, b2 - 1)
            repeat
                local e2 = tag:find("[:|]", b2 + 1) or (#tag + 1)
                local c = tag:sub(b2, b2)
                if c == ":" then
                    tagfmt = tag:sub(b2 + 1, e2 - 1)
                elseif c == "|" then
                    tagalt = tag:sub(b2 + 1, e2 - 1)
                end
                b2 = e2
            until b2 >= #tag
        end
        local min, max, align
        if tagfmt ~= "" then
            local success
            success, min, max, align = lengths_from_string(tagfmt)
        end
        tag = tag_name
        -- print("DEBUG: tag("..tag..") tagname("..tag_name..")")
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
                -- řetězec je kratší než minimum => prodloužit
                local missing = min - len
                if align == "left" then
                    table.insert(result, value)
                    table.insert(result, string.rep(" ", missing))
                elseif align == "right" then
                    table.insert(result, string.rep(" ", missing))
                    table.insert(result, value)
                else
                    table.insert(result, string.rep(" ", math.floor(missing / 2)))
                    table.insert(result, value)
                    table.insert(result, string.rep(" ", missing - math.floor(missing / 2)))
                end
            elseif max ~= nil and len > max then
                -- řetězec je delší než maximum => oříznout
                if align == "left" then
                    local pos = assert(ch_core.utf8_seek(value, 1, max))
                    table.insert(result, value:sub(1, pos - 1))
                elseif align == "right" then
                    local pos = assert(ch_core.utf8_seek(value, 1, len - max))
                    table.insert(result, value:sub(pos, -1))
                else
                    local overflow = len - max
                    local half = math.floor(overflow / 2)
                    local pos1 = assert(ch_core.utf8_seek(value, 1, half))
                    local pos2 = (ch_core.utf8_seek(value, pos1, len - overflow) or 0) - 1
                    table.insert(result, value:sub(pos1, pos2))
                end
            else
                -- řetězec odpovídá
                table.insert(result, value)
            end
        end
        b = format:find("{", e + 1, true)
    end
    table.insert(result, format:sub(e + 1, -1))
    return table.concat(result)
end

-- Vrátí neuspořádaný seznam čísel řádků, které musejí být zformátovány pro daný formátovací řetězec.
local function ktere_radky(s, empty_as_string)
    local set = {}
    local list = {}
    for match in s:gmatch("{[1-9][:|}]") do
        local n = tonumber(match:sub(2,2))
        if n ~= nil and not set[n] then
            set[n] = true
            table.insert(list, n)
        end
    end
    if list[1] == nil and empty_as_string then
        return ""
    else
        return list
    end
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
            local def = assert(hl_texty[hl_texty_id_to_idx[id]])
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
        a("{SEP}")
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
    s = s:gsub("{SEP}", " ")
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

local cedule_default_settings = {
    empty = "{-:5}",
    fs = "",
    pos = vector.zero(),
    row = "{LINKA: 3} za {ODJZA: 2-3} s",
    text = "{ZDE} - odjezdy\n{1}\n{2}",
    text_rtf = {1, 2},
}

local function init_ann_data(stn, epos)
    local anns = get_or_add_anns(stn)
    if anns == nil then
        return
    end
    local result = {
        cedule = {
            table.copy(cedule_default_settings), table.copy(cedule_default_settings),
            table.copy(cedule_default_settings), table.copy(cedule_default_settings)},
        chat_dosah = 50,
        fmt_delay = "{}",
        fmt_negdelay = "-{}",
        fmt_nodelay = "",
        fn_firstupper = false,
        fs_koleje = "",
        koleje = "",
        version = 1,
    }
    anns[epos] = result
    -- print("DEBUG: ann data initialized for '"..stn.."'/"..epos..": "..dump2(result))
    return result
end

local function get_ann_data(stn, epos, make_copy)
    local anns = get_or_add_anns(stn)
    if anns == nil then
        core.log("error", "get_ann_data() called on non-existent stn '"..tostring(stn).."'!")
        return nil
    end
    local ann = assert(anns[epos] or init_ann_data(stn, epos))
    if make_copy then
        ann = table.copy(ann)
        local cedule = {}
        for i, v in ipairs(ann.cedule) do
            cedule[i] = table.copy(v)
        end
        ann.cedule = cedule
    end
    return ann
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
    return true
end

local function attach_sign(stn, epos, i, sign_pos)
    -- zkontrolovat rozhlas:
    local rozhl_pos = advtrains.decode_pos(epos)
    core.load_area(rozhl_pos)
    local rozhl_node = core.get_node(rozhl_pos)
    if rozhl_node.name ~= rozhlas_node_name then
        return false, "Staniční rozhlas se nenachází na očekávané pozici."
    end
    local rozhl_meta = core.get_meta(rozhl_pos)
    if rozhl_meta:get_string("stn") ~= stn then
        return false, "Staniční rozhlas přísluší k jiné dopravně." -- vnitřní chyba!
    end
    local data = get_ann_data(stn, epos, false)
    if data == nil then
        return false, "Data staničního rozhlasu nebyla nalezena."
    end

    -- zkontrolovat ceduli:
    core.load_area(sign_pos)
    local sign_node = core.get_node_or_nil(sign_pos)
    if sign_node == nil or core.get_item_group(sign_node.name, "display_api") == 0 then
        return false, "Toto není podporovaná cedule."
    end

    -- zkontrolovat vzdálenost:
    if vector.distance(rozhl_pos, sign_pos) > 1024 then
        return false, "Cedule je příliš daleko. Vzdálenost může být max. 1024 metrů."
    end

    -- zkontrolovat zadání:
    local cedule = data.cedule[i]
    if cedule == nil then
        return false, "Chybný index."
    end

    -- připojit:
    local s = string.format("%d,%d,%d", sign_pos.x, sign_pos.y, sign_pos.z)
    local fs = F(s)
    cedule.fs = fs
    cedule.pos = sign_pos
    return true, "Cedule úspěšně připojena ke staničnímu rozhlasu."
end

local function detach_sign(stn, epos, i)
    -- zkontrolovat rozhlas:
    local rozhl_pos = advtrains.decode_pos(epos)
    core.load_area(rozhl_pos)
    local rozhl_node = core.get_node(rozhl_pos)
    if rozhl_node.name ~= rozhlas_node_name then
        return false, "Staniční rozhlas se nenachází na očekávané pozici."
    end
    local rozhl_meta = core.get_meta(rozhl_pos)
    if rozhl_meta:get_string("stn") ~= stn then
        return false, "Staniční rozhlas přísluší k jiné dopravně." -- vnitřní chyba!
    end
    local data = get_ann_data(stn, epos, false)
    if data == nil then
        return false, "Data staničního rozhlasu nebyla nalezena."
    end

    -- zkontrolovat zadání:
    local cedule = data.cedule[i]
    if cedule == nil then
        return false, "Chybný index."
    end

    if cedule.fs == "" then
        return false, "Cedule není připojena."
    end

    -- odpojit:
    cedule.fs = ""
    cedule.pos = vector.zero()
    return true, "Cedule úspěšně odpojena."
end


local function init_formspec_callback(custom_state, player, formname, fields)
    local player_name = player:get_player_name()
    local pos = custom_state.pos
    local node = core.get_node(pos)
    if node.name ~= rozhlas_node_name then
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
            local meta = core.get_meta(pos)
            meta:set_string("infotext", "staniční rozhlas ("..(stdata.name or "???")..")")
            meta:set_string("owner", player_name)
            meta:set_string("stn", stn)
            init_ann_data(stn, custom_state.epos)
            core.chat_send_player(player_name, "*** Úspěšně nastaveno.")
        end
    end
end

local function get_setup_formspec(custom_state)
    local player_name = assert(custom_state.player_name)
    local page = assert(custom_state.page)
    local stations = assert(custom_state.stations)
    local stn = custom_state.stn
    local data = custom_state.data

    local formspec = {
        "formspec_version[6]"..
        "size[15,16.5]"..
        -- "style_type[textarea;font=mono]"..
        "tabheader[0,0;0.75;tab;Nastavení 1,Nastavení 2,Import/export nastavení,Nápověda",
        ifthenelse(custom_state.is_admin, ",Vlastnictví;", ";"),
        custom_state.page..";false;true]"..
        "button_exit[14,0.25;0.75,0.75;close;X]"..
        "item_image[0.5,0.5;1,1;"..rozhlas_node_name.."]"..
        "label[1.75,1;staniční rozhlas (experimentální)]"..
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
            "checkbox[0,0.25;fn_firstupper;první písmeno řádky odjezdu vždy velké;",
            ifthenelse(ifthenelse(custom_state.fn_firstupper ~= nil, custom_state.fn_firstupper, data.fn_firstupper), "true", "false"),
            "]field[0,1;3.25,0.75;fmt_nodelay;bez zpoždění;", F(data.fmt_nodelay or ""), "]"..
            "field[4,1;3.25,0.75;fmt_delay;zpoždění ({} = číslo);", F(data.fmt_delay or "{}"), "]"..
            "field[8,1;3.25,0.75;fmt_negdelay;záp.zpoždění ({} = číslo);", F(data.fmt_negdelay or "-{}"), "]"..
            "tooltip[fmt_nodelay;Text pro značku {ZPOZDENI} v případě\\, že vlak jede bez zpoždění.]"..
            "tooltip[fmt_delay;Formát pro značku {ZPOZDENI} v případě\\, že vlak má (kladné) zpoždění.\n"..
            "Značka {} se nahradí počtem sekund zpoždění.]"..
            "tooltip[fmt_negdelay;Formát pro značku {ZPOZDENI} v případě\\, že vlak má záporné zpoždění."..
            "Značka {} se nahradí absolutní hodnotou počtu sekund záporného zpoždění.]"..
            "container_end[]"..
            "container[0.5,10.5]"..
            "box[0,0.15;14,0.05;#000000FF]"}
            --[[
            -- hlášení do četu (zatím neimplementováno):
        a{  "label[7,0.5;dosah hlášení v četu \\[m\\] (0=vyp):]"..
            "field[11.5,0.25;2,0.5;chat_dosah;;",
            tostring(data.chat_dosah or "50"),
            "]"..
            "tooltip[chat_dosah;Dosah je současně limitován doslechem jednotlivých hráčských postav.]"..
            "label[0,0.5;texty pro hlášení příjezdu/přistavení vlaku v četu:]"..
            "tablecolumns[text;text]"..
            "table[0,0.75;14,2;texty;"}
        for _, def in ipairs(hl_texty) do
            local id = "tx_"..def.id
            a(def.fs_sample)
            a(",")
            a(F(data[id] or def.default or def.sample))
            a(",")
        end
        formspec[#formspec] = ";"..(custom_state.tx_index or "").."]"
        a("label[0.1,3.125;text:]".."field[0.75,2.75;10,0.75;preklad;;")
        if custom_state.tx_index ~= nil then
            local def = assert(hl_texty[custom_state.tx_index])
            local id = "tx_"..def.id
            local s = data[id]
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
        a("]")
        ]]
        a("container_end[]"--[[..
            -- ----
            "container[0.5,9.25]"..
            "label[0,0.25;Formáty řádků ({1}, {2} atd.):]"..
            "container_end[]" ]]
        )
        a("button[0.5,15;14,1;btn_save;Uložit]")
    elseif page == PAGE_SETUP_2 then
        a(  "textarea[0.5,2;14,2;;;Podporované značky: {LINKA}\\, {VYCHOZI}\\, {CIL}\\, {KOLEJ}\\, {PRIJZA}\\, {ODJZA}\\, {ZPOZDENI}\\,"..
            " {PREDCH}\\, {NASL}\\, {JMVLAKU}\\, {TYP}\\, {TYPVLAKU}\\, {ZDE}\\, {KOLEJE}.\n"..
            "{LINKA:4} (pevná délka)\\, {LINKA:4-} (min. délka)\\, {LINKA:-4} (max. délka)\\, {LINKA:2-4} (rozmezí).\n"..
            "Náhr. text: {LINKA|-}\\, {LINKA:3|-}.\n"..
            "Zopakování symbolu (ne \\[A-Za-z0-9{}\\:|\\]), lze použít i ve formátu prázdných řádků: {.:7}\\, { :4}.]"..
            "container[0.5,4]")
        for i = 1, 4 do
            local cedule = data.cedule[i]
            local s = tostring(i)
            a{  "container[0,", string.format("%f", 2.5 * (i - 1)),
                "]label[0,0.3;cedule ", s, ":]"..
                "field[0,0.9;9.75,0.75;fmt_cedule", s, "_row;formát řádky / prázdný řádek:;",
                F(cedule.row),
                "]field[0,1.75;9.75,0.75;fmt_cedule", s, "_empty;;", F(cedule.empty),
                "]textarea[10,0.5;4,2;fmt_cedule", s, ";;"..F(cedule.text),
                "]field[2,0;4.5,0.5;pos_cedule", s, ";;", cedule.fs,
                "]button_exit[10,0;3,0.5;zam_cedule", s,
                ";zaměřit...]button[6.75,0;3,0.5;",
                ifthenelse(cedule.fs ~= "", "odp_cedule"..s..";odpojit", "pri_cedule"..s..";připojit"),
                "]container_end[]",
            }
        end
        a{  "container_end[]"..
            "label[0.5,14.5;", CF(custom_state.message), "]"..
            "button[0.5,15;14,1;btn_save;Uložit]",
        }
    elseif page == PAGE_IMPORT then
        a{
            "textarea[0.5,2.5;14,10;nastaveni;nastavení ve formátu JSON:;",
            -- CF(core.write_json(data, true)),
            "(Zatím neimplementováno)",
            "]label[0.5,13;",
            CF(custom_state.message),
            "]".. -- "button[0.5,13.5;14,1;importovat;importovat zadané nastavení a uložit]"..
            "button_exit[0.5,15;14,1;close2;zavřít]",
        }

    elseif page == PAGE_HELP then
    elseif custom_state.is_admin and page == PAGE_OWNERSHIP then
        a{
            "field[0.5,2.5;5,0.75;owner;vlastník/ice:;",
            ch_core.prihlasovaci_na_zobrazovaci(custom_state.owner),
            "]button[5.75,2.5;3,0.75;set_owner;nastavit]"..
            "label[0.5,13;",
            CF(custom_state.message),
            "]button_exit[0.5,15;14,1;close2;zavřít]",
        }
    end
    return table.concat(formspec)
end

local function setup_formspec_callback(custom_state, player, formname, fields)
    -- print("DEBUG: setup_formspec_callback(): "..dump2({custom_state = custom_state, fields = fields, player_name = custom_state.player_name}))
    assert(player:get_player_name() == custom_state.player_name)
    local node = core.get_node(custom_state.pos)
    if node.name ~= rozhlas_node_name then
        return
    end
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
            if #list == 0 then
                -- všechny koleje
                data.fs_koleje = ""
                data.koleje = ""
            elseif #list == 1 then
                data.fs_koleje = F(list[1])
                data.koleje = list[1]
            else
                table.sort(list, function(a, b) return a < b end)
                data.fs_koleje = F(table.concat(list, ","))
                data.koleje = set
            end
        end
        if fields.fmt_delay then
            data.fmt_delay = fields.fmt_delay
        end
        if fields.fmt_nodelay then
            data.fmt_nodelay = fields.fmt_nodelay
        end
        if fields.fmt_negdelay then
            data.fmt_negdelay = fields.fmt_negdelay
        end

        -- texty
        if fields.texty then
            local event = core.explode_table_event(fields.texty)
            if (event.type == "CHG" or event.type == "DCL") and event.row ~= custom_state.tx_index and hl_texty[event.row] ~= nil then
                custom_state.tx_index = event.row
            end
        end

        if fields.preklad_set and custom_state.tx_index then
            local def = assert(hl_texty[custom_state.tx_index])
            custom_state.data["tx_"..def.id] = assert(fields.preklad)
            return get_setup_formspec(custom_state)
        end
        if fields.chat_dosah and tonumber(fields.chat_dosah) ~= nil then
            local new_dosah = tonumber(fields.chat_dosah)
            if new_dosah ~= nil and new_dosah == math.floor(new_dosah) and new_dosah >= 0 and new_dosah < 1024 then
                custom_state.data.chat_dosah = new_dosah
            end
        end

        -- uložit?
        if fields.btn_save then
            local new_stn = custom_state.stations[custom_state.station_index].stn
            if new_stn ~= stn then
                -- přesunout rozhlas na jinou dopravnu
                local meta = assert(core.get_meta(custom_state.pos))
                local old_anns = get_or_add_anns(stn)
                local new_anns = get_or_add_anns(new_stn)
                if old_anns ~= nil and new_anns ~= nil then
                    local epos = custom_state.epos
                    new_anns[epos] = old_anns[epos]
                    old_anns[epos] = nil
                    meta:set_string("stn", new_stn)
                    stn = new_stn
                    custom_state.stn = new_stn
                end
            end
            set_ann_data(stn, custom_state.epos, data)
            custom_state.data = get_ann_data(stn, custom_state.epos, true)
        end
    elseif page == PAGE_SETUP_2 then
        -- update fields:
        for i = 1, 4 do
            local cedule = data.cedule[i]
            local s = fields["fmt_cedule"..i]
            if s ~= nil then
                cedule.text = s
                cedule.text_rtf = ktere_radky(s, true)
            end
            s = fields["fmt_cedule"..i.."_row"]
            if s ~= nil then
                cedule.row = s
            end
            s = fields["fmt_cedule"..i.."_empty"]
            if s ~= nil then
                cedule.empty = s
            end
        end
        if fields.btn_save then
            local new_cedule = {}
            for i = 1, 4 do
                new_cedule[i] = table.copy(data.cedule[i])
            end
            get_ann_data(stn, custom_state.epos, false).cedule = new_cedule
            -- print("DEBUG: new_cedule saved, ann_data = "..dump2(get_ann_data(stn, custom_state.epos, false)))
            return get_setup_formspec(custom_state)
        else
            for i = 1, 4 do
                if fields["pri_cedule"..i] then
                    -- připojit ceduli:
                    local pos_cedule_str = fields["pos_cedule"..i]
                    local x, y, z = pos_cedule_str:match("^(-?%d+),(-?%d+),(-?%d+)$")
                    if x == nil or y == nil or z == nil then
                        custom_state.message = "Chybný formát pozice: "..pos_cedule_str
                        return get_setup_formspec(custom_state)
                    end
                    local pos_cedule = vector.new(tonumber(x), tonumber(y), tonumber(z))
                    local success, message = attach_sign(stn, custom_state.epos, i, pos_cedule)
                    if success then
                        local current_data = get_ann_data(stn, custom_state.epos, true)
                        if current_data ~= nil then
                            custom_state.data = current_data
                        end
                        custom_state.message = "Cedule úspěšně připojena."
                    else
                        custom_state.message = "CHYBA: "..message
                    end
                    return get_setup_formspec(custom_state)
                end
                if fields["odp_cedule"..i] then
                    local success, message = detach_sign(stn, custom_state.epos, i)
                    if success then
                        local current_data = get_ann_data(stn, custom_state.epos, true)
                        if current_data ~= nil then
                            custom_state.data = current_data
                        end
                        custom_state.message = "Cedule úspěšně odpojena."
                    else
                        custom_state.message = "CHYBA: "..message
                    end
                    return get_setup_formspec(custom_state)
                end
                if fields["zam_cedule"..i] then
                    local player_name = player:get_player_name()
                    local stack = player:get_wielded_item()
                    if stack:is_empty() then
                        player:set_wielded_item("advtrains_line_automation:sign_selector")
                        core.chat_send_player(player_name, "*** Levým klikem vyberte ceduli k připojení...")
                    else
                        player:get_inventory():add_item("main", "advtrains_line_automation:sign_selector")
                        core.chat_send_player(player_name, "*** Levým klikem výběrovým nástrojem vyberte ceduli k připojení...")
                    end
                    punch_context[player_name] = {stn = assert(custom_state.stn), epos = custom_state.epos, i = i}
                    return
                end
            end
        end
    elseif page == PAGE_IMPORT then
        if fields.importovat then
            local s = assert(fields.nastaveni)
            -- TODO
        end
    elseif page == PAGE_HELP then
        -- nic
    elseif page == PAGE_OWNERSHIP then
        if is_admin and fields.set_owner then
            local new_owner = ch_core.jmeno_na_existujici_prihlasovaci(fields.owner or "")
            if new_owner == nil then
                custom_state.message = "Postava '"..(fields.owner or "").."' neexistuje!"
            else
                core.load_area(custom_state.pos)
                local meta = core.get_meta(custom_state.pos)
                meta:set_string("owner", new_owner)
                custom_state.owner = new_owner
            end
            return get_setup_formspec(custom_state)
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
            custom_state.message = "" -- smazat zprávu
        end
        return get_setup_formspec(custom_state)
    end
    if not fields.quit then
        return get_setup_formspec(custom_state)
    end
end

local debug_counter = 0

local function update_ann(stn, epos, signs, deps, rwtime)
    -- print("DEBUG: update_ann(): "..dump2({stn = stn, epos = epos, signs = signs, deps = deps, rwtime = rwtime}))
    local ann = get_ann_data(stn, epos)
    if ann == nil then
        core.log("error", "update_ann() called for "..stn.."/"..epos..", but ann is nil!")
        return
    end
    local tracks = ann.koleje
    if tracks ~= nil and type(tracks) ~= "table" then
        if tracks == "" then
            tracks = nil
        else
            tracks = {[tracks] = true}
        end
    end
    local any_line = {
        KOLEJE = "TODO", -- [ ] TODO
        ZDE = al.get_station_name(stn),
    }
    -- print("DEBUG: "..dump2({tracks = tracks}))
    local lines = {}
    -- update_ann(assert(stn), assert(ann.rozh_epos), signs, deps)
    for _, dep in ipairs(deps) do
        if (tracks == nil or tracks[dep.track]) and (dep.dep == nil or dep.dep > rwtime) then
            local linevar_def = dep.linevar_def
            local stops = linevar_def.stops
            local line = setmetatable({}, {__index = any_line})
            line.LINKA = linevar_def.line or ""
            line.VYCHOZI = al.get_line_description(linevar_def, {line_number = false, first_stop = true, last_stop = false})
            line.CIL = dep.destination
            if dep.track ~= "" then
                line.KOLEJ = dep.track
            end
            if dep.arr ~= nil then
                line.PRIJZA = math.ceil((dep.arr - rwtime) / 5) * 5
            end
            if dep.dep ~= nil then
                line.ODJZA = math.ceil((dep.dep - rwtime) / 5) * 5
            end
            local abs_delay = math.abs(dep.delay)
            if abs_delay < 5 then
                line.ZPOZDENI = ann.fmt_nodelay or ""
            else
                line.ZPOZDENI = dosadit(
                    ifthenelse(dep.delay > 0, ann.fmt_delay or "{}", ann.fmt_negdelay or "-{}"),
                    {[""] = tostring(5 * math.ceil(abs_delay / 5))}
                )
            end
            -- PREDCH
            if dep.prev_stop ~= nil then
                line.PREDCH = dep.prev_stop
            end
            -- NASL
            if dep.next_stop ~= nil then
                line.NASL = dep.next_stop
            end
            -- POLOHA
            if dep.last_pos ~= nil then
                line.POLOHA = dep.last_pos
            end
            -- JMVLAKU
            if linevar_def.train_name ~= nil then
                line.JMVLAKU = linevar_def.train_name
            end
            -- TYP
            line.TYP = "Os"
            -- TYPVLAKU
            line.TYPVLAKU = "osobní vlak"
            debug_counter = debug_counter + 1
            line.POCITADLO = tostring(debug_counter)
            table.insert(lines, line)
        end
    end
    if signs ~= nil then
        local empty_table = {}
        for i = 1, 4 do
            local cedule = ann.cedule[i]
            local sign_pos = signs[i]
            if sign_pos ~= nil and core.compare_block_status(sign_pos, "active") then
                local formatted_lines = setmetatable({}, {__index = any_line})
                if type(cedule.text_rtf) == "table" then
                    for _, i_row in ipairs(cedule.text_rtf) do
                        if lines[i_row] == nil then
                            -- prázdný řádek
                            formatted_lines[tostring(i_row)] = dosadit(cedule.empty, empty_table)
                        else
                            -- řádek odjezdu
                            local s = dosadit(cedule.row, lines[i_row])
                            if s ~= "" and ann.fn_firstupper then
                                local l = ch_core.utf8_seek(s, 1, 1)
                                if l == nil then
                                    s = ch_core.na_velka_pismena(s)
                                else
                                    local c = s:sub(1, l - 1)
                                    local uc = ch_core.na_velka_pismena(c)
                                    if uc ~= c then
                                        s = uc..s:sub(l, -1)
                                    end
                                end
                            end
                            formatted_lines[tostring(i_row)] = s
                        end
                    end
                end
                local s = dosadit(cedule.text, formatted_lines)
                if has_signs_api then
                    signs_api.set_display_text(sign_pos, s)
                end
            end
        end
    end
end

local globalstep_time = -5

local function globalstep(dtime)
    globalstep_time = globalstep_time + dtime
    if globalstep_time < 0 then
        return
    end
    globalstep_time = globalstep_time - 5

    local rwtime = rwt.to_secs(rwt.get_time())
    -- Shromáždit rozhlasy:
    local subscriptions = {--[[
        [stn] = {{
            rozh_pos = vector,
            rozh_epos = string,
            rozh_def = table,
            signs = {[1..4] = vector or nil} or nil,
        }...}
    ]]}
    local signs = {}
    for stn, stdata in pairs(advtrains.lines.stations) do
        local anns = stdata.anns
        if stdata.anns ~= nil then
            for rozh_epos, ann in pairs(stdata.anns) do
                local rozh_pos = advtrains.decode_pos(rozh_epos)
                local signs_count = 0
                for i = 1, 4 do
                    local cedule = assert(ann.cedule[i])
                    local s = cedule.fs
                    if s ~= nil and s ~= "" then
                        local sign_pos = assert(cedule.pos)
                        if core.compare_block_status(sign_pos, "active") then
                            signs[i] = sign_pos
                            signs_count = signs_count + 1
                        end
                    end
                end
                if signs_count > 0 then
                    -- nějaké cedule jsou aktivní
                    -- print("DEBUG: - "..rozh_epos.." : added ("..stn.."), because has "..signs_count.." active signs")
                    table.insert(goa(subscriptions, stn), {rozh_pos = rozh_pos, rozh_epos = rozh_epos, rozh_def = ann, signs = signs})
                    signs = {}
                elseif core.compare_block_status(rozh_pos, "active") then
                    -- cedule nejsou aktivní, ale rozhlas ano
                    -- print("DEBUG: - "..rozh_epos.." : added ("..stn.."), because is active")
                    table.insert(goa(subscriptions, stn), {rozh_pos = rozh_pos, rozh_epos = rozh_epos, rozh_def = ann})
                end
            end
        else
            -- print("DEBUG: - "..stn.." not added (anns: "..ifthenelse(stdata.anns == nil, "nil", "non-nil")..")")
        end
    end

    -- Shromáždit vlaky:
    local deps_by_stn = {}
    for stn, _ in pairs(subscriptions) do
        deps_by_stn[stn] = {}
    end
    for _, train in pairs(advtrains.trains) do
        local ls, linevar_def = al.get_line_status(train)
        if linevar_def ~= nil then
            local prediction = al.predict_train(ls, linevar_def, rwtime)
            local last_pos = al.get_last_pos_station_name(ls)
            local destination = "???"
            for i = #prediction, 1, -1 do
                local p = prediction[i]
                if not p.hidden then
                    destination = al.get_station_name(p.stn)
                    break
                end
            end
            for _, record in ipairs(prediction) do
                local deps = deps_by_stn[record.stn]
                if deps ~= nil and record.dep ~= nil then
                    local record_index = assert(record.index)
                    local other_index, other_data = al.get_prev_stop(linevar_def, record_index, false)
                    if other_index ~= nil then
                        record.prev_stop = al.get_station_name(other_data.stn)
                    end
                    other_index, other_data = al.get_next_stop(linevar_def, record_index, false)
                    if other_index ~= nil then
                        record.next_stop = al.get_station_name(other_data.stn)
                    end
                    record.last_pos = last_pos -- název poslední dopravny, kde byl vlak spatřen
                    record.linevar = linevar_def.name
                    record.linevar_def = linevar_def
                    record.destination = destination
                    table.insert(deps, record)
                end
            end
        end
    end

    -- Aktualizovat rozhlasy:
    for stn, deps in pairs(deps_by_stn) do
        table.sort(deps, function(a, b) return assert(a.dep) < assert(b.dep) end)
        for _, ann in ipairs(subscriptions[stn]) do
            update_ann(assert(stn), assert(ann.rozh_epos), ann.signs, deps, rwtime)
        end
    end
end

core.register_globalstep(globalstep)

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
    -- return core.node_dig(pos, node, digger)
    if has_unifieddyes then
        return unifieddyes.on_dig(pos, node, digger)
    else
        return core.node_dig(pos, node, digger)
    end
end

local function on_rightclick(pos, node, clicker, itemstack, pointed_thing)
    if clicker == nil or not clicker:is_player() then
        return
    end
    local player_name = assert(clicker:get_player_name())
    local meta = core.get_meta(pos)
    local owner = meta:get_string("owner")
    local stn = meta:get_string("stn")
    local epos = advtrains.encode_pos(pos)
    local stdata = advtrains.lines.stations[stn]
    if owner == "" or stn == "" or stdata == nil or stdata.anns == nil or stdata.anns[epos] == nil then
        if not core.check_player_privs(clicker, "railway_operator") then
            core.chat_send_player(player_name, "*** K instalaci staničního rozhlasu je nutné právo railway_operator!")
            return
        end
        local limit = 256 * 256
        local stations = advtrains.lines.load_stations_for_formspec()
        local list = {}
        for i, station_data in ipairs(stations) do
            local d2 = limit
            for _, stop in ipairs(station_data.tracks) do
                local d2new = dist2(pos, stop.pos)
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
            "item_image[0.5,0.5;1,1;"..rozhlas_node_name.."]"..
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
            custom_state.selection_index = 1
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

local function selector_on_use(itemstack, user, pointed_thing)
    if pointed_thing.type ~= "node" then
        return
    end
    if user ~= nil then
        local player_name = user:get_player_name()
        local pc = punch_context[player_name]
        if pc ~= nil then
            local success, message = attach_sign(assert(pc.stn), assert(pc.epos), assert(pc.i), assert(pointed_thing.under))
            if not success then
                message = message.." Zaměřování bude zrušeno."
            end
            core.chat_send_player(player_name, message)
        end
    end
    return ItemStack()
end

local box = {
    type = "fixed",
    fixed = {
        {-0.25, -0.25, 0, 0.25, 0.25, 0.5},
        {-0.5, -0.4, -0.25, 0.5, 0.4, 0},
    },
}

def = {
    description = "staniční rozhlas [EXPERIMENTÁLNÍ]",
    tiles = {{name = "default_steel_block.png", backface_culling = true}},
    drawtype = "mesh",
    mesh = "advtrains_tuber.obj",
    paramtype = "light",
    paramtype2 = "4dir",
    selection_box = box,
    collision_box = box,
    groups = {oddly_breakable_by_hand = 3, ud_param2_colorable = 1, experimental = 1}, -- TODO
    sounds = default.node_sound_metal_defaults(),
    can_dig = can_dig,
    on_dig = on_dig,
    on_construct = on_construct,
    on_destruct = on_destruct,
    on_rightclick = on_rightclick,
}
if has_unifieddyes then
    def.paramtype2 = "color4dir"
    def.palette = "unifieddyes_palette_color4dir.png"
end
core.register_node(rozhlas_node_name, def)

def = {
    description = "levým klikem zvolte ceduli pro připojení",
    groups = {not_in_creative_inventory = 1, tool = 1},
    inventory_image = "[combine:16x16:7,0=blank.png\\^[noalpha\\^[resize\\:2x16:0,7=blank.png\\^[noalpha\\^[resize\\:16x2",
    wield_image = "blank.png",
    on_use = selector_on_use,
}

core.register_tool("advtrains_line_automation:sign_selector", def)

