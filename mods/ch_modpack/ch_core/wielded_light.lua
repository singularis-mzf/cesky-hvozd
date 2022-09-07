ch_core.open_submod("wielded_light", {data = true, lib = true, nodes = true})

local valid_numbers = {}

for i = 0, minetest.LIGHT_MAX do
	valid_numbers[i] = true
end

function ch_core.set_player_light(player_name, slot, light_level)
	local ll_1 = light_level or minetest.LIGHT_MAX
	local ll = tonumber(ll_1)
	if not ll then
		minetest.log("warning", "Invalid light_level: "..ll_1)
		return false
	end
	local online_charinfo = ch_core.online_charinfo[player_name]
	if not online_charinfo or not valid_numbers[ll] then
		return false
	end
	local slots = online_charinfo.wielded_lights
	if not slots then
		slots = {}
		online_charinfo.wielded_lights = slots
	end
	if ll == 0 then
		slots[slot] = nil
	else
		slots[slot] = ll
	end
end

ch_core.close_submod("wielded_light")
