local al = advtrains.lines
local rwt = assert(advtrains.lines.rwt)

local MODE_NORMAL = 0 -- normální zastávka (výchozí nebo mezilehlá)
local MODE_REQUEST_STOP = 1 -- zastávka na znamení (mezilehlá)
local MODE_HIDDEN = 2 -- skrytá zastávka (výchozí nebo mezilehlá)
local MODE_DISABLED = 3 -- vypnutá zastávka (mezilehlá nebo koncová)
local MODE_FINAL = 4 -- koncová zastávka (linka zde jízdu končí)
local MODE_FINAL_HIDDEN = 5 -- koncová zastávka skrytá
local MODE_FINAL_CONTINUE = 6 -- koncová zastávka (vlak pokračuje jako jiná linka)

local simple_modes = {
    [MODE_NORMAL] = MODE_NORMAL,
    [MODE_REQUEST_STOP] = MODE_NORMAL,
    [MODE_HIDDEN] = MODE_NORMAL,
    [MODE_DISABLED] = MODE_DISABLED,
    [MODE_FINAL] = MODE_FINAL,
    [MODE_FINAL_HIDDEN] = MODE_FINAL,
    [MODE_FINAL_CONTINUE] = MODE_FINAL,
}

local current_passages = {--[[
    [train_id] = {
        [1] = rwtime,
        ...,
        [n] = rwtime (časy *odjezdu*, kromě koncových zastávek, kde jde o čas příjezdu)
        wait = int or nil (původně naplánovaná doba čekání na výchozí zastávce)
    }
]]}

local last_passages = {--[[
    [linevar] = {
        [1..10] = {[1] = rwtime, ..., wait} -- jízdy seřazeny od nejstarší (1) po nejnovější (až 10) podle odjezdu z výchozí zastávky
    }
]]}

local diakritika_na_velka = {
	["á"] = "Á", ["ä"] = "Ä", ["č"] = "Č", ["ď"] = "Ď", ["é"] = "É", ["Ě"] = "Ě", ["Í"] = "Í", ["ĺ"] = "Ĺ", ["ľ"] = "Ľ",
	["ň"] = "Ň", ["ó"] = "Ó", ["ô"] = "Ô", ["ŕ"] = "Ŕ", ["ř"] = "Ř", ["š"] = "Š", ["ť"] = "Ť", ["ú"] = "Ú", ["ů"] = "Ů",
	["ý"] = "Ý", ["ž"] = "Ž",
}

local debug_print_i = 0

-- LOCAL funkce:
-- =========================================================================
local function debug_print(s)
    debug_print_i = debug_print_i + 1
    -- core.chat_send_all("["..debug_print_i.."] "..tostring(s))
    return s
end

-- Je-li stn kód stanice, vrací její jméno, jinak vrací "???". stn může být i nil.
local function get_station_name(stn)
    local station = advtrains.lines.stations[stn or ""]
    if station ~= nil and station.name ~= nil then
        return station.name
    else
        return "???"
    end
end
al.get_station_name = get_station_name

local function na_velka_pismena(s)
	local l = #s
	local i = 1
	local res = ""
	local c
	while i <= l do
		c = diakritika_na_velka[s:sub(i, i + 1)]
		if c then
			res = res .. c
			i = i + 2
		else
			res = res .. s:sub(i, i)
			i = i + 1
		end
	end
	return string.upper(res)
end

--[[
    -- Vrací index následujícího výskytu 'stn' v seznamu zastávek podle linevar_def.
    -- Vrací i skryté zastávky, ale ne vypnuté.
    -- Je-li linevar_def == nil nebo stn == nil nebo stn == "", vrací nil.
    - line_status = table
    - linevar_def = table or nil
    - stn = string
    return: int or nil
]]
local function find_next_index(line_status, linevar_def, stn)
    assert(line_status)
    if linevar_def ~= nil and stn ~= nil and stn ~= "" then
        local stops = linevar_def.stops
        if line_status.linevar_index < #stops then
            for i = line_status.linevar_index + 1, #stops do
                local stop = stops[i]
                if stop.stn == stn and (stop.mode or MODE_NORMAL) ~= MODE_DISABLED then
                    return i
                end
            end
        end
    end
end

-- Vrací kódy výchozí a cílové stanice k zobrazení cestujícím: stn_first (string), stn_terminus (string)
-- Předané linevar_def musí obsahovat platný seznam 'stops', ale nemusí obsahovat nic jiného (nemusí to být platná definice).
-- V případě chyby vrací nil, nil.
local function get_first_last_stations(linevar_def)
    local a, b = linevar_def.index_vychozi, linevar_def.index_cil
    if a ~= nil and b ~= nil then
        local stops = linevar_def.stops
        return stops[a].stn, stops[b].stn
    else
        return nil, nil
    end
end

--[[
    Používá se na *nelinkový* vlak stojící na *neanonymní* zastávce.
    Zahájí jízdu na lince nalezené podle kombinace line/stn/rc, nebo vrátí false.
]]
local function line_start(train, stn, departure_rwtime)
    assert(train)
    assert(stn and stn ~= "")
    assert(departure_rwtime)
    local ls = al.get_line_status(train)
    if ls.linevar ~= nil then
        error("line_start() used on a train that is already on a line: "..dump2({train = train}))
    end
    local linevar, linevar_def = al.try_get_linevar(train.line, stn, train.routingcode)
    if linevar == nil or linevar_def.disabled then
        return false
    end
    ls.linevar = linevar
    ls.linevar_station = stn
    ls.linevar_index = 1
    ls.linevar_dep = departure_rwtime
    ls.linevar_last_dep = departure_rwtime
    ls.linevar_last_stn = stn
    ls.linevar_past = nil
    train.text_outside = al.get_line_description(linevar_def, {
        line_number = true,
        last_stop = true,
        last_stop_prefix = "",
        last_stop_uppercase = true,
        train_name = true,
    })
    return true
end

