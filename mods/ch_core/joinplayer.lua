ch_core.require_submod("joinplayer", "data")
ch_core.require_submod("joinplayer", "lib")

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
	-- print("DEBUG: on_joinplayer("..player:get_player_name().."): will update nametag")
	ch_core.update_player_nametag(player:get_player_name())
	--[[ player:hud_set_flags({
		minimap = true, -- enable minimap for everyone
		minimap_radar = minetest.check_player_privs(player, "creative"), -- radar if the player has creative priv
	})
	]]
	-- print("DEBUG: on_joinplayer("..player:get_player_name()..").")
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

ch_core.submod_loaded("joinplayer")
