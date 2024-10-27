print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local modpath = minetest.get_modpath("ch_overrides")
local dofile = ch_core.dofile

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
		dofile({name = "mod_overrides/"..mod..".lua"})
	end
end


dofile({name = "aliases.lua"})
dofile({name = "bushy_leaves.lua"})
dofile({name = "chests.lua"})
dofile({name = "colorable_glass.lua"})
dofile({name = "extra_recipes.lua"})
dofile({name = "falling_nodes.lua"})
dofile({name = "flowers.lua"})
dofile({name = "liquid_physics.lua"})
dofile({name = "news.lua"})
dofile({name = "nutrition.lua"})
dofile({name = "ores.lua"})
dofile({name = "poles.lua"})
dofile({name = "security.lua"})
dofile({name = "shelves.lua"})
dofile({name = "stairsplus_recipes.lua"})
dofile({name = "trash_cans.lua"})
dofile({name = "tool_breaking.lua"})
dofile({name = "ui_appearance.lua"})
dofile({name = "ui_settings.lua"}) -- : news
dofile({name = "ui_stavby.lua"})
dofile({name = "underwater_dig.lua"})
dofile({name = "unknown_watcher.lua"})

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