--[[
    Vrací:
    - "true", pokud má vlak zastavit
    - nil, pokud zastavit nemá
    - "on_request", pokud má zastavit na znamení, ale znamení zatím nebylo dáno
]]
local function should_stop(pos, stdata, train)
    if stdata == nil or stdata.stn == nil then
        return nil -- neplatná data
    end
	local n_trainparts = #assert(train.trainparts)
    -- vyhovuje počet vagonů?
    if not ((stdata.minparts or 0) <= n_trainparts and n_trainparts <= (stdata.maxparts or 128)) then
        return nil
    end
    local stn = assert(stdata.stn) -- zastávka stále může být anonymní
	local ls, linevar_def = al.get_line_status(train)
    local next_index
    if stn ~= "" then
        next_index = find_next_index(ls, linevar_def, stn)
    end
    -- jde o linkový vlak?
    if linevar_def ~= nil then
        if next_index == nil then
            return nil
        end
        local stop = assert(linevar_def.stops[next_index])
        if stop.pos ~= nil and stop.pos ~= string.format("%d,%d,%d", pos.x, pos.y, pos.z) then
            return nil
        end
        if stop.mode ~= nil and stop.mode == MODE_REQUEST_STOP then
            if ls.stop_request ~= nil then
                debug_print("Vlak "..train.id.." zastaví na zastávce na znamení.")
                return "true"
            else
                debug_print("Vlak "..train.id.." možná zastaví na zastávce na znamení.")
                return "on_request"
            end
        end
        return "true"
        -- TODO: zastávky na znamení
    else
        local ars = stdata.ars
        -- vyhovuje vlak ARS pravidlům?
        local result = ars and (ars.default or advtrains.interlocking.ars_check_rule_match(ars, train))
        if result then
            return "true"
        else
            return nil
        end
    end
end

local function update_value(train, key, setting)
    if setting == "-" then
        train[key] = nil
    elseif setting ~= "" then
        train[key] = setting
    end
    return train[key]
end

--[[
    Pokud vlak jede na lince, odebere ho z této linky a vrátí true; jinak vrátí false.
]]
function al.cancel_linevar(train)
    local ls = train.line_status
    if ls == nil or ls.linevar == nil then return false end
    ls.linevar = nil
    ls.linevar_station = nil
    ls.linevar_index = nil
    ls.linevar_dep = nil
    ls.linevar_last_dep = nil
    ls.linevar_last_stn = nil
    train.text_outside = ""
    return true
end

-- Vrací seznam názvů neskrytých zastávek, počínaje od uvedeného indexu.
-- Pokud by vrátila prázdný seznam, vrátí místo něj {"???"}.
function al.get_stop_names(linevar_def, start_index)
    local stations = advtrains.lines.stations
    local result = {}
    if linevar_def ~= nil then
        local stops = linevar_def.stops
        if start_index == nil then
            start_index = 1
        end
        for i = start_index, #stops do
            local stop = stops[i]
            if stop.mode == nil or (stop.mode ~= MODE_HIDDEN and stop.mode ~= MODE_FINAL_HIDDEN and stop.mode ~= MODE_DISABLED) then
                local station = stations[stop.stn]
                if station ~= nil and station.name ~= nil and station.name ~= "" then
                    table.insert(result, station.name)
                else
                    table.insert(result, "???")
                end
            end
        end
    end
    if result[1] == nil then
        result[1] = "???"
    end
    return result
end

--[[
    Vrací:
    a) index, stop_data -- pokud byla vyhovující předchozí zastávka nalezena
    b) nil, nil -- pokud nalezena nebyla
]]
function al.get_first_stop(linevar_def, allow_hidden_stops)
    if allow_hidden_stops then
        return 1, linevar_def.stops[1]
    else
        local result = linevar_def.index_vychozi
        if result ~= nil then
            return result, linevar_def.stops[result]
        else
            return nil, nil
        end
    end
end

--[[
    Vrací:
    a) index, stop_data -- pokud byla vyhovující předchozí zastávka nalezena
    b) nil, nil -- pokud nalezena nebyla
]]
function al.get_last_stop(linevar_def, allow_hidden_stops)
    if allow_hidden_stops then
        local stops = linevar_def.stops[result]
        for i = linevar_def.index_cil, #stops do
            local stop = stops[i]
            local mode = stop.mode
            if mode == MODE_FINAL or mode == MODE_FINAL_CONTINUE or mode == MODE_FINAL_HIDDEN then
                return i, stop
            end
        end
    else
        local result = linevar_def.index_cil
        if result ~= nil then
            return result, linevar_def.stops[result]
        end
    end
    return nil, nil
end

--[[
    Vrací:
    a) index, stop_data -- pokud byla vyhovující předchozí zastávka nalezena
    b) nil, nil -- pokud nalezena nebyla
]]
function al.get_prev_stop(linevar_def, current_index, allow_hidden_stops)
    local stops = assert(linevar_def.stops)
    assert(current_index)
    if current_index > 1 then
        for i = current_index - 1, 1, -1 do
            local mode = stops[i].mode
            if mode == nil or (mode ~= MODE_DISABLED and ((mode ~= MODE_HIDDEN and mode ~= MODE_FINAL_HIDDEN) or allow_hidden_stops)) then
                return i, stops[i]
            end
        end
    end
    return nil, nil
end

--[[
    Vrací:
    a) index, stop_data -- pokud byla vyhovující další zastávka nalezena
    b) nil, nil -- pokud nalezena nebyla
]]
function al.get_next_stop(linevar_def, current_index, allow_hidden_stops)
    local stops = assert(linevar_def.stops)
    assert(current_index)
    if current_index < #stops then
        for i = current_index + 1, #stops do
            local mode = stops[i].mode
            if mode == nil or (mode ~= MODE_DISABLED and ((mode ~= MODE_HIDDEN and mode ~= MODE_FINAL_HIDDEN) or allow_hidden_stops)) then
                return i, stops[i]
            end
        end
    end
    return nil, nil
end

--[[
    Vrací:
    a) index, stop_data -- pokud byla vyhovující koncová zastávka nalezena
    b) nil, nil -- pokud nalezena nebyla
]]
function al.get_terminus(linevar_def, current_index, allow_hidden_stops)
    if linevar_def.index_cil ~= nil then
        return linevar_def.index_cil, linevar_def.stops[linevar_def.index_cil]
    end
    local stops = assert(linevar_def.stops)
    local r_i, r_stop
    if current_index < #stops then
        for i = current_index + 1, #stops do
            local mode = stops[i].mode or MODE_NORMAL
            if mode ~= MODE_DISABLED and ((mode ~= MODE_HIDDEN and mode ~= MODE_FINAL_HIDDEN) or allow_hidden_stops) then
                r_i, r_stop = i, stops[i]
            end
            if mode == MODE_FINAL or mode == MODE_FINAL_CONTINUE or mode == MODE_FINAL_HIDDEN then
                break
            end
        end
    end
    return r_i, r_stop
