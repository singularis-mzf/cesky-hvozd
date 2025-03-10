-- lakovaná tyč
------------------
-- local ifthenelse = assert(ch_core.ifthenelse)
local pole_texture = "ch_core_clay.png"
local pole_sounds = default.node_sound_metal_defaults()
local pole_groups = {
    panel_pole = 1,
    oddly_breakable_by_hand = 1,
    cracky = 1,
    choppy = 1,
    ud_param2_colorable = 1,
    not_blocking_trains = 1,
    not_in_creative_inventory = 1,
}
local pole_groups_in_ci = ch_core.assembly_groups(pole_groups, {not_in_creative_inventory = 0})
local pole_groups_thin = ch_core.assembly_groups(pole_groups, {panel_pole = 0, panel_pole_thin = 1})
local pole_groups_thin_in_ci = ch_core.assembly_groups(pole_groups_thin, {not_in_creative_inventory = 0})
local drop_pole_flat = {items = {{items = {"ch_extras:colorable_pole_flat"}, inherit_color = true}}}
local drop_pole_thin_flat = {items = {{items = {"ch_extras:colorable_pole_thin_flat"}, inherit_color = true}}}

local def = {
    description = "lakovaná tyč (spojující se)",
    drawtype = "nodebox",
    tiles = {
        {name = pole_texture, backface_culling = true, align_style = "world"},
    },
    node_box = {
        type = "connected",
        fixed = {-0.125, -0.125, -0.125, 0.125, 0.125, 0.125},
        connect_top = {-0.125, 0.125, -0.125, 0.125, 0.5, 0.125}, -- +Y
        connect_bottom = {-0.125, -0.5, -0.125, 0.125, -0.125, 0.125}, -- -Y
        connect_front = {-0.125, -0.125, -0.5, 0.125, 0.125, -0.125}, -- -Z
        connect_left = {-0.5, -0.125, -0.125, -0.125, 0.125, 0.125}, -- -X
        connect_back = {-0.125, -0.125, 0.125, 0.125, 0.125, 0.5}, -- +Z
        connect_right = {0.125, -0.125, -0.125, 0.5, 0.125, 0.125}, -- +X
    },
    connect_sides = {"left", "right", "top", "bottom", "front", "back"},
    connects_to = {"group:panel_pole", "group:full_cube_node", "group:attracts_poles"}, -- no fence, no wall
    is_ground_content = false,
    sunlight_propagates = true,
    paramtype = "light",
    paramtype2 = "color",
    palette = "unifieddyes_palette_extended.png",
    on_dig = unifieddyes.on_dig,

    groups = pole_groups_in_ci,
    sounds = pole_sounds,
    check_for_pole = true,
}

core.register_node("ch_extras:colorable_pole", table.copy(def))

def.description = "tenká lakovaná tyč (spojující se)"
def.node_box = {
    type = "connected",
    fixed = {-0.0625, -0.0625, -0.0625, 0.0625, 0.0625, 0.0625},
    connect_top = {-0.0625, 0.0625, -0.0625, 0.0625, 0.5, 0.0625}, -- +Y
    connect_bottom = {-0.0625, -0.5, -0.0625, 0.0625, -0.0625, 0.0625}, -- -Y
    connect_front = {-0.0625, -0.0625, -0.5, 0.0625, 0.0625, -0.0625}, -- -Z
    connect_left = {-0.5, -0.0625, -0.0625, -0.0625, 0.0625, 0.0625}, -- -X
    connect_back = {-0.0625, -0.0625, 0.0625, 0.0625, 0.0625, 0.5}, -- +Z
    connect_right = {0.0625, -0.0625, -0.0625, 0.5, 0.0625, 0.0625}, -- +X
}
def.connects_to = {"group:panel_pole_thin", "group:wall", "group:full_cube_node", "group:attracts_poles"}
def.groups = pole_groups_thin_in_ci

core.register_node("ch_extras:colorable_pole_thin", def)

def = {
    description = "lakovaná tyč (přímá)",
    drawtype = "nodebox",
    tiles = {{name = pole_texture, backface_culling = true, align_style = "world"}},
    is_ground_content = false,
    sunlight_propagates = true,
    paramtype = "light",
    paramtype2 = "color",
    palette = "unifieddyes_palette_extended.png",
    on_construct = unifieddyes.on_construct,

    sounds = pole_sounds,
}

