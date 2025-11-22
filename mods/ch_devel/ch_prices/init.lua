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
	if f == nil then
		core.log("error", "ch_prices.lua file not loaded, because: "..(errmsg or "unknown error"))
		return
	end
	local data = f()
	local fixed, aliases, mks, aliases2 = {}, {}, {}, {}
	local set = {}
	-- načíst definice cen a zapsat je do dočasných seznamů
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
			if row[3] == row[2] then
				error("Circular alias for "..name.."!")
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
			sell_prices[name] = row[3] -- prodej dovolen (může být i zadarmo)
		end
		if row[4] ~= nil then
			if row[4] ~= 0 then
				buy_prices[name] = row[4]
			else
				buy_prices[name] = nil -- 0 => výkup zakázán
			end
		else
			-- cena výkupu není uvedena, spočítat jako čtvrtinu ceny prodeje
			local price = math.floor((sell_prices[name] or 0) / 4)
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
			assert(type(subname) == "string")
			if set[subname] then
				local coef = subrow[2] or 1
				local subsell = sell_prices[subname]
				local subbuy = buy_prices[subname]
				if subsell ~= nil then
					-- víme, za kolik se prodává tato položka potřebná k výrobě => přičíst k výsledné ceně prodeje
					sell_price = sell_price + subsell * coef
				else
					allow_sell = false
					print("DEBUG: cannot sell '"..name.."' because '"..subname.."' has no sell price yet!")
				end
				if subbuy ~= nil then
					-- víma, za kolik se vykupuje tato položka potřebná k výrobě => přičíst k výsledné ceně výkupu
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

function ch_prices.get_buy_price(pos, stack, owner_name, shop_age)
	if stack:is_empty() then
		return nil
	end
	local name = stack:get_name()
	local base_price = buy_prices[name]
	if base_price == nil then
		return nil
	end
	-- TODO
	local result = math.ceil(stack:get_count() * base_price)
	if result > 0 then
		return result
	end
end

function ch_prices.get_sell_price(pos, stack, owner_name, shop_age)
	if stack:is_empty() then
		return nil
	end
	local name = stack:get_name()
	local base_price = sell_prices[name]
	if base_price == nil then
		return nil
	end
	-- TODO
	local result = math.floor(stack:get_count() * base_price)
	if result > 0 then
		return result
	end
end

local known_ui_recipe_types = {}

local function recipe_to_mk(recipe)
	assert(recipe.output)
	assert(type(recipe.output) == "string")
	if recipe.output == "" then
		return nil, false
	end
	local output_stack = ItemStack(recipe.output)
	local output_name = output_stack:get_name()
	local output_count = output_stack:get_count()
	-- print("DEBUG: recipe = "..dump2(recipe))
	-- print("DEBUG: output_stack = "..recipe.output.." [type="..type(recipe.output).."]")
	assert(output_count >= 1)
	local items = {}
	local item_to_index = {}
	for j = 1, 9 do
		if type(recipe.items[j]) ~= "nil" then
			local input_name = recipe.items[j]
			if item_to_index[input_name] ~= nil then
				local record = items[item_to_index[input_name]]
				record[2] = (record[2] or 1 / output_count) + 1 / output_count
			else
				table.insert(items, {input_name, 1 / output_count})
				item_to_index[input_name] = #items
			end
		end
	end
	if #items > 0 then
		local parts = {"mk(\"", output_name, "\", {"}
		table.sort(items, function(a, b) return a[1] < b[1] end)
		for i, record in ipairs(items) do
			if i > 1 then
				table.insert(parts, ", {\"")
			else
				table.insert(parts, "{\"")
			end
			table.insert(parts, record[1])
			if record[2] ~= nil and record[2] ~= 1 then
				table.insert(parts, "\", "..record[2].."}")
			else
				table.insert(parts, "\"}")
			end
		end
		table.insert(parts, "})")
		return table.concat(parts), true
	else
		return "-- fix(\"".. output_name.."\", )", false
	end
end

local function combine_recipes(core_recipes, ui_recipes)
	if core_recipes == nil then
		return ui_recipes
	elseif ui_recipes == nil then
		return core_recipes
	else
		core_recipes = table.copy(core_recipes)
		for _, recipe in ipairs(ui_recipes) do
			assert(type(recipe.type) == "string")
			known_ui_recipe_types[recipe.type] = true
			if recipe.type ~= "digging" and recipe.type ~= "digging_chance" then
				table.insert(core_recipes, recipe)
			end
		end
		return core_recipes
	end
end

local function generovat_ceny(name, params)
	local mks = {}
	local item_names = {}
	local full = params == "full"
	for item_name, _ in pairs(core.registered_items) do
		if item_name:find(":") and (full or sell_prices[item_name] == nil) then
			table.insert(item_names, item_name)
		end
	end
	table.sort(item_names)
	for _, output_name in ipairs(item_names) do
		local recipes = core.get_all_craft_recipes(output_name)
		local ui_recipes = unified_inventory.get_recipe_list(output_name)
		local mks_orig_length = #mks
		local duplicity_protection = {}
		recipes = combine_recipes(recipes, ui_recipes)
		if recipes ~= nil then
			for i, recipe in ipairs(recipes) do
				local new_mk, success = recipe_to_mk(recipe)
				if success and duplicity_protection[new_mk] == nil then
					table.insert(mks, new_mk)
					duplicity_protection[new_mk] = new_mk
				end
				--[[
				if recipe.output ~= "" then
					local output_stack = ItemStack(assert(recipe.output))
					print("DEBUG: recipe = "..dump2(recipe))
					print("DEBUG: output_stack = "..recipe.output.." [type="..type(recipe.output).."]")
					local output_count = output_stack:get_count()
					assert(output_count >= 1)
					local items = {}
					local item_to_index = {}
					for j = 1, 9 do
						if type(recipe.items[j]) ~= "nil" then
							local input_name = recipe.items[j]
							if item_to_index[input_name] ~= nil then
								local record = items[item_to_index[input_name] ]
								record[2] = (record[2] or 1 / output_count) + 1 / output_count
							else
								table.insert(items, {input_name, 1 / output_count})
								item_to_index[input_name] = #items
							end
						end
					end
					if #items > 0 then
						local parts = {"mk(\"", output_name, "\", {"}
						table.sort(items, function(a, b) return a[1] < b[1] end)
						for i, record in ipairs(items) do
							if i > 1 then
								table.insert(parts, ", {\"")
							else
								table.insert(parts, "{\"")
							end
							table.insert(parts, record[1])
							if record[2] ~= nil and record[2] ~= 1 then
								table.insert(parts, "\", "..record[2].."}")
							else
								table.insert(parts, "\"}")
							end
						end
						table.insert(parts, "})")
						table.insert(mks, table.concat(parts))
					end
				end
				]]
			end
		end
		if #mks == mks_orig_length then
			-- no recipes for this item
			mks[mks_orig_length + 1] = "-- fix(\"".. output_name.."\", )"
		end
	end
	core.safe_file_write(worldpath.."/_ch_prices_generated.lua", table.concat(mks, "\n--\n"))
	print("DEBUG: "..dump2({known_ui_recipe_types = known_ui_recipe_types}))
	return true, "Vygenerováno."
end

core.register_chatcommand("generovat_ceny", {
	params = "",
	description = "Vygeneruje data pro soubor ch_prices.lua pro mód ch_prices.",
	privs = {server = true},
	func = generovat_ceny,
})



ch_base.close_mod(core.get_current_modname())
