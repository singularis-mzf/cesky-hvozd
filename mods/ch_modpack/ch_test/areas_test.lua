local hud_def = {
    type = "text",
    position = {x = 0.5, y = 0.5},
    name = "player_area_test",
    alignment = {x = 0, y = 0},
    z_index = -300,
    text = "",
    text2 = "",
    number = 0xFF0000,
    size = {x = 5.0, y = 1},
    style = 5,
}

local function clear_hud(player_name, expected_generation)
    local online_charinfo = ch_core.online_charinfo[player_name]
    local player = minetest.get_player_by_name(player_name)
    if online_charinfo ~= nil and player ~= nil and online_charinfo.ch_areas_test_hud.generation == expected_generation then
        local hud_handle = online_charinfo.ch_areas_test_hud.handle
        player:hud_change(hud_handle, "text", "")
        player:hud_change(hud_handle, "text2", "ab")
    end
end

local function on_player_change_area(player_name, old_areas, new_areas)
    local online_charinfo = ch_core.online_charinfo[player_name]
    local player = minetest.get_player_by_name(player_name)
    if online_charinfo == nil or player == nil then return end
    local hud = online_charinfo.ch_areas_test_hud
    local hud_handle

    if hud == nil then
        -- create a new HUD
        hud_handle = player:hud_add(hud_def)
        hud = {
            handle = hud_handle,
            generation = 1,
        }
        online_charinfo.ch_areas_test_hud = hud
    else
        player:hud_change(hud.handle, "text", new_areas[1].name)
        player:hud_change(hud.handle, "text2", "xy")
        local new_generation = hud.generation + 1
        hud.generation = new_generation
        minetest.after(2, clear_hud, player_name, new_generation)
    end
--[[
    if old_areas ~= nil and old_areas[1].id ~= 0 then
        ch_core.systemovy_kanal(player_name, "[TEST] Opustil/a jste oblast >"..old_areas[1].name.."< ("..new_areas[1].id..")")
    end
    if new_areas[1].id ~= 0 then
        ch_core.systemovy_kanal(player_name, "[TEST] Vstoupil/a jste do oblasti >"..new_areas[1].name.."< ("..new_areas[1].id..")")
    end ]]
end

-- ch_core.register_on_player_change_area(on_player_change_area)
