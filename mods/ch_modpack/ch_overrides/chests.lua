-- CHESTS
local S = minetest.get_translator("ch_overrides")

-- LOCAL FUNCTIONS
local function can_dig_without_inventory_check(pos, player)
	local pinfo = ch_core.normalize_player(player)
	if pinfo.role == "none" then
		return false
	end
	if minetest.is_protected(pos, pinfo.player_name) then
		minetest.register_protection_violation(pos, pinfo.player_name)
		return false
	end
	return default.can_interact_with_node(player, pos)
end

local function can_dig_with_inventory_check(pos, player)
	return can_dig_without_inventory_check(pos, player) and minetest.get_meta(pos):get_inventory():is_empty("main")
end

local function allow_metadata_inventory_move_checked(pos, from_list, from_index, to_list, to_index, count, player)
	local player_role = ch_core.get_player_role(player)
	if player_role ~= "new" and player_role ~= "none" then
		return count
	else
		return 0
	end
end

local function allow_metadata_inventory_put_or_take_checked(pos, listname, index, stack, player)
	local player_role = ch_core.get_player_role(player)
	if player_role ~= "new" and player_role ~= "none" then
		return stack:get_count()
	else
		return 0
	end
end

local function after_place_node_with_infotext(old_f, infotext)
	return function(pos, placer, itemstack, pointed_thing)
		if old_f ~= nil then
			old_f(pos, placer, itemstack, pointed_thing)
		end
		local meta = minetest.get_meta(pos)
		local player_name = placer.get_player_name and placer:get_player_name()
		if player_name then
			meta:set_string("placer", player_name)
			minetest.log("action", player_name.." placed "..minetest.get_node(pos).name.." at "..minetest.pos_to_string(pos))
		else
			minetest.log("warning", "The chest of type "..minetest.get_node(pos).name.." placed at "..minetest.pos_to_string(pos).." with no placer player_name!")
		end
		meta:set_string("infotext", S(infotext, ch_core.prihlasovaci_na_zobrazovaci(player_name)))
	end
end

local function on_dig_pickable(pos, node, digger)
	if minetest.get_meta(pos):get_inventory():is_empty("main") then
		return minetest.node_dig(pos, node, digger)
	else
		local player_name = digger:get_player_name()
		local picked_up, err_msg = wrench.pickup_node(pos, digger)
		if not picked_up then
			if err_msg then
				minetest.chat_send_player(player_name, err_msg)
			end
			return false
		end
		return true
	end
end

local function on_punch_with_infotext(old_f, infotext, meta_key)
	return function(pos, node, puncher, pointed_thing)
		if old_f ~= nil then
			old_f(pos, node, puncher, pointed_thing)
		end
		if minetest.node_punch(pos, node, puncher, pointed_thing) ~= false then
			local meta = minetest.get_meta(pos)
			meta:set_string("infotext", S(infotext, ch_core.prihlasovaci_na_zobrazovaci(meta:get_string(meta_key))))
		end
	end
end

local function move_only_for_registered(old_f)
	if old_f ~= nil then
		return function(pos, from_list, from_index, to_list, to_index, count, player)
			local result = allow_metadata_inventory_move_checked(pos, from_list, from_index, to_list, to_index, count, player)
			if result ~= 0 then
				result = math.min(result, old_f(pos, from_list, from_index, to_list, to_index, count, player))
			end
			return result
		end
	else
		return allow_metadata_inventory_move_checked
	end
end

local function put_or_take_only_for_registered(old_f)
	if old_f ~= nil then
		return function(pos, listname, index, stack, player)
			local result = allow_metadata_inventory_put_or_take_checked(pos, listname, index, stack, player)
			if result ~= 0 then
				result = math.min(result, old_f(pos, listname, index, stack, player))
			end
			return result
		end
	else
		return allow_metadata_inventory_put_or_take_checked
	end
end

local function on_rightclick_only_for_registered(old_f)
	if old_f ~= nil then
		return function(pos, node, clicker, itemstack, pointed_thing)
			local player_role = ch_core.get_player_role(clicker)
			if player_role == "new" or player_role == "none" then
				return
			else
				return old_f(pos, node, clicker, itemstack, pointed_thing)
			end
		end
	end
end

-- DEFINITIONS AND OPTIONS
local chest_default = {
	infotext = "dřevěná truhla (truhlu umístil/a: @1)",
	on_punch_infotext_key = "placer",
	check_rightclick = true,
	required = true,
}
local chest_default_locked = {
	infotext = "zamčená dřevěná truhla (vlastník/ice: @1)",
	on_punch_infotext_key = "owner",
	check_rightclick = true,
	required = true,
}
local chest_pickable = {
	pickable = true,
}

local chests = {
	["darkage:box"] = chest_pickable,
	["default:chest"] = chest_default,
	["default:chest_open"] = chest_default,
	["default:chest_locked"] = chest_default_locked,
	["default:chest_locked_open"]  = chest_default_locked,
	["giftbox2:giftbox_black"] = chest_pickable,
	["giftbox2:giftbox_blue"] = chest_pickable,
	["giftbox2:giftbox_cyan"] = chest_pickable,
	["giftbox2:giftbox_green"] = chest_pickable,
	["giftbox2:giftbox_magenta"] = chest_pickable,
	["giftbox2:giftbox_orange"] = chest_pickable,
	["giftbox2:giftbox_red"] = chest_pickable,
	["giftbox2:giftbox_violet"] = chest_pickable,
	["giftbox2:giftbox_white"] = chest_pickable,
	["giftbox2:giftbox_yellow"] = chest_pickable,
	["homedecor:cardboard_box"] = chest_pickable,
	["homedecor:cardboard_box_big"] = chest_pickable,
}

for chest_name, chest_options in pairs(chests) do
	local ndef = minetest.registered_nodes[chest_name]
	if ndef ~= nil then
		local override = {}
		local old_after_place_node = ndef.after_place_node
		local override = {
			allow_metadata_inventory_move = move_only_for_registered(ndef.allow_metadata_inventory_move),
			allow_metadata_inventory_put = put_or_take_only_for_registered(ndef.allow_metadata_inventory_put),
			allow_metadata_inventory_take = put_or_take_only_for_registered(ndef.allow_metadata_inventory_take),
		}
		if chest_options.infotext ~= nil then
			override.after_place_node = after_place_node_with_infotext(ndef.after_place_node, chest_options.infotext)
		end
		if chest_options.on_punch_infotext_key ~= nil then
			override.on_punch = on_punch_with_infotext(ndef.on_punch, chest_options.infotext or "", chest_options.on_punch_infotext_key)
		end
		if chest_options.check_rightclick and ndef.on_rightclick ~= nil then
			override.on_rightclick = on_rightclick_only_for_registered(ndef.on_rightclick)
		end
		if chest_options.pickable then
			override.can_dig = can_dig_without_inventory_check
			override.on_dig = on_dig_pickable
		end
		minetest.override_item(chest_name, override)

	elseif chest_options.required then
		error("Required chest "..chest_name.." is not defined!")
	end
end
