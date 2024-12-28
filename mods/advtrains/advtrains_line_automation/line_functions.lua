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
    [train_id] = {[1] = rwtime, ..., [n] = rwtime (časy *odjezdu*, kromě koncových zastávek, kde jde o čas příjezdu)}
]]}

local last_passages = {--[[
    [linevar] = {
        [1..10] = {[1] = rwtime, ...} -- jízdy seřazeny od nejstarší (1) po nejnovější (až 10) podle odjezdu z výchozí zastávky
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
    core.chat_send_all("["..debug_print_i.."] "..tostring(s))
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
        -- print("DEBUG: line_start() failed for "..(train.line or "").."/"..stn.."/"..(train.routingcode or ""))
        return false
    end
    ls.linevar = linevar
    ls.linevar_station = stn
    ls.linevar_index = 1
    ls.linevar_dep = departure_rwtime
    ls.linevar_last_dep = departure_rwtime
    ls.linevar_last_stn = stn
    train.text_outside = al.get_line_description(linevar_def, {
        line_number = true,
        last_stop = true,
        last_stop_prefix = "",
        last_stop_uppercase = true,
        train_name = true,
    })
    -- print("DEBUG: line_start(): "..dump2({train_id = train.id, line_status = ls}))
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
        -- print("DEBUG: should_stop() == false, because stdata is invalid!")
        return nil -- neplatná data
    end
	local n_trainparts = #assert(train.trainparts)
    -- vyhovuje počet vagonů?
    if not ((stdata.minparts or 0) <= n_trainparts and n_trainparts <= (stdata.maxparts or 128)) then
        -- print("DEBUG: should_stop("..stdata.stn..") == false, because n_trainparts is not in interval")
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
            -- print("DEBUG: should_stop("..stn..") == false, because linevar=='"..ls.linevar.."' and next_index == nil")
            return nil
        end
        local stop = assert(linevar_def.stops[next_index])
        if stop.pos ~= nil and stop.pos ~= string.format("%d,%d,%d", pos.x, pos.y, pos.z) then
            -- print("DEBUG: should_stop("..stn..") == false, because the stop is limited to position "..stop.pos)
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
        -- print("DEBUG: should_stop("..stn..") == true for "..linevar_def.name)
        return "true"
        -- local result = next_index ~= nil -- zastávka má index => zastavit
        --[[
        if result then
            print("DEBUG: should_stop() == true, because linevar=='"..ls.linevar.."' and get_line_status() retuned next_index == "..next_index)
        else
            print("DEBUG: should_stop() == false, because linevar=='"..ls.linevar.."' and get_line_status() retuned next_index == nil")
        end
        ]]
        -- return result
        -- TODO: zastávky na znamení
    else
        local ars = stdata.ars
        -- vyhovuje vlak ARS pravidlům?
        local result = ars and (ars.default or advtrains.interlocking.ars_check_rule_match(ars, train))
        if result then
            return "true"
            -- print("DEBUG: should_stop("..stn..") == true, because linevar==nil and ARS rules match")
        else
            return nil
            -- print("DEBUG: should_stop("..stn..") == false, because linevar==nil and ARS rules don't match")
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
    -- print("DEBUG: line_end(train_id = "..train.id..", linevar was: "..ls.linevar.."): "..dump2({line_status_old = ls}))
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
    a) index, stop_data -- pokud byla vyhovující další zastávka nalezena
    b) nil, nil -- pokud nalezena nebyla
]]
function al.get_next_stop(linevar_def, current_index, allow_hidden_stops)
    local stops = assert(linevar_def.stops)
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
    local stops = assert(linevar_def.stops)
    if current_index < #stops then
        for i = current_index + 1, #stops do
            local mode = stops[i].mode
            if mode ~= nil and (mode == MODE_FINAL or mode == MODE_FINAL_CONTINUE or (mode == MODE_FINAL_HIDDEN and allow_hidden_stops)) then
                return i, stops[i]
            end
        end
    end
    return nil, nil
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
    if line == nil then
        return "???"
    end
    if options == nil then options = {} end
    local s1, s2, s3, s4
    if options.line_number then
        s1 = "["..line.."] "
    else
        s1 = ""
    end
    if options.first_stop then
        s2 = get_station_name(stn).." "
    else
        s2 = ""
    end
    if options.last_stop == nil or options.last_stop then
        s3 = "???"
        local terminus_index, terminus_data = al.get_terminus(linevar_def, 1, false)
        if terminus_index ~= nil then
            s3 = get_station_name(terminus_data.stn)
            if options.last_stop_uppercase then
                s3 = na_velka_pismena(s3)
            end
        end
        s3 = (options.last_stop_prefix or "⇒ ")..s3
    else
        s3 = ""
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
        local mode = stop_data.mode or MODE_NORMAL
        if mode ~= MODE_DISABLED and mode ~= MODE_HIDDEN and mode ~= MODE_FINAL_HIDDEN then
            s1 = get_station_name(stop_data.stn)
            if mode == MODE_FINAL or mode == MODE_FINAL_CONTINUE then
                s2 = "Koncová zastávka"
            end
        end
    end
    if next_stop_data ~= nil then
        local mode = next_stop_data.mode or MODE_NORMAL
        if mode ~= MODE_DISABLED and mode ~= MODE_HIDDEN and mode ~= MODE_FINAL_HIDDEN then
            s2 = "Příští zastávka/stanice: "..get_station_name(next_stop_data.stn)
            if mode == MODE_REQUEST_STOP then
                s2 = s2.." (na znamení)"
            end
        end
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
function al.get_delay_description(line_status, linevar_def)
    assert(line_status)
    if linevar_def == nil then
        return {text = ""}
    end
    local expected_departure = line_status.linevar_dep + assert(linevar_def.stops[line_status.linevar_index]).dep
    local real_departure = line_status.linevar_last_dep
    local delay = real_departure - expected_departure
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

