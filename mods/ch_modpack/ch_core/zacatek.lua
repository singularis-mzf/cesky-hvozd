ch_core.require_submod("zacatek", "privs")
ch_core.require_submod("zacatek", "data")
ch_core.require_submod("zacatek", "chat")
ch_core.require_submod("zacatek", "lib")

-- /doma
local function doma(player_name, pos)
	if not pos then
		return false, "Chybná pozice!"
	end
	local offline_charinfo = ch_core.get_offline_charinfo(player_name)
	offline_charinfo.domov = minetest.pos_to_string(pos)
	if not offline_charinfo.domov then
		return false, "Pozice nebyla uložena!"
	end
	ch_core.save_offline_charinfo(player_name, "domov")
	return true
end

-- /domů
local function domu(player_name)
	local offline_charinfo = ch_core.offline_charinfo[player_name]
	if not offline_charinfo then
		return false, "Interní údaje nebyly nalezeny!"
	elseif offline_charinfo.trest > 0 then
		return false, "Jste ve výkonu trestu odnětí svobody!"
	elseif not offline_charinfo.domov then
		return false, "Nejprve si musíte nastavit domovskou pozici příkazem /doma."
	end
	local player = minetest.get_player_by_name(player_name)
	if not player then
		return false, "Postava není online!"
	end
	local new_pos = minetest.string_to_pos(offline_charinfo.domov)
	if not new_pos then
		return false, "Uložená pozice má neplatný formát!"
	end
	player:set_pos(new_pos)
	ch_core.systemovy_kanal(player_name, "Teleport úspěšný!")
	return true
end

-- /začátek
local function zacatek(player_name)
	local offline_charinfo = ch_core.offline_charinfo[player_name]
	if not offline_charinfo then
		return false, "Interní údaje nebyly nalezeny!"
	elseif offline_charinfo.trest > 0 then
		return false, "Jste ve výkonu trestu odnětí svobody!"
	end
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

def = {
	description = "Uloží domovskou pozici pro pozdější návrat příkazem /domů.",
	privs = {home = true},
	func = function(player_name)
		local player = minetest.get_player_by_name(player_name)
		local pos = player and player:get_pos()
		if not pos then
			return false
		else
			local result, err = doma(player_name, pos)
			if result then
				return result, "Domovská pozice nastavena!"
			else
				return false, err
			end
		end
	end
}
minetest.register_chatcommand("doma", table.copy(def));
def.description = "Teleportuje vás na domovskou pozici uloženou příkazem /doma."
def.func = domu

minetest.register_chatcommand("domů", def);
minetest.register_chatcommand("domu", def);


ch_core.submod_loaded("zacatek")