end

--[[
    options = {
        line_number = bool or nil, -- zahrnout do popisu číslo linky? nil => false
        first_stop = bool or nil, -- zahrnout do popisu název výchozí zastávky? nil => false
        last_stop = bool or nil, -- zahrnout do popisu název cílové zastávky? nil => true
        last_stop_prefix = string or nil, -- text před název cílové zastávky; nil => "⇒ "
        last_stop_uppercase = bool or nil, -- je-li true, název cílové zastávky se před uvedením převede na velká písmena
        train_name = bool or nil, -- zahrnout do popisu jméno vlaku, je-li k dispozici; nil => false
        train_name_prefix = string or nil, -- text před jméno vlaku; nil => "\n"
    }
]]
function al.get_line_description(linevar_def, options)
    local line, stn = al.linevar_decompose(linevar_def.name)
    local first_stn, last_stn = get_first_last_stations(linevar_def)
    if line == nil or first_stn == nil or last_stn == nil then
        return "???"
    end
    if options == nil then options = {} end
    local s1, s2, s3, s4
    if options.line_number then
        s1 = "["..line.."] "
    else
        s1 = ""
    end
    if first_stn == last_stn and options.first_stop and (options.last_stop == nil or options.last_stop) then
        s2 = get_station_name(last_stn)
        if options.last_stop_uppercase then
            s2 = na_velka_pismena(s2)
        end
        s3 = " (okružní)"
    else
        if options.first_stop then
            s2 = get_station_name(first_stn).." "
        else
            s2 = ""
        end
        if options.last_stop == nil or options.last_stop then
            s3 = get_station_name(last_stn)
            if options.last_stop_uppercase then
                s3 = na_velka_pismena(s3)
            end
            s3 = (options.last_stop_prefix or "⇒ ")..s3
        else
            s3 = ""
        end
    end
    if options.train_name and linevar_def.train_name ~= nil then
        s4 = (options.train_name_prefix or "\n")..linevar_def.train_name
    else
        s4 = ""
    end
    return s1..s2..s3..s4
end

function al.get_stop_description(stop_data, next_stop_data)
    local s1, s2 = "", ""
    if stop_data ~= nil then
        local mode = stop_data.mode
        if mode ~= MODE_DISABLED and mode ~= MODE_HIDDEN and mode ~= MODE_FINAL_HIDDEN then
            s1 = get_station_name(stop_data.stn)
            --[[
            if
                mode == MODE_FINAL or mode == MODE_FINAL_CONTINUE or
                (next_stop_data ~= nil and next_stop_data.mode == MODE_FINAL_HIDDEN)
            then
                s2 = "Koncová zastávka"
            end
            ]]
        end
    end
    if next_stop_data ~= nil then
        local mode = next_stop_data.mode
        if mode ~= MODE_DISABLED and mode ~= MODE_HIDDEN and mode ~= MODE_FINAL_HIDDEN then
            s2 = "Příští zastávka/stanice: "..get_station_name(next_stop_data.stn)
            if mode == MODE_REQUEST_STOP then
                s2 = s2.." (na znamení)"
            end
        end
    else
        s2 = "Koncová zastávka"
    end
    if s1 ~= "" and s2 ~= "" then
        return s1.."\n"..s2
    else
        return s1..s2
    end
end

--[[
    Není-li zpoždění k dispozici, vrací {text = ""}, jinak vrací:
    {
        has_delay = bool,
        delay = int,
        text = string,
    }
]]
function al.get_delay_description(line_status, linevar_def, rwtime)
    assert(line_status)
    if linevar_def == nil then
        return {text = ""}
    end
    local stops = linevar_def.stops
    local expected_departure = line_status.linevar_dep + assert(stops[line_status.linevar_index]).dep
    local real_departure = line_status.linevar_last_dep
    local delay = real_departure - expected_departure

    if rwtime ~= nil then
        local expected_departure_next
        for i = line_status.linevar_index + 1, #stops do
            if stops[i] == nil then
                break
            else
                local mode = stops[i].mode
                if mode == nil or mode ~= MODE_DISABLED then
                    expected_departure_next = line_status.linevar_dep + stops[i].dep
                    break
                end
            end
        end
        if expected_departure_next ~= nil then
            local delay2 = rwtime - expected_departure_next
            if delay2 > delay then
                delay = delay2
            end
        end
    end

    if delay < -1 or delay > 10 then
        return {
            has_delay = true,
            delay = delay,
            text = "zpoždění "..delay.." sekund",
        }
    else
        return {
            has_delay = false,
            delay = delay,
            text = "bez zpoždění",
        }
    end
end

-- Test na módy MODE_FINAL*
function al.is_final_mode(stop_mode)
    return stop_mode ~= nil and simple_modes[stop_mode] == MODE_FINAL
end
local is_final_mode = al.is_final_mode

-- Test na skrytou zastávku. Vrací true, pokud zadaný mód neodpovídá skryté zastávce.
function al.is_visible_mode(stop_mode)
	return stop_mode == nil or (stop_mode ~= MODE_HIDDEN and stop_mode ~= MODE_FINAL_HIDDEN)
end
local is_visible_mode = al.is_visible_mode

-- Pokud zadaná varianta linky existuje, vrátí:
--      linevar_def, linevar_station
-- Jinak vrací:
--      nil, nil
-- Je-li linevar_station == nil, doplní se z linevar. Je-li linevar == nil, vrátí nil, nil.
function al.try_get_linevar_def(linevar, linevar_station)
    if linevar == nil then
        return nil, nil
    end
    if linevar_station == nil then
        local line
        line, linevar_station = al.linevar_decompose(linevar)
        if line == nil then
            return nil, nil
        end
    end
    local t = advtrains.lines.stations[linevar_station]
    if t ~= nil then
        t = t.linevars
        if t ~= nil then
            return t[linevar], linevar_station
        end
    end
    return nil, nil
end

--[[
    Vrací:
    a) nil, nil, pokud daná kombinace line/stn/rc nemá definovanou variantu linky
    b) linevar, linevar_def, pokud má
]]
function al.try_get_linevar(line, stn, rc)
    if line ~= nil and line ~= "" and stn ~= nil and stn ~= "" then
        local linevar = line.."/"..stn.."/"..(rc or "")
        local result = al.try_get_linevar_def(linevar, stn)
        if result ~= nil then
            return linevar, result
        end
    end
    return nil, nil
