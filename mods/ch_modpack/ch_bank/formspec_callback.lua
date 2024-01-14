local tinv, utils = ...

local STATE_OPEN, STATE_CLOSED, STATE_CONFIRMED = utils.STATE_OPEN, utils.STATE_CLOSED, utils.STATE_CONFIRMED

function utils.formspec_callback(trade_state, player, formname, fields)
	local player_name = player:get_player_name()
	local player_name_right = trade_state.right.player_name
	local zprava_name

	local _trade_state, tstype1, tstype2
	_trade_state, tstype1 = utils.get_player_trade_state(player_name)
	_trade_state, tstype2 = utils.get_player_trade_state(player_name_right)
	if tstype1 ~= "trade" or tstype2 ~= "trade" then
		minetest.log("error", "[ch_bank] formspec_callback called when trade states of players "..player_name.." and "..player_name_right.." are: "..tstype1.." and "..tstype2.."!")
		return
	end

	-- Preprocessing:
	if fields.key_enter == "true" then
		if fields.key_enter_field:sub(1, 6) == "zprava" then
			zprava_name = fields.key_enter_field
			fields.sendprivmsg = "odeslat"
		elseif fields.key_enter_field == "penize" then
			fields.kcs = ""
		end
	end

	-- Buttons:
	local update_right_formspec = false
	if fields.zavrit then
		ch_bank.zrusit_obchod(player_name)

	elseif fields.close_offer then
		if not trade_state.left.state == STATE_OPEN then
			minetest.log("warning", "[ch_bank] close_offer with unexpected left state "..trade_state.left.state.."!")
			return
		end
		trade_state.left.state = STATE_CLOSED
		update_right_formspec = true

	elseif fields.cancel_offer then
		trade_state.left.state = STATE_OPEN
		trade_state.right.state = STATE_OPEN
		update_right_formspec = true

	elseif fields.confirm_offer then
		if trade_state.left.state ~= STATE_CLOSED or trade_state.right.state == STATE_OPEN then
			minetest.log("warning", "[ch_bank] confirm_offer with unexpected states: "..trade_state.left.state..", "..trade_state.right.state.."!")
			return
		end
		trade_state.left.state = STATE_CONFIRMED
		if trade_state.right.state == STATE_CONFIRMED and
			utils.uzavrit_obchod(player, minetest.get_player_by_name(trade_state.right.player_name))
		then
			return
		end
		update_right_formspec = true

	elseif fields.sendprivmsg then
		local zprava
		if zprava_name ~= nil then
			zprava = fields[zprava_name] or ""
		else
			for k, v in pairs(fields) do
				if k:sub(1, 6) == "zprava" then
					zprava = v
					break
				end
			end
			if zprava == nil then
				minetest.log("warning", "[ch_bank] zprava_name not found in fields when expected!")
				return
			end
		end
		if zprava ~= "" then
			ch_core.soukroma_zprava(trade_state.left.player_name, trade_state.right.player_name, zprava)
			trade_state.privmsg_index = trade_state.privmsg_index + 1
		end

	elseif fields.resetprivmsg then
		trade_state.privmsg_index = trade_state.privmsg_index + 1

	elseif (fields.kcs or fields.hcs or fields.zcs) and trade_state.left.state == STATE_OPEN then
		local n = tonumber(fields.penize)
		if n == nil or n ~= math.floor(n) or n < 1 or n > 10000 then
			ch_core.systemovy_kanal(trade_state.left.player_name, "Chybné zadání! Zadejte celé číslo 1 až 10000.")
			return
		end
		local stack
		if fields.kcs then
			stack = ItemStack("ch_core:kcs_kcs "..n)
		elseif fields.zcs then
			stack = ItemStack("ch_core:kcs_zcs "..n)
		else
			stack = ItemStack("ch_core:kcs_h "..n)
		end
		if not tinv.room_for_item_in_trade_inventory(player, stack) then
			ch_core.systemovy_kanal(trade_state.left.player_name, "Chyba při výběru: V cílovém inventáři není dost místa.")
			return
		end
		local castka = assert(ch_core.precist_hotovost(stack))
		local uspech, chyba = ch_bank.platba{
			from_player = trade_state.left.player_name,
			to_player = "",
			amount = castka,
			label = "dočasný vklad/výběr",
			group = "temp",
		}
		if uspech then
			tinv.add_item_to_trade_inventory(player, stack)
		else
			ch_core.systemovy_kanal(trade_state.left.player_name, "Chyba při výběru: "..(chyba or "neznámá chyba"))
		end

	elseif fields.quit then
		ch_bank.zrusit_obchod(player_name)
		return

	else
		return
	end
	if update_right_formspec then
		local right_trade_state = utils.get_player_trade_state(player_name_right)
		ch_core.update_formspec(player_name_right, "ch_bank:trade", utils.get_formspec(right_trade_state))
	end
	return utils.get_formspec(trade_state)
end
