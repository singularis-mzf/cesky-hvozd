local groups_to_inherit = {
    "cracky", "crumbly", "snappy", "oddly_breakable_by_hand", "flammable", "not_in_creative_inventory"
}
local function prepare_groups(orig_groups)
    local groups = {}
    if orig_groups ~= nil then
        for _, group in ipairs(groups_to_inherit) do
            if orig_groups[group] ~= nil then
                groups[group] = orig_groups[group]
            end
        end
    end
    groups.wall = 1
    return groups
end

function ch_extras.register_arcade(name, recipeitem, options)
    local y_min, y_max = -0.5 - 1 / 32, -0.5 + 1/32
    local rdef = minetest.registered_nodes[recipeitem]
    if rdef == nil then
        error("ch_extras.register_arcade(): "..recipeitem.." is not a registered node!")
    end
    if options == nil then
        options = {}
    end

    local def = {
        description = (rdef.description or "Blok bez názvu")..": překlad zdi",
        drawtype = "nodebox",
        node_box = {
            type = "connected",
            fixed = {-3/16, y_min, -3/16, 3/16, y_max, 3/16},
            connect_front = {-3/16, y_min, -1/2, 3/16, y_max, 3/16},
            connect_left = {-1/2, y_min, -3/16, -3/16, y_max, 3/16},
            connect_back = {-3/16, y_min, 3/16, 3/16, y_max, 1/2},
            connect_right = {3/16, y_min, -3/16, 1/2, y_max, 3/16},
        },
        connects_to = {"group:wall", "group:stone"},
        paramtype = "light",
        is_ground_content = false,
        tiles = rdef.tiles or {"ch_extras_white_pixel.png"},
        groups = prepare_groups(rdef.groups),
        sounds = default.node_sound_stone_defaults(),
    }

    minetest.register_node(name, def)

    local panel = stairsplus:get_shape(recipeitem, "panel", "_4")
    if not options.no_craft and panel ~= nil then
        name = name:gsub("^:", "")
        minetest.register_craft({
            output = name.." 6",
            recipe = {
                {"", "", ""},
                {panel, panel, panel},
                {panel, panel, panel},
            },
        })
    end
end
