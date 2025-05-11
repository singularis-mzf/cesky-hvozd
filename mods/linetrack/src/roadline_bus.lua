-- linetrack/src/roadline_bus.lua
-- Bus on roads
-- Copyright (C) ?  (c) orwell96 and contributors
-- Copyright (C) 2025  1F616EMO
-- SPDX-License-Identifier: LGPL-2.1-or-later

local S = core.get_translator("linetrack")

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
    drives_on = { roadline = true },
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
    collisionbox = { -2.0, -3.0, -2.0, 2.0, 4.0, 2.0 },
    is_locomotive = true,
    wagon_width = 3,
    drops = { "default:steelblock 4" },
    horn_sound = "linetrack_boat_horn",
    offtrack = S("!!! Bus off road !!!"),
}, S("Bus"), "linetrack_tcb.png")
