-- linetrack/src/roadline.lua
-- Road lines for buses on various surfaces
-- Copyright (C) ?  (c) orwell96 and contributors
-- Copyright (C) 2025  1F616EMO
-- SPDX-License-Identifier: LGPL-2.1-or-later

local S = core.get_translator("linetrack")

-- Just lines, no surface (i.e. not slope/slab)

advtrains.register_tracks("roadline", {
    nodename_prefix = "linetrack:roadtrack",
    texture_prefix = "advtrains_rtrack",
    models_prefix = "advtrains_ltrack",
    models_suffix = ".obj",
    shared_texture = "linetrack_road_line.png",
    description = S("Road Line Track"),
    formats = {},
    get_additional_definiton = function()
        return {
            groups = {
                advtrains_track = 1,
                advtrains_track_roadline = 1,
                save_in_at_nodedb = 1,
                dig_immediate = 2,
                not_in_creative_inventory = 1,
                not_blocking_trains = 1,
            },
            use_texture_alpha = "blend",
        }
    end
}, advtrains.ap.t_30deg_flat)

advtrains.register_tracks("roadline", {
    nodename_prefix = "linetrack:roadtrack_atc",
    texture_prefix = "advtrains_rtrack_atc",
    models_prefix = "advtrains_ltrack",
    models_suffix = ".obj",
    shared_texture = "linetrack_atc.png",
    description = S("ATC controller Road Line Track"),
    formats = {},
    get_additional_definiton = advtrains.atc_function
}, advtrains.trackpresets.t_30deg_straightonly)

if linetrack.use_luaautomation then
    local lua_rail_def = core.registered_nodes["advtrains_luaautomation:dtrack_st"]

    advtrains.register_tracks("roadline", {
        nodename_prefix = "linetrack:roadtrack_lua",
        texture_prefix = "advtrains_rtrack_lua",
        models_prefix = "advtrains_ltrack",
        models_suffix = ".obj",
        shared_texture = "linetrack_road_lua.png",
        description = S("LuaAutomation Road Line Track"),
        formats = {},
        get_additional_definiton = function()
            return {
                after_place_node = lua_rail_def.after_place_node,
                after_dig_node = lua_rail_def.after_dig_node,
                on_receive_fields = lua_rail_def.on_receive_fields,
                advtrains = {
                    on_train_enter = lua_rail_def.advtrains.on_train_enter,
                    on_train_approach = lua_rail_def.advtrains.on_train_approach,
                },
                luaautomation = lua_rail_def.luaautomation,
                digiline = lua_rail_def.digiline,

                groups = {
                    advtrains_track = 1,
                    advtrains_track_roadline = 1,
                    save_in_at_nodedb = 1,
                    dig_immediate = 2,
                    not_in_creative_inventory = 1,
                    not_blocking_trains = 1,
                },
                use_texture_alpha = "blend",
            }
        end
    }, advtrains.trackpresets.t_30deg_straightonly)
end

if linetrack.use_line_automation then
    local stn_rail_def = core.registered_nodes["advtrains_line_automation:dtrack_stop_st"]
    advtrains.register_tracks("roadline", {
        nodename_prefix = "linetrack:roadtrack_stn",
        texture_prefix = "advtrains_rtrack_stn",
        models_prefix = "advtrains_ltrack",
        models_suffix = ".obj",
        shared_texture = "linetrack_road_stn.png",
        description = S("Station/Stop Road Line Track"),
        formats = {},
        get_additional_definiton = function()
            return {
                after_place_node = stn_rail_def.after_place_node,
                after_dig_node = stn_rail_def.after_dig_node,
                on_rightclick = stn_rail_def.on_rightclick,
                advtrains = {
                    on_train_enter = stn_rail_def.advtrains.on_train_enter,
                    on_train_approach = stn_rail_def.advtrains.on_train_approach,
                },

                groups = {
                    advtrains_track = 1,
                    advtrains_track_roadline = 1,
                    save_in_at_nodedb = 1,
                    dig_immediate = 2,
                    not_in_creative_inventory = 1,
                    not_blocking_trains = 1,
                },
                use_texture_alpha = "blend",
            }
        end
    }, advtrains.trackpresets.t_30deg_straightonly)
end

