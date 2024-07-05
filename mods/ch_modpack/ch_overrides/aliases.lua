-- ALIASES

if minetest.get_modpath("moretrees") and not minetest.get_modpath("willow") then
	local list = {
		["willow:trunk"] = "moretrees:willow_trunk",
		["willow:wood"] = "moretrees:willow_planks",
		["willow:trunk_noface"] = "moretrees:willow_trunk_noface",
		["willow:trunk_allfaces"] = "moretrees:willow_trunk_allfaces",
		["willow:mese_post_light"] = "moretrees:willow_mese_post_light",
		["willow:leaves"] = "moretrees:willow_leaves",
		["willow:sapling"] = "moretrees:willow_sapling",
		["willow:sapling_ongen"] = "moretrees:willow_sapling_ongen",
		["willow:gate_open"] = "moretrees:willow_gate_open",
		["willow:gate_closed"] = "moretrees:willow_gate_closed",
		["willow:fence"] = "moretrees:willow_fence",
		["willow:fence_rail"] = "moretrees:willow_fence_rail",
	}
	for alias, name in pairs(list) do
		if minetest.registered_items[name] ~= nil then
			minetest.register_alias(alias, name)
		end
	end

	-- stairsplus shapes
	local name
	for category, alternates in pairs(stairsplus.defs) do
		for alternate, _ in pairs(alternates) do
			name = stairsplus:get_shape("moretrees:willow_planks", category, alternate)
			if name ~= nil then
				minetest.register_alias("willow:"..category.."_wood"..alternate, name)
			end
			name = stairsplus:get_shape("moretrees:willow_trunk_noface", category, alternate)
			if name ~= nil then
				minetest.register_alias("willow:"..category.."_trunk_noface"..alternate, name)
			end
		end
	end
end
