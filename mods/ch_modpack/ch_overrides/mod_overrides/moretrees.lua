core.override_item("moretrees:acorn", {visual_scale = 0.8})
local def = assert(core.registered_items["moretrees:cherry"])
core.override_item("moretrees:cherry", {
	groups = ch_core.assembly_groups(def.groups, {ch_food = 2}),
	on_use = ch_core.item_eat(),
})
def = assert(core.registered_items["moretrees:plum"])
core.override_item("moretrees:plum", {
	groups = ch_core.assembly_groups(def.groups, {ch_food = 2}),
	on_use = ch_core.item_eat(),
})
