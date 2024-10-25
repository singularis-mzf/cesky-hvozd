unused_args = false
allow_defined_top = false

globals = {
    "yl_canned_food_mtg"
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

    -- dependency
    "yl_canned_food", "unified_inventory"
}
