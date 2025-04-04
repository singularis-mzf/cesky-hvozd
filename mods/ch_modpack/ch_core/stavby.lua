ch_core.open_submod("stavby", {chat = true, events = true, lib = true})

--[[
Datová struktura záznamu o stavbě:

{
    key = string, -- pozice stavby v normalizovaném tvaru (klíč do tabulky staveb)
    pos = {x = int y = int, z = int} -- pozice stavby ve formě vektoru celých čísel

    -- ostatní pole mohou být přímo upravována:
    nazev = string, -- název stavby (nemusí být jedinečný)
    druh = string, -- druh stavby (doplňuje název)
    zalozil_a = string, -- postava, která stavby založila (přihlašovací tvar)
    spravuje = string, -- postava, která stavbu spravuje (přihlašovací tvar)
    urceni = string, -- jeden z řetězců z ch_core.urceni_staveb
    stav = string, -- jeden z řetězců z ch_core.stavy_staveb
    historie = {
        [1...] = string, ...
    } -- postupná historie změn
    zamer = string, -- záměr stavby (text)
    heslo = string || nil, -- do budoucna: vygenerované heslo u staveb nabízených k převzetí; kdo heslo zadá, dostane stavbu do správy
    mapa = {x1, z1, [w, h]}, -- volitelné pole; definuje místo zobrazení na mapě (buď jen bod, nebo zónu)
}
]]

minetest.register_privilege("ch_stavby_admin", {
    description = "Umožňuje měnit všechny vlastnosti registrovaných staveb.",
    give_to_singleplayer = true,
    give_to_admin = true,
})

local worldpath = minetest.get_worldpath()

ch_core.urceni_staveb = {
    soukroma = "soukromá",
    verejna = "veřejná",
    chranena_oblast = "chráněná oblast",
}

ch_core.stavy_staveb = {
    k_povoleni = "čeká na stavební povolení",
    rozestaveno = "rozestavěná",
    k_schvaleni = "k schválení",
    hotovo = "hotová",
    rekonstrukce = "v rekonstrukci",
    opusteno = "opuštěná",
    k_smazani = "ke smazání",
}

ch_core.urceni_staveb_r = table.key_value_swap(ch_core.urceni_staveb)
ch_core.stavy_staveb_r = table.key_value_swap(ch_core.stavy_staveb)

local function pos_to_key(pos)
    pos = vector.round(pos)
    return string.format("%d,%d,%d", pos.x, pos.y, pos.z)
end

local function key_to_pos(s)
    local parts = s:split(",")
    local result
    if #parts == 3 then
        result = vector.round(vector.new(assert(tonumber(parts[1])), assert(tonumber(parts[2])), assert(tonumber(parts[3]))))
    end
    return result
end

local function verify_record(record)
    if record == nil then
        return "record is nil!"
    end
    local s
    if type(record.key) ~= "string" then return "invalid key type: "..type(record.key) end
    local pos = key_to_pos(record.key)
    if pos == nil then return "invalid key (cannot unhash): "..record.key end
    s = type(record.pos)
    if s ~= "table" then return "invalid pos type: "..s end
    if pos.x ~= record.pos.x or pos.y ~= record.pos.y or pos.z ~= record.pos.z then
        return "invalid or inconsistent record.pos!"
    end
    s = type(record.nazev)
    if s ~= "string" and s ~= "number" then return "invalid nazev type: "..s end
    if record.nazev == "" then return "empty nazev!" end
    s = type(record.zalozil_a)
    if s ~= "string" and s ~= "number" then return "invalid zalozil_a type: "..s end
    s = type(record.spravuje)
    if s ~= "string" and s ~= "number" then return "invalid spravuje type: "..s end
    s = record.urceni
    if s == nil or ch_core.urceni_staveb[s or ""] == nil then
        return "invalid urceni: "..(s or "nil")
    end
    s = record.stav
    if s == nil or ch_core.stavy_staveb[s or ""] == nil then
        return "invalid stav: "..(s or "nil")
    end
    s = type(record.historie)
    if s ~= "table" then return "invalid historie type: "..s end
    for i, v in ipairs(record.historie) do
        if type(v) ~= "string" then return "invalid historie["..i.."] type: "..type(v) end
    end
    s = type(record.zamer)
    if s ~= "string" and s ~= "number" then return "invalid zamer type: "..s end
    return nil
end

local function load_data()
    local f = io.open(worldpath.."/ch_stavby.json")
    local result
    if f then
        result = f:read("*a")
        f:close()
        if result ~= nil then
            result = assert(minetest.parse_json(result))
        end
    end
    if result ~= nil then
        local count = 0
        for key, record in pairs(result) do
            local error_message = verify_record(record)
            if error_message == nil and key ~= record.key then
                error_message = "key mismatch! table key = <"..key..">, record key = <"..(record.key or "nil")..">"
            end
            if error_message ~= nil then
                minetest.log("warning", "[ch_core/stavby] Verification error for stavba <"..key..">: "..error_message)
            end
            count = count + 1
        end
        minetest.log("info", "[ch_core/stavby] "..count.." records loaded.")
        return result
    end
    minetest.log("warning", "[ch_core/stavby] No data was loaded!")
    return {}
end

local data = load_data()

