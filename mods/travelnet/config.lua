
-- set this to 0 if you want no limit
travelnet.MAX_STATIONS_PER_NETWORK = tonumber(minetest.settings:get("travelnet.MAX_STATIONS_PER_NETWORK")) or 24

-- set this to true if you want a simulated beam effect
travelnet.travelnet_effect_enabled = minetest.settings:get_bool("travelnet.travelnet_effect_enabled", false)
-- set this to true if you want a sound to be played when the travelnet is used
travelnet.travelnet_sound_enabled  = minetest.settings:get_bool("travelnet.travelnet_sound_enabled", true)

-- if you set this to false, travelnets cannot be created
-- (this may be useful if you want nothing but the elevators on your server)
travelnet.travelnet_enabled        = minetest.settings:get_bool("travelnet.travelnet_enabled", true)

travelnet.travelnet_cleanup_lbm = minetest.settings:get_bool("travelnet.travelnet_cleanup_lbm", false)

-- if you set travelnet.elevator_enabled to false, you will not be able to
-- craft, place or use elevators
travelnet.elevator_enabled         = minetest.settings:get_bool("travelnet.elevator_enabled", true)
-- if you set this to false, doors will be disabled
travelnet.doors_enabled            = minetest.settings:get_bool("travelnet.doors_enabled", true)

-- starts an abm which re-adds travelnet stations to networks in case the savefile got lost
travelnet.abm_enabled              = minetest.settings:get_bool("travelnet.abm_enabled", false)

-- will disable payment enforcement for all players
travelnet.is_free                  = minetest.settings:get_bool("travelnet.is_free", false)

-- change these if you want other receipes for travelnet or elevator
travelnet.travelnet_recipe = {
	{ "default:glass", "default:steel_ingot", "default:glass" },
	{ "default:glass", "default:mese",        "default:glass" },
	{ "default:glass", "default:steel_ingot", "default:glass" }
}
travelnet.elevator_recipe = {
	{ "default:steel_ingot", "default:glass", "default:steel_ingot" },
	{ "default:steel_ingot", "",              "default:steel_ingot" },
	{ "default:steel_ingot", "default:glass", "default:steel_ingot" }
}
travelnet.tiles_elevator = {
	"travelnet_elevator_front.png",
	"travelnet_elevator_inside_controls.png",
	"travelnet_elevator_sides_outside.png",
	"travelnet_elevator_inside_ceiling.png",
	"travelnet_elevator_inside_floor.png",
	"travelnet_top.png"
}
travelnet.elevator_inventory_image  = "travelnet_elevator_inv.png"

if minetest.registered_nodes["mcl_core:wood"] then
	travelnet.travelnet_recipe = {
		{ "mcl_stairs:slab_wood",            "mcl_stairs:slab_wood", "mcl_stairs:slab_wood" },
		{ "mesecons_torch:mesecon_torch_on", "mcl_chests:chest",     "mesecons_torch:mesecon_torch_on" },
		{ "mesecons_torch:mesecon_torch_on", "mcl_chests:chest",     "mesecons_torch:mesecon_torch_on" },
		-- { "core:glass",     "mcl_core:iron_ingot",          "mcl_core:glass" },
		-- { "mcl_core:glass", "mesecons_torch:redstoneblock", "mcl_core:glass" },
		-- { "mcl_core:glass", "mcl_core:iron_ingot",          "mcl_core:glass" }
	}
	travelnet.elevator_recipe = {
		{ "mcl_stairs:slab_wood", "mcl_stairs:slab_wood", "mcl_stairs:slab_wood" },
		{ "mesecons_torch:mesecon_torch_on", "", "mesecons_torch:mesecon_torch_on" },
		{ "mesecons_torch:mesecon_torch_on", "", "mesecons_torch:mesecon_torch_on" },
		-- { "mcl_core:iron_ingot", "mcl_core:glass", "mcl_core:iron_ingot" },
		-- { "mcl_core:iron_ingot", "",               "mcl_core:iron_ingot" },
		-- { "mcl_core:iron_ingot", "mcl_core:glass", "mcl_core:iron_ingot" }
	}
	travelnet.tiles_elevator = {
		"mcl_core_planks_big_oak.png^[transformR90", -- front
		"mcl_core_planks_big_oak.png^[transformR90", -- inside
		"mcl_core_planks_big_oak.png^[transformR90", -- sides outside
		"mcl_core_planks_big_oak.png^[transformR90", -- inside ceiling
		"mcl_core_planks_big_oak.png^[transformR90", -- inside floor
		"mcl_core_planks_big_oak.png^[transformR90", -- top
	}
	travelnet.elevator_inventory_image = nil
