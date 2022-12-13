petz.ownthing = function(self)
	self.status = kitz.remember(self, "status", nil)
	if self.can_fly then
		petz.hq_wanderfly(self, 0)
	elseif self.can_swin and self.isinliquid then
		kitz.hq_aqua_roam(self, 0, self.max_speed)
	else
		kitz.hq_roam(self, 0)
	end
	kitz.clear_queue_low(self)
	kitz.clear_queue_high(self)
end

petz.stand = function(self)
	self.object:set_velocity({ x = 0, y = 0, z = 0 })
	self.object:set_acceleration({ x = 0, y = 0, z = 0 })
end

petz.standhere = function(self)
	kitz.clear_queue_high(self)
	kitz.clear_queue_low(self)
	if self.can_fly then
		if petz.node_name_in(self, "below") == "air" then
			kitz.animate(self, "fly")
		else
			kitz.animate(self, "stand")
		end
	elseif self.can_swin and petz.isinliquid(self) then
		kitz.animate(self, "def")
	else
		if self.animation["sit"] and not(petz.isinliquid(self)) then
			kitz.animate(self, "sit")
		else
			kitz.animate(self, "stand")
		end
	end
	self.status = kitz.remember(self, "status", "stand")
	--kitz.lq_idle(self, 2400)
	petz.stand(self)
end

petz.guard = function(self)
	self.status = kitz.remember(self, "status", "guard")
	kitz.clear_queue_high(self)
	petz.stand(self)
end

petz.follow = function(self, player)
	kitz.clear_queue_low(self)
	kitz.clear_queue_high(self)
	self.status = kitz.remember(self, "status", "follow")
	if self.can_fly then
		kitz.animate(self, "fly")
		petz.hq_followliquidair(self, 100, player)
	elseif self.can_swin and self.isinliquid then
		kitz.animate(self, "def")
		petz.hq_followliquidair(self, 100, player)
	else
		kitz.hq_follow(self, 100, player)
	end
end
