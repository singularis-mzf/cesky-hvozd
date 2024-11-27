ch_base.open_mod(minetest.get_current_modname())
local S = minetest.get_translator(minetest.get_current_modname())

local modpath = minetest.get_modpath("technic_chests")

technic = rawget(_G, "technic") or {}
technic.chests = {}

technic.chests.colors = {
	{"black", S("Black"), "#000000"},
	{"blue", S("Blue"), "#2020ff"},
	{"brown", S("Brown"), "#794d20"},
	{"cyan", S("Cyan"), "#3cffff"},
	{"dark_green", S("Dark Green"), "#206620"},
	{"dark_grey", S("Dark Grey"), "#666666"},
	{"green", S("Green"), "#20ff20"},
	{"grey", S("Grey"), "#acacac"},
	{"magenta", S("Magenta"), "#ff20ff"},
	{"orange", S("Orange"), "#ff9020"},
	{"pink", S("Pink"), "#ffbaff"},
	{"red", S("Red"), "#ff2020"},
	{"violet", S("Violet"), "#ff2020"},
	{"white", S("White"), "#ffffff"},
	{"yellow", S("Yellow"), "#ffff00"},
}

function technic.chests.change_allowed(pos, player, owned, protected)
	if minetest.is_player(player) and not minetest.check_player_privs(player, "ch_registered_player") then
		return false
	end
	if owned then
		if minetest.is_player(player) and not default.can_interact_with_node(player, pos) then
			local meta = minetest.get_meta(pos)
			local owner2 = meta:get_string("owner2")
			if owner2 == "" or player:get_player_name() ~= owner2 then
				return false
			end
		end
	elseif protected then
		if minetest.is_protected(pos, player:get_player_name()) then
			return false
		end
	end
	return true
end

if minetest.get_modpath("digilines") then
	dofile(modpath.."/digilines.lua")
end

dofile(modpath.."/formspec.lua")
dofile(modpath.."/inventory.lua")
dofile(modpath.."/register.lua")
dofile(modpath.."/chests.lua")

-- Undo all of the locked wooden chest recipes, and just make them use a padlock.
minetest.register_on_mods_loaded(function()
	ch_core.clear_crafts("technic_chests", {{output = "default:chest_locked"}})
	minetest.register_craft({
		output = "default:chest_locked",
		recipe = {
			{ "group:wood", "group:wood", "group:wood" },
			{ "group:wood", "basic_materials:padlock", "group:wood" },
			{ "group:wood", "group:wood", "group:wood" }
		}
	})
	minetest.register_craft({
		output = "default:chest_locked",
		type = "shapeless",
		recipe = {
			"default:chest",
			"basic_materials:padlock"
		}
	})
end)

-- Conversion for old chests
minetest.register_lbm({
	name = "technic_chests:old_chest_conversion",
	nodenames = {"group:technic_chest"},
	run_at_every_load = false,
	action = function(pos, node)
		-- Use `on_construct` function because that has data from register function
		local def = minetest.registered_nodes[node.name]
		if def and def.on_construct then
			def.on_construct(pos)
		end
	end,
})
ch_base.close_mod(minetest.get_current_modname())
