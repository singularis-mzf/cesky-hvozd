unused_args = false
allow_defined_top = true

globals = {
    "yl_canned_food"
}

read_globals = {
    string = {fields = {"split"}},
    table = {fields = {"copy", "getn"}},

    -- Core
    "minetest",
    "core",

    -- Builtin
    "vector", "ItemStack",
    "dump", "DIR_DELIM", "VoxelArea", "Settings",

    -- MTG
    "default", "sfinv", "creative",

    -- depency
    "yl_api_nodestages"
}
