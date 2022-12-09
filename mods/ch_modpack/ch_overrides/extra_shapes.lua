if minetest.get_modpath("technic_cnc") then

	local box = {
		type = "fixed",
		fixed = {
			{0.25, -0.5, -1.5, 0.5, -0.25, 1.5},
			{0, -0.25, -1.5, 0.25, 0, 1.5},
			{-0.25, 0, -1.5, 0, 0.25, 1.5},
			{-0.5, 0.25, -1.5, -0.25, 0.5, 1.5},
		}
	}

	local recipeitems = {
		"bakedclay:black",
		"cottages:black",
		"cottages:brown",
		"cottages:red",
		"cottages:reet",
		"default:acacia_wood",
		"default:aspen_wood",
		"default:copperblock",
		"default:junglewood",
		"default:obsidian_glass",
		"default:pine_wood",
		"default:steelblock",
		"default:tinblock",
		"default:wood",
		"moreblocks:cactus_checker",
		"moreblocks:copperpatina",
		"technic:cast_iron_block",
		"technic:stainless_steel_block",
		"technic:zinc_block",
	}

	for _, recipeitem in ipairs(recipeitems) do
		local ndef = minetest.registered_nodes[recipeitem.."_technic_cnc_d45_slope_216"]
		if ndef then
			ndef = table.copy(ndef)
			ndef.description = ndef.description .. " (trojitý díl)"
			ndef.mesh = "technic_45_slope_216_3.obj"
			ndef.selection_box = box
			ndef.collision_box = box
			local groups = table.copy(ndef.groups or {})
			groups.not_in_creative_inventory = nil
			ndef.groups = groups
			minetest.register_node(":"..recipeitem.."_technic_cnc_d45_slope_216_3", ndef)
			minetest.register_craft({
				output = recipeitem.."_technic_cnc_d45_slope_216_3",
				recipe = {
					{recipeitem.."_technic_cnc_d45_slope_216", recipeitem.."_technic_cnc_d45_slope_216", recipeitem.."_technic_cnc_d45_slope_216"},
					{"", "", ""},
					{"", "", ""},
				}
			})
			minetest.register_craft({output = recipeitem.."_technic_cnc_d45_slope_216 3", recipe = {{recipeitem.."_technic_cnc_d45_slope_216_3"}}})
		else
			minetest.log("warning", "Expected node "..recipeitem.."_technic_cnc_d45_slope_216 does not exist for an extra shape!")
		end
	end
end
