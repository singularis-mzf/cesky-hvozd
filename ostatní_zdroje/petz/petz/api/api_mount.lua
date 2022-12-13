--
-- Mount Engine
--

petz.mount = function(self, clicker, wielded_item, wielded_item_name)
	if clicker:is_player() then
		local player_pressed_keys = clicker:get_player_control()
		if player_pressed_keys["sneak"] then
			return true
		end
	end
	if self.tamed and self.owner == clicker:get_player_name() then
		if self.driver and clicker == self.driver then -- detatch player already riding horse
			petz.detach(clicker, {x = 1, y = 0, z = 1})
			if self.wagon then
				petz.animate_wagon(self, "stand")
			end
			kitz.clear_queue_low(self)
			kitz.clear_queue_high(self)
			kitz.animate(self, "still")
			return false
		elseif (self.saddle or self.saddlebag or self.wagon) and wielded_item_name == petz.settings.shears then
			if self.wagon then
				self.wagon:remove()
				kitz.drop_item(self, ItemStack("petz:wagon 1"))
				self.wagon = nil
			end
			petz.free_saddles(self)
			petz.set_properties(self, {textures = {"petz_"..self.type.."_"..self.skin_colors[self.texture_no]..".png"}})
			return false
		elseif (not(self.driver) and not(self.is_baby)) and ((wielded_item_name == "petz:saddle") or (wielded_item_name == "petz:saddlebag")) then -- Put on saddle if tamed
			local put_saddle = false
			if wielded_item_name == "petz:saddle" and not(self.saddle) then
				put_saddle = true
			elseif wielded_item_name == "petz:saddlebag" and not(self.saddlebag) and not(self.type == "pony") then
				put_saddle = true
			end
			if put_saddle then
				petz.put_saddle(self, clicker, wielded_item, wielded_item_name)
				return false
			end
		elseif not(self.driver) and (self.saddle or self.wagon) then -- Mount petz
			petz.set_properties(self, {stepheight = 1.1})
			petz.attach(self, clicker)
			return false
		else
			return true
		end
	else
		return true
	end
end

petz.put_saddle = function(self, clicker, wielded_item, wielded_item_name)
	local saddle_type
	local another_saddle = ""
	if wielded_item_name == "petz:saddle" then
		saddle_type = "saddle"
		self.saddle = true
		kitz.remember(self, "saddle", self.saddle)
		if self.saddlebag then
			another_saddle = "^petz_"..self.type.."_saddlebag.png"
		end
	else
		saddle_type = "saddlebag"
		self.saddlebag = true
		kitz.remember(self, "saddlebag", self.saddlebag)
		if self.saddle then
			another_saddle = "^petz_"..self.type.."_saddle.png"
		end
	end
	local texture = "petz_"..self.type.."_"..self.skin_colors[self.texture_no]..".png"
		.. "^petz_"..self.type.."_"..saddle_type..".png"..another_saddle
	petz.set_properties(self, {textures = {texture}})
	wielded_item:take_item()
	clicker:set_wielded_item(wielded_item)
	kitz.make_sound("object", self.object, "petz_put_sound", petz.settings.max_hear_distance)
end
