petz.increase_egg_count = function(self)
	self.eggs_count = kitz.remember(self, "eggs_count", self.eggs_count+1)
end

--Lay Egg
petz.lay_egg = function(self)
	if self.eggs_count >= petz.settings.max_laid_eggs then
		return
	end
	if petz.isinliquid(self) then --do not put eggs when in liquid
		return
	end
	local pos = self.object:get_pos()
	local laid_egg = false
	if self.lay_eggs == "item" or self.lay_eggs == "node" then
		local lay_egg_timing = petz.settings.lay_egg_timing
		if kitz.timer(self, math.random(lay_egg_timing - (lay_egg_timing * 0.2),
			lay_egg_timing + (lay_egg_timing * 0.2))) then
				if self.lay_eggs == "node" and kitz.is_air(pos) then
					minetest.set_node(pos, {name = "petz:"..self.type.."_egg"})
					laid_egg = true
				else
					minetest.add_item(pos, "petz:"..self.type.."_egg") --penguin egg!
					laid_egg = true
				end
		end
	elseif self.lay_eggs == "nest" then
		local lay_range = 1
		local nearby_nodes = minetest.find_nodes_in_area(
			{x = pos.x - lay_range, y = pos.y - 1, z = pos.z - lay_range},
			{x = pos.x + lay_range, y = pos.y + 1, z = pos.z + lay_range},
			"petz:ducky_nest")
		if #nearby_nodes > 1 then
			local nest_type
			if self.type == "hen" then
				nest_type = "chicken"
			else
				nest_type = "ducky"
			end
			local nest_to_lay = nearby_nodes[math.random(1, #nearby_nodes)]
			minetest.set_node(nest_to_lay, {name= "petz:"..nest_type.."_nest_egg"})
			laid_egg = true
		end
	end
	if laid_egg then
		petz.increase_egg_count(self)
	end
end

--Extract Egg from a Nest
petz.extract_egg_from_nest = function(pos, player, itemstack, egg_type)
	local inv = player:get_inventory()
	if inv:room_for_item("main", egg_type) then
		if ((itemstack:get_name() == egg_type) and not(itemstack:get_count() >= itemstack:get_stack_max()))
			or (itemstack:get_name() == "") then
				itemstack:add_item(egg_type)
		else
			inv:add_item("main", egg_type) --add the egg to the player's inventory
		end
		minetest.set_node(pos, {name= "petz:ducky_nest"}) --Replace the node to a empty nest
	else
		minetest.chat_send_player(player:get_player_name(), "No room in your inventory for the egg.")
	end
	return itemstack
end
