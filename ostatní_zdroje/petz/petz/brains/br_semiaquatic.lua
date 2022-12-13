--
-- SEMIAQUATIC BRAIN
--

function petz.semiaquatic_brain(self)

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

	if not(petz.isinliquid(self)) then
		petz.check_ground_suffocation(self, pos)
	end

	if kitz.timer(self, 1) then

		local prty = kitz.get_queue_priority(self)
		local player = kitz.get_nearby_player(self)

		--if prty < 100 then
			--if petz.isinliquid(self) then
				--kitz.hq_liquid_recovery(self, 100)
			--end
		--end

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

		-- hunt a prey (frogs)
		if prty < 12 then -- if not busy with anything important
			 petz.bh_hunt(self, 12, false)
		end

		if prty < 10 then
			if player then
				if not(self.tamed) or (self.tamed and self.status == "guard" and player:get_player_name() ~= self.owner) then
					local player_pos = player:get_pos()
					if vector.distance(pos, player_pos) <= self.view_range then -- if player close
						if self.warn_attack then --attack player
							kitz.clear_queue_high(self) -- abandon whatever they've been doing
							if petz.isinliquid(self) then
								kitz.hq_aqua_attack(self, 10, player, 6) -- get revenge
							else
								petz.hq_hunt(self, 10, player)
							end
						end
					end
				end
			end
		end

		if prty < 8 then
			if (self.can_jump) and not(self.status) then
				local random_number = math.random(1, self.jump_ratio)
				if random_number == 1 then
					--minetest.chat_send_player("singleplayer", "jump")
					kitz.clear_queue_high(self)
					petz.hq_terrestial_jump(self, 8)
				end
			end
		end

		if prty < 6 then
			petz.bh_replace(self)
		end

		-- Default Random Sound
		kitz.make_misc_sound(self, petz.settings.misc_sound_chance, petz.settings.max_hear_distance)

		if self.petz_type == "beaver" then --beaver's dam
			petz.create_dam(self, pos)
		end

		--if prty < 5 then
			--local swin_again = math.random(1, 5)
			--if swin_again <= 1 and not self.isinliquid then
				--if petz.hq_liquid_search(self, 5) then
					--return
				--end
			--end
		--end

		--Roam default
		if kitz.is_queue_empty_high(self) and not(self.status) then
			if self.isinliquid then
				kitz.hq_aqua_roam(self, 0, self.max_speed/3)
			else
				kitz.hq_roam(self, 0)
			end
		end
	end
end
