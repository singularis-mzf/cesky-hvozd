ch_core.require_submod("zacatek", "privs")

-- /začátek
local function zacatek(player_name)
	local player = minetest.get_player_by_name(player_name)
	local player_pos = player and player:get_pos()
	if player_pos then
		player_pos = vector.new(player_pos.x, player_pos.y, player_pos.z)
	else
		return false
	end
	local is_registered = minetest.check_player_privs(player_name, "ch_registered_player")
	local zacatek_pos = (is_registered and ch_core.registered_spawn or ch_core.unregistered_spawn) or minetest.setting_get_pos("static_spawnpoint") or vector.new(0,0,0)
	if vector.distance(player_pos, zacatek_pos) < 5 then
		return false, "Jste příliš blízko počáteční pozice!"
	end
	player:set_pos(zacatek_pos)
	ch_core.systemovy_kanal(player_name, "Teleport úspěšný!")
	return true
end

local def = {
	description = "Okamžitě vás přenese na počáteční pozici.",
	func = zacatek,
}
minetest.register_chatcommand("zacatek", def);
minetest.register_chatcommand("začátek", def);
minetest.register_chatcommand("zacatek", def);
minetest.register_chatcommand("yačátek", def);
minetest.register_chatcommand("yacatek", def);

ch_core.submod_loaded("zacatek")
