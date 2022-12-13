---
--- Bee Behaviours
---

function petz.bh_create_beehive(self, pos)
	if not self.create_beehive then
		return false
	end
	local node_name = petz.node_name_in(self, "front")
	if minetest.get_item_group(node_name, "wood") > 0 or minetest.get_item_group(node_name, "leaves") > 0 then
		local minp = {
			x = pos.x - (self.max_height*4),
			y = pos.y - self.max_height,
			z = pos.z - (self.max_height*4),
		}
		local maxp = {
			x = pos.x + (self.max_height*4),
			y = pos.y + self.max_height,
			z = pos.z + (self.max_height*4),
		}
		if #minetest.find_nodes_in_area(minp, maxp, {"petz:beehive"}) < 1 then
			minetest.set_node(pos, {name= "petz:beehive"})
			kitz.remove_mob(self)
			return true
		else
			return false
		end
	else
		return false
	end
end

function petz.hq_gotopollen(self, prty, tpos)
	local func = function()
		if self.pollen then
			--kitz.clear_queue_low(self)
			--kitz.clear_queue_high(self)
			return true
		end
		kitz.animate(self, "fly")
		petz.lq_search_flower(self, tpos)
	end
	kitz.queue_high(self, func, prty)
end

function petz.lq_search_flower(self, tpos)
	local func = function()
		local pos = self.object:get_pos()
		if not(pos) or not(tpos) then
			return true
		end
		local y_distance = tpos.y - pos.y
		local abs_y_distance = math.abs(y_distance)
		if (abs_y_distance > 1) and (abs_y_distance < self.view_range) then
			petz.set_velocity(self, {x= 0.0, y= y_distance, z= 0.0})
		end
		if kitz.drive_to_pos(self, tpos, 1.5, 6.28, 0.5) then
			self.pollen = true
			petz.do_particles_effect(self.object, self.object:get_pos(), "pollen")
			return true
		end
	end
	kitz.queue_low(self, func)
end

function petz.hq_gotobeehive(self, prty, pos)
	local func = function()
		if not(self.pollen) or not(self.beehive) then
			return true
		end
		kitz.animate(self, "fly")
		petz.lq_search_beehive(self)
	end
	kitz.queue_high(self, func, prty)
end

function petz.lq_search_beehive(self)
	local func = function()
		local tpos
		if self.beehive then
			tpos = self.beehive
		else
			return true
		end
		local pos = self.object:get_pos()
		local y_distance = tpos.y - pos.y
		local abs_y_distance = math.abs(y_distance)
		if (abs_y_distance > 1) and (abs_y_distance < self.view_range) then
			petz.set_velocity(self, {x= 0.0, y= y_distance, z= 0.0})
		end
		if kitz.drive_to_pos(self, tpos, 1.5, 6.28, 1.01)  then
				if petz.beehive_exists(self) then
					kitz.remove_mob(self)
					local meta, honey_count, bee_count = petz.get_beehive_stats(self.beehive)
					bee_count = bee_count + 1
					meta:set_int("bee_count", bee_count)
					honey_count = honey_count + 1
					meta:set_int("honey_count", honey_count)
					petz.set_infotext_beehive(meta, honey_count, bee_count)
					self.pollen = false
				end
		end
	end
	kitz.queue_low(self, func)
end

function petz.hq_approach_beehive(self, pos, prty)
	local func = function()
		if math.abs(pos.x - self.beehive.x) <= (self.view_range / 2)
			or math.abs(pos.z - self.beehive.z) <= (self.view_range / 2) then
				kitz.clear_queue_low(self)
				kitz.clear_queue_high(self)
				return true
		end
		petz.lq_approach_beehive(self)
	end
	kitz.queue_high(self, func, prty)
end

function petz.lq_approach_beehive(self)
	local func = function()
		local tpos
		if self.beehive then
			tpos = self.beehive
		else
			return true
		end
		--local y_distance = tpos.y - pos.y
		if kitz.drive_to_pos(self, tpos, 1.5, 6.28, (self.view_range / 4) ) then
			kitz.clear_queue_high(self)
			return true
		end
	end
	kitz.queue_low(self, func)
end
