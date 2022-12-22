print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local modpath = minetest.get_modpath("ch_overrides")

local mods = {
	"cavestuff",
	"farming",
	"homedecor_kitchen",
	"moreblocks",
	"moretrees",
	"screwdriver",
	"ts_furniture", -- colored chairs and sitting
}

for _, mod in ipairs(mods) do
	if minetest.get_modpath(mod) then
		dofile(modpath.."/mod_overrides/"..mod..".lua")
	end
end

dofile(modpath.."/chests.lua")
dofile(modpath.."/extra_recipes.lua")
dofile(modpath.."/extra_shapes.lua")
dofile(modpath.."/falling_nodes.lua")
dofile(modpath.."/ores.lua")
dofile(modpath.."/poles.lua")
dofile(modpath.."/shelves.lua")
dofile(modpath.."/security.lua")

-- log giveme

local giveme_func = minetest.registered_chatcommands["giveme"].func
minetest.override_chatcommand("giveme", {func = function(player_name, param)
	minetest.log("action", player_name.." gives themself: "..param)
	return giveme_func(player_name, param)
end})

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
