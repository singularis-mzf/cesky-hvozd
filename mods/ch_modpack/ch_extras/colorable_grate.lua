local ifthenelse = assert(ch_core.ifthenelse)
local grate_sounds = default.node_sound_metal_defaults()

local groups_in_ci = {cracky = 3, ud_param2_colorable = 1, not_blocking_trains = 1}
local groups = ch_core.assembly_groups(groups_in_ci, {not_in_creative_inventory = 1})

local function face(coord, sign)
    local result = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
    if sign >= 0 then
        result[coord] = 0.5 -- 63/128
        result[coord + 3] = 0.5 -- 65/128
    else
        result[coord] = -0.5 -- -65/128
        result[coord + 3] = -0.5 -- -63/128
    end
    return result
end

local function sbface(coord, sign)
    local result = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
    if sign >= 0 then
        result[coord] = 7/16
    else
        result[coord + 3] =  -7/16
    end
    return result
end

local mx = {type = "fixed", fixed = face(1, -1)}
local my = {type = "fixed", fixed = face(2, -1)}
local mz = {type = "fixed", fixed = face(3, -1)}
local px = {type = "fixed", fixed = face(1, 1)}
local py = {type = "fixed", fixed = face(2, 1)}
local pz = {type = "fixed", fixed = face(3, 1)}
local sbmx = {type = "fixed", fixed = sbface(1, -1)}
local sbmy = {type = "fixed", fixed = sbface(2, -1)}
local sbmz = {type = "fixed", fixed = sbface(3, -1)}
local sbpx = {type = "fixed", fixed = sbface(1, 1)}
local sbpy = {type = "fixed", fixed = sbface(2, 1)}
local sbpz = {type = "fixed", fixed = sbface(3, 1)}


local function combine(face_a, face_b)
    return {type = "fixed", fixed = {face_a.fixed, face_b.fixed}}
end

ch_core.register_nodes({
    description = "lakované pletivo (vychýlené)",
    drawtype = "nodebox",
    tiles = {{name = "ch_extras_grate32.png", backface_culling = true, align_style = "world"}},
    use_texture_alpha = "clip",
    is_ground_content = false,
    sunlight_propagates = true,
    paramtype = "light",
    paramtype2 = "color",
    palette = "unifieddyes_palette_extended.png",
    inventory_image = "ch_extras_grate32.png",
    wield_image = "ch_extras_grate32.png",
    on_construct = unifieddyes.on_construct,
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type == "node" then
            local node = core.get_node(pointed_thing.under)
            local name = node.name
            if name ~= itemstack:get_name() and name:len() == 17 and name:sub(1, 16) == "ch_extras:grate_" then
                local new_itemstack = ItemStack(itemstack)
                new_itemstack:set_name(name)
                local a, b = core.item_place(new_itemstack, placer, pointed_thing)
                if not a:is_empty() and a:get_name() == name then
                    a:set_name(itemstack:get_name())
                end
                return a, b
            end
        end
        return core.item_place(itemstack, placer, pointed_thing)
    end,
    -- on_dig = unifieddyes.on_dig,
    drop = {items = {{items = {"ch_extras:grate_1"}, inherit_color = true}}},

    groups = groups,
    sounds = grate_sounds,
}, {
    ["ch_extras:grate_1"] = {node_box = my, selection_box = sbmy, groups = groups_in_ci},
    ["ch_extras:grate_2"] = {node_box = mz, selection_box = sbmz}, -- -z
    ["ch_extras:grate_3"] = {node_box = pz, selection_box = sbpz}, -- +z
    ["ch_extras:grate_4"] = {node_box = mx, selection_box = sbmx}, -- -x
    ["ch_extras:grate_5"] = {node_box = px, selection_box = sbpx}, -- +x
    ["ch_extras:grate_6"] = {node_box = py, selection_box = sbpy}, -- +y
}, {
    {
        output = "ch_extras:grate_1 8",
        recipe = {
            {"default:steel_ingot", "", "default:steel_ingot"},
            {"", "default:steel_ingot", ""},
            {"default:steel_ingot", "", "default:steel_ingot"},
        }
    },
})

