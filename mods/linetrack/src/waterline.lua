-- linetrack/src/waterline.lua
-- Water lines for boats
-- Copyright (C) ?  (c) orwell96 and contributors
-- Copyright (C) 2025  1F616EMO
-- SPDX-License-Identifier: LGPL-2.1-or-later

local S = core.get_translator("linetrack")

local _ch_map_color = 0x777b7f

-- Require patch to work
-- Patch: Allow using def.suitable_substrate to override default substrate detection
-- https://lists.sr.ht/~gpcf/advtrains-devel/patches/58713
local function suitable_substrate(upos)
    local node_name = core.get_node(upos).name
    local node_def = core.registered_nodes[node_name]
    return node_def ~= nil and node_def.walkable or (node_def.liquidtype == "source" or node_def.liquidtype == "flowing")
end

advtrains.register_tracks("default", {
    nodename_prefix = "linetrack:watertrack",
    texture_prefix = "advtrains_ltrack",
    models_prefix = "advtrains_ltrack",
    models_suffix = ".obj",
    shared_texture = "linetrack_line.png",
    description = S("Water Line Track"),
    formats = {},
    suitable_substrate = suitable_substrate,
    get_additional_definiton = function()
        return {
            groups = {
                advtrains_track = 1,
                advtrains_track_waterline = 1,
                save_in_at_nodedb = 1,
                dig_immediate = 2,
                not_in_creative_inventory = 1,
                not_blocking_trains = 1,
            },
            use_texture_alpha = "blend",
            _ch_map_color = _ch_map_color,
        }
    end
}, advtrains.ap.t_30deg_flat)

local empty_table = {}

advtrains.register_tracks("default", {
    nodename_prefix = "linetrack:watertrack",
    texture_prefix = "advtrains_ltrack",
    models_prefix = "advtrains_ltrack",
    models_suffix = ".obj",
    shared_texture = "linetrack_line.png",
    description = S("Water Line Track"),
    formats = {
        vst1 = { true, false, true },
        vst2 = { true, false, true },
        vst31 = { true },
        vst32 = { true },
        vst33 = { true },
        vst41 = empty_table, vst42 = empty_table, vst43 = empty_table, vst44 = empty_table,
        vst51 = empty_table, vst52 = empty_table, vst53 = empty_table, vst54 = empty_table, vst55 = empty_table,
        vst61 = empty_table, vst62 = empty_table, vst63 = empty_table, vst64 = empty_table, vst65 = empty_table, vst66 = empty_table,
        vst71 = empty_table, vst72 = empty_table, vst73 = empty_table, vst74 = empty_table, vst75 = empty_table, vst76 = empty_table, vst77 = empty_table,
        vst81 = empty_table, vst82 = empty_table, vst83 = empty_table, vst84 = empty_table, vst85 = empty_table, vst86 = empty_table, vst87 = empty_table, vst88 = empty_table,
    },
    suitable_substrate = suitable_substrate,
    get_additional_definiton = function()
        return {
            liquids_pointable = true,
            groups = {
                advtrains_track = 1,
                advtrains_track_waterline = 1,
                save_in_at_nodedb = 1,
                dig_immediate = 2,
                not_in_creative_inventory = 1,
                not_blocking_trains = 1,
            },
            use_texture_alpha = "blend",
            _ch_map_color = _ch_map_color,
        }
    end
}, advtrains.ap.t_30deg_slope)

advtrains.register_tracks("default", {
    nodename_prefix = "linetrack:watertrack_atc",
    texture_prefix = "advtrains_ltrack_atc",
    models_prefix = "advtrains_ltrack",
    models_suffix = ".obj",
    shared_texture = "linetrack_atc.png",
    description = S("ATC controller Water Line Track"),
    formats = {},
    get_additional_definiton = advtrains.atc_function,
    suitable_substrate = suitable_substrate,
}, advtrains.trackpresets.t_30deg_straightonly)

