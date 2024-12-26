local def
local F = minetest.formspec_escape
local ifthenelse = ch_core.ifthenelse

local max_stations = 60

local MODE_NORMAL = 0 -- normální zastávka (výchozí nebo mezilehlá)
local MODE_REQUEST_STOP = 1 -- zastávka na znamení (mezilehlá)
local MODE_HIDDEN = 2 -- skrytá zastávka (výchozí nebo mezilehlá)
local MODE_DISABLED = 3 -- vypnutá zastávka (mezilehlá nebo koncová)
local MODE_FINAL = 4 -- koncová zastávka (linka zde jízdu končí)
local MODE_FINAL_HIDDEN = 5 -- koncová zastávka skrytá
local MODE_FINAL_CONTINUE = 6 -- koncová zastávka (vlak pokračuje jako jiná linka)

local color_red = core.get_color_escape_sequence("#ff0000")
local color_green = core.get_color_escape_sequence("#00ff00")

local cancel_linevar = assert(advtrains.lines.cancel_linevar)
local get_last_passages = assert(advtrains.lines.get_last_passages)
local get_line_description = assert(advtrains.lines.get_line_description)
local linevar_decompose = assert(advtrains.lines.linevar_decompose)
local try_get_linevar_def = assert(advtrains.lines.try_get_linevar_def)

local show_last_passages_formspec -- forward declaration

local function check_rights(pinfo, owner)
    if pinfo.role == "new" or pinfo.role == "none" then
        return false
    end
    if owner == nil or pinfo.role == "admin" or pinfo.player_name == owner then
        return true
    end
    return false
end

local function get_stn_from_linevar(linevar)
    local line, stn = linevar_decompose(linevar)
    return ifthenelse(line ~= nil, stn, nil)
end

local function add_linevar(stn, linevar_def)
    local station = advtrains.lines.stations[stn]
    if station == nil then
        return false, "Chybná stanice!"
    end
    local linevars = station.linevars
    if linevars == nil then
        linevars = {}
        station.linevars = linevars
    end
    if linevars[linevar_def.name] ~= nil then
        return false, "Nemohu přidat, varianta linky '"..linevar_def.name.."' již existuje."
    end
    linevars[linevar_def.name] = linevar_def
    return true, nil
end

local function replace_linevar(stn, linevar_def)
    local station = advtrains.lines.stations[stn]
    if station == nil or station.linevars == nil then
        return false, "Chybná stanice!"
    end
    local linevar = assert(linevar_def.name)
    local linevars = station.linevars
    if linevars[linevar] == nil then
        return false, "Nemohu nahradit, varianta linky '"..linevar.."' dosud neexistuje!"
    end
    linevars[linevar] = linevar_def
    for train_id, train in pairs(advtrains.trains) do
        local ls = train.line_status
        if ls ~= nil and ls.linevar == linevar then
            core.log("action", "Train "..train_id.." restarted from index "..ls.linevar_index.." due to replacement of linevar '"..linevar.."'.")
            ls.linevar_index = 1
        end
    end
    return true, nil
end

local function delete_linevar(stn, linevar)
    local station = advtrains.lines.stations[stn]
    if station == nil or station.linevars == nil then
        return false, "Chybná stanice!"
    end
    local linevars = station.linevars
    if linevars[assert(linevar)] == nil then
        return false, "Nemohu odstranit, varianta linky '"..linevar.."' nebyla nalezena!"
    end
    linevars[linevar] = nil
    for train_id, train in pairs(advtrains.trains) do
        local ls = train.line_status
        if ls ~= nil and ls.linevar == linevar then
            core.log("action", "Train "..train_id.." removed from deleted linevar '"..linevar.."'.")
            cancel_linevar(train)
        end
    end
    return true, nil
end

