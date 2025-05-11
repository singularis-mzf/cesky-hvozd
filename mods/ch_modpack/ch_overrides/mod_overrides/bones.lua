-- Based on code from: Bonified (https://github.com/Shqug/Bonified/blob/main/init.lua) under Apache License 2.0, by Shqug (from GitHub)
-- Here licensed under LGPLv2.1
core.override_item("bones:bones", {
    drawtype = "mesh",
    mesh = "bonified_bone_pile.obj",
    tiles = {
        "bonified_bone_pile_base.png",
        "bonified_bone_pile.png",
    },
    use_texture_alpha = "clip",
    paramtype = "light",
    paramtype2 = "4dir",
    sunlight_propagates = true,

	collision_box = {
		type = 'fixed',
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5}
	},
	selection_box = {
		type = 'fixed',
		fixed = {-0.5, -0.5, -0.5, 0.5, 1.5/16, 0.5}
	},
})
