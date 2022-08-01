unused_args = false
allow_defined_top = false

globals = {
    "minetest",
    "player_api",
    "armor",
    "dye",
    "closet",
    "vanity"
}

read_globals = {
    string = {fields = {"split"}},
    table = {fields = {"copy", "getn"}},

    -- Builtin
    "vector", "ItemStack",
    "dump", "DIR_DELIM", "VoxelArea", "Settings",

    -- MTG
    "default", "sfinv", "creative",
}
