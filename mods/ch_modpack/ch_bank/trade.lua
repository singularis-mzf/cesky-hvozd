local tinv, utils = ...

-- CONFIGURATION
local distance_limit = 50
local title_is_offering = "nabízí obchod"
local title_is_trading = "obchoduje"

-- CONSTANT DATA
local player_inventory_lists = {
	"main", "bag1contents", "bag2contents", "bag3contents", "bag4contents",
	"bag5contents", "bag6contents", "bag7contents", "bag8contents", "craft"
}

-- ALIASES AND CONSTANT CONDITIONS
local has_currency = minetest.get_modpath("currency")
local has_emote = minetest.get_modpath("emote")
local STATE_OPEN, STATE_CONFIRMED = utils.STATE_OPEN, utils.STATE_CONFIRMED

-- VAIRABLE DATA
local player_trade_states = {}
local next_trade_id = 1

--
-- UTILITY FUNCTIONS
-------------------------------------------------------------------------------
function utils.get_player_trade_state(player_name)
	if player_name == nil then return nil, "none" end
	local result = player_trade_states[player_name]
	if result == nil then return nil, "none" end
	return result, result.type
end

function utils.give_items_to_player(player, player_inv, stacks)
	if stacks == nil then return 0 end
	local pil_i = 1
	local listname = player_inventory_lists[pil_i]
	local count = 0
	local player_pos
	for _, stack in ipairs(stacks) do
		local remains = stack
		while not remains:is_empty() do
			if listname ~= nil then
				remains = player_inv:add_item(listname, stack)
				if remains:is_empty() then
					count = count + 1
					break
				end
				repeat
					pil_i = pil_i + 1
					listname = player_inventory_lists[pil_i]
				until (listname == nil or player_inv:get_size(listname) > 0)
			else
				-- all lists are full
				if player_pos == nil then
					player_pos = player:get_pos()
				end
				minetest.add_item(player_pos, remains)
				count = count + 1
				break
			end
		end
	end
	return count
end
ch_bank.give_items_to_player = utils.give_items_to_player

function utils.give_money_to_player(player_name, amount)
	if amount <= 0 then return end
	local success, _message = ch_bank.platba{
		from_player = "",
		to_player = player_name,
		amount = amount,
		label = "dočasný vklad/výběr",
		group = "temp",
	}
	if success then
		return
	end
	local player = minetest.get_player_by_name(player_name)
	if not player then
		return
	end
	local inv = player:get_inventory()
	local hotovost = ch_core.hotovost(amount)
	utils.give_items_to_player(player, inv, hotovost)
end

function utils.mohou_obchodovat(from_player_name, to_player_name)
	local from_player = minetest.get_player_by_name(from_player_name)
	local to_player = minetest.get_player_by_name(to_player_name)
	if from_player == nil or to_player == nil then
		return false, "not_online"
	end
	if from_player_name == to_player_name then
		return false, "same_player"
	end
	local from_player_role = ch_core.get_player_role(from_player_name)
	local to_player_role = ch_core.get_player_role(to_player_name)
	if from_player_role == "admin" then
		return true
	end
	local from_trest = ch_core.je_ve_vykonu_trestu(from_player_name)
	local to_trest = ch_core.je_ve_vykonu_trestu(to_player_name)
	if (from_trest and not to_trest) or (not from_trest and to_trest) then
		return false, "prison"
	end
	if from_player_role == "new" then
		return false, "new_1"
	end
	if to_player_role == "new" then
		return false, "new_2"
	end
	if not utils.umoznuje_vzdalenost_obchodovani(from_player:get_pos(), to_player:get_pos()) then
		return false, "distance"
	end
	local empty_list = {}
	local from_player_info = ch_core.online_charinfo[from_player_name] or empty_list
	if (from_player_info.chat_ignore_list or empty_list)[to_player_name] then
		return false, "ignore_1"
	end
	local to_player_info = ch_core.online_charinfo[to_player_name] or empty_list
	if (to_player_info.chat_ignore_list or empty_list)[from_player_name] then
		return false, "ignore_2"
	end
	local from_player_control = from_player:get_player_control()
	local to_player_control = to_player:get_player_control()
	if from_player_control.zoom then
		return false, "zoom_1"
	end
	if to_player_control.zoom then
		return false, "zoom_2"
	end
	if ch_core.je_pryc(to_player_name) then
		return false, "pryc_2"
	end
	return true
end

function utils.set_player_trade_state(player_name, new_state)
	player_trade_states[player_name] = new_state
	return new_state
end

