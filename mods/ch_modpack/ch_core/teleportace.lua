ch_core.open_submod("teleportace", {privs = true, data = true, chat = true, lib = true, stavby = true, timers = true})

local ifthenelse = ch_core.ifthenelse

local can_teleport_callbacks = {}

-- LOCAL FUNCTIONS
local function get_entity_name(obj)
	if obj.get_luaentity then
		obj = obj:get_luaentity()
	end
	return obj.name or "unknown entity"
end

local function get_finish_teleport_func(player_name, d, is_immediate)
	return function()
		-- je postava stále ještě ve hře?
		local player = minetest.get_player_by_name(player_name)
		local online_charinfo = ch_core.online_charinfo[player_name]
		if player == nil or online_charinfo == nil then
			return
		end
		local player_pos = player:get_pos()
		player:set_properties{pointable = true}
		ch_core.set_temporary_titul(player_name, "přemísťuje se", false)

		-- zopakovat testy přemístitelnosti
		if not is_immediate then
			if d.type ~= "admin" and ch_core.je_ve_vykonu_trestu ~= nil then
				local trest = ch_core.je_ve_vykonu_trestu(player_name)
				if trest ~= nil then
					ch_core.systemovy_kanal(player_name, "Jste ve výkonu trestu odnětí svobody! Zbývající výše trestu: "..trest)
					return false
				end
			end
		end

		-- can_teleport?
		local priority
		if d.type == "admin" then
			priority = 4
		elseif d.type == "force" then
			priority = 3
		else
			priority = 2
		end
		for name, can_teleport in pairs(can_teleport_callbacks) do
			if can_teleport(player, online_charinfo, priority) == false then
				minetest.log("warning", "teleport_player() denied due to callback "..name)
				return false, "Přemístění selhalo (technické informace: "..name..")"
			end
		end

		-- přehrát zvuk před přemístěním
		if d.sound_before ~= nil then
			minetest.sound_play(d.sound_before, {pos = player_pos, max_hear_distance = d.sound_before_max_hearing_distance or 50.0})
		end

		-- zavolat funkce před přemístěním
		if d.callback_before ~= nil then
			d.callback_before()
		end

		-- zavříŧ formspec
		if d.close_formspec ~= false then
			minetest.close_formspec(player_name, "")
		end

		-- vyřešit připojení postavy k objektu
		local attach_object = player:get_attach()
		if attach_object ~= nil then
			local entity_name = get_entity_name(attach_object)

			if (d.type == "admin" or d.type == "force") and entity_name == "boats:boat" then
				-- detach from the boat
				player:set_detach()
				player_api.player_attached[player_name] = false
				player_api.set_animation(player, "stand" , 30)
			else
				if d.type == "player" then
					ch_core.systemovy_kanal(player_name, "Přemístění selhalo")
				end
				minetest.log("action", player_name.." was not teleported to "..minetest.pos_to_string(d.target_pos)..".")
				return false -- přemístění selhalo
			end
		end

		-- načíst cílovou oblast
		minetest.load_area(vector.round(d.target_pos))

		-- přemístit postavu
		player:set_pos(d.target_pos)

		-- zrušit rychlost
		if d.set_velocity ~= false then
			player:add_velocity(vector.multiply(player:get_velocity(), -1.0))
		end

		-- nastavit natočení
		if d.look_horizontal ~= nil then
			player:set_look_horizontal(d.look_horizontal)
		end
		if d.look_vertical ~= nil then
			player:set_look_vertical(d.look_vertical)
		end

		-- zavolat funkci po přemístění
		if d.callback_after ~= nil then
			d.callback_after()
		end

		-- přehrát zvuk po přemístění
		if d.sound_after ~= nil then
			minetest.sound_play(d.sound_after, {pos = d.target_pos, max_hear_distance = d.sound_after_max_hearing_distance or 50.0})
		end

		if d.type == "player" then
			ch_core.systemovy_kanal(player_name, "Přemístění úspěšné")
		end
		minetest.log("action", player_name.." teleported to "..minetest.pos_to_string(d.target_pos)..".")

		return true
	end
end