local function get_formspec(custom_state)
	local pinfo = ch_core.normalize_player(assert(custom_state.player_name))
	if pinfo.player == nil then
		minetest.log("error", "Expected player not in game!")
		return ""
	end

    local selection_index_raw = custom_state.selection_index
	local selection_index = selection_index_raw or 1
    local formspec = {
        ch_core.formspec_header({formspec_version = 6, size = {20, 16}, auto_background = true}),
        "label[0.5,0.6;Editor variant linek]"..
        "style[s01_pos",
    }
    for i = 2, max_stations do
        table.insert(formspec, string.format(",s%02d_pos", i))
    end
    table.insert(formspec, ";font=mono;font_size=-4]"..
        "style[rc;font=mono]"..
        "tablecolumns[color;text,align=right;text;text,align=center;color;text,width=7;color;text]"..
        "table[0.5,1.25;19,5;linevar;#ffffff,LINKA,TRASA,SM. KÓD,#ffffff,SPRAVUJE,#ffffff,STAV")

    for _, linevar_def in ipairs(custom_state.linevars) do
        local lv_line, lv_stn, lv_rc = linevar_decompose(linevar_def.name)
        local color = ifthenelse(linevar_def.disabled, "#cccccc", "#ffffff")
        table.insert(formspec,
            ","..color..","..F(lv_line)..","..F(get_line_description(linevar_def, {first_stop = true, last_stop = true}))..
            ","..F(lv_rc)..","..ifthenelse(linevar_def.owner == pinfo.player_name, "#00ff00", color)..",")
        table.insert(formspec, F(ch_core.prihlasovaci_na_zobrazovaci(linevar_def.owner)))
        table.insert(formspec, ","..color..",")
        if linevar_def.disabled then
            table.insert(formspec, "vypnutá")
        end
    end
    if selection_index_raw ~= nil then
        table.insert(formspec, ";"..selection_index.."]")
    else
        table.insert(formspec, ";]")
    end
    if pinfo.role ~= "new" then
        table.insert(formspec, "button[14.5,0.3;3.5,0.75;create;nová varianta...]")
    end
    local has_rights_to_open_variant =
        pinfo.role == "admin" or selection_index == 1 or
        pinfo.player_name == custom_state.linevars[selection_index - 1].owner

    if has_rights_to_open_variant then
        table.insert(formspec, "button[10.5,0.3;3.5,0.75;delete;smazat variantu]")
    end
    table.insert(formspec, "button_exit[18.75,0.3;0.75,0.75;close;X]"..
        "field[0.5,7;1.25,0.75;line;linka:;"..F(custom_state.line).."]"..
        "field[2,7;1.5,0.75;rc;sm.kód:;"..F(custom_state.rc).."]"..
        "field[3.75,7;3,0.75;train_name;jméno vlaku:;"..F(custom_state.train_name).."]")
    if pinfo.role ~= "admin" then
        table.insert(formspec, "label[7,6.75;spravuje:\n")
    else
        table.insert(formspec, "field[7,7;4,0.75;owner;spravuje:;")
    end
    table.insert(formspec, F(custom_state.owner).."]"..
        "checkbox[11.25,7.25;disable_linevar;vypnout;"..custom_state.disable_linevar.."]")

    if pinfo.role ~= "new" then
        if has_rights_to_open_variant then
            if selection_index > 1 then
                table.insert(formspec, "button[5,15;4.5,0.75;last_passages;posledních 10 jízd...]"..
                "tooltip[last_passages;Zobrazí přehled časů posledních 10 jízd na dané variantě linky.]")
            end
            table.insert(formspec, "button[10,15;4.5,0.75;save;"..
                ifthenelse(custom_state.compiled_linevar == nil, "ověřit změny\npřed uložením]", "uložit změny]"))
        end
        table.insert(formspec, "button[15,15.25;4,0.5;reset;vrátit změny]")
    end

    table.insert(formspec, "tooltip[line;"..
        "Označení linky. Musí být neprázdné. Varianta linky bude použita pouze na vlaky s tímto označením linky.]"..
        "tooltip[rc;Směrový kód. Může být prázdný. Varianta linky bude použita pouze na vlaky\\,\n"..
        "jejichž směrový kód se přesně shoduje se zadaným. Obvykle se toto pole nechává prázdné.]"..
        "tooltip[train_name;Volitelný údaj. Je-li zadán\\, jízdní řády budou uvádět u spojů této\n"..
        "varianty zadané jméno.]"..
        "tooltip[disable_linevar;Zaškrtnutím variantu linky vypnete. Vypnutá varianta linky není používána\n"..
        "na žádné další vlaky\\, stávající vlaky však mohou dojet do svých koncových zastávek.]")

    table.insert(formspec, "container[0,8.75]"..
        "label[0.5,0.25;odjezd]"..
        "label[2,0.25;kód dop.]"..
        "label[4.75,0.25;režim zastávky]"..
        "label[9.5,0.25;kolej]"..
        "label[11,0.25;omezení pozice]"..
        "scrollbaroptions[min=0;max=550;arrows=show]"..
        "scrollbar[19,0.5;0.5,5.5;vertical;evl_scroll;"..custom_state.evl_scroll.."]"..
        "scroll_container[0.5,0.5;18.5,5.5;evl_scroll;vertical]"..
        "box[0,0;20,70;#00808040]") -- box[] = pozadí

    -- výchozí zastávka:
    table.insert(formspec,
        "label[0.1,0.4;0]"..
        "field[1.5,0;2.5,0.75;s01_stn;;"..F(custom_state.stops[1].stn).."]"..
        "dropdown[4.25,0;4.5,0.75;s01_mode;výchozí,skrytá (výchozí);"..custom_state.stops[1].mode..";true]"..
        "field[9,0;1.25,0.75;s01_track;;"..F(custom_state.stops[1].track).."]"..
        "field[10.5,0;3,0.75;s01_pos;;"..F(custom_state.stops[1].pos).."]"..
        "label[13.75,0.4;"..F(custom_state.stops[1].label).."]")

    -- ostatní zastávky:
    local y_base, y_scale = 0, 1
    for i = 2, max_stations do
        local stop = custom_state.stops[i]
        local n
        if i < 10 then
            n = "0"..i
        else
            n = tostring(i)
        end
        local y = string.format("%f", y_base + (i - 1) * y_scale)
        local y2 = string.format("%f", y_base + (i - 1) * y_scale + 0.4) -- for a label
        table.insert(formspec,
            "field[0,"..y..";1.25,0.75;s"..n.."_dep;;"..F(stop.dep).."]"..
            "field[1.5,"..y..";2.5,0.75;s"..n.."_stn;;"..F(stop.stn).."]"..
            "dropdown[4.25,"..y..";4.5,0.75;s"..n.."_mode;normální,na znamení,skrytá (mezilehlá),vypnutá,koncová,koncová skrytá,"..
            "koncová (pokračuje);"..stop.mode..";true]"..
            "field[9,"..y..";1.25,0.75;s"..n.."_track;;"..F(stop.track).."]"..
            "field[10.5,"..y..";3,0.75;s"..n.."_pos;;"..F(stop.pos).."]"..
            "label[13.75,"..y2..";"..F(stop.label).."]")
    end

    table.insert(formspec,
        "scroll_container_end[]"..
        "tooltip[0,0;2,1;Odjezd: očekávaná jízdní doba v sekundách od odjezdu z výchozí zastávky\n"..
        "do odjezdu z dané zastávky. Podle ní se počítá zpoždění. Hodnota musí být jedinečná\n"..
        "pro každou zastávku na lince a podle ní se zastávky seřadí.\n"..
        "Pro úplné smazání dopravny z linky nechte pole prázdné.]"..
        "tooltip[2,0;2.75,1;Kód dopravny: kód dopravny\\, kde má vlak zastavit. Vlak bude ignorovat\n"..
        "ARS pravidla a zastaví na první zastávkové koleji v dopravně pro odpovídající počet vagonů.\n"..
        "Kód dopravny se na lince může opakovat.]"..
        "tooltip[4.75,0;4.75,1;Režim zastávky: výchozí/normální - vždy zastaví\\;\n"..
        "na znamení: zastaví na znamení (zatím neimplementováno)\\;\n"..
        "skrytá – vždy zastaví\\, ale nezobrazí se v jízdních řádech\\;\n"..
        "vypnutá – nezastaví (použijte při výlukách nebo při zrušení zastávky)\\;\n"..
        "koncová – vždy zastaví a tím ukončí spoj\\, vlak se stane nelinkovým\\;\n"..
        "koncová (pokračuje) – jako koncová\\, ale vlak se může na odjezdu opět stát linkovým.]"..
        "tooltip[9.5,0;1.5,1;Kolej: nepovinný\\, orientační údaj do jízdních řádů – na které koleji\n"..
        "vlaky obvykle zastavují. Nepovinný údaj.]"..
        "tooltip[10.5,0;3.5,1;Omezení pozice: Zadávejte jen v případě potřeby.\n"..
        "Je-li zadáno\\, vlak v dané dopravně nezastaví na žádné jiné zastávkové koleji\n"..
        "než na té\\, která leží přesně na zadané pozici. Příklad platné hodnoty:\n123,7,-13]"..
        "container_end[]")

	-- if pinfo.role ~= "new" then
	return table.concat(formspec)
