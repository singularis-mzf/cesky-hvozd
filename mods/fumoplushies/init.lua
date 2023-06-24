local plushie_base = "fumoplushies:plushie"
local plastic_sheet = "basic_materials:plastic_sheet"
local plastic_strip = "basic_materials:plastic_strip"

local panenky = {
	cirno = {
		name = "Alena",
		recipe = {
			{"wool:blue", "dye:white", "wool:blue"},
			{"", plushie_base, ""},
			{"wool:blue", "wool:white", "wool:blue"},
		},
	},
	reimu = {
		name = "Lucie",
		recipe = {
			{"wool:red", "wool:brown", "wool:red"},
			{"", plushie_base, ""},
			{"wool:brown", "wool:red", "wool:brown"},
		},
	},
	alice = {
		name = "Alice",
		recipe = {
			{"wool:yellow", "wool:red", "wool:yellow"},
			{"", plushie_base, ""},
			{"wool:blue", "wool:black", "wool:blue"},
		},
	},
	marisa = {
		name = "Marie",
		recipe = {
			{"wool:black", "wool:dark_grey", "wool:yellow"},
			{"", plushie_base, ""},
			{"wool:black", "wool:black", "wool:black"},
		},
	},
}

minetest.register_craftitem(plushie_base, {
	description = "materiál na panenku",
	inventory_image = "fumobaseitem.png"
})


minetest.register_craft({
	output = plushie_base,
	recipe = {
		{plastic_sheet, plastic_sheet, ""},
		{plastic_strip, plastic_strip, ""},
		{plastic_sheet, plastic_sheet, ""},
	},
})

local cbox = {
	type = "fixed",
	fixed = {-0.3, -0.46, -0.4, 0.3, 0.3, 0.3},
}

local groups = {
	snappy = 2, choppy = 2, oddly_breakable_by_hand = 3,
	flammable = 3, wool = 1, doll = 1
}

for id, props in pairs(panenky) do
	minetest.register_node("fumoplushies:" .. id .. "plushie", {
		description = "panenka "..props.name,
		drawtype = "mesh",
		mesh = "fumo" .. id .. ".obj",
		tiles = {{name = "fumo" .. id .. ".png", backface_culling = true}},
		use_texture_alpha = "clip",
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		selection_box = cbox,
		collision_box = cbox,
		is_ground_content = false,
		groups = groups,
	})
	if props.recipe ~= nil then
		minetest.register_craft({type = props.craft_type, output = "fumoplushies:" .. id .. "plushie", recipe = props.recipe})
	end
end
