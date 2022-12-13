--
-- AQUATIC BRAIN
--

function petz.aquatic_brain(self)

	local pos = self.object:get_pos()

	kitz.vitals(self)

	-- Die Behaviour

	if self.hp <= 0 then
		petz.on_die(self)
		return
	elseif not(petz.is_night()) and self.die_at_daylight then --it dies when sun rises up
		if minetest.get_node_light(pos, minetest.get_timeofday()) >= self.max_daylight_level then
			petz.on_die(self)
			return
		end
	end

	petz.check_ground_suffocation(self, pos)

	if kitz.timer(self, 1) then

		if not(self.is_mammal) and not(petz.isinliquid(self)) then --if not mammal, air suffocation
			kitz.hurt(self, petz.settings.air_damage)
		end

		local prty = kitz.get_queue_priority(self)
		local player = kitz.get_nearby_player(self)

		--Follow Behaviour
		if prty < 16 then
			if petz.bh_start_follow(self, pos, player, 16) then
				return
			end
		end

		if prty == 16 then
			if petz.bh_stop_follow(self, player) then
				return
			end
		end

		if prty < 10 then
			if player and self.attack_player then
				if petz.bh_attack_player(self, pos, 10, player) then
					return
				end
			end
		end

		if prty < 8 then
			if (self.can_jump) and not(self.status== "jump") and (kitz.is_in_deep(self)) then
				local random_number = math.random(1, 25)
				if random_number == 1 then
					if petz.can_jump(self, pos) then
						--minetest.chat_send_player("singleplayer", "jump")
						kitz.clear_queue_high(self)
						petz.hq_aqua_jump(self, 8)
					end
				end
			end
		end

		-- Default Random Sound
		kitz.make_misc_sound(self, petz.settings.misc_sound_chance, petz.settings.max_hear_distance)

		--Roam default
		if kitz.is_queue_empty_high(self) and not(self.status) and not(self.status== "jump") then
			if self.isinliquid then
				kitz.hq_aqua_roam(self, 0, self.max_speed)
			end
		end
	end
end
