-- CHESTS
local S = minetest.get_translator("ch_overrides")

local normal_chest = {
	infotext = "dřevěná truhla (truhlu umístil/a: @1)",
}
local locked_chest = {
	infotext = "zamčená dřevěná truhla (vlastník/ice: @1)",
}

local default_chests = {
	["default:chest"] = normal_chest,
	["default:chest_open"] = normal_chest,
	["default:chest_locked"] = locked_chest,
	["default:chest_locked_open"] = locked_chest,
}

local function function_only_for_registered(f, i, forbidden_result)
	if not f then
		error("f is required")
	end
	return function(...)
		local args = {...}
		-- minetest.log("warning", "Will test this for player_privs: "..dump2({args[i]}))
		if not minetest.check_player_privs(args[i], "ch_registered_player") then
			return forbidden_result
		else
			return f(...)
		end
	end
end

local function default_allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	return count
end
local function default_allow_metadata_inventory_put_or_take(pos, listname, index, stack, player)
	return stack:get_count()
end

for chest_name, chest_def in pairs(default_chests) do
	local ndef = minetest.registered_nodes[chest_name]
	if not ndef then
		minetest.log("warning", "Chest "..chest_name.." is not defined!")
	else
		local old_allow_metadata_inventory_move = ndef.allow_metadata_inventory_move
		local old_allow_metadata_inventory_put = ndef.allow_metadata_inventory_put
		local old_allow_metadata_inventory_take = ndef.allow_metadata_inventory_take
		local override = {
			allow_metadata_inventory_move = function_only_for_registered(ndef.allow_metadata_inventory_move or default_allow_metadata_inventory_move, 7, 0),
			allow_metadata_inventory_put = function_only_for_registered(ndef.allow_metadata_inventory_put or default_allow_metadata_inventory_put_or_take, 5, 0),
			allow_metadata_inventory_take = function_only_for_registered(ndef.allow_metadata_inventory_take or default_allow_metadata_inventory_put_or_take, 5, 0),
		}
		local old_after_place_node = ndef.after_place_node
		if chest_def.type == "locked" then
			if chest_def.infotext then
				override.after_place_node = function(pos, placer)
					if old_after_place_node then old_after_place_node(pos, placer) end
					local meta = minetest.get_meta(pos)
					local player_name = placer.get_player_name and placer:get_player_name()
					if player_name then
						meta:set_string("placer", player_name)
						minetest.log("action", player_name.." placed "..chest_name.." at "..minetest.pos_to_string(pos))
					else
						minetest.log("warning", "The chest of type "..chest_name.." placed at "..minetest.pos_to_string(pos).." with no placer player_name!")
					end
					meta:set_string("infotext", S(chest_def.infotext, ch_core.prihlasovaci_na_zobrazovaci(player_name)))
				end
				override.on_punch = function(pos, node, puncher, pointed_thing)
					if minetest.node_punch(pos, node, puncher, pointed_thing) ~= false then
						local meta = minetest.get_meta(pos)
						meta:set_string("infotext", S(chest_def.infotext, ch_core.prihlasovaci_na_zobrazovaci(meta:get_string("owner"))))
					end
				end
			end
		else
			if chest_def.infotext then
				override.after_place_node = function(pos, placer)
					if old_after_place_node then old_after_place_node(pos, placer) end
					local meta = minetest.get_meta(pos)
					local player_name = placer.get_player_name and placer:get_player_name()
					if player_name then
						meta:set_string("placer", player_name)
					else
						minetest.log("warning", "The chest of type "..chest_name.." placed at "..minetest.pos_to_string(pos).." with no placer player_name!")
					end
					meta:set_string("infotext", S(chest_def.infotext, ch_core.prihlasovaci_na_zobrazovaci(meta:get_string("placer"))))
				end
				override.on_punch = function(pos, node, puncher, pointed_thing)
					if minetest.node_punch(pos, node, puncher, pointed_thing) ~= false then
						local meta = minetest.get_meta(pos)
						meta:set_string("infotext", S(chest_def.infotext, ch_core.prihlasovaci_na_zobrazovaci(meta:get_string("placer"))))
					end
				end
			end
			override.on_rightclick = function_only_for_registered(ndef.on_rightclick or function(pos, node, clicker) return end, 3, nil)
		end
		minetest.override_item(chest_name, override)
	end
end