-- PUBLIC FUNCTIONS
function ch_core.register_can_teleport(name, func)
	-- func = function(player, online_charinfo, priority)
	-- priority: 0 = very low priority, 1 = low priority, 2 = normal priority (player/normal), 3 = high priority (force), 4 = very high priority (admin)
	-- should return: true or nil (can teleport), false (can't teleport)
	if not name then
		error("Name is required!")
	end
	can_teleport_callbacks[name] = func
end

--[[
	d = {
		type = string, // musí být jedno z:
			// "admin": přemístění s nejvyšší prioritou, umí odpojovat od všech typů objektů a může k němu docházet i ve výkonu trestu
			// "force": neinteraktivní přemístění s vyšší prioritou, umí odpojovat od objektů
			// "player": interaktivní přemístění s normální prioritou, neumí odpojovat od objektů, vypisuje zprávy do četu
			// "normal": neinteraktivní přemístění s normální prioritou, neumí odpojovat od objektů, nevypisuje zprávy
		player = ObjRef or string, // postava k přemístění (objekt nebo jméno)
		target_pos = vector, // cílová pozice

		delay = float or nil, // zpoždění; během zpoždění může postava přemístění zrušit např. pohybem
		look_horizontal = float or nil,
		look_vertical = float or nil,
		sound_before = SimpleSoundSpec or nil, // zvuk k přehrání na výchozí pozici těsně před přemístěním,
		sound_before_max_hearing_distance = float or nil,
		sound_after = SimpleSoundSpec or nil, // zvuk k přehrání na cílové pozici těsně po přemístění,
		sound_after_max_hearing_distance = float or nil,
		callback_before = function or nil, // funkce k zavolání těsně před přemístěním
		callback_after = function or nil, // funkce k zavolání těsně po přemístění
			// nebude zavolána, pokud bude přemístění přerušeno
		close_formspec = bool or nil, // je-li true nebo nil, v momentě přemístění uzavře klientovi formspec
		set_velocity = bool or nil, // je-li true nebo nil, po přemístění nastaví postavě nulovou rychlost
	}
]]

function ch_core.teleport_player(def)
	local d = table.copy(def)
	if d.type == nil or d.player == nil or d.target_pos == nil then
		error("ch_core.teleport_player(): a required argument is missing: "..dump2(def))
	end
	if d.type ~= "admin" and d.type ~= "force" and d.type ~= "player" and d.type ~= "normal" then
		error("ch_core.teleport_player(): unsupported teleport type '"..d.type.."'!")
	end
	d.target_pos = vector.copy(d.target_pos)

	-- je postava ve hře?
	local pinfo = ch_core.normalize_player(d.player)
	if pinfo.role == "none" then
		return false, "postava neexistuje"
	end
	local player = pinfo.player
	local player_name = pinfo.player_name
	local online_charinfo = ch_core.online_charinfo[player_name]
	if player == nil or online_charinfo == nil then
		return false, "postava není ve hře"
	end
	-- local player_pos = player:get_pos()

	-- mohu přemístit postavu?
	if d.type ~= "admin" and ch_core.je_ve_vykonu_trestu ~= nil then
		local trest = ch_core.je_ve_vykonu_trestu(player_name)
		if trest ~= nil then
			if d.type == "player" then
				ch_core.systemovy_kanal(player_name, "Jste ve výkonu trestu odnětí svobody! Zbývající výše trestu: "..trest)
			end
			return false, "postava je ve výkonu trestu"
		end
	end

	-- zrušit stávající přemístění, je-li naplánováno
	local timer_def = ch_core.get_ch_timer_info(online_charinfo, "teleportace")
	if timer_def then
		ch_core.cancel_teleport(player_name, false)
	end

	-- přemístit se zpožděním?
	local delay = d.delay
	if delay ~= nil and delay > 0.0 then
		timer_def = {
			label = "přemístění",
			func = get_finish_teleport_func(player_name, d, false),
			hudbar_icon = (minetest.registered_items["basic_materials:energy_crystal_simple"] or {}).inventory_image,
			hudbar_bar = "hudbars_bar_timer.png^[multiply:#0000ff",

			teleport_type = d.type,
			start_pos = player and player:get_pos(),
			target_pos = d.target_pos,
			def = d,
		}
		if ch_core.start_ch_timer(online_charinfo, "teleportace", d.delay, timer_def) then
			if d.type == "player" then
				local delay_str = string.format("%.3f", delay)
				delay_str = delay_str:gsub("%.", ",")
				ch_core.systemovy_kanal(player_name, "Přemístění zahájeno (čas na přípravu: "..delay_str.." sekund).")
				ch_core.set_temporary_titul(player_name, "přemísťuje se", true)
			end
			minetest.log("action", "Teleport of "..player_name.." to "..minetest.pos_to_string(d.target_pos).." started.")
			player:set_properties{pointable = false}
			return true
		end
		return false, "neznámý důvod"
	end

	-- přemístit okamžitě?
	local f = get_finish_teleport_func(player_name, d, true)
	return f()
end

--[[
	Zjistí, zda je postava přemísťována.
]]
function ch_core.is_teleporting(player_name)
	local online_charinfo = ch_core.online_charinfo[player_name]
	if online_charinfo == nil then
		return false
	end
	local timer_def = ch_core.get_ch_timer_info(online_charinfo, "teleportace")
	if timer_def == nil then
		return false
	end
	return timer_def.teleport_type
end

--[[
	Zruší probíhající přemístění.
]]
function ch_core.cancel_teleport(player_name, due_to_player_action)
	local online_charinfo = ch_core.online_charinfo[player_name]
	if online_charinfo == nil then
		return false
	end
	local timer_def = ch_core.get_ch_timer_info(online_charinfo, "teleportace")
	if timer_def == nil then
		return false
	end
	ch_core.cancel_ch_timer(online_charinfo, "teleportace")
	ch_core.set_temporary_titul(player_name, "přemísťuje se", false)
	local player = minetest.get_player_by_name(player_name)
	if player ~= nil then
		player:set_properties{pointable = true}
	end
	if timer_def.def.type == "player" then
		ch_core.systemovy_kanal(player_name, ifthenelse(due_to_player_action,
			"Přemístění zrušeno v důsledku akce hráče/ky nebo postavy.",
			"Přemístění zrušeno."))
	end
	return true
end

--[[
	Předčasně dokončí probíhající přemístění.
]]
function ch_core.finish_teleport(player_name)
	local online_charinfo = ch_core.online_charinfo[player_name]
	if online_charinfo == nil then
		return false
	end
	local timer_def = ch_core.get_ch_timer_info(online_charinfo, "teleportace")
	if timer_def ~= nil then
		ch_core.cancel_ch_timer(online_charinfo, "teleportace")
		ch_core.set_temporary_titul(player_name, "přemísťuje se", false)
		return timer_def.func()
	else
		return false
	end
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
	ch_core.teleport_player{
		type = "player",
		player = player_name,
		target_pos = new_pos,
		delay = 30.0,
		sound_before = ch_core.default_teleport_sound,
		sound_after = ch_core.default_teleport_sound,
	}
	return true
end

-- /stavím
local function stavim(player_name, pos)
	if not pos then
		return false, "Chybná pozice!"
	end
	local filter_result = {}
	ch_core.stavby_get_all(function(record)
		local distance = vector.distance(pos, record.pos)
		if record.spravuje == player_name then
			-- spravovaná stavba: max. vzdálenost 100 m, stav jakýkoliv kromě opuštěného
			if distance <= 100 and record.stav ~= "opusteno" and record.stav ~= "k_smazani" then
				filter_result[1] = record
			end
		else
			-- nespravovaná stavba: max. vzdálenost 20 m, stav rozestaveno nebo rekonstrukce
			if distance <= 20 and (record.stav == "rozestaveno" or record.stav == "rekonstrukce") then
				filter_result[1] = record
			end
		end
	end)
	if filter_result[1] == nil then
		return false, "Pro nastavení pozice příkazem /stavím musíte mít do 100 metrů vámi spravovanou stavbu, která není opuštěná nebo ke smazání, "..
			"nebo musí být do 20 metrů cizí stavba, která je rozestavěná nebo v rekonstrukci."
	end
	local cas = ch_core.aktualni_cas()
	local dnes = string.format("%04d-%02d-%02d", cas.rok, cas.mesic, cas.den)
	local offline_charinfo = ch_core.get_offline_charinfo(player_name)
	if not offline_charinfo then
		return false, "Interní údaje nebyly nalezeny!"
	end
	local old_pos, pos_date
	if offline_charinfo.stavba ~= nil then
		old_pos, pos_date = offline_charinfo.stavba:match("^([^@]+)@([^@]+)$")
	end
	if pos_date == dnes then
		return false, "Cílovou pozici příkazem /stavím lze nastavit jen jednou denně!"
	end
	offline_charinfo.stavba = core.pos_to_string(pos).."@"..dnes
	ch_core.save_offline_charinfo(player_name, "stavba")
	core.log("action", player_name.." set their 'stavba' position to "..offline_charinfo.stavba)
	return true, "Pozice pro příkaz /nastavbu nastavena. Pamatujte, že tuto pozici můžete změnit jen jednou denně."
end

-- /nastavbu
local function nastavbu(player_name)
	local offline_charinfo = ch_core.offline_charinfo[player_name]
	if not offline_charinfo then
		return false, "Interní údaje nebyly nalezeny!"
	elseif not offline_charinfo.stavba or offline_charinfo.stavba == "" then
		return false, "Nejprve si musíte nastavit pozici stavby příkazem /stavím."
	end
	local new_pos, pos_date = offline_charinfo.stavba:match("^([^@]+)@([^@]+)$")
	new_pos = new_pos and core.string_to_pos(new_pos)
	if not new_pos or not pos_date then
		return false, "Uložená pozice má neplatný formát!"
	end
	ch_core.teleport_player{
		type = "player",
		player = player_name,
		target_pos = new_pos,
		delay = 20.0,
		sound_before = ch_core.default_teleport_sound,
		sound_after = ch_core.default_teleport_sound,
	}
	return true
end

-- /začátek
local function zacatek(player_name, _param)
	local offline_charinfo = ch_core.offline_charinfo[player_name]
	if not offline_charinfo then
		return false, "Interní údaje nebyly nalezeny!"
	end
	local player = minetest.get_player_by_name(player_name)
	local player_pos = player and player:get_pos()
	if not player_pos then
		return false
	end
	local i = tonumber(offline_charinfo.zacatek_kam) or 1
	local zacatek_pos = ch_core.positions["zacatek_"..i] or ch_core.positions["zacatek_1"] or vector.zero()
	if vector.distance(player_pos, zacatek_pos) < 5 then
		return false, "Jste příliš blízko počáteční pozice!"
	end
	ch_core.teleport_player{
		type = "player",
		player = player_name,
		target_pos = zacatek_pos,
		delay = 30.0,
		sound_before = ch_core.default_teleport_sound,
		sound_after = ch_core.default_teleport_sound,
	}
	return true
end

local def

-- /začátek
def = {
	description = "Přenese vás na počáteční pozici.",
	func = zacatek,
}
core.register_chatcommand("zacatek", def);
core.register_chatcommand("začátek", def);
core.register_chatcommand("zacatek", def);
core.register_chatcommand("yačátek", def);
core.register_chatcommand("yacatek", def);

-- /doma
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
core.register_chatcommand("doma", table.copy(def));

-- /domů
def = {
	description  = "Přenese vás na domovskou pozici uloženou příkazem /doma.",
	privs = {home = true},
	func = domu,
}
core.register_chatcommand("domů", def);
core.register_chatcommand("domu", def);

-- /stavím
def = {
	description = "Uloží pozici na stavbě pro pozdější návrat příkazem /nastavbu. Pozici lze změnit jen jednou denně.",
	privs = {home = true},
	func = function(player_name)
		local player = minetest.get_player_by_name(player_name)
		local pos = player and player:get_pos()
		if pos then
			return stavim(player_name, pos)
		else
			return false
		end
	end
}
core.register_chatcommand("stavím", def)
core.register_chatcommand("stavim", def)

-- /nastavbu
def = {
	description = "Přenese vás na pozici na stavbě uloženou příkazem /stavím.",
	privs = {home = true},
	func = nastavbu,
}
core.register_chatcommand("nastavbu", def)
core.register_chatcommand("na_stavbu", def)

ch_core.close_submod("teleportace")