end

--[[
    Vrací 2 hodnoty:
    - line_status = table -- tabulka train.line_status (může být prázdná)
    - linevar_def = table or nil -- jde-li o linkový vlak, vrací definici linevar, jinak nil
    Parametry:
    - train = table (train)
]]
function al.get_line_status(train)
    assert(train)
    if train.line_status == nil then
        train.line_status = {}
        return train.line_status, nil
    end
    local ls = train.line_status
    if ls.linevar == nil then
        -- nelinkový vlak
        local linevar_past = ls.linevar_past
        if linevar_past ~= nil then
            local rwtime = rwt.to_secs(rwt.get_time())
            if train.line ~= linevar_past.line or rwtime - linevar_past.arrival >= 86400 then
                -- smazat linevar_past, pokud se změnilo označení linky nebo uplynulo 24 hodin
                ls.linevar_past = nil
            end
        end
        return ls, nil
    end
    local rwtime = rwt.to_secs(rwt.get_time())
    if rwtime - ls.linevar_dep >= 86400 then
        core.log("warning", "Train "..train.id.." put out of linevar '"..ls.linevar.."', because it was riding more then 24 hours.")
        al.cancel_linevar(train)
        return ls, nil
    end
    local linevar_def = al.try_get_linevar_def(ls.linevar, ls.linevar_station)
    if linevar_def == nil then
        core.log("warning", "Train "..train.id.." was riding a non-existent (undefined) line '"..tostring(ls.linevar).."'!")
        al.cancel_linevar(train)
    elseif linevar_def.stops[ls.linevar_index] == nil then
        core.log("warning", "Train "..train.id.." put out of linevar '"..ls.linevar.."', because its index "..ls.linevar_index.." became invalid.")
        al.cancel_linevar(train)
        linevar_def = nil
    else
        local train_line_prefix = (train.line or "").."/"
        if train_line_prefix ~= ls.linevar:sub(1, train_line_prefix:len()) then
            core.log("warning", "Train "..train.id.." put out of linevar '"..ls.linevar.."', because its line changed to '"..tostring(train.line).."'.")
            al.cancel_linevar(train)
            linevar_def = nil
        end
    end
    return ls, linevar_def
end

function al.on_train_approach(pos, train_id, train, index, has_entered)
    if has_entered then return end -- do not stop again!
    if train.path_cn[index] ~= 1 then return end -- špatný směr
    local pe = advtrains.encode_pos(pos)
    local stdata = advtrains.lines.stops[pe]
    if should_stop(pos, stdata, train) ~= nil then
        advtrains.lzb_add_checkpoint(train, index, 2, nil)
        if train.line_status.linevar == nil then
            -- nelinkový vlak:
            local stn = advtrains.lines.stations[stdata.stn]
            local stnname = stn and stn.name or attrans("Unknown Station")
            train.text_inside = attrans("Next Stop:") .. "\n"..stnname
        end
        advtrains.interlocking.ars_set_disable(train, true)
    end
end

local function record_skipped_stops(train_id, linevar_def, linevar_index, next_index)
    assert(linevar_def)
    if next_index > linevar_index + 1 then
        local skipped_stops = {}
        for i = linevar_index + 1, next_index - 1 do
            local mode = linevar_def.stops[i].mode or MODE_NORMAL
            if mode ~= MODE_DISABLED then
                table.insert(skipped_stops, linevar_def.stops[i].stn)
            end
        end
        if #skipped_stops > 0 then
            core.log("warning", "Train "..train_id.." of line '"..linevar_def.name.."' skipped "..#skipped_stops.." stops: "..
                table.concat(skipped_stops, ", "))
        end
        return #skipped_stops
    else
        return 0
    end
end

