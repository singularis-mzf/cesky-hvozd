-- ch_extras:fence_hv
---------------------------------------------------------------
if not minetest.get_modpath("technic") then return end

default.register_fence("ch_extras:fence_hv", {
    description = "výstražný plot",
    texture = "technic_hv_cable.png^[colorize:#91754d:40",
    inventory_image = "default_fence_overlay.png^technic_hv_cable.png^[colorize:#91754d:40^default_fence_overlay.png^[makealpha:255,126,126",
    wield_image = "default_fence_overlay.png^technic_hv_cable.png^[colorize:#91754d:40^default_fence_overlay.png^[makealpha:255,126,126",
    material = "technic:hv_cable",
    groups = {choppy = 2, oddly_breakable_by_hand = 2, technic_hv_cablelike = 1},
    sounds = default.node_sound_wood_defaults(),
    check_for_pole = true,
    connects_to = {"group:fence", "group:wood", "group:tree", "group:wall", "group:technic_hv_cable"},
})

default.register_fence_rail("ch_extras:fence_rail_hv", {
    description = "výstražné zábradlí",
    texture = "technic_hv_cable.png^[colorize:#91754d:40",
    inventory_image = "default_fence_rail_overlay.png^technic_hv_cable.png^[colorize:#91754d:40^default_fence_rail_overlay.png^[makealpha:255,126,126",
    wield_image = "default_fence_rail_overlay.png^technic_hv_cable.png^[colorize:#91754d:40^default_fence_rail_overlay.png^[makealpha:255,126,126",
    material = "technic:hv_cable",
    groups = {choppy = 2, oddly_breakable_by_hand = 2},
    sounds = default.node_sound_wood_defaults(),
})
