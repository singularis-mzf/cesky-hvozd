-- Original code comes from walkin_light mod by Echo
-- http://minetest.net/forum/viewtopic.php?id=2621

local flashlight_max_charge = 30000
local flashlight_consumption = 100
local S = technic.getter
local has_wielded_light = minetest.get_modpath("wielded_light")

-- node:
local def = {
	drawtype = "glasslike",
	tiles = {"technic_light.png"},
	paramtype = "light",
	groups = {not_in_creative_inventory = 1},
	drop = "",
	walkable = false,
	buildable_to = true,
	sunlight_propagates = true,
	light_source = minetest.LIGHT_MAX,
	is_ground_content = false,
	pointable = false,
}
minetest.register_node("technic:light", def)
minetest.register_alias("technic:light_off", "air")

-- tool:
technic.register_power_tool("technic:flashlight", flashlight_max_charge)
minetest.register_tool("technic:flashlight", {
	description = S("Flashlight"),
	_ch_help = "Svítí kolem vás, když ji máte na výběrové liště.\nElektrický nástroj — před použitím nutno nabít.",
	inventory_image = "technic_flashlight.png",
	stack_max = 1,
	wear_represents = "technic_RE_charge",
	on_refill = technic.refill_RE_charge,
})

minetest.register_craft({
	output = "technic:flashlight",
	recipe = {
		{"technic:rubber",                "default:glass",   "technic:rubber"},
		{"technic:stainless_steel_ingot", "technic:battery", "technic:stainless_steel_ingot"},
		{"",                              "technic:battery", ""}
	}
})

local function check_for_flashlight(player, skip_charge)
	local flashlights = ch_core.predmety_na_liste(player, true)["technic:flashlight"]

	if flashlights then
		local is_creative = minetest.is_creative_enabled(player:get_player_name())
		local inv = player:get_inventory()
		local hotbar = inv:get_list("main")
		for i, flashlight_index in ipairs(flashlights) do
			local item = hotbar[flashlight_index]
			local meta = minetest.deserialize(item:get_meta():get_string(""))
			local charge = meta and meta.charge
			if charge and charge >= flashlight_consumption then
				if not skip_charge and not is_creative then
					meta.charge = charge - flashlight_consumption
					technic.set_RE_wear(item, meta.charge, flashlight_max_charge)
					item:get_meta():set_string("", minetest.serialize(meta))
					inv:set_stack("main", flashlight_index, item)
				end
				return true
			end
		end
	end

	return false
end

if has_wielded_light then
	-- wielded_light.register_item_light("technic:light", minetest.LIGHT_MAX, false)

	--[[ local function wl_player_lightstep(player)
		if check_for_flashlight(player) then
			wielded_light.track_user_entity(player, "flashlight", "technic:light")
		else
			wielded_light.track_user_entity(player, "flashlight", "default:cobble")
		end
	end ]]

	-- wielded_light.register_player_lightstep(wl_player_lightstep)
	local charge_counter = 0
	minetest.register_globalstep(function(dtime)
		charge_counter = charge_counter + dtime
		local skip_charge = charge_counter < 5
		if not skip_charge then
			charge_counter = charge_counter - 5
		end

		for i, player in pairs(minetest.get_connected_players()) do
			local player_name = player:get_player_name()
			local flashlight_weared = check_for_flashlight(player, skip_charge)
			if flashlight_weared then
				ch_core.set_player_light(player_name, "flashlight", minetest.LIGHT_MAX)
			else
				ch_core.set_player_light(player_name, "flashlight", 0)
			end
		end
	end)

else
	local player_positions = {}
	local was_wielding = {}
	local light_to_water = {["technic:light"] = ""}
	local water_to_light = {["air"] = "technic:light"}
	local water_source_to_flowing = {}


	minetest.register_on_joinplayer(function(player)
		local player_name = player:get_player_name()
		local pos = player:get_pos()
		local rounded_pos = vector.round(pos)
		rounded_pos.y = rounded_pos.y + 1
		player_positions[player_name] = rounded_pos
		was_wielding[player_name] = true
	end)

	minetest.register_on_leaveplayer(function(player)
		local player_name = player:get_player_name()
		local pos = player_positions[player_name]
		local nodename = minetest.get_node(pos).name
		local new_node = light_to_water[nodename]
		if new_node then
			if new_node == "" then
				minetest.remove_node(pos)
			else
				minetest.swap_node(pos, {name = new_node})
			end
		end
		player_positions[player_name] = nil
	end)

	minetest.register_globalstep(function(dtime)
		for i, player in pairs(minetest.get_connected_players()) do
			local player_name = player:get_player_name()
			local flashlight_weared = check_for_flashlight(player)
			local pos = player:get_pos()
			local rounded_pos = vector.round(pos)
			rounded_pos.y = rounded_pos.y + 1
			local old_pos = player_positions[player_name]
			local player_moved = old_pos and not vector.equals(old_pos, rounded_pos)
			if not old_pos then
				old_pos = rounded_pos
				player_moved = true
			end

			-- Remove light, flashlight weared out or was removed from hotbar
			if was_wielding[player_name] and not flashlight_weared then
				was_wielding[player_name] = false
				local node = minetest.get_node_or_nil(old_pos)
				local new_node = node and light_to_water[node.name]
				if new_node then
					if new_node == "" then
						minetest.remove_node(old_pos)
					else
						minetest.swap_node(old_pos, {name = new_node})
					end
				end
			elseif (player_moved or not was_wielding[player_name]) and flashlight_weared then
				local node = minetest.get_node_or_nil(rounded_pos)
				local new_node = node and water_to_light[node.name]
				if new_node then
					local node_below = minetest.get_node(vector.new(rounded_pos.x, rounded_pos.y - 1, rounded_pos.z)).name
					if node_below ~= (water_source_to_flowing[node.name] or "ignore") then
						-- place a new light
						if node == "air" then
							minetest.set_node(rounded_pos, {name = new_node})
						else
							minetest.swap_node(rounded_pos, {name = new_node})
						end
					end
				end
				node = minetest.get_node_or_nil(old_pos)
				new_node = node and light_to_water[node.name]
				if new_node then
					if new_node == "" then
						minetest.remove_node(old_pos)
					else
						minetest.swap_node(old_pos, {name = new_node})
					end
				end
				player_positions[player_name] = rounded_pos
				was_wielding[player_name] = true
			end
		end
	end)

	local function register_light_in_water(name, water_source, water_flowing)
		local orig_def = minetest.registered_nodes[water_source]
		if not orig_def then
			minetest.log("error", "Required water node "..water_source.." does not exist!")
			return false
		end
		local def = table.copy(orig_def)
		def.groups = table.copy(def.groups)
		def.groups.not_in_creative_inventory = 1
		def.liquid_alternative_source = name
		def.liquid_alternative_flowing = name
		def.liquid_range = 0
		def.paramtype = "light"
		def.light_source = minetest.LIGHT_MAX
		def.sunlight_propagates = true
		minetest.register_node(name, def)
	
		water_to_light[water_source] = name
		light_to_water[name] = water_source
		water_source_to_flowing[water_source] = water_flowing
		return true
	end

	register_light_in_water("technic:light_water_source", "default:water_source", "default:water_flowing")
	register_light_in_water("technic:light_river_water_source", "default:river_water_source", "default:river_water_flowing")
end
