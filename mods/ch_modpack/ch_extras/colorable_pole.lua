-- barvitelná tyč
------------------
local ifthenelse = assert(ch_core.ifthenelse)
local pole_texture = ifthenelse(minetest.get_modpath("solidcolor"), "solidcolor_clay.png", "default_clay.png")
local pole_sounds = default.node_sound_metal_defaults()

local def = {
    description = "barvitelná tyč (spojující se)",
    drawtype = "nodebox",
    tiles = {
        {name = pole_texture, backface_culling = true, align_style = "world"},
    },
    node_box = {
        type = "connected",
        fixed = {-0.125, -0.125, -0.125, 0.125, 0.125, 0.125},
        connect_top = {-0.125, 0.125, -0.125, 0.125, 0.5, 0.125}, -- +Y
        connect_bottom = {-0.125, -0.5, -0.125, 0.125, -0.125, 0.125}, -- -Y
        connect_front = {-0.125, -0.125, -0.5, 0.125, 0.125, -0.125}, -- -Z
        connect_left = {-0.5, -0.125, -0.125, -0.125, 0.125, 0.125}, -- -X
        connect_back = {-0.125, -0.125, 0.125, 0.125, 0.125, 0.5}, -- +Z
        connect_right = {0.125, -0.125, -0.125, 0.5, 0.125, 0.125}, -- +X
    },
    connect_sides = {"left", "right", "top", "bottom", "front", "back"},
    connects_to = {"group:panel_pole", "group:full_cube_node",
        "group:streets_light",
        "group:technic_cnc_arch216_flange",
        "group:technic_cnc_bannerstone",
        "group:technic_cnc_block_fluted",
        "group:technic_cnc_cylinder",
        "group:technic_cnc_oct",
        "group:technic_cnc_opposedcurvededge",
        "group:technic_cnc_onecurvededge",
        "group:technic_cnc_sphere",
        "group:technic_cnc_spike",
        "group:technic_cnc_twocurvededge",
        "group:technic_cnc_valley",
    }, -- no fence, no wall
    is_ground_content = false,
    sunlight_propagates = true,
    paramtype = "light",
    paramtype2 = "color",
    palette = "unifieddyes_palette_extended.png",
    on_construct = unifieddyes.on_construct,
    on_dig = unifieddyes.on_dig,

    groups = {panel_pole = 1, oddly_breakable_by_hand = 1, cracky = 1, choppy = 1, ud_param2_colorable = 1, not_blocking_trains = 1},
    sounds = pole_sounds,
    check_for_pole = true,
}

minetest.register_node("ch_extras:colorable_pole", def)

def = {
    description = "barvitelná tyč (přímá)",
    drawtype = "nodebox",
    tiles = {
        {name = pole_texture, backface_culling = true, align_style = "world"},
    },
    node_box = {
        type = "fixed",
        fixed = {-0.125, -0.5, -0.125, 0.125, 0.5, 0.125},
    },
    is_ground_content = false,
    sunlight_propagates = true,
    paramtype = "light",
    paramtype2 = "colorwallmounted",
    palette = "unifieddyes_palette_colorwallmounted.png",
    on_construct = unifieddyes.on_construct,
    on_dig = unifieddyes.on_dig,

    groups = {panel_pole = 1, cracky = 1, choppy = 1, ud_param2_colorable = 1, not_blocking_trains = 1},
    sounds = pole_sounds,
    check_for_pole = true,
}

minetest.register_node("ch_extras:colorable_pole_flat", def)

minetest.register_craft({
    output = "ch_extras:colorable_pole_flat",
    recipe = {{"ch_extras:colorable_pole"}},
})
minetest.register_craft({
    output = "ch_extras:colorable_pole",
    recipe = {{"ch_extras:colorable_pole_flat"}},
})
minetest.register_craft({
    output = "ch_extras:colorable_pole 6",
    recipe = {
        {"dye:red", "dye:green", "dye:blue"},
        {"group:panel_pole", "group:panel_pole", "group:panel_pole"},
        {"group:panel_pole", "group:panel_pole", "group:panel_pole"},
    },
})
