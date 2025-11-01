ch_core.open_submod("penize", {lib = true})

-- ch_core:kcs_{h,kcs,zcs}
minetest.register_craftitem("ch_core:kcs_h", {
	description = "haléř československý",
	inventory_image = "ch_core_kcs_1h.png",
	stack_max = 10000,
	groups = {money = 1},
})
minetest.register_craftitem("ch_core:kcs_kcs", {
	description = "koruna československá (Kčs)",
	inventory_image = "ch_core_kcs_1kcs.png",
	stack_max = 10000,
	groups = {money = 2},
})
minetest.register_craftitem("ch_core:kcs_zcs", {
	description = "zlatka československá (Zčs)",
	inventory_image = "ch_core_kcs_1zcs.png",
	stack_max = 10000,
	groups = {money = 3},
})

local penize = {
	["ch_core:kcs_h"] = 1,
	["ch_core:kcs_kcs"] = 100,
	["ch_core:kcs_zcs"] = 10000,
}

local payment_methods = {}

--[[
	Zformátuje částku do textové podoby, např. "-1 235 123,45".
	Částka může být záporná. Druhá vrácená hodnota je doporučený
	hexadecimální colorstring pro hodnotu.
	-- n : int
	=> text : string, colorstring : string
]]
function ch_core.formatovat_castku(n)
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
		color = "#bb0000"
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

--[[
	Vrátí tabulku ItemStacků s penězi v dané výši. Částka musí být nezáporná.
	Případné desetinné číslo se zaokrouhlí dolů.
	Platidla jsou seřazena od nejvyšší hodnoty po nejnižší.
	Pro nulu vrací prázdnou tabulku.
]]
function ch_core.hotovost(castka)
	local debug = {"puvodni castka: "..castka}
	local stacks = {}
	castka = math.floor(castka)
	if castka < 0 then
		return stacks
	end
	while castka > 10000 * 10000 do -- 10 000 zlatek
		table.insert(stacks, ItemStack("ch_core:kcs_zcs 10000"))
		castka = castka - 10000 * 10000
		table.insert(debug, "ch_core:kcs_zcs 10000 => "..castka)
	end
	while castka > 10000 * 100 do -- 10 000 korun
		local n = math.floor(castka / 10000)
		assert(n >= 1 and n <= 10000)
		table.insert(stacks, ItemStack("ch_core:kcs_zcs "..n))
		castka = castka - n * 10000
		table.insert(debug, "ch_core:kcs_zcs "..n.." => "..castka)
	end
	local n = math.floor(castka / 100)
	assert(n >= 0 and n <= 10000)
	if n > 0 then
		table.insert(stacks, ItemStack("ch_core:kcs_kcs "..n))
		table.insert(debug, "ch_core:kcs_kcs "..n.." => "..castka)
	end
	castka = castka - n * 100
	if castka > 0 then
		assert(castka >= 1 and castka <= 100)
		table.insert(stacks, ItemStack("ch_core:kcs_h "..castka))
		table.insert(debug, "ch_core:kcs_h "..castka.." => 0")
	end
	return stacks
end

-- 0 = upřednostňovat platby z/na účet
-- 1 = přijímat v hotovosti, platit z účtu
-- 2 = přijímat na účet, platit hotově
-- 3 = upřednostňovat hotovost
-- 4 = zakázat platby z účtu

