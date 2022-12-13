-- BEE BRAIN
--

function petz.bee_brain(self)

	local pos = self.object:get_pos() --pos of the petz

	kitz.vitals(self)

	self.object:set_acceleration({x=0, y=0, z=0})

	local beehive_exists = petz.beehive_exists(self)
	local meta, honey_count, bee_count
	if beehive_exists then
		meta, honey_count, bee_count = petz.get_beehive_stats(self.beehive)
	end

	if (self.hp <= 0) or (not(self.queen) and not(petz.beehive_exists(self))) then
		if beehive_exists then --decrease the total bee count
			petz.decrease_total_bee_count(self.beehive)
			petz.set_infotext_beehive(meta, honey_count, bee_count)
		end
		petz.on_die(self) -- Die Behaviour
		return
	elseif (petz.is_night() and not(self.queen)) then --all the bees sleep in their beehive
		if beehive_exists then
			bee_count = bee_count + 1
			meta:set_int("bee_count", bee_count)
			if self.pollen and (honey_count < petz.settings.max_honey_beehive) then
				honey_count = honey_count + 1
				meta:set_int("honey_count", honey_count)
			end
			petz.set_infotext_beehive(meta, honey_count, bee_count)
			kitz.remove_mob(self)
			return
		end
	end

	petz.check_ground_suffocation(self, pos)

	if kitz.timer(self, 1) then

		local prty = kitz.get_queue_priority(self)

		if prty < 40 and self.isinliquid then
			kitz.hq_liquid_recovery(self, 40)
			return
		end

		local player = kitz.get_nearby_player(self)

		if prty < 30 then
			petz.env_damage(self, pos, 30) --enviromental damage: lava, fire...
		end

		--search for flowers
		if prty < 20 and beehive_exists then
			if not(self.queen) and not(self.pollen) and (honey_count < petz.settings.max_honey_beehive) then
				local view_range = self.view_range
				local nearby_flowers = minetest.find_nodes_in_area(
					{x = pos.x - view_range, y = pos.y - view_range, z = pos.z - view_range},
					{x = pos.x + view_range, y = pos.y + view_range, z = pos.z + view_range},
					{"group:flower"})
				if #nearby_flowers >= 1 then
					local tpos = 	nearby_flowers[1] --the first match
					petz.hq_gotopollen(self, 20, tpos)
					return
				end
			end
		end

		--search for the bee beehive when pollen
		if prty < 18 and beehive_exists then
			if not(self.queen) and self.pollen and (honey_count < petz.settings.max_honey_beehive) then
				if vector.distance(pos, self.beehive) <= self.view_range then
					petz.hq_gotobeehive(self, 18, pos)
					return
				end
			end
		end

		--stay close beehive
		if prty < 15 and beehive_exists then
			if not(self.queen) then
			--minetest.chat_send_player("singleplayer", "testx")
				if math.abs(pos.x - self.beehive.x) > self.view_range
					and math.abs(pos.z - self.beehive.z) > self.view_range then
						petz.hq_approach_beehive(self, pos, 15)
						return
				end
			end
		end

		if prty < 13 and self.queen then --if queen try to create a colony (beehive)
			if petz.bh_create_beehive(self, pos) then
				return
			end
		end

		if prty < 10 then
			if player then
				if petz.bh_attack_player(self, pos, 10, player) then
					return
				end
			end
		end

		-- Default Random Sound
		kitz.make_misc_sound(self, petz.settings.misc_sound_chance, petz.settings.max_hear_distance)

		--Roam default
		if kitz.is_queue_empty_high(self) and not(self.status) then
			petz.hq_wanderfly(self, 0)
		end

	end
end
