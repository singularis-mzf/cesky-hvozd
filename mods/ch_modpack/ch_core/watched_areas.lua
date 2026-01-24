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

local function remove_if_expired(os_time, area_id, area)
    if os_time < area.expire_at then
        return false -- not expired
    else
        core.log("action", "DEBUG: watched area at "..core.pos_to_string(core.get_position_from_hash(area_id)).." expired.")
        areas_for_writing()[area_id] = nil
        return true
    end
end

--[[
    args = {
        min = vector,
        max = vector,
        on_enter, on_leave, on_joinplayer, on_leaveplayer, on_registered = function() or nil,
        state = any,
        ttl = int > 0 or nil, -- default = 300
    }
    -- on_registered({[player_name] = PlayerRef, ...}, state) -- may be called with an empty list
]]
function ch_core.register_watched_area(pos, args)
    local area_id = core.hash_node_position(pos)
    if areas[area_id] ~= nil then
        error("Watched area at "..core.pos_to_string(pos).." is already registered!")
    end
    if args == nil then
        local node = core.get_node(pos)
        local ndef = core.registered_nodes[node.name]
        if ndef == nil or ndef.get_watched_area_def == nil then
            error("ch_core.register_watched_area() called with null args, but the node at "..core.pos_to_string(pos).." ("..node.name..") has no get_watched_area_def() callback!")
        end
        args = assert(ndef.get_watched_area_def(pos))
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
    local area = {min = min, max = max}
    if type(args.on_registered) == "function" then
        area.on_registered = args.on_registered
    end
    if type(args.on_enter) == "function" then
        area.on_enter = args.on_enter
    end
    if type(args.on_leave) == "function" then
        area.on_leave = args.on_leave
    end
    if type(args.on_joinplayer) == "function" then
        area.on_joinplayer = args.on_joinplayer
    end
    if type(args.on_leaveplayer) == "function" then
        area.on_leaveplayer = args.on_leaveplayer
    end
    area.state = args.state
    if type(args.ttl) == "number" and args.ttl >= 1 then
        area.expire_at = os.time() + math.floor(args.ttl)
    else
        area.expire_at = os.time() + 300
    end
    local players_in_area = {}
    area.players = players_in_area
    for player_name, online_charinfo in pairs(ch_data.online_charinfo) do
        if vector.in_area(assert(online_charinfo.wa_last_pos), area.min, area.max) then
            players_in_area[player_name] = assert(online_charinfo.player)
        end
    end
    areas_for_writing()[area_id] = area
    if area.on_registered ~= nil then
        return area.on_registered(area.players, area.state)
    end
    core.log("action", "DEBUG: new watched area "..core.pos_to_string(pos).." registered.")
end

function ch_core.get_players_in_watched_area(pos)
    local area_id = core.hash_node_position(pos)
    local area = areas[area_id]
    local os_time = os.time()
    if area == nil or remove_if_expired(os_time, area_id, area) then
        return nil
    end
    return area.players
end

local function is_watched_area_registered(area_id)
    local area = areas[area_id]
    return area ~= nil and not remove_if_expired(os.time(), area_id, area)
end

function ch_core.is_watched_area_registered(pos)
    return is_watched_area_registered(core.hash_node_position(pos))
end

function ch_core.extend_watched_area_expiration(pos, min_ttl)
    local area_id = core.hash_node_position(pos)
    local t = areas[area_id]
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

function ch_core.unregister_watched_area(pos)
    local area_id = core.hash_node_position(pos)
    if areas[area_id] == nil then
        return false -- not registered
    end
    areas_for_writing()[area_id] = nil
    core.log("action", "DEBUG: Watched area at "..core.pos_to_string(pos).." unregistered.")
    return true
end

local function on_joinplayer(player)
    local online_charinfo = ch_data.get_joining_online_charinfo(player)
    local player_name = assert(online_charinfo.player_name)
    local pos = vector.round(player:get_pos())
    local os_time = os.time()
    online_charinfo.wa_last_pos = pos
    lock_areas()
    for area_id, area in pairs(areas) do
        if not remove_if_expired(os_time, area_id, area) and vector.in_area(pos, area.min, area.max) then
            area.players[player_name] = player
            -- player joined to a watched area
            local f = area.on_joinplayer or area.on_enter
            if f ~= nil then
                f(player, area.state)
            end
        end
    end
    unlock_areas()
end

