local tinv, utils = ...

local detached_inventory_id = "ch_bank_trade"
local player_inventory_listname = "ch_bank_trade"
local trade_inv_size = 4 * 4

local ifthenelse = ch_core.ifthenelse
local STATE_OPEN = utils.STATE_OPEN
-- RESCUE ITEMS AFTER JOINPLAYER
local function rescue_items_after_joinplayer(player, last_login)
	local player_inv = player:get_inventory()
	local inv_size = player_inv:get_size(player_inventory_listname)
	if inv_size > 0 then
		if player_inv:is_empty(player_inventory_listname) then
			player_inv:set_size(player_inventory_listname, 0)
			minetest.log("warning", "Player Rescue Trade Inventory of "..player:get_player_name().." found after joinplayer with size "..inv_size..", but empty.")
		else
			local list = player_inv:get_list(player_inventory_listname)
			player_inv:set_size(player_inventory_listname, 0)
			local count = utils.give_items_to_player(player, player_inv, list)
			if count > 0 then
				minetest.log("action", count.." items rescued form the Player Rescue Trade Inventory of "..player:get_player_name()..".")
			end
		end
	end
end
minetest.register_on_joinplayer(rescue_items_after_joinplayer)

-- CALLBACKS FOR THE TRADE INVENTORY
local function allow_move(inv, from_list, from_index, to_list, to_index, count, player)
	return ifthenelse(from_list == to_list, count, 0) -- only allow move inside one list
end
local function allow_put_or_take(inv, listname, index, stack, player)
	local player_name = player:get_player_name()
	if listname ~= player_name then return 0 end
	local trade_state, tstype = utils.get_player_trade_state(player_name)
	return ifthenelse(tstype == "trade" and trade_state.left.state == STATE_OPEN, stack:get_count(), 0)
end
local function on_move(inv, from_list, from_index, to_list, to_index, count, player)
	local player_inv = player:get_inventory()
	local from_stack = inv:get_stack(from_list, from_index)
	local to_stack = inv:get_stack(to_list, to_index)
	player_inv:set_stack(player_inventory_listname, from_index, from_stack)
	player_inv:set_stack(player_inventory_listname, to_index, to_stack)
end
local function on_put_or_take(inv, listname, index, stack, player)
	local player_inv = player:get_inventory()
	stack = inv:get_stack(listname, index)
	player_inv:set_stack(player_inventory_listname, index, stack)
end
local function on_put(inv, listname, index, stack, player)
	local player_inv = player:get_inventory()
	stack = inv:get_stack(listname, index)
	player_inv:set_stack(player_inventory_listname, index, stack)
	minetest.log("player "..listname.." put item to a trade inventory; index = "..index..", stack = "..stack:to_string())
end

-- DETACHED INVENTORIES
local trade_inv = minetest.create_detached_inventory(detached_inventory_id, {
	allow_move = allow_move,
	allow_put = allow_put_or_take,
	allow_take = allow_put_or_take,
	on_move = on_move,
	on_put = on_put,
	on_take = on_put_or_take,
})
minetest.register_on_joinplayer(function(player, last_login)
	trade_inv:set_size(player:get_player_name(), trade_inv_size)
end)
minetest.register_on_leaveplayer(function(player, timed_out)
	trade_inv:set_size(player:get_player_name(), 0)
end)

-- ACCESS TO THE TRADE INVENTORY
function tinv.open_trade_inventory(player)
	local empty_list = {}
	local player_name = player:get_player_name()
	local player_inv = player:get_inventory()
	trade_inv:set_list(player_name, empty_list)
	player_inv:set_size(player_inventory_listname, trade_inv_size)
	player_inv:set_list(player_inventory_listname, empty_list)
	return true
end

function tinv.close_trade_inventory(player)
	local player_name = player:get_player_name()
	local player_inv = player:get_inventory()
	player_inv:set_size(player_inventory_listname, 0)
	trade_inv:set_list(player_name, {})
	return true
end

function tinv.get_trade_inventory_formspec_params(player)
	local player_name = player:get_player_name()
	return {
		location = "detached:"..detached_inventory_id,
		listname = player_name,
		width = 4,
		height = math.floor(trade_inv_size / 4),
		size = trade_inv_size,
	}
end

function tinv.read_trade_inventory(player)
	return player:get_inventory():get_list(player_inventory_listname) or {}
end

function tinv.add_item_to_trade_inventory(player, stack)
	local player_name = player:get_player_name()
	player:get_inventory():add_item(player_inventory_listname, stack)
	return trade_inv:add_item(player_name, stack)
end

function tinv.room_for_item_in_trade_inventory(player, stack)
	return player:get_inventory():room_for_item(player_inventory_listname, stack)
end

-- SIMULATION INVENTORY
local sim_inv = minetest.create_detached_inventory("ch_bank_trade_simulation", {})

function tinv.open_simulation(player_name, inv, listname)
	assert(type(player_name) == "string")
	local size = inv:get_size("listname")
	local list = assert(inv:get_list(listname))
	sim_inv:set_size(player_name, size)
	sim_inv:set_list(player_name, list)
	return size, list
end

function tinv.add_items_to_simulation(player_name, stacks) -- true | false
	if stacks == nil then return true end
	for _, stack in ipairs(stacks) do
		if not stack:is_empty() and not sim_inv:add_item(player_name, stack):is_empty() then
			return false
		end
	end
	return true
end

function tinv.close_simulation(player_name) -- => stacks
	local result = sim_inv:get_list(player_name)
	sim_inv:set_size(player_name, 0)
	return result
end
