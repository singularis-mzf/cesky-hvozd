if minetest.get_modpath("vessels") then
    technic.register_grinder_recipe({input = {"xpanes:pane_flat 8"}, output = "vessels:glass_fragments 3"})
end

technic.register_grinder_recipe({input = {"xpanes:bar_flat 8"}, output = "technic:wrought_iron_dust 3"})
technic.register_grinder_recipe({input = {"xpanes:obsidian_pane_flat 8"}, output = "default:obsidian_shard 3"})
