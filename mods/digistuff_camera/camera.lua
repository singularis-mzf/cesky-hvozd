minetest.register_node("digistuff_camera:camera", {
	tiles = {
		"digistuff_camera_top.png",
		"digistuff_camera_bottom.png",
		"digistuff_camera_right.png",
		"digistuff_camera_left.png",
		"digistuff_camera_back.png",
		"digistuff_camera_front.png",
	},
	groups = {cracky=2},
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
				{-0.1,-0.5,-0.28,0.1,-0.3,0.3}, --Camera Body
				{-0.045,-0.42,-0.34,0.045,-0.36,-0.28}, -- Lens
				{-0.05,-0.9,-0.05,0.05,-0.5,0.05}, --Pole
			}
	},
	selection_box = {
		type = "fixed",
		fixed = {
				{-0.1,-0.5,-0.34,0.1,-0.3,0.3}, --Camera Body
			}
	},
	description = "kamera",
	sounds = default and default.node_sound_stone_defaults()
})

minetest.register_craft({
	output = "digistuff_camera:camera",
	recipe = {
		{"basic_materials:plastic_sheet","basic_materials:plastic_sheet","basic_materials:plastic_sheet"},
		{"default:glass","basic_materials:ic","mesecons_luacontroller:luacontroller0000"},
		{"basic_materials:plastic_sheet","basic_materials:plastic_sheet","basic_materials:plastic_sheet"},
	}
})
