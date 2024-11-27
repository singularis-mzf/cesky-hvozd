ch_base.open_mod(minetest.get_current_modname())
-- Areas mod by ShadowNinja
-- Based on node_ownership
-- Modified by Singularis for Český hvozd server
-- License: LGPLv2+


local area_types = {
	{number = 1, name = "normal", jmeno = "normální"}, -- ch_registered_player priv is required to build
	{number = 2, name = "open", jmeno = "otevřená"}, -- no priv is required to build
	{number = 3, name = "private", jmeno = "soukromá"}, -- ch_registered_player priv is required to build, but the owner should be noticed when someone else builds or enters there
	{number = 4, name = "locked", jmeno = "uzamčená"}, -- ch_trustful_player priv is required to build if you're not the owner
	{number = 5, name = "protected", jmeno = "chráněná"}, -- only owner is allowed to build there
	{number = 6, name = "shared", jmeno = "sdílená"}, -- not implemented yet
	{number = 7, name = "reserved", jmeno = "rezervovaná"}, -- ch_registered_player priv is required to build, but the owner should be noticed when someone else builds or enters there
}

areas = {
	adminPrivs = {areas=true},
	factions_available = minetest.get_modpath("playerfactions") and true,
	modpath = minetest.get_modpath("areas"),
	startTime = os.clock(),
	area_types_number_to_name = {},
	area_types_name_to_number = {},
}

for _, def in ipairs(area_types) do
	areas.area_types_number_to_name[def.number] = def.name
	areas.area_types_name_to_number[def.name] = def.number
	areas.area_types_name_to_number[def.jmeno] = def.number
	areas.area_types_name_to_number[ch_core.odstranit_diakritiku(def.jmeno)] = def.number
end

dofile(areas.modpath.."/settings.lua")
dofile(areas.modpath.."/api.lua")
dofile(areas.modpath.."/internal.lua")
dofile(areas.modpath.."/chatcommands.lua")
dofile(areas.modpath.."/pos.lua")
dofile(areas.modpath.."/interact.lua")
dofile(areas.modpath.."/legacy.lua")
dofile(areas.modpath.."/hud.lua")

areas:load()

local S = minetest.get_translator("areas")

minetest.register_privilege("areas", {
	description = S("Can administer areas."),
	give_to_singleplayer = false
})
minetest.register_privilege("areas_high_limit", {
	description = S("Can protect more, bigger areas."),
	give_to_singleplayer = false
})

if not minetest.registered_privileges[areas.config.self_protection_privilege] then
	minetest.register_privilege(areas.config.self_protection_privilege, {
		description = S("Can protect areas."),
	})
end

if minetest.settings:get_bool("log_mods") then
	local diffTime = os.clock() - areas.startTime
	minetest.log("action", "areas loaded in "..diffTime.."s.")
end

ch_base.close_mod(minetest.get_current_modname())
