	--[[

API:

function ch_bank.platba(def)
	-- Pokusí se provést platbu mezi dvěma postavami nebo mezi systémem
	a postavou. Jeden z parametrů from_player a to_player může být ""
	(systém). Částka amount musí být kladná. group může být nil.
	-- Vrací true v případě úspěchu. V případě selhání vrací false, error_message.
	-- Je-li def.simulation == true, ve skutečnosti platbu neprovede.

function ch_bank.zustatek(player_name, as_string)
	-- Vrátí zůstatek dané postavy, nebo nil, pokud postava neexistuje nebo nemůže používat bankovní služby.
		as_string: true => výsledek vrátí zformátovaný pomocí funkce ch_bank.formatovat_castku() (druhý vrácený řetězec bude hexadecimální colorstring)
			false => výsledek vrátí jako částku

]]

local _tfinv, utils = ...

-- imports
local account_max = assert(utils.account_max)
local formatovat_castku = assert(ch_core.formatovat_castku)
local get_amount_from_storage = assert(utils.get_amount_from_storage)
local get_current_bank_day = assert(ch_bank.get_current_bank_day)
local ifthenelse = assert(ch_core.ifthenelse)
local set_amount_to_storage = assert(utils.set_amount_to_storage)

local registered_after_transaction = {}

local next_transaction_id = 1

local function platba_inner(transaction_id, from_player, to_player, amount, label_from, label_to, is_simulation)
	local log_level = "action"
	local log_prefix = "[ch_bank]["..transaction_id..(ifthenelse(is_simulation, "*", "")).."] "
	local bank_day, cas = get_current_bank_day()
	assert(cas)
	local take_state_key, take_state_before, take_state_after, take_warning, take_record
	local give_state_key, give_state_before, give_state_after, give_warning, give_record

	if from_player == to_player then
		return false, "nelze postat platbu sobě"
	end

	minetest.log(log_level, log_prefix.."Bank day determined to be: "..bank_day)

	if from_player ~= "" then
		-- take
		from_player = ch_core.jmeno_na_prihlasovaci(from_player)
		local player_role = ch_core.get_player_role(from_player)
		if player_role == nil or not minetest.player_exists(from_player) then
			return false, "plátce/yně neexistuje"
		elseif player_role == "new" then
			return false, "nové postavy nemohou využívat vnitroherní platby"
		end
		local player_key = from_player..#from_player
		take_state_key = player_key.."/state"
		take_state_before = get_amount_from_storage(take_state_key)
		take_state_after = take_state_before - amount
		minetest.log(log_level, log_prefix.."Take plan: "..take_state_before.." => "..take_state_after.." ("..take_state_key..")")
		if player_role == "survival" and take_state_after < 0 then
			return false, "na účtu není dostatek peněz"
		elseif take_state_after < -account_max then
			take_warning = "Account overflow for player "..from_player.." value "..take_state_after.." will be truncated to -"..account_max.."."
			if is_simulation then return
				false, take_warning
			end
			minetest.log("warning", log_prefix..take_warning)
			take_state_after = -account_max
		end
		take_record = {
			from_player = from_player,
			to_player = to_player,
			label = label_from,
			change = take_state_after - take_state_before,
			op_count = 1,
			time = string.format("%02d:%02d:%02d", cas.hodina, cas.minuta, cas.sekunda),
		}
	end
	if to_player ~= "" then
		-- give
		to_player = ch_core.jmeno_na_prihlasovaci(to_player)
		local player_role = ch_core.get_player_role(to_player)
		if player_role == nil or not minetest.player_exists(to_player) then
			return false, "adresát/ka neexistuje"
		elseif player_role == "new" then
			return false, "nové postavy nemohou využívat vnitroherní platby"
		end
		local player_key = to_player..#to_player
		give_state_key = player_key.."/state"
		give_state_before = get_amount_from_storage(give_state_key)
		give_state_after = give_state_before + amount
		minetest.log(log_level, log_prefix.."Give plan: "..give_state_before.." => "..give_state_after.." ("..give_state_key..")")
		if give_state_after > account_max then
			if player_role == "survival" then
				return false, "přetečení účtu (maximální dovolená částka je "..formatovat_castku(account_max)..")"
			end
			give_warning = "Account overflow for player "..to_player.." value "..give_state_after.." will be truncated to "..account_max.."."
			if is_simulation then return
				false, give_warning
			end
			minetest.log("warning", log_prefix..give_warning)
			give_state_after = account_max
		end
		give_record = {
			from_player = from_player,
			to_player = to_player,
			label = label_to,
			change = give_state_after - give_state_before,
			op_count = 1,
			time = string.format("%02d:%02d:%02d", cas.hodina, cas.minuta, cas.sekunda),
		}
	end
	if take_state_key == nil and give_state_key == nil then
		return false, "není co dělat"
	end

	if is_simulation then
		return true, nil
	end

	if take_state_key ~= nil then
		utils.add_today_transaction(from_player, take_record)
	end
	if give_state_key ~= nil then
		utils.add_today_transaction(to_player, give_record)
	end

	if take_state_key ~= nil then
		-- take money
		if get_amount_from_storage(take_state_key) ~= take_state_before then
			error("[ch_bank] Security error! take_state_key == '"..take_state_key.."', state is "..get_amount_from_storage(take_state_key).." while expected is "..take_state_before.."!")
		end
		set_amount_to_storage(take_state_key, take_state_after)
		-- take successful
		minetest.log(log_level, log_prefix.."Take successful: state set to "..take_state_after)
	end
	if give_state_key ~= nil then
		-- give money
		if get_amount_from_storage(give_state_key) ~= give_state_before then
			error("[ch_bank] Security error! give_state_key == '"..give_state_key.."', state is "..get_amount_from_storage(give_state_key).." while expected is "..give_state_before.."!")
		end
		set_amount_to_storage(give_state_key, give_state_after)
		-- give successful
		minetest.log(log_level, log_prefix.."Give successful: state set to "..give_state_after)
	end

	-- update inventory formspec
	for _, player_name in ipairs({from_player, to_player}) do
		local player = player_name ~= "" and minetest.get_player_by_name(player_name)
		if player ~= nil then
			unified_inventory.set_inventory_formspec(player, unified_inventory.current_page[player_name] or unified_inventory.default)
		end
	end

	local transaction_info = {amount = amount}
	if from_player ~= "" then
		transaction_info.from_player = from_player
		transaction_info.from_player_before = take_state_before
		transaction_info.from_player_after = take_state_after
		transaction_info.from_player_label = label_from
	end
	if to_player ~= "" then
		transaction_info.to_player = to_player
		transaction_info.to_player_before = give_state_before
		transaction_info.to_player_after = give_state_after
		transaction_info.to_player_label = label_to
	end

	for _, func in ipairs(registered_after_transaction) do
		func(table.copy(transaction_info))
	end

	if take_warning ~= nil and give_warning ~= nil then
		return true, take_warning.."; "..give_warning
	else
		return true, take_warning or give_warning
	end
