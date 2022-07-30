print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local groups_clothing = {clothing = 1}

local hair_colors = {
	{"blond", "D7C58C", "blond dlouhé vlasy"},
	{"cerne", "16120D", "černé dlouhé vlasy"},
	{"hnede", "2F1002", "hnědé dlouhé vlasy"},
	{"plave", "DAD2B7", "plavé dlouhé vlasy"},
	{"rysave", "9A3A1F", "ryšavé dlouhé vlasy"},
	{"sede", "EAEAEA", "šedé dlouhé vlasy"},
	{"svhnede", "B48655", "světle hnědé dlouhé vlasy"},
}

for _, hcolor in ipairs(hair_colors) do
	minetest.register_craftitem("ch_beauty:dlvlasy_"..hcolor[1], {
		description = hcolor[3],
		inventory_image = "ch_beauty_dlvlasy_inv.png^[multiply:#"..hcolor[2],
		uv_image = "(ch_beauty_dlvlasy.png^[multiply:#"..hcolor[2]..")",
		groups = groups_clothing,
	})
end

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