end

local mode_from_formspec_map = {MODE_NORMAL, MODE_REQUEST_STOP, MODE_HIDDEN, MODE_DISABLED, MODE_FINAL, MODE_FINAL_HIDDEN, MODE_FINAL_CONTINUE}
local mode_to_formspec_map = table.key_value_swap(mode_from_formspec_map)

local function mode_to_formspec(i, raw_mode)
    if i == 1 then
        return ifthenelse(raw_mode ~= nil and raw_mode == MODE_HIDDEN, 2, 1)
    elseif raw_mode == nil then
        return 1
    else
        return mode_to_formspec_map[raw_mode] or 1
    end
end

local function mode_from_formspec(i, fs_mode)
    if i == 1 then
        return ifthenelse(fs_mode == 2, MODE_HIDDEN, nil)
    else
        local result = mode_from_formspec_map[fs_mode]
        return ifthenelse(result ~= nil and result ~= MODE_NORMAL, result, nil)
    end
end

local function custom_state_set_selection_index(custom_state, new_selection_index)
    -- this will also refresh stops and resets the changes
    assert(custom_state.player_name)
    assert(custom_state.linevars)
    assert(new_selection_index)
    local current_linevar = custom_state.linevars[new_selection_index - 1]
    custom_state.selection_index = new_selection_index or 1
    local stops = custom_state.stops
    if stops == nil then
        stops = {}
        custom_state.stops = stops
    end
    local linevar_stops
    if current_linevar ~= nil then
        linevar_stops = current_linevar.stops
    else
        linevar_stops = {}
    end

    for i = 1, max_stations do
        local stop = linevar_stops[i]
        if stop ~= nil then
            stops[i] = {
                dep = tostring(assert(stop.dep)),
                stn = assert(stop.stn),
                mode = mode_to_formspec(i, stop.mode),
                track = stop.track or "",
                pos = stop.pos or "",
                label = "",
            }
        else
            stops[i] = {
                dep = ifthenelse(i == 1, "0", ""),
                stn = "",
                mode = 1,
                track = "",
                pos = "",
                label = "",
            }
        end
    end
    if current_linevar ~= nil then
        local lv_line, lv_stn, lv_rc = linevar_decompose(current_linevar.name)
        custom_state.line = lv_line or ""
        custom_state.rc = lv_rc or ""
        custom_state.train_name = current_linevar.train_name or ""
        custom_state.owner = assert(current_linevar.owner)
        custom_state.disable_linevar = ifthenelse(current_linevar.disabled, "true", "false")
    else
        custom_state.line = ""
        custom_state.rc = ""
        custom_state.train_name = ""
        custom_state.owner = custom_state.player_name
        custom_state.disable_linevar = "false"
    end
    custom_state.compiled_linevar = nil
    custom_state.evl_scroll = 0
