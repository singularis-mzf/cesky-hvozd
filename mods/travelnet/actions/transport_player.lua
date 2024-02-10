local S = minetest.get_translator("travelnet")

return function (node_info, fields, player)

	local network = travelnet.get_network(node_info.props.owner_name, node_info.props.station_network)
	local nl_pos = string.find(fields.target, "\xe2\x80\x8b")
	if nl_pos ~= nil then
		fields.target = fields.target:sub(1, nl_pos - 1)
	end

	if node_info.node ~= nil and node_info.props.is_elevator then
		for k,_ in pairs(network) do
			if network[k].nr == fields.target then
				fields.target = k
				break
			end
		end
	end

	local target_station = network[fields.target]

	-- if the target station is gone
	if not target_station then
		return false, S("Station '@1' does not exist (anymore?)" ..
					" " .. "on this network.", fields.target or "?")
	end

	local player_name = player:get_player_name()

	if not travelnet.allow_travel(
		player_name,
		node_info.props.owner_name,
		node_info.props.station_network,
		node_info.props.station_name,
		fields.target
	) then
		return false, S("You are not allowed to travel to this station.")
	end

	-- repair the travelnet:
	local top_pos = vector.offset(node_info.pos, 0, 1, 0)
	local top_node = minetest.get_node(top_pos)
	if top_node.name ~= "travelnet:hidden_top" then
		local def = minetest.registered_nodes[top_node.name]
		if def and def.buildable_to then
			minetest.set_node(top_pos, { name="travelnet:hidden_top" })
		end
	end

	-- check if the box has at the other end has been removed.
	local target_pos = target_station.pos
	minetest.load_area(target_pos)
	local target_node = minetest.get_node(target_pos)
	if minetest.get_item_group(target_node.name, "travelnet") == 0 and minetest.get_item_group(target_node.name, "elevator") == 0 then
		-- provide information necessary to identify the removed box
		local oldmetadata = {
			fields = {
				owner           = node_info.props.owner_name,
				station_name    = fields.target,
				station_network = node_info.props.station_network
			}
		}
		travelnet.remove_box(target_pos, nil, oldmetadata, player)
		return
	end

	local player_role = ch_core.get_player_role(player_name)

	-- compute exact target_pos:
	-- may be 0.0 for some versions of MT 5 player model
	local player_model_bottom = tonumber(minetest.settings:get("player_model_bottom")) or -.5
	-- local player_model_vec = vector.new(0, player_model_bottom, 0)
	-- local target_node = minetest.get_node_or_nil(target_station.pos)

	local def = {
		type = "player",
		player = player,
		target_pos = vector.offset(target_station.pos, 0, player_model_bottom, 0),
		look_horizontal = math.rad(assert(travelnet.param2_to_yaw(target_node.param2))),
		look_vertical = 0,

		callback_before = function()
			if travelnet.travelnet_effect_enabled then
				minetest.add_entity(vector.offset(node_info.pos, 0, 0.5, 0), "travelnet:effect")
			end
			-- close the doors at the sending station
			travelnet.open_close_door(node_info.pos, player, "close")
		end,
		callback_after = function()
			-- effect at the target station
			if travelnet.travelnet_effect_enabled then
				minetest.add_entity(vector.offset(target_pos, 0, 0.5, 0), "travelnet:effect")
			end
			-- open the doors at the target station
			travelnet.open_close_door(target_pos, player, "open")
		end,
	}

	if player_role ~= "new" and player_role ~= "admin" then
		-- add delay:
		local price = travelnet.get_price(node_info.pos, target_pos) or 0
		def.delay = math.max(0.0, math.min(20.0, 3.4e-3 * price))
	end

	if travelnet.travelnet_sound_enabled then
		if node_info.props.is_elevator then
			def.sound_before = {name = "travelnet_bell", gain = 0.75}
		else
			def.sound_before = {name = "travelnet_travel", gain = 0.75}
		end
		def.sound_after = def.sound_before
	end

	ch_core.teleport_player(def)
	return true
end
