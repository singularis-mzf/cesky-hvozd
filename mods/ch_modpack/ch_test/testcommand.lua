local def

--[[

local color = minetest.get_color_escape_sequence("#FFCC9980")
local color2 = minetest.get_color_escape_sequence("#FFCC99")

local function escape_hypertext(s)
	local e = s:find("[][><\\,;]")
	if e == nil then
		return s
	end
	local result = {}
	local b = 1
	while e ~= nil do
		if b < e then
			table.insert(result, s:sub(b, e - 1))
		end
		local c = s:sub(e, e)
		if c == "\\" then
			table.insert(result, "\\\\\\")
		elseif c == "<" or c == ">" then
			table.insert(result, "\\\\")
		else
			table.insert(result, "\\")
		end
		b = e
		e = s:find("[][><\\,;]", b + 1)
	end
	if b < #s then
		table.insert(result, s:sub(b, -1))
	end
	return table.concat(result)
end

local escape_hypertext_replacements = {
	["\\"] = "\\\\\\\\",
	["<"] = "\\\\<",
	[">"] = "\\\\>",
	[";"] = "\\;",
	[","] = "\\,",
	["["] = "\\[",
	["]"] = "\\]",
}

local function escape_hypertext2(s)
	local result  = s:gsub("[][><\\,;]", escape_hypertext_replacements)
	return result
end

-- \\ => \\\\\\\\
-- < => \\\\<
-- ; => \\;
-- , => \\,
-- ] => \\]
-- [ => \\[
]]

