-- SECURITY

local area_type_private , area_type_reserved

if minetest.get_modpath("areas") then
	area_type_private = areas.area_types_name_to_number.private
	area_type_reserved = areas.area_types_name_to_number.reserved
end

-- Bloky, které smějí nové postavy umísťovat i v sektorech hlubinné těžby:
local allowed_nodes = {
	["default:ladder_wood"] = 1,
	["default:ladder_steel"] = 1,
}

-- Bloky, které nové postavy nesmějí umísťovat vůbec:
local dangerous_nodes = {
	["default:lava_source"] = 1,
	["tnt:tnt"] = 1,
}

-- "O"(owner)/"I"(intruder) + player_name + "/" + area_id => {count, timestamp}
local message_counters = {}

local function try_send_message(owner_intruder, player_name, area_id, message)
	local is_online
	local now = minetest.get_us_time()
	local counter_key = owner_intruder..player_name.."/"..area_id
	local counter = message_counters[counter_key]

	if ch_core.online_charinfo[player_name] then
		is_online = true
	else
		is_online = false
	end

	if counter then
		local was_online, old_timestamp = counter.was_online, counter.timestamp
		counter.count = counter.count + 1
		counter.timestamp = now
		counter.was_online = is_online
		if was_online == is_online and now - old_timestamp < 300000000 then -- 300000000 = 5 minut
			if counter.count < counter.next_message then
				return false -- don't spam too often
			end
			counter.next_message = counter.next_message + counter.next_interval
			counter.next_interval = 2 * counter.next_interval
		end
	else
		counter = {count = 1, next_message = 2, next_interval = 2, timestamp = now, was_online = is_online}
		message_counters[counter_key] = counter
	end
	message = message.." (počítadlo = "..counter.count..")"
	if is_online then
		ch_core.systemovy_kanal(player_name, message)
	else
		minetest.log("warning", "Varovani pro "..player_name..": "..message)
	end
	return true
end

local function on_placenode(pos, newnode, placer, oldnode, itemstack, pointed_thing)

	if placer == nil or not placer:is_player() then
		minetest.log("warning", "on_placenode: placer at "..minetest.pos_to_string(pos).." is not a player!")
		return
	end
	minetest.log("warning", "on_placenode called at "..minetest.pos_to_string(pos))

	local player_name = placer:get_player_name()

	if not minetest.check_player_privs(placer, "ch_registered_player") then
		-- non-registered player:
		if dangerous_nodes[newnode.name] then
			ch_core.systemovy_kanal(player_name, "Nové postavy nesmějí umísťovat tento typ bloku, protože je klasifikován jako nebezpečný.")
			minetest.log("warning", "New character "..player_name.." tried to place a dangerous node "..newnode.name.." at "..minetest.pos_to_string(pos).." instead of "..oldnode.name)
			minetest.swap_node(pos, oldnode)
			return
		elseif pos.y < -1990 and not allowed_nodes[newnode.name] then
			ch_core.systemovy_kanal(player_name, "Nové postavy smějí v sektorech hlubinné těžby umísťovat jen výsuvné žebříky! Těžit zde smíte při dodržení pravidel daného sektoru bez dalších omezení.")
			minetest.log("warning", "New character "..player_name.." tried to place "..newnode.name.." at "..minetest.pos_to_string(pos).." instead of "..oldnode.name.." which was not allowed.")
			minetest.swap_node(pos, oldnode)
			return
		end
	end

	if minetest.get_modpath("areas") then
		local main_area_id, main_area_def = areas:getMainAreaAtPos(pos)
		if main_area_def then
			local is_owner = main_area_def.owner == player_name
			if not is_owner then
				local owner_viewname = ch_core.prihlasovaci_na_zobrazovaci(main_area_def.owner)
				local intruder_viewname = ch_core.prihlasovaci_na_zobrazovaci(player_name)
				if main_area_def.type == area_type_private then
					-- private area
					try_send_message("I", player_name, main_area_id, "Tato oblast patří postavě jménem '"..owner_viewname.."'. Než zde budete stavět, měl/a byste se s ní domluvit. Pokud jste se již domluvil/a, je to v pořádku a tuto zprávu můžete ignorovat.")
					try_send_message("O", main_area_def.owner, main_area_id, "Postava "..intruder_viewname.." umístila blok typu "..newnode.name.." ve Vaší soukromé oblasti na pozici "..minetest.pos_to_string(pos))
				elseif main_area_def.type == area_type_reserved and not minetest.check_player_privs(placer, "ch_trustful_player") then
					-- reserved area
					local owner_viewname = ch_core.prihlasovaci_na_zobrazovaci(main_area_def.owner)
					try_send_message("I", player_name, main_area_id, "Tato oblast je rezervovaná. Než zde budete stavět, měl/a byste se domluvit s postavou jménem '"..owner_viewname.."'. Pokud jste se již domluvil/a, je to v pořádku a tuto zprávu můžete ignorovat.")
					try_send_message("O", main_area_def.owner, main_area_id, "Postava "..intruder_viewname.." umístila blok typu "..newnode.name.." v rezervované oblasti na pozici "..minetest.pos_to_string(pos))
				end
			end
		end
	end
end

local function on_dignode(pos, oldnode, digger)
	if not digger or not digger.get_player_name or (digger:get_player_name() or "") == "" then
		minetest.log("on_dignode called with an invalid digger")
		return
	end
	if minetest.get_modpath("areas") then
		local player_name = digger:get_player_name()
		local main_area_id, main_area_def = areas:getMainAreaAtPos(pos)
		if main_area_def then
			local is_owner = main_area_def.owner == player_name
			if not is_owner then
				local owner_viewname = ch_core.prihlasovaci_na_zobrazovaci(main_area_def.owner)
				local intruder_viewname = ch_core.prihlasovaci_na_zobrazovaci(player_name)
				if main_area_def.type == area_type_private then
					-- private area
					try_send_message("I", player_name, main_area_id, "Tato oblast patří postavě jménem '"..owner_viewname.."'. Než zde budete těžit, měl/a byste se s ní domluvit. Pokud jste se již domluvil/a, je to v pořádku a tuto zprávu můžete ignorovat.")
					try_send_message("O", main_area_def.owner, main_area_id, "Postava "..intruder_viewname.." vytěžila blok typu "..oldnode.name.." ve Vaší soukromé oblasti na pozici "..minetest.pos_to_string(pos))
				elseif main_area_def.type == area_type_reserved and not minetest.check_player_privs(digger, "ch_trustful_player") then
					-- reserved area
					local owner_viewname = ch_core.prihlasovaci_na_zobrazovaci(main_area_def.owner)
					try_send_message("I", player_name, main_area_id, "Tato oblast je rezervovaná. Než zde budete těžit, měl/a byste se domluvit s postavou jménem '"..owner_viewname.."'. Pokud jste se již domluvil/a, je to v pořádku a tuto zprávu můžete ignorovat.")
					try_send_message("O", main_area_def.owner, main_area_id, "Postava "..intruder_viewname.." vytěžila blok typu "..oldnode.name.." v rezervované oblasti na pozici "..minetest.pos_to_string(pos))
				end
			end
		end
	end
end

minetest.register_on_dignode(on_dignode)
minetest.register_on_placenode(on_placenode)
