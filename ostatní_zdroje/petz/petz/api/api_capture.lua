local S = ...

--
-- Register Egg
--

petz.create_pet = function(placer, itemstack, pet_name, pos)
	local meta = itemstack:get_meta()
	local staticdata = meta:get_string("staticdata")
	local static_data_table = minetest.deserialize(staticdata)
	if static_data_table and static_data_table["memory"] --if dead then..
		and static_data_table["memory"]["dead"] then
			local player_name = placer:get_player_name()
			if player_name then
				minetest.chat_send_player(player_name, S("Failed placement: The animal was dead!"))
			end
			itemstack:take_item()
			return nil
	end
	local mob = minetest.add_entity(pos, pet_name, staticdata)
	if mob then
		local self = mob:get_luaentity()
		if not(self.is_wild) and not(self.owner) then --not monster and not owner
			kitz.set_owner(self, placer:get_player_name()) --set owner
			petz.after_tame(self)
		end
		itemstack:take_item() --since mob is unique we remove egg once spawned
		return self
	else
		return nil
	end
end

function petz:register_egg(pet_name, desc, inv_img, tamed)
	local description = S("@1", desc)
	if tamed then
		description = description .." ("..S("Tamed")..")"
	end
	minetest.register_craftitem(pet_name .. "_set", { -- register new spawn egg containing mob information
		description = description,
		inventory_image = inv_img,
		groups = {spawn_egg = 2},
		stack_max = 1,
		on_place = function(itemstack, placer, pointed_thing)
			local spawn_pos = pointed_thing.above
			-- am I clicking on something with existing on_rightclick function?
			local under = minetest.get_node(pointed_thing.under)
			local def = minetest.registered_nodes[under.name]
			if def and def.on_rightclick then
				return def.on_rightclick(pointed_thing.under, under, placer, itemstack)
			end
			if spawn_pos and not minetest.is_protected(spawn_pos, placer:get_player_name()) then
				if not minetest.registered_entities[pet_name] then
					return
				end
				spawn_pos = petz.pos_to_spawn(pet_name, spawn_pos)
				petz.create_pet(placer, itemstack, pet_name, spawn_pos)
			end
			return itemstack
		end,
	})
end

petz.check_capture_items = function(self, wielded_item_name, clicker, check_inv_room)
	if self.driver then
		return
	end
	local capture_item_type
	if wielded_item_name == petz.settings.lasso then
		capture_item_type = "lasso"
	elseif (wielded_item_name == "mobs:net") or (wielded_item_name == "fireflies:bug_net")
		or (wielded_item_name == "petz:net") then
			capture_item_type = "net"
	else
		return false
	end
	if capture_item_type == self.capture_item then
		if check_inv_room then
			--check for room in inventory
			local inv = clicker:get_inventory()
			if inv:room_for_item("main", ItemStack("air")) then
				return true
			else
				minetest.chat_send_player(clicker:get_player_name(), S("No room in your inventory to capture it."))
				return false
			end
		else
			return true
		end
	else
		return false
	end
end

petz.capture = function(self, clicker, put_in_inventory)

	local ent = self.object:get_luaentity()
	local staticdata = ent:get_staticdata(self)
	local static_data_table = minetest.deserialize(staticdata)

	if static_data_table and static_data_table["memory"] --if dead then..
		and static_data_table["memory"]["dead"] then
			local player_name = clicker:get_player_name()
			if player_name then
				minetest.chat_send_player(player_name, S("Failed capture: The animal is dead!"))
			end
			return
	end

	self.captured = kitz.remember(self, "captured", true) --IMPORTANT! mark as captured

	local new_stack = ItemStack(self.name .. "_set") 	-- add special mob egg with all mob information
	local stack_meta = new_stack:get_meta()

	--Save the staticdata into the ItemStack-->
	stack_meta:set_string("staticdata", staticdata)

	--Info text stuff for the ItemStack
	local info_text = ""
	if not(petz.str_is_empty(self.tag)) then
		info_text = info_text.."\n"..S("Name")..": "..self.tag
	end
	if self.breed then
		local genre
		if self.is_male then
			genre = "Male"
		else
			genre = "Female"
		end
		info_text = info_text.."\n"..S("Gender")..": "..S(genre)
	end
	if self.skin_colors then
		info_text = info_text.."\n"..S("Color")..": "..S(petz.first_to_upper(self.skin_colors[self.texture_no]))
	end
	if self.is_mountable then
		info_text = info_text.."\n"..S("Speed Stats")..": " ..self.max_speed_forward.."/"..self.max_speed_reverse.."/"..self.accel
	end
	if self.is_pregnant then
		info_text = info_text.."\n"..S("It is pregnant")
	end
	local description
	if self.description then
		description = self.description
	else
		description = self.type
	end
	stack_meta:set_string("description", S(petz.first_to_upper(description)).." ("..S("Tamed")..")"..info_text)
	if put_in_inventory then
		local inv = clicker:get_inventory()
		if inv:room_for_item("main", new_stack) then
			inv:add_item("main", new_stack)
		else
			minetest.add_item(clicker:get_pos(), new_stack)
		end
	end
	if self.type == "bee" and self.beehive then
		petz.decrease_total_bee_count(self.beehive)
		local meta, honey_count, bee_count = petz.get_beehive_stats(self.beehive)
		petz.set_infotext_beehive(meta, honey_count, bee_count)
	end
	petz.remove_tamed_by_owner(self, false)
	kitz.remove_mob(self)
	return stack_meta
end