function ch_core.stavby_add(pos, urceni, stav, nazev, druh, player_name, zamer)
    local key = assert(pos_to_key(pos))
    if data[key] ~= nil then
        return nil -- a duplicity!
    end
    if nazev == nil or nazev == "" then nazev = "Bez názvu" end
    if druh == nil then druh = "" end
    assert(player_name ~= nil)
    local cas = ch_time.aktualni_cas()
    local new_record = {
        key = key,
        pos = assert(key_to_pos(key)),
        urceni = urceni,
        nazev = nazev,
        druh = druh,
        zalozil_a = player_name,
        spravuje = player_name,
        stav = stav,
        historie = {
            string.format("%s založeno (správa: %s, stav: %s)",
                cas:YYYY_MM_DD(), ch_core.prihlasovaci_na_zobrazovaci(player_name), assert(ch_core.stavy_staveb[stav]))
        },
        zamer = zamer or "",
    }

    local record_error = verify_record(new_record)
    if record_error ~= nil then
        error("stavby_add() internal error: "..record_error)
    end
    data[key] = new_record
    return new_record
end

function ch_core.stavby_get(key_or_pos)
    if type(key_or_pos) ~= "string" then
        key_or_pos = pos_to_key(key_or_pos)
    end
    return data[key_or_pos]
end

function ch_core.stavby_get_all(filter, sorter, extra_argument)
    local result = {}
    if filter == nil then
        filter = function() return true end
    end
    for _, record in pairs(data) do
        if filter(record, extra_argument) then
            table.insert(result, record)
        end
    end
    if sorter ~= nil then
        table.sort(result, function(a, b) return sorter(a, b, extra_argument) end)
    end
    return result
end

function ch_core.stavby_move(key_from, pos)
    local record = data[key_from]
    local key_to = pos_to_key(pos)
    if record == nil then return nil end
    if data[key_to] ~= nil then return false end
    record.key = key_to
    record.pos = key_to_pos(key_to)
    data[key_from] = nil
    data[key_to] = record
    return true
end

function ch_core.stavby_remove(key_or_pos)
    if type(key_or_pos) ~= "string" then
        key_or_pos = pos_to_key(key_or_pos)
    end
    if data[key_or_pos] == nil then
        return false
    end
    data[key_or_pos] = nil
    return true
end

local stavby_html_transtable = {
    ["-"] = "m",
    [","] = "x",
}

function ch_core.stavby_save()
    local json, error_message = minetest.write_json(data)
    if json == nil then
        error("ch_core.stavby_save(): serialization error: "..tostring(error_message or "nil"))
    end
    minetest.safe_file_write(worldpath.."/ch_stavby.json", json)
    minetest.log("info", "ch_core/stavby: "..#data.." records saved ("..#json.." bytes).")
    local html = {}
    for key, stavba in pairs(data) do
        local html_key = "st_"..key:gsub("[-,]", stavby_html_transtable)
        local nazev = stavba.nazev
        if stavba.druh ~= "" then
            nazev = stavba.nazev.." ("..stavba.druh..")"
        end
        nazev = ch_core.formspec_hypertext_escape(nazev)
        local mapa = stavba.mapa

        table.insert(html, "<div class=\""..stavba.stav.." "..stavba.urceni)
        if mapa ~= nil and #mapa == 4 then
            table.insert(html, " zona")
        end
        table.insert(html, "\" id=\""..html_key.."\" style=\"")
        if mapa == nil then
            table.insert(html, string.format("left:%dpx;top:%dpx;", stavba.pos.x, -stavba.pos.z))
        elseif #mapa == 2 then
            table.insert(html, string.format("left:%dpx;top:%dpx;", mapa[1], -mapa[2]))
        else
            table.insert(html, string.format("left:%dpx;top:%dpx;width:%dpx;height:%dpx;", mapa[1], -(mapa[2] + mapa[4]), mapa[3], mapa[4]))
        end
        table.insert(html, "\" title=\"")
        if stavba.urceni == "soukroma" then
            table.insert(html, "&lt;soukromá stavba&gt;&#13;")
        elseif stavba.urceni == "chranena_oblast" then
            table.insert(html, "&lt;rezervovaná oblast&gt;&#13;")
        end
        table.insert(html, nazev.."&#13;spravuje: "..ch_core.prihlasovaci_na_zobrazovaci(stavba.spravuje)..
            "&#13;stav: "..assert(ch_core.stavy_staveb[stavba.stav]).."\">"..nazev.."</div>\n")
    end
    minetest.safe_file_write(worldpath.."/ch_stavby.html", table.concat(html))
end

local function stavba_na_mape(admin_name, param)
    local params = string.split(param, " ")
    if #params ~= 1 and #params ~= 3 and #params ~= 5 then
        return false, "Neplatný počet parametrů!"
    end
    local stavba = data[params[1]]
    if stavba == nil then
        return false, "Stavba s klíčem <"..params[1].."> nenalezena!"
    end
    if #params == 1 then
        stavba.mapa = nil
    else
        local x1, z1 = tonumber(params[2]), tonumber(params[3])
        if x1 == nil or z1 == nil then
            return false, "Neplatné zadání!"
        end
        if #params == 3 then
            stavba.mapa = {x1, z1}
        elseif #params == 5 then
            local x2, z2 = tonumber(params[4]), tonumber(params[5])
            if x2 == nil or z2 == nil then
                return false, "Neplatné zadání!"
            end
            if x2 < x1 then x1, x2 = x2, x1 end
            if z2 < z1 then z1, z2 = z2, z1 end
            stavba.mapa = {x1, z1, x2 - x1 + 1, z2 - z1 + 1}
        end
    end
    ch_core.stavby_save()
    return true, "Nastaveno."
end

local def = {
    params = "<pozice,stavby> [<x1> <z1> [<x2> <z2>]]",
    description = "Pro správce/yni staveb: nastaví zobrazení stavby na mapě nebo toto nastavení zruší.",
    privs = {ch_stavby_admin = true},
    func = stavba_na_mape,
}

minetest.register_chatcommand("stavbanamapě", def)
minetest.register_chatcommand("stavbanamape", def)

ch_core.close_submod("stavby")
