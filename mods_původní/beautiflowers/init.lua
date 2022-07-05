beautiflowers = {}
local mpath = minetest.get_modpath("beautiflowers")
local pot = minetest.get_modpath("flowerpot")

beautiflowers.flowers ={

    {"bonsai_1","green", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"bonsai_2","brown", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"bonsai_3","green", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"bonsai_4","brown", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"bonsai_5","dark_green", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},

    {"pasto_1","dark_green", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"pasto_2","dark_green", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"pasto_3","dark_green", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"pasto_4","dark_green", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"pasto_5","dark_green", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"pasto_6","dark_green", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"pasto_7","dark_green", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"pasto_8","dark_green", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"pasto_9","dark_green", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"pasto_10","dark_green",{-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},

    {"arcoiris","red", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"ada","yellow", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"agnes","yellow", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"alicia","yellow", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"alma","yellow", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"amaia","yellow", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"any","yellow", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"anastasia","yellow", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"astrid","blue", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"beatriz","blue", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"belen","violet", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"berta","blue", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"blanca","blue", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"carla","white", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"casandra","blue", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"clara","blue", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"claudia","blue", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"cloe","white", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"cristina","pink", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"dafne","orange", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"dana","orange", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"delia","orange", {-2 / 16, -0.5, -2 / 16, 2 / 16, 6 / 16, 2 / 16}},
    {"elena","orange", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"erica","orange", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"estela","orange", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"eva","orange", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"fabiola","orange", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"fiona","orange", {-2 / 16, -0.5, -2 / 16, 2 / 16, 6 / 16, 2 / 16}},
    {"gala","orange", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"gisela","pink", {-2 / 16, -0.5, -2 / 16, 2 / 16, 6 / 16, 2 / 16}},
    {"gloria","white", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"irene","white", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"ingrid","white", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"iris","white", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"ivette","white", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"jennifer","orange", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"lara","red", {-2 / 16, -0.5, -2 / 16, 2 / 16, -2 / 16, 2 / 16}},
    {"laura","red", {-2 / 16, -0.5, -2 / 16, 2 / 16, -2 / 16, 2 / 16}},
    {"lidia","red", {-2 / 16, -0.5, -2 / 16, 2 / 16, -2 / 16, 2 / 16}},
    {"lucia","red", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"mara","red", {-5 / 16, -0.5, -5 / 16, 5 / 16, 2 / 16, 5 / 16}},
    {"martina","orange", {-2 / 16, -0.5, -2 / 16, 2 / 16, 6 / 16, 2 / 16}},
    {"melania","orange", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"mireia","red", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"nadia","red", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"nerea","red", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"noelia","red", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"noemi","violet", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"olimpia","magenta", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"oriana","magenta", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"pia","pink", {-2 / 16, -0.5, -2 / 16, 2 / 16, 0 / 16, 2 / 16}},
    {"raquel","pink", {-2 / 16, -0.5, -2 / 16, 2 / 16, 0 / 16, 2 / 16}},
    {"ruth","pink", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"sandra","pink", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"sara","pink", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"silvia","pink", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"sofia","pink", {-2 / 16, -0.5, -2 / 16, 2 / 16, -2 / 16, 2 / 16}},
    {"sonia","pink", {-2 / 16, -0.5, -2 / 16, 2 / 16, -1 / 16, 2 / 16}},
    {"talia","pink", {-2 / 16, -0.5, -2 / 16, 2 / 16, 6 / 16, 2 / 16}},
    {"thais","cyan", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"valeria","cyan", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"valentina","cyan", {-2 / 16, -0.5, -2 / 16, 2 / 16, -2 / 16, 2 / 16}},
    {"vera","cyan", {-2 / 16, -0.5, -2 / 16, 2 / 16, 3 / 16, 2 / 16}},
    {"victoria","cyan", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"xenia","cyan", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"zaida","cyan", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"virginia","cyan", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"nazareth","violet", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"arleth","violet", {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}},
    {"miriam","violet", {-5 / 16, -0.5, -5 / 16, 5 / 16, -1 / 16, 5 / 16}},
    {"minerva","violet", {-2 / 16, -0.5, -2 / 16, 2 / 16, 6 / 16, 2 / 16}},
    {"vanesa","violet", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"sabrina","red", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"rocio","violet", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"regina","violet", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"paula","violet", {-2 / 16, -0.5, -2 / 16, 2 / 16, -2 / 16, 2 / 16}},
    {"olga","violet", {-2 / 16, -0.5, -2 / 16, 2 / 16, -2 / 16, 2 / 16}},
    {"xena","violet", {-3 / 16, -0.5, -3 / 16, 3 / 16, -2 / 16, 3 / 16}},
    {"diana","white", {-2 / 16, -0.5, -2 / 16, 2 / 16, 6 / 16, 2 / 16}},
	{"caroline","pink", {-2 / 16, -0.5, -2 / 16, 2 / 16, 6 / 16, 2 / 16}},
    {"michelle","white", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"genesis","white", {-2 / 16, -0.5, -2 / 16, 2 / 16, 1 / 16, 2 / 16}},
    {"suri","white", {-2 / 16, -0.5, -2 / 16, 2 / 16, 7 / 16, 2 / 16}},
    {"hadassa","white", {-2 / 16, -0.5, -2 / 16, 2 / 16, 6 / 16, 2 / 16}},

}

local flowers = beautiflowers.flowers

for i = 1, #flowers do
	local name, dye, box = unpack(flowers[i])
    local desc = unpack(name:split("_"))

    minetest.register_node("beautiflowers:"..name, {
	    description = "Beauty "..desc,
	    drawtype = "plantlike",
	    waving = 1,
	    visual_scale = 1.0,
	    tiles = {name..".png"},
	    inventory_image = name..".png",
	    wield_image = name..".png",
	    paramtype = "light",
	    sunlight_propagates = true,
	    walkable = false,
	    buildable_to = true,
	    groups = {snappy = 3, flower = 1, flora = 1, attached_node = 1, flammable = 1, beautiflowers = 1},
	    sounds = default.node_sound_leaves_defaults(),
	    selection_box = {
		    type = "fixed",
		    fixed = box or {-2 / 16, -0.5, -2 / 16, 2 / 16, 3 / 16, 2 / 16},
	    },
    })

    minetest.register_craft({
	    output = "dye:"..dye.." 4",
	    recipe = {
		    {"beautiflowers:"..name}
	    },
    })
    
    if pot then
	   flowerpot.register_node("beautiflowers:"..name)
    end
end

minetest.register_craft({
	output = "beautiflowers:bonsai_1",
	recipe = {
		{"default:cobble", "default:cobble", "default:cobble"},
		{"default:cobble", "default:sapling", "default:cobble"},
        {"default:cobble", "default:cobble", "default:cobble"}
	}
})

minetest.register_craft({
	output = "beautiflowers:bonsai_2",
	recipe = {
		{"default:cobble", "default:sapling", "default:cobble"},
		{"default:cobble", "default:cobble", "default:cobble"},
        {"default:cobble", "default:sapling", "default:cobble"}
	}
})

minetest.register_craft({
	output = "beautiflowers:bonsai_3",
	recipe = {
		{"default:cobble", "default:sapling", "default:cobble"},
		{"default:cobble", "default:sapling", "default:cobble"},
        {"default:cobble", "default:sapling", "default:cobble"}
	}
})

minetest.register_craft({
	output = "beautiflowers:bonsai_4",
	recipe = {
		{"default:cobble", "default:sapling", "default:cobble"},
		{"default:sapling", "default:cobble", "default:sapling"},
        {"default:cobble", "default:sapling", "default:cobble"}
	}
})

minetest.register_craft({
	output = "beautiflowers:bonsai_5",
	recipe = {
		{"default:cobble", "default:sapling", "default:cobble"},
		{"default:sapling", "default:sapling", "default:sapling"},
        {"default:cobble", "default:sapling", "default:cobble"}
	}
})


dofile(mpath .. "/spawn.lua")