--[[
function ch_core.nastaveni_prichozich_plateb(player_name)
	local offline_charinfo = ch_data.offline_charinfo[player_name]
	if offline_charinfo == nil then
		return {}
	end
	local rezim = offline_charinfo.rezim_plateb
	return {cash = true, bank = true, prefer_cash = rezim ~= 0 and rezim ~= 2}
end

function ch_core.nastaveni_odchozich_plateb(player_name)
	local offline_charinfo = ch_data.offline_charinfo[player_name]
	if offline_charinfo == nil then
		return {}
	end
	local rezim = offline_charinfo.rezim_plateb
	return {cash = true, bank = rezim ~= 4, prefer_cash = rezim >= 2}
end
]]
--[[
	Parametr musí být ItemStack, seznam ItemStacků nebo nil.
	Je-li to seznam, vrátí součet hodnoty všech nalezených peněz (nepeněžní dávky ignoruje).
	Je-li to dávka peněz, vrátí jejich hodnotu (nezáporné celé číslo).
	Jinak vrací nil.
]]
function ch_core.precist_hotovost(stacks)
	if stacks == nil then
		return nil
	elseif type(stacks) == "table" then
		local result = 0
		for _, stack in ipairs(stacks) do
			local v = penize[stack:get_name()]
			if v ~= nil then
				result = result + v * stack:get_count()
			end
		end
		return result
	else
		local stack = stacks
		local v = penize[stack:get_name()]
		if v ~= nil then
			return v * stack:get_count()
		end
	end
end

-- current_count, count_to_remove
-- vrací: count_to_remove_now, hundreds_to_remove
-- hodnota count_to_remove_now může být i záporné číslo v rozsahu -100 až -1,
-- v takovém případě značí absolutní hodnota počet mincí, které je nutno přidat
local function remove100(current_count, count_to_remove)
	if count_to_remove <= current_count then
		return count_to_remove, 0
	end
	local count_to_remove_ones = count_to_remove % 100
	local count_to_remove_hundreds = (count_to_remove - count_to_remove_ones) / 100
	local new_count = current_count - count_to_remove_ones
	local new_count_hundreds = math.floor(new_count / 100)
	return count_to_remove_ones + 100 * new_count_hundreds, count_to_remove_hundreds - new_count_hundreds
end

--[[
	Pokusí se z uvedených počtů mincí odebrat mince tak,
	aby byla odebrána přesně zadaná hodnota. Vrátí nil,
	pokud je hodnota větší než součet hodnoty všech dostupných mincí.
	- items: table {["ch_core:kcs_h"] = (int >= 0) or nil, ...}
	- amount: int >= 0
	- vrací: {ch_core_kcs_1h = int, ...} or nil
		vrácený údaj značí, kolik mincí je potřeba odebrat z inventáře;
		může být záporný, v takovém případě uvádí, kolik mincí je
		potřeba do inventáře přidat
]]
function ch_core.rozmenit(items, amount)
	local current_h = items["ch_core:kcs_h"] or 0
	local current_kcs = items["ch_core:kcs_kcs"] or 0
	local current_zcs = items["ch_core:kcs_zcs"] or 0
	if current_h < 0 or current_kcs < 0 or current_zcs < 0 then
		error("Chybné zadání rozměňování! "..dump2({items = items, amount = amount}))
	end
	local h_to_remove, kcs_to_remove, zcs_to_remove
	h_to_remove, kcs_to_remove = remove100(current_h, amount)
	kcs_to_remove, zcs_to_remove = remove100(current_kcs, kcs_to_remove)
	if zcs_to_remove <= current_zcs then
		-- verify the result:
		if (h_to_remove + 100 * kcs_to_remove + 10000 * zcs_to_remove) ~= amount or h_to_remove > current_h or kcs_to_remove > current_kcs then
			error("Internal error in ch_core.rozmenit(): "..dump2({current_h = current_h, current_kcs = current_kcs, current_zcs = current_zcs, h_to_remove = h_to_remove, kcs_to_remove = kcs_to_remove, zcs_to_remove = zcs_to_remove, amount = amount, items = items, value_to_remove = h_to_remove + 100 * kcs_to_remove + 10000 * zcs_to_remove}))
		end
		return {
			["ch_core:kcs_h"] = h_to_remove,
			["ch_core:kcs_kcs"] = kcs_to_remove,
			["ch_core:kcs_zcs"] = zcs_to_remove,
		}
	else
		return nil
	end
end

