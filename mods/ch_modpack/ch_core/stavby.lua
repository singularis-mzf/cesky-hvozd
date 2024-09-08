ch_core.open_submod("stavby", {chat = true, lib = true})

--[[
Datová struktura záznamu o stavbě:

{
    key = string, -- pozice stavby v normalizovaném tvaru (klíč do tabulky staveb)
    pos = {x, y, z} -- pozice stavby ve formě tabulky celých čísel

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
    local cas = ch_core.aktualni_cas()
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
            string.format("%04d-%02d-%02d založeno (správa: %s, stav: %s)",
                cas.rok, cas.mesic, cas.den, ch_core.prihlasovaci_na_zobrazovaci(player_name), assert(ch_core.stavy_staveb[stav]))
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
    for key, record in pairs(data) do
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

function ch_core.stavby_save()
    local json, error_message = minetest.write_json(data)
    if json == nil then
        error("ch_core.stavby_save(): serialization error: "..tostring(error_message or "nil"))
    end
    minetest.safe_file_write(worldpath.."/ch_stavby.json", json)
    minetest.log("info", "ch_core/stavby: "..#data.." records saved ("..#json.." bytes).")
end

ch_core.close_submod("stavby")
