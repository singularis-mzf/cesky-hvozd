ch_base.open_mod(minetest.get_current_modname())

local modpath = minetest.get_modpath("ch_overrides")
local dofile = ch_core.compile_dofile()

ch_overrides = {}

local mods = {
	"books",
	"bones",
	"cavestuff",
	"currency",
	"darkage",
	"default",
	"doors",
	"farming",
	"homedecor_kitchen",
	"homedecor_misc",
	"mail",
	"moreblocks",
	"moretrees",
	"sandwiches",
	"smartshop",
	"technic",
	"technic_cnc",
	"ts_furniture", -- colored chairs and sitting
}

for _, mod in ipairs(mods) do
	if minetest.get_modpath(mod) then
		dofile("mod_overrides/"..mod..".lua")
	end
end


dofile("aliases.lua")
dofile("bushy_leaves.lua")
dofile("chests.lua")
dofile("chisel_regs.lua")
dofile("colorable_glass.lua")
dofile("drawtype_groups.lua")
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
dofile("ui_events.lua")
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

--[[ temp

minetest.override_item("advtrains_line_automation:stanicni_rozhlas", {
	tiles = {"ch_core_white_pixel.png"},
	paramtype2 = "4dir",
})
-- ]]

ch_base.close_mod(minetest.get_current_modname())
