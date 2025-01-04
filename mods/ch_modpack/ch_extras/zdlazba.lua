-- ch_extras:zdlazba
---------------------------------------------------------------
local def = {
	description = "zámková dlažba",
	tiles = {{name = "ch_extras_zdlazba.png"}},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {cracky = 2, stone = 1},
	sounds = default.node_sound_stone_defaults(),
}
minetest.register_node("ch_extras:zdlazba", def)

stairsplus:register_all("ch_extras", "zdlazba", "ch_extras:zdlazba", def)
def = table.copy(def)
def.description = "červená zámková dlažba"
def.tiles = {{name = "ch_extras_zdlazba.png^[multiply:#cc6666"}}

minetest.register_node("ch_extras:cervzdlazba", def)
stairsplus:register_all("ch_extras", "cervzdlazba", "ch_extras:cervzdlazba", def)

minetest.register_craft({
	output = "ch_extras:zdlazba 5",
	recipe = {
		{"default:cobble", "", "default:cobble"},
		{"", "default:cobble", ""},
		{"default:cobble", "", "default:cobble"},
	},
})

minetest.register_craft({
	output = "ch_extras:cervzdlazba 5",
	recipe = {
		{"default:desert_cobble", "", "default:desert_cobble"},
		{"", "default:desert_cobble", ""},
		{"default:desert_cobble", "", "default:desert_cobble"},
	},
})
minetest.register_craft({
	output = "ch_extras:zdlazba 4",
	type = "shapeless",
	recipe = {"moreblocks:sweeper", "ch_extras:colorable_zdlazba", "ch_extras:colorable_zdlazba",
		"ch_extras:colorable_zdlazba", "ch_extras:colorable_zdlazba"},
})

if minetest.get_modpath("unifieddyes") then
	def = table.copy(def)
	def.description = "barevná zámková dlažba"
	def.tiles = {{name = "ch_extras_zdlazba.png^[invert:rgb^[multiply:#AAAAAA^[invert:rgb"}}
	def.paramtype2 = "color4dir"
	def.palette = "unifieddyes_palette_color4dir.png"
	def.groups = {cracky = 2, stone = 1, ud_param2_colorable = 1}
	def.on_construct = unifieddyes.on_construct
	def.on_dig = unifieddyes.on_dig

	minetest.register_node("ch_extras:colorable_zdlazba", table.copy(def))

	def.description = "barevná zámková dlažba (kryt)"
	def.drawtype = "nodebox"
	def.node_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, -0.5 + 1/32, 0.5}},
	}
	def.groups = {cracky = 2, ud_param2_colorable = 1}

	minetest.register_node("ch_extras:colorable_zdlazba_1", def)

	minetest.register_craft({
		output = "ch_extras:colorable_zdlazba 2",
		recipe = {
			{"ch_extras:zdlazba", "ch_extras:zdlazba"},
			{"", ""},
		},
	})
	minetest.register_craft({
		output = "ch_extras:colorable_zdlazba_1 2",
		recipe = {
			{"ch_extras:slab_zdlazba_1", "ch_extras:slab_zdlazba_1"},
			{"", ""},
		},
	})
	minetest.register_craft({
		output = "ch_extras:colorable_zdlazba_1",
		type = "shapeless",
		recipe = {
			"ch_extras:colorable_zdlazba_1", "ch_extras:colorable_zdlazba_1", "ch_extras:colorable_zdlazba_1", "ch_extras:colorable_zdlazba_1",
			"ch_extras:colorable_zdlazba_1", "ch_extras:colorable_zdlazba_1", "ch_extras:colorable_zdlazba_1", "ch_extras:colorable_zdlazba_1",
		},
	})
end
