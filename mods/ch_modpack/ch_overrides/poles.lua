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

if minetest.get_modpath("moreblocks") then
	local def = {
		description = "cvičná vychýlená tyč",
		tiles = {{name = "default_wood.png", backface_culling = true}},
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, panel = 19},
		sounds = default.node_sound_wood_defaults(),
		node_box = {
			type = "fixed",
			fixed = {
				{-0.53125, -0.5, -0.53125, -0.46875, 0.5, -0.46875},
				{-2/16, -2/16, -2/16, 2/16, 2/16, 2/16},
			},
		},
		-- selection_box = minetest.registered_nodes["moreblocks:panel_wood_special"].selection_box,
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, -0.28125, 0.5, -0.28125},
		},
		collision_box = {
			type = "fixed",
			fixed = {-0.53125, -0.5, -0.53125, -0.46875, 0.5, -0.46875},
		},
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type == "node" then
				local old_node = minetest.get_node(pointed_thing.under)
				if minetest.get_item_group(old_node.name, "panel") == 19 then
					return minetest.item_place(itemstack, placer, pointed_thing, old_node.param2)
				end
			end
			return stairsplus.rotate_node_aux(itemstack, placer, pointed_thing)
		end,
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
end

print("[ch_overrides/walls] "..counter.." nodes overriden")
