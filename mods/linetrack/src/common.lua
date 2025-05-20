-- linetracks/src/common.lua
-- Common functions
-- Copyright (C) ?  (c) orwell96 and contributors
-- Copyright (C) 2025  1F616EMO
-- SPDX-License-Identifier: LGPL-2.1-or-later

local S = core.get_translator("linetrack")

core.settings:set_bool("linetracks_use_luaautomation", false) -- do not use luaautomation

for _, mod in ipairs({
    "luaautomation",
    "line_automation",
    "interlocking",
}) do
    linetrack["use_" .. mod] = false

    if core.settings:get_bool("linetracks_use_" .. mod, true) then
        if core.get_modpath("advtrains_" .. mod) then
            linetrack["use_" .. mod] = true
        else
            core.log("warning",
                "[linetracks] " .. mod .. " support requestsed but advtrains_" .. mod .. " is not enabled.")
        end
    end
end

linetrack.register_wagon = advtrains.register_wagon

local function correct_pointed_thing(pointed_thing)
    if pointed_thing.type == "node" then
        local under = pointed_thing.under
        local above = pointed_thing.above
        local debug_under = vector.copy(under)
        local debug_above = vector.copy(above)
        if above.y == under.y + 1 and above.x == under.x and above.z == under.z then
            under.y = above.y
            above.x = under.x - 1
            --[[ print("correct_pointed_thing() upgrade: under = "..core.pos_to_string(debug_under).." => "..core.pos_to_string(under)..
                ", above ="..core.pos_to_string(debug_above).." => "..core.pos_to_string(above)) ]]
        end
    end
    return pointed_thing
end

function linetrack.water_on_place(itemstack, placer, pointed_thing)
    return core.item_place(itemstack, placer, correct_pointed_thing(pointed_thing))
end

if core.global_exists("advtrains_attachment_offset_patch") then
    linetrack.register_wagon = function(name, wagon, ...)
        advtrains_attachment_offset_patch.setup_advtrains_wagon(wagon)
        for _, seat in pairs(wagon.seats) do
            seat.view_offset = nil
        end
        return advtrains.register_wagon(name, wagon, ...)
    end
end

core.register_node("linetrack:invisible_platform", {
    description = S("Invisible Platform"),
    groups = { cracky = 1, not_blocking_trains = 1, platform = 1 },
    drawtype = "airlike",
    inventory_image = "linetrack_invisible_platform.png",
    wield_image = "linetrack_invisible_platform.png",
    walkable = false,
    selection_box = {
        type = "fixed",
        fixed = {
            { -0.5, -0.1, -0.1, 0.5, 0,    0.5 },
            { -0.5, -0.5, 0,    0.5, -0.1, 0.5 }
        },
    },
    paramtype = "light",
    paramtype2 = "4dir",
    sunlight_propagates = true,
    liquids_pointable = true,
    on_place = assert(linetrack.water_on_place),
})

function linetrack.play_object_sound(name, gain, object)
    -- core.sound_play({name = name, gain = gain}, {object = object})
    return core.sound_play({name = name, gain = gain}, {pos = object:get_pos(), max_hear_distance = 128})
end
