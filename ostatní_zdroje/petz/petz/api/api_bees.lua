local S = ...

petz.set_infotext_beehive = function(meta, honey_count, bee_count)
	local total_bees = meta:get_int("total_bees") or petz.settings.max_bees_beehive
	local infotext = S("Honey")..": "..tostring(honey_count).." | "..S("Bees Inside")..": "..tostring(bee_count).." | "
		..S("Total Bees")..": "..tostring(total_bees)
	if petz.settings.protect_beehive then
		local owner_name = meta:get_string("owner")
		if owner_name == "" then
			owner_name = S("Unknown")
		end
		infotext = infotext .. " | " .. S("Owner") .. ": ".. owner_name
	end
	meta:set_string("infotext", infotext)
end

petz.decrease_total_bee_count = function(pos)
	local meta = minetest.get_meta(pos)
	local total_bees = meta:get_int("total_bees") or petz.settings.max_bees_beehive
	total_bees = total_bees - 1
	meta:set_int("total_bees", total_bees)
end

petz.beehive_exists = function(self)
	local beehive_exists
	if self.beehive then
		local node = minetest.get_node_or_nil(self.beehive)
		if node and node.name == "petz:beehive" then
			beehive_exists = true
		else
			beehive_exists = false
		end
	else
		beehive_exists = false
	end
	if beehive_exists then
		return true
	else
		self.beehive = nil
		return false
	end
end

petz.get_beehive_stats = function(pos)
	if not(pos) then
		return
	end
	local meta = minetest.get_meta(pos)
	local honey_count = meta:get_int("honey_count")
	local bee_count = meta:get_int("bee_count")
	local owner = meta:get_string("owner")
	return meta, honey_count, bee_count, owner
end