function al.on_train_enter(pos, train_id, train, index)
    if train.path_cn[index] ~= 1 then return end -- špatný směr
    local pe = advtrains.encode_pos(pos)
    local stdata = advtrains.lines.stops[pe]
    local stn = stdata.stn or ""
    local rwtime = assert(rwt.to_secs(rwt.get_time()))
    local ls, linevar_def = al.get_line_status(train)
    local next_index
    if stn ~= "" then
        if linevar_def ~= nil then
            next_index = find_next_index(ls, linevar_def, stn)
        end
        ls.last_enter = {stn = stn, encpos = pe, rwtime = rwtime}
        debug_print("Vlak "..train_id.." zaznamenán: "..stn.." "..core.pos_to_string(pos).." @ "..rwtime)
    end
    local should_stop_result = should_stop(pos, stdata, train)
    if should_stop_result == nil then
        debug_print("Vlak "..train_id.." projel zastávkou "..stn)
        return
    elseif should_stop_result == "on_request" then
        -- projetí zastávky na znamení
        debug_print("Vlak "..train_id.." projel zastávkou na znamení "..stn)
        if linevar_def ~= nil and next_index ~= nil then
            local stop_def = assert(linevar_def.stops[next_index])
            if stop_def.mode == nil or stop_def.mode ~= MODE_REQUEST_STOP then
                error("Internal error: mode "..MODE_REQUEST_STOP.." expected, but the real mode is "..tostring(stop_def.mode).."!")
            end
            assert(stn ~= "")
            record_skipped_stops(train_id, linevar_def, ls.linevar_index, next_index)
            ls.linevar_index = next_index
            ls.linevar_last_dep = rwtime -- u zastávky na znamení se průjezd počítá jako odjezd
            ls.linevar_last_stn = stn
            local next_stop_index, next_stop_data = al.get_next_stop(linevar_def, next_index)
            train.text_inside = al.get_stop_description(nil, linevar_def.stops[next_stop_index or 0])
            -- ATC command:
            local atc_command = "A1 S" ..(stdata.speed or "M")
            advtrains.atc.train_set_command(train, atc_command, true)
        end
        return
    end

    -- naplánovat čas odjezdu
    local wait = tonumber(stdata.wait) or 0
    local interval = stdata.interval
    local last_dep = stdata.last_dep -- posl. odjezd z této zastávkové koleje

    if interval ~= nil and last_dep ~= nil then
        if last_dep > rwtime then
            last_dep = rwtime
        end
        local ioffset = stdata.ioffset or 0
        local normal_dep = rwtime + wait
        local next_dep = last_dep + (interval - (last_dep + (interval - ioffset)) % interval)
        if normal_dep < next_dep then
            -- core.log("action", "[INFO] The train "..train_id.." will wait for "..(next_dep - normal_dep).." additional seconds due to interval at "..core.pos_to_string(pos)..".")
            wait = wait + (next_dep - normal_dep)
        -- else -- will wait normal time
        end
    end
    local planned_departure = rwtime + wait
    debug_print("Vlak "..train_id.." zastavil na "..stn.." a odjede za "..wait.." sekund ("..planned_departure..").")
    stdata.last_dep = planned_departure -- naplánovaný čas odjezdu
    stdata.last_wait = wait -- naplánovaná doba čekání
    ls.standing_at = pe
    if linevar_def == nil or next_index == nil or (linevar_def.stops[next_index].mode or MODE_NORMAL) ~= MODE_HIDDEN then
        -- zrušit stop_request, pokud jsme nezastavili na skryté zastávce:
        ls.stop_request = nil
    end

    local can_start_line
    local had_linevar = linevar_def ~= nil
    if linevar_def == nil then
        -- nelinkový vlak
        can_start_line = true
    elseif next_index ~= nil then
        -- linkový vlak zastavil na své řádné zastávce
        assert(stn ~= "") -- dopravna musí mít kód
        local stop_def = assert(linevar_def.stops[next_index])
        debug_print("Vlak "..train_id.." je linkový vlak ("..ls.linevar..") a zastavil na své pravidelné zastávce "..stn.." (index = "..next_index..")")
        record_skipped_stops(train_id, linevar_def, ls.linevar_index, next_index)
        local stop_smode = simple_modes[stop_def.mode or 0]
        if stop_smode == MODE_NORMAL then
            -- mezilehlá zastávka
            can_start_line = false
            ls.linevar_index = next_index
            ls.linevar_last_dep = planned_departure
            ls.linevar_last_stn = stn
            debug_print("Jde o mezilehlou zastávku.")
            local next_stop_index, next_stop_data = al.get_next_stop(linevar_def, next_index)
            train.text_inside = al.get_stop_description(linevar_def.stops[next_index], linevar_def.stops[next_stop_index or 0])
        else
            -- koncová zastávka
            can_start_line = stop_def.mode == MODE_FINAL_CONTINUE
            core.log("action", "Train "..train_id.." arrived at the final station "..stop_def.stn.." of linevar "..ls.linevar.." after "..(rwtime - ls.linevar_dep).." seconds.")
            debug_print("Vlak "..train_id.." skončil jízdu na lince "..ls.linevar..", může pokračovat na jinou linku: "..(can_start_line and "ihned" or "na příští zastávce"))
            train.text_inside = al.get_stop_description(linevar_def.stops[next_index])
            local current_passage = current_passages[train_id]
            if current_passage ~= nil then
                current_passage[next_index] = rwtime
                current_passages[train_id] = nil
            end
            al.cancel_linevar(train)
            -- vyplnit linevar_past:
            if train.line ~= nil and train.line ~= "" then
                ls.linevar_past = {
                    line = assert(linevar_def.line),
                    linevar = assert(linevar_def.name),
                    station = stn,
                    arrival = rwtime,
                }
            end
        end
    else
        -- linkový vlak zastavil na neznámé zastávce (nemělo by nastat)
        core.log("warning", "Train "..train_id.." of linevar '"..ls.linevar.."' stopped at unknown station '"..stn.."' at "..core.pos_to_string(pos).."!")
        debug_print("Vlak "..train_id.." je linkový vlak ("..ls.linevar.."), ale zastavil na sobě neznámé zastávce "..stn..", což by se nemělo stát.")
        can_start_line = false
    end

    -- ATC příkaz
    local atc_command = "B0 W O"..stdata.doors..(stdata.kick and "K" or "").." D"..wait..
        (stdata.keepopen and " " or " OC ")..(stdata.reverse and "R" or "").." D"..(stdata.ddelay or 1)..
        " A1 S" ..(stdata.speed or "M")
    advtrains.atc.train_set_command(train, atc_command, true)

    -- provést změny vlaku
    local new_line = stdata.line or ""
    local new_routingcode = stdata.routingcode or ""
    update_value(train, "line", new_line)
    update_value(train, "routingcode", new_routingcode)

    -- začít novou linku?
    if can_start_line and stn ~= nil and stn ~= "" and line_start(train, stn, planned_departure) then
        debug_print("Vlak "..train_id.." zahájil jízdu na nové lince ("..ls.linevar..") ze stanice "..stn..".")
        core.log("action", "Train "..train_id.." started a route with linevar '"..ls.linevar.."' at station '"..stn.."'.")
        train.text_inside = get_station_name(stn)
        assert(ls.linevar)
        linevar_def = assert(al.try_get_linevar_def(ls.linevar))
        local next_stop_index, next_stop_data = al.get_next_stop(linevar_def, 1)
        if next_stop_index ~= nil then
            train.text_inside = train.text_inside.."\nPříští zastávka/stanice: "..get_station_name(next_stop_data.stn)
            if next_stop_data.mode ~= nil and next_stop_data.mode == MODE_REQUEST_STOP then
                train.text_inside = train.text_inside.." (na znamení)"
            end
        end
    elseif not had_linevar and ls.linevar == nil then
        -- vlak, který nebyl a stále není linkový:
        train.text_inside = get_station_name(stn)
        -- core.after(wait, function() train.text_inside = "" end)
    end
end

