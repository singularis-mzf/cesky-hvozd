ch_base.open_mod(minetest.get_current_modname())

local modpath = minetest.get_modpath("wrench")

wrench = {
	translator = minetest.get_translator("wrench"),
	plus = true,
	registered_nodes = {},
	blacklisted_items = {},
	META_TYPE_IGNORE = 0,
	META_TYPE_FLOAT = 1,
	META_TYPE_STRING = 2,
	META_TYPE_INT = 3,
	has_pipeworks = minetest.get_modpath("pipeworks"),
	has_mesecons = minetest.get_modpath("mesecons"),
	has_digilines = minetest.get_modpath("digilines"),
}

dofile(modpath.."/api.lua")
dofile(modpath.."/functions.lua")
dofile(modpath.."/tool.lua")
dofile(modpath.."/crafts.lua")
-- dofile(modpath.."/legacy.lua")

local mods = {
	"3d_armor_stand",
	"basic_signs",
	"bees",
	"biofuel",
	"bones",
	"connected_chests",
	"darkage",
	"default",
	"digilines",
	"digiscreen",
	"digistuff",
	"digtron",
	-- "drawers",
	"homedecor_misc",
	-- "mesecons_commandblock",
	-- "mesecons_detector",
	-- "mesecons_luacontroller",
	-- "mesecons_microcontroller",
	-- "mobs",
	"more_chests",
	"pipeworks",
	"protector",
	-- "signs_lib",
	"smartshop",
	-- "technic",
	"technic_chests",
	-- "technic_cnc",
	"vessels",
	"xdecor",
}

for _, mod in pairs(mods) do
	if minetest.get_modpath(mod) then
		dofile(modpath.."/nodes/"..mod..".lua")
	end
end
ch_base.close_mod(minetest.get_current_modname())
