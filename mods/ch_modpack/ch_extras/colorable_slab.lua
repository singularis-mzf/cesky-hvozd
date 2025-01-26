local common_def = {
    description = "lakovaná deska 1/64",
	drawtype = "nodebox",
    tiles = {"ch_core_white_pixel.png"},
	paramtype = "light",
	paramtype2 = "color",
    palette = "unifieddyes_palette_extended.png",
    is_ground_content = false,
	sunlight_propagates = true,
    groups = {not_in_creative_inventory = 1, cracky = 3},
    sounds = default.node_sound_stone_defaults(),
    on_construct = unifieddyes.on_construct,
    on_dig = unifieddyes.on_dig,
    drop = {items = {{items = {"ch_extras:colorable_slab_0"}, inherit_color = true}}},
}
local w = 1/64
local aabb = {-0.5, -0.5, -0.5, 0.5, w - 0.5, 0.5}

ch_core.register_nodes(common_def, {
    ["ch_extras:colorable_slab_0"] = {
        node_box = {type = "fixed", fixed = aabb},
        groups = ch_core.assembly_groups(common_def.groups, {not_in_creative_inventory = 0}),
    },
    ["ch_extras:colorable_slab_1"] = {
        node_box = {type = "fixed", fixed = ch_core.rotate_aabb_by_facedir(aabb, 4)},
    },
    ["ch_extras:colorable_slab_2"] = {
        node_box = {type = "fixed", fixed = ch_core.rotate_aabb_by_facedir(aabb, 8)},
    },
    ["ch_extras:colorable_slab_3"] = {
        node_box = {type = "fixed", fixed = ch_core.rotate_aabb_by_facedir(aabb, 12)},
    },
    ["ch_extras:colorable_slab_4"] = {
        node_box = {type = "fixed", fixed = ch_core.rotate_aabb_by_facedir(aabb, 16)},
    },
    ["ch_extras:colorable_slab_5"] = {
        node_box = {type = "fixed", fixed = ch_core.rotate_aabb_by_facedir(aabb, 20)},
    },
}, {
    {
        output = "ch_extras:colorable_slab_0 8",
        recipe = {{"ch_extras:colorable_plastic"}},
    }, {
        output = "ch_extras:colorable_plastic",
        recipe = {
            {"ch_extras:colorable_slab_0", "ch_extras:colorable_slab_0", "ch_extras:colorable_slab_0"},
            {"ch_extras:colorable_slab_0", "ch_extras:colorable_slab_0", "ch_extras:colorable_slab_0"},
            {"ch_extras:colorable_slab_0", "ch_extras:colorable_slab_0", "ch_extras:colorable_slab_0"},
        },
    }
})

local nodedir_group = {}
for i = 0, 23 do
    nodedir_group[i] = "ch_extras:colorable_slab_"..math.floor(i / 4)
end
ch_core.register_nodedir_group(nodedir_group)
