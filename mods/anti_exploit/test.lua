assert(core == minetest)
assert(modlib.table.equals_noncircular(get_accessible_inventories("list[context;main;0,0;4,2;42]")["context;main"], {{min = 42, max = 50}}))