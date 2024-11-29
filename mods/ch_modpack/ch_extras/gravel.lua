local def

-- ch_extras:railway_gravel
---------------------------------------------------------------
def = table.copy(minetest.registered_nodes["default:gravel"])
def.description = "železniční štěrk"
def.tiles = {
	"default_gravel.png^[multiply:#956338"
}
def.drop = nil
minetest.register_node("ch_extras:railway_gravel", def)

minetest.register_craft({
	output = "ch_extras:railway_gravel 2",
	type = "shapeless",
	recipe = {"default:gravel", "default:gravel", "default:iron_lump"},
})

minetest.register_craft({
	output = "ch_extras:railway_gravel",
	type = "shapeless",
	recipe = {"default:gravel", "technic:wrought_iron_dust"},
})
minetest.register_alias("ch_core:railway_gravel", "ch_extras:railway_gravel")

stairsplus:register_all("ch_extras", "railway_gravel", "ch_extras:railway_gravel", minetest.registered_nodes["ch_extras:railway_gravel"])
-- stairsplus:register_alias_all("ch_core", "railway_gravel", "ch_extras", "railway_gravel")

-- ch_extras:bright_gravel
---------------------------------------------------------------
def = table.copy(minetest.registered_nodes["default:gravel"])
def.description = "světlý štěrk"
def.tiles = {
	"[combine:128x128:0,0=breccia.png:64,0=breccia.png:0,64=breccia.png:64,64=breccia.png"
}
def.drop = nil
minetest.register_node("ch_extras:bright_gravel", def)

minetest.register_craft({
	output = "ch_extras:bright_gravel 4",
	type = "shapeless",
	recipe = {"default:gravel", "default:gravel", "default:silver_sand", "default:silver_sand"},
})

stairsplus:register_all("ch_extras", "bright_gravel", "ch_extras:bright_gravel", minetest.registered_nodes["ch_extras:bright_gravel"])
