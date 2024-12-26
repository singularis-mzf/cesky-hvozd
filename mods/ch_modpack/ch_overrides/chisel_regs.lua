local groups = {
    {"homedecor:ground_lantern_14", "homedecor:ground_lantern_0"},
    {"homedecor:hanging_lantern_14", "homedecor:hanging_lantern_0"},
    {"homedecor:wall_lamp_on", "homedecor:wall_lamp_off"},
    {"homedecor:ceiling_lamp_14", "homedecor:ceiling_lamp_0"},
    {"homedecor:lattice_lantern_small_14", "homedecor:lattice_lantern_small_0"},
    {"homedecor:glowlight_small_cube_14", "homedecor:glowlight_small_cube_0"},
    {"homedecor:table_lamp_14", "homedecor:table_lamp_0"},
    {"homedecor:plasma_ball_on", "homedecor:plasma_ball_off"},
    {"homedecor:tv", "homedecor:tv_off"},
    {"homedecor:plasma_lamp_14", "homedecor:plasma_lamp_0"},
    {"homedecor:desk_lamp_14", "homedecor:desk_lamp_0"},
    {"homedecor:standing_lamp_14", "homedecor:standing_lamp_0"},
    {"homedecor:glowlight_quarter_14", "homedecor:glowlight_quarter_0"},
    {"homedecor:glowlight_half_14", "homedecor:glowlight_half_0"},
    {"homedecor:ceiling_lantern_14", "homedecor:ceiling_lantern_0"},
}

for _, group in ipairs(groups) do
    if core.registered_nodes[group[1]] ~= nil and core.registered_nodes[group[2]] ~= nil then
        ch_core.register_shape_selector_group({nodes = {
            {name = group[1], label = "zap"},
            {name = group[2], label = "vyp"},
        }})
    end
end

ch_core.register_shape_selector_group({nodes = {
    "default:torch_wall",
    {name = "real_torch:torch_wall", oneway = true},
}})

ch_core.register_shape_selector_group{nodes = {
    "cottages:glass_pane",
    "cottages:glass_pane_side",
}}
