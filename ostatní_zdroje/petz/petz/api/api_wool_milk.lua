---
---Refill lamb or milk
---

local S = ...

petz.refill = function(self)
	if self.type == "lamb" then
		petz.lamb_wool_regrow(self)
	elseif self.milkable then
		petz.milk_refill(self)
	end
end

--
--Lamb Wool
--

petz.lamb_wool_regrow = function(self)
	if not self.shaved then --only count if the lamb is shaved
		return
	end
	local food_count_wool = self.food_count_wool + 1
	self.food_count_wool = kitz.remember(self, "food_count_wool", food_count_wool)
	if self.food_count_wool >= 5 then -- if lamb replaces 5x grass then it regrows wool
		self.food_count_wool = kitz.remember(self, "food_count_wool", 0)
		self.shaved = kitz.remember(self, "shaved", false)
		local lamb_texture = "petz_lamb_"..self.skin_colors[self.texture_no]..".png"
		petz.set_properties(self, {textures = {lamb_texture}})
	end
end

petz.lamb_wool_shave = function(self, clicker)
	local inv = clicker:get_inventory()
	local color
	if not(self.colorized) then
		color = self.skin_colors[self.texture_no]
	else
		color = self.colorized
		self.colorized = kitz.remember(self, "colorized", nil) --reset the color
	end
	local new_stack = "wool:".. color
	if inv:room_for_item("main", new_stack) then
		inv:add_item("main", new_stack)
	else
		minetest.add_item(self.object:get_pos(), new_stack)
	end
    kitz.make_sound("object", self.object, "petz_lamb_moaning", petz.settings.max_hear_distance)
    local lamb_texture = "petz_lamb_shaved_"..self.skin_colors[self.texture_no]..".png"
	petz.set_properties(self, {textures = {lamb_texture}})
	self.shaved = kitz.remember(self, "shaved", true)
	self.food_count_wool = kitz.remember(self, "food_count_wool", 0)
	petz.bh_afraid(self, clicker:get_pos())
	kitz.make_sound("object", self.object, "petz_pop_sound", petz.settings.max_hear_distance)
end

---
--Calf Milk
---

petz.milk_refill = function(self)
	if self.food_count >= 5 then -- if calf replaces 5x grass then it refill milk
		self.milked = kitz.remember(self, "milked", false)
	end
end

petz.milk_milk = function(self, clicker)
	if self.is_male then
		minetest.chat_send_player(clicker:get_player_name(), S("Milk only female animals!"))
		return
	elseif self.is_baby then
		minetest.chat_send_player(clicker:get_player_name(), S("You cannot milk babies!"))
		return
	end
	local inv = clicker:get_inventory()
	local wielded_item = clicker:get_wielded_item()
	wielded_item:take_item()
	clicker:set_wielded_item(wielded_item)
	if inv:room_for_item("main", "petz:bucket_milk") then
		inv:add_item("main","petz:bucket_milk")
		kitz.make_sound("object", self.object, "petz_"..self.type.."_moaning", petz.settings.max_hear_distance)
	else
		minetest.add_item(self.object:get_pos(), "petz:bucket_milk")
	end
	self.milked = kitz.remember(self, "milked", true)
end

---
--Cut or put a feather
---
petz.pluck = function(self, clicker)
	local inv = clicker:get_inventory()
	local item_stack= "petz:ducky_feather"
	if inv:room_for_item("main", item_stack) then
		inv:add_item("main", item_stack)
	else
		minetest.add_item(self.object:get_pos(), item_stack)
	end
    kitz.make_sound("object", self.object, "petz_"..self.type.."_moaning", petz.settings.max_hear_distance)
    self.plucked = kitz.remember(self, "plucked", true)
	petz.bh_afraid(self, clicker:get_pos())
	if self.can_fly and not(self.status) then
		self.status = kitz.remember(self, "status", "alight")
		petz.alight(self, 0, nil)
	end
end

petz.feather = function(self, clicker)
	local inv = clicker:get_inventory()
	inv:remove_item("main", "petz:ducky_feather")
	kitz.make_sound("object", self.object, "petz_"..self.type.."_moaning", petz.settings.max_hear_distance)
    self.plucked = kitz.remember(self, "plucked", false)
end
