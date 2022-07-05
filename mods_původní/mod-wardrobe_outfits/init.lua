
local all_skins = {
	"Ashley",
	{"BlueZ_Sam_II", "Bluez Sam II"},
	"CaligoPL",
	"Charlotte",
	{"Chloe", "Chloé"},
	{"Cloe", "Cloé"},
	"Coralie",
	"Emma",
	"Fiona",
	{"Gregoire", "Grégoire"},
	"Iris",
	"Julia",
	"Lisa",
	"Morgane",
	{"Super_Nerd", "Super Nerd"},
	"Zenohelds",
}

for _, skin in ipairs(all_skins) do
	local basename
	local realname

	if type(skin) == "string" then
		basename = skin
		realname = skin
	else
		basename = skin[1]
		realname = skin[2]
	end

	if core.settings:get_bool("wardrobe_outfits.enable_" .. basename, true) then
		wardrobe.registerSkin(basename .. ".png", realname)
	end
end
