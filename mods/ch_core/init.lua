print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local modpath = minetest.get_modpath("ch_core")
ch_core = {
	doslech = {}, -- pro chat (player_name => number 0..65535)
	ignorovani_chatu = {}, -- (player_from..">>>>"..player_to => 1 || nil)
	joinplayer_timestamp = {}, -- player_name => timestamp (for online players only)
	storage = minetest.get_mod_storage(),
}

minetest.register_privilege("ch_registered_player", "Odlišuje registrované postavy od čerstvě založených.")

dofile(modpath .. "/lib.lua")
dofile(modpath .. "/data.lua")
dofile(modpath .. "/chat.lua")
dofile(modpath .. "/joinplayer.lua")
dofile(modpath .. "/nodes.lua")

-- kouzelníci/ce nesmí vkládat do cizích inventářů
minetest.override_chatcommand("give", {privs = {give = true, protection_bypass = true, interact = true}})


-- /začátek
local function zacatek(player_name)
	local player = minetest.get_player_by_name(player_name)
	local player_pos = player and player:get_pos()
	if not player_pos then
		return false
	end
	local is_registered = minetest.check_player_privs(player_name, "ch_registered_player")
	player_pos = vector.new(player_pos.x, player_pos.y, player_pos.z)
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
minetest.register_chatcommand("začátek", def);
minetest.register_chatcommand("zacatek", def);
minetest.register_chatcommand("yačátek", def);
minetest.register_chatcommand("yacatek", def);

-- KOHOUT: při přechodu mezi dnem a nocí přehraje zvuk
-- TODO: přehrávat, jen když je postava na povrchu (tzn. ne v hlubokém podzemí)

local last_timeofday = 0 -- pravděpodobně se pokusí něco přehrát v prvním globalstepu,
-- ale to nevadí, protöže v tu chvíli stejně nemůže být ještě nikdo online.
local gain_1 = {gain = 1.0}
minetest.register_globalstep(function(dtime)
	-- DEN: 5:30 .. 19:00
	local tod = minetest.get_timeofday()
	local byla_noc = last_timeofday < 0.2292 or last_timeofday > 0.791666
	local je_noc = tod < 0.2292 or tod > 0.791666
	if byla_noc and not je_noc then
		-- Ráno
		minetest.sound_play("birds", gain_1)
	elseif not byla_noc and je_noc then
		-- Noc
		minetest.sound_play("owl", gain_1)
	end
	last_timeofday = tod
end)

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
