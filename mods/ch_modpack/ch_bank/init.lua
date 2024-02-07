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
	account_max = 1000000000000000, -- 10 bilionů Kčs
	storage = minetest.get_mod_storage(),
	wage_amount = 3000, -- 30,- Kčs
	wage_time = 300 * 1000000, -- 5 minut
}

assert(utils.storage ~= nil)

local function mydofile(filename)
	local f = loadfile(modpath.."/"..filename)
	assert(f)
	return f(tinv, utils)
end

mydofile("trade_inv.lua")
mydofile("bank_archive.lua")
mydofile("bank_accounts.lua")
mydofile("formspec.lua")
mydofile("formspec_callback.lua")
mydofile("trade.lua")
mydofile("payment_method.lua")

unified_inventory.ch_bank = ch_bank

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
