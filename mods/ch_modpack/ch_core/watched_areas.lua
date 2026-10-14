ch_core.open_submod("watched_areas")

local areas = {--[[
    [area_id] = {
        min = vector,
        max = vector,
        on_enter, on_leave, on_joinplayer, on_leaveplayer = function() or nil,
        state = any,
        expire_at = long, -- os.time() value
        players = {[player_name] = PlayerRef, ...},
    }, ...
]]}
local areas_locked = false -- if true, you should use table.copy() before modifying areas table!

local function lock_areas()
    areas_locked = true
    return areas
end

local function unlock_areas()
    areas_locked = false
    return areas
end

local function areas_for_writing() -- use this function to access `areas` table, if you are going to add to/remove from it
    if areas_locked then
        areas = table.copy(areas)
        areas_locked = false
    end
    return areas
end

-- ch_data online_charinfo:
-- .wa_last_pos = vector (rounded vector of the last player position)

local function debug_watched_areas()
    local os_time = os.time()
    local result = {""}
    local n = 0
    for area_id, area in pairs(areas) do
        local pos = core.get_position_from_hash(area_id)
        local pos_str = core.pos_to_string(pos)
        local ttl = area.expire_at - os_time
        table.insert(result, pos_str.." ["..ttl.."]")
        n = n + 1
    end
    result[1] = n.." watched areas exist"
    return table.concat(result, " | ")
end

-- Vrací nil, pokud oblast již vypršela; jinak vrací area.
local function get_valid_area(os_time, area_id)
    local area = areas[area_id]
    if area ~= nil and os_time >= area.expire_at then
        -- Oblast vypršela
        core.log("action", "DEBUG: watched area at "..core.pos_to_string(core.get_position_from_hash(area_id)).." expired.")
        areas_for_writing()[area_id] = nil
        area.on_area_action(area.state, "destructed", {min = area.min, max = area.max})
        -- Oblast mohla být znovu zaregistrována.
        return areas[area_id]
    end
    return area
end

local function do_nothing()
    return nil
end

--[[
    Pro blok na pozici `pos` zaregistruje dočasnou hlídanou oblast. Vstupy a odchody postav
    budou hlášeny voláním callbacků. Po každou pozici může být v jednu chvíli jen jedna registrovaná
    hlídaná oblast.

    args = {
        min = vector,
        max = vector,
        on_area_action = function(area_state, action_type, action_args) or nil,
        -- on_enter, on_leave, on_joinplayer, on_leaveplayer, on_registered = function() or nil,
        state = any,
        ttl = int > 0 or nil, -- nil => 300 -- za jak dlouho má oblast vypršet
    }
    -- on_registered({[player_name] = PlayerRef, ...}, state) -- may be called with an empty list

    Podporované akce (action_type):
    - "registered" — zavolá se po úspěšné registraci oblasti;
      action_args = {[player_name] = PlayerRef, ...} (tabulka postav, které aktuálně uvnitř oblasti jsou)
    - "destructed" — zavolá se poté, co oblast vypršela a byla smazána; může oblast znovu zaregistrovat
      action_args = {min = vector, max = vector}
    - "enter" — hráčská postava vstoupila do oblasti
      action_args = PlayerRef
    - "leave" — hráčská postava odešla z oblasti
      action_args = PlayerRef
    - "joinplayer" — hráčská postava se ocitla v oblasti po přihlášení do hry
      action_args = PlayerRef
    - "leaveplayer" — hráčská postava se odhlásila ze hry uvnitř oblasti
      action_args = PlayerRef

    Parametr args může být null, pokud na dané pozici leží blok, který ve své definici
    definuje funkci get_watched_area_def(pos), která vrátí tabulku — ta se pak použije
    namísto args.
]]
function ch_core.register_watched_area(pos, args)
    local os_time = os.time()
    local area_id = core.hash_node_position(pos)
    local area = get_valid_area(os_time, area_id)
    if area ~= nil then
        error("Watched area at "..core.pos_to_string(pos).." is already registered!")
    end
    if args == nil then
        local node = core.get_node(pos)
        local ndef = core.registered_nodes[node.name]
        if ndef == nil or ndef.get_watched_area_def == nil then
            error("ch_core.register_watched_area() called with null args, but the node at "..core.pos_to_string(pos).." ("..node.name..") has no get_watched_area_def() callback!")
        end
        args = assert(ndef.get_watched_area_def(pos))
        if type(args) ~= "table" then
            error("get_watched_area_def(pos) callback for "..node.name.." returned invalid type "..type(args).."!")
        end
    end
    local min, max = vector.copy(args.min), vector.copy(args.max)
    if min.x > max.x then
        min.x, max.x = max.x, min.x
    end
    if min.y > max.y then
        min.y, max.y = max.y, min.y
    end
    if min.z > max.z then
        min.z, max.z = max.z, min.z
    end
    local players_in_area = {}
    area = {
        min = min,
        max = max,
        on_area_action = ch_core.ifthenelse(type(args.on_area_action) == "function", args.on_area_action, do_nothing),
        state = args.state,
        players = players_in_area,
    }
    if type(args.ttl) == "number" and args.ttl >= 1 then
        area.expire_at = os_time + math.floor(args.ttl)
    else
        area.expire_at = os_time + 300
    end
    for player_name, online_charinfo in pairs(ch_data.online_charinfo) do
        if vector.in_area(assert(online_charinfo.wa_last_pos), min, max) then
            players_in_area[player_name] = assert(online_charinfo.player)
        end
    end
    areas_for_writing()[area_id] = area
    core.log("action", "DEBUG: new watched area "..core.pos_to_string(pos).." registered.")
    return area.on_area_action(area.state, "registered", players_in_area)
