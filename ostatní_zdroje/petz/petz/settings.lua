local modpath = ...

local settings = Settings(modpath .. "/petz.conf")
local user = Settings(modpath .. "/user.conf")

-- All the settings definitions
local settings_def = {
	{
	name = "petz_list",
	type = "string",
	split = true,
	default = "",
	},
	{
	name = "remove_list",
	type = "string",
	split = true,
	default = "",
	},
	{
	name = "disable_monsters",
	type = "boolean",
	default = false,
	},
	--Performance
	{
	name = "speed_up",
	type = "boolean",
	default = true,
	},
	--Tamagochi Mode
	{
	name = "tamagochi_mode",
	type = "boolean",
	default = true,
	},
	{
	name = "tamagochi_check_time",
	type = "number",
	default = 2400,
	},
	{
	name = "tamagochi_reduction_factor",
	type = "number",
	default = 0.3,
	},
	{
	name = "tamagochi_punch_rate",
	type = "number",
	default = 0.3,
	},
	{
	name = "tamagochi_feed_hunger_rate",
	type = "number",
	default = 0.3,
	},
	{
	name = "tamagochi_brush_rate",
	type = "number",
	default = 0.2,
	},
	{
	name = "tamagochi_beaver_oil_rate",
	type = "number",
	default = 0.2,
	},
	{
	name = "tamagochi_lashing_rate",
	type = "number",
	default = 0.2,
	},
	{
	name = "tamagochi_hungry_warning",
	type = "number",
	default = 0.5,
	},
	{
	name = "tamagochi_check_if_player_online",
	type = "boolean",
	default = true,
	},
	{
	name = "tamagochi_safe_nodes",
	type = "string",
	split = true,
	default = "",
	},
	--Damage Engine
	{
	name = "check_enable_damage",
	type = "boolean",
	default = false,
	},
	{
	name = "no_damage_in_protected",
	type = "boolean",
	default = false,
	},
	--Enviromental Damage
	{
	name = "air_damage",
	type = "number",
	default = 1,
	},
	{
	name = "igniter_damage",
	type = "number",
	default = 1,
	},
	--Nametag Background
	{
	name = "tag_background",
	type = "boolean",
	default = false,
	},
	--Capture Mobs
	{
	name = "lasso",
	type = "string",
	split = false,
	default = "petz:lasso",
	},
	{
	name = "rob_mobs",
	type = "boolean",
	default = false,
	},
	--Shears
	{
	name = "shears",
	type = "string",
	split = false,
	default = "petz:shears",
	},
	--Look at
	{
	name = "look_at",
	type = "boolean",
	default = true,
	},
	--Selling
	{
	name = "selling",
	type = "boolean",
	default = true,
	},
	--Disable Kennel
	{
	name = "disable_kennel",
	type = "boolean",
	default = false,
	},
	--Spawn
	{
	name = "spawn_interval",
	type = "number",
	default = 30,
	},
	{
	name = "spawn_chance",
	type = "number",
	default = 0.3,
	},
	{
	name = "max_mobs",
	type = "number",
	default = 60,
	},
	{
	name = "max_per_species",
	type = "number",
	default = 10,
	},
	{
	name = "spawn_peaceful_monsters_ratio",
	type = "number",
	default = 0.7,
	delimit =
		{
		min = 0.0,
		max = 1.0,
		}
	},
	{
	name = "no_spawn_in_protected",
	type = "boolean",
	default = false,
	},
	--Parent Search
	{
	name = "parent_search",
	type = "boolean",
	default = true,
	},
	--Lifetime
	{
	name = "lifetime",
	type = "number",
	default = -1,
	},
	{
	name = "lifetime_variability",
	type = "number",
	default = 0.2,
	},
	{
	name = "lifetime_only_non_tamed",
	type = "boolean",
	default = false,
	},
	{
	name = "lifetime_avoid_non_breedable",
	type = "boolean",
	default = false,
	},
	--Lay Eggs
	{
	name = "lay_egg_timing",
	type = "number",
	default = 1200,
	},
	{
	name = "max_laid_eggs",
	type = "number",
	default = 10,
	},
	{
	name = "hatch_egg_timing",
	type = "number",
	default = 500,
	},
	--Misc Random Sound Chance
	{
	name = "misc_sound_chance",
	type = "number",
	default = 50,
	},
	{
	name = "max_hear_distance",
	type = "number",
	default = 8,
	},
	--Fly Behaviour
	{
	name = "fly_check_time",
	type = "number",
	default = 3,
	},
	--Breed Engine
	{
	name = "pregnant_count",
	type = "number",
	default = 5,
	},
	{
	name = "pregnancy_time",
	type = "number",
	default = 300,
	},
	{
	name = "growth_time",
	type = "number",
	default = 1200,
	},
	{
	name = "seed_only_owners",
	type = "boolean",
	default = true,
	},
	{
	name = "disable_syringe",
	type = "boolean",
	default = false,
	},
	--Punch Effect
	{
	name = "colorize_punch",
	type = "boolean",
	default = true,
	},
	{
	name = "punch_color",
	type = "string",
	split = false,
	default = "#FF0000",
	},
	--Blood
	{
	name = "blood",
	type = "boolean",
	default = false,
	},
	--Poop
	{
	name = "poop",
	type = "boolean",
	default = true,
	},
	{
	name = "poop_rate",
	type = "number",
	default = 600,
	},
	{
	name = "poop_decay",
	type = "number",
	default = 1200,
	},
	--Ants
	{
	name = "lay_antegg_timing",
	type = "number",
	default = 1200,
	},
	{
	name = "max_laid_anteggs",
	type = "number",
	default = 500,
	},
	{
	name = "ant_population",
	type = "number",
	default = 5,
	},
	--Smoke particles when die
	{
	name = "death_effect",
	type = "boolean",
	default = true,
	},
	--Look_at
	{
	name = "look_at",
	type = "boolean",
	default = true,
	},
	{
	name = "look_at_random",
	type = "number",
	default = 10,
	},
	--Cobweb
	{
	name = "cobweb_decay",
	type = "number",
	default = 1200,
	},
	--Mount
	{
	name = "pointable_driver",
	type = "boolean",
	default = true,
	},
	{
	name = "gallop_time",
	type = "number",
	default = 20,
	},
	{
	name = "gallop_recover_time",
	type = "number",
	default = 60,
	},
	--Sleeping
	{
	name = "sleeping",
	type = "boolean",
	default = true,
	},
	--Herding
	{
	name = "herding",
	type = "boolean",
	default = true,
	},
	{
	name = "herding_timing",
	type = "number",
	default = 3,
	},
	{
	name = "herding_members_distance",
	type = "number",
	default = 5,
	},
	{
	name = "herding_shepherd_distance",
	type = "number",
	default = 5,
	},
	--Lashing
	{
	name = "lashing_tame_count",
	type = "number",
	default = 3,
	},
	--Spinning Wheel
	{
	name = "silk_to_bobbin",
	type = "number",
	default = 3,
	},
	--Bee Stuff
	{
	name = "initial_honey_beehive",
	type = "number",
	default = 3,
	},
	{
	name = "max_honey_beehive",
	type = "number",
	default = 10,
	},
	{
	name = "max_bees_beehive",
	type = "number",
	default = 3,
	},
	{
	name = "bee_outing_ratio",
	type = "number",
	default = 20,
	},
	{
	name = "worker_bee_delay",
	type = "number",
	default = 300,
	},
	{
	name = "protect_beehive",
	type = "boolean",
	default = false,
	},
	--Weapons
	{
	name = "pumpkin_grenade_damage",
	type = "number",
	default = 8,
	},
	--Horseshoes
	{
	name = "horseshoe_speedup",
	type = "number",
	default = 0.2,
	},
	--Population Control
	{
	name = "max_tamed_by_owner",
	type = "number",
	default = -1,
	},
	--Lycanthropy
	{
	name = "lycanthropy",
	type = "boolean",
	default = true,
	},
	{
	name = "lycanthropy_infection_chance_by_wolf",
	type = "number",
	default = 200,
	},
	{
	name = "lycanthropy_infection_chance_by_werewolf",
	type = "number",
	default = 10,
	},
	--Server Cron Tasks
	{
	name = "clear_mobs_time",
	type = "number",
	default = 0,
	},
	--Go Back Home Distance
	{
	name = "back_home_distance",
	type = "number",
	default = 50,
	},
}

