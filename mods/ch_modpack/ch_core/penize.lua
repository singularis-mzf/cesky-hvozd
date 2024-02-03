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
	Případné desetinné číslo se zaokrouhlí dolů. Pro nulu vrací prázdnou tabulku.
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
	local offline_charinfo = ch_core.offline_charinfo[player_name]
	if offline_charinfo == nil then
		return {}
	end
	local rezim = offline_charinfo.rezim_plateb
	return {cash = true, bank = true, prefer_cash = rezim ~= 0 and rezim ~= 2}
end

function ch_core.nastaveni_odchozich_plateb(player_name)
	local offline_charinfo = ch_core.offline_charinfo[player_name]
	if offline_charinfo == nil then
		return {}
	end
	local rezim = offline_charinfo.rezim_plateb
	return {cash = true, bank = rezim ~= 4, prefer_cash = rezim >= 2}
end
]]
--[[
	Parametr musí být ItemStack nebo nil. Je-li to dávka peněz,
	vrátí jejich hodnotu (nezáporné celé číslo). Jinak vrací nil.
]]
function ch_core.precist_hotovost(stack)
	if stack ~= nil and not stack:is_empty() then
		local v = penize[stack:get_name()]
		if v ~= nil then
			return v * stack:get_count()
		end
	end
end
local precist_hotovost = ch_core.precist_hotovost

--[[
	Odečte ze stacků v tabulce peníze maximálně do zadaného limitu
	a vrátí celkovou odečtenou částku, nebo nil, pokud se nepodaří
	vrátit drobné.
	- stacks: table {ItemStack...}
	- limit: int >= 0 or nil
	returns: int >= 0 or nil
]]
function ch_core.vzit_hotovost(stacks, limit)
	-- Odečte ze stacků v tabulce peníze a vrátí celkovou částku.
	if limit == nil then
		limit = 1000000000000000 -- 10 bilionů Kčs
	else
		limit = tonumber(limit)
		if limit == nil or limit < 0 or math.floor(limit) ~= limit then
			error("ch_core.vzit_hotovost(): limit must be a non-negative integer!")
		end
	end
	local castka, i, last_empty_i, stack_to_return
	castka = 0
	i = 1
	while i <= #stacks do
		local stack = stacks[i]
		if stack:is_empty() then
			last_empty_i = i
		else
			local value_per_item = penize[stack:get_name()]
			if value_per_item ~= nil then
				local stack_count = stack:get_count()
				local stack_value = value_per_item * stack_count
				assert(stack_value >= 1)
				if stack_value <= limit then
					-- take full stack
					castka = castka + stack_value
					limit = limit - stack_value
					stack:clear()
					last_empty_i = i
				else
					-- take a part of the stack
					local count_to_take = math.ceil(limit / value_per_item)
					assert(count_to_take >= 1 and count_to_take <= stack_count)
					local value_to_take = count_to_take * value_per_item
					stack:set_count(stack_count - count_to_take)
					local h_to_return = value_to_take - limit
					if h_to_return > 0 then
						local kcs_to_return, zcs_to_return = h_to_return / 100.0, h_to_return / 10000.0
						if zcs_to_return == math.floor(zcs_to_return) then
							stack_to_return = ItemStack("ch_core:kcs_zcs "..zcs_to_return)
						elseif kcs_to_return == math.floor(kcs_to_return) then
							stack_to_return = ItemStack("ch_core:kcs_kcs "..kcs_to_return)
						else
							stack_to_return = ItemStack("ch_core:kcs_h "..h_to_return)
						end
					end
					castka = castka + limit
					limit = 0
					break
				end
			end
		end
		i = i + 1
	end
	if stack_to_return ~= nil then
		if last_empty_i == nil then
			i = i + 1
			while i <= #stacks do
				if stacks[i]:is_empty() then
					last_empty_i = i
					break
				end
				i = i + 1
			end
		end
		if last_empty_i == nil then
			return nil
		end
		stacks[last_empty_i] = stack_to_return
	end
	return castka
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
	local rezim = (ch_core.offline_charinfo[player_name] or {}).rezim_plateb or 0
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
			print("DEBUG: "..dump2({ziskano = ziskano, amount = amount, options = options}))
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
