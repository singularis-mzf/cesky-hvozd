-- BUSHY LEAVES
-- supported programs:
--		"none" => no model change (but makes leaves climbable, non-walkable and waving)
--		"plantlike" => use drawtype = "plantlike"
--      "degrotate" => use drawtype = "mesh", paramtype2 degrotate and model from Always Greener and LBM to set param2
--		"colordegrotate" => (not supported now, for future use)

local leaves_nodes = {
	["darkage:dry_leaves"] = "degrotate_nostick", -- special (no sticks!)
	-- default
	["default:acacia_bush_leaves"] = "plantlike_nostick",
	["default:acacia_leaves"] = "plantlike_nostick",
	["default:aspen_leaves"] = "degrotate",
	["default:blueberry_bush_leaves"] = "degrotate_nostick",
	["default:blueberry_bush_leaves_with_berries"] = "degrotate_nostick",
	["default:bush_leaves"] = "degrotate_nostick",
	["default:leaves"] = "degrotate",

	["default:jungleleaves"] = "degrotate",
	["default:pine_bush_needles"] = "degrotate",
	["default:pine_needles"] = "degrotate",

	-- Ethereal
	["ethereal:bananaleaves"] = "degrotate_nostick",

	-- More Trees
	["moretrees:apple_tree_leaves"] = "degrotate",
	["moretrees:beech_leaves"] = "degrotate",
	["moretrees:birch_leaves"] = "degrotate",
	["moretrees:cedar_leaves"] = "degrotate",
	["moretrees:date_palm_leaves"] = "degrotate",
	["moretrees:fir_leaves"] = "degrotate",
	["moretrees:fir_leaves_bright"] = "degrotate",
	["moretrees:oak_leaves"] = "degrotate",
	["moretrees:palm_leaves"] = "degrotate",
	["moretrees:poplar_leaves"] = "degrotate",
	["moretrees:sequoia_leaves"] = "degrotate",
	["moretrees:spruce_leaves"] = "degrotate",
	["moretrees:willow_leaves"] = "degrotate",
	["moretrees:rubber_tree_leaves"] = "degrotate",
	["moretrees:jungletree_leaves_red"] = "degrotate",
	["moretrees:jungletree_leaves_yellow"] = "degrotate",
	["moretrees:cherrytree_leaves"] = "degrotate",
	["moretrees:chestnut_tree_leaves"] = "degrotate",
	["moretrees:ebony_leaves"] = "degrotate",
	["moretrees:plumtree_leaves"] = "degrotate",
}

local program
local programs = {}

local node_box_full_node = {
	type = "fixed",
	fixed = { -8/16, -8/16, -8/16,  8/16,  8/16,  8/16 },
}

local function update_degrotate_param2(pos, node)
	if node.param2 < 2 then
		node.param2 = node.param2 + 2 * math.random(1, 119)
		minetest.swap_node(pos, node)
	end
end

-- Define overriding programs:

-- currently unimplemented programs:
programs.cheap = {}
programs.bushy = {}
programs.cheap_nostick = {}
programs.bushy_nostick = {}

-- "none" => no model change (but is make leaves climbable, non-walkable and waving)
program = {
	climbable = true,
	walkable = false,
	waving = 2,
	move_resistance = 1,
	collision_box = node_box_full_node,
}
programs.none = program

-- "plantlike" => use drawtype = "plantlike"
program = table.copy(programs.none)
program.drawtype = "plantlike"
program.visual_scale = 1.4

programs.plantlike = program
programs.plantlike_nostick = program

-- "degrotate" => use drawtype = "mesh", paramtype2 degrotate and model from Always Greener and LBM to set param2

program = table.copy(programs.none)
program.use_texture_alpha = "clip"
program.drawtype = "mesh"
program.mesh = "awg_tree_leaves.obj"
program.paramtype2 = "degrotate"
program.after_place_node = function(pos, placer, itemstack, pointed_thing)
	local node = minetest.get_node(pos)
	if leaves_nodes[node.name] == "degrotate" and node.param2 < 2 then
		node.param2 = 1
		return update_degrotate_param2(pos, node)
	end
end

programs.degrotate = program
programs.degrotate_nostick = program

local counter = 0
local lbm_nodenames = {}

for name, program_name in pairs(leaves_nodes) do
	local def = minetest.registered_nodes[name]
	program = programs[program_name]
	if program == nil then
		error("Invalid program: "..program_name)
	end
	if program_name == "degrotate" or program_name == "degrotate_nostick" then
		table.insert(lbm_nodenames, name)
	end
	if def ~= nil then
		if string.find(program_name, "_nostick$") == nil then
			-- add sticks to drops:
			program = table.copy(program)
			if type(def.drop) ~= "table" then
				error("Unexpected type of drop for "..name.."!")
			end
			local new_drop_items = {
				{items = {"default:stick"}, rarity = 16}
			}
			program.drop = def.drop
			table.insert_all(new_drop_items, program.drop.items)
			program.drop.items = new_drop_items
		end

		minetest.override_item(name, program)
		counter = counter + 1
	end
end

if #lbm_nodenames > 0 then
	local lbm = {
		label = "Upgrade leaves",
		name = "ch_overrides:upgrade_leaves_v1",
		nodenames = lbm_nodenames,
		action = update_degrotate_param2,
	}
	minetest.register_lbm(lbm)
end

print("["..minetest.get_current_modname().."] "..counter.." bushy leaves overriden, "..#lbm_nodenames.." for LBM upgrade")
