if not minetest.global_exists("doors") then return end

doors.register("artdeco:estatedoor", {
	description = "luxusní dveře do vily",
	inventory_image = "artdeco_estatedoor_inv.png",
	tiles = {{ name = "artdeco_estate_door.png", backface_culling = true }},
	groups = {choppy=2,cracky=2,door=1},
 	protected = false,
	sounds = default.node_sound_stone_defaults(),
})
