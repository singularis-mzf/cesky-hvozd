ch_base.open_mod(minetest.get_current_modname())
-- sethome/init.lua

sethome = {}

-- Load support for MT game translation.
local S = minetest.get_translator("sethome")

minetest.register_privilege("home", {
	description = "Umožní používat /doma a /domů",
	give_to_singleplayer = true
})

sethome.set = function(name, pos)
	local player = minetest.get_player_by_name(name)
	if not player or not pos then
		return false
	end
	local player_meta = player:get_meta()
	player_meta:set_string("sethome:home", minetest.pos_to_string(pos))
	return true
end

sethome.get = function(name)
	local player = minetest.get_player_by_name(name)
	local player_meta = player:get_meta()
	local pos = minetest.string_to_pos(player_meta:get_string("sethome:home"))
	if pos then
		return pos
	else
		return nil
	end
end

sethome.go = function(name)
	return false
end

--[[
local def = {
	description = S("Teleport you to your home point"),
	privs = {home = true},
	func = function(name)
		if sethome.go(name) then
			return true, S("Teleported to home!")
		end
		return false, S("Set a home using /sethome")
	end,
}
minetest.register_chatcommand("domu", def)
minetest.register_chatcommand("domů", def)

local def = {
	description = S("Set your home point"),
	privs = {home = true},
	func = function(name)
		name = name or "" -- fallback to blank name if nil
		local player = minetest.get_player_by_name(name)
		if player and sethome.set(name, player:get_pos()) then
			return true, S("Home set!")
		end
		return false, S("Player not found!")
	end,
}
minetest.register_chatcommand("doma", def)
]]
ch_base.close_mod(minetest.get_current_modname())
