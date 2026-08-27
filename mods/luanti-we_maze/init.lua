ch_base.open_mod(minetest.get_current_modname())
futil.check_version({ year = 2024, month = 2, day = 18 }) -- SparseGraph

we_maze = fmod.create()

we_maze.dofile("algorithm", "init")
we_maze.dofile("mazegen")
we_maze.dofile("chatcommand")
ch_base.close_mod(minetest.get_current_modname())