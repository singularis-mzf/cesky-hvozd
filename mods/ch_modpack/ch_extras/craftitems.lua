local def

-- ch_extras:clean_dirt
---------------------------------------------------------------
local image = "default_dirt.png^[resize:32x32^(default_sand.png^[resize:32x32^[opacity:128)"

image = "default_dirt.png&[resize:32x32&(default_sand.png&[resize:32x32&[opacity:128)"
image = "[inventorycube{"..image.."{"..image.."{"..image
def = {
	description = "přebraná hlína",
	inventory_image = image,
	wield_image = image,
	_ch_help = "přebranou hlínu nelze umístit do světa,\nlze ji smísit s pískem",
	-- groups = {}
}

minetest.register_craftitem("ch_extras:clean_dirt", def)
minetest.register_craft({
	output = "default:sand 5",
	recipe = {
		{"default:sand", "default:sand", ""},
		{"default:sand", "default:sand", ""},
		{"ch_extras:clean_dirt", "", ""},
	},
})

-- ch_extras:rohlik...
---------------------------------------------------------------
def = {
	description = "těsto na rohlík",
	inventory_image = "ch_extras_rohlik_testo.png",
	wield_image = "ch_extras_rohlik_testo.png",
	groups = {food = 1},
}

minetest.register_craftitem("ch_extras:rohlik_testo", def)

def = {
	description = "rohlík",
	inventory_image = "ch_extras_rohlik.png",
	wield_image = "ch_extras_rohlik.png",
	groups = {food = 2},
	on_use = minetest.item_eat(2),
}

minetest.register_craftitem("ch_extras:rohlik", def)

def = {
	description = "párek v rohlíku",
	inventory_image = "ch_extras_parekvrohliku.png",
	wield_image = "ch_extras_parekvrohliku.png",
	groups = {food = 6, food_hot_dog = 1},
	on_use = minetest.item_eat(6),
}

minetest.register_craftitem("ch_extras:parekvrohliku", def)

def = {
	description = "párek v rohlíku s kečupem",
	inventory_image = "ch_extras_parekvrohliku_k.png",
	wield_image = "ch_extras_parekvrohliku_k.png",
	groups = {food = 8, food_hot_dog = 1},
	on_use = minetest.item_eat(8),
}

minetest.register_craftitem("ch_extras:parekvrohliku_k", def)

def = {
	description = "párek v rohlíku s hořčicí",
	inventory_image = "ch_extras_parekvrohliku_h.png",
	wield_image = "ch_extras_parekvrohliku_h.png",
	groups = {food = 8, food_hot_dog = 1},
	on_use = minetest.item_eat(8),
}

minetest.register_craftitem("ch_extras:parekvrohliku_h", def)

minetest.register_craft({
	output = "ch_extras:rohlik_testo 16",
	recipe = {
		{"farming:flour", "farming:sugar", ""},
		{"farming:flour", "farming:salt", ""},
		{"farming:flour", "", ""},
	},
})

minetest.register_craft({
	output = "ch_extras:rohlik",
	type = "cooking",
	cooktime = 12,
	recipe = "ch_extras:rohlik_testo",
})

minetest.register_craft({
	output = "ch_extras:parekvrohliku",
	recipe = {
		{"ch_extras:rohlik", ""},
		{"basic_materials:steel_bar", "sausages:sausages_cooked"},
	},
	replacements = {
		{"basic_materials:steel_bar", "basic_materials:steel_bar"},
	},
})

minetest.register_craft({
	output = "ch_extras:parekvrohliku_k",
	recipe = {
		{"farming:tomato", ""},
		{"ch_extras:parekvrohliku", ""},
	},
})

minetest.register_craft({
	output = "ch_extras:parekvrohliku_h",
	recipe = {
		{"farming:pepper_ground", ""},
		{"ch_extras:parekvrohliku", ""},
	},
})

-- ice -> water_source
---------------------------------------------------------------
minetest.register_craft({
	output = "default:water_source",
	type = "cooking",
	cooktime = 6,
	recipe = "default:ice",
})
minetest.register_craft({
	output = "default:water_source",
	type = "cooking",
	cooktime = 3,
	recipe = "default:snowblock",
})
