-- ch_extras:noise (experimentální)
---------------------------------------------------------------
--[[
def = {
	drawtype = "normal",
	description = "šumový blok [EXPERIMENTÁLNÍ]",
	_ch_help = "Tento blok je experimentální. Můžete ho zkoušet, ale nepoužívejte ho bez domluvy na vážně míněných stavbách.",
	tiles = {{name = "ch_extras_noise.png", animation = {
		type = "vertical_frames",
		aspect_w = 64,
		aspect_h = 64,
		length = 0.25,
	}}},
	paramtype = "light",
	paramtype2 = "color",
	palette = "unifieddyes_palette_extended.png",
	light_source = 5,
	groups = {dig_immediate = 2, ud_param2_colorable = 1},
	sounds = default.node_sound_defaults(),
	is_ground_content = false,
	on_construct = unifieddyes.on_construct,
	on_dig = unifieddyes.on_dig,
}

minetest.register_node("ch_extras:noise", def)
]]