end

local function num_transform(s)
    local prefix = s:match("^([0-9]+)/")
    if prefix == nil then
        return s
    end
    return string.format(" %020d%s", tonumber(prefix) or 0, s:sub(#prefix, -1))
end

local function linevars_sorter(a, b)
    return num_transform(a.name) < num_transform(b.name)
end

local function custom_state_refresh_linevars(custom_state, linevar_to_select)
    assert(custom_state.player_name)
    local linevars = {}
    for _, stdata in pairs(advtrains.lines.stations) do
        if stdata.linevars ~= nil then
            for _, linevar_def in pairs(stdata.linevars) do
                table.insert(linevars, linevar_def)
            end
        end
    end
    table.sort(linevars, linevars_sorter)
    custom_state.selection_index = nil
    custom_state.linevars = linevars
    custom_state.compiled_linevar = nil
    if linevar_to_select ~= nil then
        for i, linevar_def in ipairs(linevars) do
            if linevar_def.name == linevar_to_select then
                custom_state_set_selection_index(custom_state, i + 1)
                return true
            end
        end
        return false
    end
end

local function custom_state_compile_linevar(custom_state)
    local stations = advtrains.lines.stations
    local line = assert(custom_state.line)
    local stn = assert(custom_state.stops[1].stn)
    local rc = assert(custom_state.rc)
    local train_name = assert(custom_state.train_name)
    local owner = assert(custom_state.owner)
    local stops = {}
    if line == "" then
        return false, "Označení linky nesmí být prázdné!"
    elseif line:find("[/|\\]") then
        return false, "Označení linky nesmí obsahovat znaky '/', '|' a '\\'!"
    elseif line:len() > 256 then
        return false, "Označení linky je příliš dlouhé!"
    elseif stn == "" then
        return false, "Výchozí zastávka musí být vyplněná!"
    elseif rc:find("[/|\\]") then
        return false, "Směrový kód nesmí obsahovat znaky '/', '|' a '\\'!"
    elseif owner == "" then
        return false, "Správa linky musí být vyplněná!"
    elseif train_name:len() > 256 then
        return false, "Jméno vlaku je příliš dlouhé!"
    end
    -- Zkontrolovat zastávky:
    local errcount = 0
    local finalcount = 0
    local dep_to_index = {}
    for i, stop in ipairs(assert(custom_state.stops)) do
        local good_label
        stop.label = ""
        if stop.dep == "" then
            -- přeskočit
        elseif not stop.dep:match("^[0-9][0-9]*$") then
            errcount = errcount + 1
            stop.label = color_red.."Chybný formát času odjezdu!"
        elseif tonumber(stop.dep) < 0 or tonumber(stop.dep) > 3600 then
            errcount = errcount + 1
            stop.label = color_red.."Čas odjezdu musí být v rozsahu 0 až 3600!"
        elseif dep_to_index[tonumber(stop.dep)] ~= nil then
            errcount = errcount + 1
            stop.label = color_red.."Duplicitní čas odjezdu!"
        else
            dep_to_index[tonumber(stop.dep)] = i
            if stop.stn == "" or stations[stop.stn] == nil or stations[stop.stn].name == nil then
                errcount = errcount + 1
                stop.label = color_red.."Neznámý kód dopravny!"
            elseif stop.stn:find("[/|\\]") then
                errcount = errcount + 1
                stop.label = color_red.."Kód dopravny nesmí obsahovat znaky '/', '|' a '\\'!"
            elseif stop.track:len() > 16 then
                errcount = errcount + 1
                stop.label = color_red.."Označení koleje je příliš dlouhé!"
            elseif stop.pos ~= "" and not stop.pos:match("^[-0-9][0-9]*,[-0-9][0-9]*,[-0-9][0-9]*$") then
                errcount = errcount + 1
                stop.label = color_red.."Neplatný formát pozice!"
            elseif stop.pos:len() > 22 then
                errcount = errcount + 1
                stop.label = color_red.."Specifikace pozice je příliš dlouhá!"
            else
                -- v pořádku:
                local new_stop = {
                    stn = stop.stn,
                    dep = tonumber(stop.dep),
                }
                local new_mode = mode_from_formspec(i, stop.mode)
                if new_mode ~= nil then
                    new_stop.mode = new_mode
                    if i > 1 and (new_mode == MODE_FINAL or new_mode == MODE_FINAL_CONTINUE or new_mode == MODE_FINAL_HIDDEN) then
                        finalcount = finalcount + 1
                    end
                end
                if stop.pos ~= "" then
                    new_stop.pos = stop.pos
                end
                if stop.track ~= "" then
                    new_stop.track = stop.track
                end
                table.insert(stops, new_stop)
                if stop.stn ~= "" then
                    stop.label = color_green.."= "..assert(stations[stop.stn].name)
                end
            end
        end
    end
    if errcount > 0 then
        return false, errcount.." chyb v seznamu zastávek!"
    end
    if finalcount == 0 then
        return false, "Varianta linky musí obsahovat alespoň jednu koncovou zastávku!"
    end
    table.sort(stops, function(a, b) return a.dep < b.dep end)
    custom_state.compiled_linevar = {
        name = line.."/"..stops[1].stn.."/"..rc,
        line = line,
        owner = owner,
        stops = stops,
    }
    if train_name ~= "" then
        custom_state.compiled_linevar.train_name = train_name
    end
    if custom_state.disable_linevar == "true" then
        custom_state.compiled_linevar.disabled = true
    end
    return true, nil
end

local function formspec_callback(custom_state, player, formname, fields)
    local reload_stations, update_formspec = false, false
    -- print("DEBUG: "..dump2({custom_state = custom_state, formname = formname, fields = fields}))

	if fields.quit then
		return
	end
    -- scrollbar:
    if fields.evl_scroll then
        local event = core.explode_scrollbar_event(fields.evl_scroll)
        if event.type == "CHG" then
            custom_state.evl_scroll = event.value
        end
    end
    -- checkbox:
    if fields.disable_linevar then
        custom_state.disable_linevar = fields.disable_linevar
    end
    -- dropdowns:
    for i = 1, max_stations do
        local id = string.format("s%02d_mode", i)
        local n = tonumber(fields[id])
        if n ~= nil then
            custom_state.stops[i].mode = n
        end
    end
    -- fields:
    for _, key in ipairs({"line", "rc", "train_name", "owner"}) do
        if fields[key] then
            custom_state[key] = fields[key]
        end
    end
    for i, stop in ipairs(custom_state.stops) do
        local prefix = string.format("s%02d_", i)
        for _, key in ipairs({"dep", "stn", "track", "pos"}) do
            local value = fields[prefix..key]
            if value then
                stop[key] = value
            end
        end
    end
    -- selection:
    if fields.linevar then
        local event = core.explode_table_event(fields.linevar)
        if event.type == "CHG" or event.type == "DCL" then
            custom_state_set_selection_index(custom_state, assert(tonumber(event.row)))
            update_formspec = true
        end
    end

    -- buttons:
    if fields.create then
        custom_state_set_selection_index(custom_state, 1)
        update_formspec = true
    elseif fields.reset then
        custom_state_set_selection_index(custom_state, custom_state.selection_index or 1)
        update_formspec = true
    elseif fields.save then
        local pinfo = ch_core.normalize_player(player)
        if pinfo.role == "new" or pinfo.role == "none" then
            core.log("error", "Access violation in line editor caused by '"..pinfo.player_name.."'!")
            return -- access violation!
        end
        if custom_state.compiled_linevar == nil then
            -- zkontrolovat a skompilovat
            local success, errmsg = custom_state_compile_linevar(custom_state)
            if success then
                -- TODO: zkontrolovat práva a možnost přepsání i zde!
                ch_core.systemovy_kanal(pinfo.player_name, "Úspěšně ověřeno. Varianta linky může být uložena.")
            else
                ch_core.systemovy_kanal(pinfo.player_name, "Ověření selhalo: "..(errmsg or "Neznámý důvod"))
            end
            update_formspec = true
        else
            -- pokusit se uložit...
            local selection_index = custom_state.selection_index or 1
            local selected_linevar, selected_linevar_def, selected_linevar_station
            local to_linevar, to_linevar_def, to_linevar_station
            local new_linevar, new_linevar_def, new_linevar_station

            -- NEW:
            new_linevar_def = custom_state.compiled_linevar
            new_linevar = new_linevar_def.name
            new_linevar_station = get_stn_from_linevar(new_linevar)

            -- SELECTED:
            if custom_state.selection_index > 1 and custom_state.linevars[selection_index - 1] ~= nil then
                selected_linevar_def, selected_linevar_station = try_get_linevar_def(custom_state.linevars[selection_index - 1].name)
                if selected_linevar_def ~= nil then
                    selected_linevar = selected_linevar_def.name
                end
            end

            -- TO OVERWRITE:
            to_linevar_def, to_linevar_station = try_get_linevar_def(new_linevar)
            if to_linevar_def ~= nil then
                to_linevar = to_linevar_def.name
            end

            local success, errmsg
            if selected_linevar == nil then
                if to_linevar == nil then
                    -- zcela nová varianta
                    success, errmsg = add_linevar(new_linevar_station, new_linevar_def)
                else
                    -- replace
                    success = check_rights(pinfo, to_linevar_def.owner)
                    if success then
                        success, errmsg = replace_linevar(new_linevar_station, new_linevar_def)
                    else
                        errmsg = "Nedostatečná práva k variantě linky '"..to_linevar.."'."
                    end
                end
            elseif to_linevar == nil then
                -- delete and add
                success = check_rights(pinfo, selected_linevar_def.owner)
                if success then
                    success, errmsg = delete_linevar(selected_linevar_station, selected_linevar)
                    if success then
                        success, errmsg = add_linevar(new_linevar_station, new_linevar_def)
                    end
                else
                    errmsg = "Nedostatečná práva k variantě linky '"..selected_linevar.."'."
                end
            elseif selected_linevar ~= to_linevar then
                -- delete and replace
                success = check_rights(pinfo, to_linevar_def.owner)
                if success then
                    success = check_rights(pinfo, selected_linevar_def.owner)
                    if success then
                        success, errmsg = delete_linevar(selected_linevar_station, selected_linevar)
                        if success then
                            success, errmsg = replace_linevar(new_linevar_station, new_linevar_def)
                        end
                    else
                        errmsg = "Nedostatečná práva k variantě linky '"..selected_linevar.."'."
                    end
                else
                    errmsg = "Nedostatečná práva k variantě linky '"..to_linevar.."'."
                end
            else
                -- replace
                success = check_rights(pinfo, to_linevar_def.owner)
                if success then
                    success, errmsg = replace_linevar(new_linevar_station, new_linevar_def)
                else
                    errmsg = "Nedostatečná práva k variantě linky '"..to_linevar.."'."
                end
            end

            if success then
                ch_core.systemovy_kanal(pinfo.player_name, "Varianta linky '"..new_linevar.."' úspěšně uložena.")
                custom_state_refresh_linevars(custom_state, new_linevar)
                update_formspec = true
            else
                ch_core.systemovy_kanal(pinfo.player_name, "Ukládání selhalo: "..(errmsg or "Neznámá chyba."))
            end
        end

    elseif fields.delete then
        local pinfo = ch_core.normalize_player(player)
        if pinfo.role == "new" or pinfo.role == "none" then
            core.log("error", "Access violation in line editor caused by '"..pinfo.player_name.."'!")
            return -- access violation!
        end
        local selection_index = custom_state.selection_index or 1
        local selected_linevar, selected_linevar_def, selected_linevar_station
        if custom_state.selection_index > 1 and custom_state.linevars[selection_index - 1] ~= nil then
            selected_linevar_def, selected_linevar_station = try_get_linevar_def(custom_state.linevars[selection_index - 1].name)
            if selected_linevar_def ~= nil then
                selected_linevar = selected_linevar_def.name
            end
            local success, errmsg
            success = check_rights(pinfo, selected_linevar_def.owner)
            if success then
                success, errmsg = delete_linevar(selected_linevar_station, selected_linevar)
            else
                errmsg = "Nedostatečná práva k variantě linky '"..selected_linevar.."'."
            end
            if success then
                ch_core.systemovy_kanal(pinfo.player_name, "Varianta linky '"..selected_linevar.."' úspěšně smazána.")
                custom_state_refresh_linevars(custom_state)
                update_formspec = true
            else
                ch_core.systemovy_kanal(pinfo.player_name, "Mazání selhalo: "..(errmsg or "Neznámá chyba."))
            end
        end
    elseif fields.last_passages then
        local selected_linevar_def = try_get_linevar_def(custom_state.linevars[(custom_state.selection_index or 1) - 1].name)
        if selected_linevar_def ~= nil then
            print("DEBUG: selected_linevar_def: "..dump2(selected_linevar_def))
            assert(selected_linevar_def.name)
            show_last_passages_formspec(player, selected_linevar_def, assert(selected_linevar_def.name))
            return
        end
    end

	if update_formspec then
		return get_formspec(custom_state)
	end
end

local function show_editor_formspec(player, linevar_to_select)
    if player == nil then return false end
	local custom_state = {
		player_name = assert(player:get_player_name()),
        evl_scroll = 0,
	}
    if not custom_state_refresh_linevars(custom_state, linevar_to_select) then
        custom_state_set_selection_index(custom_state, 1)
    end
	ch_core.show_formspec(player, "advtrains_line_automation:editor_linek", get_formspec(custom_state), formspec_callback, custom_state, {})
end

local function lp_formspec_callback(custom_state, player, formname, fields)
    if fields.back then
        show_editor_formspec(player, custom_state.selected_linevar)
    end
end

show_last_passages_formspec = function(player, linevar_def, selected_linevar)
    local formspec = {
        "formspec_version[6]"..
        "size[20,10]"..
        "label[0.5,0.6;Poslední jízdy na variantě linky ",
        F(assert(linevar_def.name)),
        "]"..
        "tablecolumns[text;text;text,width=5;text,width=5;text,width=5;text,width=5;text,width=5;text,width=5;text,width=5;text,width=5;text,width=5;text,width=5]",
        "table[0.5,1.25;19,8;jizdy;KÓD,DOPRAVNA,1.j.,2.j.,3.j.,4.j.,5.j.,6.j.,7.j.,8.j.,9.j.,10.j."
    }
    local passages, stops = get_last_passages(linevar_def)
    local max_time = {}
    if passages ~= nil then
        for i = 1, 10 do
            if passages[i] == nil then
                passages[i] = {}
            end
        end
        for i = 1, #stops do -- i = index zastávky
            table.insert(formspec, ","..F(stops[i][1])..","..F(stops[i][2]))
            for j = 1, 10 do -- j = index jízdy
                local time = passages[j][i]
                if time ~= nil then
                    table.insert(formspec, ","..time)
                    if max_time[j] == nil or max_time[j] < time then
                        max_time[j] = time
                    end
                else
                    table.insert(formspec, ",-")
                end
            end
        end
        table.insert(formspec, ",,DOBA JÍZDY:")
        for i = 1, 10 do
            if max_time[i] ~= nil then
                table.insert(formspec, ",_"..(max_time[i] - passages[i][1]).."_")
            else
                table.insert(formspec, ",-")
            end
        end
    end
    table.insert(formspec, ";]"..
        "button[17.75,0.3;1.75,0.75;back;zpět]"..
        "tooltip[jizdy;Časové údaje jsou v sekundách železničního času.]")
    formspec = table.concat(formspec)
    local custom_state = {
        player_name = player:get_player_name(),
        selected_linevar = selected_linevar,
    }
    ch_core.show_formspec(player, "advtrains_line_automation:posledni_jizdy", formspec, lp_formspec_callback, custom_state, {})
end

def = {
    -- params = "",
    description = "Otevře editor variant linek",
    privs = {ch_registered_player = true},
    func = function(player_name, param) show_editor_formspec(minetest.get_player_by_name(player_name)) end,
}
core.register_chatcommand("linky", def)