ch_core.register_nodes(def, {
    ["ch_extras:colorable_pole_flat"] = { -- Y
        node_box = {
            type = "fixed",
            fixed = {-0.125, -0.5, -0.125, 0.125, 0.5, 0.125},
        },
        groups = pole_groups_in_ci,
        drop = drop_pole_flat,
        check_for_pole = true,
    },
    ["ch_extras:colorable_pole_flat_2"] = { -- X
        node_box = {
            type = "fixed",
            fixed = {-0.5, -0.125, -0.125, 0.5, 0.125, 0.125},
        },
        groups = pole_groups,
        drop = drop_pole_flat,
        check_for_pole = true,
    },
    ["ch_extras:colorable_pole_flat_3"] = { -- Z
        node_box = {
            type = "fixed",
            fixed = {-0.125, -0.125, -0.5, 0.125, 0.125, 0.5},
        },
        groups = pole_groups,
        drop = drop_pole_flat,
        check_for_pole = true,
    },
    ["ch_extras:colorable_pole_thin_flat"] = { -- Y
        description = "tenká lakovaná tyč (přímá)",
        node_box = {
            type = "fixed",
            fixed = {-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625},
        },
        groups = pole_groups_thin_in_ci,
        drop = drop_pole_thin_flat,
    },
    ["ch_extras:colorable_pole_thin_flat_2"] = { -- X
        description = "tenká lakovaná tyč (přímá)",
        node_box = {
            type = "fixed",
            fixed = {-0.5, -0.0625, -0.0625, 0.5, 0.0625, 0.0625},
        },
        groups = pole_groups_thin,
        drop = drop_pole_thin_flat,
    },
    ["ch_extras:colorable_pole_thin_flat_3"] = { -- Z
        description = "tenká lakovaná tyč (přímá)",
        node_box = {
            type = "fixed",
            fixed = {-0.0625, -0.0625, -0.5, 0.0625, 0.0625, 0.5},
        },
        groups = pole_groups_thin,
        drop = drop_pole_thin_flat,
    },
}, {
    {
        output = "ch_extras:colorable_pole_flat",
        recipe = {{"ch_extras:colorable_pole"}},
    }, {
        output = "ch_extras:colorable_pole",
        recipe = {{"ch_extras:colorable_pole_flat"}},
    }, {
        output = "ch_extras:colorable_pole_thin_flat",
        recipe = {{"ch_extras:colorable_pole_thin"}},
    }, {
        output = "ch_extras:colorable_pole_thin",
        recipe = {{"ch_extras:colorable_pole_thin_flat"}},
    }
})

local nodedir_group, nodedir_group_thin = {}, {}
local name1, name2, name3 = "ch_extras:colorable_pole_flat", "ch_extras:colorable_pole_flat_2", "ch_extras:colorable_pole_flat_3"
local name1t, name2t, name3t = "ch_extras:colorable_pole_thin_flat", "ch_extras:colorable_pole_thin_flat_2", "ch_extras:colorable_pole_thin_flat_3"
for i = 0, 23 do
    nodedir_group[i] = name1
    nodedir_group_thin[i] = name1t
end
for i = 12, 19 do
    nodedir_group[i] = name2
    nodedir_group_thin[i] = name2t
end
for i = 4, 11 do
    nodedir_group[i] = name3
    nodedir_group_thin[i] = name3t
end

ch_core.register_nodedir_group(nodedir_group)
ch_core.register_nodedir_group(nodedir_group_thin)

ch_core.register_shape_selector_group({
    nodes = {
        "ch_extras:colorable_pole",
        "ch_extras:colorable_pole_flat",
        "ch_extras:colorable_pole_flat_2",
        "ch_extras:colorable_pole_flat_3",
    },
})

ch_core.register_shape_selector_group({
    nodes = {
        "ch_extras:colorable_pole_thin",
        "ch_extras:colorable_pole_thin_flat",
        "ch_extras:colorable_pole_thin_flat_2",
        "ch_extras:colorable_pole_thin_flat_3",
    },
})

core.register_craft({
    output = "ch_extras:colorable_pole 6",
    recipe = {
        {"dye:red", "dye:green", "dye:blue"},
        {"group:panel_pole", "group:panel_pole", "group:panel_pole"},
        {"group:panel_pole", "group:panel_pole", "group:panel_pole"},
    },
})

core.register_craft({
    output = "ch_extras:colorable_pole_thin 6",
    recipe = {
        {"dye:red", "dye:green", "dye:blue"},
        {"group:panel_pole_thin", "group:panel_pole_thin", "group:panel_pole_thin"},
        {"group:panel_pole_thin", "group:panel_pole_thin", "group:panel_pole_thin"},
    },
})

--[[
core.register_lbm({
    label = "Convert old colorable poles",
    name = "ch_extras:colorable_poles_update",
    nodenames = {"ch_extras:colorable_pole_flat"},
    -- run_at_every_load = true, -- TODO: remove
    action = function(pos, node, dtime_s)
        local color = unifieddyes.color_to_name(node.param2, {_ch_ud_palette = "unifieddyes_palette_colorwallmounted.png"})
        if color ~= nil then
            local new_param2, second_result = unifieddyes.getpaletteidx("dye:"..color, "extended")
            if new_param2 ~= nil and new_param2 ~= node.param2 then
                core.log("action", "Will update colorable pole at "..core.pos_to_string(pos)..": "..node.param2.." => "..new_param2.." (color="..color..")")
                node.param2 = new_param2
                core.swap_node(pos, node)
                return
            end
        end
    end,
})
]]