end

--[[
	Definice platby = {
		from_player = string, // přihlašovací jméno postavy, které mají být
			odebrány peníze, nebo ""
		to_player = string, // přihlašovací jméno postavy, které mají být
			připsány peníze, nebo ""
		amount = int > 0, // částka k převodu; musí být větší než 0
			a menší nebo rovna account_max
		label = string or nil, // popisek platby; text, který má být uložen
			k záznamu o platbě v historii; musí být uvedena buď
			"label" pro obě strany transakce, nebo "label_from" a "label_to"
			pro možnost rozdílného popisu pro from_player a to_player.
		label_from = string or nil,
		label_to = string or nil,
		message_to_chat = string or nil, // zpráva, která má být vypsána
			do četu v případě úspěšné transakce.
	}
	Poznámky:
	- alespoň jedna z hodnot from_player a to_player musí být jméno postavy
	- from_player se nesmí rovnat to_player (nelze poslat platbu sobě)
]]

function ch_bank.platba(def)
	assert(def)
	assert(def.from_player)
	assert(def.to_player)
	assert(def.amount)
	assert(def.label_from or def.label)
	assert(def.label_to or def.label)
	local amount = tonumber(def.amount)
	assert(amount)
	amount = math.floor(amount)
	assert(amount >= 0)
	if amount == 0 or (def.from_player == "" and def.to_player == "") then
		return false, "chybné zadání platby"
	end

	local transaction_id = next_transaction_id
	next_transaction_id = next_transaction_id + 1
	local log_prefix = "[ch_bank]["..transaction_id.."] "

	minetest.log("action", log_prefix.."Transaction STARTED: "..dump2(def))
	local success, warning_message = platba_inner(transaction_id, def.from_player, def.to_player, def.amount, def.label_from or def.label, def.label_to or def.label, def.simulation)
	if success then
		minetest.log("action", log_prefix.."Transaction FINISHED.")
		if def.message_to_chat ~= nil then
			local player_name = ifthenelse(def.to_player ~= "", def.to_player, def.from_player)
			if player_name ~= "" and minetest.get_player_by_name(player_name) ~= nil then
				ch_core.systemovy_kanal(player_name, def.message_to_chat)
			end
		end
	else
		minetest.log("action", log_prefix.."Transaction FAILED: "..(warning_message or "nil"))
		if def.expected then
			minetest.log("error", "[ch_bank] Expected transaction #"..transaction_id.." FAILED, money were lost. def = "..dump2(def))
		end
	end
	return success, warning_message
