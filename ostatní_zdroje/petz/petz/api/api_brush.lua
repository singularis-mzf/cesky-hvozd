local S = ...

petz.brush = function(self, wielded_item_name, pet_name)
    if petz.settings.tamagochi_mode then
        if wielded_item_name == "petz:hairbrush" then
            if not self.brushed then
                petz.set_affinity(self, petz.settings.tamagochi_brush_rate)
                self.brushed = true
                kitz.remember(self, "brushed", self.brushed)
            else
                minetest.chat_send_player(self.owner, S("Your").." "..S(pet_name).." "..S("had already been brushed."))
            end
        else --it's beaver_oil
            if not self.beaver_oil_applied then
                petz.set_affinity(self, petz.settings.tamagochi_beaver_oil_rate)
                self.beaver_oil_applied = true
                kitz.remember(self, "beaver_oil_applied", self.beaver_oil_applied)
            else
                minetest.chat_send_player(self.owner, S("Your").." "..S(pet_name).." "..S("had already been spreaded with beaver oil."))
            end
        end
    end
    kitz.make_sound("object", self.object, "petz_brushing", petz.settings.max_hear_distance)
    petz.do_particles_effect(self.object, self.object:get_pos(), "star")
end
