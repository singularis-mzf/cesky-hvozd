-- lakovaná zeď/nízká zeď
------------------
local assembly_groups = assert(ch_core.assembly_groups)
local wall_texture = "ch_core_clay.png"
local wall_sounds = default.node_sound_stone_defaults()
local common_groups_in_ci = {cracky = 1, ud_param2_colorable = 1}
local common_groups = assembly_groups(common_groups_in_ci, {not_in_creative_inventory = 1})
local drop_wall_flat = {items = {{items = {"ch_extras:colorable_wall_flat"}, inherit_color = true}}}
local drop_element_flat = {items = {{items = {"ch_extras:colorable_element_flat"}, inherit_color = true}}}

local def = {
    description = "lakovaná zeď (spojující se)",
    drawtype = "nodebox",
    tiles = {
        {name = wall_texture, backface_culling = true, align_style = "world"},
    },
    node_box = {
        type = "connected",
        fixed = {-0.125, -0.5, -0.125, 0.125, 0.5005, 0.125},
        connect_front = {-0.125, -0.5, -0.5, 0.125, 0.5005, -0.125}, -- -Z
        connect_left = {-0.5, -0.5, -0.125, -0.125, 0.5005, 0.125}, -- -X
        connect_back = {-0.125, -0.5, 0.125, 0.125, 0.5005, 0.5}, -- +Z
        connect_right = {0.125, -0.5, -0.125, 0.5, 0.5005, 0.125}, -- +X
    },
    connect_sides = {"left", "right", "front", "back"},
    connects_to = {"group:wall_flat", "group:wall_connecting", "group:element_connecting", "group:panel_pole_connecting",
        "group:panel_pole_thin_connecting"},
    is_ground_content = false,
    sunlight_propagates = true,
    paramtype = "light",
    paramtype2 = "color",
    palette = "unifieddyes_palette_extended.png",
    on_dig = unifieddyes.on_dig,

    groups = assembly_groups(common_groups_in_ci, {wall = 1, wall_connecting = 1}),
    sounds = wall_sounds,
    check_for_pole = true,
}

core.register_node("ch_extras:colorable_wall", table.copy(def))

def.description = "lakovaná nízká zeď (spojující se)"
def.node_box = {
    type = "connected",
    fixed = {-0.125, -0.5, -0.125, 0.125, 0.0, 0.125},
    connect_top = {-0.125, 0.0, -0.125, 0.125, 0.5, 0.125}, -- +Y
    connect_front = {-0.125, -0.5, -0.5, 0.125, 0.0, -0.125}, -- -Z
    connect_left = {-0.5, -0.5, -0.125, -0.125, 0.0, 0.125}, -- -X
    connect_back = {-0.125, -0.5, 0.125, 0.125, 0.0, 0.5}, -- +Z
    connect_right = {0.125, -0.5, -0.125, 0.5, 0.0, 0.125}, -- +X
}
def.connect_sides = {"left", "right", "front", "back", "top"}
def.connects_to = {"group:element_connecting", "group:element_flat", "group:wall_connecting",
    "group:panel_pole_flat", "group:panel_pole_thin_flat", "group:arcade"}
def.groups = assembly_groups(common_groups_in_ci, {element_connecting = 1})

core.register_node("ch_extras:colorable_element", def)

def = {
    description = "lakovaná zeď (přímá)",
    drawtype = "nodebox",
    tiles = {{name = wall_texture, backface_culling = true, align_style = "world"}},
    is_ground_content = false,
    sunlight_propagates = true,
    paramtype = "light",
    paramtype2 = "color",
    palette = "unifieddyes_palette_extended.png",
    on_construct = unifieddyes.on_construct,
    groups = assembly_groups(common_groups, {wall = 1, wall_flat = 1}),

    sounds = wall_sounds,
}

ch_core.register_nodes(def, {
    ["ch_extras:colorable_wall_flat"] = { -- Z
        node_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.125, 0.5, 0.5, 0.125},
        },
        groups = assembly_groups(common_groups_in_ci, {wall = 1, wall_flat = 1}),
        drop = drop_wall_flat,
        check_for_pole = true,
    },
    ["ch_extras:colorable_wall_flat_2"] = { -- X
        node_box = {
            type = "fixed",
            fixed = {-0.125, -0.5, -0.5, 0.125, 0.5, 0.5},
        },
        drop = drop_wall_flat,
        check_for_pole = true,
    },
    ["ch_extras:colorable_wall_flat_3"] = { -- Y
        node_box = {
            type = "fixed",
            fixed = {-0.5, -0.125, -0.5, 0.5, 0.125, 0.5},
        },
        drop = drop_wall_flat,
        check_for_pole = true,
    }})
