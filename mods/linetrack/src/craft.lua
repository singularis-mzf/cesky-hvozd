core.register_craft({
    output = "advtrains:boat",
    recipe = {
        {"moreblocks:slab_obsidian_glass_2", "doors:door_steel", "moreblocks:slab_obsidian_glass_2"},
        {"default:steelblock", "summer:barca_blue_item", "default:steelblock"},
        {"default:steelblock", "default:steelblock", "default:steelblock"},
    },
})

core.register_craft({
    output = "advtrains:bus",
    recipe = {
        {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
        {"default:steel_ingot", "minitram_crafting_recipes:minitram_door", "default:steel_ingot"},
        {"technic:rubber", "", "technic:rubber"},
    },
})

core.register_craft({
    output = "linetrack:invisible_platform 8",
    recipe = {
        {"dye:yellow", "default:glass"},
        {"default:glass", "default:glass"},
    },
})

core.register_craft({
    output = "linetrack:watertrack_placer 50",
    recipe = {
        {"dye:white", "default:stick", "dye:white"},
        {"dye:white", "default:stick", "dye:white"},
        {"dye:white", "default:stick", "dye:white"},
    },
})

core.register_craft({
    output = "linetrack:watertrack_slopeplacer 3",
    recipe = {
        {"", "", "linetrack:watertrack_placer"},
        {"", "linetrack:watertrack_placer", ""},
        {"linetrack:watertrack_placer", "", ""},
    },
})

core.register_craft({
    output = "linetrack:road_tcb_node",
    recipe = {{"linetrack:watertrack_placer", "advtrains_interlocking:tcb_node"}, {"", ""}},
})

core.register_craft({
    output = "linetrack:tcb_node",
    recipe = {{"advtrains_interlocking:tcb_node", "linetrack:watertrack_placer"}, {"", ""}},
})

core.register_craft({
    output = "linetrack:signal_danger",
    recipe = {{"advtrains_signals_ks:hs_danger_0", "linetrack:watertrack_placer"}, {"", ""}}
})

core.register_craft({
    output = "linetrack:watertrack_spd_placer",
    recipe = {
        {"advtrains_signals_ks:sign_8_0", "linetrack:watertrack_placer"},
        {"", ""},
    },
})

core.register_craft({
    output = "linetrack:watertrack_atc_placer",
    recipe = {
        {"mesecons_microcontroller:microcontroller0000", ""},
        {"linetrack:watertrack_placer", ""},
    },
})

core.register_craft({
    output = "linetrack:road_signal_danger",
    recipe = {{"linetrack:watertrack_placer", "advtrains_signals_ks:hs_danger_0"}, {"", ""}}
})

core.register_craft({
    output = "linetrack:watertrack_stn_placer 2",
    recipe = {
        {"default:coal_lump", ""},
        {"linetrack:watertrack_placer", "linetrack:watertrack_placer"},
    },
})
