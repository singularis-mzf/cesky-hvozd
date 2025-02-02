local function rotate_fixed(node_box, param2)
    if param2 == 0 then
        return node_box -- optimization
    end
    local fixed = {}
    for i, aabb in ipairs(assert(node_box.fixed)) do
        fixed[i] = ch_core.rotate_aabb_by_facedir(aabb, param2)
    end
    return {type = "fixed", fixed = fixed}
end

local function on_place(itemstack, placer, pointed_thing)
    local old_name = itemstack:get_name()
    if placer ~= nil and placer:is_player() then
        local yaw = placer:get_look_horizontal()
        local dir = core.yaw_to_dir(yaw)
        local facedir = tostring(core.dir_to_fourdir(dir))
        if old_name:sub(-1, -1) == facedir then
            old_name = nil
        else
            itemstack:set_name(old_name:sub(1, -2)..facedir)
        end
    end
    local result, pos = core.item_place(itemstack, placer, pointed_thing)
    if old_name ~= nil and result ~= nil and not result:is_empty() then
        result:set_name(old_name)
    end
    return result, pos
end

-- old_node_def.after_nodedir_rotate(pos, old_node, node, itemstack, user)
local function after_nodedir_rotate(pos, old_node, new_node)
    drawers.remove_visuals(pos)
    drawers.spawn_visuals(pos)
end

local function register_colorable_drawers(prefix, base_node)
    local odef = assert(core.registered_nodes[base_node])
    local drawer_group = assert(odef.groups.drawer)
    local new_def = {}
    for k, v in pairs(odef) do
        if k ~= "name" and k ~= "type" then
            new_def[k] = v
        end
    end
    new_def.description = "lakovaný zásobník"
    if drawer_group == 2 then
        new_def.description = new_def.description.." (1x2)"
    elseif drawer_group == 4 then
        new_def.description = new_def.description.." (2x2)"
    end
    new_def.paramtype2 = "color"
    new_def.palette = "unifieddyes_palette_extended.png"
    new_def.on_place = on_place
    new_def.on_dig = unifieddyes.on_dig
    new_def.groups = ch_core.assembly_groups(odef.groups, {not_in_creative_inventory = 1, ud_param2_colorable = 1})
    new_def.selection_box = nil
    new_def.node_box = nil
    new_def.on_rotate = nil
    new_def.after_nodedir_rotate = after_nodedir_rotate
    new_def.drop = {items = {{items = {prefix.."0"}, inherit_color = true}}}
    local base_tiles = drawers.node_tiles_front_other("drawers_aspen_wood_front_"..drawer_group..".png", "drawers_aspen_wood.png")
    local base_node_box = assert(odef.node_box)

    ch_core.register_nodes(new_def, {
        [prefix.."0"] = {
            tiles = base_tiles,
            node_box = base_node_box,
            groups = ch_core.assembly_groups(new_def.groups, {not_in_creative_inventory = 0})
        },
        [prefix.."1"] = {
            tiles = {
                base_tiles[1].."^[transformR270",
                base_tiles[2].."^[transformR90",
                base_tiles[5],
                base_tiles[6],
                base_tiles[4],
                base_tiles[3],
            },
            node_box = rotate_fixed(base_node_box, 1),
        },
        [prefix.."2"] = {
            tiles = {
                base_tiles[1].."^[transformR180",
                base_tiles[2].."^[transformR180",
                base_tiles[4],
                base_tiles[3],
                base_tiles[6],
                base_tiles[5],
            },
            node_box = rotate_fixed(base_node_box, 2),
        },
        [prefix.."3"] = {
            tiles = {
                base_tiles[1].."^[transformR90",
                base_tiles[2].."^[transformR270",
                base_tiles[6],
                base_tiles[5],
                base_tiles[3],
                base_tiles[4],
            },
            node_box = rotate_fixed(base_node_box, 3),
        },
    })
    ch_core.register_nodedir_group({
        [0] = prefix.."0",
        [1] = prefix.."1",
        [2] = prefix.."2",
        [3] = prefix.."3",
    })
end

register_colorable_drawers("drawers:colorable1_", "drawers:junglewood1")
register_colorable_drawers("drawers:colorable2_", "drawers:junglewood2")
register_colorable_drawers("drawers:colorable4_", "drawers:junglewood4")

core.register_craft({
    output = "drawers:colorable1_0",
    recipe = {
        {"group:wood", "group:wood", "group:wood"},
        {"group:dye", "default:chest", "group:dye"},
        {"group:wood", "group:wood", "group:wood"},
    }
})
core.register_craft({
    output = "drawers:colorable2_0",
    recipe = {
        {"group:wood", "default:chest", "group:wood"},
        {"group:wood", "group:dye", "group:wood"},
        {"group:wood", "default:chest", "group:wood"},
    }
})
core.register_craft({
    output = "drawers:colorable4_0",
    recipe = {
        {"default:chest", "group:wood", "default:chest"},
        {"group:wood", "group:dye", "group:wood"},
        {"default:chest", "group:wood", "default:chest"},
    }
})
