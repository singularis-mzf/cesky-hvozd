
-- Register nodes from default / minetest_game

wrench.register_node("default:chest", {
	lists = {"main"},
})

wrench.register_node("default:chest_locked", {
	lists = {"main"},
	metas = {
		owner = wrench.META_TYPE_STRING,
		infotext = wrench.META_TYPE_STRING
	},
	owned = true,
})