def.description = "lakovaná nízká zeď (přímá)"
def.groups = assembly_groups(common_groups, {element_flat = 1})
def.drop = drop_element_flat
ch_core.register_nodes(def, {
    -- podstava: -Y
    ["ch_extras:colorable_element_flat"] = { -- Z
        node_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.125, 0.5, 0, 0.125},
        },
        groups = assembly_groups(common_groups_in_ci, {element_flat = 1}),
    },
    ["ch_extras:colorable_element_flat_2"] = { -- X
        node_box = {
            type = "fixed",
            fixed = {-0.125, -0.5, -0.5, 0.125, 0, 0.5},
        },
    },
    -- podstava: -Z
    ["ch_extras:colorable_element_flat_3"] = { -- Y
        node_box = {
            type = "fixed",
            fixed = {-0.5, -0.125, -0.5, 0.5, 0.125, 0},
        },
    },
    ["ch_extras:colorable_element_flat_4"] = { -- X
        node_box = {
            type = "fixed",
            fixed = {-0.125, -0.5, -0.5, 0.125, 0.5, 0},
        },
    },
    -- podstava: +Z
    ["ch_extras:colorable_element_flat_5"] = { -- Y
        node_box = {
            type = "fixed",
            fixed = {-0.5, -0.125, 0, 0.5, 0.125, 0.5},
        },
    },
    ["ch_extras:colorable_element_flat_6"] = { -- X
        node_box = {
            type = "fixed",
            fixed = {-0.125, -0.5, 0, 0.125, 0.5, 0.5},
        },
    },
    -- podstava: -X
    ["ch_extras:colorable_element_flat_7"] = { -- Z
        node_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.125, 0, 0.5, 0.125},
        },
    },
    ["ch_extras:colorable_element_flat_8"] = { -- Y
        node_box = {
            type = "fixed",
            fixed = {-0.5, -0.125, -0.5, 0, 0.125, 0.5},
        },
    },
    -- podstava: +X
    ["ch_extras:colorable_element_flat_9"] = { -- Z
        node_box = {
            type = "fixed",
            fixed = {0, -0.5, -0.125, 0.5, 0.5, 0.125},
        },
    },
    ["ch_extras:colorable_element_flat_10"] = { -- Y
        node_box = {
            type = "fixed",
            fixed = {0, -0.125, -0.5, 0.5, 0.125, 0.5},
        },
    },
    -- podstava: +Y
    ["ch_extras:colorable_element_flat_11"] = { -- Z
        node_box = {
            type = "fixed",
            fixed = {-0.5, 0, -0.125, 0.5, 0.5, 0.125},
        },
    },
    ["ch_extras:colorable_element_flat_12"] = { -- X
        node_box = {
            type = "fixed",
            fixed = {-0.125, 0, -0.5, 0.125, 0.5, 0.5},
        },
    },
}, {
    {
        output = "ch_extras:colorable_wall_flat",
        recipe = {{"ch_extras:colorable_wall"}},
    }, {
        output = "ch_extras:colorable_wall",
        recipe = {{"ch_extras:colorable_wall_flat"}},
    }, {
        output = "ch_extras:colorable_element_flat",
        recipe = {{"ch_extras:colorable_element"}},
    }, {
        output = "ch_extras:colorable_element",
        recipe = {{"ch_extras:colorable_element_flat"}},
    }
})

local name1, name2, name3 = "ch_extras:colorable_wall_flat", "ch_extras:colorable_wall_flat_2", "ch_extras:colorable_wall_flat_3"

ch_core.register_nodedir_group({
    [0] = name1, name2, name1, name2,
    name3, name2, name3, name2,
    name3, name2, name3, name2,
    name1, name3, name1, name3,
    name1, name3, name1, name3,
    name1, name2, name1, name2,
})

local nd_group = {}

for i = 0, 11 do
    local s
    if i == 0 then
        s = ""
    else
        s = "_"..(i + 1)
    end
    if i % 2 == 0 then
        nd_group[2 * i] = "ch_extras:colorable_element_flat"..s
        nd_group[2 * i + 2] = "ch_extras:colorable_element_flat"..s
    else
        nd_group[2 * i - 1] = "ch_extras:colorable_element_flat"..s
        nd_group[2 * i + 1] = "ch_extras:colorable_element_flat"..s
    end
end

ch_core.register_nodedir_group(nd_group)

ch_core.register_shape_selector_group({
    nodes = {
        "ch_extras:colorable_wall",
        "ch_extras:colorable_wall_flat",
        "ch_extras:colorable_wall_flat_2",
        "ch_extras:colorable_wall_flat_3",
    },
})

local nodes = {
    "ch_extras:colorable_element", nil, nil, nil,
    {name = "ch_extras:colorable_element_flat", label = "-Y"},
    {name = "ch_extras:colorable_element_flat_2", label = "-Y"},
    {name = "ch_extras:colorable_element_flat_3", label = "-Z"},
    {name = "ch_extras:colorable_element_flat_4", label = "-Z"},
    {name = "ch_extras:colorable_element_flat_5", label = "+Z"},
    {name = "ch_extras:colorable_element_flat_6", label = "+Z"},
    {name = "ch_extras:colorable_element_flat_7", label = "-X"},
    {name = "ch_extras:colorable_element_flat_8", label = "-X"},
    {name = "ch_extras:colorable_element_flat_9", label = "+X"},
    {name = "ch_extras:colorable_element_flat_10", label = "+X"},
    {name = "ch_extras:colorable_element_flat_11", label = "+Y"},
    {name = "ch_extras:colorable_element_flat_12", label = "+Y"},
}

ch_core.register_shape_selector_group({columns = 4, rows = 4, nodes = nodes})

core.register_craft({
    output = "ch_extras:colorable_wall 6",
    recipe = {
        {"dye:red", "dye:green", "dye:blue"},
        {"group:wall", "group:wall", "group:wall"},
        {"group:wall", "group:wall", "group:wall"},
    },
})

core.register_craft({
    output = "ch_extras:colorable_element 6",
    recipe = {
        {"dye:red", "dye:green", "dye:blue"},
        {"group:element_connecting", "group:element_connecting", "group:element_connecting"},
        {"group:element_connecting", "group:element_connecting", "group:element_connecting"},
    },
})

core.register_craft({
    output = "ch_extras:colorable_element 6",
    recipe = {
        {"dye:red", "dye:green", "dye:blue"},
        {"group:element_flat", "group:element_flat", "group:element_flat"},
        {"group:element_flat", "group:element_flat", "group:element_flat"},
    },
})
