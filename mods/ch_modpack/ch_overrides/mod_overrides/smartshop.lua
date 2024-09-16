local def = {
    label = "Add money inventory to smartshops",
    name = "ch_overrides:smartshop_upgrade_1",
    nodenames = table.copy(smartshop.nodes.shop_node_names),
    action = function(pos, node, dtime_s)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        if inv:get_size("money") == 0 then
            inv:set_size("money", 3)
            minetest.log("action", "Smartshop "..node.name.." at "..minetest.pos_to_string(pos).." upgraded: money inventory added.")
        end
    end,
}

minetest.register_lbm(def)