-- Pokud zadaná varianta linky existuje, vrátí:
--      linevar_def, linevar_station
-- Jinak vrací:
--      nil, nil
-- Je-li linevar_station == nil, doplní se z linevar. Je-li linevar == nil, vrátí nil, nil.
function al.try_get_linevar_def(linevar, linevar_station)
    if linevar == nil then
        -- print("DEBUG: try_get_linevar_def() => nil, because linevar == nil")
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
        -- else
            -- print("DEBUG: no linevars for linevar_station '"..linevar_station.."'")
        end
    -- else
        -- print("DEBUG: no data for linevar_station '"..linevar_station.."'")
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
            -- print("DEBUG: linevar combination found: "..dump2({linevar = linevar, line = line, stn = stn, rc = rc or "", linevar_def = result}))
            return linevar, result
        end
    end
    -- print("DEBUG: linevar combination not found for "..(line or "").."/"..(stn or "").."/"..(rc or ""))
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
        -- print("DEBUG: new empty line_status created for train "..train.id)
        return train.line_status, nil
    end
    local ls = train.line_status
    if ls.linevar == nil then
        -- nelinkový vlak
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
        else
            -- [DEBUG:] TEMPORARY:
            if linevar_def.line == nil then
                linevar_def.line = assert(train.line)
            end
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
        -- print("DEBUG: on_train_approach(): will stop at station '"..stdata.stn.."'")
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
            core.log("action", "[INFO] The train "..train_id.." will wait for "..(next_dep - normal_dep).." additional seconds due to interval at "..core.pos_to_string(pos)..".")
            wait = wait + (next_dep - normal_dep)
        -- else -- will wait normal time
        end
    end
    local planned_departure = rwtime + wait
    debug_print("Vlak "..train_id.." zastavil na "..stn.." a odjede za "..wait.." sekund ("..planned_departure..").")
    -- print("DEBUG: planned departure: "..planned_departure.." = "..rwtime.." + "..wait)
    stdata.last_dep = planned_departure -- naplánovaný čas odjezdu
    ls.standing_at = pe
    if linevar_def == nil or next_index == nil or (linevar_def.stops[next_index].mode or MODE_NORMAL) ~= MODE_HIDDEN then
        -- zrušit stop_request, pokud jsme nezastavili na skryté zastávce:
        ls.stop_request = nil
    end
    -- print("DEBUG: standing ls = "..dump2(ls))

    local can_start_line
    local had_linevar = linevar_def ~= nil
    if linevar_def == nil then
        -- nelinkový vlak
        can_start_line = true
        -- print("DEBUG: train "..train_id.." is non-line train, can start a new line")
    elseif next_index ~= nil then
        -- linkový vlak zastavil na své řádné zastávce
        assert(stn ~= "") -- dopravna musí mít kód
        local stop_def = assert(linevar_def.stops[next_index])
        debug_print("Vlak "..train_id.." je linkový vlak ("..ls.linevar..") a zastavil na své pravidelné zastávce "..stn.." (index = "..next_index..")")
        -- print("DEBUG: train "..train_id.." stopped at regular stop '"..stn.."': "..dump2({stop_def = stop_def}))
        record_skipped_stops(train_id, linevar_def, ls.linevar_index, next_index)
        local stop_smode = simple_modes[stop_def.mode or 0]
        if stop_smode == MODE_NORMAL then
            -- mezilehlá zastávka
            can_start_line = false
            ls.linevar_index = next_index
            ls.linevar_last_dep = planned_departure
            ls.linevar_last_stn = stn
            -- print("DEBUG: "..dump2({line_status = ls}))
            debug_print("Jde o mezilehlou zastávku.")
            local next_stop_index, next_stop_data = al.get_next_stop(linevar_def, next_index)
            train.text_inside = al.get_stop_description(linevar_def.stops[next_index], linevar_def.stops[next_stop_index or 0])
        else
            -- koncová zastávka
            can_start_line = stop_def.mode == MODE_FINAL_CONTINUE
            debug_print("Vlak "..train_id.." skončil jízdu na lince "..ls.linevar..", může pokračovat na jinou linku: "..(can_start_line and "ihned" or "na příští zastávce"))
            train.text_inside = al.get_stop_description(linevar_def.stops[next_index])
            local current_passage = current_passages[train_id]
            if current_passage ~= nil then
                current_passage[next_index] = rwtime
                current_passages[train_id] = nil
            end
            al.cancel_linevar(train)
        end
    else
        -- linkový vlak zastavil na neznámé zastávce (nemělo by nastat)
        core.log("warning", "Train "..train_id.." of linevar '"..ls.linevar.."' stopped at unknown station '"..stn.."' at "..core.pos_to_string(pos).."!")
        debug_print("Vlak "..train_id.." je linkový vlak ("..ls.linevar.."), ale zastavil na sobě neznámé zastávce "..stn..", což by se nemělo stát.")
        can_start_line = false
    end
    -- print("DEBUG: "..dump2({can_start_line = can_start_line}))

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
    if can_start_line and line_start(train, stn, planned_departure) then
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
    -- print("DEBUG: the train will wait for "..wait.." seconds")
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

    -- print("DEBUG: *on_train_leave("..train_id..") from "..(stdata and stdata.stn or "nil"))
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
            -- print("DEBUG: on_train_leave from non-anonymous stop")
            debug_print("Vlak "..train_id.." odjel ze zastávky "..stn)
            if ls.linevar_last_dep ~= nil and ls.linevar_last_dep > rwtime then
                debug_print("Vlak "..train_id.." předčasně odjel z dopravny "..stn.." (zbývalo "..(ls.linevar_last_dep - rwtime).." sekund)")
                ls.linevar_last_dep = rwtime -- předčasný odjezd
                if ls.linevar_index == 1 then
                    ls.linevar_dep = rwtime
                end
            end
        else
            -- print("DEBUG: on_train_leave from anonymous stop")
            debug_print("Vlak "..train_id.." odjel z anonymní zastávky "..core.pos_to_string(pos)..".")
        end
        train.text_inside = ""
        if linevar_def ~= nil then
            -- linkový vlak:
            debug_print("Linkový vlak "..train_id.." odjel ze zastávky s indexem "..ls.linevar_index)
            if ls.linevar_index == 1 then
                -- odjezd z výchozí zastávky:
                local new_passage = {rwtime}
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
            debug_print("DEBUG: Vlak "..train_id.." projel (odjezd) zastávkou "..stn..".")
        else
            debug_print("DEBUG: Vlak "..train_id.." projel (odjezd) anonymní zastávkou "..core.pos_to_string(pos)..".")
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
        {{[1] = rwtime, ...}...}, {"kód", "název"}...}
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

