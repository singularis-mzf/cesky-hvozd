--
-- FOLLOW BEHAVIOURS
-- 2 types: for terrestrial and for flying/aquatic mobs.

--
-- Follow behaviours for terrestrial mobs (2 functions; start & stop)
--

function petz.bh_start_follow(self, pos, player, prty)
	if player then
		local wielded_item_name = player:get_wielded_item():get_name()
		local tpos = player:get_pos()
		if kitz.item_in_itemlist(wielded_item_name, self.follow) and vector.distance(pos, tpos) <= self.view_range then
			self.status = kitz.remember(self, "status", "follow")
			if (self.can_fly) or (self.can_swin and self.isinliquid) then
				petz.hq_followliquidair(self, prty, player)
			else
				kitz.hq_follow(self, prty, player)
			end
			return true
		else
			return false
		end
	end
end

function petz.bh_stop_follow(self, player)
	if player then
		local wielded_item_name = player:get_wielded_item():get_name()
		if wielded_item_name ~= self.follow then
			petz.ownthing(self)
			return true
		else
			return false
		end
	else
		petz.ownthing(self)
	end
end

--
-- Follow Fly/Water Behaviours (2 functions: HQ & LQ)
--

function petz.hq_followliquidair(self, prty, player)
	local func=function()
		local pos = kitz.get_stand_pos(self)
		local tpos = player:get_pos()
		if self.can_swin then
			if not(petz.isinliquid(self)) then
				--check if water below, dolphins
				local node_name = petz.node_name_in(self, "below")
				if minetest.get_item_group(node_name, "water") == 0  then
					petz.ownthing(self)
					return true
				end
			end
		end
		if pos and tpos then
			local distance = vector.distance(pos, tpos)
			if distance < 3 then
				return
			elseif (distance < self.view_range) then
				if kitz.is_queue_empty_low(self) then
					petz.lq_followliquidair(self, player)
				end
			elseif distance >= self.view_range then
				petz.ownthing(self)
				return true
			end
		else
			return true
		end
	end
	kitz.queue_high(self, func, prty)
end

function petz.lq_followliquidair(self, target)
	local func = function()
		petz.flyto(self, target)
		return true
	end
	kitz.queue_low(self,func)
end

function petz.flyto(self, target)
	local pos = self.object:get_pos()
	local tpos = target:get_pos()
	local tgtbox = target:get_properties().collisionbox
	local height = math.abs(tgtbox[3]) + math.abs(tgtbox[6])
	--minetest.chat_send_player("singleplayer", tostring(tpos.y))
	--minetest.chat_send_player("singleplayer", tostring(height))
	tpos.y = tpos.y + 2 * (height)
	local dir = vector.direction(pos, tpos)
	local velocity = {
		x= self.max_speed* dir.x,
		y= self.max_speed* dir.y,
		z= self.max_speed* dir.z,
	}
	local new_yaw = minetest.dir_to_yaw(dir)
	self.object:set_yaw(new_yaw)
	self.object:set_velocity(velocity)
end

function petz.follow_parents(self, pos)
	local tpos
	local ent_obj = kitz.get_closest_entity(self, self.parents[1]) -- look for the mom to join with
	if not ent_obj then
		ent_obj = kitz.get_closest_entity(self, self.parents[2]) -- look for the dad to join with
	end
	if ent_obj then
		local ent = ent_obj:get_luaentity()
		if ent then
			tpos = ent_obj:get_pos()
			local distance = vector.distance(pos, tpos)
			if distance > 5 then
				kitz.hq_goto(self, 10, tpos)
				return true
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end
