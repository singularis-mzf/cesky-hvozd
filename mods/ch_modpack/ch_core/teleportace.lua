ch_core.open_submod("teleportace", {privs = true, data = true, chat = true, lib = true, timers = true})

local teleport_delay = 30

ch_core.can_teleport_callbacks = {}

function ch_core.register_can_teleport(name, func)
	-- func = function(player, online_charinfo, priority)
	-- priority: 0 = very low priority, 1 = low priority, 2 = normal priority, 3 = high priority, 4 = very high priority
	if not name then
		error("Name is required!")
	end
	ch_core.can_teleport_callbacks[name] = func
end

-- player, pos [, priority[, delay]] -> final_delay or false
function ch_core.teleport_player(player, pos, priority, delay)
	if not player or not player:is_player() then
		minetest.log("warning", "teleport_player() failed for reason: Not a player")
		return false, "Not a player"
	end
	local player_name = player:get_player_name()
	local online_charinfo = ch_core.online_charinfo[player_name]
	if not online_charinfo then
		minetest.log("warning", "teleport_player() failed for reason: Player not online")
		return false, "Player not online"
	end
	if not priority then
		priority = 2
	end
	if not delay then
		delay = 0.05
	end
	for name, can_teleport in pairs(ch_core.can_teleport_callbacks) do
		local can = can_teleport(player, online_charinfo, priority)
		if can == false then
			minetest.log("warning", "teleport_player() denied due to callback "..name)
			return false, "Teleport denied by callback "..name
		end
		if type(can) == "number" and can > delay then
			delay = can
		end
	end
	local entity = player:get_attach()
	if entity ~= nil then
		local entity_name = "unknown entity"
		if entity.get_luaentity then
			local luaentity = entity:get_luaentity()
			if luaentity and luaentity.name then
				entity_name = luaentity.name
			end
		end

		if priority >= 1 and entity_name == "boats:boat" then
			-- detach from the boat
			local boat = entity:get_luaentity()
			player:set_detach()
			player_api.player_attached[player_name] = false
			player_api.set_animation(player, "stand" , 30)
		else
			minetest.log("warning", "teleport_player() failed due to player being attached to "..entity_name)
			return false, "Teleport failed, because the player is attached to "..entity_name.."."
		end
	end
	if delay and delay == 0 then
		player:set_pos(pos)
	else
		minetest.after(delay or 0.05, function(player2, pos2) player2:set_pos(pos2) end, player, pos)
	end
	return delay
end

local function start_teleport(online_charinfo, pos)
	if not online_charinfo or not pos then
		return false
	end
	local player_name = online_charinfo.player_name
	local trest = (ch_core.offline_charinfo[player_name] or {}).trest
	if trest > 0 then
		ch_core.systemovy_kanal(player_name, "Jste ve výkonu trestu odnětí svobody! Zbývající výše trestu: "..trest)
		return false
	end

	pos = vector.new(pos.x, pos.y, pos.z)
	local func = function()
		local player = minetest.get_player_by_name(player_name)
		if player then
			local trest2 = (ch_core.offline_charinfo[player_name] or {}).trest
			if trest2 > 0 then
				ch_core.systemovy_kanal(player_name, "Jste ve výkonu trestu odnětí svobody! Zbývající výše trestu: "..trest2)
				return false
			end
			if ch_core.teleport_player(player, pos) then
				ch_core.systemovy_kanal(player_name, "Teleport úspěšný")
				minetest.log("action", player_name.." teleported to "..minetest.pos_to_string(pos)..".")
				minetest.sound_play("teleport", { to_player = player_name, gain = 1.0 })
			else
				ch_core.systemovy_kanal(player_name, "Teleport selhal")
				minetest.log("action", player_name.." was not teleported to "..minetest.pos_to_string(pos)..".")
			end
		end
	end
	local player = minetest.get_player_by_name(player_name)
	local timer_def = ch_core.get_ch_timer_info(online_charinfo, "teleportace")
	if timer_def then
		ch_core.cancel_ch_timer(online_charinfo, "teleportace")
	end
	timer_def = {label = "teleportace", func = func, start_pos = player and player:get_pos()}
	local energy_crystal = minetest.registered_items["basic_materials:energy_crystal_simple"]
	if energy_crystal then
		timer_def.hudbar_icon = energy_crystal.inventory_image
	end
	if ch_core.start_ch_timer(online_charinfo, "teleportace", teleport_delay, timer_def) then
		minetest.log("action", "Teleport of "..player_name.." to "..minetest.pos_to_string(pos).." started.")
	else
	end
	return true
end

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
	elseif not offline_charinfo.domov then
		return false, "Nejprve si musíte nastavit domovskou pozici příkazem /doma."
	end
	local new_pos = minetest.string_to_pos(offline_charinfo.domov)
	if not new_pos then
		return false, "Uložená pozice má neplatný formát!"
	end
	start_teleport(ch_core.online_charinfo[player_name], new_pos)
	return true
end

-- /začátek
local function zacatek(player_name)
	local offline_charinfo = ch_core.offline_charinfo[player_name]
	if not offline_charinfo then
		return false, "Interní údaje nebyly nalezeny!"
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
	start_teleport(ch_core.online_charinfo[player_name], zacatek_pos)
	return true
end

local def = {
	description = "Přenese vás na počáteční pozici.",
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
def.description = "Přenese vás na domovskou pozici uloženou příkazem /doma."
def.func = domu

minetest.register_chatcommand("domů", def);
minetest.register_chatcommand("domu", def);

ch_core.close_submod("teleportace")
