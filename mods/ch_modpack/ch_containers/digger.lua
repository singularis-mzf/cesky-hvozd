local internal = ...

local queue = {--[[
    [int] = {
        [1] = vector (pos), -- základní pozice
        [2] = int (count), -- počet bloků k vytěžení (směrem dolů)
        [3] = player_name (string), -- jméno postavy, která má těžit
        [4] = int (subtasks_remains), -- zbývajících podúkolů u stejné postavy (používá se pro výpis stavu)
    } or nil, ...
]]}
local queue_begin, queue_end = 1, 1
local player_name_to_hud_id = {}

local hud_def = {
    type = "text",
    position = {x = 0.5, y = 0.5},
    name = "ch_containers:progress",
    text = "0/0",
    z_index = 10,
}

--[[
    player_name = string,
    subtasks = {
        {
            [1] = vector (pos), -- základní pozice pro těžbu
            [2] = int (count), -- počet bloků, které se mají vytěžit směrem dolů
        }...
    },
]]
function internal.add_digtask(player_name, subtasks)
    for i, subtask in ipairs(subtasks) do
        subtask[3] = player_name
        subtask[4] = #subtasks - i
        queue[queue_end] = subtask
        queue_end = queue_end + 1
    end
end

function internal.assembly_subtasks(minp, maxp)
    local result = {}
    local p = vector.new(0, maxp.y, 0)
    local q = vector.new(0, minp.y, 0)
    for x = minp.x, maxp.x do
        p.x = x
        q.x = x
        for z = minp.z, maxp.z do
            p.z = z
            q.z = z
            local free, top = core.line_of_sight(p, q)
            if not free then
                table.insert(result, {top, q.y - top.y + 1})
            end
        end
    end
    if result[1] ~= nil then
        return result
    else
        return nil
    end
end

local function globalstep(dtime)
    local subtask = queue[queue_begin]
    if subtask == nil then
        return -- práce není
    end
    local player_name = subtask[3]
    local player = core.get_player_by_name(player_name)
    if player == nil then
        -- postava není k dispozici
        player_name_to_hud_id[player_name] = nil
        queue[queue_begin] = nil
        queue_begin = queue_begin + 1
        return
    end
    local pos = subtask[1]
    local player_pos = player:get_pos()
    local xdiff = player_pos.x - pos.x
    local ydiff = player_pos.y - pos.y
    local zdiff = player_pos.z - pos.z
    if xdiff * xdiff + ydiff * ydiff + zdiff * zdiff > 65536 then
        -- postava je příliš daleko, zrušit těžbu
        local hud_id = player_name_to_hud_id[player_name]
        if hud_id ~= nil then
            player:hud_remove(hud_id)
            player_name_to_hud_id[player_name] = nil
        end
        repeat
            queue[queue_begin] = nil
            queue_begin = queue_begin + 1
            subtask = queue[queue_begin]
        until subtask == nil or subtask[3] ~= player_name
        return
    end
    local count = subtask[2] - 1
    -- print("subtask ["..queue_begin.."] started: "..core.pos_to_string(pos).."/"..count)
    local y_end = pos.y - count + 1
    local pos_end = vector.new(pos.x, y_end, pos.z)
    core.load_area(pos, pos_end)
    local cache = {}
    local ignore_count, digged_count, not_digged_count = 0, 0, 0
    repeat
        local node = core.get_node_or_nil(pos)
        if node == nil then
            ignore_count = ignore_count + 1
        elseif node.name == "air" then
            -- skip air
        elseif not core.registered_nodes[node.name] then
            -- unknown node!
            core.log("error", "Unknown node "..node.name.." at "..core.pos_to_string(pos).." will be removed!")
            core.remove_node(pos)
        else
            -- print("will dig '"..node.name.."' at "..core.pos_to_string(pos))
            if core.registered_nodes[node.name].on_dig(pos, node, player) then
                digged_count = digged_count + 1
            else
                not_digged_count = not_digged_count + 1
            end
        end
        pos.y = pos.y - 1
    until pos.y < y_end

    local hud_id = player_name_to_hud_id[player_name]
    if subtask[4] <= 0 then
        if hud_id ~= nil then
            player:hud_remove(hud_id)
            player_name_to_hud_id[player_name] = nil
        end
    elseif hud_id ~= nil then
        player:hud_change(hud_id, "text", tostring(subtask[4]))
    else
        local def = table.copy(hud_def)
        def.text = tostring(subtask[4])
        player_name_to_hud_id[player_name] = player:hud_add(def)
    end

    -- print("subtask ["..queue_begin.."] finished: "..digged_count.." digged nodes, "..not_digged_count.." not digged nodes, "..ignore_count.." ignores.")
    queue[queue_begin] = nil
    queue_begin = queue_begin + 1
end

core.register_globalstep(globalstep)
