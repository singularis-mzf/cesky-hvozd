local S = smartshop.S
local api = smartshop.api

local check_shop_add = smartshop.util.check_shop_add_remainder
local check_shop_removed = smartshop.util.check_shop_remove_remainder
local check_player_add = smartshop.util.check_player_add_remainder
local check_player_removed = smartshop.util.check_player_remove_remainder

api.registered_purchase_mechanics = {}
api.registered_on_purchases = {}
api.registered_on_shop_fulls = {}
api.registered_on_shop_emptys = {}
api.registered_transaction_transforms = {}

local function smartshop_pay_from_shop(player_name, amount, options)
	if options.smartshop == false or options.shop == nil then return false end
	local shop = options.shop
	if player_name ~= shop:get_owner() then
		return false, "Obchodní terminál nepatří zadané postavě (pravděpodobně vnitřní chyba)."
	end
	local tmp_shop_inv = shop:get_tmp_inv()

	local removal_data = tmp_shop_inv:remove_ch_money(amount)
	shop:destroy_tmp_inv(tmp_shop_inv)
	if not removal_data.success then
		return false, "V obchodním terminálu není dost hotovosti."
	end
	local amount_to_remove = 10000 * removal_data.zcs_to_remove + 100 * removal_data.kcs_to_remove + removal_data.h_to_remove
	if amount_to_remove ~= amount then
		error("Error in remove_ch_money(): "..dump2({amount = amount, amount_to_remove = amount_to_remove, removal_data = removal_data}))
	end
	if options.simulation then
		return true
	end
	local removed_items = {}
	local added_items = {}
	local items_to_remove = {
		{ "ch_core:kcs_h", removal_data.h_to_remove },
		{ "ch_core:kcs_kcs", removal_data.kcs_to_remove },
		{ "ch_core:kcs_zcs", removal_data.zcs_to_remove },
	}
	for i = 1, 3 do
		local count = items_to_remove[i][2]
		if count > 0 then
			local name = items_to_remove[i][1]
			if count > 10000 then
				stack = ItemStack(name.." 10000")
				repeat
					table.insert(removed_items, shop:remove_item(stack, "give"))
					count = count - 10000
				until(count <= 10000)
			end
			stack = ItemStack(name.." "..count)
			table.insert(removed_items, shop:remove_item(stack, "give"))
		end
	end
	for i = 1, 3 do
		local count = items_to_remove[i][2]
		if count < 0 then
			local name = items_to_remove[i][1]
			stack = ItemStack(name.." "..(-count))
			table.insert(added_items, shop:add_item(stack, "pay"))
		end
	end
	return true
end

local function smartshop_pay_to_shop(player_name, amount, options)
	if options.smartshop == false or options.shop == nil then return false end
	local shop = options.shop
	if player_name ~= shop:get_owner() then
		return false, "Obchodní terminál nepatří zadané postavě (pravděpodobně vnitřní chyba)."
	end
	local hotovost = ch_core.hotovost(amount)
	local tmp_shop_inv = shop:get_tmp_inv()
	for _, stack in ipairs(hotovost) do
		if not tmp_shop_inv:add_item(stack, "pay"):is_empty() then
			return false, "Obchodní terminál je plný"
		end
	end
	if options.simulation then
		return true
	end
	for _, stack in ipairs(hotovost) do
		if not shop:add_item(stack, "pay"):is_empty() then
			minetest.log("action", player_name.." failed to pay "..amount.." to a smartshop")
			return false, "Obchodní terminál je plný"
		end
	end
	minetest.log("action", player_name.." has payed "..amount.." to a smartshop")
	return true
end

ch_core.register_payment_method("smartshop", smartshop_pay_from_shop, smartshop_pay_to_shop)


--[[
	TODO: mechanic definition isn't set in stone currently, see below
	      for an example
]]
function api.register_purchase_mechanic(def)
	table.insert(api.registered_purchase_mechanics, def)
end

function api.register_on_purchase(callback)
	table.insert(api.registered_on_purchases, callback)