petz.spawn_bee_pos = function(pos)	--Check a pos close to a beehive to spawn a bee
	local pos_1 = {
		x = pos.x - 1,
		y = pos.y - 1,
		z = pos.z - 1,
	}
	local pos_2 = {
		x = pos.x + 1,
		y = pos.y + 1,
		z = pos.z + 1,
	}
	local spawn_pos_list = minetest.find_nodes_in_area(pos_1, pos_2, {"air"})
	if #spawn_pos_list > 0 then
		return spawn_pos_list[math.random(1, #spawn_pos_list)]
	else
		return nil
	end
end

--Beehive

minetest.register_node("petz:beehive", {
	description = S("Beehive"),
	tiles = {"petz_beehive.png"},
	is_ground_content = false,
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3,
		flammable = 3, wool = 1},
	sounds = default.node_sound_defaults(),

	drop = {},

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local	drops = {
			{name = "petz:honeycomb", chance = 1, min = 1, max= 6},
		}
		meta:set_string("drops", minetest.serialize(drops))
		local timer = minetest.get_node_timer(pos)
		timer:start(2.0) -- in seconds
		local honey_count = petz.settings.initial_honey_beehive
		meta:set_int("honey_count", honey_count)
		local bee_count = petz.settings.max_bees_beehive
		meta:set_int("total_bees", bee_count)
		meta:set_int("bee_count", bee_count)
		petz.set_infotext_beehive(meta, honey_count, bee_count)
	end,

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		local honey_count
		local bee_count
		if placer:is_player() then
			honey_count = 0
			bee_count = 0
			if petz.settings.protect_beehive then
				meta:set_string("owner", placer:get_player_name())
			end
			minetest.after(petz.settings.worker_bee_delay, function()
				local node =minetest.get_node_or_nil(pos)
				if not(node and node.name == "petz:beehive") then
					return
				end
				meta = minetest.get_meta(pos)
				local total_bees = meta:get_int("total_bees") or petz.settings.max_bees_beehive
				if total_bees < petz.settings.max_bees_beehive then
					bee_count = meta:get_int("bee_count")
					bee_count = bee_count + 1
					total_bees = total_bees + 1
					meta:set_int('bee_count', bee_count)
					meta:set_int('total_bees', total_bees)
					honey_count = meta:get_int('honey_count')
					petz.set_infotext_beehive(meta, honey_count, bee_count)
				end
			end, pos)
		else
			honey_count = petz.settings.initial_honey_beehive
			bee_count = petz.settings.max_bees_beehive
		end
		meta:set_int("honey_count", honey_count)
		meta:set_int("bee_count", bee_count)
		meta:set_int("total_bees", bee_count)
		petz.set_infotext_beehive(meta, honey_count, bee_count)
	end,

	on_destruct = function(pos)
		minetest.add_entity(pos, "petz:queen_bee")
		kitz.node_drop_items(pos)
	end,

	on_timer = function(pos)
		local meta, honey_count, bee_count = petz.get_beehive_stats(pos)
		if bee_count > 0 then --if bee inside
			local tpos = {
				x = pos. x,
				y = pos.y - 4,
				z = pos.z,
			}
			local ray = minetest.raycast(pos, tpos, false, false) --check if fire/torch (igniter) below
			local igniter_below = false
			for thing in ray do
				if thing.type == "node" then
					local node_name = minetest.get_node(thing.under).name
					--minetest.chat_send_player("singleplayer", node_name)
					if minetest.get_item_group(node_name, "igniter") >0 or minetest.get_item_group(node_name, "torch") > 0 then
						igniter_below = true
						--minetest.chat_send_player("singleplayer", S("igniter"))
						break
					end
				end
			end
			local bee_outing_ratio
			if igniter_below == false then
				bee_outing_ratio = petz.settings.bee_outing_ratio
			else
				bee_outing_ratio = 1
			end
			if math.random(1, bee_outing_ratio) == 1 then --opportunitty to go out
				local spawn_bee_pos = petz.spawn_bee_pos(pos)
				if spawn_bee_pos then
					local bee = minetest.add_entity(spawn_bee_pos, "petz:bee")
					local bee_entity = bee:get_luaentity()
					bee_entity.beehive = kitz.remember(bee_entity, "beehive", pos)
					bee_count = bee_count - 1
					meta:set_int("bee_count", bee_count)
					petz.set_infotext_beehive(meta, honey_count, bee_count)
				end
			end
		end
        return true
    end,

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local wielded_item = player:get_wielded_item()
		local wielded_item_name = wielded_item:get_name()
		local meta, honey_count, bee_count = petz.get_beehive_stats(pos)
		local player_name = player:get_player_name()
		if petz.settings.protect_beehive then
			local owner_name = meta:get_string("owner")
			if not(owner_name == "") and (owner_name ~= player_name) then
				minetest.chat_send_player(player_name, S("This beehive belongs to").." "..owner_name)
				return
			end
		end
		if wielded_item_name == "vessels:glass_bottle" then
			if honey_count > 0 then
				local inv = player:get_inventory()
				if inv:room_for_item("main", "petz:honey_bottle") then
					local itemstack_name = itemstack:get_name()
					local stack = ItemStack("petz:honey_bottle 1")
					if (itemstack_name == "petz:honey_bottle" or itemstack_name == "") and (itemstack:get_count() < itemstack:get_stack_max()) then
						itemstack:add_item(stack)
					else
						inv:add_item("main", stack)
					end
					itemstack:take_item()
					honey_count = honey_count - 1
					meta:set_int("honey_count", honey_count)
					petz.set_infotext_beehive(meta, honey_count, bee_count)
					return itemstack
				else
					minetest.chat_send_player(player_name, S("No room in your inventory for the honey bottle."))
				end
			else
				minetest.chat_send_player(player_name, S("No honey in the beehive."))
			end
		elseif wielded_item_name == "petz:bee_set" then
			local total_bees = meta:get_int("total_bees") or petz.settings.max_bees_beehive
			if total_bees < petz.settings.max_bees_beehive then
				bee_count = bee_count + 1
				total_bees = total_bees + 1
				meta:set_int("bee_count", bee_count)
				meta:set_int("total_bees", total_bees)
				petz.set_infotext_beehive(meta, honey_count, bee_count)
				itemstack:take_item()
				return itemstack
			else
				minetest.chat_send_player(player_name, S("This beehive already has").." "
					..tostring(petz.settings.max_bees_beehive).." "..S("bees inside."))
			end
		end
	end,
})

minetest.register_craft({
	type = "shaped",
	output = "petz:beehive",
	recipe = {
		{"petz:honeycomb", "petz:honeycomb", "petz:honeycomb"},
		{"petz:honeycomb", "petz:queen_bee_set", "petz:honeycomb"},
		{"petz:honeycomb", "petz:honeycomb", "petz:honeycomb"},
	}
})
