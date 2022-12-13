---
--- Semiaquatic Behaviours
---

function kitz.hq_gotoliquid(self, prty, tpos)
	local func = function(self)
		if kitz.is_queue_empty_low(self) then
			minetest.chat_send_all("nana")
			local pos = kitz.get_stand_pos(self)
			if vector.distance(pos, tpos) > 3 then
				kitz.goto_next_waypoint(self, tpos)
			else
				return true
			end
		end
	end
	kitz.queue_high(self, func, prty)
end

function petz.hq_liquid_search(self, prty) --scan for nearest liquid
	minetest.chat_send_all("lila")
	local radius = 1
	local yaw = 0
	local func = function(self)
		minetest.chat_send_all("nono")
		if self.isinliquid then
			return true
		end
		minetest.chat_send_all("lucas")
		local pos = self.object:get_pos()
		local vec = minetest.yaw_to_dir(yaw)
		local pos2 = kitz.pos_shift(pos,vector.multiply(vec,radius))
		local height, liquidflag = kitz.get_terrain_height(pos2)
		if height and not liquidflag then
			minetest.chat_send_all("cool")
			kitz.hq_gotoliquid(self, prty, pos2)
			return true
		end
	end
	kitz.queue_high(self, func, prty)
end
