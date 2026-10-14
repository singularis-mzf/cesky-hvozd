local suspend_autoopen = {} -- hash => expiration time

local function on_player_moved(player, player_name, old_pos, new_pos)
    local offline_charinfo = ch_data.offline_charinfo[player_name]
    if offline_charinfo == nil or offline_charinfo.otevirat_dvere == 0 then
        return
    end
    local ray_begin = vector.offset(old_pos, 0, 0.5, 0)
    local ray_end = vector.add(ray_begin, vector.multiply(vector.direction(old_pos, new_pos), 3))
    local ray = core.raycast(ray_begin, ray_end, false, false)
    local pointed_thing = ray:next()
    if pointed_thing ~= nil and pointed_thing.type == "node" then
        local door_pos = vector.round(pointed_thing.under)
        local door_node = core.get_node(door_pos)
        local door_name = door_node.name
        if doors.registered_doors[door_name] or doors.registered_custom_doors[door_name] or doors.registered_fencegates[door_name] then
            local ndef = core.registered_nodes[door_node.name]
            local handle = doors.get(door_pos)
            if ndef ~= nil and handle ~= nil then
                -- door found!
                local hash = core.hash_node_position(door_pos)
                local os_time = os.time()
                local suspend_time = suspend_autoopen[hash]
                if suspend_time ~= nil then
                    if suspend_time >= os_time then
                        return -- no autoopen, because suspended
                    else
                        suspend_autoopen[hash] = nil -- suspend expired
                    end
                end
                local meta = core.get_meta(door_pos)
                -- Podmínky automatického otevírání:
                -- 0. podporováno jen pro standardní dveře, "custom" dveře a branky v plotech; ne pro padací dveře
                -- 1. dveře musejí být zavřené
                -- 2. nesmí být zakázáno jejich samootevírání
                -- 3. nesmí být soukromé
                -- 4. nesmí být hotelové
                if not handle:state() and meta:get_int("zakotsam") == 0 and meta:get_string("owner") == "" and meta:get_int("hes") == 0 then
                    -- try to open...
                    doors.door_rightclick(door_pos, door_node, player, ItemStack(), pointed_thing)
                    suspend_autoopen[hash] = os_time + 3 -- suspend for 3 seconds
                end
            end
        end
    end
end

ch_core.register_on_player_moved(on_player_moved)
