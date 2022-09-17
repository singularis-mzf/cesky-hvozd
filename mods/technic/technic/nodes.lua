
local S = technic.getter

minetest.register_node("technic:warning_block", {
	description = S("Warning Block"),
	tiles = {"technic_hv_cable.png"},
	paramtype2 = "facedir",
	groups = {cracky = 1},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = "technic:warning_block",
	recipe = {
		{"basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "dye:yellow"},
		{"basic_materials:plastic_sheet", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet"},
		{"dye:black", "basic_materials:plastic_sheet", "basic_materials:plastic_sheet"},
	},
})

local row = {"technic:hv_cable_plate_1", "technic:hv_cable_plate_1", "technic:hv_cable_plate_1"}
minetest.register_craft({
	output = "technic:warning_block",
	recipe = {
		row,
		row,
		{"", "", ""},
	},
})