if linetrack.use_interlocking then
    local spd_rail_def = core.registered_nodes["advtrains_interlocking:dtrack_npr_st"]
    advtrains.register_tracks("roadline", {
        nodename_prefix = "linetrack:roadtrack_spd",
        texture_prefix = "advtrains_rtrack_spd",
        models_prefix = "advtrains_rtracks",
        models_suffix = ".obj",
        shared_texture = "linetrack_road_spd.png",
        description = S("Point Speed Restriction Road Line Track"),
        formats = {},
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
            }
        end
    }, advtrains.trackpresets.t_30deg_straightonly)
end

-- Slabs and slopes

local function conns(c1, c2, r1, r2) return { { c = c1, y = r1 }, { c = c2, y = r2 } } end

local slab_preset = {
    v25_format = true,
    regstep = 1,
    variant = {
        st = {
            conns = conns(0, 8, 0.5, 0.5),
            rail_y = 0.5,
            desc = ("straight (slab)"),
            tpdouble = true,
            tpsingle = true,
            trackworker = "cr",
        },
        cr = {
            conns = conns(0, 7, 0.5, 0.5),
            rail_y = 0.5,
            desc = "curve (slab)",
            tpdouble = true,
            trackworker = "st",
        },
    },
    regtp = true,
    tpdefault = "st",
    trackworker = {},
    rotation = { "", "_30", "_45", "_60" },
}

local slope1_preset = {
    v25_format = true,
    regstep = 1,
    variant = {
        vst1 = {
            -- conns = conns(8, 0, 0, 0.5),
            -- rail_y = 0.25,
            -- desc = "slope (lower)",
            -- tpdouble = true,
            -- tpsingle = true,
            -- trackworker = "vst1",
            conns = conns(8, 0, 0, 0.5),
            rail_y = 0.25,
            desc = "steep uphill 1/2",
            slope = true
        },
    },
    regtp = true,
    tpdefault = "vst1",
    trackworker = {},
    rotation = { "" },
}

local slope2_preset = {
    v25_format = true,
    regstep = 1,
    variant = {
        vst2 = {
            -- conns = conns(8, 0, 0.5, 1),
            -- rail_y = 0.75,
            -- desc = "slope (lower)",
            -- tpdouble = true,
            -- tpsingle = true,
            -- trackworker = "vst2",
            conns = conns(8, 0, 0.5, 1),
            rail_y = 0.75,
            desc = "steep uphill 2/2",
            slope = true
        },
    },
    regtp = true,
    tpdefault = "vst2",
    trackworker = {},
    rotation = { "" },
}

