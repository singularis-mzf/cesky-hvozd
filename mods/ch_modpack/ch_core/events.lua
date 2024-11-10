ch_core.open_submod("events", {chat = true, data = true, lib = true, privs = true})

local safety_limit = 256
local worldpath = minetest.get_worldpath()

local event_types = {}
ch_core.event_types = event_types

local sendable_event_types_cache = {--[[
    [hour_id] = {
        [player_name] = {string, ...},
    }
]]}

local function get_timestamp()
	local cas = ch_core.aktualni_cas()
	return string.format("%04d-%02d-%02d %02d:%02d:%02d", cas.rok, cas.mesic, cas.den, cas.hodina, cas.minuta, cas.sekunda), cas
end

local function timestamp_to_date(timestamp)
    return string.sub(timestamp, 1, 10)
end

local function timestamp_to_month_id(timestamp)
    return string.sub(timestamp, 1, 7)
end

local function timestamp_to_hour_id(timestamp)
    return string.sub(timestamp, 1, 13)
end

local function is_events_admin(pinfo)
    return pinfo.role == "admin" or pinfo.privs.ch_events_admin
end

local events_month_id -- ID aktuálního měsíce (aktualizuje se ve funkci add_event())
local events = function()
    local cas = ch_core.aktualni_cas()
    local rok, mesic = cas.rok, cas.mesic
    local result, result_month_id = {}, string.format("%04d-%02d", rok, mesic)
    for i = 1, 3 do
        local month_id = string.format("%04d-%02d", rok, mesic)
        local filename = worldpath.."/events_"..month_id..".json"
        local f = io.open(filename)
        local data
        if f then
            data = f:read("*a")
            f:close()
            if data ~= nil then
                data = assert(minetest.parse_json(data))
            end
            if data == nil then
                minetest.log("warning", "Loading events data from "..filename.." failed!")
            end
        end
        result[i] = data or {}
        minetest.log("info", "[ch_core/events] Loaded "..#result[i].." events for "..month_id)
        if mesic > 1 then
            mesic = mesic - 1
        else
            mesic, rok = 12, rok - 1
        end
    end
    return result, result_month_id
end
events, events_month_id = events()
--[[
    events[month_id] = {
        -- pole je seřazené od nejstarší události po nejnovější
        {
            timestamp = STRING, -- časová známka události (úplná)
            type = STRING, -- typ události (podle pole event_types)
            text = STRING || nil, -- text události (značku {PLAYER} je potřeba před zobrazením nahradit jménem podle player_name)
                -- je-li nil, použije se default_text podle typu události
            player_name = STRING || nil, -- postava, které se událost týká (je-li)
        }...
    }
]]

local function access_events(month_id)
    if month_id ~= events_month_id then
        minetest.log("warning", "Will open a new event month "..month_id.."!")
        table.insert(events, 1, {})
        events_month_id = month_id
    end
    return events[1]
end

local function save_events()
    local filename = worldpath.."/events_"..events_month_id..".json"
    local data, error_message = minetest.write_json(events[1])
	if data == nil then
		error("save_events(): serialization error: "..tostring(error_message or "nil"))
	end
    minetest.safe_file_write(filename, data)
end

local function get_event_text(event, type_def)
    local event_text = event.text
    if event_text == nil then
        if type_def == nil then
            return nil -- unknown event type
        end
        event_text = type_def.default_text or "[Bez textu]"
    end
    if event.player_name then
        if type_def ~= nil and type_def.prepend_viewname then
            event_text = ch_core.prihlasovaci_na_zobrazovaci(event.player_name)..": "..event_text
        else
            event_text = event_text:gsub("{PLAYER}", ch_core.prihlasovaci_na_zobrazovaci(event.player_name))
        end
    end
    return event_text
end

--[[
    event_def = {
        access = "public" or "admin" or "players" or "player_only" or "discard",
        description = string, -- popis typu události pro zobrazení ve formspecech a v četu

        color = "#RRGGBB" or nil, -- barva pro zobrazení události
        default_text = string or nil, -- text události, který se použije, pokud nebude zadán žádný text ve volání ch_core.add_event()
        chat_access = "public" or "admin" or "players" or "player_only" or nil, -- komu se má událost vypsat v četu, bude-li online
        send_access = "admin" or "players" or nil, -- kdo může událost ručně odeslat z dialogového okna
        delete_access = "player_only" or nil, -- kdo kromě postav s právem ch_events_admin může událost smazat

        ignore = bool or nil, -- je-li true, budou události tohoto typu tiše ignorovány; v případě načtení ze souboru nebudou vypisovány
        prepend_viewname = bool or nil, -- je-li true, značka "{PLAYER}" v textu události nebude rozpoznávána; namísto toho se
            -- před text vloží zobrazovací jméno postavy oddělené ": "
    }
]]
function ch_core.register_event_type(event_type, event_def)
    if event_types[event_type] ~= nil then
        error("Event type "..event_type.." is already registered.")
    end
    local access = event_def.access
    if access ~= "public" and access ~= "admin" and access ~= "players" and access ~= "player_only" and access ~= "discard" then
        error("Invalid event access keyword: "..event_def.access)
    end
    local def = {
        access = access,
        color = event_def.color or "#ffffff",
        description = assert(event_def.description),
    }
    if event_def.default_text ~= nil then
        def.default_text = event_def.default_text
    end
    if event_def.ignore then
        def.ignore = true
    else
        def.ignore = false
    end
    if event_def.prepend_viewname then
        def.prepend_viewname = true
    end
    if event_def.chat_access ~= nil then
        if event_def.chat_access == "admin" or event_def.chat_access == "players" or event_def.chat_access == "public" or event_def.chat_access == "player_only" then
            def.chat_access = event_def.chat_access
        else
            minetest.log("warning", "Unsupported 'chat_access' value '"..event_def.chat_access.."' ignored!")
        end
    end
    if event_def.send_access ~= nil then
        if event_def.send_access == "admin" or event_def.send_access == "players" then
            def.send_access = event_def.send_access
        else
            minetest.log("warning", "Unsupported 'send_access' value '"..event_def.send_access.."' ignored!")
        end
    end
    if event_def.delete_access ~= nil then
        if event_def.delete_access == "player_only" then
            def.delete_access = event_def.delete_access
        else
            minetest.log("warning", "Unsupported 'delete_access' value '"..event_def.delete_access.."' ignored!")
        end
    end
    event_types[event_type] = def
end

function ch_core.add_event(event_type, text, player_name)
    local type_def = event_types[event_type]
    if type_def == nil then
        minetest.log("warning", "Event added with unknown type: "..dump2({event_type = event_type, text = text, player_name = player_name}))
        return
    end
    if type_def.ignore then
        return -- ignore this event
    end
    local timestamp = get_timestamp()
    local month_id = timestamp_to_month_id(timestamp)
    local event = {
        timestamp = timestamp,
        type = event_type,
        text = text,
        player_name = player_name,
    }
    if text == nil and type_def.default_text == nil then
        minetest.log("warning", "Event of type "..event_type.." added with no text!")
    end
    if type_def.access ~= "discard" then
        local current_events = assert(access_events(month_id))

        -- Check safety limit:
        if #current_events >= safety_limit then
            local count = 0
            for i = #current_events, 1, -1 do
                if current_events[i].type == event_type then
                    count = count + 1
                    if count >= safety_limit then
                        minetest.log("warning", "Event NOT added, because the security limit "..safety_limit.." was achieved: "..
                            timestamp.." <"..event_type.."> "..(get_event_text(event, type_def) or "nil"))
                        return
                    end
                end
            end
        end

        table.insert(current_events, event)
        save_events()
        minetest.log("action", "Event #"..#current_events.." added: "..timestamp.." <"..event_type.."> "..(get_event_text(event, type_def) or "nil"))

        -- remove from sendable events cache:
        if player_name ~= nil and is_events_admin(ch_core.normalize_player(player_name)) then
            local cache = sendable_event_types_cache[timestamp_to_date(timestamp)]
            if cache ~= nil then
                cache = cache[player_name]
                if cache ~= nil then
                    local i = table.indexof(cache, event_type)
                    if i ~= -1 then
                        table.remove(cache, i)
                    end
                end
            end
        end
    end

    -- send to chat
    if type_def.chat_access ~= nil then
        local players_to_send = {}
        if type_def.chat_access == "player_only" then
            if player_name ~= nil and ch_core.online_charinfo[player_name] ~= nil then
                table.insert(players_to_send, player_name)
            end
        elseif type_def.chat_access == "players" then
            for _, oplayer in ipairs(minetest.get_connected_players()) do
                if ch_core.get_player_role(oplayer) ~= "new" then
                    table.insert(players_to_send, oplayer:get_player_name())
                end
            end
        elseif type_def.chat_access == "public" then
            for _, oplayer in ipairs(minetest.get_connected_players()) do
                table.insert(players_to_send, oplayer:get_player_name())
            end
        elseif type_def.chat_access == "admin" then
            for _, oplayer in ipairs(minetest.get_connected_players()) do
                local opinfo = ch_core.normalize_player(oplayer)
                if is_events_admin(opinfo) then
                    table.insert(players_to_send, opinfo.player_name)
                end
            end
        end
        local message_to_send = {}
        if type_def.color ~= nil then
            table.insert(message_to_send, minetest.get_color_escape_sequence(type_def.color))
        end
        table.insert(message_to_send, get_event_text(event, type_def).." "..ch_core.colors.light_gray.."<"..type_def.description..">")
        message_to_send = table.concat(message_to_send)
        for _, oplayer_name in ipairs(players_to_send) do
            ch_core.systemovy_kanal(oplayer_name, message_to_send)
        end
    end
end

--[[
    Vrací prostý seznam typů událostí, k nimž zadaná postava může mít přístup a pro které
    dotaz do negative_set vyjde „pravdivý“.
    player_name_or_player = PlayerRef or string,
    negative_set = table or nil,
    => {string, ...}
]]
function ch_core.get_event_types_for_player(player_name_or_player, negative_set)
    if negative_set == nil then negative_set = {} end
    local pinfo = ch_core.normalize_player(player_name_or_player)
    local has_access_rights = {
        public = true,
        players = pinfo.role ~= "new",
        admin = is_events_admin(pinfo),
        player_only = true,
        discard = false,
    }
    local result = {}
    for event_type, type_def in pairs(event_types) do
        if not negative_set[event_type] and has_access_rights[type_def.access] then
            table.insert(result, event_type)
        end
    end
    return result
end

function ch_core.get_sendable_event_types_for_player(player_name_or_player)
    local pinfo = ch_core.normalize_player(player_name_or_player)
    local timestamp = get_timestamp()
    local hour_id = timestamp_to_hour_id(timestamp)
    local player_name = pinfo.player_name
    local is_admin = is_events_admin(pinfo)

    local cache = sendable_event_types_cache[hour_id]
    if cache == nil then
        -- discard/renew cache
        cache = {}
        sendable_event_types_cache = {[hour_id] = cache}
    end
    local result = cache[player_name]
    if result ~= nil then
        return result -- cache hit
    end
    result = {}
    if is_admin then
        for event_type, type_def in pairs(ch_core.event_types) do
            if type_def.send_access == "players" or type_def.send_access == "admin" then
                table.insert(result, event_type)
            end
        end
    elseif pinfo.role ~= "new" then -- nové postavy nemohou odesílat nic
        local used_types_set = {}
        for _, event in ipairs(events[events_month_id] or {}) do
            if event.player_name == player_name and timestamp_to_hour_id(event.timestamp) == hour_id then
                used_types_set[event.type] = true
            end
        end
        for event_type, type_def in pairs(ch_core.event_types) do
            if type_def.send_access == "players" and not used_types_set[event_type] then
                table.insert(result, event_type)
            end
        end
    end
    -- seřadit:
    if #result > 1 then
        table.sort(result, function(et_a, et_b)
            if et_a == et_b then return false end
            if et_a == "custom" then return true end -- "custom" na začátek
            if et_b == "custom" then return false end
            return ch_core.utf8_mensi_nez(ch_core.event_types[et_a].description, ch_core.event_types[et_b].description, false)
            end)
    end
    cache[player_name] = result
    return result
end

--[[
    Vrací pole prvků od nejnovější události po nejstarší. Každý prvek má strukturu:
    {
        id = STRING or nil, -- ID události, které umožňuje ji smazat (závisí na právech postavy)
        time = STRING, -- časová známka v podobě, jak má být prezentována hráči/ce
        description = STRING, -- označení typu zprávy
        color = "#RRGGBB", -- barva pro zobrazení události, vždy ve formátu #RRGGBB
        text = STRING, -- text, jak má být prezentován hráči/ce, nebo prázdný řetězec
    }
]]
function ch_core.get_events_for_player(player_name_or_player, allowed_event_types, limit)
    local pinfo = ch_core.normalize_player(player_name_or_player)
    local result = {}
    local has_access_rights = {
        public = true,
        players = pinfo.role ~= "new",
        admin = is_events_admin(pinfo),
        player_only = true, -- bude testováno samostatně
        discard = false,
    }
    local event_types_filtered = {}
    if allowed_event_types ~= nil then
        for _, event_type in ipairs(allowed_event_types) do
            local type_def = event_types[event_type]
            if type_def ~= nil and has_access_rights[type_def.access] then
                event_types_filtered[event_type] = type_def
            end
        end
    else
        for event_type, type_def in pairs(event_types) do
            if has_access_rights[type_def.access] then
                event_types_filtered[event_type] = type_def
            end
        end
    end
    for events_month_iter, events_month in ipairs(events) do
        for i = #events_month, 1, -1 do
            local event = events_month[i]
            local type_def = event_types_filtered[event.type]
            if type_def ~= nil and not type_def.ignore and (type_def.access ~= "player_only" or event.player_name == pinfo.player_name) then
                local record = {
                    time = assert(event.timestamp), -- TODO...
                    description = assert(type_def.description),
                    text = get_event_text(event, type_def) or "",
                    color = assert(type_def.color),
                }
                if events_month_iter == 1 and
                    (has_access_rights.admin or
                        (type_def.delete_access == "player_only" and
                        event.player_name == pinfo.player_name and
                        timestamp_to_date(event.timestamp) == timestamp_to_date(get_timestamp())))
                then
                        record.id = tostring(i)
                end
                table.insert(result, record)
                if #result >= limit then
                    return result
                end
            end
        end
    end
    return result
end

--[[
    id = STRING -- ID oznámení k smazání (podle záznamu z funkce ch_core.get_events_for_player() )
    descripton = STRING or nil -- je-li vyplněno, oznámení se smaže jen tehdy, pokud jeho popis přesně odpovídá zadanému
    player_name = STRING or nil, -- je-li vyplněno, oznámení se smaže jen tehdy, pokud jeho player_name přesně odpovídá zadanému
    vrací: true, pokud bylo oznámení úspěšně smazáno; false, pokud mazání selhalo
]]
function ch_core.remove_event(id, description, player_name)
    minetest.log("warning", "ch_core.remove_event(): an event is going to be deleted: "..dump2({id = id, description = description}))
    local index = tonumber(id)
    local events_month = events[1]
    if events_month == nil or index == nil or index < 1 or index > #events_month then
        minetest.log("error", "ch_core.remove_event(): failed, because of invalid index "..tostring(id).." (#events_month = "..#events_month..")")
        return false
    end
    local event = events_month[index]
    if event == nil then
        minetest.log("error", "ch_core.remove_event(): failed, because event not found")
        return false
    end
    if description ~= nil then
        local type_def = event_types[event.type]
        if type_def == nil or type_def.description ~= description then
            minetest.log("error", "ch_core.remove_event(): failed, because description does not match")
            return false
        end
    end
    if player_name ~= nil and event.player_name ~= player_name then
        minetest.log("error", "ch_core.remove_event(): failed, because player_name does not match")
        return false
    end
    table.remove(events_month, index)
    save_events()
    minetest.log("action", "Event removed: "..dump2(event))
    return true
end

-- Událost "server_started"

ch_core.register_event_type("server_started", {
    description = "server spuštěn",
    access = "admin",
    color = "#aaaaaa",
    default_text = "",
})

ch_core.register_event_type("server_shutdown", {
    description = "server vypnut",
    access = "admin",
    color = "#aaaaaa",
    default_text = "",
})

minetest.register_on_mods_loaded(function()
    ch_core.add_event("server_started")
end)

minetest.register_on_shutdown(function()
    ch_core.add_event("server_shutdown")
end)

ch_core.close_submod("events")
