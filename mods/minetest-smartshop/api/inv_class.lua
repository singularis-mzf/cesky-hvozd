
local class = smartshop.util.class
local get_stack_key = smartshop.util.get_stack_key
local remove_stack_with_meta = smartshop.util.remove_stack_with_meta

--------------------

local inv_class = class()
smartshop.inv_class = inv_class

--------------------

function inv_class:__new(inv)
	if type(inv) ~= "userdata" then
		smartshop.util.error("nový inventář nečekaně %s", dump(inv))
	end
	self.inv = inv
end

--------------------

function inv_class:initialize_inventory()
	-- noop
end

--------------------

function inv_class:get_count(stack, match_meta)
	if type(stack) == "string" then
		stack = ItemStack(stack)
	end
	if stack:is_empty() then
		return 0
	end
	local inv = self.inv
	local total = 0

	local key = get_stack_key(stack, match_meta)
	for _, inv_stack in ipairs(inv:get_list("main")) do
		if key == get_stack_key(inv_stack, match_meta) then
			total = total + inv_stack:get_count()
		end
	end

	return math.floor(total / stack:get_count())
end

function inv_class:get_all_counts(match_meta)
	local inv = self.inv
	local all_counts = {}

	for _, stack in ipairs(inv:get_list("main")) do
		local key = get_stack_key(stack, match_meta)
		local count = all_counts[key] or 0
		count = count + stack:get_count()
		all_counts[key] = count
	end

	return all_counts
end

function inv_class:room_for_item(stack)
	return self.inv:room_for_item("main", stack)
end

function inv_class:add_item(stack)
	return self.inv:add_item("main", stack)
end

function inv_class:contains_item(stack, match_meta)
	return self.inv:contains_item("main", stack, match_meta)
end

function inv_class:remove_item(stack, match_meta)
	local inv = self.inv

	local removed
	if match_meta then
		removed = remove_stack_with_meta(inv, "main", stack)

	else
		removed = inv:remove_item("main", stack)
	end

	return removed
end

-- => remaining_hundreds, how_much_to_remove
local function remove_money_to_match_100(inv, item_name, amount)
	local count_to_remove = 0
	local target = math.floor(amount / 100) * 100
	local stack = inv:remove_item(item_name.." "..math.min(amount, 10000))
	local count = stack:get_count()
	while count == 10000 and amount >= 10000 do
		amount = amount - 10000
		count_to_remove = count_to_remove + 10000
	end
	if count >= amount then
		-- completely satisfied
		return 0, count_to_remove + count
	end
	-- count < amount
	count_to_remove = amount - 100
	local remaining_hundreds = (amount - count_to_remove) / 100
	assert(remaining_hundreds == math.floor(remaining_hundreds))
	return remaining_hundreds, count_to_remove
end

--[[
	=> { success = true|false, h_to_remove, kcs_to_remove, zcs_to_remove, remains }
]]
function inv_class:remove_ch_money(amount)
	local remains
	local result = {}
	remains, result.h_to_remove = remove_money_to_match_100(self, "ch_core:kcs_h", amount)
	if remains ~= 0 then
		remains, result.kcs_to_remove = remove_money_to_match_100(self, "ch_core:kcs_kcs", remains)
		result.zcs_to_remove = 0
		while remains > 0 do
			local stack = self:remove_item("ch_core:kcs_zcs "..math.min(remains, 10000), "give")
			local count = stack:get_count()
			if count >= remains then
				result.zcs_to_remove = result.zcs_to_remove + remains
				remains = 0
				break
			elseif count > 0 then
				result.zcs_to_remove = result.zcs_to_remove + count
				remains = remains - count
			else
				break -- no more items
			end
		end
	end
	local success = remains == 0
	if success then
		if result.h_to_remove < 0 then
			success = self:add_item(ItemStack("ch_core:kcs_h "..(-result.h_to_remove)), "pay")
		end
		if success and result.kcs_to_remove < 0 then
			success = self:add_item(ItemStack("ch_core:kcs_kcs "..(-result.kcs_to_remove)), "pay")
		end
		assert(result.zcs_to_remove >= 0)
	end
	result.success = success
	result.remains = remains
	print("DEBUG: remove_ch_money(): "..dump2({amount = amount, result = result}))
	return result
end

--------------------

function inv_class:get_tmp_inv()
	return smartshop.tmp_inv_class:new(self.inv)
end

function inv_class:destroy_tmp_inv(tmp_inv)
	tmp_inv:destroy()
end
