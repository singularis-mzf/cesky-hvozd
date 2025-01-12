local _tfinv, utils = ...

local F = minetest.formspec_escape
local formatovat_castku = ch_core.formatovat_castku
local get_or_add = ch_core.get_or_add
local ifthenelse = ch_core.ifthenelse

local account_max = utils.account_max
local storage = utils.storage

local worldpath = minetest.get_worldpath()

local bank_history = { --[[
	bank_month => { -- bank_month např. "2023-12"
		player_name = { -- player_name např. "Administrace"
			day => { -- day: 1..31
				state_before = int,
				state_after = int,
				transactions = {
					{from_player, to_player, label, change, op_count}... -- v pořadí od nejnovější(!) transakce
				}
			}
		}
	}
]]}

local today_transactions = { --[[
	player_name => {
		bank_day = string,
		state_before = int,
		has_wage = bool,
		transactions = {
			-- v pořadí od nejstarší(!) transakce (nejnovější transakce je poslední)
			{from_player, to_player, label, change, op_count, time, [transactions = {...}]}...
		}
	}
]]}

local plprikaz_states = {
	[""] = {komu = "", castka = "", poznamka = "", zprava = "", chyba = ""},
	--[[
	player_name => {
		komu = string,
		castka = string,
		poznamka = string,
		zprava = string,
		chyba = string,
	}
]]}

function utils.check_transaction_record(record, expect_time)
	if type(record) ~= "table" then
		return false, "record type"
	end
	local r = table.copy(record)
	if type(r.from_player) ~= "string" then
		return false, "r.from_player type"
	elseif r.from_player ~= "" and not minetest.player_exists(r.from_player) then
		minetest.log("warning", "check_transaction_record(): record with non-existing from_player: "..dump2(r))
	end
	r.from_player = nil

	if type(r.to_player) ~= "string" then
		return false, "r.to_player type"
	elseif r.to_player ~= "" and not minetest.player_exists(r.to_player) then
		minetest.log("warning", "check_transaction_record(): record with non-existing from_player: "..dump2(r))
	end
	r.to_player = nil

	if type(r.label) ~= "string" then
		return false, "r.label type"
	end
	r.label = nil

	if type(r.change) ~= "number" then
		return false, "r.change type"
	elseif r.change < -account_max or r.change > account_max then
		return false, "r.change out of range"
	elseif r.change ~= math.floor(r.change) then
		return false, "r.change is not integer"
	end
	r.change = nil

	if type(r.op_count) ~= "number" then
		return false, "r.op_count type"
	elseif r.op_count < 1 or r.op_count ~= math.floor(r.op_count) then
		return false, "r.op_count value"
	end
	r.op_count = nil

	if expect_time then
		if r.time == nil then
			return false, "r.time is nil"
		elseif type(r.time) ~= "string" then
			return false, "r.time type"
		end
		r.time = nil
	end

	local unexpected_fields = {}
	for k, _ in pairs(r) do
		table.insert(unexpected_fields, k)
	end
	if #unexpected_fields > 0 then
		return false, #unexpected_fields.." unexpected fields: "..table.concat(unexpected_fields, ", ")
	end
	return true
end

function utils.get_amount_from_storage(key)
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
local get_amount_from_storage = utils.get_amount_from_storage

function utils.set_amount_to_storage(key, amount)
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

function ch_bank.get_current_bank_day()
	local cas = ch_time.aktualni_cas()
	return cas:YYYY_MM_DD(), cas
end
local get_current_bank_day = ch_bank.get_current_bank_day

local function convert_transactions_to_archive(t_in)
	local result = {}
	local tr_key_to_i = {}
	for i = #t_in, 1, -1 do
		local tr = t_in[i]
		local tr_key = tr.from_player.."/"..tr.to_player.."/"..tr.label
		local old_i = tr_key_to_i[tr_key]
		if old_i == nil or math.abs(result[old_i].change + tr.change) > account_max then
			tr.time = nil
			tr.transactions = nil
			table.insert(result, tr)
			tr_key_to_i[tr_key] = #result
		else
			-- combine transactions
			local tr_old = result[old_i]
			tr_old.change = tr_old.change + tr.change
			tr_old.op_count = tr_old.op_count + tr.op_count
		end
	end
	return result
