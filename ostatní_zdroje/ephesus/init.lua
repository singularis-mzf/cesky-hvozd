--
-- Node Registration
--

-- Marble
minetest.register_node("ephesus:marble", {
    description = "Marble",
    tiles = {"marble.png"},
    groups = {cracky = 3, stone = 1, ephesus_blocks = 1},
    sounds = default.node_sound_stone_defaults(),
})

--Tiles
minetest.register_node("ephesus:tiles", {
    description = "Tiles",
    tiles = {"tuile.png"},
    groups = {cracky = 3, stone = 1, ephesus_blocks = 2},
    sounds = default.node_sound_stone_defaults(),
})

-- Blue mosaic
minetest.register_node("ephesus:blue_mosaic", {
    description = "Blue mosaic",
    tiles = {"blue_mosaic.png"},
    groups = {cracky = 3, stone = 1, ephesus_blocks = 3},
    sounds = default.node_sound_stone_defaults(),
})

--Red mosaic
minetest.register_node("ephesus:red_mosaic", {
    description = "Red Mosaic",
    tiles = {"red_mosaic.png"},
    groups = {cracky = 3, stone = 1, ephesus_blocks = 4},
    sounds = default.node_sound_stone_defaults(),
})

--Ivor
minetest.register_node("ephesus:ivor", {
    description = "Ivor",
    tiles = {"ivoire.png"},
    groups = {cracky = 3, stone = 1, ephesus_blocks = 5},
    sounds = default.node_sound_stone_defaults(),
    drawtype = "glasslike",
    paramtype = "light",
    sunlight_propagates = true,
    use_texture_alpha = true,
    alpha = 180 
})



--
-- Slab Registration
--

-- Marble Slab
stairs.register_slab("ephesus:marble_slab", "ephesus:marble",
    {cracky = 3, oddly_breakable_by_hand = 1},
    {"marble.png"},
    "Marble Slab",
    default.node_sound_stone_defaults()
)

--Tiles slab
stairs.register_slab("ephesus:tiles_slab", "ephesus:tiles",
    {cracky = 3, oddly_breakable_by_hand = 1},
    {"tuile.png"},
    "Tiles Slab",
    default.node_sound_stone_defaults()
)

--Blue Mosaic slab
stairs.register_slab("ephesus:blue_mosaic_slab", "ephesus:blue_mosaic",
    {cracky = 3, oddly_breakable_by_hand = 1},
    {"blue_mosaic.png"},
    "Blue Mosaic Slab",
    default.node_sound_stone_defaults()
)

--Red Mosaic Slab
stairs.register_slab("ephesus:red_mosaic_slab", "ephesus:red_mosaic",
    {cracky = 3, oddly_breakable_by_hand = 1},
    {"red_mosaic.png"},
    "Red Mosaic Slab",
    default.node_sound_stone_defaults()
)

--Ivor Slab 
stairs.register_slab("ephesus:ivor_slab", "ephesus:ivor",
    {cracky = 3, oddly_breakable_by_hand = 1},
    {"ivoire.png"},
    "Ivor Slab",
    default.node_sound_stone_defaults()
)


--
--Stair Registration
--

-- Marble Stair
stairs.register_stair("ephesus:marble_stair", "ephesus:marble",
    {cracky = 3, oddly_breakable_by_hand = 1},
    {"marble.png"},
    "Marble Stair",
    default.node_sound_stone_defaults()
)

-- Tiles Stair
stairs.register_stair("ephesus:tiles_stair", "ephesus:tiles",
    {cracky = 3, oddly_breakable_by_hand = 1},
    {"tuile.png"},
    "Tiles Stair",
    default.node_sound_stone_defaults()
)

--Blue Mosaic Stair
stairs.register_stair("ephesus:blue_mosaic_stair", "ephesus:blue_mosaic",
    {cracky = 3, oddly_breakable_by_hand = 1},
    {"blue_mosaic.png"},
    "Blue Mosaic Stair",
    default.node_sound_stone_defaults()
)

--Blue Mosaic Stair
stairs.register_stair("ephesus:red_mosaic_stair", "ephesus:red_mosaic",
    {cracky = 3, oddly_breakable_by_hand = 1},
    {"red_mosaic.png"},
    "Red Mosaic Stair",
    default.node_sound_stone_defaults()
)

--Ivor Stair
stairs.register_stair("ephesus:ivor_stair", "ephesus:ivor",
    {cracky = 3, oddly_breakable_by_hand = 1},
    {"ivoire.png"},
    "Ivor Stair",
    default.node_sound_stone_defaults()
)

