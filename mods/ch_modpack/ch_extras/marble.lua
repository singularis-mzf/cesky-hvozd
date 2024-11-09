-- ch_extras:marble
---------------------------------------------------------------
local def = {
	description = "venkovní mramor",
	tiles = {{name = "ch_extras_nehodiv.png"}},
	groups = {cracky = 2, stone = 1},
}

minetest.register_node("ch_extras:marble", table.copy(def))
minetest.register_alias("jonez:marble", "ch_extras:marble")

stairsplus:register_all("ch_extras", "marble", "ch_extras:marble", def)