end

local function prev_bank_month(bank_month)
	local n = tonumber(bank_month:sub(6,7)) - 1
	if n > 0 then
		return string.format("%s%02d", bank_month:sub(1,5), n)
	else
		return string.format("%04d-12", assert(tonumber(bank_month:sub(1,4))) - 1)
	end
end

local function load_file(dir_path, file_name)
	local f = io.open(worldpath.."/"..dir_path.."/"..file_name)
	local result
	if f then
		result = f:read("*a")
		f:close()
	end
	return result
end

local function save_file(dir_path, file_name, content)
	minetest.mkdir(worldpath.."/"..dir_path)
	minetest.safe_file_write(worldpath.."/"..dir_path.."/"..file_name, content)
end

local function get_bank_month_history(player_name, bank_month)
	local month = get_current_bank_day():sub(1,7)
	local i = 1
	while i <= 3 and month ~= bank_month do
		month = prev_bank_month(month)
		i = i + 1
	end
	if month ~= bank_month then
		return nil -- 3 months only
	end
	local bhistory = get_or_add(bank_history, bank_month)
	if bhistory[player_name] == nil then
		-- load from file
		local json = load_file("bank/"..bank_month, player_name)
		local h = {}
		if json == nil then
			minetest.log("warning", "No bank history data found for player "..player_name..", bank month "..bank_month..".")
		else
			local encoded_data = assert(minetest.parse_json(json))
			for day_id, day_data in pairs(encoded_data) do
				local day = tonumber(day_id:sub(2,-1))
				if day == nil then
					error("Cannot parse day id '"..day.."'!")
				end
				h[day] = day_data
				if day_data.transactions == nil then
					day_data.transactions = {}
				else
					for _, tr in ipairs(day_data.transactions) do
						tr.time = nil -- remove time if stored (it should not be)
						tr.transactions = nil
					end
				end
			end
		end
		bhistory[player_name] = h
		return h
	else
		return bhistory[player_name]
	end
end

