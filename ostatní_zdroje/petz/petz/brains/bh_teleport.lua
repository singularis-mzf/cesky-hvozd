--
-- Teleport Behaviour
--

function petz.bh_teleport(self, pos, player, player_pos)
	local node, back_pos = petz.get_player_back_pos(player, player_pos)
	if node and node == "air" then
		petz.do_particles_effect(self.object, self.object:get_pos(), "pumpkin")
		self.object:set_pos(back_pos)
		kitz.make_sound(self, 'laugh')
	end
end
