petz.on_step = function(self, dtime)
	local on_step_time = 1
	if kitz.timer(self, on_step_time) and not(self.dead) then --Only check every 1 sec, not every step!
		if self.init_tamagochi_timer then
			petz.init_tamagochi_timer(self)
		end
		if self.is_pregnant then
			petz.pregnant_timer(self, on_step_time)
		elseif self.is_baby then
			petz.growth_timer(self, on_step_time)
		end
		if self.gallop then
			petz.gallop(self, on_step_time)
		end
		local lifetime = petz.check_lifetime(self)
		if lifetime then
			petz.lifetime_timer(self, lifetime, on_step_time)
		end
		if self.dreamcatcher and self.back_home then
			petz.back_home(self)
		end
		--Tamagochi
		--Check the hungry
		if petz.settings.tamagochi_mode and self.owner and self.is_pet and petz.settings.tamagochi_hungry_warning > 0 and not(self.status=="sleep") and petz.settings[self.type.."_follow"] then
			if not(self.tmp_follow_texture) then
				local items = string.split(petz.settings[self.type.."_follow"], ',')
				local item = petz.str_remove_spaces(items[1]) --the first one
				local follow_texture
				if string.sub(item, 1, 5) == "group" then
					follow_texture = "petz_pet_bowl_inv.png"
				else
					follow_texture = minetest.registered_items[item].inventory_image
				end
				self.tmp_follow_texture = follow_texture --temporary property
			end
			if kitz.timer(self, 2) then
				if (self.hp / self.max_hp) <= petz.settings.tamagochi_hungry_warning then
					petz.do_particles_effect(self.object, self.object:get_pos(), "hungry", self.tmp_follow_texture)
				end
			end
		end
	end
end