end

-- if this function returns true, the player with the name player_name is
-- allowed to add a box to the network named network_name, which is owned
-- by the player owner_name;
-- if you want to allow *everybody* to attach stations to all nets, let the
-- function always return true;
-- if the function returns false, players with the travelnet_attach priv
-- can still add stations to that network
-- params: player_name, owner_name, network_name
travelnet.allow_attach = function()
	return minetest.settings:get_bool("travelnet.allow_attach", false)
end


-- if this returns true, a player named player_name can remove a travelnet station
-- from network_name (owned by owner_name) even though he is neither the owner nor
-- has the travelnet_remove priv
-- params: player_name, owner_name, network_name, pos
travelnet.allow_dig = function()
	return minetest.settings:get_bool("travelnet.allow_dig", false)
end


-- if this function returns false, then player player_name will not be allowed to use
-- the travelnet station_name_start on networ network_name owned by owner_name to travel to
-- the station station_name_target on the same network;
-- if this function returns true, the player will be transfered to the target station;
-- you can use this code to i.e. charge the player money for the transfer or to limit
-- usage of stations to players in the same fraction on PvP servers
-- params: player_name, owner_name, network_name, station_name_start, station_name_target
travelnet.allow_travel = function(player_name, owner_name, station_network, station_name, target)
	local result = minetest.settings:get_bool("travelnet.allow_travel", true)
	local network = travelnet.get_network(owner_name, station_network)
	local current_pos = ch_core.safe_get_3(network, station_name, "pos")
	local target_pos = ch_core.safe_get_3(network, target, "pos")
	local price, pay_success
	if result then
		local pinfo = ch_core.normalize_player(player_name)
		if pinfo.player == nil then
			return false -- player not online
		end
		if pinfo.role == "admin" then
			return true
		end
		if station_network:sub(1, 1) == "@" and player_name ~= owner_name then
			ch_core.systemovy_kanal(player_name, ch_core.colors.red.."Tato síť cestovních budek je zabezpečená a vyhrazená pro postavu: "..ch_core.prihlasovaci_na_zobrazovaci(owner_name).."!")
			result = false
		end
		if result and not travelnet.is_free and not pinfo.role == "new" and not minetest.is_creative_enabled(player_name) then
			-- payment
			if current_pos ~= nil and target_pos ~= nil then
				price = travelnet.get_price(current_pos, target_pos)
				if (price or 0) > 0 then
					pay_success = ch_core.pay_from(player_name, price, {label = "platba za cestování cestovní budkou"})
					if pay_success then
						ch_core.systemovy_kanal(player_name, ch_core.formatovat_castku(price).." Kčs zaplaceno za cestu cestovní budkou.")
					else
						ch_core.systemovy_kanal(player_name, ch_core.colors.red.."Na tuto cestu nemáte dost peněz! Cena cesty: "..ch_core.formatovat_castku(price).." Kčs")
						result = false
					end
				end
			end
		end
	end
	minetest.log("action", "travelnet.allow_travel() called:\n- player: "..player_name.."\n- box   : "..minetest.pos_to_string(current_pos).." owned by "..owner_name.."  at network "..station_network.." with box name {"..station_name.."}\n- target: "..minetest.pos_to_string(target_pos).." {"..target.."}\n- price: "..(price or "nil")..", payment_success = "..tostring(pay_success).."\n- result = "..tostring(result))
	return result
end
