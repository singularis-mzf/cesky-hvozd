ch_base.open_mod(minetest.get_current_modname())

local modpath = minetest.get_modpath("ch_overrides")
local dofile = ch_core.compile_dofile()

ch_overrides = {}

local mods = {
	"advtrains",
	"books",
	"cavestuff",
	"currency",
	"darkage",
	"default",
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

-- watch receive fields


minetest.register_on_player_receive_fields(function(player, formname, fields)
	local player_name = player:get_player_name()
	if formname ~= "" then
		ch_core.play_click_sound_to(player_name)
	end
	local hash = minetest.sha1(formname.."@"..dump2(fields))
	ch_core.ap_announce_craft(player, hash)
	local count = 0
	for _, _ in pairs(fields) do
		count = count + 1
	end
	minetest.log("action", "Player "..player_name.." received "..count.." fields (formname = \""..tostring(formname).."\", sha1 = "..hash..", quit = "..tostring(fields.quit)..")")
end)

--[[ temp

minetest.override_item("default:wood", {
	tiles = {"default_wood.png^[resize:256x256^(ch_core_planks_128.png^[makealpha:255,255,255^[opacity:100^[resize:256x256)"},
}) ]]

ch_base.close_mod(minetest.get_current_modname())