ch_core.register_nodes({
    description = "lakované pletivo (vychýlené L)",
    drawtype = "nodebox",
    tiles = {{name = "ch_extras_grate32.png", backface_culling = true, align_style = "world"}},
    use_texture_alpha = "clip",
    is_ground_content = false,
    sunlight_propagates = true,
    paramtype = "light",
    paramtype2 = "color",
    palette = "unifieddyes_palette_extended.png",
    on_construct = unifieddyes.on_construct,
    -- on_dig = unifieddyes.on_dig,
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type == "node" then
            local node = core.get_node(pointed_thing.under)
            local name = node.name
            if name ~= itemstack:get_name() and name:len() == 18 and name:sub(1, 17) == "ch_extras:grate_l" then
                local new_itemstack = ItemStack(itemstack)
                new_itemstack:set_name(name)
                local a, b = core.item_place(new_itemstack, placer, pointed_thing)
                if not a:is_empty() and a:get_name() == name then
                    a:set_name(itemstack:get_name())
                end
                return a, b
            end
        end
        return core.item_place(itemstack, placer, pointed_thing)
    end,
    drop = {items = {{items = {"ch_extras:grate_l1"}, inherit_color = true}}},

    groups = groups,
    sounds = grate_sounds,
}, {
    ["ch_extras:grate_l1"] = {
        -- 0 / 10 = -y + +z
        node_box = combine(my, pz),
        selection_box = combine(sbmy, sbpz),
        collision_box = combine(sbmy, sbpz),
        groups = groups_in_ci,
    },
    ["ch_extras:grate_l2"] = {
        -- 1 / 19 = -y + +x
        node_box = combine(my, px),
        selection_box = combine(sbmy, sbpx),
        collision_box = combine(sbmy, sbpx),
    },
    ["ch_extras:grate_l3"] = {
        -- 2 / 4 = -y + -z
        node_box = combine(my, mz),
        selection_box = combine(sbmy, sbmz),
        collision_box = combine(sbmy, sbmz),
    },
    ["ch_extras:grate_l4"] = {
        -- 3 / 13 = -y + -x
        node_box = combine(my, mx),
        selection_box = combine(sbmy, sbmx),
        collision_box = combine(sbmy, sbmx),
    },
    ["ch_extras:grate_l5"] = {
        -- 5 / 18 = -z + +x
        node_box = combine(px, mz),
        selection_box = combine(sbpx, sbmz),
        collision_box = combine(sbpx, sbmz),
    },
    ["ch_extras:grate_l6"] = {
        -- 6 / 22 = +y + -z
        node_box = combine(py, mz),
        selection_box = combine(sbpy, sbmz),
        collision_box = combine(sbpy, sbmz),
    },
    ["ch_extras:grate_l7"] = {
        -- 7 / 14 = -x + -z
        node_box = combine(mx, mz),
        selection_box = combine(sbmx, sbmz),
        collision_box = combine(sbmx, sbmz),
    },
    ["ch_extras:grate_l8"] = {
        -- 8 / 20 = +y + +z
        node_box = combine(py, pz),
        selection_box = combine(sbpy, sbpz),
        collision_box = combine(sbpy, sbpz),
    },
    ["ch_extras:grate_l9"] = {
        -- 9 / 16 = +x + +z
        node_box = combine(px, pz),
        selection_box = combine(sbpx, sbpz),
        collision_box = combine(sbpx, sbpz),
    },
    ["ch_extras:grate_l10"] = {
        -- 11 / 12 = -x + +z
        node_box = combine(mx, pz),
        selection_box = combine(sbmx, sbpz),
        collision_box = combine(sbmx, sbpz),
    },
    ["ch_extras:grate_l11"] = {
        -- 15 / 21 = -x + +y
        node_box = combine(mx, py),
        selection_box = combine(sbmx, sbpy),
        collision_box = combine(sbmx, sbpy),
    },
    ["ch_extras:grate_l12"] = {
        -- 17 / 23 = +x + +y
        node_box = combine(px, py),
        selection_box = combine(sbpx, sbpy),
        collision_box = combine(sbpx, sbpy),
    },
}, {
    {
        output = "ch_extras:grate_l1",
        recipe = {
            {"", "ch_extras:grate_1"},
            {"ch_extras:grate_1", ""},
        }
    },
    {
        output = "ch_extras:grate_1 2",
        recipe = {{"ch_extras:grate_l1"}},
    }
})

