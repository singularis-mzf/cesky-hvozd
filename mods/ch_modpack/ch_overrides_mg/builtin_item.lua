-- BUILTIN ITEM on_step override
local orig_builtin_item_on_step = default.builtin_item_on_step
default.builtin_item_on_step = function(self, dtime, ...)
	local orig_itemstring = assert(self.itemstring)
	self.itemstring = "default:pick_steel" -- dirty hack to disable built-in merging of items
	assert(ItemStack(self.itemstring):get_free_space() == 0)
	orig_builtin_item_on_step(self, dtime, ...)
	if self.itemstring == "default:pick_steel" then
		self.itemstring = orig_itemstring
	end
	-- a new merging of items
	if self.physical_state and not self.moving_state then
		local rndnum = math.random(0, 15)
		if rndnum == 15 then
			local my_handle, errmsg = ch_core.get_handle_of_entity(self)
			if my_handle == nil then
				core.log("error", "ch_core.get_handle_of_entity() failed for __builtin:item: "..(errmsg or "nil"))
				return
			end
			local stack = ItemStack(self.itemstring)
			if stack:get_free_space() == 0 then return end
			local other_items = ch_core.find_handles_in_radius(self.object:get_pos(), 1.0, "__builtin:item", "entity", my_handle)
			for i = 1, #other_items do
				local entity = other_items[i]
				if self:try_merge_with(stack, entity.object, entity) then
					stack = ItemStack(self.itemstack)
					if stack:get_free_space() == 0 then return end
				end
			end
		end
	end
end