--[[
	Všechny stacky s penězi v tabulce vyprázdní a vrátí jejich původní
	celkovou hodnotu.
	- stacks: table {ItemStack...}
	- limit: int >= 0 or nil
	returns: int >= 0 or nil
]]
function ch_core.vzit_vsechnu_hotovost(stacks)
	local castka = 0
	for _, stack in ipairs(stacks) do
		local stack_count = stack:get_count()
		if stack_count > 0 then
			local value_per_item = penize[stack:get_name()]
			if value_per_item ~= nil then
				castka = castka + value_per_item * stack_count
				stack:clear()
			end
		end
	end
	return castka
end

--[[
	Odečte ze stacků v tabulce peníze maximálně do zadaného limitu
	a vrátí celkovou odečtenou částku, nebo nil, pokud se nepodaří
	vrátit drobné.
	- stacks: table {ItemStack...}
	- limit: int >= 0 or nil
	- strict: bool or nil (je-li true, vrátí nil, pokud nemůže odečíst přesně
		částku „limit“)
	returns: int >= 0 or nil
]]
function ch_core.vzit_hotovost(stacks, limit, strict)
	-- Odečte ze stacků v tabulce peníze a vrátí celkovou částku.
	if limit == nil then
		return ch_core.vzit_vsechnu_hotovost(stacks)
	end
	limit = tonumber(limit)
	if limit == nil or limit < 0 or math.floor(limit) ~= limit then
		error("ch_core.vzit_hotovost(): limit must be a non-negative integer!")
	end
	local items = {
		[""] = {count = 0, indices = {}},
		["ch_core:kcs_h"] = {count = 0, indices = {}},
		["ch_core:kcs_kcs"] = {count = 0, indices = {}},
		["ch_core:kcs_zcs"] = {count = 0, indices = {}},
	}
	for i, stack in ipairs(stacks) do
		local name = stack:get_name()
		local info = items[name]
		if info ~= nil then
			info.count = info.count + stack:get_count()
			table.insert(info.indices, i)
		end
	end
	local total_value = items["ch_core:kcs_h"].count +
		items["ch_core:kcs_kcs"].count * penize["ch_core:kcs_kcs"] +
		items["ch_core:kcs_zcs"].count * penize["ch_core:kcs_zcs"]

	if total_value <= limit then
		if strict and total_value ~= limit then
			return nil
		end

		for name, info in pairs(items) do
			if name ~= "" then
				for _, i in ipairs(info.indices) do
					stacks[i]:clear()
				end
			end
		end
		return total_value
	end

	local new_stacks = {} -- {i = int, stack = ItemStack or false}
	local next_empty_index = 1
	local rinfo = ch_core.rozmenit({
		["ch_core:kcs_h"] = items["ch_core:kcs_h"].count,
		["ch_core:kcs_kcs"] = items["ch_core:kcs_kcs"].count,
		["ch_core:kcs_zcs"] = items["ch_core:kcs_zcs"].count,
	}, limit)
	for name, info in pairs(items) do
		if name ~= "" then
			local count_to_remove = rinfo[name]
			if count_to_remove < 0 then
				local stack_to_add = ItemStack(name.." "..(-count_to_remove))
				-- try to add to the existing stacks
				local j = 1
				while not stack_to_add:is_empty() and j <= #info.indices do
					local i = info.indices[j]
					local new_stack = ItemStack(stacks[i])
					stack_to_add = new_stack:add_item(stack_to_add)
					table.insert(new_stacks, {i = i, stack = new_stack})
				end
				if not stack_to_add:is_empty() then
					-- need an empty stack...
					local empty_i = items[""].indices[next_empty_index]
					if empty_i == nil then
						return nil -- failure
					end
					table.insert(new_stacks, {i = empty_i, stack = stack_to_add})
					next_empty_index = next_empty_index + 1
				end
			else
				while count_to_remove > 0 do
					for _, i in ipairs(info.indices) do
						local current_stack = stacks[i]
						local stack_count = current_stack:get_count()
						if stack_count < count_to_remove then
							count_to_remove = count_to_remove - stack_count
							table.insert(new_stacks, {i = i, stack = ItemStack()})
						else
							local new_stack = ItemStack(current_stack)
							new_stack:take_item(count_to_remove)
							table.insert(new_stacks, {i = i, stack = new_stack})
							count_to_remove = 0
							break
						end
					end
				end
				assert(count_to_remove == 0)
			end
		end
	end

	-- commit the transaction
	for _, pair in ipairs(new_stacks) do
		stacks[pair.i]:replace(pair.stack)
	end
	return limit
