ch_base.open_mod(minetest.get_current_modname())
-- Licensed under CC0.
-- Painting textures from Stunt Rally <https://code.google.com/p/vdrift-ogre/>, licensed under CC0.

local paintings = {}
paintings.dyes = {
	{"white",      "White", "dekorativní malba 21: Sněžné údolí"},
	{"grey",       "Grey", "dekorativní malba 30: Horské jezero"},
	{"black",      "Black", "dekorativní malba 22: Na Blatech"},
	{"red",        "Red", "dekorativní malba 23: Vulkán"},
	{"yellow",     "Yellow", "dekorativní malba 35: Cesta"},
	{"green",      "Green", "dekorativní malba 34: Horská stezka"},
	{"cyan",       "Cyan", "dekorativní malba 33: Na horách"},
	{"blue",       "Blue", "dekorativní malba 26: Pláž"},
	{"magenta",    "Magenta", "dekorativní malba 28: Oáza"},
	{"orange",     "Orange", "dekorativní malba 27: Útesy pouště"},
	{"violet",     "Violet", "dekorativní malba 24: Fialová fantazie"},
	{"brown",      "Brown", "dekorativní malba 25: Podzimní louka"},
	{"pink",       "Pink", "dekorativní malba 29: Západ/východ slunce 2"},
	{"dark_grey",  "Dark Grey", "dekorativní malba 31: Tajuplný les"},
	{"dark_green", "Dark Green", "dekorativní malba 32: Močál"},
}

local selection_box = minetest.registered_nodes["homedecor:painting_1"].selection_box

for _, row in ipairs(paintings.dyes) do
	local name = row[1]
	local desc = row[2]
	minetest.register_node("paintings:" .. name, {
		description = row[3],
		drawtype = "mesh",
		mesh = "homedecor_painting.obj",
		tiles = {"default_wood.png", "homedecor_blank_canvas.png", "paintings_" .. name .. ".png"},
		--[[ inventory_image = "paintings_" .. name .. ".png",
		wield_image = "paintings_" .. name .. ".png", ]]
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		walkable = false,
		selection_box = selection_box,
		groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3, flammable = 3},
		sounds = default.node_sound_wood_defaults(),
	})
	minetest.register_craft({
		output = "paintings:" .. name,
		recipe = {
			{"group:stick", "", ""},
			{"dye:"..name, "", ""},
			{"homedecor:blank_canvas", "", ""},
		}
	})
end
ch_base.close_mod(minetest.get_current_modname())
