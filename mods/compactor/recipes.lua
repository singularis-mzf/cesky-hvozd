compactor.register_compactor_recipe({input = {"basic_materials:brass_ingot 9"}, output = "basic_materials:brass_block"})

compactor.register_compactor_recipe({input = {"default:bronze_ingot 9"}, output = "default:bronzeblock"})
compactor.register_compactor_recipe({input = {"default:coal_lump 9"}, output = "default:coalblock"})
compactor.register_compactor_recipe({input = {"default:copper_ingot 9"}, output = "default:copperblock"})
compactor.register_compactor_recipe({input = {"default:clay_brick 4"}, output = "default:brick"})
compactor.register_compactor_recipe({input = {"default:clay_lump 4"}, output = "default:clay"})
compactor.register_compactor_recipe({input = {"default:diamond 9"}, output = "default:diamondblock"})
compactor.register_compactor_recipe({input = {"default:gold_ingot 9"}, output = "default:goldblock"})
compactor.register_compactor_recipe({input = {"default:mese_crystal 9"}, output = "default:mese"})
compactor.register_compactor_recipe({input = {"default:mese_crystal_fragment 9"}, output = "default:mese_crystal"})
compactor.register_compactor_recipe({input = {"default:obsidian_shard 9"}, output = "default:obsidian"})
compactor.register_compactor_recipe({input = {"default:steel_ingot 9"}, output = "default:steelblock"})
compactor.register_compactor_recipe({input = {"default:tin_ingot 9"}, output = "default:tinblock"})

compactor.register_compactor_recipe({input = {"technic:carbon_steel_ingot 9"}, output = "technic:carbon_steel_block"})
compactor.register_compactor_recipe({input = {"technic:chromium_ingot 9"}, output = "technic:chromium_block"})
compactor.register_compactor_recipe({input = {"technic:lead_ingot 9"}, output = "technic:lead_block"})
compactor.register_compactor_recipe({input = {"technic:stainless_steel_ingot 9"}, output = "technic:stainless_steel_block"})
compactor.register_compactor_recipe({input = {"technic:zinc_ingot 9"}, output = "technic:zinc_block"})

if minetest.get_modpath("df_farming") then
    compactor.register_compactor_recipe({input = {"df_farming:cave_wheat 3"}, output = "df_farming:cave_straw"})
end

if minetest.get_modpath("ethereal") then
    compactor.register_compactor_recipe({input = {"ethereal:crystal_ingot 9"}, output = "ethereal:crystal_block"})
end

if minetest.get_modpath("farming") then
    compactor.register_compactor_recipe({input = {"farming:wheat 3"}, output = "farming:straw"})
    
    if farming.mod and farming.mod == "redo" then
        compactor.register_compactor_recipe({input = {"farming:hemp_fibre 9"}, output = "farming:hemp_block"})
        compactor.register_compactor_recipe({input = {"farming:melon_slice 4"}, output = "farming:melon_8"})
        compactor.register_compactor_recipe({input = {"farming:salt 9"}, output = "farming:salt_crystal"})
    end
end

if minetest.get_modpath("moreores") then
    compactor.register_compactor_recipe({input = {"moreores:mithril_ingot 9"}, output = "moreores:mithril_block"})
    compactor.register_compactor_recipe({input = {"moreores:silver_ingot 9"}, output = "moreores:silver_block"})
end

if minetest.get_modpath("terumet") then
    compactor.register_compactor_recipe({input = {"terumet:item_ceramic 9"}, output = "terumet:block_ceramic"})
    compactor.register_compactor_recipe({input = {"terumet:ingot_cgls 9"}, output = "terumet:block_cgls"})
    compactor.register_compactor_recipe({input = {"terumet:item_dust_bio 9"}, output = "terumet:block_dust_bio"})
    compactor.register_compactor_recipe({input = {"terumet:item_tarball 8"}, output = "terumet:block_tar"})
    compactor.register_compactor_recipe({input = {"terumet:ingot_tcha 9"}, output = "terumet:block_tcha"})
    compactor.register_compactor_recipe({input = {"terumet:ingot_tcop 9"}, output = "terumet:block_tcop"})
    compactor.register_compactor_recipe({input = {"terumet:ingot_tgol 9"}, output = "terumet:block_tgol"})
    compactor.register_compactor_recipe({input = {"terumet:item_thermese 9"}, output = "terumet:block_thermese"})
    compactor.register_compactor_recipe({input = {"terumet:ingot_tste 9"}, output = "terumet:block_tste"})
    compactor.register_compactor_recipe({input = {"terumet:ingot_ttin 9"}, output = "terumet:block_ttin"})
    compactor.register_compactor_recipe({input = {"terumet:ingot_raw 9"}, output = "terumet:block_raw"})
    compactor.register_compactor_recipe({input = {"terumet:item_coke 9"}, output = "terumet:block_coke"})
end