function utils.set_is_offering_title(player_name, enabled)
	if title_is_offering then
		ch_core.set_temporary_titul(player_name, title_is_offering, enabled)
	end
end

function utils.set_is_trading_title(player_name_1, player_name_2, enabled)
	if title_is_trading ~= nil then
		ch_core.set_temporary_titul(player_name_1, title_is_trading, enabled)
		ch_core.set_temporary_titul(player_name_2, title_is_trading, enabled)
	end
end

function utils.umoznuje_vzdalenost_obchodovani(pos1, pos2)
	return vector.distance(pos1, pos2) < distance_limit
end
--
-- MAIN FUNCTIONS
-------------------------------------------------------------------------------
local function cancel_offer(pn_offer, pn_offer_target)
	local ts_offer = player_trade_states[pn_offer]
	local ts_offer_target = player_trade_states[pn_offer_target]
	assert(ts_offer.type == "offer")
	assert(ts_offer_target.type == "offer_target")
	utils.set_is_offering_title(pn_offer, false)
	ch_core.cancel_ch_timer(assert(ch_core.online_charinfo[pn_offer_target]), "trade")
	player_trade_states[pn_offer] = nil
	player_trade_states[pn_offer_target] = nil
	ch_core.systemovy_kanal(pn_offer, ch_core.prihlasovaci_na_zobrazovaci(pn_offer_target).." odmítl/a nabídku obchodování.")
	ch_core.systemovy_kanal(pn_offer_target, "Nabídka obchodování od "..ch_core.prihlasovaci_na_zobrazovaci(pn_offer).." odmítnuta.")
end