--General Hardcoded Settings-->
petz.settings.visual = "mesh"
petz.settings.visual_size = {x=10, y=10}
petz.settings.rotate = 0

for key, value in ipairs(settings_def) do
	if value.type == "string" then
		if not(value.default) then
			value.default = ''
		end
		local str = user:get(value.name) or settings:get(value.name, value.default)
		if str and value.split then
			str = string.split(str)
		end
		petz.settings[value.name] = str
	elseif value.type == "number" then
		if not(value.default) then
			value.default = -1
		end
		local number = tonumber(user:get(value.name) or settings:get(value.name, value.default))
		if value.delimit then
			number = kitz.delimit_number(number, {min=value.delimit.min, max=value.delimit.max})
		end
		petz.settings[value.name] = number
	elseif value.type == "boolean" then
		if not(value.default) then
			value.default = false
		end
		local bool_value = user:get_bool(value.name) --can return true/false or nil
		if bool_value == nil then
			petz.settings[value.name] = settings:get_bool(value.name, value.default)
		else
			petz.settings[value.name] = bool_value
		end
	end
end

--Selling
petz.settings.selling_exchange_items = string.split(user:get("selling_exchange_items") or settings:get("selling_exchange_items", ""), ",")
petz.settings.selling_exchange_items_list = {}
for i = 1, #petz.settings.selling_exchange_items do
	local exchange_item = petz.settings.selling_exchange_items[i]
	local exchange_item_description = minetest.registered_items[exchange_item].description
	local exchange_item_inventory_image = minetest.registered_items[exchange_item].inventory_image
	if exchange_item_description then
		petz.settings.selling_exchange_items_list[i] = {name = exchange_item, description = exchange_item_description, inventory_image = exchange_item_inventory_image}
	end
