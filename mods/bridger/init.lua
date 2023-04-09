local S = minetest.get_translator("bridger")

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local function analyze_look(placer) -- => coord, shift
	local vlook = placer:get_look_vertical() * 8 / math.pi -- => -4..4
	local hlook = placer:get_look_horizontal() * 4 / math.pi -- => 0..8
	if vlook <= -3 then
		return "y", 1
	elseif vlook >= 3 then
		return "y", -1
	elseif hlook < 1 or hlook >= 7 then
		return "z", 1
	elseif hlook < 3 then
		return "x", -1
	elseif hlook < 5 then
		return "z", -1
	else
		return "x", 1
	end
end

local function scaffolding_on_place(itemstack, placer, pointed_thing)
	if placer and placer:is_player() then
		local placement_logic = "normal"
		-- If there is no pointed_thing or player points from inside the node,
		-- place the next scaffolding according to look direction, starting from
		-- the player position.
		if pointed_thing.type == "nothing" then
			pointed_thing.type = "node"
			pointed_thing.under = vector.round(placer:get_pos())
			pointed_thing.above = vector.copy(pointed_thing.under)
			placement_logic = "by_look"
		elseif pointed_thing.type == "node" then
			local above, under = pointed_thing.above, pointed_thing.under
			if minetest.get_node(under).name == "bridger:scaffolding" and above.x == under.x and above.y == under.y and above.z == under.z then
				placement_logic = "by_look"
			end
		else
			return
		end
		if placement_logic == "by_look" then
			local coord, shift = analyze_look(placer)
			local above = pointed_thing.above
			for i = 1, 8 do
				above[coord] = above[coord] + shift
				if minetest.get_node(above).name ~= "bridger:scaffolding" then
					break
				end
			end
		end
	end

	return minetest.item_place(itemstack, placer, pointed_thing)
end

minetest.register_node("bridger:scaffolding", {
	description = S("Scaffolding"),
	drawtype = "glasslike_framed_optional",
	tiles = {"bridges_scaffolding.png", "bridges_scaffolding_detail.png"},
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	climbable = true,
	groups = {cracky = 3, oddly_breakable_by_hand = 3, dig_immediate = 3},
	sounds = default.node_sound_wood_defaults(),
	node_placement_prediction = "",
	on_place = scaffolding_on_place,
	on_secondary_use = scaffolding_on_place,
	_ch_help = "Lešení slouží ke snadnému pohybu po stavbě. Staví se pravým klikem, rozebírá levým.\nPravý klik do volného prostoru nebo uvnitř stávajícího bloku lešení postaví lešení směrem pohledu až do vzdálenosti 8 metrů.\nLešením lze volně prolézat libovolným směrem.",
})


dofile(minetest.get_modpath("bridger") .. "/nodes.lua")
dofile(minetest.get_modpath("bridger") .. "/crafts.lua")

if minetest.settings:get_bool("Bridger_enable_alias") then
	dofile(minetest.get_modpath("bridger") .. "/alias.lua")
end

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
