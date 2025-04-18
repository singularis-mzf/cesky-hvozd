-- SECURITY

local area_type_private, area_type_reserved
local ifthenelse = assert(ch_core.ifthenelse)

if minetest.get_modpath("areas") then
	area_type_private = areas.area_types_name_to_number.private
	area_type_reserved = areas.area_types_name_to_number.reserved
end

ch_core.register_event_type("intrusion_for_admin", {
	access = "admin",
	description = "stavba v soukromé či rezervované zóně (pro adm.)",
	chat_access = "admin",
})
ch_core.register_event_type("intrusion_for_owner", {
	access = "player_only",
	description = "stavba ve vaší soukromé zóně",
	chat_access = "player_only",
})
ch_core.register_event_type("intrusion_for_intruder", {
	access = "discard",
	description = "varování při stavbě v cizí zóně",
	chat_access = "player_only",
})

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
	local now = minetest.get_us_time()
	local counter_key = owner_intruder..player_name.."/"..area_id
	local counter = message_counters[counter_key]
	local is_online = ifthenelse(ch_data.online_charinfo[player_name], true, false)

	if counter then
		local was_online, old_timestamp = counter.was_online, counter.timestamp
		counter.count = counter.count + 1
		counter.timestamp = now
		counter.was_online = is_online
		if was_online == is_online and now - old_timestamp < 300000000 then -- 300000000 = 5 minut
			if counter.count < counter.next_message then
				return nil -- don't spam too often
			end
			counter.next_message = counter.next_message + counter.next_interval
			counter.next_interval = 2 * counter.next_interval
		end
	else
		counter = {count = 1, next_message = 2, next_interval = 2, timestamp = now, was_online = is_online}
		message_counters[counter_key] = counter
	end
	if message ~= nil then
		message = message.." (počítadlo = "..counter.count..")"
		if is_online then
			ch_core.systemovy_kanal(player_name, message)
		else
			minetest.log("warning", "Varovani pro "..player_name..": "..message)
		end
	end
	return counter.count
end

local function on_intrusion(pos, owner, intruder, area_id, intrusion_type, place_or_dig, nodename)
	local i_count = try_send_message("I", intruder, area_id)
	local o_count = try_send_message("O", owner, area_id)
	local intruder_viewname = ch_core.prihlasovaci_na_zobrazovaci(intruder)
	local owner_viewname = ch_core.prihlasovaci_na_zobrazovaci(owner)

	if i_count ~= nil then
		-- we should send a message to the intruder
		local message
		if intrusion_type == "private" then
			message = "Tato oblast patří postavě jménem '"..owner_viewname.."'. Než zde budete stavět, měl/a byste se s ní domluvit. "..
				"Pokud jste se již domluvil/a, je to v pořádku a tuto zprávu můžete ignorovat. (počítadlo = "..i_count..")"
		else
			message = "Tato oblast je rezervovaná. Než zde budete stavět, měl/a byste se domluvit s postavou jménem '"..
				owner_viewname.."'. Pokud jste se již domluvil/a, je to v pořádku a tuto zprávu můžete ignorovat. (počítadlo = "..i_count..")"
		end
		ch_core.add_event("intrusion_for_intruder", message, intruder)
	end
	if o_count ~= nil then
		-- we should send a message to the owner (and admin)
		local area_type = ifthenelse(intrusion_type == "private", "soukromé", "rezervované")
		local pos_str = minetest.pos_to_string(pos)
		local op_str = ifthenelse(place_or_dig == "place", "umístila", "vytěžila")
		local message = "Ve vaší "..area_type.." oblasti na pozici "..pos_str.." "..op_str.." blok postava jménem "..intruder_viewname..
			" (počítadlo = "..o_count..")"
		ch_core.add_event("intrusion_for_owner", message, owner)
		message = "V "..area_type.." oblasti na pozici "..pos_str.." ("..owner_viewname..") postava "..intruder_viewname.." "..op_str.." blok typu "..
			nodename.." (počítadlo = "..o_count..")"
		ch_core.add_event("intrusion_for_admin", message, intruder)
	end
end

local function on_placenode(pos, newnode, placer, oldnode, itemstack, pointed_thing)

	if placer == nil or not placer:is_player() then
		return
		--[[
		minetest.log("warning", "on_placenode: placer at "..minetest.pos_to_string(pos).." is not a player!")

		local s = ""
		if placer == nil then
			s = "placer == nil"
		elseif placer.get_player_name == nil then
			s = "placer.get_player_name == nil"
		else
			local pn = placer:get_player_name()
			if pn == nil then
				s = "placer:get_player_name() == nil"
			elseif pn == "" then
				s = "placer:get_player_name() == \"\""
			else
				s = "placer:get_player_name() == \""..pn.."\""
			end
		end
		print("DEBUG: "..s)
		return ]]
	end

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
		if main_area_def and main_area_def.owner ~= player_name then
			local intrusion_type
			if main_area_def.type == area_type_private then
				intrusion_type = "private"
			elseif main_area_def.type == area_type_reserved and not minetest.check_player_privs(placer, "ch_trustful_player") then
				intrusion_type = "reserved"
			end

			if intrusion_type ~= nil then
				on_intrusion(pos, main_area_def.owner, player_name, main_area_id, intrusion_type, "place", newnode.name or "")
			end
			--[[
			elseif main_area_def.type == area_type_reserved and not minetest.check_player_privs(placer, "ch_trustful_player") then
				-- reserved area
				try_send_message("I", player_name, main_area_id, "Tato oblast je rezervovaná. Než zde budete stavět, měl/a byste se domluvit s postavou jménem '"..owner_viewname.."'. Pokud jste se již domluvil/a, je to v pořádku a tuto zprávu můžete ignorovat.")
				try_send_message("O", main_area_def.owner, main_area_id, "Postava "..intruder_viewname.." umístila blok typu "..newnode.name.." v rezervované oblasti na pozici "..minetest.pos_to_string(pos))
			end
			]]
		end
	end
end

local function on_dignode(pos, oldnode, digger)
	if not digger or not digger.get_player_name or (digger:get_player_name() or "") == "" then
		-- minetest.log("on_dignode called with an invalid digger")
		return
	end
	if minetest.get_modpath("areas") then
		local player_name = digger:get_player_name()
		local main_area_id, main_area_def = areas:getMainAreaAtPos(pos)
		if main_area_def and main_area_def.owner ~= player_name then
			local intrusion_type
			if main_area_def.type == area_type_private then
				intrusion_type = "private"
			elseif main_area_def.type == area_type_reserved and not minetest.check_player_privs(digger, "ch_trustful_player") then
				intrusion_type = "reserved"
			end

			if intrusion_type ~= nil then
				on_intrusion(pos, main_area_def.owner, player_name, main_area_id, intrusion_type, "dig", oldnode.name or "")
			end
		end
	end
end

minetest.register_on_dignode(on_dignode)
minetest.register_on_placenode(on_placenode)
