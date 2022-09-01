technic.register_grinder_recipe({input = {"doors:door_steel"}, output = "technic:wrought_iron_dust 6"})
technic.register_grinder_recipe({input = {"doors:door_obsidian_glass"}, output = "default:obsidian_shard 6"})
technic.register_grinder_recipe({input = {"doors:trapdoor_steel"}, output = "technic:wrought_iron_dust 4"})

if minetest.get_modpath("vessels") then
    technic.register_grinder_recipe({input = {"doors:door_glass"}, output = "vessels:glass_fragments 6"})
end
