local S = minetest.get_translator("ch_decor")
local def

def = {
	description = "červené šupiny",
	drawtype = "normal",
	tiles = {"petz_red_gables.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_gravel_defaults()
}

minetest.register_node(":petz:red_gables", table.copy(def))

if minetest.get_modpath("moreblocks") then
	stairsplus:register_slabs_and_slopes("petz", "red_gables", "petz:red_gables", table.copy(def))
end

def.description = "barvitelné šupiny"
def.tiles = {"petz_grey_gables.png"}
def.groups = {cracky = 3, oddly_breakable_by_hand = 3, ud_param2_colorable = 1}
def.paramtype2 = "color"
def.palette = "unifieddyes_palette_extended.png"

minetest.register_node(":petz:colorable_gables", def)

minetest.register_craft({
	output = "petz:colorable_gables",
	recipe = {
		{"", "basic_materials:plastic_strip", ""},
		{"basic_materials:plastic_strip", "basic_materials:plastic_strip", "basic_materials:plastic_strip"},
		{"", "basic_materials:plastic_strip", ""},
	},
})
minetest.register_craft({
	output = "petz:red_gables",
	recipe = {
		{"dye:red", "", "dye:red"},
		{"", "petz:colorable_gables", ""},
		{"", "", ""},
	},
})

def = {
	description = "včelí vosk",
	inventory_image = "petz_honeycomb.png",
	wield_image = "petz_honeycomb.png",
}

minetest.register_craftitem(":petz:honeycomb", def)

def = {
	description = "cukrová špejle",
	inventory_image = "petz_candy_cane.png",
	wield_image = "petz_candy_cane.png",
	on_use = ch_core.item_eat(),
	groups = {food = 1, food_sugar = 1, ch_food = 4},
}
minetest.register_craftitem(":petz:candy_cane", def)

minetest.register_craft({
	output = "petz:candy_cane",
	recipe = {
		{"farming:sugar", "farming:sugar", "farming:sugar"},
		{"farming:sugar", "", "farming:sugar"},
		{"farming:sugar", "", ""},
	},
})

def = {
	description = "injekční stříkačka",
	inventory_image = "petz_glass_syringe.png",
	wield_image = "petz_glass_syringe.png",
}
minetest.register_tool(":petz:glass_syringe", def)

minetest.register_craft({
	output = "petz:glass_syringe",
	recipe = {
		{"basic_materials:plastic_sheet", "", ""},
		{"", "basic_materials:plastic_sheet", ""},
		{"", "", "default:steel_ingot"},
	},
})

def = {
	description = "sbírka motýlů",
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 1,
	tiles = {"petz_butterfly_showcase.png"},
	inventory_image = "petz_butterfly_showcase.png",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 0.5 - 1/16, 0.5, 0.5, 0.5},
	},
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 3, oddly_breakable_by_hand = 3, flammable = 3},
	sounds = default.node_sound_glass_defaults(),
}

minetest.register_node(":petz:butterfly_showcase", def)

minetest.register_craft({
	output = "petz:butterfly_showcase",
	recipe = {
		{"butterflies:bufferfly_white", "butterflies:bufferfly_red", "default:glass"},
		{"butterflies:bufferfly_violet", "butterflies:bufferfly_white", "butterflies:bufferfly_red"},
		{"butterflies:bufferfly_red", "butterflies:bufferfly_violet", "butterflies:bufferfly_white"},
	},
})
