--
--Poop Engine
--

petz.poop = function(self, pos)
	if not(petz.settings.poop) or not(self.tamed) or not(self.poop) or
		self.child or petz.is_jumping(self) or not(petz.is_standing(self))
			or math.random(1, petz.settings.poop_rate) > 1 then
				return
	end
	--minetest.chat_send_player("singleplayer", node_name)
	local stand_node = minetest.get_node_or_nil(self.stand_pos)
	local below_pos = vector.new(self.stand_pos.x, self.stand_pos.y - 1, self.stand_pos.z)
	local node_below = minetest.get_node_or_nil(below_pos)
	if stand_node.name == "air" and node_below.name ~= "air" then
		minetest.set_node(self.stand_pos, {name = "petz:poop"})
	end
end
