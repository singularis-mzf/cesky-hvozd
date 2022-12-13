function petz.back_home(self)
	local pos = self.object:get_pos()
	local home_pos = self.home_pos
	if not home_pos then
		return
	end
	local distance = vector.distance(pos, home_pos)
	if distance <= petz.settings["back_home_distance"] then
		return
	end
	local node = minetest.get_node_or_nil(home_pos)
	local map_loaded
	if not node then
		-- Load the map at pos and try again
		--minetest.chat_send_all("manip")
		minetest.get_voxel_manip():read_from_map(home_pos, home_pos)
		node = minetest.get_node(pos)
		map_loaded = true
	end
	if not node then
		return
	end
	if node.name == "air" then
		--minetest.chat_send_all("test")
		local forceload
		if map_loaded then
			forceload = minetest.forceload_block(home_pos)
			--minetest.chat_send_all("FORCELOAD")
			if not forceload then
				--minetest.chat_send_all("NO FORCELOAD")
				return
			end
		end
		--minetest.chat_send_all("test2")
		self.object:set_pos(home_pos)
		if map_loaded then
			minetest.forceload_free_block(pos)
		end
	end
end
