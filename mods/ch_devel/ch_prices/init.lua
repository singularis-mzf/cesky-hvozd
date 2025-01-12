ch_base.open_mod(core.get_current_modname())

ch_prices = {}

local worldpath = core.get_worldpath()
local sell_prices, buy_prices = {}, {}

local function intern(s)
	local def = core.registered_items[s]
	if def ~= nil and def.name == s then
		return def.name
	else
		return s
	end
end

local function on_mods_loaded()
	local f, errmsg = loadfile(worldpath.."/ch_prices.lua")
	if f ~= nil then
		local data = f()
		local fixed, aliases, mks, aliases2 = {}, {}, {}, {}
		local set = {}
		for _, row in ipairs(data) do
			local typ, name = row[1], row[2]
			assert(type(typ) == "string")
			assert(type(name) == "string")
			if set[name] ~= nil then
				error("ch_prices.lua define prices for '"..name.."' multiple times!")
			end
			if typ == "a" then
				if type(row[3]) ~= "string" or row[4] ~= nil then
					error("Invalid format for alias '"..name.."' in ch_prices.lua!")
				end
				table.insert(aliases, row)
				set[name] = row
			elseif typ == "f" then
				if (row[3] == nil and row[4] == nil) or row[5] ~= nil then
					error("Invalid format for fixed '"..name.."' in ch_prices.lua!")
				end
				table.insert(fixed, row)
				set[name] = row
			elseif typ == "m" then
				if type(row[3]) ~= "table" or row[4] ~= nil then
					error("Invalid format for make '"..name.."' in ch_prices.lua!")
				end
				table.insert(mks, row)
				set[name] = row
			else
				core.log("error", "Unknown 'typ' '"..typ.."' in ch_prices.lua ignored for '"..name.."'!")
			end
		end
		-- process fixed:
		for _, row in ipairs(fixed) do
			local name = intern(row[2])
			if row[3] ~= nil then
				sell_prices[name] = row[3]
			end
			if row[4] ~= nil then
				buy_prices[name] = row[4]
			elseif row[3] ~= nil then
				local price = math.floor(row[3] / 4)
				if price > 0 then
					buy_prices[name] = price
				end
			end
		end
		-- process aliases:
		for _, row in ipairs(aliases) do
			local new_name, old_name = row[2], row[3]
			if set[old_name] then
				local sell_price = sell_prices[old_name]
				local buy_price = buy_prices[old_name]
				if not sell_price and not buy_price then
					table.insert(aliases2, row) -- wait for the second round
				else
					if sell_price ~= nil then
						sell_prices[new_name] = sell_price
					end
					if buy_price ~= nil then
						buy_prices[new_name] = buy_price
					end
				end
				--[[
				if sell_price == nil and buy_price == nil then
					core.log("warning", "Alias '"..new_name.."' = '"..old_name.."' is ineffective, because '"..old_name.."' has no sell/buy prices defined!")
				end ]]
			else
				core.log("warning", "Alias to '"..old_name.."' in ch_prices.lua ignored, because that has no registered price.")
			end
		end
		-- process mks:
		for _, row in ipairs(mks) do
			local name = row[2]
			local allow_sell, sell_price, buy_price = true, 0, 0
			assert(type(row[3]) == "table")
			for _, subrow in ipairs(row[3]) do
				local subname = assert(subrow[1])
				if set[subname] then
					local coef = subrow[2] or 1
					local subsell = sell_prices[subname]
					local subbuy = buy_prices[subname]
					if subsell ~= nil then
						sell_price = sell_price + subsell * coef
					else
						allow_sell = false
						print("DEBUG: cannot sell '"..name.."' because '"..subname.."' has no sell price yet!")
					end
					if subbuy ~= nil then
						buy_price = buy_price + subbuy * coef
					end
				else
					allow_sell = false
					core.log("warning", "Make '"..name.."' cannot be sold, because it references unkown item '"..subname.."'!")
					break
				end
			end
			if allow_sell and sell_price > 0 then
				sell_prices[name] = sell_price
			end
			if buy_price > 0 then
				buy_prices[name] = buy_price
			end
		end
		-- process aliases2:
		for _, row in ipairs(aliases2) do
			local new_name, old_name = row[2], row[3]
			local sell_price = sell_prices[old_name]
			local buy_price = buy_prices[old_name]
			if not sell_price and not buy_price then
				core.log("warning", "Alias '"..new_name.."' = '"..old_name.."' is ineffective, because '"..old_name.."' has no sell/buy prices defined!")
			else
				if sell_price ~= nil then
					sell_prices[new_name] = sell_price
				end
				if buy_price ~= nil then
					buy_prices[new_name] = buy_price
				end
			end
		end
		core.log("action", "[ch_prices] initialized from ch_prices.lua")
	else
		core.log("error", "ch_prices.lua file not loaded, because: "..(errmsg or "unknown error"))
	end
end
core.register_on_mods_loaded(on_mods_loaded)

function ch_prices.get_base_prices(name)
	local buy_price = buy_prices[name]
	local sell_price = sell_prices[name]
	if buy_price or sell_price then
		return {name = name, buy = buy_price, sell = sell_price}
	else
		return {name = name}
	end
end

function ch_prices.get_buy_price(pos, stack, player_name, shop_age)
	if stack:is_empty() then
		return nil
	end
	local name = stack:get_name()
	local base_price = buy_prices[name]
	if base_price == nil then
		return nil
	end
	-- TODO
end

function ch_prices.get_sell_price(pos, stack, player_name, shop_age)
	if stack:is_empty() then
		return nil
	end
	local name = stack:get_name()
	local base_price = sell_prices[name]
	if base_price == nil then
		return nil
	end
	-- TODO
end

ch_base.close_mod(core.get_current_modname())
