function petz.bh_hunt(self, prty, force)
	if self.tamed and not(force) then
		return
	end
	local preys_list = petz.settings[self.type.."_preys"]
	if preys_list then
		preys_list = petz.str_remove_spaces(preys_list)
		local preys = string.split(preys_list, ',')
		for i = 1, #preys  do --loop  thru all preys
			--minetest.chat_send_player("singleplayer", "preys list="..preys[i])
			--minetest.chat_send_player("singleplayer", "node name="..node.name)
			local prey = kitz.get_closest_entity(self, preys[i])	-- look for prey
			if prey then
				--minetest.chat_send_player("singleplayer", "got it")
				petz.hq_hunt(self, prty, prey) -- and chase it
				return
			end
		end
	end
end
