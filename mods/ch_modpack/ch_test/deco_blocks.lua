local nodes = {
    x1 = {
        description = "modrá",
        texture = "ch_test_01.png",
    },
    x2 = {
        description = "žlutá",
        texture = "ch_test_02.png",
    },
    x3 = {
        description = "fialová",
        texture = "ch_test_03.png",
    }
}


for id, def in pairs(nodes) do
    ch_core.register_nodes({
        sounds = default.node_sound_stone_defaults(),
        is_ground_content = false,
    },
    {
        ["ch_test:deco_"..id] = {
            description = "dekorativní blok ("..def.description..")",
            tiles = {
                {name = def.texture, backface_culling = true},
                {name = def.texture.."^[transformR90", backface_culling = true},
                {name = def.texture, backface_culling = true},
                {name = def.texture, backface_culling = true},
                {name = def.texture.."^[transformR270", backface_culling = true},
                {name = def.texture, backface_culling = true},
            },
            drawtype = "normal",
            paramtype = "none",
            paramtype2 = "facedir",
            groups = {cracky = 3},
        },
        ["ch_test:deco_"..id.."_slab"] = {
            description = "dekorativní blok ("..def.description..") (deska)",
            tiles = {{name = def.texture, backface_culling = true}},
            drawtype = "nodebox",
            paramtype = "light",
            paramtype2 = "facedir",
            node_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, -0.5, 0.5, 1/64 - 0.5, 0.5},
			},
			selection_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, -0.5, 0.5, 1/16 - 0.5, 0.5},
			},
            groups = {cracky = 3, not_blocking_trains = 1},
        }
    }, {
        {
            output = "ch_test:deco_"..id,
            recipe = {
                {"ch_test:deco_"..id.."_slab", "ch_test:deco_"..id.."_slab", "ch_test:deco_"..id.."_slab"},
                {"ch_test:deco_"..id.."_slab", "ch_test:deco_"..id.."_slab", "ch_test:deco_"..id.."_slab"},
                {"", "", ""},
            },
        }, {
            output = "ch_test:deco_"..id.."_slab 6",
            recipe = {{"ch_test:deco_"..id}},
        }
    })
end