end

function ch_core.register_payment_method(name, pay_from_player, pay_to_player)
	if payment_methods[name] ~= nil then
		error("payment method "..name.." is already registered!")
	end
	if type(pay_from_player) ~= "function" or type(pay_to_player) ~= "function" then
		error("ch_core.register_payment_method(): invalid type of arguments!")
	end
	payment_methods[name] = {pay_from = pay_from_player, pay_to = pay_to_player}
end

local function build_methods_to_try(options, allow_bank, prefer_cash)
	if options[1] ~= nil then
		return options
	end
	local methods_to_consider = {}
	if options.bank ~= false and allow_bank then
		methods_to_consider.bank = true
	end
	if options.smartshop ~= false and options.shop ~= nil then
		methods_to_consider.smartshop = true
	elseif options.cash ~= false then
		methods_to_consider.cash = true
	end

	local methods_to_try = {}
	if methods_to_consider.bank and not prefer_cash then
		table.insert(methods_to_try, "bank")
		methods_to_consider.bank = nil
	end
	if methods_to_consider.smartshop then
		table.insert(methods_to_try, "smartshop")
		methods_to_consider.smartshop = nil
	end
	if methods_to_consider.cash then
		table.insert(methods_to_try, "cash")
		methods_to_consider.cash = nil
	end
	if methods_to_consider.bank then
		table.insert(methods_to_try, "bank")
		methods_to_consider.bank = nil
	end
	for method, _ in pairs(methods_to_consider) do
		table.insert(methods_to_try, method)
	end
	return methods_to_try
end

