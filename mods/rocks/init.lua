
--Register Rockset does all the heavy lifting for the mod:

--Name is the starting name of the rock: i.e. stone_pillar
-- Recipe_cobble and recipe_stone refer to the name of the nodes that will become hte crafting recipes
-- for this registered rockset. For sand, I reccomend sand + sandstone, etc.
-- Image: this is a plain color image that best matches the color set you are going for
function register_rockset(name, recipe_cobble, recipe_stone, image)
    --There are eight rocks to register:
    --round
    --pillar_90
    --pillar_45
    --large_flat
    --flat
    --glove
    --spike
    --stub
    
    ---Register the round rock
    minetest.register_node("rocks:".. name .."_round", {
        description = "Round " .. name .. " Rock",
        drawtype = "mesh",
        mesh = "round.obj",
        sunlight_propagates = true,
        paramtype2 = "facedir",
        collision_box = {
            type = "fixed", --Complicated Collision Boxes:
            fixed = {
                        {-0.18, -0.41, -0.8, 0.62, 0.39, -0.6},
                        {-0.6, -0.5, -0.6, 0.35, 0.5, 0.7},
                        {0.02, -0.21, -0.6, 0.77, 1.09, 0.7},
                        {-0.36, -0.35, 0.70, 0.49, 0.75, 1.02},
                        {-0.38, 0.5, -0.55, 0.02, 0.85, 0.85},
                    }
        },
        selection_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}, 
        },

        tiles = {image},
        
        groups = { cracky=2 },

    })
    
    minetest.register_craft({
        output = "rocks:".. name .."_round 1",
        recipe = {
            {"",            recipe_cobble,  ""},
            {recipe_cobble, recipe_stone,   recipe_cobble},
            {"",            recipe_cobble,  ""},
        },
    })
    
    -- Now for pillar_90
     minetest.register_node("rocks:".. name .."_pillar_90", {
        description = name .. " Pillar 90",
        drawtype = "mesh",
        mesh = "pillar_90.obj",
        sunlight_propagates = true,
        paramtype2 = "facedir",
        collision_box = {
            type = "fixed",
            fixed = {
                        {-0.23, -0.58, -0.52, 0.5, -0.28, 0.53},
                        {-0.23, -0.28, -0.32, 0.5, -0.03, 0.48},
                        {-0.23, -0.03, -0.02, 0.5,  0.67, 0.46},
                        {-0.19, -0.67, 0.20 , 0.31,-0.27, 0.66},
                    }
        },
        selection_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        },

        tiles = {image},

        
        groups = { cracky=2 },

    })

    
    minetest.register_craft({
        output = "rocks:".. name .."_pillar_90 1",
        recipe = {
            {"",    recipe_stone,   ""},
            {"",    recipe_cobble,  ""},
            {"",    recipe_cobble,  ""},
        },
    })

    -- Now for pillar_45
     minetest.register_node("rocks:".. name .."_pillar_45", {
        description = name .. " Pillar 45",
        drawtype = "mesh",
        mesh = "pillar_45.obj",
        sunlight_propagates = true,
        paramtype2 = "facedir",
        collision_box = {
            type = "fixed",
            fixed = {
                        {-0.34, -0.56, -0.40, 0.56, -0.21, 0.4},
                        {-0.32, -0.21, -0.24, 0.33, 0.14, 0.46},
                        {-0.34, -0.14, -0.12, 0.14, 0.34, 0.48},
                        {-0.47, 0.62, 0.04, -0.02, 1.0,   0.49},
                        {-0.5, 1.0,   0.34, -0.3, 1.2, 0.54   },
                    }
        },
        selection_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        },

        tiles = {image},

        
        groups = { cracky=2 },

    })

    
    minetest.register_craft({
        output = "rocks:".. name .."_pillar_45 1",
        recipe = {
            {"",    "",             recipe_stone},
            {"",    recipe_cobble,  ""},
            {"",    recipe_cobble,  ""},
        },
    })
    
    -- Now for large_flat
     minetest.register_node("rocks:".. name .."_large_flat", {
        description = "Large Flat ".. name .. " Rock",
        drawtype = "mesh",
        mesh = "large_flat.obj",
        sunlight_propagates = true,
        paramtype2 = "facedir",
        collision_box = {
            type = "fixed",
            fixed = {
                        {-1.38, -1.06, 0.11, 0.92, -0.86, 1.44},
                        {-1.62, -0.89, -0.87,1.28, 0.64,  1.53},
                        {-1.02, -0.68, -1.50,1.28, 0.62, -0.86},
                        {1.28, -0.81, -0.96, 1.58, 0.69, 1.14 },
                        {-1.55, -0.70, -0.79,1.15, 0.63, 1.41 },
                    }
        },
        selection_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        },

        tiles = {image},

        
        groups = { cracky=2 },

    })

    
    minetest.register_craft({
        output = "rocks:".. name .."_large_flat 1",
        recipe = {
            {"",                "",              ""},
            {recipe_stone,      recipe_stone,    recipe_stone},
            {recipe_cobble,     recipe_cobble,   recipe_cobble},
        },
    })
    
    -- Now for flat
     minetest.register_node("rocks:".. name .."_flat", {
        description = "Flat ".. name .. " Rock",
        drawtype = "mesh",
        mesh = "flat.obj",
        sunlight_propagates = true,
        paramtype2 = "facedir",
        collision_box = {
            type = "fixed",
            fixed = {
                        {-0.77, -0.72, -0.51, 0.83, 0.19, 0.84},
                        {-0.61, -0.57, -0.84, 0.59, 0.13, -0.49},
                        {-0.86, -0.57, -0.34, -0.75,0.13, 0.51},
                    }
        },
        selection_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        },

        tiles = {image},

        
        groups = { cracky=2 },

    })

    
    minetest.register_craft({
        output = "rocks:".. name .."_flat 1",
        recipe = {
            {"",                "",              ""},
            {recipe_stone,      recipe_stone,    ""},
            {recipe_cobble,     recipe_cobble,   ""},
        },
    })

    -- Now for glove
    minetest.register_node("rocks:".. name .."_glove", {
        description =  name .. " Glove Rock",
        drawtype = "mesh",
        mesh = "glove.obj",
        sunlight_propagates = true,
        paramtype2 = "facedir",
        collision_box = {
            type = "fixed",
            fixed = {
                        {-0.93, -0.25, -0.37, -0.23, 0.65, 0.58},
                        {-0.4, -0.36, -0.52, 0.8, 0.86, 0.48},
                        {-0.18, -0.30, -0.75, 0.72, 0.40, 0.85},
                        {-0.66, -0.24, 0.37, 0.44, 0.46, 0.87},
                        {-0.23, -0.33, 0.87, 0.47, 0.07, 1.05},
                    }
        },
        selection_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        },

        tiles = {image},

        
        groups = { cracky=2 },

    })

    
    minetest.register_craft({
        output = "rocks:".. name .."_glove 1",
        recipe = {
            {"",                "",              ""},
            {recipe_stone,      recipe_cobble,    recipe_stone},
            {"",     recipe_cobble,   ""},
        },
    })
    
    -- Now for spike
    minetest.register_node("rocks:".. name .."_spike", {
        description =  name .. " Spike",
        drawtype = "mesh",
        mesh = "spike.obj",
        sunlight_propagates = true,
        paramtype2 = "facedir",
        collision_box = {
            type = "fixed",
            fixed = {
                        {1.04, -1.49, -0.73, -0.36, -0.60, 0.87},
                        {-0.37, -1.49, -0.73, -1.27, -0.76, 0.77},
                        {0.29, -1.43, -1.05,-0.71, -0.78, -0.65},
                        {-0.20, -0.69, -0.57, -0.90, 0.21, 0.21},
                        {0.66, -0.69, -0.64, -0.34, 0.81, 0.56},
                        {0.65, 0.83, -0.39, -0.05, 1.49, 0.31},
                    }
        },
        selection_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        },

        tiles = {image},

        
        groups = { cracky=2 },

    })

    
    minetest.register_craft({
        output = "rocks:".. name .."_spike 1",
        recipe = {
            {"",                recipe_stone,              ""},
            {recipe_stone,      recipe_cobble,    recipe_stone},
            {recipe_cobble,     recipe_cobble,   recipe_cobble},
        },
    })
    
    -- Now for stub
    minetest.register_node("rocks:".. name .."_stub", {
        description =  name .. " Stub",
        drawtype = "mesh",
        mesh = "stub.obj",
        sunlight_propagates = true,
        paramtype2 = "facedir",
        collision_box = {
            type = "fixed",
            fixed = {
                        {0.56, -0.46, -0.36, -0.54, -0.04, 0.59},
                        {0.28, -0.39, -0.55, -0.32, -0.14, -0.36},
                        {0.35, -0.08, -0.21, -0.3, 0.32, 0.38},
                        {0.30, 0.32, -0.16, -0.14, 0.80, 0.24},
                    }
        },
        selection_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        },

        tiles = {image},

        
        groups = { cracky=2 },

    })

    
    minetest.register_craft({
        output = "rocks:".. name .."_stub 1",
        recipe = {
            {"",                "",              ""},
            {"",                recipe_stone,    ""},
            {recipe_cobble,     recipe_cobble,   recipe_cobble},
        },
    })
end --End register_rockset function


--------------Default Rocks Registration -------

register_rockset("stone", "default:cobble", "default:stone", "stone.png")
register_rockset("desert_sand", "default:desert_sand", "default:desert_sandstone", "desert_sand.png")
register_rockset("desert_stone", "default:desert_stone", "default:desert_cobble", "desert_stone.png")
register_rockset("sand", "default:sand", "default:sandstone", "sand.png")
register_rockset("silver_sand", "default:silver_sand", "default:silver_sandstone", "silver_sand.png")
