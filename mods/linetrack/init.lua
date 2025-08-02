-- linetrack/init.lua
-- Advtrains adoption for boats, buses, etc. that follows a line
-- Copyright (C) ?  orwell96 and contributors
-- Copyright (C) 2025  1F616EMO
-- SPDX-License-Identifier: LGPL-2.1-or-later

ch_base.open_mod(minetest.get_current_modname())

linetrack = {}

local MP = core.get_modpath("linetrack")
for _, name in ipairs({
    "common",

    "waterline",
    "waterline_boat",

    -- "roadline",
    "roadline_bus",

    "interlocking",
    "craft",
}) do
    dofile(MP .. DIR_DELIM .. "src" .. DIR_DELIM .. name .. ".lua")
end

ch_base.close_mod(minetest.get_current_modname())