local function pay_from_or_to(dir, player_name, amount, options)
	if options == nil then options = {} end
	local rezim = (ch_data.offline_charinfo[player_name] or {}).rezim_plateb or 0
	local methods_to_try
	if dir == "from" then
		methods_to_try = build_methods_to_try(options, rezim ~= 4, rezim >= 2)
	else
		methods_to_try = build_methods_to_try(options, true, rezim ~= 0 and rezim ~= 2)
	end
	local silent = options.simulation and options.silent
	local errors = {}
	local i = 1
	local method = methods_to_try[i]
	while method ~= nil do
		local pm = payment_methods[method]
		if pm ~= nil then
			local success, error_message
			if dir == "from" then
				success, error_message = pm.pay_from(player_name, amount, options)
			else
				success, error_message = pm.pay_to(player_name, amount, options)
			end
			if success then
				if not silent then
					minetest.log("action", "pay_"..dir.."("..player_name..", "..amount..") succeeded with method "..method)
				end
				return true, {method = method}
			end
			if error_message ~= nil then
				table.insert(errors, error_message)
			end
		end
		i = i + 1
		method = methods_to_try[i]
	end
	if #errors == 0 then
		return false, "Nebyla nalezena žádná použitelná platební metoda."
	end
	if options.assert == true then
		error("Payment assertion failed: pay_"..dir.."("..player_name..", "..amount.."): "..dump2({dir = dir, options = options, errors = errors, methods_to_try = methods_to_try}))
	end
	if not silent then
		minetest.log("action", "pay_"..dir.."("..player_name..", "..amount..") failed! "..#methods_to_try.." methods has been tried. Errors: "..dump2(errors))
	end
	return false, {errors = errors}
end

function ch_core.pay_from(player_name, amount, options)
	return pay_from_or_to("from", player_name, amount, options)
end

function ch_core.pay_to(player_name, amount, options)
	return pay_from_or_to("to", player_name, amount, options)
end

--[[
options:

	[method] : bool or nil, // je-li false, daná metoda nemá dovoleno běžet
		a musí vrátit false bez chybového hlášení
	assert : bool or nil, // je-li true a platba nebude uskutečněna
		žádnou platební metodou, shodí server. Tato volba je obsluhována
		přímo ch_core a platební metody by s ní neměly interferovat.
	silent : bool or nil, // je-li true a je-li i simulation == true,
		mělo by potlačit obvyklé logování, aby transakce zanechala co nejméně stop
	simulation : bool or nil, // je-li true, jen vyzkouší, zda může uspět;
		ve skutečnosti platbu neprovede a nikam nezaznamená

	player_inv : InvRef or nil, // platí pro metodu "cash"; specifikuje
		inventář, se kterým se má zacházet jako s hráčovým/iným
	listname : string or nil, // platí pro metodu "cash"; specifikuje
		listname v inventáři; není-li zadáno, použije se "main"

	label : string or nil, // platí pro metodu "bank";
		udává poznámku, která se má uložit do záznamu o platebním převodu

	shop : shop_class or nil, // platí pro metodu "smartshop";
		odkazuje na objekt obchodního terminálu, který se má použít
		namísto hráčova/ina inventáře

	Další platební metody mohou mít svoje vlastní parametry.
]]


local function cash_pay_from_player(player_name, amount, options)
	if options.cash == false then return false end
	local player_inv = options.player_inv
	if player_inv == nil then
		local player = minetest.get_player_by_name(player_name)
		if player == nil then
			return false, "Postava není ve hře"
		end
		player_inv = player:get_inventory()
	end
	local silent = options.simulation and options.silent
	local listname = options.listname or "main"
	local inv_list = player_inv:get_list(listname)
	local hotovost_v_inv_pred = ch_core.vzit_hotovost(player_inv:get_list(listname)) or 0
	local ziskano = ch_core.vzit_hotovost(inv_list, amount)
	if ziskano ~= amount then
		if not silent then
			minetest.log("action", player_name.." failed to pay "..amount.." in cash (got "..(ziskano or "nil")..")")
		end
		return false, "V inventáři není dost peněz v hotovosti."
	end
	if not options.simulation then
		player_inv:set_list(listname, inv_list)
		minetest.log("action", player_name.." payed "..amount.." in cash")
		local hotovost_v_inv_po = ch_core.vzit_hotovost(inv_list) or 0
		if hotovost_v_inv_po ~= hotovost_v_inv_pred - amount then
			error("ERROR in cash_pay_from_player: pred="..hotovost_v_inv_pred..", po="..hotovost_v_inv_po..", amount="..amount)
		end
	end
	return true
end

local function cash_pay_to_player(player_name, amount, options)
	if options.cash == false then return false end
	local player_inv = options.player_inv
	if player_inv == nil then
		local player = minetest.get_player_by_name(player_name)
		if player == nil then
			return false, "Postava není ve hře"
		end
		player_inv = player:get_inventory()
	end
	local silent = options.simulation and options.silent
	local listname = options.listname or "main"
	local inv_backup = player_inv:get_list(listname)
	local hotovost_v_inv_pred = ch_core.vzit_hotovost(player_inv:get_list(listname)) or 0
	local hotovost = ch_core.hotovost(amount)
	for _, stack in ipairs(hotovost) do
		local remains = player_inv:add_item(listname, stack)
		if not remains:is_empty() then
			-- failure
			player_inv:set_list(listname, inv_backup)
			return false, "Plný inventář, platba v hotovosti se do něj nevejde."
		end
	end
	local hotovost_v_inv_po = ch_core.vzit_hotovost(player_inv:get_list(listname)) or 0
	if hotovost_v_inv_po ~= hotovost_v_inv_pred + amount then
		error("ERROR in cash_pay_to_player: pred="..hotovost_v_inv_pred..", po="..hotovost_v_inv_po..", amount="..amount)
	end
	if options.simulation then
		player_inv:set_list(listname, inv_backup)
		return true
	end
	if not silent then
		minetest.log("action", "to "..player_name.." "..amount.." has been payed in cash")
	end
	return true
end

ch_core.register_payment_method("cash", cash_pay_from_player, cash_pay_to_player)

ch_core.close_submod("penize")
