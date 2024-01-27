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
					assert(count_to_take >= 1 and count_to_take < stack_count)
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





ch_core.close_submod("penize")

--[[
	Daná postava zaplatí požadovanou částku v hotovosti.
	Vrací true v případě úspěchu.
	V případě neúspěchu vrátí false a nic nebude zaplaceno.
	- player_name: string // jméno postavy
	- castka : int >= 0 // částka k zaplacení
	- options : {
		cash = bool or nil,
		player_inv = InvRef or nil,
		simulation = bool or nil,
	} or nil
]]
function ch_core.zaplatit_od_postavy(player_name, castka, options)
	local player_inv, simulation
	if options ~= nil then
		if options.cash == false then
			return nil -- není povoleno
		end
		player_inv = options.player_inv
		simulation = options.simulation
	end
	if player_inv == nil then
		local player = minetest.get_player_by_name(player_name)
		if player == nil then
			return nil -- postava není ve hře
		end
		player_inv = player:get_inventory()
	end
	local inv_list = player_inv:get_list("main")
	local hotovost_v_inv_pred = ch_core.vzit_hotovost(player_inv:get_list("main")) or 0
	local ziskano = ch_core.vzit_hotovost(inv_list, castka)
	if ziskano ~= castka then
		minetest.log("action", player_name.." failed to pay "..castka.." in cash (got "..(ziskano or "nil")..")")
		print("DEBUG: "..dump2({ziskano = ziskano, castka = castka, options = options}))
		return false
	end
	if not simulation then
		player_inv:set_list("main", inv_list)
		minetest.log("action", player_name.." payed "..castka.." in cash")
		local hotovost_v_inv_po = ch_core.vzit_hotovost(inv_list) or 0
		if hotovost_v_inv_po ~= hotovost_v_inv_pred - castka then
			error("ERROR in zaplatit_od_postavy: pred="..hotovost_v_inv_pred..", po="..hotovost_v_inv_po..", castka="..castka)
		end
	end
	return true
end

--[[
	Zaplatí dané postavě v hotovosti uvedenou částku.
	Vrací true v případě úspěchu.
	V případě neúspěchu vrátí false a nic nebude zaplaceno.
	- player_name: string // jméno postavy
	- castka : int >= 0 // částka k zaplacení
	- options : {
		cash = bool or nil,
		player_inv = InvRef or nil,
		simulation = bool or nil,
	} or nil
]]
function ch_core.zaplatit_postave(player_name, castka, options)
	local player_inv, simulation
	if options ~= nil then
		if options.cash == false then
			return nil -- není povoleno
		end
		player_inv = options.player_inv
		simulation = options.simulation
	end
	if player_inv == nil then
		local player = minetest.get_player_by_name(player_name)
		if player == nil then
			return nil -- postava není ve hře
		end
		player_inv = player:get_inventory()
	end
	local inv_backup = player_inv:get_list("main")
	local hotovost_v_inv_pred = ch_core.vzit_hotovost(player_inv:get_list("main")) or 0
	local hotovost = ch_core.hotovost(castka)
	for _, stack in ipairs(hotovost) do
		local remains = player_inv:add_item("main", stack)
		if not remains:is_empty() then
			-- failure
			player_inv:set_list("main", inv_backup)
			return false
		end
	end
	local hotovost_v_inv_po = ch_core.vzit_hotovost(player_inv:get_list("main")) or 0
	if hotovost_v_inv_po ~= hotovost_v_inv_pred + castka then
		error("ERROR in zaplatit_postave: pred="..hotovost_v_inv_pred..", po="..hotovost_v_inv_po..", castka="..castka)
	end
	if simulation then
		player_inv:set_list("main", inv_backup)
		return true
	end
	minetest.log("action", "to "..player_name.." "..castka.." has been payed in cash")
	return true
end
