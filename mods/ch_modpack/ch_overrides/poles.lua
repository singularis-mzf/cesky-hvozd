--[[
POLES

Tento soubor definuje výčet vodorovných „tyčí“ a přidává jim vlastnost
check_for_horiz_pole, díky díž budou jako tyče rozpoznány módem signs_lib.

]]

local horiz_poles = {
	"ch_extras:fence_rail_hv",
	"cherrytree:fence_rail",
	"chestnuttree:fence_rail",
	"default:fence_rail_acacia_wood",
	"default:fence_rail_aspen_wood",
	"default:fence_rail_junglewood",
	"default:fence_rail_pine_wood",
	"default:fence_rail_wood",
	"ebony:fence_rail",
	"moretrees:apple_tree_fence_rail",
	"moretrees:beech_fence_rail",
	"moretrees:birch_fence_rail",
	"moretrees:cedar_fence_rail",
	"moretrees:date_palm_fence_rail",
	"moretrees:fir_fence_rail",
	"moretrees:oak_fence_rail",
	"moretrees:palm_fence_rail",
	"moretrees:poplar_fence_rail",
	"moretrees:rubber_tree_fence_rail",
	"moretrees:sequoia_fence_rail",
	"moretrees:spruce_fence_rail",
	"plumtree:fence_rail",
	"willow:fence_rail",
}

local counter = 0
local override = {check_for_horiz_pole = function(pos, node, def, pole_pos, pole_node, pole_def) return true end}

for _, node_name in ipairs(horiz_poles) do
	if minetest.registered_nodes[node_name] then
		minetest.override_item(node_name, override)
		counter = counter + 1
	end
end

print("[ch_overrides/walls] "..counter.." nodes overriden")
