-- linetrack/src/waterline_boat.lua
-- Neat and simple boat
-- Copyright (C) ?  (c) orwell96 and contributors
-- Copyright (C) 2025  1F616EMO
-- SPDX-License-Identifier: LGPL-2.1-or-later

local S = core.get_translator("linetrack")

local exhaust_particle_spawner_base = {
    amount = 10,
    time = 0,
    minpos = { x = -1, y = 2.8, z = -3.4 },
    maxpos = { x = -1, y = 2.8, z = -3.4 },
    minvel = { x = -0.2, y = 1.8, z = -0.2 },
    maxvel = { x = 0.2, y = 2, z = 0.2 },
    minacc = { x = 0, y = -0.1, z = 0 },
    maxacc = { x = 0, y = -0.3, z = 0 },
    minexptime = 1,
    maxexptime = 3,
    minsize = 1,
    maxsize = 4,
    collisiondetection = true,
    vertical = false,
    texture = "smoke_puff.png",
}

linetrack.register_wagon("boat", {
    mesh = "linetrack_boat.b3d",
    textures = {
        "doors_door_steel.png",             --y
        "linetrack_steel_tile_dark.png",    --y(exhaust)
        "default_coal_block.png",
        "linetrack_steel_tile_light.png",   --y
        "linetrack_steel_tile_dark.png",
        "linetrack_steel_tile_blue.png",    --y
        "linetrack_diamond_plate_steel_blue.png", --y
        "linetrack_steel_tile_dark.png",    --y(hull)
        "default_wood.png",                 --y
        "linetrack_lifering.png",           --y
        "linetrack_boat_windows.png",
    },
    drives_on = { waterline = true },
    max_speed = 10,
    seats = {
        {
            name = attrans("Driver stand"),
            attach_offset = { x = 6, y = 2, z = 10 },
            view_offset = { x = 6, y = 0, z = 8 },
            group = "dstand",
        },
        {
            name = "1",
            attach_offset = { x = -4, y = 0, z = -4 },
            view_offset = { x = 0, y = 0, z = 0 },
            group = "pass",
        },
        {
            name = "2",
            attach_offset = { x = 4, y = 0, z = -4 },
            view_offset = { x = 0, y = 0, z = 0 },
            group = "pass",
        },
        {
            name = "3",
            attach_offset = { x = -4, y = 0, z = 4 },
            view_offset = { x = 0, y = 0, z = 0 },
            group = "pass",
        },
        {
            name = "4",
            attach_offset = { x = 4, y = 0, z = 4 },
            view_offset = { x = 0, y = 0, z = 0 },
            group = "pass",
        },
        {
            name = "5",
            attach_offset = { x = -4, y = 0, z = -12 },
            view_offset = { x = 0, y = 0, z = 0 },
            group = "pass",
        },
        {
            name = "6",
            attach_offset = { x = 4, y = 0, z = -12 },
            view_offset = { x = 0, y = 0, z = 0 },
            group = "pass",
        },
        {
            name = "7",
            attach_offset = { x = -4, y = 0, z = -20 },
            view_offset = { x = 0, y = 0, z = 0 },
            group = "pass",
        },
        {
            name = "8",
            attach_offset = { x = 4, y = 0, z = -20 },
            view_offset = { x = 0, y = 0, z = 0 },
            group = "pass",
        },
        {
            name = "9",
            attach_offset = { x = -4, y = 0, z = -28 },
            view_offset = { x = 0, y = 0, z = 0 },
            group = "pass",
        },
        {
            name = "10",
            attach_offset = { x = 4, y = 0, z = -28 },
            view_offset = { x = 0, y = 0, z = 0 },
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
            [-1] = { frames = { x = 0, y = 1 }, time = 1 },
            [1] = { frames = { x = 0, y = 1 }, time = 1 },
            sound = "doors_steel_door_open",
        },
        close = {
            [-1] = { frames = { x = 2, y = 3 }, time = 1 },
            [1] = { frames = { x = 2, y = 3 }, time = 1 },
            sound = "doors_steel_door_close",
        }
    },
    assign_to_seat_group = { "pass", "dstand" },
    door_entry = { -3 },
    visual_size = { x = 1, y = 1 },
    wagon_span = 2,
    collisionbox = { -2.0, -3.0, -2.0, 2.0, 4.0, 2.0 },
    is_locomotive = true,
    wagon_width = 5,
    drops = { "default:steelblock 4" },
    horn_sound = "linetrack_boat_horn",
    offtrack = S("!!! Boat off line !!!"),
    custom_on_destroy = function(self)
        if (self.sound_loop_handle) then
            core.sound_stop(self.sound_loop_handle) --don't loop forever D:
        end
        return true
    end,
    custom_on_velocity_change = function(self, velocity, old_velocity)
        if not velocity or not old_velocity then return end
        if old_velocity == 0 and velocity > 0 then
            self.particlespawners = {
                core.add_particlespawner(advtrains.merge_tables(exhaust_particle_spawner_base, {
                    minpos = { x = 1, y = 2.8, z = -3.4 },
                    maxpos = { x = 1, y = 2.9, z = -3.4 },
                    attached = self
                        .object
                })),
                core.add_particlespawner(advtrains.merge_tables(exhaust_particle_spawner_base, {
                    minpos = { x = -1, y = 2.8, z = -3.4 },
                    attached = self.object
                })),
            }
            core.sound_play("linetrack_boat_start", { object = self.object })
            return
        end
        if velocity == 0 then
            if self.sound_loop_handle then
                core.sound_stop(self.sound_loop_handle)
                self.sound_loop_handle = nil
            end
            if self.particlespawners then
                for _, v in pairs(self.particlespawners) do
                    core.delete_particlespawner(v)
                end
            end
            if old_velocity > 0 then
                core.sound_play("linetrack_boat_stop", { object = self.object })
            end
            return
        end
        if self.rev_tmr then
            local delta = core.get_us_time() - self.rev_start
            if delta >= self.rev_tmr then
                self.rev_tmr = nil
                if self.rev_high then
                    core.sound_play({ name = "linetrack_boat_idle_high", gain = 1 }, { object = self.object })
                    self.rev_start = core.get_us_time()
                    self.rev_tmr = 2.8 * 1000000
                else
                    core.sound_play({ name = "linetrack_boat_idle_low", gain = 1 }, { object = self.object })
                    self.rev_start = core.get_us_time()
                    self.rev_tmr = 2.1 * 1000000
                end
            end
        elseif velocity > 0 then
            if velocity ~= old_velocity then
                if old_velocity < 5 and velocity > 5 then
                    core.sound_play({ name = "linetrack_boat_revup", gain = 1 }, { object = self.object })
                    self.rev_start = core.get_us_time()
                    self.rev_tmr = 2813000
                    self.rev_high = true
                elseif old_velocity > 5 and velocity < 5 then
                    core.sound_play({ name = "linetrack_boat_revdown", gain = 1 }, { object = self.object })
                    self.rev_start = core.get_us_time()
                    self.rev_tmr = 373000
                    self.rev_high = false
                end
            elseif self.rev_start and self.rev_tmr and (core.get_us_time() - self.rev_start) >= self.rev_tmr then
                if velocity > 5 then
                    core.sound_play({ name = "linetrack_boat_idle_high", gain = 1 }, { object = self.object })
                    self.rev_start = core.get_us_time()
                    self.rev_tmr = 2.8 * 1000000
                    self.rev_high = true
                else
                    core.sound_play({ name = "linetrack_boat_idle_low", gain = 1 }, { object = self.object })
                    self.rev_start = core.get_us_time()
                    self.rev_tmr = 2.1 * 1000000
                    self.rev_high = false
                end
            end
        end
    end,
}, S("Boat"), "linetrack_boat_inv.png")