end

function api.on_purchase(player, shop, i)
	for _, callback in ipairs(api.registered_on_purchases) do
		callback(player, shop, i)
	end
end

function api.register_on_shop_full(callback)
	table.insert(api.registered_on_shop_fulls, callback)
end

function api.on_shop_full(player, shop, i)
	for _, callback in ipairs(api.registered_on_shop_fulls) do
		callback(player, shop, i)
	end
end

function api.register_on_shop_empty(callback)
	table.insert(api.registered_on_shop_emptys, callback)
end

function api.on_shop_empty(player, shop, i)
	for _, callback in ipairs(api.registered_on_shop_emptys) do
		callback(player, shop, i)
	end
end

function api.register_transaction_transform(callback)
	table.insert(api.registered_transaction_transforms, callback)
end

function api.do_transaction_transforms(player, shop, i, shop_removed, player_removed)
	for _, callback in ipairs(api.registered_transaction_transforms) do
		shop_removed, player_removed = callback(player, shop, i, shop_removed, player_removed)
	end
	return shop_removed, player_removed
end

function api.try_purchase(player, shop, i)
	for _, def in ipairs(api.registered_purchase_mechanics) do
		if def.allow_purchase(player, shop, i) then
			def.do_purchase(player, shop, i)
			shop:log_purchase(player, i, def.description)
			api.on_purchase(player, shop, i)
			return true
		end
	end

	local reason = api.get_purchase_fail_reason(player, shop, i)
	smartshop.chat_send_player(player, ("Nemohu směnit: %s"):format(reason))

	if reason == "Shop is sold out" then
		api.on_shop_empty(player, shop, i)
	elseif reason == "Shop is full" then
		api.on_shop_full(player, shop, i)
	end

	return false
end

function api.get_purchase_fail_reason(player, shop, i)
	local player_inv = api.get_player_inv(player)
	local pay_stack = shop:get_pay_stack(i)
	local give_stack = shop:get_give_stack(i)

	if not player_inv:contains_item(pay_stack) then
		return "Nemáte v inventáři zboží požadované jako cenu"
	elseif not shop:contains_item(give_stack, "give") then
		return "Zboží je vyprodáno"
	elseif not player_inv:room_for_item(give_stack) then
		return "Ve vašem inventáři není dost místa"
	elseif not shop:room_for_item(pay_stack, "pay") then
		return "Terminál je přeplněný"
	end

	return "Selhalo z neznámého důvodu"
end

--[[
local function first(a)
	return a
end
]]

local function ifthenelse(condition, true_result, false_result)
	if condition then
		return true_result
	else
		return false_result
	end
end