ch_core.register_nodedir_group({
    [0] = "ch_extras:grate_1",
    [1] = "ch_extras:grate_1",
    [2] = "ch_extras:grate_1",
    [3] = "ch_extras:grate_1",
    [4] = "ch_extras:grate_2",
    [5] = "ch_extras:grate_2",
    [6] = "ch_extras:grate_2",
    [7] = "ch_extras:grate_2",
    [8] = "ch_extras:grate_3",
    [9] = "ch_extras:grate_3",
    [10] = "ch_extras:grate_3",
    [11] = "ch_extras:grate_3",
    [12] = "ch_extras:grate_4",
    [13] = "ch_extras:grate_4",
    [14] = "ch_extras:grate_4",
    [15] = "ch_extras:grate_4",
    [16] = "ch_extras:grate_5",
    [17] = "ch_extras:grate_5",
    [18] = "ch_extras:grate_5",
    [19] = "ch_extras:grate_5",
    [20] = "ch_extras:grate_6",
    [21] = "ch_extras:grate_6",
    [22] = "ch_extras:grate_6",
    [23] = "ch_extras:grate_6",
})
ch_core.register_nodedir_group({
    [0] = "ch_extras:grate_l1",
    [1] = "ch_extras:grate_l2",
    [2] = "ch_extras:grate_l3",
    [3] = "ch_extras:grate_l4",
    [4] = "ch_extras:grate_l3",
    [5] = "ch_extras:grate_l5",
    [6] = "ch_extras:grate_l6",
    [7] = "ch_extras:grate_l7",
    [8] = "ch_extras:grate_l8",
    [9] = "ch_extras:grate_l9",
    [10] = "ch_extras:grate_l1",
    [11] = "ch_extras:grate_l10",
    [12] = "ch_extras:grate_l10",
    [13] = "ch_extras:grate_l4",
    [14] = "ch_extras:grate_l7",
    [15] = "ch_extras:grate_l11",
    [16] = "ch_extras:grate_l9",
    [17] = "ch_extras:grate_l12",
    [18] = "ch_extras:grate_l5",
    [19] = "ch_extras:grate_l2",
    [20] = "ch_extras:grate_l8",
    [21] = "ch_extras:grate_l11",
    [22] = "ch_extras:grate_l6",
    [23] = "ch_extras:grate_l12",
})

