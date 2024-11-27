ch_base.open_mod(minetest.get_current_modname())
-- Bushes Mod by Mossmanikin, Evergreen, & Neuromancer
-- The initial code for this was taken from Mossmanikin's Grasses Mod,
-- then heavilly modified by Neuromancer for this mod.
-- Mossmanikin also greatly helped with providing samples for coding.
-- bush leaf textures are from VannessaE's moretrees mod.
-- (Leaf texture created by RealBadAngel or VanessaE)
-- Branch textures created by Neuromancer.

-- support for i18n
local S = minetest.get_translator("bushes")
abstract_bushes = {}

minetest.register_node("bushes:youngtree2_bottom", {
	description = S("Young Tree 2 (bottom)"),
	drawtype="nodebox",
	tiles = {"bushes_youngtree2trunk.png"},
	inventory_image = "bushes_youngtree2trunk_inv.png",
	wield_image = "bushes_youngtree2trunk_inv.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = true,
	node_box = {
		type = "fixed",
		fixed = {
			--{0.375000,-0.500000,-0.500000,0.500000,0.500000,-0.375000}, --NodeBox 1
			{-0.0612,-0.500000,-0.500000,0.0612,0.500000,-0.375000}, --NodeBox 1
		}
	},
	groups = {snappy=3,flammable=2},
	sounds = default.node_sound_leaves_defaults(),
})

