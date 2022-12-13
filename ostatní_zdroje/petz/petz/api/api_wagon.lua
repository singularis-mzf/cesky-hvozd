--
--Wagon API
--

petz.put_wagon = function(self, clicker)
	if self.wagon then --already a put wagon
		return
	end
	local pos = self.object:get_pos()
	local rotation = self.object:get_rotation()
	local wagon_obj = minetest.add_entity(pos, "petz:wagon", nil)
	wagon_obj:set_attach(self.object, "", {x = 0, y = 0.0, z = 0}, rotation)
	kitz.make_sound("object", self.object, "petz_pop_sound", petz.settings.max_hear_distance)
	wagon_obj:set_properties({
		visual_size = {
				x =1,
				y = 1,
		},
	})
	self.wagon = wagon_obj
	local wielded_item = clicker:get_wielded_item()
	wielded_item:take_item()
	clicker:set_wielded_item(wielded_item)
end
