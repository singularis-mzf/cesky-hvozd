if minetest.get_modpath("ch_extras") and minetest.registered_nodes["basic_materials:concrete_block"] ~= nil then
    ch_extras.register_arcade("ch_overrides:concrete_arcade", "basic_materials:concrete_block")
end