function linetrack.regiser_roadline_for_surface(surface_name, display_name, texture)
    -- Compactibility hack
    if surface_name == "bakedclay_black" then
        surface_name = ""

        core.register_alias("linetrack:roadtrack_slope1_bakedclay_black_placer", "linetrack:roadtrack_slope1_placer")
        core.register_alias("linetrack:roadtrack_slope2_bakedclay_black_placer", "linetrack:roadtrack_slope2_placer")
        core.register_alias("linetrack:roadtrack_slab_bakedclay_black_placer", "linetrack:roadtrack_slab_placer")
        --[[
        core.register_alias("linetrack:roadtrack_slab_lua_bakedclay_black_placer",
            "linetrack:roadtrack_slab_lua_placer")
        core.register_alias("linetrack:roadtrack_slab_stn_bakedclay_black_placer",
            "linetrack:roadtrack_slab_stn_placer")
        core.register_alias("linetrack:roadtrack_slab_spd_bakedclay_black_placer",
            "linetrack:roadtrack_slab_spd_placer")
        ]]
    else
        surface_name = "_" .. surface_name
    end

    advtrains.register_tracks("roadline", {
        nodename_prefix = "linetrack:roadtrack_slope1" .. surface_name,
        texture_prefix = "linetrack_road_slope1",
        models_prefix = "advtrains_rtrack",
        models_suffix = ".obj",
        shared_texture = "[combine:32x16:0,0=" .. texture .. ":16,0=linetrack_road_line.png:",
        description = S("Road Line Track Slope on @1 (lower)", display_name),
        formats = {},
        get_additional_definiton = function()
            return {
                groups = {
                    advtrains_track = 1,
                    advtrains_track_roadline = 1,
                    save_in_at_nodedb = 1,
                    dig_immediate = 2,
                    not_in_creative_inventory = 1,
                    not_blocking_trains = 1,
                },
                node_box = {
                    type = "fixed",
                    fixed = {
                        { -0.5, -0.5,   -0.5,  0.5, -0.375, 0.5 },
                        { -0.5, -0.375, -0.25, 0.5, -0.25,  0.5 },
                        { -0.5, -0.25,  0,     0.5, -0.125, 0.5 },
                        { -0.5, -0.125, 0.25,  0.5, 0,      0.5 },
                    }
                },
                use_texture_alpha = "blend",
                walkable = true,
            }
        end
    }, slope1_preset)

    core.override_item("linetrack:roadtrack_slope1" .. surface_name .. "_placer", {
        inventory_image = "linetrack_road_slope1_placer.png^[mask:" .. texture
    })

    advtrains.register_tracks("roadline", {
        nodename_prefix = "linetrack:roadtrack_slope2" .. surface_name,
        texture_prefix = "linetrack_road_slope2",
        models_prefix = "advtrains_rtrack",
        models_suffix = ".obj",
        shared_texture = "[combine:32x16:0,0=" .. texture .. ":16,0=linetrack_road_line.png:",
        description = S("Road Line Track Slope on @1 (upper)", display_name),
        formats = {},
        get_additional_definiton = function()
            return {
                groups = {
                    advtrains_track = 1,
                    advtrains_track_roadline = 1,
                    save_in_at_nodedb = 1,
                    dig_immediate = 2,
                    not_in_creative_inventory = 1,
                    not_blocking_trains = 1,
                },
                node_box = {
                    type = "fixed",
                    fixed = {
                        { -0.5, -0.5,  -0.5,  0.5, 0.125, 0.5 },
                        { -0.5, 0.125, -0.25, 0.5, 0.25,  0.5 },
                        { -0.5, 0.25,  0,     0.5, 0.375, 0.5 },
                        { -0.5, 0.375, 0.25,  0.5, 0.5,   0.5 },
                    }
                },
                use_texture_alpha = "blend",
                walkable = true,
            }
        end
    }, slope2_preset)

    core.override_item("linetrack:roadtrack_slope2" .. surface_name .. "_placer", {
        inventory_image = "linetrack_road_slope2_placer.png^[mask:" .. texture
    })

    advtrains.register_tracks("roadline", {
        nodename_prefix = "linetrack:roadtrack_slab" .. surface_name,
        texture_prefix = "linetrack_road_slab",
        models_prefix = "advtrains_rtracks",
        models_suffix = ".obj",
        shared_texture = "[combine:32x16:0,0=" .. texture .. ":16,0=linetrack_road_line.png:",
        description = S("Road Line Track Slab on @1", display_name),
        formats = {},
        get_additional_definiton = function()
            return {
                groups = {
                    advtrains_track = 1,
                    advtrains_track_roadline = 1,
                    save_in_at_nodedb = 1,
                    dig_immediate = 2,
                    not_in_creative_inventory = 1,
                    not_blocking_trains = 1,
                },
                node_box = {
                    type = "fixed",
                    fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 },
                },
                use_texture_alpha = "blend",
                walkable = true,
            }
        end
    }, slab_preset)

    core.override_item("linetrack:roadtrack_slab" .. surface_name .. "_placer", {
        inventory_image = "linetrack_road_slab_placer.png^[mask:" .. texture
    })

    advtrains.register_tracks("roadline", {
        nodename_prefix = "linetrack:roadtrack_slab_atc" .. surface_name,
        texture_prefix = "linetrack_road_slab",
        models_prefix = "advtrains_ltrack",
        models_suffix = ".obj",
        shared_texture = "linetrack_atc.png",
        description = S("Road Line Track Slab ATC Controller on @1", display_name),
        formats = {},
        get_additional_definiton = advtrains.atc_function
    }, advtrains.trackpresets.t_30deg_straightonly)

    core.override_item("linetrack:roadtrack_slab_atc" .. surface_name .. "_placer", {
        inventory_image = "linetrack_road_slab_placer.png^[mask:" .. texture .. "^advtrains_rtrack_atc_placer.png"
    })

    -- Special tracks for slab

    -- TODO: Approach callbacks seems not working on slabs
    --[[
    if linetrack.use_luaautomation then
        local lua_rail_def = core.registered_nodes["advtrains_luaautomation:dtrack_st"]
        advtrains.register_tracks("roadline", {
            nodename_prefix = "linetrack:roadtrack_slab_lua" .. surface_name,
            texture_prefix = "linetrack_road_slab",
            models_prefix = "advtrains_rtracks",
            models_suffix = ".obj",
            shared_texture = "[combine:32x16:0,0=" .. texture .. ":16,0=linetrack_road_lua.png:",
            description = S("LuaAutomation Road Line Track Slab on @1", display_name),
            formats = {},
            get_additional_definiton = function()
                return {
                    after_place_node = lua_rail_def.after_place_node,
                    after_dig_node = lua_rail_def.after_dig_node,
                    on_receive_fields = lua_rail_def.on_receive_fields,
                    advtrains = {
                        on_train_enter = lua_rail_def.advtrains.on_train_enter,
                        on_train_approach = lua_rail_def.advtrains.on_train_approach,
                    },
                    luaautomation = lua_rail_def.luaautomation,
                    digiline = lua_rail_def.digiline,

                    groups = {
                        advtrains_track = 1,
                        advtrains_track_roadline = 1,
                        save_in_at_nodedb = 1,
                        dig_immediate = 2,
                        not_in_creative_inventory = 1,
                        not_blocking_trains = 1,
                    },
                    node_box = {
                        type = "fixed",
                        fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 },
                    },
                    use_texture_alpha = "blend",
                    walkable = true,
                }
            end
        }, slab_preset)
    end

    if linetrack.use_line_automation then
        local stn_rail_def = core.registered_nodes["advtrains_line_automation:dtrack_stop_st"]
        advtrains.register_tracks("roadline", {
            nodename_prefix = "linetrack:roadtrack_slab_stn" .. surface_name,
            texture_prefix = "linetrack_road_slab",
            models_prefix = "advtrains_rtracks",
            models_suffix = ".obj",
            shared_texture = "[combine:32x16:0,0=" .. texture .. ":16,0=linetrack_road_stn.png:",
            description = S("Station/Stop Road Line Track Slab on @1", display_name),
            formats = {},
            get_additional_definiton = function()
                return {
                    after_place_node = stn_rail_def.after_place_node,
                    after_dig_node = stn_rail_def.after_dig_node,
                    on_rightclick = stn_rail_def.on_rightclick,
                    advtrains = {
                        on_train_enter = stn_rail_def.advtrains.on_train_enter,
                        on_train_approach = stn_rail_def.advtrains.on_train_approach,
                    },

                    groups = {
                        advtrains_track = 1,
                        advtrains_track_roadline = 1,
                        save_in_at_nodedb = 1,
                        dig_immediate = 2,
                        not_in_creative_inventory = 1,
                        not_blocking_trains = 1,
                    },
                    node_box = {
                        type = "fixed",
                        fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 },
                    },
                    use_texture_alpha = "blend",
                    walkable = true,
                }
            end
        }, slab_preset)
    end

    if linetrack.use_interlocking then
        local spd_rail_def = core.registered_nodes["advtrains_interlocking:dtrack_npr_st"]
        advtrains.register_tracks("roadline", {
            nodename_prefix = "linetrack:roadtrack_slab_spd" .. surface_name,
            texture_prefix = "linetrack_road_slab",
            models_prefix = "advtrains_rtracks",
            models_suffix = ".obj",
            shared_texture = "[combine:32x16:0,0=" .. texture .. ":16,0=linetrack_road_spd.png:",
            description = S("Point Speed Restriction Road Line Track Slab on @1", display_name),
            formats = {},
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
                    node_box = {
                        type = "fixed",
                        fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 },
                    },
                    use_texture_alpha = "blend",
                }
            end
        }, slab_preset)
    end
    ]]
end

do
    local black_baked_clay_def = core.registered_nodes["bakedclay:black"]
    local description = black_baked_clay_def and black_baked_clay_def.description or "Black Baked Clay"
    local texture = black_baked_clay_def and black_baked_clay_def.tiles[1] or "baked_clay_black.png"

    linetrack.regiser_roadline_for_surface("bakedclay_black", description, texture)
end

core.register_node("linetrack:lane_platform", {
    description = S("Lane Platform"),
    groups = { cracky = 1, not_blocking_trains = 1, platform = 1 },
    drawtype = "nodebox",
    tiles = { "linetrack_lane_platform.png", "linetrack_transparent.png" },
    node_box = {
        type = "fixed",
        fixed = { -0.5, -0.5, -0.5, 0.5, -0.49, 0.5 }
    },
    wield_image = "linetrack_lane_platform.png",
    inventory_image = "linetrack_lane_platform.png",
    walkable = false,
    paramtype2 = "facedir",
    paramtype = "light",
    sunlight_propagates = true,
})
