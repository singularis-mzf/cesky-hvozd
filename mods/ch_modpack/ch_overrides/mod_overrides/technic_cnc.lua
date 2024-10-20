--[[
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
	"bakedclay:blue",
	"cottages:black",
	"cottages:brown",
	"cottages:red",
	"cottages:reet",
	"darkage:slate_tile",
	"default:acacia_wood",
	"default:aspen_wood",
	"default:copperblock",
	"default:junglewood",
	"default:obsidian_glass",
	"default:pine_wood",
	"default:steelblock",
	"default:wood",
	"farming:straw",
	"moreblocks:cactus_checker",
	"moreblocks:copperpatina",
	"technic:cast_iron_block",
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
		ndef.groups = ch_core.override_groups(ndef.groups, {not_in_creative_inventory = 0})
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
]]
