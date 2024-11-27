ch_base.open_mod(minetest.get_current_modname())

mesecon.node_sound = {}

mesecon.sound_name = {}

mesecon.texture = {}

mesecon.dye_colors = {
	"red", "green", "blue", "grey", "dark_grey", "yellow",
	"orange", "white", "pink", "magenta", "cyan", "violet",
}

if minetest.get_modpath("default") then
	minetest.log("info", "Mesecons: detected Minetest Game for game compatibility")
	dofile(minetest.get_modpath("mesecons_gamecompat").."/compat_mtg.lua")
end
ch_base.close_mod(minetest.get_current_modname())