local function on_leaveplayer(player)
    local player_name = player:get_player_name()
    lock_areas()
    for _, area in pairs(areas) do
        if area.players[player_name] ~= nil then
            area.players[player_name] = nil
            -- player leaved the game inside a watched area
            local f = area.on_leaveplayer or area.on_leave
            if f ~= nil then
                f(player, area.state)
            end
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
    local first_move = true
    local f
    for player_name, online_charinfo in pairs(ch_data.online_charinfo) do
        local player_pos = vector.round(online_charinfo.player:get_pos())
        local last_pos = online_charinfo.wa_last_pos
        if not vector.equals(player_pos, last_pos) then -- if the player moved...

            if first_move then -- if it is the first player who moved in the step, we must check for expired areas
                local os_time = os.time()
                lock_areas()
                for area_id, area in pairs(areas) do
                    remove_if_expired(os_time, area_id, area)
                end
                unlock_areas()
                first_move = false
            end

            lock_areas()
            for _, area in pairs(areas) do
                if vector.in_area(player_pos, area.min, area.max) then
                    -- the player is in the area
                    -- print("DEBUG: TEST: "..player_name.." is in the area")
                    if area.players[player_name] ~= nil then
                        -- the player is was and is in the area
                        f = nil
                    else
                        -- the player was not, but now is in the area (enter)
                        area.players[player_name] = online_charinfo.player
                        f = area.on_enter
                    end
                else
                    -- the player is not in the area
                    -- print("DEBUG: TEST: "..player_name.." is NOT in the area")
                    if area.players[player_name] ~= nil then
                        -- the player was is the area, but not they're not (leave)
                        area.players[player_name] = nil
                        f = area.on_leave
                    else
                        f = nil
                    end
                end
                if f ~= nil then
                    f(online_charinfo.player, area.state) -- call the callback
                end
            end
            unlock_areas()

            -- update wa_last_pos:
            online_charinfo.wa_last_pos = player_pos
        end
    end
end

core.register_globalstep(globalstep)
core.register_on_joinplayer(on_joinplayer)
core.register_on_leaveplayer(on_leaveplayer)

local node_name = "ch_core:watched_areas_test"

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
    groups = {oddly_breakable_by_hand = 1, experimental = 1, has_watched_area = 1},
    on_construct = function(pos)
        ch_core.register_watched_area(pos)
    end,
    on_destruct = function(pos)
        ch_core.unregister_watched_area(pos)
    end,
    get_watched_area_def = function(pos)
        return {
            min = vector.offset(pos, -1, -1, -1),
            max = vector.offset(pos, 1, 1, 1),
            on_registered = function(players, state)
                local s = "Sledovaná oblast okolo "..core.pos_to_string(pos).." zaregistrována s těmito hráči/kami:"
                for pname, _ in pairs(players) do
                    s = s.."\n- "..pname
                end
                core.chat_send_all(s)
            end,
            on_enter = function(player, state)
                core.chat_send_player(player:get_player_name(), "Vstoupil/a jste do sledované oblasti okolo "..core.pos_to_string(pos))
            end,
            on_leave = function(player, state)
                core.chat_send_player(player:get_player_name(), "Opustil/a jste sledovanou oblast okolo "..core.pos_to_string(pos))
            end,
            on_joinplayer = function(player, state)
                core.chat_send_all(player:get_player_name().." se připojil/a do sledované oblasti okolo "..core.pos_to_string(pos))
            end,
            on_leaveplayer = function(player, state)
                core.chat_send_all(player:get_player_name().." se odpojil/a ve sledované oblasti okolo "..core.pos_to_string(pos))
            end,
            ttl = 30,
        }
    end,
})

core.register_lbm({
    label = "Watched areas",
    name = "ch_core:watched_areas",
    nodenames = {"group:has_watched_area"},
    run_at_every_load = true,
    action = function(pos, node, dtime_s)
        if ch_core.is_watched_area_registered(pos) then
            print("DEBUG: LBM called for already registered watched area "..core.pos_to_string(pos))
        else
            local ndef = core.registered_nodes[node.name]
            if ndef and ndef.get_watched_area_def then
                print("DEBUG: LBM will register a new watched area at "..core.pos_to_string(pos))
                ch_core.register_watched_area(pos, ndef.get_watched_area_def(pos))
            end
        end
    end,
})

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
            --[[
            if ch_core.extend_watched_area_expiration(pos, 30) then
                print("Watched area "..core.pos_to_string(pos).." expiration extended.")
            else
                print("Watched area "..core.pos_to_string(pos).." expiration not extended.")
            end
            ]]
        else
            local ndef = core.registered_nodes[node.name]
            if ndef and ndef.get_watched_area_def then
                ch_core.register_watched_area(pos)
            end
        end
    end,
})

ch_core.close_submod("watched_areas")
