-- Original code comes from walkin_light mod by Echo
-- http://minetest.net/forum/viewtopic.php?id=2621

local flashlight_max_charge = 30000

local S = technic.getter

technic.register_power_tool("technic:flashlight", flashlight_max_charge)

minetest.register_alias("technic:light_off", "air")

minetest.register_tool("technic:flashlight", {
	description = S("Flashlight"),
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


local player_positions = {}
local was_wielding = {}

local function check_for_flashlight(player)
	local flashlights = ch_core.predmety_na_liste(player, true)["technic:flashlight"]

	if flashlights then
		if minetest.is_creative_enabled(player:get_player_name()) then
			return true
		end
		local inv = player:get_inventory()
		local hotbar = inv:get_list("main")
		local i = 1
		local flashlight_index = flashlights[i]

		while flashlight_index do
			local item = hotbar[flashlight_index]
			local meta = minetest.deserialize(item:get_metadata())
			local charge = meta and meta.charge
			if charge and charge >= 2 then
				meta.charge = charge - 2
				technic.set_RE_wear(item, meta.charge, flashlight_max_charge)
				item:set_metadata(minetest.serialize(meta))
				inv:set_stack("main", flashlight_index, item)
				return true
			else
				i = i + 1
				flashlight_index = flashlights[i]
			end
		end
	end

	return false
end

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
	if nodename == "technic:light" then
		minetest.remove_node(pos)
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
			if node and node.name == "technic:light" then
				minetest.remove_node(old_pos)
			end
		elseif (player_moved or not was_wielding[player_name]) and flashlight_weared then
			local node = minetest.get_node_or_nil(rounded_pos)
			if node and node.name == "air" then
				minetest.set_node(rounded_pos, {name="technic:light"})
			end
			node = minetest.get_node_or_nil(old_pos)
			if node and node.name == "technic:light" then
				minetest.remove_node(old_pos)
			end
			player_positions[player_name] = rounded_pos
			was_wielding[player_name] = true
		end
	end
end)

minetest.register_node("technic:light", {
	drawtype = "glasslike",
	tiles = {"technic_light.png"},
	paramtype = "light",
	groups = {not_in_creative_inventory = 1},
	drop = "",
	walkable = false,
	buildable_to = true,
	sunlight_propagates = true,
	light_source = minetest.LIGHT_MAX,
	pointable = false,
})
