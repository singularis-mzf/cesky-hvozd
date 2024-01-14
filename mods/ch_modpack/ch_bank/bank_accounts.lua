--[[

API:

function ch_bank.extrahovat_penize(stacks)
	-- Odečte z ItemStacků v tabulce peníze a vrátí celkovou částku (může být 0).

function ch_bank.formatovat_castku(n)
	-- Zformátuje částku do textové podoby, např. "-1 235 123,45".
		Částka může být záporná. Druhá vrácená hodnota je doporučený
		hexadecimální colorstring pro hodnotu.

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

local bank_history_length = 100
-- local account_max = 2000000000 -- 20 milionů Kčs
local account_max = 1000000000000000 -- 10 bilionů Kčs
local bank_day_pattern = "%d+[.] *%d+[.] *%d+"
local change_pattern  = "-?%d+"

local ifthenelse = ch_core.ifthenelse
local storage = minetest.get_mod_storage()

-- [sha1(player_from_key/player_to_key/<take|give>/group/bank_day)] = index
local transaction_grouping = {}
local registered_after_transaction = {}

local function get_current_bank_day()
	local cas = ch_core.aktualni_cas()
	return string.format("%d. %d. %d", cas.den, cas.mesic, cas.rok)
end

local function transaction_grouping_key(from_player, to_player, op_type, group, bank_day)
	return minetest.sha1("@"..from_player..#from_player.."/"..to_player..#to_player.."/"..op_type.."/"..group.."/"..bank_day.."@", false)
end

local function deserialize_bank_record(s)
	local version, rest, from_player, to_player, before, change, after, op_count, bank_day, label
	if s == nil or s == "" then return nil end
	version, rest = s:match("^([^|]*)|(.*)$")
	if version == nil or version == "" then
		return nil
	elseif version == "1" then
		from_player, to_player, before, change, after, op_count, bank_day, label =
				rest:match("^([^|]*)|([^|]*)|("..change_pattern..")|("..change_pattern..")|("..change_pattern..")|(%d+)|("..bank_day_pattern..")|(.*)$")
		if from_player == nil or to_player == nil or tonumber(change) == nil or bank_day == nil or label == nil then
			minetest.log("warning", "deserialize_bank_record() failed: "..s)
			return nil
		end
		return {
			from_player = from_player,
			to_player = to_player,
			before = tonumber(before),
			change = tonumber(change),
			after = tonumber(after),
			op_count = tonumber(op_count),
			bank_day = bank_day,
			label = label,
		}
	else
		minetest.log("warning", "deserialize_bank_record(): unsupported version '"..version.."'")
		return nil
	end
end

local function serialize_bank_record(record)
	assert(record)
	assert(record.from_player) -- string
	assert(record.to_player) -- string
	assert(record.before) -- string
	assert(record.change) -- int
	assert(record.after) -- string
	assert(record.op_count) -- int
	assert(record.bank_day) -- string
	assert(record.label) -- string
	local before, change, after = record.before, record.change, record.after
	if type(before) == "number" then
		before = string.format("%d", before)
	end
	if type(change) == "number" then
		change = string.format("%d", change)
	end
	if type(after) == "number" then
		after = string.format("%d", after)
	end
	if record.from_player:find("|") ~= nil then
		minetest.log("error", "serialize_bank_record(): from_player cannot contain |: "..dump2(record))
		return nil
	elseif record.to_player:find("|") ~= nil then
		minetest.log("error", "serialize_bank_record(): to_player cannot contain |: "..dump2(record))
		return nil
	elseif not (before:match("^("..change_pattern..")$")) then
		minetest.log("error", "serialize_bank_record(): invalid format of before! "..dump2(record))
		return nil
	elseif not (after:match("^("..change_pattern..")$")) then
		minetest.log("error", "serialize_bank_record(): invalid format of after! "..dump2(record))
		return nil
	elseif not (change:match("^("..change_pattern..")$")) then
		minetest.log("error", "serialize_bank_record(): invalid format of change! "..dump2(record))
		return nil
	elseif not tonumber(record.op_count) or tonumber(record.op_count) <= 0 then
		minetest.log("error", "serialize_bank_record(): invalid op_count! "..dump2(record))
		return nil
	elseif not (record.bank_day:match("^("..bank_day_pattern..")$")) then
		minetest.log("error", "serialize_bank_record(): invalid format of bank_day! "..dump2(record))
		return nil
	end
	local result = "1|"..record.from_player.."|"..record.to_player.."|"..before.."|"..change.."|"..after.."|"..record.op_count.."|"..record.bank_day.."|"..record.label
	local debug = table.copy(record)
	debug.result = result
	local test = deserialize_bank_record(result)
	if test == nil then
		error("deserialization of a serialized record failed <"..result..">")
	end
	debug.test = test
	for _, field in ipairs({""}) do
		if test[field] ~= record[field] then
			minetest.log("warning", "serialize_bank_record(): "..field.." serialized incorrectly: "..dump2(debug))
		end
	end
	return result
end


function ch_bank.formatovat_castku(n)
	-- => text, colorstring
	-- minus, halere, string, division, remainder
	local m, h, s, d, r, color
	if n < 0 then
		m = "-"
		n = -n
	else
		m = ""
	end
	n = math.ceil(n)
	if m ~= "" then
		color = "#990000"
	elseif n < 100 then
		color = "#ffffff"
	else
		color = "#00ff00"
	end
	d = math.floor(n / 100.0)
	r = n - 100.0 * d
	if r > 0 then
		h = string.format("%02d", r)
	else
		h = "-"
	end
	s = string.format("%d", d)
	if #s > 3 then
		local t
		r = #s % 3
		t = {s:sub(1, r)}
		s = s:sub(r + 1, -1)
		while #s >= 3 do
			table.insert(t, s:sub(1, 3))
			s = s:sub(4, -1)
		end
		s = table.concat(t, " ")
	end
	return m..s..","..h, color
end

local precist_hotovost = ch_core.precist_hotovost

function ch_bank.extrahovat_penize(stacks)
	-- Odečte ze stacků v tabulce peníze a vrátí celkovou částku.
	local result = 0
	for _, stack in ipairs(stacks) do
		local value = precist_hotovost(stack)
		if value ~= nil then
			result = result + value
			stack:clear()
		end
	end
	return result
end

local function generate_new_transaction_record(transaction, player_key, new_record)
	local index_key = player_key.."/last_index"
	local record_index = storage:get_int(index_key) + 1
	local record = serialize_bank_record{
		from_player = new_record.from_player,
		to_player = new_record.to_player,
		before = new_record.before,
		change = new_record.change,
		after = new_record.after,
		op_count = 1,
		bank_day = new_record.bank_day,
		label = new_record.label or "",
	}
	if record == nil then
		minetest.log("warning", "[ch_bank] serialization failed!")
		return nil
	end

	-- remove an old record
	if record_index > bank_history_length then
		transaction[player_key.."/"..(record_index - bank_history_length)] = ""
	end
	-- save the record
	transaction[player_key.."/"..record_index] = record
	-- update the index
	transaction[index_key] = record_index
	return record_index
end

local function generate_grouped_transaction_record(transaction, player_key, new_record, group)
	assert(group)
	local grouping_key = transaction_grouping_key(new_record.from_player, new_record.to_player, ifthenelse(new_record.change > 0, "give", "take"), group, new_record.bank_day)
	local record_index = transaction_grouping[grouping_key]
	if record_index ~= nil then
		local record_key = player_key.."/"..record_index
		local record = deserialize_bank_record(storage:get_string(record_key))
		if record ~= nil then
			if new_record.label ~= nil then
				record.label = new_record.label
			end
			record.change = assert(tonumber(record.change)) + new_record.change
			if math.abs(record.change) <= account_max then
				record.after = new_record.after
				record.op_count = tonumber(record.op_count) + 1
				record = serialize_bank_record(record)
				if record == nil then
					minetest.log("warning", "[ch_bank] serialization failed! (will add new record)")
				else
					-- save the record
					transaction[record_key] = record
					return record_index
				end
			end
		end
	end
	record_index = generate_new_transaction_record(transaction, player_key, new_record)
	if record_index ~= nil then
		transaction_grouping[grouping_key] = record_index
	end
	return record_index
end

local function generate_transaction_record(transaction, player_key, new_record, group)
	assert(new_record)
	assert(new_record.from_player ~= nil)
	assert(new_record.to_player ~= nil)
	assert(new_record.before ~= nil and tonumber(new_record.before) ~= nil)
	assert(new_record.change ~= nil and tonumber(new_record.change) ~= nil)
	assert(new_record.after ~= nil and tonumber(new_record.after) ~= nil)
	if new_record.bank_day == nil then
		error("bank_day is nil!")
	elseif not new_record.bank_day:match("^"..bank_day_pattern.."$") then
		error("bank_day <"..new_record.bank_day.."> does not match the bank_day_pattern <"..bank_day_pattern..">!")
	end

	if group ~= nil then
		return generate_grouped_transaction_record(transaction, player_key, new_record, group)
	else
		return generate_new_transaction_record(transaction, player_key, new_record)
	end
end

local function get_amount_from_storage(key)
	assert(type(key) == "string")
	local s, n
	s = storage:get_string(key)
	if s == "" then
		n = 0
	else
		n = tonumber(s)
		if n == nil then
			error("[ch_bank] get_amount_from_storage(): cannot decode amount '"..s.."' read from key '"..key.."'!")
		end
		if n < -account_max or n > account_max then
			minetest.log("warning", "[ch_bank] get_amount_from_storage(): the value read is out of range (s="..s..")(n="..n..")(key="..key..")!")
		end
	end
	assert(type(n) == "number")
	return n
end

local function set_amount_to_storage(key, amount)
	assert(type(key) == "string")
	assert(type(amount) == "number")
	assert(amount >= -account_max)
	assert(amount <= account_max)
	local s = string.format("%d", amount)
	assert(tonumber(s) == amount)
	storage:set_string(key, s)
	local s2 = storage:get_string(key)
	assert(s == s2)
	assert(amount == tonumber(s2))
end

local next_transaction_id = 1

local function platba_inner(transaction_id, from_player, to_player, amount, label_from, label_to, group, is_simulation)
	local log_level = "action"
	local log_prefix = "[ch_bank]["..transaction_id..(ifthenelse(is_simulation, "*", "")).."] "
	local bank_day = get_current_bank_day()
	local transaction = {}
	local take_state_key, take_state_before, take_state_after, take_warning
	local give_state_key, give_state_before, give_state_after, give_warning

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
		local take_record_index = generate_transaction_record(transaction, player_key, {
			from_player = from_player,
			to_player = to_player,
			before = take_state_before,
			change = -amount,
			after = take_state_after,
			bank_day = bank_day,
			label = label_from,
			}, group)
		minetest.log(log_level, log_prefix.."Take record index: "..(take_record_index or "nil"))
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
				return false, "přetečení účtu (maximální dovolená částka je "..ch_bank.formatovat_castku(account_max)..")"
			end
			give_warning = "Account overflow for player "..to_player.." value "..give_state_after.." will be truncated to "..account_max.."."
			if is_simulation then return
				false, give_warning
			end
			minetest.log("warning", log_prefix..give_warning)
			give_state_after = account_max
		end
		local give_record_index = generate_transaction_record(transaction, player_key, {
			from_player = from_player,
			to_player = to_player,
			before = give_state_before,
			change = amount,
			after = give_state_after,
			bank_day = bank_day,
			label = label_to,
			}, group)
		minetest.log(log_level, log_prefix.."Give record index: "..(give_record_index or "nil"))
	end
	if take_state_key == nil and give_state_key == nil then
		return false, "není co dělat"
	end

	if is_simulation then
		return true, nil
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
	local counter = 0
	for k, v in pairs(transaction) do
		local t = type(v)
		counter = counter + 1
		minetest.log(log_level, log_prefix.."Transaction setup ["..counter.."]: key("..k..") type("..t..") value ("..dump2(v)..").")
		if t == "string" then
			storage:set_string(k, v)
		elseif t == "number" then
			storage:set_int(k, v)
		else
			minetest.log("warning", log_prefix.."Transaction contains a value of invalid type '"..t.."' with key '"..k.."'!")
		end
	end
	minetest.log(log_level, log_prefix.."Transaction setup finished, "..counter.." keys were set.")

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
	local success, warning_message = platba_inner(transaction_id, def.from_player, def.to_player, def.amount, def.label_from or def.label, def.label_to or def.label, def.group, def.simulation)
	if success then
		minetest.log("action", log_prefix.."Transaction FINISHED.")
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
		return ch_bank.formatovat_castku(result)
	end
	return result, nil
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
		print("DEBUG: <"..(castka or "nil")..">")
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
