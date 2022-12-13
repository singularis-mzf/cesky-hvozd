--
-- ANT BRAIN
--

function petz.ant_brain(self)

	local pos = self.object:get_pos() --pos of the petz

	kitz.vitals(self)

	if self.hp <= 0 then
		petz.on_die(self) -- Die Behaviour
		return
	end

	petz.check_ground_suffocation(self, pos)

	local timer_timing = 1

	if kitz.timer(self, timer_timing) then

		if not(self.ant_type == "queen") then --hardcoded lifetime for worker and warrior ants
			petz.lifetime_timer(self, petz.settings.lay_antegg_timing, timer_timing) --each second
		end

		local prty = kitz.get_queue_priority(self)

		if prty < 40 and self.isinliquid then
			kitz.hq_liquid_recovery(self, 40)
			return
		end

		local player = kitz.get_nearby_player(self)

		if prty < 30 then
			petz.env_damage(self, pos, 30) --enviromental damage: lava, fire...
		end

		-- hunt a prey (another queen in the case of a queen)
		if prty < 20 and self.ant_type == "queen" then
			 petz.bh_hunt(self, 20, true)
		end

		if prty < 13 and self.ant_type == "queen" and not(self.anthill_founded) then --if queen, try to create a colony (anthill)
			if kitz.timer(self, 10) then --try to create an anthill every 10 seconds
				if petz.bh_create_anthill(self, pos) then
					return
				end
			end
		end

		if prty < 10 then
			if player then
				if petz.bh_attack_player(self, pos, 10, player) then
					return
				end
			end
		end

		if prty < 8 and self.ant_type == "queen" and not(self.anthill_founded) then --if queen try to create a colony (beehive)
			if petz.bh_create_anthill(self, pos) then
				return
			end
		end

		if prty < 6 and self.lay_eggs then
			local lay_antegg_timing= petz.settings.lay_antegg_timing
			if self.eggs_count <= petz.settings.ant_population then --quick laid in the beginning
				lay_antegg_timing= lay_antegg_timing / petz.settings.ant_population
			end
			if kitz.timer(self, lay_antegg_timing) then
				petz.bh_lay_antegg(self, pos)
			end
		end

		-- Default Random Sound
		kitz.make_misc_sound(self, petz.settings.misc_sound_chance, petz.settings.max_hear_distance)

		--Roam default
		if kitz.is_queue_empty_high(self) and not(self.status) then
			kitz.hq_roam(self, 0)
		end

	end
end