end

--Mobs Specific
for i = 1, #petz.settings["petz_list"] do --load the settings
	local petz_type = petz.settings["petz_list"][i]
	petz.settings[petz_type.."_spawn"] = user:get_bool(petz_type.."_spawn")
	if petz.settings[petz_type.."_spawn"] == nil then
		petz.settings[petz_type.."_spawn"] = settings:get_bool(petz_type.."_spawn", false)
	end
	petz.settings[petz_type.."_spawn_chance"]  = tonumber(user:get(petz_type.."_spawn_chance") or settings:get(petz_type.."_spawn_chance")) or 0.0
	petz.settings[petz_type.."_spawn_nodes"]  = user:get(petz_type.."_spawn_nodes") or settings:get(petz_type.."_spawn_nodes") or ""
	petz.settings[petz_type.."_spawn_biome"]  = user:get(petz_type.."_spawn_biome") or settings:get(petz_type.."_spawn_biome") or "default"
	petz.settings[petz_type.."_spawn_herd"] = tonumber(user:get(petz_type.."_spawn_herd") or settings:get(petz_type.."_spawn_herd")) or 1
	petz.settings[petz_type.."_seasonal"] = user:get(petz_type.."_seasonal") or settings:get(petz_type.."_seasonal") or ""
	petz.settings[petz_type.."_follow"] = user:get(petz_type.."_follow") or settings:get(petz_type.."_follow") or nil
	petz.settings[petz_type.."_breed"]  = user:get(petz_type.."_breed") or settings:get(petz_type.."_breed") or nil
	petz.settings[petz_type.."_predators"]  = user:get(petz_type.."_predators") or settings:get(petz_type.."_predators") or ""
	petz.settings[petz_type.."_preys"] = user:get(petz_type.."_preys") or settings:get(petz_type.."_preys") or ""
	petz.settings[petz_type.."_colorized"] = user:get_bool(petz_type.."_colorized")
	if petz.settings[petz_type.."_colorized"] == nil then
		petz.settings[petz_type.."_colorized"] = settings:get_bool(petz_type.."_colorized", false)
	end
	petz.settings[petz_type.."_copulation_distance"] = tonumber(user:get(petz_type.."_copulation_distance") or settings:get(petz_type.."_copulation_distance")) or 0.0
	petz.settings[petz_type.."_convert"] = user:get(petz_type.."_convert") or settings:get(petz_type.."_convert") or nil
	petz.settings[petz_type.."_convert_to"] = user:get(petz_type.."_convert_to") or settings:get(petz_type.."_convert_to") or nil
	petz.settings[petz_type.."_convert_count"] = tonumber(user:get(petz_type.."_convert_count") or settings:get(petz_type.."_convert_count")) or nil
	petz.settings[petz_type.."_lifetime"] = tonumber(user:get(petz_type.."_lifetime") or settings:get(petz_type.."_lifetime")) or nil
	petz.settings[petz_type.."_disable_spawn"] = user:get_bool(petz_type.."_disable_spawn")
	if petz.settings[petz_type.."_disable_spawn"] == nil then
		petz.settings[petz_type.."_disable_spawn"] = settings:get_bool(petz_type.."_disable_spawn", false)
	end
	if petz_type == "beaver" then
		petz.settings[petz_type.."_create_dam"] = user:get_bool(petz_type.."_create_dam")
		if petz.settings[petz_type.."_create_dam"] == nil then
			petz.settings[petz_type.."_create_dam"] = settings:get_bool(petz_type.."_create_dam", false)
		end
		settings:get_bool(petz_type.."_create_dam", false)
	elseif petz_type == "silkworm" then
		petz.settings[petz_type.."_lay_egg_on_node"] = user:get(petz_type.."_lay_egg_on_node") or settings:get(petz_type.."_lay_egg_on_node") or ""
		petz.settings[petz_type.."_chrysalis_min_time"] = tonumber(user:get(petz_type.."_chrysalis_min_time") or settings:get(petz_type.."_chrysalis_min_time")) or 1200
		petz.settings[petz_type.."_chrysalis_max_time"] = tonumber(user:get(petz_type.."_chrysalis_max_time") or settings:get(petz_type.."_chrysalis_min_time")) or 1500
	end
end
