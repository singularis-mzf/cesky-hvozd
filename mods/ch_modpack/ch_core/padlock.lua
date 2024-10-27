ch_core.open_submod("padlock", {data = true, lib = true})

--[[

How to use padlock:

1. Add "on_padlock_place = function(player, pos, owner)" to the node definition.
   The function should check, if a padlock is present.
   If the padlock is already present, it should return false.
   Otherwise it should add the padlock and return true.
2. Add "on_padlock_remove = function(player, pos, owner)" to the node definition.
   The function should check, if a padlock is present.
   If the padlock is missing, it should return false.
   Otherwise it should remove the padlock and return true.
3. Add node to the "padlockable = 1" group (optional).
4. Add "ch_core.dig_padlock(pos, player)" to the can_dig before returning true.
   (This function will call on_padlock_remove to test and remove a padlock.)
]]

local function padlock_remove(itemstack, player, pointed_thing)
	if pointed_thing.type == "object" then
		local o, e, f
		o = pointed_thing.ref
		e = o:get_luaentity()
		f = e and e.on_punch
		if f then
			return f(e, player)
		else
			return
		end
	end
	local pos = minetest.get_pointed_thing_position(pointed_thing, false)
	if not player or not player:is_player() or not pos then
		return nil
	end
	local nodedef = minetest.registered_nodes[minetest.get_node(pos).name]
	if not nodedef or not nodedef.on_padlock_remove then
		return nil
	end
	local player_name = player:get_player_name()
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	if owner == player_name or minetest.check_player_privs(player, "protection_bypass") then
		if nodedef.on_padlock_remove(player, pos, owner) then
			-- padlock removed => give it to the player
			player:get_inventory():add_item("main", itemstack:peek_item(1))
		end
	else
		minetest.chat_send_player(player_name, "*** Nemáte právo odstranit zámek z tohoto objektu!")
	end
	return nil
end

local function padlock_place(itemstack, player, pointed_thing)
	if pointed_thing.type == "object" then
		local o, e, f
		o = pointed_thing.ref
		e = o:get_luaentity()
		f = e and e.on_rightclick
		if f then
			return f(e, player)
		else
			return
		end
	end

	local pos = minetest.get_pointed_thing_position(pointed_thing, false)
	if not player or not player:is_player() or not pos then
		return nil
	end
	local nodedef = minetest.registered_nodes[minetest.get_node(pos).name]
	if not nodedef or not nodedef.on_padlock_place then
		return nil
	end
	local player_name = player:get_player_name()
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	if owner == player_name or minetest.check_player_privs(player, "protection_bypass") then
		if nodedef.on_padlock_place(player, pos, owner) then
			-- padlock placed
			itemstack:take_item(1)
			return itemstack
		end
	else
		minetest.chat_send_player(player_name, "*** Nemáte právo umístit zámek na tento objekt!")
	end
	return nil
end

minetest.override_item("basic_materials:padlock", {
	on_use = padlock_remove,
	on_place = padlock_place,
})

-- call ch_core.dig_padlock(pos, player) in can_dig before returning true
function ch_core.dig_padlock(pos, player)
	padlock_remove(ItemStack("basic_materials:padlock"), player, {type = "node", under = pos, above = vector.new(pos.x, pos.y + 1, pos.z)})
	return true
end

ch_core.close_submod("padlock")
