-- linetrack/src/interlocking.lua
-- Interlocking-related stuffs
-- Copyright (C) ?  (c) orwell96 and contributors
-- Copyright (C) 2025  1F616EMO
-- SPDX-License-Identifier: LGPL-2.1-or-later

if not linetrack.use_interlocking then return end

local S = core.get_translator("linetrack")

-- TCBs
do
    local at_tcb = core.registered_nodes["advtrains_interlocking:tcb_node"]

    core.register_node("linetrack:tcb_node", {
        drawtype = "mesh",
        paramtype = "light",
        paramtype2 = "facedir",
        walkable = false,
        mesh = "linetrack_signal.obj",
        tiles = { "linetrack_tcb.png" },
        description = S("Line Circuit Break"),
        sunlight_propagates = true,
        liquids_pointable = true,
        selection_box = {
            type = "fixed",
            fixed = { -5 / 16, -5 / 16, -5 / 16, 5 / 16, 5 / 16, 5 / 16 }
        },
        groups = {
            cracky = 3,
            not_blocking_trains = 1,
            --save_in_at_nodedb=2,
            at_il_track_circuit_break = 1,
        },
        after_place_node = at_tcb.after_place_node,
        on_rightclick = at_tcb.on_rightclick,
        can_dig = at_tcb.can_dig,
        after_dig_node = at_tcb.after_dig_node,
        use_texture_alpha = "blend",
    })

    core.register_node("linetrack:road_tcb_node", {
        drawtype = "nodebox",
        paramtype = "light",
        paramtype2 = "facedir",
        walkable = false,
        tiles = { "linetrack_lane_tcb.png", "linetrack_transparent.png" },
        wield_image = "linetrack_lane_tcb.png",
        inventory_image = "linetrack_lane_tcb.png",
        description = S("Road Circuit Break"),
        sunlight_propagates = true,
        node_box = {
            type = "fixed",
            fixed = { -0.5, -0.5, -0.5, 0.5, -0.49, 0.5 }
        },
        groups = {
            cracky = 3,
            not_blocking_trains = 1,
            --save_in_at_nodedb=2,
            at_il_track_circuit_break = 1,
        },
        after_place_node = at_tcb.after_place_node,
        on_rightclick = at_tcb.on_rightclick,
        can_dig = at_tcb.can_dig,
        after_dig_node = at_tcb.after_dig_node,
        use_texture_alpha = "blend",
    })
end

-- Signals

-- Modified from Munich Signals
local all_sigs = {
    danger = { asp = { main = 0 }, crea = true },           -- halt
    free = { asp = { main = -1, proceed_as_main = true } }, -- free full speed
    slow = { asp = { main = 6, proceed_as_main = true } },  -- slow speed
    shunt = { asp = { main = 0, shunt = true } },           -- shunting
}

local mainaspects = {
    { name = "free",  description = S("Full speed") },
    { name = "slow",  description = S("Reduced Speed") },
    { name = "shunt", description = S("Shunt") },
}

local function applyaspect(loc)
    return function(pos, node, main_aspect)
        local ma_node = main_aspect.name
        if all_sigs[ma_node] and not all_sigs[ma_node].distant then -- luacheck: ignore
            -- ma_node is fine
        elseif main_aspect.halt then
            ma_node = "danger" -- default halt aspect
        else
            ma_node = "free"   -- default free aspect
        end
        advtrains.ndb.swap_node(pos, { name = loc .. ma_node, param2 = node.param2 })
    end
end

for typ, prts in pairs(all_sigs) do
    core.register_node("linetrack:signal_" .. typ, {
        description = S("Generic Main Signal"),
        drawtype = "mesh",
        mesh = "linetrack_signal.obj",
        tiles = { "linetrack_signal_" .. typ .. ".png" },
        selection_box = {
            type = "fixed",
            fixed = { -5 / 16, -5 / 16, -5 / 16, 5 / 16, 5 / 16, 5 / 16 }
        },

        paramtype = "light",
        sunlight_propagates = true,
        light_source = 4,
        walkable = false,
        liquids_pointable = true,

        groups = {
            cracky = 2,
            advtrains_signal = 2,
            not_blocking_trains = 1,
            save_in_at_nodedb = 1,
            not_in_creative_inventory = prts.crea and 0 or 1,
        },
        drop = "linetrack:signal_danger",
        inventory_image = "linetrack_signal_danger.png",
        on_rightclick = advtrains.interlocking.signal.on_rightclick,
        can_dig = advtrains.interlocking.signal.can_dig,
        after_dig_node = advtrains.interlocking.signal.after_dig,
        -- new signal API
        advtrains = {
            main_aspects = mainaspects,
            apply_aspect = applyaspect("linetrack:signal_"),
            pure_distant = false,
            get_aspect_info = function() return prts.asp end,
            route_role = "main"
        },
        use_texture_alpha = "blend",
    })

    core.register_node("linetrack:road_signal_" .. typ, {
        description = S("Road Main Signal"),
        drawtype = "nodebox",
        tiles = { "linetrack_lane_" .. typ .. ".png", "linetrack_transparent.png" },
        node_box = {
            type = "fixed",
            fixed = { -0.5, -0.5, -0.5, 0.5, -0.49, 0.5 }
        },

        paramtype = "light",
        paramtype2 = "facedir",
        sunlight_propagates = true,
        walkable = false,

        groups = {
            cracky = 2,
            advtrains_signal = 2,
            not_blocking_trains = 1,
            save_in_at_nodedb = 1,
            not_in_creative_inventory = prts.crea and 0 or 1,
        },
        drop = "linetrack:road_signal_danger",
        inventory_image = "linetrack_lane_danger.png",
        on_rightclick = advtrains.interlocking.signal.on_rightclick,
        can_dig = advtrains.interlocking.signal.can_dig,
        after_dig_node = advtrains.interlocking.signal.after_dig,
        -- new signal API
        advtrains = {
            main_aspects = mainaspects,
            apply_aspect = applyaspect("linetrack:road_signal_"),
            pure_distant = false,
            get_aspect_info = function() return prts.asp end,
            route_role = "main"
        },
        use_texture_alpha = "blend",
    })
end
