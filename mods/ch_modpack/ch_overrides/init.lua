print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local modpath = minetest.get_modpath("ch_overrides")
local dofile = ch_core.compile_dofile()

ch_overrides = {}

local mods = {
	"books",
	"cavestuff",
	"currency",
	"darkage",
	"default",
	"farming",
	"homedecor_kitchen",
	"homedecor_misc",
	"moreblocks",
	"moretrees",
	"sandwiches",
	"smartshop",
	"technic_cnc",
	"ts_furniture", -- colored chairs and sitting
}

for _, mod in ipairs(mods) do
	if minetest.get_modpath(mod) then
		dofile("mod_overrides/"..mod..".lua")
	end
end


dofile("aliases.lua")
dofile("arcades.lua")
dofile("bushy_leaves.lua")
dofile("chests.lua")
dofile("colorable_glass.lua")
dofile("extra_recipes.lua")
dofile("falling_nodes.lua")
dofile("flowers.lua")
dofile("liquid_physics.lua")
dofile("news.lua")
dofile("nutrition.lua")
dofile("ores.lua")
dofile("poles.lua")
dofile("security.lua")
dofile("shelves.lua")
dofile("stairsplus_recipes.lua")
dofile("trash_cans.lua")
dofile("tool_breaking.lua")
dofile("ui_appearance.lua")
dofile("ui_settings.lua") -- : news
dofile("ui_stavby.lua")
dofile("underwater_dig.lua")
dofile("unknown_watcher.lua")

-- log giveme

local giveme_func = minetest.registered_chatcommands["giveme"].func
minetest.override_chatcommand("giveme", {func = function(player_name, param)
	minetest.log("action", player_name.." gives themself: "..param)
	return giveme_func(player_name, param)
end})

-- temp

minetest.override_item("default:wood", {
	tiles = {"default_wood.png^[resize:256x256^(ch_core_planks_128.png^[makealpha:255,255,255^[opacity:100^[resize:256x256)"},
})


print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
