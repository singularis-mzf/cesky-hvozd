local function bank_pay_from_player(player_name, amount, options)
	if options.bank == false then return false end
	local success, error_message = ch_bank.platba{
		from_player = player_name,
		to_player = "",
		amount = amount,
		label = options.label or "obecná platba",
		simulation = options.simulation,
	}
	if not options.simulation then
		if success then
			minetest.log("action", player_name.." payed "..amount.." from bank")
		else
			minetest.log("action", player_name.." failed to pay "..amount.." from bank ("..dump2(options)..")")
		end
	end
	return success, error_message
end

local function bank_pay_to_player(player_name, amount, options)
	if options.bank == false then return false end
	local success, error_message = ch_bank.platba{
		from_player = "",
		to_player = player_name,
		amount = amount,
		label = options.label or "obecná platba",
		simulation = options.simulation,
	}
	if not options.simulation then
		if success then
			minetest.log("action", player_name.." has been payed "..amount.." to bank")
		else
			minetest.log("action", player_name.." failed to been payed "..amount.." to bank ("..dump2(options)..")")
		end
	end
	return success, error_message
end

ch_core.register_payment_method("bank", bank_pay_from_player, bank_pay_to_player)