--
-- Registration of other node types
--


--Column
minetest.register_node("ephesus:marble_column", {
    description = "Marble Column",
    tiles = {"marble.png"},
    drawtype = "mesh",
    mesh = "large_column.obj",
    groups = {cracky = 2, ephesus_blocks = 6},
})

--Column Top
minetest.register_node("ephesus:hat_column", {
    description = "Marble Column Top",
    tiles = {"marble.png"},
    drawtype = "mesh",
    mesh = "hat_column.obj",
    paramtype2 = "facedir",
    groups = {cracky = 2, ephesus_blocks = 6},
})

--Medium Column
minetest.register_node("ephesus:hat_medium", {
    description = "Medium Column",
    tiles = {"marble.png"},
    drawtype = "mesh",
    mesh = "medium_column.obj",
    paramtype2 = "facedir",
    groups = {cracky = 2, ephesus_blocks = 6},
-- Boîte de sélection (selection box)
selection_box = {
    type = "fixed",
    fixed = {
        {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}, -- Pavé d'une hauteur d'un bloc
    },
},

-- Boîte de collision (collision box)
collision_box = {
    type = "fixed",
    fixed = {
        {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}, -- Pavé d'une hauteur d'un bloc et de largeur de 0,5 bloc
    },
},

})

--Meium-Column Top
minetest.register_node("ephesus:medium_column_top", {
    description = "Medium Column Top",
    tiles = {"marble.png"},
    drawtype = "mesh",
    mesh = "medium_hat_column.obj",
    paramtype2 = "facedir",
    groups = {cracky = 2, ephesus_blocks = 6},
    -- Boîte de sélection (selection box)
selection_box = {
    type = "fixed",
    fixed = {
        {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}, -- Pavé d'une hauteur d'un bloc
    },
},

-- Boîte de collision (collision box)
collision_box = {
    type = "fixed",
    fixed = {
        {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}, -- Pavé d'une hauteur d'un bloc et de largeur de 0,5 bloc
    },
},
})

--Upper Corner
minetest.register_node("ephesus:hat_angle", {
    description = "Upper Corner",
    tiles = {"marble.png"},
    drawtype = "mesh",
    mesh = "haut_angle.obj",
    paramtype2 = "facedir",
    groups = {cracky = 2, ephesus_blocks = 6},
})

--Top
minetest.register_node("ephesus:hat", {
    description = "Top",
    tiles = {"marble.png"},
    drawtype = "mesh",
    mesh = "haut.obj",
    paramtype2 = "facedir",
    groups = {cracky = 2, ephesus_blocks = 6},
})

--Pedestal
minetest.register_node("ephesus:pedestal", {
    description = "Pedestal",
    tiles = {"marble.png"},
    drawtype = "mesh",
    mesh = "socle.obj",
    groups = {cracky = 2, ephesus_blocks = 6},
})

--Slope Bottom
minetest.register_node("ephesus:slope_bottom", {
    description = "Marble Slope Bottom",
    tiles = {"marble.png"},
    drawtype = "mesh",
    mesh = "pente.obj",
    paramtype2 = "facedir",
    groups = {cracky = 2, ephesus_blocks = 6},
    -- Boîte de sélection (selection box)
selection_box = {
    type = "fixed",
    fixed = {
        {-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- Demi-bloc avec une hauteur de 0,5 bloc
    },
},

-- Boîte de collision (collision box)
collision_box = {
    type = "fixed",
    fixed = {
        {-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- Demi-bloc avec une hauteur de 0,5 bloc
    },
},

})

--Slope Top
minetest.register_node("ephesus:slope_top", {
    description = "Marble Slope Top",
    tiles = {"marble.png"},
    drawtype = "mesh",
    mesh = "pente_haut.obj",
    paramtype2 = "facedir",
    groups = {cracky = 2, ephesus_blocks = 6},
-- Boîte de sélection (selection box)
selection_box = {
    type = "fixed",
    fixed = {
        {-0.5, 0, -0.5, 0.5, 0.5, 0.5}, -- Demi-bloc supérieur avec une hauteur de 0,5 bloc
    },
},

-- Boîte de collision (collision box)
collision_box = {
    type = "fixed",
    fixed = {
        {-0.5, 0, -0.5, 0.5, 0.5, 0.5}, -- Demi-bloc supérieur avec une hauteur de 0,5 bloc
        {-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- Partie inférieure pour la collision
    },
},



})