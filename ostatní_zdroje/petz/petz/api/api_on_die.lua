--
--on_die event for all the mobs
--

petz.on_die = function(self)
	if self.dead then
		return
	else
		self.dead = kitz.remember(self, "dead", true) --a variable, useful to avoid functions
	end
	local pos = self.object:get_pos()
	--Specific of each mob-->
	if self.is_mountable then
		petz.free_saddles(self)
		 --Drop horseshoes-->
		if self.horseshoes and self.horseshoes > 0 then
			kitz.drop_item(self, ItemStack("petz:horseshoe".." "..tostring(self.horseshoes)))
		end
		--If mounted, force unmount-->
		if self.driver then
			petz.force_detach(self.driver)
		end
		--If wagon, detach-->
		if self.wagon then
			self.wagon:set_detach()
		end
	elseif self.type == "puppy" then
		if self.square_ball_attached and self.attached_squared_ball then
			self.attached_squared_ball.object:set_detach()
		end
	end
	--Make it not pointable-->
	self.object:set_properties({
		pointable = false,
	})
	--Check if Dreamctacher to drop it-->
	petz.drop_dreamcatcher(self)
	--Flying mobs fall down-->
	if self.can_fly then
		self.can_fly = false
	end
	--For all the mobs-->
    local props = self.object:get_properties()
    props.collisionbox[2] = props.collisionbox[1] - 0.0625
	self.object:set_properties({collisionbox=props.collisionbox})
    --Drop Items-->
	kitz.drop_items(self, self.was_killed_by_player or nil)
	kitz.clear_queue_high(self)
	--Remove the owner entry for right_click formspec and close the formspec (it could be opened)-->
	if petz.pet[self.owner] then
		petz.pet[self.owner]= nil
		minetest.close_formspec(self.owner, "petz:form_orders")
	end
	--Remove this petz from the list of the player pets-->
	if self.tamed then
		petz.remove_tamed_by_owner(self, false)
	end
	--Make Sound-->
	kitz.make_sound(self, 'die')
	--Particles Effect
	if petz.settings.death_effect then
		minetest.add_particlespawner({
			amount = 20,
			time = 0.001,
			minpos = pos,
			maxpos = pos,
			minvel = vector.new(-2,-2,-2),
			maxvel = vector.new(2,2,2),
			minacc = {x=0, y=0, z=0},
			maxacc = {x=0, y=0, z=0},
			minexptime = 1.1,
			maxexptime = 1.5,
			minsize = 1,
			maxsize = 2,
			collisiondetection = false,
			vertical = false,
			texture = "petz_smoke.png",
		})
	end
	--To finish, the Kitz Die Function-->
	kitz.hq_die(self)
end

petz.was_killed_by_player = function(self, puncher)
	if self.hp <= 0 then
		if puncher:is_player() then
			return true
		else
			return false
		end
	else
		return false
	end
end