end

function ch_core.get_players_in_watched_area(pos)
    local os_time = os.time()
    local area_id = core.hash_node_position(pos)
    local area = get_valid_area(os_time, area_id)
    if area == nil then
        return nil
    end
    return area.players
end

local function is_watched_area_registered(area_id)
    return get_valid_area(os.time(), area_id) ~= nil
end

function ch_core.is_watched_area_registered(pos)
    return is_watched_area_registered(core.hash_node_position(pos))
end

--[[
    Prodlouží životnost registrované oblasti na minimálně min_ttl sekund od tohoto okamžiku.
]]
function ch_core.extend_watched_area_expiration(pos, min_ttl)
    local area_id = core.hash_node_position(pos)
    local t = areas[area_id] -- zde nechceme způsobit vypršení oblasti, proto nevoláme get_valid_area()
    if t == nil or min_ttl < 1 then
        return false
    end
    local new_expire_at = os.time() + min_ttl
    if new_expire_at > t.expire_at then
        t.expire_at = new_expire_at
        return true
    end
    return false
end

--[[
    Zruší registrovanou oblast a zavolá callback pro událost "destructed".
    Vrací:
        - true :: pokud oblast existovala a byla zrušena
        - false :: pokud oblast neexistovala (nebo už předtím vypršela)
        - nil :: pokud oblast existovala, ale po zrušení ji callback obnovil
]]
function ch_core.unregister_watched_area(pos)
    local os_time = os.time()
    local area_id = core.hash_node_position(pos)
    local area = get_valid_area(os_time, area_id)
    if area == nil then
        return false
    end
    areas_for_writing()[area_id] = nil
    core.log("action", "DEBUG: Watched area at "..core.pos_to_string(pos).." unregistered.")
    area.on_area_action(area.state, "destructed", {min = area.min, max = area.max})
    if areas[area_id] == nil then
        return true
    else
        return nil
    end
end

local function on_joinplayer(player)
    local online_charinfo = ch_data.get_joining_online_charinfo(player)
    local player_name = assert(online_charinfo.player_name)
    local pos = vector.round(player:get_pos())
    local os_time = os.time()
    online_charinfo.wa_last_pos = pos
    local areas_snapshot = lock_areas()
    for area_id, _ in pairs(areas_snapshot) do
        local area = get_valid_area(os_time, area_id)
        if area ~= nil and vector.in_area(pos, area.min, area.max) then
            -- player joined to a watched area
            area.players[player_name] = player
            area.on_area_action(area.state, "joinplayer", player)
        end
    end
    unlock_areas()
end

local function on_leaveplayer(player)
    local player_name = player:get_player_name()
    local os_time = os.time()
    lock_areas()
    for area_id, _ in pairs(areas) do
        local area = get_valid_area(os_time, area_id)
        if area ~= nil and area.players[player_name] ~= nil then
            area.players[player_name] = nil
            -- player leaved the game inside a watched area
            area.on_area_action(area.state, "leaveplayer", player)
        end
    end
    unlock_areas()
end

local skip_globalstep = true

local function globalstep(dtime)
    skip_globalstep = not skip_globalstep
    if not skip_globalstep then
        return
    end
    for player_name, online_charinfo in pairs(ch_data.online_charinfo) do
        local player = online_charinfo.player
        local player_pos = vector.round(player:get_pos())
        local last_pos = online_charinfo.wa_last_pos
        if not vector.equals(player_pos, last_pos) then -- if the player moved...
            local os_time = os.time()
            local actions = {} -- {state, action_type, player, area_id}
            local areas_snapshot = lock_areas()
            local area_id = next(areas_snapshot)
            while area_id ~= nil do
                local area = get_valid_area(os_time, area_id)
                if area ~= nil then
                    if vector.in_area(player_pos, area.min, area.max) then
                        -- the player is in the area
                        if area.players[player_name] == nil then
                            -- the player was not, but now is in the area (enter)
                            area.players[player_name] = player
                            table.insert(actions, {area.state, "enter", player, area_id})
                        end
                    else
                        if area.players[player_name] ~= nil then
                            -- the player was is the area, but now they're not (leave)
                            area.players[player_name] = nil
                            table.insert(actions, {area.state, "leave", player, area_id})
                        end
                    end
                end
                area_id = next(areas_snapshot, area_id)
            end
            unlock_areas()

            -- call callbacks
            for _, action in ipairs(actions) do
                local area = areas[action[4]]
                if area ~= nil then
                    area.on_area_action(action[1], action[2], action[3])
                end
            end

            -- update wa_last_pos:
            online_charinfo.wa_last_pos = player_pos
        end
    end
