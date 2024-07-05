-- ALIASES

if minetest.get_modpath("moretrees") and not minetest.get_modpath("cherrytree") then
	local list = {
		["cherrytree:trunk"] = "moretrees:cherrytree_trunk",
		["cherrytree:wood"] = "moretrees:cherrytree_planks",
		["cherrytree:trunk_noface"] = "moretrees:cherrytree_trunk_noface",
		["cherrytree:trunk_allfaces"] = "moretrees:cherrytree_trunk_allfaces",
		["cherrytree:mese_post_light"] = "moretrees:cherrytree_mese_post_light",
		["cherrytree:blossom_leaves"] = "moretrees:cherrytree_leaves",
		["cherrytree:sapling"] = "moretrees:cherrytree_sapling",
		["cherrytree:sapling_ongen"] = "moretrees:cherrytree_sapling_ongen",
		["cherrytree:gate_open"] = "moretrees:cherrytree_gate_open",
		["cherrytree:gate_closed"] = "moretrees:cherrytree_gate_closed",
		["cherrytree:fence"] = "moretrees:cherrytree_fence",
		["cherrytree:fence_rail"] = "moretrees:cherrytree_fence_rail",
		["cherrytree:cherries"] = "moretrees:cherry",
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
			name = stairsplus:get_shape("moretrees:cherrytree_planks", category, alternate)
			if name ~= nil then
				minetest.register_alias("cherrytree:"..category.."_wood"..alternate, name)
			end
			name = stairsplus:get_shape("moretrees:cherrytree_trunk_noface", category, alternate)
			if name ~= nil then
				minetest.register_alias("cherrytree:"..category.."_trunk_noface"..alternate, name)
			end
		end
	end
end

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