-- COLORABLE EDGE-POLES:
local function rotate_box_by_facedir(box, facedir)
    local fixed = assert(box.fixed)
    if type(fixed[1]) == "table" then
        local result = {}
        for i, aabb in ipairs(fixed) do
            result[i] = assert(ch_core.rotate_aabb_by_facedir(aabb, facedir))
        end
        return {type = "fixed", fixed = result}
    else
        return {type = "fixed", fixed = assert(ch_core.rotate_aabb_by_facedir(fixed, facedir))}
    end
end

local ep_node_box = {
    type = "fixed",
    fixed = {-17/32, -17/32, -17/32, -15/32, 17/32, -15/32},
}

local ep_selection_box = {
    type = "fixed",
    fixed = {-16/32, -16/32, -16/32, -9/32, 16/32, -9/32},
}

def = {
    description = "lakovaná vychýlená tyč I",
    drawtype = "nodebox",
    tiles = {{name = pole_texture, backface_culling = true, align_style = "world"}},
    is_ground_content = false,
    sunlight_propagates = true,
    paramtype = "light",
    paramtype2 = "color",
    palette = "unifieddyes_palette_extended.png",
    groups = {cracky = 3, not_blocking_trains = 1, ud_param2_colorable = 1, not_in_creative_inventory = 1},
    sounds = pole_sounds,
    on_dig = unifieddyes.on_dig,
    drop = {items = {{items = {"ch_extras:colorable_edgepole_0"}, inherit_color = true}}},
}

local node_defs = {
    ["ch_extras:colorable_edgepole_0"] = {
        node_box = ep_node_box,
        selection_box = ep_selection_box,
        groups = {cracky = 3, not_blocking_trains = 1, ud_param2_colorable = 1},
    }
}

for i = 1, 23 do
    node_defs["ch_extras:colorable_edgepole_"..i] = {
        node_box = rotate_box_by_facedir(ep_node_box, i),
        selection_box = rotate_box_by_facedir(ep_selection_box, i),
    }
end

ch_core.register_nodes(def, node_defs, {{
    output = "ch_extras:colorable_edgepole_0 5",
    recipe = {
        {"", "moreblocks:panel_steelblock_special", ""},
        {"moreblocks:panel_steelblock_special", "", "moreblocks:panel_steelblock_special"},
        {"", "moreblocks:panel_steelblock_special", ""},
        }
}})

ep_node_box = {
    type = "fixed",
    fixed = {
        {-17/32, -17/32, -17/32, -15/32, 17/32, -15/32},
        {-17/32, -17/32, -17/32, 17/32, -15/32, -15/32},
    },
}
ep_selection_box = {
    type = "fixed",
    fixed = {
        {-16/32, -16/32, -16/32, -9/32, 16/32, -9/32},
        {-16/32, -16/32, -16/32, 16/32, -9/32, -9/32},
    },
}

def.description = "lakovaná vychýlená tyč L"
def.drop = {items = {{items = {"ch_extras:colorable_edgepole_l_0"}, inherit_color = true}}}

node_defs = {
    ["ch_extras:colorable_edgepole_l_0"] = {
        node_box = ep_node_box,
        selection_box = ep_selection_box,
        groups = {cracky = 3, not_blocking_trains = 1, ud_param2_colorable = 1},
    },
}

for i = 1, 23 do
    node_defs["ch_extras:colorable_edgepole_l_"..i] = {
        node_box = rotate_box_by_facedir(ep_node_box, i),
        selection_box = rotate_box_by_facedir(ep_selection_box, i),
    }
end
ch_core.register_nodes(def, node_defs, {
    {
        output = "ch_extras:colorable_edgepole_l_0 5",
        recipe = {
            {"", "moreblocks:panel_steelblock_l", ""},
            {"moreblocks:panel_steelblock_l", "", "moreblocks:panel_steelblock_l"},
            {"", "moreblocks:panel_steelblock_l", ""},
        }
    }, {
        output = "ch_extras:colorable_edgepole_l_0",
        recipe = {
            {"ch_extras:colorable_edgepole_0", "ch_extras:colorable_edgepole_0"},
            {"", ""},
        },
    }, {
        output = "ch_extras:colorable_edgepole_l_0",
        recipe = {
            {"ch_extras:colorable_edgepole_0", ""},
            {"ch_extras:colorable_edgepole_0", ""},
        },
    }, {
        output = "ch_extras:colorable_edgepole_0 2",
        recipe = {{"ch_extras:colorable_edgepole_l_0"}},
    }
})

nodedir_group = {}
for i = 0, 23 do
    nodedir_group[i] = "ch_extras:colorable_edgepole_"..i
end
ch_core.register_nodedir_group(nodedir_group)
for i = 0, 23 do
    nodedir_group[i] = "ch_extras:colorable_edgepole_l_"..i
end
ch_core.register_nodedir_group(nodedir_group)
