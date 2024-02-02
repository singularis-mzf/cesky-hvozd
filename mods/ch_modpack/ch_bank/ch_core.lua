local zaplatit_od_postavy_v_hotovosti = ch_core.zaplatit_od_postavy
local zaplatit_postave_v_hotovosti = ch_core.zaplatit_postave

--[[
	Daná postava zaplatí požadovanou částku určenou metodou.
	Vrací true v případě úspěchu.
	V případě neúspěchu vrátí false a nic nebude zaplaceno.
	- player_name: string // jméno postavy
	- castka : int >= 0 // částka k zaplacení
	- options : {
		bank = bool or nil
		cash = bool or nil,
		group = string or nil,
		label = string or nil,
		player_inv = InvRef or nil,
		prefer_cash = bool or nil,
		simulation = bool or nil,
	} or nil
]]
function ch_core.zaplatit_od_postavy(player_name, castka, options)
	local result, _message
	if options == nil then
		options = {}
	end
	if options.cash ~= false and options.prefer_cash then
		result = zaplatit_od_postavy_v_hotovosti(player_name, castka, options)
		if result then
			return result -- zaplaceno v hotovosti
		end
	end
	if options.bank ~= false then
		result, _message = ch_bank.platba{
			from_player = player_name,
			to_player = "",
			amount = castka,
			label = options.label or "obecná platba",
			group = options.group,
			simulation = options.simulation,
		}
		if result then
			if not options.simulation then
				minetest.log("action", player_name.." payed "..castka.." from bank")
			end
			return result -- zaplaceno z banky
		end
	end
	if options.cash ~= false and not options.prefer_cash then
		result = zaplatit_od_postavy_v_hotovosti(player_name, castka, options)
		if result then
			return result -- zaplaceno v hotovosti
		end
	end
	if not options.simulation then
		minetest.log("action", player_name.." failed to pay "..castka.." ("..dump2(options)..")")
	end
	return false
end

--[[
	Zaplatí dané postavě uvedenou částku určenou metodou.
	Vrací true v případě úspěchu.
	V případě neúspěchu vrátí false a nic nebude zaplaceno.
	- player_name: string // jméno postavy
	- castka : int >= 0 // částka k zaplacení
	- options : {
		bank = bool or nil
		cash = bool or nil,
		group = string or nil,
		label = string or nil,
		player_inv = InvRef or nil,
		prefer_cash = bool or nil,
		simulation = bool or nil,
	} or nil
]]
function ch_core.zaplatit_postave(player_name, castka, options)
	local result, _message
	if options == nil then
		options = {}
	end
	if options.cash and options.prefer_cash then
		result = zaplatit_postave_v_hotovosti(player_name, castka, options)
		if result then
			return result -- zaplaceno v hotovosti
		end
	end
	if options.bank then
		result, _message = ch_bank.platba{
			from_player = "",
			to_player = player_name,
			amount = castka,
			label = options.label or "obecná platba",
			group = options.group,
			simulation = options.simulation,
		}
		if result then
			if not options.simulation then
				minetest.log("action", player_name.." got payed "..castka.." to bank")
			end
			return result -- zaplaceno z banky
		end
	end
	if options.cash and not options.prefer_cash then
		result = zaplatit_postave_v_hotovosti(player_name, castka, options)
		if result then
			return result -- zaplaceno v hotovosti
		end
	end
	if not options.simulation then
		minetest.log("action", player_name.." failed to got payed "..castka.." ("..dump2(options)..")")
	end
	return false
end
