--[[
local function on_player_inventory_action(player, action, inventory, inventory_info)
	local message = "player_inventory_action("..player:get_player_name().." @ "..minetest.pos_to_string(vector.round(player:get_pos())).."): "
	if action == "move" then
		local destination_stack = inventory:get_stack(inventory_info.to_list, inventory_info.to_index)
		message = message.."move "..inventory_info.count.." of "..destination_stack:get_name().." from "..inventory_info.from_list.."/"..inventory_info.from_index.." to "..inventory_info.to_list.."/"..inventory_info.to_index
	elseif action == "put" or action == "take" then
		if action == "put" then
			message = message.." put to "
		else
			message = message.." take from "
		end
		
		message = message..inventory_info.listname.."/"..inventory_info.index.." ("..inventory_info.stack:get_count().." of "..inventory_info.stack:get_name()..")"
	else
		message = message..action
	end

	minetest.log("action", message)
end

minetest.register_on_player_inventory_action(on_player_inventory_action)
]]

local function on_cheat(player, cheat)
	local player_name = (player and player:get_player_name()) or "nil"
	local player_pos = (player and minetest.pos_to_string(player:get_pos())) or "nil"
	minetest.log("warning", "Player "..player_name.." cheating detected at position "..player_pos..": "..dump2(cheat))
end
minetest.register_on_cheat(on_cheat)

