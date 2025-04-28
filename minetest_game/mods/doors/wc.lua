local door_a = {
    hidden_red = "doors:hidden_red_a",
    hidden_green = "doors:hidden_green_a",
    inside_mode = "a",
}
local door_b = {
    hidden_red = "doors:hidden_red_b",
    hidden_green = "doors:hidden_green_b",
    inside_mode = "b",
}
doors.wc_config = {
    ["door_a.obj"] = door_a,
    ["homedecor_3d_door_wood_a.obj"] = door_a,
    ["homedecor_3d_door_steel_a.obj"] = door_a,
    ["door_a2.obj"] = {
        hidden_red = "doors:hidden_red_b",
        hidden_green = "doors:hidden_green_b",
    },
    ["door_b.obj"] = door_b,
    ["homedecor_3d_door_wood_b.obj"] = door_b,
    ["homedecor_3d_door_steel_b.obj"] = door_b,
    ["door_b2.obj"] = {
        hidden_red = "doors:hidden_red_a",
        hidden_green = "doors:hidden_green_a",
    },
    ["doors_cdoor_a.obj"] = {
        hidden_red = "doors:hidden_red_ca",
        hidden_green = "doors:hidden_green_ca",
        inside_mode = "ca",
    },
    ["doors_cdoor_a2.obj"] = {
        hidden_red = "doors:hidden_red_ca2",
        hidden_green = "doors:hidden_green_ca2",
    },
    ["doors_cdoor_b.obj"] = {
        hidden_red = "doors:hidden_red_cb",
        hidden_green = "doors:hidden_green_cb",
        inside_mode = "cb",
    },
    ["doors_cdoor_b2.obj"] = {
        hidden_red = "doors:hidden_red_cb2",
        hidden_green = "doors:hidden_green_cb2",
    },
}
