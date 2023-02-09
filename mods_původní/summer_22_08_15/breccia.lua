--BRECCIA
minetest.register_node("summer:breccia", {
	description = "Breccia",
	tiles = {"breccia.png"},
	groups = {crumbly = 2, falling_node = 1},
    --groups = {cracky = 3, stone = 1},
	drop = '"summer:pietra" 9',
	--legacy_mineral = true,
	is_ground_content = true, -- 
    sounds = default.node_sound_gravel_defaults(),
	--sounds = default.node_sound_stone_defaults(),
})
minetest.register_node("summer:breccia_2", {
	description = "BrecciaB  ",
	tiles = {"breccia2.png"},
	groups = {crumbly = 2, falling_node = 1},
    --groups = {cracky = 3, stone = 1},
	drop = '"summer:pietraA" 9',
	--legacy_mineral = true,
    sounds = default.node_sound_gravel_defaults(),
	--sounds = default.node_sound_stone_defaults(),
})
    minetest.register_node("summer:desert_breccia_2", {
	description = "Red Breccia",
	tiles = {"desert_breccia2.png"},
	groups = {crumbly = 2, falling_node = 1},
    --groups = {cracky = 3, stone = 1},
	drop = '"summer:desert_pietra" 9',
	--legacy_mineral = true,
    sounds = default.node_sound_gravel_defaults(),
	--sounds = default.node_sound_stone_defaults(),
})    
minetest.register_node("summer:desert_breccia", {
	description = "Desert Breccia",
	tiles = {"desert_breccia.png"},
	groups = {crumbly = 2, falling_node = 1},
    --groups = {cracky = 3, stone = 1},
	drop = '"summer:pietraP" 9',
	--legacy_mineral = true,
    sounds = default.node_sound_gravel_defaults(),
	--sounds = default.node_sound_stone_defaults(),
})  
   