ch_core.register_nodes({
    drawtype = "nodebox",
    tiles = {{name = "ch_extras_grate32.png", backface_culling = true, align_style = "world"}},
    use_texture_alpha = "clip",
    is_ground_content = false,
    sunlight_propagates = true,
    paramtype = "light",
    paramtype2 = "color",
    inventory_image = "blank.png",
    inventory_overlay = "ch_extras_grate32.png^[multiply:#aaaaaa",
    wield_image = "ch_extras_grate32.png",
    palette = "unifieddyes_palette_extended.png",
    on_construct = unifieddyes.on_construct,
    -- on_dig = unifieddyes.on_dig,
    sounds = grate_sounds,
    drop = {items = {{items = {"ch_extras:grate_flat_1"}, inherit_color = true}}},
    }, {
        ["ch_extras:grate_con"] = {
            description = "lakované pletivo (spojující se)",
            node_box = {
                type = "connected",
                disconnected = {-1/64, -0.5, -1/64, 1/64, 0.5, 1/64},
                connect_front = {0, -0.5, -0.5, 0, 0.5, 0}, -- -Z
                connect_left = {-0.5, -0.5, 0, 0, 0.5, 0}, -- -X
                connect_back = {0, -0.5, 0, 0, 0.5, 0.5}, -- +Z
                connect_right = {0, -0.5, 0, 0.5, 0.5, 0}, -- +X
            },
            selection_box = {
                type = "connected",
                disconnected = {-1/32, -0.5, -1/32, 1/32, 0.5, 1/32},
                connect_front = {-1/32, -0.5, -0.5, 1/32, 0.5, 0}, -- -Z
                connect_left = {-0.5, -0.5, 0, -1/32, 0.5, 1/32}, -- -X
                connect_back = {-1/32, -0.5, 0, 1/32, 0.5, 0.5}, -- +Z
                connect_right = {0, -0.5, -1/32, 0.5, 0.5, 1/32}, -- +X
            },
            connect_sides = {"front", "back", "left", "right"},
            connects_to = {"ch_extras:grate_con", "ch_extras:grate_flat_1", "ch_extras:grate_flat_2"},
            groups = groups_in_ci,
            drop = {items = {{items = {"ch_extras:grate_con"}, inherit_color = true}}},
        },
        ["ch_extras:grate_flat_1"] = { -- Z
            description = "lakované pletivo (vystředěné)",
            node_box = {type = "fixed", fixed = {-0.5, -0.5, 0, 0.5, 0.5, 0}},
            selection_box = {type = "fixed", fixed = {-0.5, -0.5, -1/32, 0.5, 0.5, 1/32}},
            collision_box = {type = "fixed", fixed = {-0.5, -0.5, -1/32, 0.5, 0.5, 1/32}},
            groups = groups_in_ci,
        },
        ["ch_extras:grate_flat_2"] = { -- X
            description = "lakované pletivo (vystředěné)",
            node_box = {type = "fixed", fixed = {0, -0.5, -0.5, 0, 0.5, 0.5}},
            selection_box = {type = "fixed", fixed = {-1/32, -0.5, -0.5, 1/32, 0.5, 0.5}},
            collision_box = {type = "fixed", fixed = {-1/32, -0.5, -0.5, 1/32, 0.5, 0.5}},
            groups = groups,
        },
    },
    {
        {
            output = "ch_extras:grate_con 5",
            recipe = {
                {"", "ch_extras:grate_1", ""},
                {"ch_extras:grate_1", "ch_extras:grate_1", "ch_extras:grate_1"},
                {"", "ch_extras:grate_1", ""},
            },
        }, {
            output = "ch_extras:grate_flat_1 3",
            recipe = {
                {"ch_extras:grate_1", "ch_extras:grate_1", "ch_extras:grate_1"},
                {"", "", ""},
                {"", "", ""},
            },
        }, {
            output = "ch_extras:grate_flat_1 3",
            recipe = {
                {"ch_extras:grate_1", "", ""},
                {"ch_extras:grate_1", "", ""},
                {"ch_extras:grate_1", "", ""},
            },
        }, {
            output = "ch_extras:grate_1",
            recipe = {{"ch_extras:grate_con"}},
        }, {
            output = "ch_extras:grate_flat_1",
            recipe = {{"ch_extras:grate_flat_1"}},
        },
    }
)

ch_core.register_nodedir_group({
    [0] = "ch_extras:grate_flat_1",
    [1] = "ch_extras:grate_flat_2",
    [2] = "ch_extras:grate_flat_1",
    [3] = "ch_extras:grate_flat_2",
})

ch_core.register_shape_selector_group({
    input_only = {
        "ch_extras:grate_2",
        "ch_extras:grate_3",
        "ch_extras:grate_4",
        "ch_extras:grate_5",
        "ch_extras:grate_6",
    },
    nodes = {
        {name = "ch_extras:grate_1", label = "1"},
        {name = "ch_extras:grate_con", label = "spoj."},
        {name = "ch_extras:grate_flat_2", label = "X"},
        {name = "ch_extras:grate_flat_1", label = "Z"},
    }})
