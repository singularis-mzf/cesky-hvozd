ch_base.open_mod(minetest.get_current_modname())
local modpath = minetest.get_modpath(minetest.get_current_modname())

local mods = {
	"bbq",
	"cucina_vegana",
	"cutepie",
	"digistuff",
	"ephesus",
	"ethereal",
	"petz",
	"stoneblocks",
	"xdecor",
}

for _, mod in ipairs(mods) do
	dofile(modpath .. "/" .. mod .. ".lua")
end

ch_base.close_mod(minetest.get_current_modname())