end

core.register_globalstep(globalstep)
core.register_on_joinplayer(on_joinplayer)
core.register_on_leaveplayer(on_leaveplayer)

local node_name = "ch_core:watched_areas_test"

local watched_area_action, watched_area_test_get_watched_area_def

watched_area_action = function(state, action_type, action_args)
    local pos = state.pos
    print("DEBUG: "..core.pos_to_string(pos).." action "..action_type)
    if action_type == "registered" then
        local s = "Sledovaná oblast okolo "..core.pos_to_string(pos).." zaregistrována s těmito hráči/kami:"
        local players = action_args
        for pname, _ in pairs(players) do
            s = s.."\n- "..pname
        end
        core.chat_send_all(s)
    elseif action_type == "enter" then
        local player = action_args
        core.chat_send_player(player:get_player_name(), "Vstoupil/a jste do sledované oblasti okolo "..core.pos_to_string(pos))
    elseif action_type == "leave" then
        local player = action_args
        core.chat_send_player(player:get_player_name(), "Opustil/a jste sledovanou oblast okolo "..core.pos_to_string(pos))
    elseif action_type == "joinplayer" then
        local player = action_args
        core.chat_send_all(player:get_player_name().." se připojil/a do sledované oblasti okolo "..core.pos_to_string(pos))
    elseif action_type == "leaveplayer" then
        local player = action_args
        core.chat_send_all(player:get_player_name().." se odpojil/a ve sledované oblasti okolo "..core.pos_to_string(pos))
    elseif action_type == "destructed" then
        local meta = core.get_meta(pos)
        local lives = meta:get_int("watched_area_lives")
        local s
        if lives > 0 then
            meta:set_int("watched_area_lives", lives - 1)
            ch_core.register_watched_area(pos)
            s = "Sledovaná oblast okolo "..core.pos_to_string(pos).." vzkříšena (měla "..lives.." životů, má "..meta:get_int("watched_area_lives")..")."
        else
            s = "Sledovaná oblast okolo "..core.pos_to_string(pos).." zrušena."
        end
        core.chat_send_all(s)
    end
    print("DEBUG: AREAS: "..debug_watched_areas())
end

watched_area_test_get_watched_area_def = function(pos)
    return {
        min = vector.offset(pos, -1, -1, -1),
        max = vector.offset(pos, 1, 1, 1),
        on_area_action = watched_area_action,
        state = {pos = pos},
        ttl = 30,
    }
end

core.register_node(node_name, {
    description = "Test sledované oblasti [EXPERIMENTÁLNÍ]",
    tiles = {{name = "ch_core_white_pixel.png^[opacity:40^[resize:32x32", backface_culling = false}},
    use_texture_alpha = "blend",
    drawtype = "nodebox",
    node_box = {type = "fixed", fixed = {
        {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        {-1.5, -1.5, -1.5, 1.5, 1.5, 1.5},
    }},
    selection_box = {type = "regular"},
    walkable = false,
    groups = {oddly_breakable_by_hand = 1, experimental = 1,
        has_watched_area__ = 1 -- disable this temporarily
    },
    on_construct = function(pos)
        ch_core.register_watched_area(pos)
        core.get_meta(pos):set_int("watched_area_lives", 1)
    end,
    on_destruct = function(pos)
        ch_core.unregister_watched_area(pos)
    end,
    get_watched_area_def = watched_area_test_get_watched_area_def,
})

core.register_lbm({
    label = "Watched areas",
    name = "ch_core:watched_areas",
    nodenames = {"group:has_watched_area"},
    run_at_every_load = true,
    action = function(pos, node, dtime_s)
        if not ch_core.is_watched_area_registered(pos) then
            local ndef = core.registered_nodes[node.name]
            if ndef and ndef.get_watched_area_def then
                print("DEBUG: LBM will register a new watched area at "..core.pos_to_string(pos))
                ch_core.register_watched_area(pos)
            end
        end
    end,
})

-- Automaticky prodlužovat/zřizovat sledování blokům se skupinou has_watched_area
core.register_abm({
    label = "Watched areas",
    nodenames = {"group:has_watched_area"},
    interval = 10,
    chance = 1,
    catch_up = true,
    action = function(pos, node)
        print("DEBUG: watched area ABM at "..core.pos_to_string(pos))
        if ch_core.is_watched_area_registered(pos) then
            ch_core.extend_watched_area_expiration(pos, 30)
        else
            local ndef = core.registered_nodes[node.name]
            if ndef and ndef.get_watched_area_def then
                ch_core.register_watched_area(pos)
            end
        end
    end,
})

ch_core.close_submod("watched_areas")