local BushBranchCenter			= { {1,1}, {3,2} }
for _, def in pairs(BushBranchCenter) do
	local Num		= def[1]
	local TexNum	= def[2]
	minetest.register_node("bushes:bushbranches"..Num, {
		description = S("Bush Branches @1", Num),
		drawtype = "nodebox",
		tiles = {
			"bushes_leaves_"..TexNum..".png",
			"bushes_branches_center_"..TexNum..".png"
		},
		use_texture_alpha = "clip",
		node_box = {
			type = "fixed",
			fixed = {
				{0, -1/2, -1/2, -1/4, 1/2, 1/2},
				{0, -1/2, -1/2, 1/4, 1/2, 1/2}
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {-1/2, -1/2, -1/2, 1/2, 1/2, 1/2},
		},
		inventory_image = "bushes_branches_center_"..TexNum..".png",
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		groups = {
		--	tree=1, -- MM: disabled because some recipes use group:tree for trunks
			snappy=3,
			flammable=2,
			leaves=1,
		},
		sounds = default.node_sound_leaves_defaults(),
	})
end

local BushBranchSide			= { {2,1}, {4,2} }
for _, def in pairs(BushBranchSide) do
	local Num		= def[1]
	local TexNum	= def[2]
	minetest.register_node("bushes:bushbranches"..Num, {
		description = S("Bush Branches @1", Num),
		drawtype = "nodebox",
		tiles = {
--[[top]]	"bushes_leaves_"..TexNum..".png",
--[[bottom]]"bushes_branches_center_"..TexNum..".png",
--[[right]]	"bushes_branches_left_"..TexNum..".png",
--[[left]]	"bushes_branches_right_"..TexNum..".png", -- MM: We could also mirror the previous here,
--[[back]]	"bushes_branches_center_"..TexNum..".png",--		 unless U really want 'em 2 B different
--[[front]]	"bushes_branches_right_"..TexNum..".png"
		},
		use_texture_alpha = "clip",
		node_box = {
			type = "fixed",
			fixed = {
--				{ left	 , bottom	, front, right	 , top		 , back		}
				{0.137748,-0.491944, 0.5	,-0.125000,-0.179444,-0.007790}, --NodeBox 1
				{0.262748,-0.185995, 0.5	,-0.237252, 0.126505,-0.260269}, --NodeBox 2
				{0.500000, 0.125000, 0.5	,-0.500000, 0.500000,-0.500000}, --NodeBox 3
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {-1/2, -1/2, -1/2, 1/2, 1/2, 1/2},
		},
		inventory_image = "bushes_branches_right_"..TexNum..".png",
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		groups = {
		--	tree=1, -- MM: disabled because some recipes use group:tree for trunks
			snappy=3,
			flammable=2,
			leaves=1,
		},
		sounds = default.node_sound_leaves_defaults(),
	})
end

local BushLeafNode			= { 1, 2 }
for _, Num in ipairs(BushLeafNode) do
	minetest.register_node("bushes:BushLeaves"..Num, {
		description = S("Bush Leaves @1", Num),
		drawtype = "allfaces_optional",
		tiles = {"bushes_leaves_"..Num..".png"},
		paramtype = "light",
		groups = {	-- MM: Should we add leafdecay?
			snappy=3,
			flammable=2,
		},
		sounds = default.node_sound_leaves_defaults(),
	})
end

abstract_bushes.grow_bush = function(pos)
	local leaf_type = math.random(1,2)
	local bush_side_height = math.random(0,1)
		local chance_of_bush_node_right = math.random(1,10)
		if chance_of_bush_node_right> 5 then
			local right_pos = {x=pos.x+1, y=pos.y+bush_side_height, z=pos.z}
			abstract_bushes.grow_bush_node(right_pos,3,leaf_type)
		end
		local chance_of_bush_node_left = math.random(1,10)
		if chance_of_bush_node_left> 5 then
			bush_side_height = math.random(0,1)
			local left_pos = {x=pos.x-1, y=pos.y+bush_side_height, z=pos.z}
			abstract_bushes.grow_bush_node(left_pos,1,leaf_type)
		end
		local chance_of_bush_node_front = math.random(1,10)
		if chance_of_bush_node_front> 5 then
			bush_side_height = math.random(0,1)
			local front_pos = {x=pos.x, y=pos.y+bush_side_height, z=pos.z+1}
			abstract_bushes.grow_bush_node(front_pos,2,leaf_type)
		end
		local chance_of_bush_node_back = math.random(1,10)
		if chance_of_bush_node_back> 5 then
			bush_side_height = math.random(0,1)
			local back_pos = {x=pos.x, y=pos.y+bush_side_height, z=pos.z-1}
			abstract_bushes.grow_bush_node(back_pos,0,leaf_type)
		end

abstract_bushes.grow_bush_node(pos,5,leaf_type)
end


abstract_bushes.grow_bush_node = function(pos,dir, leaf_type)
	local right_here = {x=pos.x, y=pos.y+1, z=pos.z}
	local above_right_here = {x=pos.x, y=pos.y+2, z=pos.z}

	local bush_branch_type = 2

	-- MM: I'm not sure if it's slower now than before...
	if dir ~= 5 and leaf_type == 1 then
		bush_branch_type = 2
	end
	if dir ~= 5 and leaf_type == 2 then
		bush_branch_type = 4
	end
	if dir == 5 and leaf_type == 1 then
		bush_branch_type = 1
		dir = 1
	end
	if dir == 5 and leaf_type == 2 then
		bush_branch_type = 3
		dir = 1
	end

	if minetest.get_node(right_here).name == "air"	-- instead of check_air = true,
	or minetest.get_node(right_here).name == "default:junglegrass" then
		minetest.swap_node(right_here, {name="bushes:bushbranches"..bush_branch_type , param2=dir})
						--minetest.chat_send_all("leaf_type: (" .. leaf_type .. ")")
		minetest.swap_node(above_right_here, {name="bushes:BushLeaves"..leaf_type})
		local chance_of_high_leaves = math.random(1,10)
		if chance_of_high_leaves> 5 then
			local two_above_right_here = {x=pos.x, y=pos.y+3, z=pos.z}
							--minetest.chat_send_all("leaf_type: (" .. leaf_type .. ")")
			minetest.swap_node(two_above_right_here, {name="bushes:BushLeaves"..leaf_type})
		end
	end
end

abstract_bushes.grow_youngtree2 = function(pos)
	local height = math.random(4,5)
	abstract_bushes.grow_youngtree_node2(pos,height)
end

abstract_bushes.grow_youngtree_node2 = function(pos, height)
	pos = vector.new(pos.x, pos.y, pos.z)
	local right_here = {x=pos.x, y=pos.y+1, z=pos.z}
	if height == 4 then
		pos.y = pos.y - 1
	end
	local above_right_here = {x=pos.x, y=pos.y+2, z=pos.z}
	local two_above_right_here = {x=pos.x, y=pos.y+3, z=pos.z}
	local three_above_right_here = {x=pos.x, y=pos.y+4, z=pos.z}

	if minetest.get_node(right_here).name == "air"	-- instead of check_air = true,
	or minetest.get_node(right_here).name == "default:junglegrass" then
			local two_above_right_here_south = {x=pos.x, y=pos.y+3, z=pos.z-1}
			local three_above_right_here_south = {x=pos.x, y=pos.y+4, z=pos.z-1}
			minetest.swap_node(right_here, {name="bushes:youngtree2_bottom"})
			minetest.swap_node(above_right_here, {name="bushes:youngtree2_bottom"})
			minetest.swap_node(two_above_right_here, {name="bushes:bushbranches2"	, param2=2})
			minetest.swap_node(two_above_right_here_south, {name="bushes:bushbranches2"	, param2=0})
			minetest.swap_node(three_above_right_here, {name="bushes:BushLeaves1" })
			minetest.swap_node(three_above_right_here_south, {name="bushes:BushLeaves1" })
	end
end

local sapling_def = {
	description = S("Young Tree Sapling"),
	drawtype="nodebox",
	tiles = {"bushes_youngtree2trunk.png"},
	inventory_image = "bushes_youngtree2trunk_inv.png",
	wield_image = "bushes_youngtree2trunk_inv.png",
	paramtype = "light",
	walkable = false,
	is_ground_content = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.0612,-0.500000,-0.500000,0.0612,0.500000,-0.375000}, --NodeBox 1
		}
	},
	on_timer = abstract_bushes.grow_youngtree2,
	groups = {snappy = 2, dig_immediate = 3, flammable = 2,
		attached_node = 1, sapling = 1},
	sounds = default.node_sound_leaves_defaults(),

	on_construct = function(pos)
		minetest.get_node_timer(pos):start(math.random(30, 150))
	end,

	on_place = function(itemstack, placer, pointed_thing)
		itemstack = default.sapling_on_place(itemstack, placer, pointed_thing,
			"bushes:yt_sapling",
			-- minp, maxp to be checked, relative to sapling pos
			-- minp_relative.y = 1 because sapling pos has been checked
			{x = -2, y = 1, z = -2},
			{x = 2, y = 6, z = 2},
			-- maximum interval of interior volume check
			4)

		return itemstack
	end,
}

minetest.register_node("bushes:yt_sapling", sapling_def)
ch_base.close_mod(minetest.get_current_modname())