api.register_purchase_mechanic({
	name = "smartshop:basic_purchase",
	description = S("normal exchange"),
	allow_purchase = function(player, shop, i)
		local player_name = player:get_player_name()
		local shop_owner = shop:get_owner()
		local player_inv = api.get_player_inv(player)
		local pay_stack = shop:get_pay_stack(i)
		local give_stack = shop:get_give_stack(i)
		local pay_money = ch_core.precist_hotovost(pay_stack)
		local give_money = ch_core.precist_hotovost(give_stack)
		local tmp_shop_inv = shop:get_tmp_inv()
		local tmp_player_inv = player_inv:get_tmp_inv()
		local empty_stack = ItemStack()
		local success = true
		local pl_options, player_removed, shop_removed

		if pay_money ~= nil and give_money ~= nil then
			pay_money, give_money = nil, nil -- exchange money for money as items
		end

		-- 1. remove "give" from the shop
		--[[ if give_money ~= nil then
			local lsuccess = ch_core.pay_from(shop_owner, give_money, {shop = shop, simulation = true})
			shop_removed = ifthenelse(lsuccess, give_stack, empty_stack)
			success = success and lsuccess
		else ]]
		local count_to_remove = give_stack:get_count()
		shop_removed = tmp_shop_inv:remove_item(give_stack, "give")
		success = count_to_remove == shop_removed:get_count()
		-- end

		-- 2. remove "pay" from the player
		if pay_money ~= nil then
			local lsuccess = ch_core.pay_from(player_name, pay_money, {simulation = true})
			player_removed = ifthenelse(lsuccess, pay_stack, empty_stack)
			success = success and lsuccess
		else
			local count_to_remove = pay_stack:get_count()
			player_removed = tmp_player_inv:remove_item(pay_stack, "pay")
			success = success and (count_to_remove == player_removed:get_count())
		end

		-- 3. add "pay" to the shop
		--[[ if pay_money ~= nil then
			local lsuccess = ch_core.pay_to(shop_owner, pay_money, {shop = shop, simulation = true})
			success = success and lsuccess
		else ]]
		local leftover = tmp_shop_inv:add_item(player_removed, "pay")
		success = success and (leftover:get_count() == 0)
		-- end

		-- 4. add "give" to the player
		if give_money ~= nil then
			local lsuccess = ch_core.pay_to(player_name, give_money, {simulation = true})
			success = success and lsuccess
		else
			local leftover = tmp_player_inv:add_item(shop_removed, "give")
			success = success and (leftover:get_count() == 0)
		end

		-- 5. clean up
		shop:destroy_tmp_inv(tmp_shop_inv)
		player_inv:destroy_tmp_inv(tmp_player_inv)

		return success
	end,
	do_purchase = function(player, shop, i)
		local player_name = player:get_player_name()
		local shop_owner = shop:get_owner()
		local player_inv = api.get_player_inv(player)
		local pay_stack = shop:get_pay_stack(i)
		local give_stack = shop:get_give_stack(i)
		local pay_money = ch_core.precist_hotovost(pay_stack)
		local give_money = ch_core.precist_hotovost(give_stack)
		local empty_stack = ItemStack()

		local shop_removed, player_removed, shop_remaining, player_remaining, pl_options

		if pay_money ~= nil and give_money ~= nil then
			pay_money, give_money = nil, nil -- exchange money for money as items
		end

		-- 1. remove "give" from the shop
		--[[ if give_money ~= nil then
			local lsuccess = ch_core.pay_from(shop_owner, give_money, {shop = shop, label = "platba za výkup pomocí obchodního terminálu"})
			shop_removed = ifthenelse(lsuccess, give_stack, empty_stack)
		else ]]
		shop_removed = shop:remove_item(give_stack, "give")
		-- end

		-- 2. remove "pay" from the player
		if pay_money ~= nil then
			local lsuccess = ch_core.pay_from(player_name, pay_money, {label = "platba u obchodního terminálu"})
			player_removed = ifthenelse(lsuccess, pay_stack, empty_stack)
		else
			player_removed = player_inv:remove_item(pay_stack)
		end

		-- api.do_transaction_transforms()
		shop_removed, player_removed = api.do_transaction_transforms(player, shop, i, shop_removed, player_removed)

		-- 3. add "pay" to the shop
		--[[ if pay_money ~= nil then
			local lsuccess = ch_core.pay_to(shop_owner, pay_money, {shop = shop, label = "platba za zboží v obchodním terminálu"})
			shop_remaining = ifthenelse(lsuccess, empty_stack, pay_stack)
		else ]]
		-- plain exchange
		shop_remaining = shop:add_item(player_removed, "pay")
		--end

		-- 4. add "give" to the player
		if give_money ~= nil then
			local lsuccess = ch_core.pay_to(player_name, give_money, {label = "platba z obchodního terminálu"})
			player_remaining = ifthenelse(lsuccess, empty_stack, give_stack)
		else
			-- plain exchange
			player_remaining = player_inv:add_item(shop_removed)
		end

		-- 5. checks
		check_shop_removed(shop, shop_removed, give_stack)
		check_player_removed(player_inv, shop, player_removed, pay_stack)
		check_player_add(player_inv, shop, player_remaining)
		check_shop_add(shop, shop_remaining)
	end
})