function al.on_train_leave(pos, train_id, train, index)
    local pe = advtrains.encode_pos(pos)
    local stdata = advtrains.lines.stops[pe]
    if stdata == nil then
        return -- neplatná zastávka
    end
    local stn = stdata.stn or ""
    local ls, linevar_def = al.get_line_status(train)
    local rwtime = assert(rwt.to_secs(rwt.get_time()))

    if stn ~= "" then
        ls.last_leave = {stn = stn, encpos = pe, rwtime = rwtime}
        debug_print("Vlak "..train_id.." zaznamenán na odjezdu: "..stn.." "..core.pos_to_string(pos).." @ "..rwtime)
    end

    if ls.standing_at == pe then
        -- vlak stál v této dopravně
        ls.standing_at = nil
        if
            linevar_def == nil or ls.linevar_index == nil or
            linevar_def.stops[ls.linevar_index] == nil or
            (linevar_def.stops[ls.linevar_index].mode or MODE_NORMAL) ~= MODE_HIDDEN
        then
            ls.stop_request = nil -- zrušit stop_request při odjezdu ze zastávky, pokud není nekoncová skrytá
        end
        if stn ~= "" then
            debug_print("Vlak "..train_id.." odjel ze zastávky "..stn)
            if ls.linevar_last_dep ~= nil and ls.linevar_last_dep > rwtime then
                debug_print("Vlak "..train_id.." předčasně odjel z dopravny "..stn.." (zbývalo "..(ls.linevar_last_dep - rwtime).." sekund)")
                ls.linevar_last_dep = rwtime -- předčasný odjezd
                if ls.linevar_index == 1 then
                    ls.linevar_dep = rwtime
                end
            end
        else
            debug_print("Vlak "..train_id.." odjel z anonymní zastávky "..core.pos_to_string(pos)..".")
        end
        train.text_inside = ""
        if linevar_def ~= nil then
            -- linkový vlak:
            debug_print("Linkový vlak "..train_id.." odjel ze zastávky s indexem "..ls.linevar_index)
            if ls.linevar_index == 1 then
                -- odjezd z výchozí zastávky:
                local new_passage = {rwtime}
                if stdata.last_wait ~= nil then
                    new_passage.wait = stdata.last_wait
                end
                current_passages[train_id] = new_passage
                local passages_by_linevar = last_passages[ls.linevar]
                if passages_by_linevar == nil then
                    passages_by_linevar = {new_passage}
                    last_passages[ls.linevar] = passages_by_linevar
                else
                    while #passages_by_linevar >= 10 do
                        table.remove(passages_by_linevar, 1)
                    end
                    table.insert(passages_by_linevar, new_passage)
                end
            else
                -- odjezd z nácestné zastávky
                local current_passage = current_passages[train_id]
                if current_passage ~= nil then
                    current_passage[ls.linevar_index] = rwtime
                end
            end
            local next_stop_index, next_stop_data = al.get_next_stop(linevar_def, ls.linevar_index)
            if next_stop_index ~= nil then
                train.text_inside = al.get_stop_description(nil, next_stop_data)
            end
        end
    -- else
        --[[ průjezd?
        local stn = (stdata and stdata.stn) or ""
        if stn ~= "" then
            debug_print("Vlak "..train_id.." projel (odjezd) zastávkou "..stn..".")
        else
            debug_print("Vlak "..train_id.." projel (odjezd) anonymní zastávkou "..core.pos_to_string(pos)..".")
        end
        ]]
    end
end

function al.linevar_decompose(linevar)
    if linevar == nil then
        return nil, nil, nil
    end
    local parts = string.split(linevar, "/", true, 3)
    return parts[1], parts[2] or "", parts[3] or ""
end

--[[
    Vrací:
    a) pokud linevar existuje a má průjezdy:
        passages, stops:
        {{[1] = rwtime, ..., wait = int or nil}...}, {"kód", "název"}...}
    b) jinak:
        nil, nil
]]
function al.get_last_passages(linevar_def)
    local lp = last_passages[linevar_def.name]
    if linevar_def ~= nil and lp ~= nil and lp[1] ~= nil then
        local passages, stops = {}, {}
        for i, stop in ipairs(linevar_def.stops) do
            stops[i] = {stop.stn, get_station_name(stop.stn)}
        end
        for i = 1, #lp do
            passages[i] = table.copy(lp[i])
        end
        return passages, stops
    end
end

local function get_last_pos(line_status)
    assert(line_status)
    local last_enter, last_leave, standing_at = line_status.last_enter, line_status.last_leave, line_status.standing_at
    local last_pos, last_pos_type
    if last_enter ~= nil then
        last_pos, last_pos_type = last_enter, "enter"
        if standing_at ~= nil and standing_at == last_enter.encpos then
            last_pos_type = "standing"
        elseif last_leave ~= nil and last_leave.rwtime > last_enter.rwtime then
            last_pos, last_pos_type = last_leave, "leave"
        end
    elseif last_leave ~= nil then
        last_pos, last_pos_type = last_leave, "leave"
    else
        result.type = "none"
        return {type = "none"}
    end
    local result = {type = last_pos_type, last_pos = last_pos}
    if last_enter ~= nil then
        result.last_enter = last_enter
    end
    if last_leave ~= nil then
        result.last_leave = last_leave
    end
    return result
end

function al.get_last_pos_station_name(line_status)
    local result = get_last_pos(line_status)
    if result.type ~= "none" then
        return get_station_name(result.last_pos.stn)
    else
        return nil
    end
end

local function get_train_position(line_status, linevar_def, rwtime)
    if line_status ~= nil then
        local last_pos_info = get_last_pos(line_status)
        local last_pos = last_pos_info.last_pos
        if last_pos ~= nil then
            local result = "„"..get_station_name(last_pos.stn).."“"
            local delay_info = al.get_delay_description(line_status, linevar_def, rwtime)
            if last_pos_info.type ~= "standing" then
                result = result.." (před "..(rwtime - last_pos.rwtime).." sekundami)"
            end
            if delay_info.has_delay ~= nil then
                result = result.." ("..delay_info.text..")"
            end
            return result
        end
    end
    return "???"
end

--[[
local function prepare_prediction_for_dump(result)
    local x = {}
    for i, record in ipairs(result) do
        local y = table.copy(record)
        y.stdata = record.stdata.name
        if y.arr_linevar_def ~= nil then
            y.arr_linevar_def = y.arr_linevar_def.name
        end
        if y.dep_linevar_def ~= nil then
            y.dep_linevar_def = y.dep_linevar_def.name
        end
        x[i] = y
    end
    return x
end
]]

