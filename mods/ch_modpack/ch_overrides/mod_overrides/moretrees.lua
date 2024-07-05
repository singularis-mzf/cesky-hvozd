minetest.override_item("moretrees:acorn", {visual_scale = 0.8})
minetest.override_item("moretrees:cherry", {
	groups = {fleshy=3, dig_immediate=3, flammable=2, leafdecay = 1, leafdecay_drop = 1, ch_food = 2},
	on_use = ch_core.item_eat(),
})
