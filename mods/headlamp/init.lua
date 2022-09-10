
local has_technic = minetest.get_modpath("technic")

local drain_inv = minetest.settings:get_bool("headlamp_drain_inventory", false)
local battery_life = tonumber(minetest.settings:get("headlamp_battery_life")) or 180
local battery_drain = math.floor(65535 / (battery_life * 60)) * 5

-- Helper function to make code neater
local function merge(t1, t2)
	local t = table.copy(t1)
	for k, v in pairs(t2) do
		t[k] = v
	end
	return t
end

-- Battery draining logic
--------------------------------------------------

local function use_battery(stack)
	if stack:get_wear() >= (65535 - battery_drain) then
		stack:set_name("headlamp:headlamp_off")
		return false
	end
	stack:add_wear(battery_drain)
	return true
end

local function update_wielded(player)
	local stack = player:get_wielded_item()
	if stack:get_name() == "headlamp:headlamp_on" then
		use_battery(stack)
		player:set_wielded_item(stack)
	end
end

local function update_inventory(player)
	local inv = player:get_inventory()
	if not inv:contains_item("main", "headlamp:headlamp_on") then
		return  -- Skip checking every stack
	end
	for i=1, inv:get_size("main") do
		local stack = inv:get_stack("main", i)
		if stack:get_name() == "headlamp:headlamp_on" then
			use_battery(stack)
			inv:set_stack("main", i, stack)
		end
	end
end

local function update_armor(player)
	local name, inv = armor:get_valid_player(player)
	if not name then
		return  -- Armor not initialized yet
	end
	if not inv:contains_item("armor", "headlamp:headlamp_on") then
		return  -- Skip checking every stack
	end
	for i=1, inv:get_size("armor") do
		local stack = inv:get_stack("armor", i)
		if stack:get_name() == "headlamp:headlamp_on" then
			local success = use_battery(stack)
			inv:set_stack("armor", i, stack)
			armor:save_armor_inventory(player)
			if not success then
				armor:set_player_armor(player)
			end
			return  -- There can only be one
		end
	end
end

local timer = 0

minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < 5 then return end -- Doesn't need a fast update, every 5 seconds is enough
	timer = 0
	for _, player in pairs(minetest.get_connected_players()) do
		if not minetest.is_creative_enabled(player:get_player_name()) then
			update_armor(player)
			if drain_inv then
				update_inventory(player)
			else
				update_wielded(player)
			end
		end
	end
end)

-- Item registration
--------------------------------------------------

local base_def = {
	groups = {armor_head = 1, armor_heal = 0, armor_use = 0},
	armor_groups = {fleshy = 2},  -- Headlamp is terrible armor, but it's better than nothing
	on_secondary_use = function(stack, player)
		return armor:equip(player, stack)
	end,
	on_place = function(stack, player, pointed)
		if pointed.type == "node" and player and not player:get_player_control().sneak then
			local node = minetest.get_node(pointed.under)
			local ndef = minetest.registered_nodes[node.name]
			if ndef and ndef.on_rightclick then
				return ndef.on_rightclick(pointed.under, node, player, stack, pointed)
			end
		end
		return armor:equip(player, stack)
	end,
}

if has_technic then
	-- Battery values are now charge values instead of wear
	battery_life = battery_life * 600
	battery_drain = 50
	-- Different code for different APIs
	if technic.plus then
		use_battery = function(stack)
			if technic.use_RE_charge(stack, battery_drain) then
				return true
			end
			stack:set_name("headlamp:headlamp_off")
			return false
		end
		base_def.max_charge = battery_life
	else
		use_battery = function(stack)
			local meta = stack:get_meta()
			local metadata = minetest.deserialize(meta:get_string("")) or {}
			if not metadata.charge or metadata.charge <= battery_drain then
				stack:set_name("headlamp:headlamp_off")
				return false
			end
			metadata.charge = metadata.charge - battery_drain
			meta:set_string("", minetest.serialize(metadata))
			technic.set_RE_wear(stack, metadata.charge, battery_life)
			return true
		end
		base_def.wear_represents = "technic_RE_charge"
		base_def.on_refill = technic.refill_RE_charge
	end
end

local off_def = merge(base_def, {
	description = "Headlamp (Off)",
	inventory_image = "headlamp_inv_headlamp_off.png",
	on_use = function(stack, player)
		-- Turn headlamp on if there is enough battery left
		if minetest.is_creative_enabled(player:get_player_name()) or use_battery(stack) then
			stack:set_name("headlamp:headlamp_on")
		end
		return stack
	end,
})

local on_def = merge(base_def, {
	description = "Headlamp (On)",
	inventory_image = "headlamp_inv_headlamp_on.png",
	groups = {armor_head = 1, armor_heal = 0, armor_use = 0, not_in_creative_inventory = 1},
	light_source = 14,
	on_use = function(stack)
		-- Turn headlamp off
		stack:set_name("headlamp:headlamp_off")
		return stack
	end,
})

if has_technic and technic.plus then
	technic.register_power_tool("headlamp:headlamp_off", off_def)
	technic.register_power_tool("headlamp:headlamp_on", on_def)
else
	minetest.register_tool("headlamp:headlamp_off", off_def)
	minetest.register_tool("headlamp:headlamp_on", on_def)
	if has_technic then
		technic.register_power_tool("headlamp:headlamp_off", battery_life)
		technic.register_power_tool("headlamp:headlamp_on", battery_life)
	end
end

-- Crafting recipe
--------------------------------------------------

if minetest.get_modpath("farming") then
	if has_technic then
		-- Somewhat realistic recipe
		minetest.register_craft({
			output = "headlamp:headlamp_off",
			recipe = {
				{"farming:string", "technic:battery", "farming:string"},
				{"technic:rubber", "technic:lv_led", "technic:rubber"},
				{"farming:string", "technic:stainless_steel_ingot", "farming:string"},
			}
		})
	elseif minetest.get_modpath("default") then
		-- Magic mese powered headlamp
		minetest.register_craft({
			output = "headlamp:headlamp_off",
			recipe = {
				{"farming:string", "farming:string", "farming:string"},
				{"farming:string", "default:mese_crystal", "farming:string"},
				{"farming:string", "default:steel_ingot", "farming:string"},
			}
		})
	end
end
