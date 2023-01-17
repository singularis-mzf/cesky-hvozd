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

-- Add a training pole

local odef = minetest.registered_nodes["moreblocks:panel_wood_special"]
if minetest.get_modpath("moreblocks") and odef ~= nil then
	local def = {
		description = "cvičná vychýlená tyč",
		tiles = {{name = "default_wood.png", align_style = "world", backface_culling = true}},
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = odef.sunlight_propagates,
		is_ground_content = odef.is_ground_content,
		groups = ch_core.override_groups(odef.groups, {not_in_creative_inventory = 0}),
		sounds = odef.sounds,
		node_box = {
			type = "fixed",
			fixed = {
				odef.node_box.fixed, -- {-0.53125, -0.5, -0.53125, -0.46875, 0.5, -0.46875},
				{-2/16, -2/16, -2/16, 2/16, 2/16, 2/16},
			},
		},
		selection_box = odef.selection_box,
		collision_box = odef.node_box,
		on_place = odef.on_place,
	}
	minetest.register_node("ch_overrides:training_pole", def)
	minetest.register_craft({
		output = "ch_overrides:training_pole 5",
		recipe = {
			{"", "moreblocks:panel_wood_special", ""},
			{"moreblocks:panel_wood_special", "moreblocks:panel_wood_special", "moreblocks:panel_wood_special"},
			{"", "moreblocks:panel_wood_special", ""},
		},
	})
	minetest.register_craft({
		output = "moreblocks:panel_wood_special",
		recipe = {{"ch_overrides:training_pole"}},
	})

	odef = minetest.registered_nodes["moreblocks:panel_wood_l"]
	if odef ~= nil then
		def = table.copy(def)
		def.description = "cvičná vychýlená tyč L"
		def.groups = ch_core.override_groups(odef.groups, {not_in_creative_inventory = 0})
		def.node_box = {
			type = "fixed",
			fixed = table.copy(odef.node_box.fixed),
		}
		table.insert(def.node_box.fixed, {-2/16, -2/16, -2/16, 2/16, 2/16, 2/16})
		def.selection_box = odef.selection_box
		def.collision_box = odef.node_box
		minetest.register_node("ch_overrides:training_pole_l", def)
		minetest.register_craft({
			output = "ch_overrides:training_pole_l 5",
			recipe = {
				{"", "moreblocks:panel_wood_l", ""},
				{"moreblocks:panel_wood_l", "moreblocks:panel_wood_l", "moreblocks:panel_wood_l"},
				{"", "moreblocks:panel_wood_l", ""},
			},
		})
		minetest.register_craft({
			output = "moreblocks:panel_wood_l",
			recipe = {{"ch_overrides:training_pole_l"}},
		})
	end
end

print("[ch_overrides/walls] "..counter.." nodes overriden")
