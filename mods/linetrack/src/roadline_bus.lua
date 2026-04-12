-- linetrack/src/roadline_bus.lua
-- Bus on roads
-- Copyright (C) ?  (c) orwell96 and contributors
-- Copyright (C) 2025  1F616EMO
-- SPDX-License-Identifier: LGPL-2.1-or-later

local S = core.get_translator("linetrack")
local function play_object_sound(name, gain, object)
    local s = {name = name, gain = gain}
    local opos = object:get_pos()
    local result = {}
    for _, player in ipairs(core.get_connected_players()) do
        if vector.distance(player:get_pos(), opos) < 128 then
            local handle = core.sound_play(s, {to_player = player:get_player_name(), max_hear_distance = 128})
            table.insert(result, handle)
        end
    end
    return result
end
-- (name, gain, object)

local function stop_sound(handles)
    for _, handle in ipairs(handles) do
        core.sound_stop(handle)
    end
end

-- play_object_sound("linetrack_bus3", 1.0, self.object)

linetrack.register_wagon("bus", {
    mesh = "linetrack_bus.b3d",
    textures = {
        "linetrack_bus.png",
        "linetrack_bus_body.png",
        "linetrack_bus_bumper.png",
        "linetrack_light_red.png",
        "linetrack_bus_light_white.png",
        "linetrack_bus_light_yellow.png",
        "linetrack_bus_windows.png"
    },
    drives_on = { default = true },
    max_speed = 15,
    seats = {
        {
            name = attrans("Driver stand"),
            attach_offset = { x = -5, y = 0, z = 19 },
            view_offset = { x = -5, y = 0, z = 19 },
            group = "dstand",
        },
        {
            name = "1",
            attach_offset = { x = -5, y = 0, z = -4 },
            view_offset = { x = -5, y = 0, z = -4 },
            group = "pass",
        },
        {
            name = "2",
            attach_offset = { x = 5, y = 0, z = -4 },
            view_offset = { x = 5, y = 0, z = -4 },
            group = "pass",
        },
        {
            name = "3",
            attach_offset = { x = -5, y = 0, z = -14 },
            view_offset = { x = -5, y = 0, z = -14 },
            group = "pass",
        },
        {
            name = "4",
            attach_offset = { x = 5, y = 0, z = -14 },
            view_offset = { x = 5, y = 0, z = -14 },
            group = "pass",
        },
        {
            name = "5",
            attach_offset = { x = -5, y = 0, z = -24 },
            view_offset = { x = -5, y = 0, z = -24 },
            group = "pass",
        },
        {
            name = "6",
            attach_offset = { x = 5, y = 0, z = -24 },
            view_offset = { x = 5, y = 0, z = -24 },
            group = "pass",
        },
    },
    seat_groups = {
        dstand = {
            name = attrans("Driver Stand"),
            access_to = { "pass" },
            require_doors_open = true,
            driving_ctrl_access = true,
        },
        pass = {
            name = attrans("Passenger area"),
            access_to = { "dstand" },
            require_doors_open = true,
        },
    },
    doors = {
        open = {
            [-1] = { frames = { x = 2, y = 20 }, time = 1 },
            [1] = { frames = { x = 2, y = 20 }, time = 1 },
            sound = "advtrains_subway_dopen",
        },
        close = {
            [-1] = { frames = { x = 20, y = 38 }, time = 1 },
            [1] = { frames = { x = 20, y = 38 }, time = 1 },
            sound = "advtrains_subway_dclose",
        }
    },
    assign_to_seat_group = { "pass", "dstand" },
    door_entry = { -1, 1 },
    visual_size = { x = 1, y = 1, z = 1 },
    use_texture_alpha = true,
    backface_culling = false,
    wagon_span = 3,
    light_level = 10,
    collisionbox = { -2.0, -3.0, -2.0, 2.0, 4.0, 2.0 },
    is_locomotive = true,
    wagon_width = 3,
    drops = {
        "default:steel_ingot 5",
        "minitram_crafting_recipes:minitram_door",
        "technic:rubber 2"
    },
    horn_sound = "linetrack_boat_horn",
    offtrack = S("!!! Bus off road !!!"),
    --[[
    custom_on_destroy = function(self)
        if (self.sound_loop_handle) then
            core.sound_stop(self.sound_loop_handle) --don't loop forever D:
        end
        return true
    end, ]]
    custom_on_velocity_change = function(self, velocity, old_velocity)
        if not velocity or not old_velocity then return end
        local now = core.get_us_time()
        local guid = self.object:get_guid()
        local gain = velocity / 15.9
        if gain > 1.0 then
            gain = 1.0
        end
        -- print("DEBUG: object "..guid.." is valid: "..(self.object:is_valid() and "true" or "false"))
        if old_velocity == 0 and velocity > 0 then
            -- print("DEBUG:"..guid..": Will play sound, because old=0, vel>0("..velocity..")")
            self.sound_loop_handle = play_object_sound("linetrack_bus", gain, self.object)
            self.sound_start = now
            self.sound_end = now + 2000000
            return
        end
        if velocity == 0 then
            if self.sound_loop_handle then
                -- print("DEBUG:"..guid..": Will stop sound, because vel=0")
                stop_sound(self.sound_loop_handle)
                self.sound_loop_handle = nil
                self.sound_start = nil
                self.sound_end = nil
            end
            --[[ if old_velocity > 0 then
                play_object_sound("linetrack_bus", 0.8, self.object)
            end ]]
            return
        elseif self.sound_end ~= nil and now >= self.sound_end then
            -- print("DEBUG:"..guid..": Will play sound, because vel~=0("..velocity..") and sound_end has expired (old="..old_velocity..")")
            self.sound_loop_handle = play_object_sound("linetrack_bus", gain, self.object)
            self.sound_start = now
            self.sound_end = now + 2000000
            return
        end
        --[[
        if self.rev_tmr then
            local delta = core.get_us_time() - self.rev_start
            if delta >= self.rev_tmr then
                self.rev_tmr = nil
                if self.rev_high then
                    play_object_sound("linetrack_boat_idle_high", 1.0, self.object)
                    self.rev_start = core.get_us_time()
                    self.rev_tmr = 2.8 * 1000000
                else
                    play_object_sound("linetrack_boat_idle_low", 1.0, self.object)
                    self.rev_start = core.get_us_time()
                    self.rev_tmr = 2.1 * 1000000
                end
            end
        elseif velocity > 0 then
            if velocity ~= old_velocity then
                if old_velocity < 5 and velocity > 5 then
                    play_object_sound("linetrack_boat_revup", 1.0, self.object)
                    self.rev_start = core.get_us_time()
                    self.rev_tmr = 2813000
                    self.rev_high = true
                elseif old_velocity > 5 and velocity < 5 then
                    play_object_sound("linetrack_boat_revdown", 1.0, self.object)
                    self.rev_start = core.get_us_time()
                    self.rev_tmr = 373000
                    self.rev_high = false
                end
            elseif self.rev_start and self.rev_tmr and (core.get_us_time() - self.rev_start) >= self.rev_tmr then
                if velocity > 5 then
                    play_object_sound("linetrack_boat_idle_high", 1.0, self.object)
                    self.rev_start = core.get_us_time()
                    self.rev_tmr = 2.8 * 1000000
                    self.rev_high = true
                else
                    play_object_sound("linetrack_boat_idle_low", 1.0, self.object)
                    self.rev_start = core.get_us_time()
                    self.rev_tmr = 2.1 * 1000000
                    self.rev_high = false
                end
            end
        end]]
    end,


}, S("Bus"), "linetrack_tcb.png")
