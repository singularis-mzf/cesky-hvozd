--
-- mirrors
-- License:GPLv3
--

-- internationalization boilerplate
local S = minetest.get_translator(minetest.get_current_modname())

--
-- Mirrors Mod
--

minetest.register_node("mirrors:mirror", {
    description = S("Mirror"),
    inventory_image = "mirrors_mirror_inv.png",
    wield_image = "mirrors_mirror_inv.png",
    tiles = {"mirrors_mirror.png", "mirrors_mirror.png", "mirrors_mirror.png", "mirrors_mirror.png",
				"mirrors_mirror_back.png","mirrors_mirror.png"},
    groups = {mirror = 1, cracky=1},
    sounds = default.node_sound_glass_defaults(),
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, 0.375, 0.5, 0.5, 0.5 },
            },
        },
})

minetest.register_craft({
	output = "mirror:mirror",
	type = "shaped",
		recipe = {
		{"default:stick", "default:stick", "default:stick"},
		{"default:stick", "xpanes:pane_flat", "default:stick"},
		{"default:stick", "default:stick", "default:stick"},
	}
})
