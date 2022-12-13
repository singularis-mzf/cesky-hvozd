local modpath = ...

---
--- Ant Behaviours
---

function petz.bh_create_anthill(self, pos)
	--Do anthill close to coasts (to avoid mountains)
	if not self.create_anthill or pos.y > 8 then
		return false
	end
	local node_name, pos_below = petz.node_name_in(self, "below")
	if not(node_name) or not(pos_below) then
		return false
	end
	if minetest.is_protected(pos_below, "") then --check for a non-protected node
		return false
	end
	--Only construct on 'soil' or 'sand' nodes
	if minetest.get_item_group(node_name, "soil") > 0 or minetest.get_item_group(node_name, "sand") > 0 then
		local minp = {
			x = pos.x - 50,
			y = pos.y - 50,
			z = pos.z - 50,
		}
		local maxp = {
			x = pos.x + 50,
			y = pos.y + 50,
			z = pos.z + 50,
		}
		if #minetest.find_nodes_in_area(minp, maxp, {"petz:antbed"}) < 1 then
			minetest.place_schematic({x = pos.x-6, y = pos.y-25, z = pos.z-6}, modpath.."/schematics/petz_anthill.mts", "0", nil, true)
			 --replace the entrance node to the same to trigger the on_construct event of the node (because is not triggered for schematics)-->
			local node_entrance, pos_entrance = petz.node_name_in(self, "below")
			if node_entrance == "petz:anthill_entrance" then
				minetest.set_node(pos_entrance, {name = node_entrance})
			end
			self.anthill_founded = kitz.remember(self, "anthill_founded", true) --Mark the foundation
			pos.y = pos.y - 24 --y offset for place the queen inside the anthill
			self.object:move_to(pos) --place the queen
			return true
		else
			return false
		end
	else
		return false
	end
end

function petz.bh_lay_antegg(self, pos)
	if self.eggs_count >= petz.settings.max_laid_anteggs then --the limit for laying eggs
		return
	end
	--Lay in front (air node) and above a Ant Bed Node
	local node_name_front, egg_pos = petz.node_name_in(self, "front")
	local node_name_front_below = petz.node_name_in(self, "front_below")
	if egg_pos and node_name_front == "air" and node_name_front_below == "petz:antbed" then
		minetest.place_node(egg_pos, {name="petz:antegg"})
		petz.increase_egg_count(self)
		return true
	else
		return false
	end
end
