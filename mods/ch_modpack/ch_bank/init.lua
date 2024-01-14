print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
ch_bank = {
	icon = "default_gold_block.png",
}
local tinv = {}
local utils = {
	STATE_OPEN = 1,
	STATE_CLOSED = 2,
	STATE_CONFIRMED = 3,
}

local function mydofile(filename)
	local f = loadfile(modpath.."/"..filename)
	assert(f)
	return f(tinv, utils)
end

mydofile("trade_inv.lua")
mydofile("bank_accounts.lua")
mydofile("formspec.lua")
mydofile("formspec_callback.lua")
mydofile("trade.lua")

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