local function predict_train_continue(line, stn, rc, departure, result)
    if line == nil or line == "" then
        return
    end
    local linevar_def = al.try_get_linevar_def(line.."/"..stn.."/"..rc, stn)
    if linevar_def == nil then
        return
    end
    if #result == 0 then
        return
    end
    local stops = assert(linevar_def.stops)
    local last_record = result[#result]
    last_record.dep = departure
    last_record.dep_linevar_def = linevar_def
    last_record.dep_index = 1
    local index = 2
    while stops[index] ~= nil do
        local stop = stops[index]
        local stdata = advtrains.lines.stations[stop.stn]
        if stop.mode == MODE_FINAL or stop.mode == MODE_FINAL_CONTINUE or stop.mode == MODE_FINAL_HIDDEN then
            -- koncová zastávka
            local arr = departure + stop.dep
            local record = {
                stn = assert(stop.stn),
                track = stop.track or "",
                stdata = stdata,
                arr = arr,
                arr_linevar_def = linevar_def,
                arr_index = index,
                delay = 0,
                hidden = stop.mode == MODE_FINAL_HIDDEN,
            }
            table.insert(result, record)
            return
        elseif stop.mode ~= MODE_DISABLED then
            -- mezilehlá zastávka
            local dep = departure + stop.dep
            table.insert(result, {
                stn = assert(stop.stn),
                track = stop.track or "",
                stdata = stdata,
                arr = dep - (stop.wait or 10),
                arr_linevar_def = linevar_def,
                arr_index = index,
                dep = dep,
                dep_linevar_def = linevar_def,
                dep_index = index,
                delay = 0,
                hidden = stop.mode == MODE_HIDDEN,
            })
        end
        index = index + 1
    end
end

--[[
    Zadaný vlak musí být linkový.
    Parametry:
        line_status = table,
        linevar_def = table,
        rwtime = int,
        allow_continue = bool,
    Vrací *pole* následujících záznamů:
        {
            stn = string,
            track = string,
            delay = int,
            stdata = table or nil,
            dep = int or nil, dep_linevar_def = table or nil, dep_index = int or nil,
            arr = int or nil, arr_linevar_def = table or nil, arr_index = int or nil,
        }
]]
function al.predict_train(line_status, linevar_def, rwtime, allow_continue)
    assert(line_status)
    assert(linevar_def)
    local stops = linevar_def.stops
    local result = {}
    local index = assert(line_status.linevar_index)
    if rwtime == nil then
        rwtime = rwt.to_secs(rwt.get_time())
    end
    local delay_desc = al.get_delay_description(line_status, linevar_def, rwtime)
    local delay
    if delay_desc.has_delay then
        delay = delay_desc.delay
    else
        delay = 0
    end
    local departure = line_status.linevar_dep
    if line_status.standing_at ~= nil then
        -- vlak stojí na zastávce
        local stop = assert(stops[index])
        local stdata = advtrains.lines.stations[stop.stn]
        table.insert(result, {
            stn = line_status.linevar_last_stn,
            track = stop.track or "",
            stdata = stdata,
            dep = assert(line_status.linevar_last_dep),
            dep_linevar_def = assert(linevar_def),
            dep_index = index,
            -- arr = nil, arr_index = nil, arr_linevar_def = nil,
            delay = delay,
            hidden = stop.mode == MODE_HIDDEN
        })
    end
    index = index + 1
    while stops[index] ~= nil do
        local stop = stops[index]
        local stdata = advtrains.lines.stations[stop.stn]
        if stop.mode == MODE_FINAL or stop.mode == MODE_FINAL_CONTINUE or stop.mode == MODE_FINAL_HIDDEN then
            -- koncová zastávka
            local arr = departure + stop.dep + delay
            local record = {
                stn = assert(stop.stn),
                track = stop.track or "",
                stdata = stdata,
                arr = arr,
                arr_linevar_def = linevar_def,
                arr_index = index,
                delay = delay,
                hidden = stop.mode == MODE_FINAL_HIDDEN,
                final = true,
            }
            table.insert(result, record)
            if allow_continue and (linevar_def.continue_line or "") ~= "" and stop.mode == MODE_FINAL_CONTINUE then
                predict_train_continue(linevar_def.continue_line, stop.stn, linevar_def.continue_rc, arr + (stop.wait or 10), result)
            end
            break
        elseif stop.mode ~= MODE_DISABLED then
            -- mezilehlá zastávka
            local dep = departure + stop.dep + delay
            table.insert(result, {
                stn = assert(stop.stn),
                track = stop.track or "",
                stdata = stdata,
                arr = dep - (stop.wait or 10),
                arr_linevar_def = linevar_def,
                arr_index = index,
                dep = dep,
                dep_linevar_def = assert(linevar_def),
                dep_index = index,
                delay = delay,
                hidden = stop.mode == MODE_HIDDEN,
            })
        end
        index = index + 1
    end
    -- print("DEBUG: "..dump2({prediction = prepare_prediction_for_dump(result)}))
    return result
end

--[[
    Parametry:
        linevar_def = table, -- definice linevar, z něhož se má analýza provádět
        linevar_index = int,
        rwtime = int or nil, -- (aktuální žel. čas; nepovinné)
        trains = {train_table...} or nil, -- je-li zadáno, bude zkoumat pouze vlaky v tomto seznamu
    Vrací *pole* záznamů (stejných jako al.predict_train) vztahujících se k odjezdu
    z požadované zastávky, seřazené od nejbližšího odjezdu po nejvzdálenější.
]]
function al.predict_station_departures(linevar_def, linevar_index, rwtime, trains)
    assert(linevar_def)
    assert(linevar_index)
    local linevar = linevar_def.name
    local stop = assert(linevar_def.stops[linevar_index])
    if trains == nil then
        trains = al.get_trains_by_linevar()[linevar] or {}
    end
    if rwtime == nil then
        rwtime = rwt.to_secs(rwt.get_time())
    end
    local result = {}
    for _, train in ipairs(trains) do
        local ls, lvdef = al.get_line_status(train)
        if ls.linevar == linevar and ls.linevar_index <= linevar_index then
            local prediction = al.predict_train(ls, linevar_def, rwtime, true)
            for _, pr in ipairs(prediction) do
                if
                    pr.dep ~= nil and pr.dep_linevar_def ~= nil and pr.dep_index ~= nil and
                    pr.dep_linevar_def.name == linevar and
                    pr.dep_index == linevar_index and
                    pr.dep > rwtime
                then
                    table.insert(result, pr)
                    break
                end
            end
        end
    end
    table.sort(result, function(a, b) return a.dep < b.dep end)
    return result
end

--[[
    => {{
        linevar = string,
        indices = {int,...},
        linevar_def = linevar_def,
    }...}
]]
function al.get_linevars_by_station(stn, track, options)
    if options == nil then
        options = {}
    end
    local include_hidden_stops = options.include_hidden_stops
    local ignore_first_stop = options.ignore_first_stop
    local ignore_last_stop = options.ignore_last_stop
    local result = {}
    assert(stn)
    for lvstn, stdata in pairs(advtrains.lines.stations) do
        if stdata.linevars ~= nil then
            for linevar, linevar_def in pairs(stdata.linevars) do
                local first_stop_index = al.get_first_stop(linevar_def, include_hidden_stops)
                local last_stop_index = al.get_last_stop(linevar_def, include_hidden_stops)
                if not (ignore_first_stop or ignore_last_stop) or (first_stop_index ~= nil and last_stop_index ~= nil) then
                    for i, stop in ipairs(linevar_def.stops) do
                        if
                            stop.stn == stn and
                            (track == nil or tostring(stop.track) == track) and
                            (include_hidden_stops or is_visible_mode(stop.mode)) and
                            ((not ignore_first_stop) or i ~= 1) and
                            ((not ignore_last_stop) or (not is_final_mode(stop.mode)))
                        then
                            if ld == nil then
                                ld = {linevar = linevar, linevar_def = linevar_def, indices = {i}}
                                table.insert(result, ld)
                            else
                                table.insert(ld.indices, i)
                            end
                        end
                    end
                end
            end
        end
    end
    if #result > 1 then
        table.sort(result, function(a, b) return a.linevar < b.linevar end)
    end
    return result
end

--[[
    => {
        [linevar] = {train...}, -- generuje jen neprázdné seznamy
    }
]]
function al.get_trains_by_linevar()
    local result = {}
    for train_id, train in pairs(advtrains.trains) do
        local ls, linevar_def = al.get_line_status(train)
        if linevar_def ~= nil then
            local linevar = linevar_def.name
            local list = result[linevar]
            if list ~= nil then
                table.insert(list, train)
            else
                list = {train}
                result[linevar] = list
            end
        end
    end
    for linevar, list in pairs(result) do
        if list[2] ~= nil then
            table.sort(list, function(a, b) return a.id < b.id end)
        end
    end
    return result
end

local function vlaky(param, past_trains_too)
    local result = {}
    if param:match("/") then
        return result -- parametr nesmí obsahovat '/'
    end
    local train_line_prefix
    if param ~= "" then
        train_line_prefix = param.."/"
    end
    local rwtime = rwt.to_secs(rwt.get_time())
    local players_per_train = {}
    local results = {}
    for player_name, train_id in pairs(advtrains.player_to_train_mapping) do
        results[train_id] = (results[train_id] or 0) + 1
    end
    for train_id, train in pairs(advtrains.trains) do
        local ls, linevar_def = al.get_line_status(train)
        if linevar_def ~= nil then
            if train_line_prefix == nil or train_line_prefix == ls.linevar:sub(1, #train_line_prefix) then
                local direction_index, direction_stop = al.get_terminus(linevar_def, ls.linevar_index, false)
                local direction = "???"
                if direction_index ~= nil then
                    direction = get_station_name(direction_stop.stn)
                end
                local s = "("..train_id..") ["..linevar_def.line.."] směr „"..direction.."“, poloha: "..
                    get_train_position(ls, linevar_def, rwtime)
                if results[train_id] ~= nil then
                    s = s.." ["..results[train_id].." cestující/ch]"
                end
                table.insert(results, {key = linevar_def.name.."/"..ls.linevar_index, value = s})
            end
        elseif past_trains_too and ls.linevar_past ~= nil and (train_line_prefix == nil or ls.linevar_past.line == param) then
            local age = rwtime - ls.linevar_past.arrival
            local s = "("..train_id..") ["..ls.linevar_past.line.."] služební, poloha: "..
                get_station_name(ls.linevar_past.station).." (před "..age.." sekundami)"
            if results[train_id] ~= nil then
                s = s.." ["..results[train_id].." cestující/ch]"
            end
            table.insert(results, {
                key = string.format("%s/~/%s/%05d", ls.linevar_past.line, ls.linevar_past.station, age),
                value = s,
            })
        end
    end
    table.sort(results, function(a, b) return a.key < b.key end)
    for i, v in ipairs(results) do
        result[i] = v.value
    end
    return result
end

-- příkaz /vlaky
local def = {
    params = "[linka]",
    description = "Vypíše všechny linkové vlaky na zadané lince (resp. na všech linkách)",
    privs = {},
    func = function(player_name, param)
        local result = vlaky(param, false)
        if #result == 0 then
            return false, "Nenalezen žádný odpovídající vlak."
        end
        return true, "Nalezeno "..#result.." vlaků:\n- "..table.concat(result, "\n- ")
    end,
}
core.register_chatcommand("vlaky", def)
def = {
    params = "[linka]",
    description = "Vypíše všechny linkové vlaky na zadané lince (resp. na všech linkách) a ty, které nedávno jízdu na lince ukončily",
    privs = {ch_registered_player = true},
    func = function(player_name, param)
        local result = vlaky(param, true)
        if #result == 0 then
            return false, "Nenalezen žádný odpovídající vlak."
        end
        return true, "Nalezeno "..#result.." vlaků:\n- "..table.concat(result, "\n- ")
    end,
}
core.register_chatcommand("vlaky+", def)

def = {
    -- params = "",
    description = "(pro ladění)",
    privs = {server = true},
    func = function(player_name, param)
        local train = advtrains.trains[param]
        if train == nil then
            return false, "Vlak "..param.." nenalezen!"
        end
        local line_status, linevar_def = al.get_line_status(train)
        if linevar_def == nil then
            return false, "Vlak "..param.." není linkový!"
        end
        -- function al.predict_train(line_status, linevar_def, rwtime, allow_continue)
        local rwtime = rwt.to_secs(rwt.get_time())
        local predictions = al.predict_train(line_status, linevar_def, rwtime, true)
        local result = {"----"}
        local s
        for i, record in ipairs(predictions) do
            local arr, dep
            if record.arr ~= nil then
                arr = "("..(record.arr - rwtime)..", lv="..record.arr_linevar_def.name..", i="..record.arr_index..")"
            else
                arr = "nil"
            end
            if record.dep ~= nil then
                dep  = "("..(record.dep - rwtime)..", lv="..record.dep_linevar_def.name..", i="..record.dep_index..")"
            else
                dep = "nil"
            end
            result[i + 1] = "- "..record.stn.." ["..record.track.."] arr="..arr.." dep="..dep.." delay="..record.delay
        end
        table.insert(result, "----")
        s = table.concat(result, "\n")
        print(s)
        core.chat_send_player(player_name, s)
        return true
    end,
}
core.register_chatcommand("jřád", def)
core.register_chatcommand("jrad", def)