local function save_bank_history(player_name, bank_month)
	local current_month = ch_core.get_or_add(bank_history, bank_month)
	local current_data = ch_core.get_or_add(current_month, player_name)
	local encoded_data = {}
	for i = 1, 31 do
		if current_data[i] ~= nil then
			encoded_data["D"..i] = current_data[i]
		end
	end

	local data, error_message = minetest.write_json(encoded_data)
	if data == nil then
		error("save_bank_history(): serialization error: "..tostring(error_message or "nil"))
	end
	save_file("bank/"..bank_month, player_name, data)
	minetest.log("action", "[ch_bank] Bank history saved to bank/"..bank_month.."/"..player_name.." ("..#data.." bytes)")
end

local function open_new_bank_day(player_name, bank_day, state_before)
	minetest.log("action", "[ch_bank DEBUG] open_new_bank_day("..player_name..", "..bank_day..", "..state_before..")")
	local player_key = player_name..#player_name
	local result = {
		bank_day = bank_day,
		state_before = state_before,
		transactions = {},
	}
	local result_json = assert(minetest.write_json(result))
	storage:set_string(player_key.."/transactions", result_json)
	today_transactions[player_name] = result
	minetest.log("action", "[ch_bank] Bank day "..bank_day.." openned for "..player_name..".")
	return result
end

--[[
	Vrátí strukturu jako today_transactions[player_name], ale postará
	se o okrajové případy.
]]
local function get_today_transactions(player_name)
	local player_role = ch_core.get_player_role(player_name)
	if player_role == nil or player_role == "new" then
		return nil
	end
	local result = today_transactions[player_name]
	local result_json
	local player_key = player_name..#player_name
	local today = ch_bank.get_current_bank_day()
	if result == nil then
		-- načíst...
		result_json = storage:get_string(player_key.."/transactions")
		minetest.log("action", "[ch_bank DEBUG] get_today_transactions("..player_name..") on "..today..", will try to load them.")
		if result_json == "" then
			-- zatím nic, založit nový den
			return open_new_bank_day(player_name, today, get_amount_from_storage(player_key.."/state"))
		end
		-- načíst z JSONu
		result = assert(minetest.parse_json(result_json))
		assert(result.bank_day)
		assert(result.state_before)
		if result.transactions == nil then
			result.transactions = {}
		end
		today_transactions[player_name] = result
		minetest.log("action", "[ch_bank] A bank day "..result.bank_day.." loaded for "..player_name.." from the storage ("..#result.transactions.." transactions).")
	end
	if result.bank_day == today then
		return result
	end
	-- načten starý den
	local bank_month = result.bank_day:sub(1,7)
	local day = tonumber(result.bank_day:sub(9,10))
	local history = get_bank_month_history(player_name, bank_month) or {}
	local state_after = get_amount_from_storage(player_key.."/state")
	history[day] = {
		state_before = result.state_before,
		state_after = state_after,
		transactions = convert_transactions_to_archive(result.transactions),
	}
	save_bank_history(player_name, bank_month)
	today_transactions[player_name] = nil
	minetest.log("action", "[ch_bank] Bank day "..result.bank_day.." closed for "..player_name.." with states: "..result.state_before.." => "..state_after.." .")
	-- Open a new bank day
	return open_new_bank_day(player_name, today, get_amount_from_storage(player_key.."/state"))
end

function utils.add_today_transaction(player_name, record)
	local tt = get_today_transactions(player_name)
	assert(tt)
	assert(tt.transactions)
	local check, error_message = utils.check_transaction_record(record, true)
	if not check then
		error("Invalid transaction record: "..(error_message or "nil"))
	end
	local last_transaction = tt.transactions[#tt.transactions]
	if last_transaction ~= nil and record.from_player == last_transaction.from_player and record.to_player == last_transaction.to_player and record.label == last_transaction.label and math.abs(last_transaction.change + record.change) < account_max then
		if last_transaction.transactions ~= nil then
			-- přidat k existující kombinované transakci
			table.insert(last_transaction.transactions, record)
			last_transaction.change = last_transaction.change + record.change
			last_transaction.op_count = last_transaction.op_count + record.op_count
		else
			-- vytvořit novou kombinovanou transakci
			local subtransactions = { last_transaction, record }
			tt.transactions[#tt.transactions] = {
				from_player = last_transaction.from_player,
				to_player = last_transaction.to_player,
				change = last_transaction.change + record.change,
				label = last_transaction.label,
				op_count = last_transaction.op_count + record.op_count,
				time = last_transaction.time,
				transactions = subtransactions,
			}
		end
	else
		-- přidat novou samostatnou transakci
		table.insert(tt.transactions, record)
	end
	local result_json = assert(minetest.write_json(tt))
	storage:set_string(player_name..#player_name.."/transactions", result_json)
end

local function formatovat_bank_day(bank_day)
	return string.format("%d. %d. %d", bank_day:sub(9,10), bank_day:sub(6,7), bank_day:sub(1,4))
end

local function transaction_to_formspec(transaction, tree_level)
	local column1, color2, text2, text3, castka
	if tree_level == nil then
		tree_level = 1
	end
	castka, color2 = formatovat_castku(transaction.change)
	text2 = F(ifthenelse(transaction.change > 0, "+"..castka.." Kčs", castka.." Kčs"))
	if transaction.change > 0 and transaction.from_player ~= "" then
		column1 = ",« "..F(ch_core.prihlasovaci_na_zobrazovaci(transaction.from_player))
	elseif transaction.change < 0 and transaction.to_player ~= "" then
		column1 = ",⇨"..F(ch_core.prihlasovaci_na_zobrazovaci(transaction.to_player))
	else
		column1 = "#cccccc,-"
	end
	if transaction.op_count > 1 then
		text3 = F("["..transaction.op_count.." tr.] "..transaction.label)
		if transaction.transactions ~= nil then
			local result = {
				tree_level..","..column1..","..color2..","..text2..",#ffffff,"..text3
			}
			for i = #transaction.transactions, 1, -1 do
				table.insert(result, transaction_to_formspec(transaction.transactions[i], tree_level + 1))
			end
			return table.concat(result, ",")
		end
	elseif transaction.time ~= nil then
		text3 = F(transaction.time.." "..transaction.label)
	else
		text3 = F(transaction.label)
	end
	return tree_level..","..column1..","..color2..","..text2..",#ffffff,"..text3
end

local function bank_history_day_to_formspec(bank_day, day_record)
	-- {state_before, state_after, transactions = {{from_player, to_player, label, change, op_count}...}}
	local result = {
		"0,,"..F(formatovat_bank_day(bank_day))..",,,,",
	}
	-- => tree,color,text,color,text,color,text
	for _, transaction in ipairs(day_record.transactions) do
		table.insert(result, transaction_to_formspec(transaction))
	end
	local castka, barva = formatovat_castku(day_record.state_before)
	table.insert(result, "1,#cccccc,❉ poč. stav,"..barva..","..F(castka)..",,")
	return table.concat(result, ",")
end

local function bank_current_day_to_formspec(player_name)
	local zustatek = ch_bank.zustatek(player_name)
	local tt = get_today_transactions(player_name)
	if zustatek == nil or tt == nil then
		minetest.log("warning", "Unexpected call to bank_current_day_to_formspec() for "..player_name.." (nil)")
		return nil
	end
	local result = {
		"0,,"..F(formatovat_bank_day(tt.bank_day))..",,,,(dnes)",
	}
	for i = #tt.transactions, 1, -1 do
		table.insert(result, transaction_to_formspec(tt.transactions[i]))
	end
	local castka, barva = formatovat_castku(tt.state_before)
	table.insert(result, "1,#cccccc,❉ poč. stav,"..barva..","..F(castka)..",,")
	return table.concat(result, ",")
end

--[[
	Vrátí historii účtu dané postavy v textové podobě, která může být
	přímo použita v prvku table[] ve formspecu.
]]
function utils.get_bank_history_strlist(player_name)
	local today = ch_bank.get_current_bank_day()
	local today_day = tonumber(today:sub(9,10))
	local bank_month = today:sub(1,7)
	local result = {
		-- current day
		bank_current_day_to_formspec(player_name)
	}
	-- current month
	local history = get_bank_month_history(player_name, bank_month)
	if history ~= nil then
		for day = today_day - 1, 1, -1 do
			if history[day] ~= nil then
				table.insert(result, bank_history_day_to_formspec(string.format("%s-%02d", bank_month, day), history[day]))
			end
		end
	end
	for _ = 2, 3 do
		bank_month = prev_bank_month(bank_month)
		history = get_bank_month_history(player_name, bank_month)
		if history ~= nil then
			for day = 31, 1, -1 do
				if history[day] ~= nil then
					table.insert(result, bank_history_day_to_formspec(string.format("%s-%02d", bank_month, day), history[day]))
				end
			end
		end
	end
	return table.concat(result, ",")
end

function utils.reset_bank_history(player_name)
	for _, month_records in pairs(bank_history) do
		month_records[player_name] = nil
	end
	local month = get_current_bank_day():sub(1,7)
	for i = 1, 3 do
		os.remove(worldpath.."/bank/"..month.."/"..player_name)
		month = prev_bank_month(month)
	end
	local player_key = player_name..#player_name
	storage:set_string(player_key.."/transactions", "")
	today_transactions[player_name] = nil
end

local function get_formspec(player, perplayer_formspec)
	local fs = perplayer_formspec
	local player_info = ch_core.normalize_player(player)
	local player_name = assert(player_info.player_name) -- (who is the formspec for)
	local player_viewname_colored = ch_core.prihlasovaci_na_zobrazovaci(player_name, true)
	local plprikaz_state = plprikaz_states[player_name]
	if plprikaz_state == nil then
		plprikaz_state = table.copy(plprikaz_states[""])
		plprikaz_states[player_name] = plprikaz_state
	end
--[[
	local left_form = {
		x = fs.std_inv_x,
		y = fs.form_header_y + 0.5,
		w = 10.0,
		h = fs.std_inv_y - fs.form_header_y - 1.25,
	}
	local right_form = {
		x = fs.page_x - 0.25,
		y = fs.page_y + 0.5,
		w = fs.pagecols - 1,
		h = fs.pagerows - 1,
	}
	local sbar_width = 0.5
	local tooltip
		   ]]

	local formspec = {
		fs.standard_inv_bg,
		"label[0.3,0.65;Pohyby na účtu ("..player_viewname_colored..ch_core.colors.white..")]",
		"box[0.3,0.9;10,4.1;#ff000033]", -- DEBUG (vlevo)

		"box[10.5,5.25;7,6.5;#002200]", -- pozadí platebního příkazu
		"label[11.0,5.75;Platební příkaz]",
		"field[11.0,6.5;6,0.5;ch_bank_komu;komu:;"..F(plprikaz_state.komu).."]",
		"field[11.0,7.5;2.5,0.5;ch_bank_castka;částka:;"..F(plprikaz_state.castka).."]",
		"label[13.75,7.75;Kčs]",
		"field[11.0,8.5;6,0.5;ch_bank_pozn;poznámka pro vás:;", F(plprikaz_state.poznamka), "]",
		"field[11.0,9.5;6,0.5;ch_bank_zprava;zpráva pro příjemce/yni:;", F(plprikaz_state.zprava), "]",
		"tooltip[ch_bank_zprava;Zpráva se používá místo variabilního symbolu...]",
		"tablecolumns[tree;color;text;color;text;color;text]",
	}
	if plprikaz_state.chyba == "" then
		table.insert(formspec, "button[11.0,10.25;6,1;ch_bank_test;ověřit zadání a možnost platby]")
	elseif plprikaz_state.chyba == "@OK" then
		table.insert(formspec, "button[11.0,10.25;6,1;ch_bank_platba;provést platbu]")
	else
		table.insert(formspec, "button[11.0,10.25;6,1;ch_bank_test;došlo k chybě\nznovu ověřit]")
	end
-- button[11.0,10.25;6,1;pltest;Chybové hlášení.\nZnovu ověřit zadání]
	table.insert(formspec, "table[0.3,0.9;17.2,4.1;ch_bank_pohyby;0,#cccccc,od/komu,,částka,,poznámka,")
	table.insert(formspec, utils.get_bank_history_strlist(player_name) or "")
	table.insert(formspec, ";3]")
	return {
		draw_item_list = false,
		formspec = table.concat(formspec),
	}
end

unified_inventory.register_button("ch_bank", {
	type = "image",
	image = "[combine:40x40:4,4=ch_core_kcs_1kcs.png",
	tooltip = "Bankovnictví",
	condition = function(player)
		return ch_bank.zustatek(player:get_player_name()) ~= nil
	end,
})

unified_inventory.register_page("ch_bank", {get_formspec = get_formspec})

local kcs1, kcs2 = "Kčs", "Kcs"
local function precist_castku(s)
	print(s)
	if s:sub(-#kcs1,-1) == kcs1 then
		s = s:sub(1, -#kcs1 - 1)
	elseif s:sub(-#kcs2,-1) == kcs2 then
		s = s:sub(1, -#kcs2 - 1)
	end
	s = s:gsub("[ _]", ""):gsub(",%-", ".00"):gsub(",", ".")
	if s:find("%.") == nil then
		if s:find("^%d+$") ~= nil then
			return tonumber(s) * 100
		end
	elseif s:find("^%d+[.]%d%d$") ~= nil then
		return tonumber(s:sub(1,-4)) * 100 + tonumber(s:sub(-2,-1))
	end
end

local function on_player_receive_fields(player, formname, fields)
	if formname ~= "" then return end
	local player_info = ch_core.normalize_player(player)
	local player_name = assert(player_info.player_name) -- (who is the formspec for)

	if fields.quit then
		plprikaz_states[player_name] = table.copy(plprikaz_states[""])
		return
	end
	if not fields.ch_bank_test and not fields.ch_bank_platba then
		return
	end

	local komu = fields.ch_bank_komu or ""
	local castka = fields.ch_bank_castka or ""
	local poznamka = fields.ch_bank_pozn or ""
	local zprava = fields.ch_bank_zprava or ""
	local chyby = {}

	local np = ch_core.normalize_player(komu)
	if np.role == "none" then
		table.insert(chyby, "Postava "..komu.." neexistuje!")
	elseif ch_bank.zustatek(np.player_name) == nil then
		table.insert(chyby, "Postava "..komu.." nemůže používat bankovní služby.")
	else
		komu = np.viewname
	end
	local castka_n = precist_castku(castka)
	if castka_n == nil then
		table.insert(chyby, "Chybný formát zadané částky!")
	else
		castka = string.format("%.2f", castka_n / 100.0):gsub("%.", ",")
	end
	if poznamka ~= "" then
		poznamka = ch_core.utf8_truncate_right(poznamka, 160, "")
	end
	if zprava ~= "" then
		zprava = ch_core.utf8_truncate_right(zprava, 160, "")
	end

	local plprikaz_state = {komu = komu, castka = castka, poznamka = poznamka, zprava = zprava, chyba = ""}
	-- ifthenelse(#chyby == 0, "@OK", #chyby.." chyb")
	plprikaz_states[player_name] = plprikaz_state

	if #chyby > 0 then
		for _, chyba in ipairs(chyby) do
			ch_core.systemovy_kanal(player_name, "CHYBA: "..chyba)
		end
		plprikaz_state.chyba = #chyby.." chyb v zadání"
		return
	end

	-- simulovat nebo vykonat platbu
	local success, error_message = ch_bank.platba{
		from_player = player_name,
		to_player = ch_core.jmeno_na_prihlasovaci(komu),
		amount = castka_n,
		label_from = poznamka,
		label_to = zprava,
		simulation = fields.ch_bank_platba == nil,
	}
	if not success then
		-- chyba při platbě nebo simulaci platby
		plprikaz_state.chyba = "chyba při platbě: "..(error_message or "neznámá chyba")
	elseif fields.ch_bank_platba then
		plprikaz_states[player_name] = table.copy(plprikaz_states[""])
		ch_core.systemovy_kanal(player_name, "Převod proveden: "..formatovat_castku(castka_n).." Kčs bylo převedeno postavě "..ch_core.prihlasovaci_na_zobrazovaci(komu)..".")
	else
		plprikaz_state.chyba = ifthenelse(fields.ch_bank_platba == nil, "@OK", "")
	end

	unified_inventory.set_inventory_formspec(player, "ch_bank")
	return true
end
minetest.register_on_player_receive_fields(on_player_receive_fields)

function utils.try_pay_wage(player_name, join_timestamp, ap_xp_at_join)
	if utils.wage_amount <= 0 then return end
	local online_charinfo = ch_core.online_charinfo[player_name]
	local offline_charinfo = ch_core.offline_charinfo[player_name]
	local ap_xp_now = (offline_charinfo and offline_charinfo.ap_xp) or 0
	local now = minetest.get_us_time()

	if
		online_charinfo ~= nil and
		offline_charinfo ~= nil and
		online_charinfo.join_timestamp == join_timestamp and
		ap_xp_now >= ap_xp_at_join + 10
	then
		local tt = get_today_transactions(player_name)
		if tt and not tt.has_wage then
			tt.has_wage = true
			ch_bank.platba{
				from_player = "",
				to_player = player_name,
				amount = utils.wage_amount,
				label = "mzda (za připojení do hry)",
				message_to_chat = "banka: na účet jste obdržel/a mzdu 30,- Kčs",
			}
		end
	end
end
