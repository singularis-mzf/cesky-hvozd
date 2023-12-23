local trashbins = {
	["homedecor:trash_can"] = 1,
	["homedecor:trash_can_green_open"] = 1,
	["trash_can:dumpster"] = 1,
	["trash_can:trash_can_wooden"] = 1,
}

local function allow_trashbin_for(player)
	local role = ch_core.get_player_role(player)
	return role == nil or role == "admin" or role == "survival"
end

local function try_trashbin_for(player)
	if not allow_trashbin_for(player) then
		ch_core.systemovy_kanal(player:get_player_name(), "Jen dělnické postavy mohou využívat odpadkové koše!")
		return false
	else
		return true
	end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	if try_trashbin_for(player) then
		return count
	else
		return 0
	end
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if try_trashbin_for(player) then
		return stack:get_count()
	else
		return 0
	end
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if try_trashbin_for(player) then
		return stack:get_count()
	else
		return 0
	end
end

local default_override = {
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
}

for k, variant in pairs(trashbins) do
	local ndef = minetest.registered_nodes[k]
	if ndef ~= nil then
		local override
		if variant == 1 then
			override = default_override
		else
			error("Internal error: invalid trash bin behavior variant!")
		end
		minetest.override_item(k, override)
	end
end
