ch_core.open_submod("joinplayer", {data = true, lib = true, nametag = true})

local function on_newplayer(player)
	local player_name = player:get_player_name()
	minetest.log("action", "[ch_core] New player '"..player_name.."'");
	local inv = player:get_inventory();
	if minetest.registered_tools["orienteering:map"] then
		inv:add_item("main", "orienteering:map")
	end
	return
end

local function on_joinplayer(player, last_login)
	local player_name = player:get_player_name()
	local online_charinfo = ch_core.get_joining_online_charinfo(player_name)
	local offline_charinfo = ch_core.get_offline_charinfo(player_name)
	player:set_nametag_attributes(ch_core.compute_player_nametag(online_charinfo, offline_charinfo))
	return true
end

--[[
local function on_leaveplayer(player)
	local player_name = player:get_player_name()
end
]]

minetest.register_on_newplayer(on_newplayer)
minetest.register_on_joinplayer(on_joinplayer)
-- minetest.register_on_leaveplayer(on_leaveplayer)

ch_core.close_submod("joinplayer")