--[[ DEBUG:
local debug_print = {}
function debug_print.print()
    print(".")
    core.after(1, debug_print.print)
end
debug_print.print()
]]

--[[
function al.rwt_to_cas()
    return
end
]]

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

local function get_train_position(line_status, linevar_def, rwtime)
    if line_status ~= nil then
        local last_pos_info = get_last_pos(line_status)
        print("DEBUG: last_pos_info = "..dump2({last_pos_info}))
        local last_pos = last_pos_info.last_pos
        if last_pos ~= nil then
            local result = "„"..get_station_name(last_pos.stn).."“"
            local delay_info = al.get_delay_description(line_status, linevar_def)
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

-- příkaz /vlaky
local def = {
    params = "[linka]",
    description = "Vypíše všechny linkové vlaky na zadané lince (resp. na všech linkách)",
    privs = {},
    func = function(player_name, param)
        local result = {}
        if not param:match("/") then
            local rwtime = rwt.to_secs(rwt.get_time())
            for train_id, train in pairs(advtrains.trains) do
                local ls, linevar_def = al.get_line_status(train)
                if linevar_def ~= nil and (param == "" or ls.linevar:sub(1, #param + 1) == param.."/") then
                    local direction_index, direction_stop = al.get_terminus(linevar_def, ls.linevar_index, false)
                    local direction = "???"
                    if direction_index ~= nil then
                        direction = get_station_name(direction_stop.stn)
                    end
                    local s = "("..train_id..") ["..linevar_def.line.."] směr „"..direction.."“, poloha: "..get_train_position(ls, linevar_def, rwtime)
                    table.insert(result, s)
                end
            end
        end
        if #result == 0 then
            return false, "Nenalezen žádný odpovídající vlak."
        end
        return true, "Nalezeno "..#result.." vlaků:\n- "..table.concat(result, "\n- ")
    end,
}
core.register_chatcommand("vlaky", def)


-- DEBUG:
def = {
    -- params = "",
    description = "(pro ladění)",
    privs = {server = true},
    func = function(player_name, param)
        print("----")
        for linevar, passages in pairs(last_passages) do
            print("LINEVAR "..linevar..":")
            local linevar_def = al.try_get_linevar_def(linevar)
            if linevar_def ~= nil then
                local stops = linevar_def.stops
                for i, passage in ipairs(passages) do
                    print("  Passage #"..i..":")
                    for j, stop in ipairs(stops) do
                        local s
                        if passage[j] ~= nil then
                            s = tostring(passage[j])
                        else
                            s = "-"
                        end
                        print("  - "..stop.stn.." = "..s.." ["..j.."]")
                    end
                end
            else
                print("ERROR! definition not found")
            end
        end
        print("----")
        return true
    end,
}
core.register_chatcommand("odjezdy", def)
