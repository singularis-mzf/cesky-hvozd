print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local modpath = minetest.get_modpath("ch_overrides")

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
		dofile(modpath.."/mod_overrides/"..mod..".lua")
	end
end

dofile(modpath.."/aliases.lua")
dofile(modpath.."/bushy_leaves.lua")
dofile(modpath.."/chests.lua")
dofile(modpath.."/colorable_glass.lua")
dofile(modpath.."/extra_recipes.lua")
dofile(modpath.."/falling_nodes.lua")
dofile(modpath.."/flowers.lua")
dofile(modpath.."/liquid_physics.lua")
dofile(modpath.."/news.lua")
dofile(modpath.."/ores.lua")
dofile(modpath.."/poles.lua")
dofile(modpath.."/security.lua")
dofile(modpath.."/shelves.lua")
dofile(modpath.."/trash_cans.lua")
dofile(modpath.."/tool_breaking.lua")
dofile(modpath.."/ui_appearance.lua")
dofile(modpath.."/ui_settings.lua") -- : news
dofile(modpath.."/ui_stavby.lua")
dofile(modpath.."/underwater_dig.lua")
dofile(modpath.."/unknown_watcher.lua")

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
