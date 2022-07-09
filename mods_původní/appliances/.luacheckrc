ignore = {
  -- only spaces on lines
  "611",
  -- two long line
  "631",
  -- ignore unused arguments
  "212"
}

read_globals = {
  -- minetest
  "AreaStore",
  "dump",
  "minetest",
  "vector",
  "VoxelManip",
  "VoxelArea",
  "ItemStack",
  "PcgRandom",
  -- special minetest functions
  "table.copy",
  -- mods
  "unified_inventory",
  "craftguide",
  "hades_craftguide2",
  "i3",
  "technic",
  "pipeworks",
  "ele",
  "techage",
}

globals = {
  "appliances",
}

exclude_files = {
  "example/",
}
