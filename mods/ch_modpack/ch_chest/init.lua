print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
ch_chest = {}
local internal = {
	default_width = 8,
	default_height = 4,
	upgrades = {
		{
			items = {"default:steelblock"},
			width = 9,
			height = 5,
		},
		{
			items = {"default:copperblock", "moreblocks:copperpatina"},
			width = 12,
			height = 5,
		},
		{
			items = {"moreores:silver_block"},
			width = 12,
			height = 6,
		},
		{
			items = {"default:goldblock"},
			width = 18,
			height = 6,
		},
		{
			items = {"moreores:mithril_block"},
			width = 20,
			height = 10,
		},
	},
}

local function mydofile(filename)
	local f = loadfile(modpath.."/"..filename)
	assert(f)
	return f(internal)
end

mydofile("formspec.lua")
mydofile("functions.lua")
mydofile("nodes.lua")

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
