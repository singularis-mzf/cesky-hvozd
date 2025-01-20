
minetest.register_craft({
	output = "underch:goldstone 8",
	recipe = {
		{"group:stone","group:stone","group:stone"},
		{"group:stone","default:gold_ingot","group:stone"},
		{"group:stone","group:stone","group:stone"},
	}
})

minetest.register_craft({
	output = "underch:sichamine_lamp",
	recipe = {
		{"","default:mese_crystal",""},
		{"default:mese_crystal","underch:sichamine","default:mese_crystal"},
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "underch:mossy_gravel 2",
	recipe = {"group:leaves", "group:leaves", "default:dirt", "default:gravel"},
})

minetest.register_craft({
	type = "shapeless",
	output = "underch:dark_sichamine 3",
	recipe = {"underch:sichamine", "underch:sichamine", "underch:sichamine", "default:coal_lump"},
})

if minetest.get_modpath("moreores") ~= nil then
	minetest.register_craft({
		type = "shapeless",
		output = "underch:light_leafstone 5",
		recipe = {"moreores:tin_ingot", "moreores:tin_ingot", "moreores:tin_ingot", "moreores:tin_ingot", "underch:leafstone", "underch:leafstone", "underch:leafstone", "underch:leafstone"},
	})
end

minetest.register_craft({
	type = "shapeless",
	output = "underch:weedy_sichamine",
	recipe = {"underch:sichamine", "group:leaves"},
})

minetest.register_craft({
	type = "cooking",
	output = "underch:leafstone",
	recipe = "underch:mossy_gravel",
})

minetest.register_craft({
	output = "underch:burner",
	recipe = {
		{"underch:dark_vindesite","underch:ruby","underch:dark_vindesite"},
		{"underch:quartz","fire:flint_and_steel","underch:quartz"},
		{"underch:dark_vindesite","underch:ruby","underch:dark_vindesite"},
	}
})

minetest.register_craft({
	output = "underch:coal_diamond",
	recipe = {
		{"default:coal_lump","default:coal_lump","default:coal_lump"},
		{"default:coal_lump","default:diamond","default:coal_lump"},
		{"default:coal_lump","default:coal_lump","default:coal_lump"},
	}
})

minetest.register_craft({
	output = "default:coalblock",
	recipe = {
		{"underch:coal_dust","underch:coal_dust","underch:coal_dust"},
		{"underch:coal_dust","underch:coal_dust","underch:coal_dust"},
		{"underch:coal_dust","underch:coal_dust","underch:coal_dust"},
	}
})

minetest.register_craft({
	output = "default:torch 4",
	recipe = {
		{"underch:torchberries"},
		{"default:stick"}
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "default:stick",
	recipe = {"underch:dead_bush"},
})

minetest.register_craft({
	type = "shapeless",
	output = "default:stick 2",
	recipe = {"underch:underground_bush"},
})

--clay

minetest.register_node("underch:clay", {
	description = "Brown Clay",
	tiles = {"underch_clay.png"},
	groups = {crumbly = 3, jit_shadow = 1},
	after_dig_node = underch.jit.dig_shadow,
	drop = 'underch:clay_lump 4',
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_craftitem("underch:clay_lump", {
	description = "Brown Clay Lump",
	inventory_image = "underch_clay_lump.png",
})

minetest.register_craft({
	output = 'underch:clay',
	recipe = {
		{'underch:clay_lump', 'underch:clay_lump'},
		{'underch:clay_lump', 'underch:clay_lump'},
	}
})

minetest.register_craft({
	output = 'underch:clay_lump 4',
	recipe = {
		{'underch:clay'},
	}
})

minetest.register_craft({
	type = "cooking",
	output = "default:clay_brick",
	recipe = "underch:clay_lump",
})

-- fuel

minetest.register_craft({
	type = "fuel",
	recipe = "underch:dead_bush",
	burntime = 5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "underch:underground_bush",
	burntime = 5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "underch:dry_moss",
	burntime = 2,
})

minetest.register_craft({
	type = "fuel",
	recipe = "underch:moss",
	burntime = 2,
})

minetest.register_craft({
	type = "fuel",
	recipe = "underch:mould",
	burntime = 1,
})

minetest.register_craft({
	type = "fuel",
	recipe = "underch:fiery_vine",
	burntime = 8,
})

minetest.register_craft({
	type = "fuel",
	recipe = "underch:underground_vine",
	burntime = 4,
})

minetest.register_craft({
	type = "fuel",
	recipe = "underch:coal_dust",
	burntime = 40,
})
