
local path = minetest.get_modpath(minetest.get_current_modname()) .. "/"

-- Check for translation method
local S
if minetest.get_translator ~= nil then
	S = minetest.get_translator("mobs_npc") -- 5.x translation function
else
	if minetest.get_modpath("intllib") then
		dofile(minetest.get_modpath("intllib") .. "/init.lua")
		if intllib.make_gettext_pair then
			gettext, ngettext = intllib.make_gettext_pair() -- new gettext method
		else
			gettext = intllib.Getter() -- old text file method
		end
		S = gettext
	else -- boilerplate function
		S = function(str, ...)
			local args = {...}
			return str:gsub("@%d+", function(match)
				return args[tonumber(match:sub(2))]
			end)
		end
	end
end

mobs.intllib_npc = S


-- Check for custom mob spawn file
local input = io.open(path .. "spawn.lua", "r")

if input then
	mobs.custom_spawn_npc = true
	input:close()
	input = nil
end


-- NPCs
dofile(path .. "npc.lua") -- TenPlus1
dofile(path .. "trader.lua")
dofile(path .. "igor.lua")


-- Load custom spawning
if mobs.custom_spawn_npc then
	dofile(path .. "spawn.lua")
end


-- Lucky Blocks
dofile(path .. "/lucky_block.lua")


print ("[MOD] Mobs Redo NPCs loaded")
