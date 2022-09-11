std = "lua51+luajit+minetest+builtin_overrides"
unused_args = false
max_line_length = 120

stds.minetest = {
	globals = {
		"minetest",
	},
	read_globals = {
		"DIR_DELIM",
		"core",
		"dump",
		"vector",
		"nodeupdate",
		"VoxelManip",
		"VoxelArea",
		"PseudoRandom",
		"ItemStack",
		"default",
		"table",
		"math",
		"string",
	}
}

stds.builtin_overrides = {
	globals = {
		"builtin_overrides",
	},
	read_globals = {
		"futil",
	},
}
