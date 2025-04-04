ch_base.open_mod(minetest.get_current_modname())
local modpath = minetest.get_modpath("technic_worldgen")

technic = rawget(_G, "technic") or {}
technic.worldgen = {
	gettext = minetest.get_translator("technic_worldgen"),
}

dofile(modpath.."/config.lua")
dofile(modpath.."/nodes.lua")
dofile(modpath.."/oregen.lua")
dofile(modpath.."/crafts.lua")

-- Rubber trees, moretrees also supplies these
if not minetest.get_modpath("moretrees") then
	dofile(modpath.."/rubber.lua")
else
	-- older versions of technic provided rubber trees regardless
	minetest.register_alias("technic:rubber_sapling", "moretrees:rubber_tree_sapling")
	minetest.register_alias("technic:rubber_tree_empty", "moretrees:rubber_tree_trunk_empty")
end

-- mg suppport
if minetest.get_modpath("mg") then
	dofile(modpath.."/mg.lua")
end

ch_base.close_mod(minetest.get_current_modname())