local function cancel_trade(player_name, trade_state)
	local player = assert(minetest.get_player_by_name(player_name))
	local player_name_right = assert(trade_state.with_player)
	local player_right = assert(minetest.get_player_by_name(player_name_right))
	-- 1. close formspecs (if they're openned)
	ch_core.close_formspec(player_name, "ch_bank:trade")
	ch_core.close_formspec(player_name_right, "ch_bank:trade")
	-- 2. return items
	local items_ltr = tinv.read_trade_inventory(player)
	local items_rtl = tinv.read_trade_inventory(player_right)
	local rezim_left = (ch_core.offline_charinfo[player_name] or {}).rezim_plateb or 0
	local rezim_right = (ch_core.offline_charinfo[player_name_right] or {}).rezim_plateb or 0
	local money_ltr, money_rtl
	if rezim_left == 0 or rezim_left == 2 then
		money_ltr = ch_core.vzit_hotovost(items_ltr)
	end
	if rezim_right == 0 or rezim_right == 2 then
		money_rtl = ch_core.vzit_hotovost(items_rtl)
	end
	utils.give_items_to_player(player:get_pos(), player:get_inventory(), items_ltr)
	utils.give_items_to_player(player_right:get_pos(), player_right:get_inventory(), items_rtl)
	--  3. return money
	if money_ltr ~= nil and money_ltr > 0 then
		utils.give_money_to_player(player_name, money_ltr)
	end
	if money_rtl ~= nil and money_rtl > 0 then
		utils.give_money_to_player(player_name_right, money_rtl)
	end
	-- 4. discard the trade inventory
	tinv.close_trade_inventory(player)
	tinv.close_trade_inventory(player_right)
	-- 5. remove titles
	utils.set_is_trading_title(player_name, player_name_right, false)
	-- 6. remove states
	utils.set_player_trade_state(player_name, nil)
	utils.set_player_trade_state(player_name_right, nil)
	-- 7. announce the message
	ch_core.systemovy_kanal(player_name, "Obchod zrušen.")
	ch_core.systemovy_kanal(player_name_right, "Obchod zrušen.")
end

function ch_bank.zrusit_obchod(player_name, is_leaving)
	local trade_state = player_trade_states[player_name]
	if trade_state == nil then
		return false
	end
	if trade_state.type == "offer" then
		cancel_offer(player_name, trade_state.to_player)
		return true
	elseif trade_state.type == "offer_target" then
		cancel_offer(trade_state.from_player, player_name)
		return true
	elseif trade_state.type ~= "trade" then
		minetest.log("error", "ch_bank.zrusit_obchod("..player_name.."): unknown trade state type '"..trade_state.type.."'!")
		return true
	end
	cancel_trade(player_name, trade_state)
	return true
end

function utils.nabidnout_obchod(from_player, to_player)
	local from_player_name = assert(from_player:get_player_name())
	local to_player_name = assert(to_player:get_player_name())
	local _trade_state, tstype = utils.get_player_trade_state(from_player_name)
	if tstype ~= "none" then
		ch_bank.zrusit_obchod(from_player_name)
	end
	_trade_state, tstype = utils.get_player_trade_state(to_player_name)
	if tstype ~= "none" then
		ch_bank.zrusit_obchod(to_player_name)
	end
	local trade_id = next_trade_id
	next_trade_id = next_trade_id + 1
	local from_trade_state = {
		type = "offer",
		trade_id = trade_id,
		to_player = to_player_name,
	}
	local to_trade_state = {
		type = "offer_target",
		trade_id = trade_id,
		from_player = from_player_name,
	}
	local to_data = assert(ch_core.online_charinfo[to_player_name])
	utils.set_player_trade_state(from_player_name, from_trade_state)
	utils.set_player_trade_state(to_player_name, to_trade_state)
	utils.set_is_offering_title(from_player_name, true)
	ch_core.systemovy_kanal(from_player_name, "Nabízíte obchod postavě "..ch_core.prihlasovaci_na_zobrazovaci(to_player_name).."...", {alert = true})
	ch_core.systemovy_kanal(to_player_name, "Postava "..ch_core.prihlasovaci_na_zobrazovaci(from_player_name).." vám nabízí obchod. Máte 20 sekund na reakci.", {alert = true})
	local timer_def = {
		label = "obchod",
		func = function()
			local ts = utils.get_player_trade_state(to_player_name)
			if ts ~= nil and ts.type == "offer_target" and ts.trade_id == trade_id then
				-- timed out
				ch_bank.zrusit_obchod(to_player_name)
			end
		end,
	}
	if has_currency then
		timer_def.hudbar_icon = "barter_top.png"
	end
	ch_core.start_ch_timer(to_data, "trade", 20, timer_def)
end

function utils.zacit_obchod(from_player, to_player)
	local from_player_name = assert(from_player:get_player_name())
	local to_player_name = assert(to_player:get_player_name())
	local from_player_data = ch_core.online_charinfo[from_player_name] or {}
	local to_player_data = ch_core.online_charinfo[to_player_name] or {}
	local trade_state, tstype = utils.get_player_trade_state(from_player_name)
	if
		(tstype == "offer" and trade_state.to_player ~= to_player_name) or
		(tstype == "offer_target" and trade_state.from_player ~= to_player_name) or
		(tstype == "trade")
	then
		ch_bank.zrusit_obchod(from_player_name)
	end
	trade_state, tstype = utils.get_player_trade_state(to_player_name)
	if
		(tstype == "offer" and trade_state.to_player ~= from_player_name) or
		(tstype == "offer_target" and trade_state.from_player ~= from_player_name) or
		(tstype == "trade")
	then
		ch_bank.zrusit_obchod(from_player_name)
	end
	local from_state = {
		player_name = from_player_name,
		player_display_name = ch_core.prihlasovaci_na_zobrazovaci(from_player_name),
		player_role = assert(ch_core.get_player_role(from_player_name)),
		state = STATE_OPEN,
	}
	local to_state = {
		player_name = to_player_name,
		player_display_name = ch_core.prihlasovaci_na_zobrazovaci(to_player_name),
		player_role = assert(ch_core.get_player_role(to_player_name)),
		state = STATE_OPEN,
	}
	local from_trade_state = {
		type = "trade",
		with_player = to_player_name,
		privmsg_index = 1,
		left = from_state,
		right = to_state,
	}
	local to_trade_state = {
		type = "trade",
		with_player = from_player_name,
		privmsg_index = 1,
		left = to_state,
		right = from_state,
	}

	utils.set_player_trade_state(from_player_name, from_trade_state)
	utils.set_player_trade_state(to_player_name, to_trade_state)

	tinv.open_trade_inventory(from_player)
	tinv.open_trade_inventory(to_player)

	ch_core.cancel_ch_timer(from_player_data, "trade")
	ch_core.cancel_ch_timer(to_player_data, "trade")
	utils.set_is_offering_title(from_player_name, false)
	utils.set_is_offering_title(to_player_name, false)
	utils.set_is_trading_title(from_player_name, to_player_name, true)

	local from_formspec = utils.get_formspec(from_trade_state)
	local to_formspec = utils.get_formspec(to_trade_state)
	ch_core.show_formspec(from_player_name, "ch_bank:trade", from_formspec, utils.formspec_callback, from_trade_state, {})
	ch_core.show_formspec(to_player_name, "ch_bank:trade", to_formspec, utils.formspec_callback, to_trade_state, {})

	-- Stop animations for trading players:
	if has_emote then
		minetest.after(0.75, function()
			for _, name in ipairs({from_player_name, to_player_name}) do
				local p = minetest.get_player_by_name(name)
				if p ~= nil then
					emote.stop(p)
				end
			end
		end)
	end

	return true
end

function utils.uzavrit_obchod(player, player_right)
	local player_name = player:get_player_name()
	local player_name_right = player_right:get_player_name()
	assert(player_name ~= player_name_right)
	local trade_state, tstype = utils.get_player_trade_state(player_name)
	if tstype ~= "trade" or trade_state.with_player ~= player_name_right or trade_state.left.state ~= STATE_CONFIRMED or trade_state.right.state ~= STATE_CONFIRMED then
		return false
	end
	local trade_state_right = utils.get_player_trade_state(player_name_right)
	assert(trade_state_right.type == "trade")
	assert(trade_state_right.with_player == player_name)

	local inv_left = player:get_inventory()
	local inv_right = player_right:get_inventory()

	tinv.open_simulation(player_name, inv_left, "main")
	tinv.open_simulation(player_name_right, inv_right, "main")

	local items_ltr = tinv.read_trade_inventory(player)
	local items_rtl = tinv.read_trade_inventory(player_right)
	local rezim_left = (ch_core.offline_charinfo[player_name] or {}).rezim_plateb or 0
	local rezim_right = (ch_core.offline_charinfo[player_name_right] or {}).rezim_plateb or 0
	local money_ltr, money_rtl
	if rezim_left == 0 or rezim_left == 2 then
		money_ltr = ch_core.vzit_hotovost(items_ltr)
	end
	if rezim_right == 0 or rezim_right == 2 then
		money_rtl = ch_core.vzit_hotovost(items_rtl)
	end

	-- 1. Give back money
	if money_ltr ~= nil and money_ltr ~= 0 then
		utils.give_money_to_player(player_name, money_ltr)
	end
	if money_rtl ~= nil and money_rtl ~= 0 then
		utils.give_money_to_player(player_name_right, money_rtl)
	end

	local errors = {}
	local success_items_rtl = tinv.add_items_to_simulation(player_name, items_rtl)
	if not success_items_rtl then
		table.insert(errors, "V hlavním inventáři postavy "..ch_core.prihlasovaci_na_zobrazovaci(player_name).." není dost místa na směněné položky!")
	end
	local success_items_ltr = tinv.add_items_to_simulation(player_name_right, items_ltr)
	if not success_items_ltr then
		table.insert(errors, "V hlavním inventáři postavy "..ch_core.prihlasovaci_na_zobrazovaci(player_name_right).." není dost místa na směněné položky!")
	end
	local success_bank = true
	if success_items_ltr and success_items_rtl then
		local message
		local money_diff = (money_ltr or 0) - (money_rtl or 0)
		if money_diff > 0 then
			success_bank, message = ch_bank.platba{
				from_player = player_name,
				to_player = player_name_right,
				amount = money_diff,
				label = "směna",
			}
		elseif money_diff < 0 then
			success_bank, message = ch_bank.platba{
				from_player = player_name_right,
				to_player = player_name,
				amount = -money_diff,
				label = "směna",
			}
		end
		if not success_bank then
			table.insert(errors, message or "Bankovní převod selhal!")
		end
	end

	local success = success_items_ltr and success_items_rtl and success_bank
	if success then
		-- 1. close formspecs
		ch_core.close_formspec(player_name, "ch_bank:trade")
		ch_core.close_formspec(player_name_right, "ch_bank:trade")
		-- 2. exchange items
		inv_left:set_list("main", tinv.close_simulation(player_name))
		inv_right:set_list("main", tinv.close_simulation(player_name_right))
		-- 3. close trade inventories
		tinv.close_trade_inventory(player)
		tinv.close_trade_inventory(player_right)
		-- 4. remove titles
		if title_is_trading ~= nil then
			ch_core.set_temporary_titul(player_name, title_is_trading, false)
			ch_core.set_temporary_titul(player_name_right, title_is_trading, false)
		end
		-- 5. remove states
		utils.set_player_trade_state(player_name, nil)
		utils.set_player_trade_state(player_name_right, nil)
		-- 6. announce the message
		ch_core.systemovy_kanal(player_name, "Směna proběhla v pořádku.")
		ch_core.systemovy_kanal(player_name_right, "Směna proběhla v pořádku.")
		return true
	else
		-- 1. close the simulation
		tinv.close_simulation(player_name)
		tinv.close_simulation(player_name_right)
		-- 2. announce errors
		local message = "Směna selhala z následujících důvodů:\n- "..table.concat(errors, "\n- ")
		ch_core.systemovy_kanal(player_name, message, {alert = true})
		ch_core.systemovy_kanal(player_name_right, message, {alert = true})
		return false
	end
end

local function on_rightclickplayer(player, clicker)
	if not minetest.is_player(player) or not minetest.is_player(clicker) then
		return
	end
	local clicker_name = clicker:get_player_name()
	local player_name = player:get_player_name()

	local can, reason = utils.mohou_obchodovat(clicker_name, player_name)
	if can then
		local trade_state, tstype = utils.get_player_trade_state(clicker_name)
		if trade_state ~= nil then
			if tstype == "trade" or tstype == "offer" then
				return -- tato postava právě obchoduje nebo nabízí obchod
			end
			if tstype == "offer_target" then
				if trade_state.from_player == player_name then
					-- potvrzení nabídky k obchodu
					utils.zacit_obchod(player, clicker)
					return
				end
				-- nutno nejprve zrušit nabídku
				ch_bank.zrusit_obchod(trade_state.from_player)
			end
		end
		utils.nabidnout_obchod(clicker, player)
		return
	end
	if reason == "new_1" then
		reason = "Nové postavy nemohou obchodovat!"
	elseif reason == "new_2" then
		reason = "S novými postavami nelze obchodovat!"
	elseif reason == "distance" then
		reason = "Nemůžete nabídnout obchod, protože jste příliš daleko."
	elseif reason == "ignore_1" then
		reason = "Nemůžete nabídnout obchod postavě, kterou ignorujete."
	elseif reason == "ignore_2" then
		reason = "Postavě, která vás ignoruje, nemůžete nabídnout obchod."
	elseif reason == "prison" then
		reason = "Nemůžete nabídnout obchod, protože jedna z postav je ve výkonu trestu."
	elseif reason == "same_player" then
		reason = "Nemůžete obchodovat sám/a se sebou."
	elseif reason == "zoom_1" then
		reason = "Když držíte klávesu Zoom, nemůžete nabízet obchod."
	elseif reason == "zoom_2" then
		reason = "Postavě právě nemůžete nabídnout obchod, protože drží klávesu Zoom. Zkuste to později."
	elseif reason == "pryc_2" then
		reason = "Postavě právě nemůžete nabídnout obchod, protože hráč/ka je pryč od klávesnice. Zkuste to později."
	else
		reason = "Této postavě teď nemůžete nabídnout obchod."
	end
	ch_core.systemovy_kanal(clicker_name, reason)
end

local function on_dieplayer(player, reason)
	ch_bank.zrusit_obchod(player:get_player_name())
end

local function on_leaveplayer(player, timed_out)
	ch_bank.zrusit_obchod(player:get_player_name())
end

local dtime_agg = 0

local function globalstep(dtime)
	local players
	dtime_agg = dtime_agg + dtime
	if dtime_agg < 0.5 then
		return
	end
	dtime_agg = dtime_agg - math.floor(dtime_agg * 2) / 2

	for player_name, trade_state in pairs(player_trade_states) do
		if players == nil then
			players = {}
			for _, player in ipairs(minetest.get_connected_players()) do
				players[player:get_player_name()] = player
			end
		end
		local player = players[player_name]
		if trade_state.type == "trade" and not utils.umoznuje_vzdalenost_obchodovani(player:get_pos(), players[trade_state.with_player]:get_pos()) then
			ch_bank.zrusit_obchod(player_name)
			return
		elseif (trade_state.type == "offer" or trade_state.type == "offer_target") and player:get_player_control().zoom then
			ch_bank.zrusit_obchod(player_name)
			return
		end
	end
end

minetest.register_on_rightclickplayer(on_rightclickplayer)
minetest.register_on_dieplayer(on_dieplayer)
minetest.register_on_leaveplayer(on_leaveplayer)
minetest.register_globalstep(globalstep)

minetest.register_on_punchplayer(function(...) minetest.log("warning", "on_punchplayer called with arguments: "..dump2({...})) return end)

--[[
Trade states:
a) player_name => {
		type = "offer",
		to_player = string,
		trade_id = int,
	}
b) player_name => {
		type = "offer_target",
		from_player = string,
		trade_id = int,
	}
c) player_name => {
		type = "trade",
		with_player = string,
		privmsg_index = int, -- starting at 1
		left = {
			player_name = string,
			player_display_name = string,
			player_role = ("admin", "new", "survival", "creative"),
			state = enum, (STATE_OPEN, STATE_CLOSED, STATE_CONFIRMED),
		}, -- custom state of THIS player
		right = {...}, -- the same format as left, but for THAT player
	}
]]
