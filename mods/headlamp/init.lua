local battery_life = 30000
local battery_drain = 100

local function try_charge_headlamp(stack)
	if stack:get_name() ~= "headlamp:headlamp_on" then
		return nil
	end
	local meta = stack:get_meta()
	local metadata = minetest.deserialize(meta:get_string("")) or {}
	if not metadata.charge or metadata.charge < battery_drain then
		return nil
	else
		metadata.charge = metadata.charge - battery_drain
		meta:set_string("", minetest.serialize(metadata))
		technic.set_RE_wear(stack, metadata.charge, battery_life)
		return stack
	end
end

function clear_headlamp_cache(player, index, stack)
	local online_charinfo = ch_core.online_charinfo[player:get_player_name()]
	if online_charinfo then
		online_charinfo.headlamp_last_update = 0
	end
end

local function globalstep(player, player_name, online_charinfo, offline_charinfo, us_time)
	local last_timestamp = online_charinfo.headlamp_last_update or 0
	if us_time < last_timestamp + 5000000 then
		return
	end
	online_charinfo.headlamp_last_update = us_time
	local inv = minetest.get_inventory({type = "detached", name = player_name.."_clothing"})
	if not inv then
		minetest.log("warning", "Detached inventory "..player_name.."_clothing not found!")
		return
	end
	local had_headlamp = online_charinfo.has_headlamp
	if had_headlamp == nil then
		had_headlamp = false
	end
	local has_headlamp = inv:contains_item("clothing", ItemStack("headlamp:headlamp_on"), false)

	if has_headlamp and not minetest.is_creative_enabled(player_name) then
		-- try to charge the headlamp
		has_headlamp = false
		local list_size = inv:get_size("clothing")
		for i = 1, list_size do
			local stack = inv:get_stack("clothing", i)
			if stack:get_name() == "headlamp:headlamp_on" then
				local result = try_charge_headlamp(stack)
				if result == nil then
					minetest.log("info", "Cannot charge a headlamp_on")
					inv:set_stack("clothing", i, ItemStack("headlamp:headlamp_off"))
					clothing:update_player_skin_from_inv(player, inv)
				else
					-- headlamp charged, but not changed, so we do not need to
					-- update player skin
					inv:set_stack("clothing", i, result)
					-- print("DEBUG: headlamp at "..i.." successfully charged")
					has_headlamp = true
					break
				end
			end
		end
	end

	if has_headlamp ~= had_headlamp then
		online_charinfo.has_headlamp = has_headlamp
		if has_headlamp then
			-- turn the light on
			ch_core.set_player_light(player_name, "headlamp", minetest.LIGHT_MAX)
		else
			-- turn the light off
			ch_core.set_player_light(player_name, "headlamp", 0)
		end
	end
end

ch_core.register_player_globalstep(globalstep)

-- Item registration
--------------------------------------------------
local def = {
	description = "čelovka (vypnutá)",
	inventory_image = "headlamp_inv_headlamp_off.png",
	uv_image = "headlamp_headlamp_off.png",
	on_use = function(stack)
		stack:set_name("headlamp:headlamp_on")
		return stack
	end,
	-- common part:
	groups = {clothing = 1},
	wear_represents = "technic_RE_charge",
	on_refill = technic.refill_RE_charge,
}
minetest.register_tool("headlamp:headlamp_off", table.copy(def))
technic.register_power_tool("headlamp:headlamp_off", battery_life)

def.description = "čelovka (zapnutá)"
def.inventory_image = "headlamp_inv_headlamp_on.png"
def.uv_image = "headlamp_headlamp_on.png"
-- def.light_source = 14
def.on_use = function(stack)
	stack:set_name("headlamp:headlamp_off")
	return stack
end
def.on_load = clear_headlamp_cache
def.on_equip = clear_headlamp_cache
def.on_unequip = clear_headlamp_cache

minetest.register_tool("headlamp:headlamp_on", def)
technic.register_power_tool("headlamp:headlamp_on", battery_life)

-- Crafting recipe
--------------------------------------------------

minetest.register_craft({
	output = "headlamp:headlamp_off",
	recipe = {
		{"farming:string", "technic:battery", "farming:string"},
		{"technic:rubber", "morelights:bulb", "technic:rubber"},
		{"farming:string", "technic:stainless_steel_ingot", "farming:string"},
	}
})
