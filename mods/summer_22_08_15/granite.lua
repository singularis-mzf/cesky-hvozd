local defs = {
	granite = {
		description = "šedá zeď",
	},
	graniteR = {
		description = "oranžová zeď",
	},
	graniteA = {
		description = "bledá zeď",
	},
	graniteP = {
		description = "růžová zeď",
	},
	graniteB = {
		description = "nebeská zeď",
	},
	graniteBC = {
		description = "nebeská zeď, zdobená",
	},
}

for name, granite_def in pairs(defs) do
	minetest.register_node("summer:"..name, {
		description = granite_def.description,
		tiles = {name..".png"},
		groups = {cracky = 3, stone = 1},
		sounds = default.node_sound_stone_defaults(),
	})

	if minetest.get_modpath("moreblocks") and minetest.global_exists("stairsplus") then
		stairsplus:register_all("summer", name, "summer:" .. name, {
			description = granite_def.description,
			tiles = {name..".png"},
			groups = {cracky = 3},
			sounds = default.node_sound_stone_defaults(),
		})
	end
end
