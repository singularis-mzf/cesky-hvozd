print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local path = minetest.get_modpath("mobs")

-- Peaceful player privilege
minetest.register_privilege("peaceful_player", {
	description = "Prevents Mobs Redo mobs from attacking player",
	give_to_singleplayer = false
})

-- Mob API
dofile(path .. "/api.lua")

-- Rideable Mobs
dofile(path .. "/mount.lua")

-- Mob Items
dofile(path .. "/crafts.lua")

-- Lucky Blocks
dofile(path .. "/lucky_block.lua")

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