if linetrack.use_luaautomation then
    local lua_rail_def = core.registered_nodes["advtrains_luaautomation:dtrack_st"]

    advtrains.register_tracks("default", {
        nodename_prefix = "linetrack:watertrack_lua",
        texture_prefix = "advtrains_ltrack_lua",
        models_prefix = "advtrains_ltrack",
        models_suffix = ".obj",
        shared_texture = "linetrack_lua.png",
        description = S("LuaAutomation Water Line Track"),
        formats = {},
        suitable_substrate = suitable_substrate,
        get_additional_definiton = function()
            return {
                after_place_node = lua_rail_def.after_place_node,
                after_dig_node = lua_rail_def.after_dig_node,
                on_receive_fields = lua_rail_def.on_receive_fields,
                advtrains = {
                    on_train_enter = lua_rail_def.advtrains.on_train_enter,
                    on_train_approach = lua_rail_def.advtrains.on_train_approach,
                    on_train_leave = stn_rail_def.advtrains.on_train_leave,
                },
                luaautomation = lua_rail_def.luaautomation,
                digiline = lua_rail_def.digiline,

                groups = {
                    advtrains_track = 1,
                    advtrains_track_waterline = 1,
                    save_in_at_nodedb = 1,
                    dig_immediate = 2,
                    not_in_creative_inventory = 1,
                    not_blocking_trains = 1,
                },
                use_texture_alpha = "blend",
                _ch_map_color = _ch_map_color,
            }
        end
    }, advtrains.trackpresets.t_30deg_straightonly)
end

if linetrack.use_line_automation then
    local stn_rail_def = core.registered_nodes["advtrains_line_automation:dtrack_stop_st"]
    advtrains.register_tracks("default", {
        nodename_prefix = "linetrack:watertrack_stn",
        texture_prefix = "advtrains_ltrack_stn",
        models_prefix = "advtrains_ltrack",
        models_suffix = ".obj",
        shared_texture = "linetrack_stn.png",
        description = S("Station/Stop Water Line Track"),
        formats = {},
        suitable_substrate = suitable_substrate,
        get_additional_definiton = function()
            return {
                after_place_node = stn_rail_def.after_place_node,
                after_dig_node = stn_rail_def.after_dig_node,
                on_rightclick = stn_rail_def.on_rightclick,
                advtrains = {
                    on_train_enter = stn_rail_def.advtrains.on_train_enter,
                    on_train_approach = stn_rail_def.advtrains.on_train_approach,
                    on_train_leave = stn_rail_def.advtrains.on_train_leave,
                },

                groups = {
                    advtrains_track = 1,
                    advtrains_track_waterline = 1,
                    save_in_at_nodedb = 1,
                    dig_immediate = 2,
                    not_in_creative_inventory = 1,
                    not_blocking_trains = 1,
                },
                use_texture_alpha = "blend",
                _ch_map_color = _ch_map_color,
            }
        end
    }, advtrains.trackpresets.t_30deg_straightonly)
end

if linetrack.use_interlocking then
    local spd_rail_def = core.registered_nodes["advtrains_interlocking:dtrack_npr_st"]
    advtrains.register_tracks("default", {
        nodename_prefix = "linetrack:watertrack_spd",
        texture_prefix = "advtrains_ltrack_spd",
        models_prefix = "advtrains_ltrack",
        models_suffix = ".obj",
        shared_texture = "linetrack_stn.png",
        description = S("Point Speed Restriction Water Line Track"),
        formats = {},
        suitable_substrate = suitable_substrate,
        get_additional_definiton = function()
            return {
                after_place_node = spd_rail_def.after_place_node,
                after_dig_node = spd_rail_def.after_dig_node,
                on_receive_fields = spd_rail_def.on_receive_fields,
                advtrains = {
                    on_train_approach = spd_rail_def.advtrains.on_train_approach,
                },

                groups = {
                    advtrains_track = 1,
                    advtrains_track_waterline = 1,
                    save_in_at_nodedb = 1,
                    dig_immediate = 2,
                    not_in_creative_inventory = 1,
                    not_blocking_trains = 1,
                },
                use_texture_alpha = "blend",
                _ch_map_color = _ch_map_color,
            }
        end
    }, advtrains.trackpresets.t_30deg_straightonly)
end

for _, name in ipairs({
    "linetrack:watertrack_placer",
    "linetrack:watertrack_slopeplacer",
    "linetrack:watertrack_atc_placer",
    "linetrack:watertrack_lua_placer",
    "linetrack:watertrack_stn_placer",
    "linetrack:watertrack_spd_placer",
}) do
    if core.registered_items[name] ~= nil then
        core.override_item(name, {
            liquids_pointable = true,
        })
    end
end
