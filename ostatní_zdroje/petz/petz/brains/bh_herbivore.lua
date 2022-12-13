function petz.hq_terrestial_jump(self, prty)
	--Check igf not water or air (cliff)
	local node_name = petz.node_name_in(self, "front_below")
	if not(node_name) or minetest.registered_nodes[node_name]["liquidtype"] == "source" or
		minetest.registered_nodes[node_name]["liquidtype"] == "flowing" or
			node_name == "air" then
				return
	end
	local func = function()
		local velocity = {
			x = self.max_speed * (self.jump_impulse/3),
			y = self.max_speed * self.jump_impulse,
			z = self.max_speed * (self.jump_impulse/3),
		}
		petz.set_velocity(self, velocity)
		kitz.animate(self, 'jump')
		self.object:set_acceleration({x=1.0, y=self.jump_impulse, z=1.0})
		self.status = "jump"
		kitz.animate(self, 'fly')
		--kitz.make_sound("object", self.object, "petz_splash", petz.settings.max_hear_distance)
		minetest.after(0.5, function()
			if kitz.is_alive(self.object) then
				self.status = nil
				kitz.clear_queue_high(self)
			end
		end, self, velocity)
		return true
	end
	kitz.queue_high(self, func, prty)
end