local active_nodenames = {
"advtrains:across_on",
"advtrains:track_swl_cr",
"advtrains:track_swl_cr_45",
"advtrains:track_swl_st",
"advtrains:track_swl_st_45",
"advtrains:track_swr_cr",
"advtrains:track_swr_cr_45",
"advtrains:track_swr_st",
"advtrains:track_swr_st_45",
"auto_tree_tap:off",
"auto_tree_tap:on",
"clothing:dirty_water_source",
"clothing:mannequin_stand",
"cottages:window_shutter_closed",
"cottages:window_shutter_open",
"craftable_lava:hot_stone",
"default:cactus",
"default:cobble",
"default:dirt",
"default:dry_dirt_with_dry_grass",
"default:lava_flowing",
"default:lava_source",
"default:mossycobble",
"default:papyrus",
"default:river_water_source",
"default:stone",
"default:stone_with_coal",
"default:water_source",
"elevator:elevator_off",
"elevator:elevator_on",
"group:flora",
"group:growing",
"group:mushroom",
"group:pipe_to_update",
"group:portable_tl",
"group:radioactive",
"group:spreading_dirt_type",
"group:streets_light",
"group:technic_machine",
"group:tnt",
"group:tube_to_update",
"group:vacuum_tube",
"group:water",
"group:waterable",
"handdryer:xa5",
"homedecor:coffee_maker",
"homedecor:microwave_oven",
"homedecor:microwave_oven_active",
"homedecor:microwave_oven_active_locked",
"homedecor:microwave_oven_locked",
"homedecor:oven",
"homedecor:oven_active",
"homedecor:oven_active_locked",
"homedecor:oven_locked",
"homedecor:oven_steel",
"homedecor:oven_steel_active",
"homedecor:oven_steel_active_locked",
"homedecor:oven_steel_locked",
"ch_extras:world_anchor",
"mesecons_hydroturbine:hydro_turbine_off",
"mesecons_hydroturbine:hydro_turbine_on",
"mesecons_solarpanel:solar_panel_off",
"mesecons_solarpanel:solar_panel_on",
"mesecons_torch:mesecon_torch_off",
"mesecons_torch:mesecon_torch_on",
"mobs:beehive",
"moreblocks:horizontal_jungle_tree",
"moreblocks:horizontal_tree",
"moretrees:apple_tree_trunk_sideways",
"moretrees:beech_trunk_sideways",
"moretrees:birch_trunk_sideways",
"moretrees:cedar_trunk_sideways",
"moretrees:date_palm_ffruit_trunk",
"moretrees:date_palm_fruit_trunk",
"moretrees:date_palm_mfruit_trunk",
"moretrees:date_palm_trunk_sideways",
"moretrees:fir_trunk_sideways",
"moretrees:jungletree_trunk_sideways",
"moretrees:oak_trunk_sideways",
"moretrees:palm_fruit_trunk",
"moretrees:palm_fruit_trunk_gen",
"moretrees:palm_trunk_sideways",
"moretrees:poplar_trunk_sideways",
"moretrees:rubber_tree_trunk_empty",
"moretrees:rubber_tree_trunk_empty_sideways",
"moretrees:rubber_tree_trunk_sideways",
"moretrees:sequoia_trunk_sideways",
"moretrees:spruce_trunk_sideways",
"new_campfire:campfire_active",
"new_campfire:campfire_active_with_grille",
"new_campfire:fireplace_with_embers",
"new_campfire:fireplace_with_embers_with_grille",
"ontime_clocks:frameless_black",
"ontime_clocks:frameless_gold",
"ontime_clocks:frameless_white",
"ontime_clocks:green_digital",
"ontime_clocks:red_digital",
"ontime_clocks:white",
"pipeworks:entry_block_empty",
"pipeworks:entry_block_loaded",
"pipeworks:entry_panel_empty",
"pipeworks:entry_panel_loaded",
"pipeworks:flow_sensor_empty",
"pipeworks:flow_sensor_loaded",
"pipeworks:fountainhead",
"pipeworks:fountainhead_pouring",
"pipeworks:pipe_1_empty",
"pipeworks:pipe_1_loaded",
"pipeworks:pipe_10_empty",
"pipeworks:pipe_10_loaded",
"pipeworks:pipe_2_empty",
"pipeworks:pipe_2_loaded",
"pipeworks:pipe_3_empty",
"pipeworks:pipe_3_loaded",
"pipeworks:pipe_4_empty",
"pipeworks:pipe_4_loaded",
"pipeworks:pipe_5_empty",
"pipeworks:pipe_5_loaded",
"pipeworks:pipe_6_empty",
"pipeworks:pipe_6_loaded",
"pipeworks:pipe_7_empty",
"pipeworks:pipe_7_loaded",
"pipeworks:pipe_8_empty",
"pipeworks:pipe_8_loaded",
"pipeworks:pipe_9_empty",
"pipeworks:pipe_9_loaded",
"pipeworks:spigot",
"pipeworks:spigot_pouring",
"pipeworks:straight_pipe_empty",
"pipeworks:straight_pipe_loaded",
"pipeworks:valve_off_empty",
"pipeworks:valve_on_empty",
"pipeworks:valve_on_loaded",
"stairs:slab_cobble",
"stairs:stair_cobble",
"stairs:stair_inner_cobble",
"stairs:stair_outer_cobble",
"streets:roadwork_blinking_light_off",
"streets:roadwork_blinking_light_on",
"streets:roadwork_delineator_light_off_top",
"streets:roadwork_delineator_light_on_top",
"technic:coal_alloy_furnace",
"technic:coal_alloy_furnace_active",
"technic:corium_flowing",
"technic:corium_source",
"technic:hv_nuclear_reactor_core_active",
"technic:power_monitor",
"technic:switching_station",
"tnt:gunpowder",
"walls:cobble",
}

local function command(player_name, param)
	local pos = vector.round(minetest.get_player_by_name(player_name):get_pos())
	local _, counts = minetest.find_nodes_in_area(vector.offset(pos, -64, -64, -64), vector.offset(pos, 64, 64, 64), active_nodenames, false)
	for name, count in pairs(counts) do
		if count > 0 then
			print("- "..name..": "..count.."x")
		end
	end
	return true
end










def = {
	params = "[text]",
	description = "spustí právě testovanou akci pro účely vývoje serveru (jen pro Administraci)",
	privs = {server = true},
	func = command,
}
minetest.register_chatcommand("test", def)