end

function ch_bank.zustatek(player_name, as_string)
	local player_role = ch_core.get_player_role(player_name)
	if player_role == nil then
		return nil, "postava neexistuje"
	elseif player_role == "new" then
		return nil, "nové postavy nemohou využívat vnitroherní platby"
	end
	local result = get_amount_from_storage(player_name..#player_name.."/state")
	if as_string then
		return formatovat_castku(result)
	end
	return result, nil
end

local cccccc = minetest.get_color_escape_sequence("#cccccc")

-- width: 10
function ch_bank.get_zustatek_formspec(player_name, x_base, y_base, width, id_penize, id_hcs, id_kcs, id_zcs)
	local zustatek, color = ch_bank.zustatek(player_name, true)
	if zustatek == nil then
		return ""
	end
	return "label["..(x_base + 0.05)..","..(y_base + 0.25)..";"..cccccc.."zůstatek na bankovním účtu:  "..minetest.get_color_escape_sequence(color)..minetest.formspec_escape(zustatek)..cccccc.." Kčs]"..
		"field["..(width - 3.2)..","..(y_base - 0.1)..";1,0.5;"..(id_penize or "penize")..";;1]"..
		"tooltip["..(id_penize or "penize")..";Částka pro výběr z účtu. Musí být celé číslo v rozsahu 1 až 10000.]"..
		"field_close_on_enter["..(id_penize or "penize")..";false]"..
		"item_image_button["..(width - 2.0)..","..(y_base - 0.2)..";0.6,0.6;ch_core:kcs_kcs;"..(id_kcs or "kcs")..";]"..
		"item_image_button["..(width - 1.3)..","..(y_base - 0.2)..";0.6,0.6;ch_core:kcs_h;"..(id_hcs or "hcs")..";]"..
		"item_image_button["..(width - 0.6)..","..(y_base - 0.2)..";0.6,0.6;ch_core:kcs_zcs;"..(id_zcs or "zcs")..";]"
end

function ch_bank.register_after_transaction(func)
	--[[ transaction_info = {
		[
		from_player,
		from_player_before,
		from_player_after,
		from_player_label,
		]
		[ to_player,
		to_player_before,
		to_player_after,
		to_player_label,
		]
		amount,
		}
	]]
	if type(func) == "function" then
		table.insert(registered_after_transaction, func)
	end
end

local function cc_platba(name, params)
	local player_role = ch_core.get_player_role(name)
	if player_role == "new" then
		return false, "nové postavy nemohou využívat bankovní služby"
	end
	if params == "" then
		return false, "chybné zadání"
	end
	local odkoho, komu, castka, zprava, x
	odkoho, x = params:match("^-([^ ]*) +([^ ].*)$")
	if odkoho ~= nil then
		params = x
	end
	komu, castka, zprava = params:match("^([^ ]+) +([^ ]+)(.*)$")
	castka = castka:gsub(",", "."):gsub("-$", "00"):gsub("_", "")
	castka = tonumber(castka)
	if castka ~= nil then
		castka = math.floor(castka * 100)
	end
	if castka == nil or castka <= 0 then
		return false, "neplatná částka"
	end
	zprava = zprava:gsub("^ *", "")
	if player_role ~= "admin" then
		if odkoho ~= nil then
			return false, "parametr -odkoho je dostupný pouze správě serveru"
		end
		if komu == "-" then
			return false, "platba systému je dostupná pouze správě serveru"
		end
	else
		if odkoho == "." then
			odkoho = nil
		end
		if komu == "." then
			komu = name
		elseif komu == "-" then
			komu = ""
		end
	end
	if odkoho ~= nil then
		odkoho = ch_core.jmeno_na_prihlasovaci(odkoho)
	end
	komu = ch_core.jmeno_na_prihlasovaci(komu)
	local success, warning_message = ch_bank.platba{
		from_player = odkoho or name,
		to_player = komu,
		amount = castka,
		label = zprava,
	}
	local zustatek_jmeno, zustatek
	if player_role == "admin" then
		if komu ~= "" then
			zustatek_jmeno = ch_core.prihlasovaci_na_zobrazovaci(komu)
			zustatek = ch_bank.zustatek(komu, true)
		else
			zustatek_jmeno = ch_core.prihlasovaci_na_zobrazovaci(odkoho or name)
			zustatek = ch_bank.zustatek(odkoho or name, true)
		end
	end
	if zustatek ~= nil then
		if success then
			return true, "platba proběhla úspěšně (nový zůstatek na účtu "..zustatek_jmeno..": "..zustatek.." Kčs)"
		else
			return false, (warning_message or "platba selhala").." ; zůstatek na účtu "..zustatek_jmeno..": "..zustatek.." Kčs"
		end
	else
		if success then
			return true, "platba proběhla úspěšně"
		else
			return false, warning_message or "platba selhala"
		end
	end
end

local cc_def = {
	params = "[-odkoho] <komu> <částka> [zpráva]",
	description = "Provede platbu bankovním převodem.",
	privs = {ch_registered_player = true},
	func = cc_platba,
}
minetest.register_chatcommand("platba", cc_def)

local function cc_zustatek(name, params)
	local role = ch_core.get_player_role(name)
	if role == "new" then
		return false, "nové postavy nemohou využívat bankovní služby"
	end
	params = ch_core.jmeno_na_prihlasovaci(params or "")
	if role ~= "admin" and params ~= "" and params ~= name then
		return false, "cizí zůstatky může vypsat jen Administrace"
	end
	local zustatek, color
	if params ~= "" then
		zustatek, color = ch_bank.zustatek(params, true)
	else
		zustatek, color = ch_bank.zustatek(name, true)
	end
	if zustatek == nil then
		return false, "Chyba: Postava "..params.." neexistuje nebo nesmí využívat bankovní služby!"
	end
	ch_core.systemovy_kanal(name, minetest.get_color_escape_sequence("#ffffff").."Zůstatek na účtu postavy "..ch_core.prihlasovaci_na_zobrazovaci(params)..": "..minetest.get_color_escape_sequence(color)..zustatek.." Kčs")
	return true
end

cc_def = {
	params = "[koho]",
	description = "Vypíše zůstatek na vašem bankovním účtu. Administrace může vypsat zůstatek i na cizích účtech.",
	privs = {ch_registered_player = true},
	func = cc_zustatek,
}
minetest.register_chatcommand("zůstatek", cc_def)
minetest.register_chatcommand("zustatek", cc_def)

function ch_bank.receive_inventory_fields(player, castka, typ_mince, listname)
	if castka == nil or not tostring(castka):match("^%d+$") then
		return false
	end
	castka = tonumber(castka)
	if castka == nil or castka <= 0 or castka > 10000 then
		return false
	end
	if typ_mince ~= "kcs" and typ_mince ~= "zcs" and typ_mince ~= "h" then
		if typ_mince == "hcs" then
			minetest.log("warning", "ch_bank.receive_inventory_fields() doesn't accept 'hcs' as typ_mince, 'h' is required!")
		end
		return false
	end
	local stack = ItemStack("ch_core:kcs_"..typ_mince.." "..castka)
	local inv = player:get_inventory()
	castka = ch_core.precist_hotovost(stack)
	assert(castka)
	assert(castka > 0)
	if listname == nil then
		listname = "main"
	end
	local player_name = player:get_player_name()
	if inv:room_for_item(listname, stack) then
		local success, message = ch_bank.platba{
			from_player = player_name,
			to_player = "",
			amount = castka,
			label = "výběr v hotovosti",
		}
		if success then
			inv:add_item(listname, stack)
		else
			ch_core.systemovy_kanal(player_name, "Výběr z účtu selhal: "..(message or "neznámý důvod"))
		end
	end
	return true
end

-- Mzda
local function on_joinplayer(player, last_login)
	minetest.after(utils.wage_time / 1000000, utils.try_pay_wage, player:get_player_name())
end

minetest.register_on_joinplayer(on_joinplayer)
