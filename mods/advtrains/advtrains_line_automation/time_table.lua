local visual_scale = 15/16
local node_box = {type = "fixed", fixed = {
	-16/32, -16/32, 15/32 / visual_scale,
	16/32, 16/32, 16/32 / visual_scale,
}}
local sbox = {type = "fixed", fixed = {
	-16/32 * visual_scale, -16/32 * visual_scale, 15/32,
	16/32 * visual_scale, 16/32 * visual_scale, 16/32,
}}

local def = {
	description = "jízdní řád",
	drawtype = "nodebox",
	node_box = node_box,
	selection_box = sbox,
	collision_box = sbox,
	tiles = {
		{name = "ch_core_white_pixel.png^[multiply:#aaaaaa"},
		{name = "ch_core_white_pixel.png^[multiply:#aaaaaa"},
		{name = "ch_core_white_pixel.png^[multiply:#aaaaaa"},
		{name = "ch_core_white_pixel.png^[multiply:#aaaaaa"},
		{name = "advtrains_line_automation_jrad.png"},
		{name = "advtrains_line_automation_jrad.png"},
	},
	paramtype = "light",
	paramtype2 = "4dir",
	sunlight_propagates = true,
	groups = {cracky = 3, ch_jrad = 1},
	sounds = default.node_sound_metal_defaults(),
	visual_scale = visual_scale,
	_ch_help = "Použitím (levým klikem) zobrazí jízdní řády všech linek.\nLze umístit do světa a nastavit na jízdní řády v konkrétní stanici/zastávce.\nPo umístění lze také barvit barvicí pistolí.",
	_ch_help_group = "jrad",
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local player_name = placer and placer:get_player_name()
		if player_name ~= nil then
			local meta = core.get_meta(pos)
			meta:set_string("infotext", "jízdní řád (spravuje: "..ch_core.prihlasovaci_na_zobrazovaci(player_name)..")")
			meta:set_string("owner", player_name)
		end
	end,
	can_dig = function(pos, player)
		if player == nil then
			return false
		end
		local player_name = player:get_player_name()
		if ch_core.get_player_role(player_name) == "admin" then
			return true
		end
		if core.is_protected(pos, player_name) then
			core.record_protection_violation(pos, player_name)
			return false
		end
		local meta = core.get_meta(pos)
		local owner = meta:get_string("owner")
		return owner == "" or owner == player_name
	end,
	on_use = function(itemstack, user, pointed_thing)
		if core.is_player(user) then
			advtrains.lines.show_jr_formspec(user)
		end
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if clicker ~= nil and core.is_player(clicker) then
			local meta = core.get_meta(pos)
			advtrains.lines.show_jr_formspec(clicker, pos, meta:get_string("stn"), meta:get_string("track"))
		end
	end,
}

core.register_node("advtrains_line_automation:jrad", table.copy(def))

def.description = "jízdní řád (na tyč)"
def.tiles = table.copy(def.tiles)
def.tiles[5] = def.tiles[1]
def.node_box = {
    type = "fixed",
    fixed = {
	    -16/32, -16/32, 27/32 / visual_scale,
	    16/32, 16/32, 28/32 / visual_scale,
    }}
def.selection_box = {
    type = "fixed",
    fixed = {
	    -16/32 * visual_scale, -16/32 * visual_scale, 27/32,
	    16/32 * visual_scale, 16/32 * visual_scale, 28/32,
}}
def.collision_box = def.selection_box
core.register_node("advtrains_line_automation:jrad_on_pole", def)
