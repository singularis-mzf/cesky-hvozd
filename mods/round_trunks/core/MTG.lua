--[[
    Round Tree Trunks - Turns cubic tree trunks into cylindrical.
	Copyright © 2018, 2020 Hamlet and contributors.

	Licensed under the EUPL, Version 1.2 or – as soon they will be
	approved by the European Commission – subsequent versions of the
	EUPL (the "Licence");
	You may not use this work except in compliance with the Licence.
	You may obtain a copy of the Licence at:

	https://joinup.ec.europa.eu/software/page/eupl
	https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32017D0863

	Unless required by applicable law or agreed to in writing,
	software distributed under the Licence is distributed on an
	"AS IS" basis,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
	implied.
	See the Licence for the specific language governing permissions
	and limitations under the Licence.

--]]


local pr_Overrider = function()

	-- Constants

	-- Whether if textures' overrider should be used.
	local b_roundTrunksTextures =
		minetest.settings:get_bool('round_trunks_textures')

	if (b_roundTrunksTextures == nil) then
		b_roundTrunksTextures = true
	end

	-- Whether if X-shaped leaves must be applied.
	local b_roundTrunksLeaves =
		minetest.settings:get_bool('round_trunks_leaves')

	if (b_roundTrunksLeaves == nil) then
		b_roundTrunksLeaves = false
	end


	local t_ROUND_TRUNK = {
		drawtype = 'mesh',
		mesh = 'round_trunks_trunk.obj',
		paramtype = 'light',
		paramtype2 = 'facedir',
		selection_box = {
			type = 'fixed',
			fixed = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4}
		},
		collision_box = {
			type = 'fixed',
			fixed = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4}
		}
	}


	-- X-shaped drawtype
	local t_ALTERNATIVE_LEAVES = {
		drawtype = 'plantlike',
		visual_scale = 1.0
	}


	-- Textures' replacers
	local t_TEXTURES_ACACIA_TREE = {
		tiles = {
			'round_trunks_acacia_tree_top.png',
			'round_trunks_acacia_tree_top.png',
			'default_acacia_tree.png',
			'default_acacia_tree.png',
			'default_acacia_tree.png',
			'default_acacia_tree.png'
		}
	}

	local t_TEXTURES_ASPEN_TREE = {
		tiles = {
			'round_trunks_aspen_tree_top.png',
			'round_trunks_aspen_tree_top.png',
			'default_aspen_tree.png',
			'default_aspen_tree.png',
			'default_aspen_tree.png',
			'default_aspen_tree.png'
		}
	}

	local t_TEXTURES_PINE_TREE = {
		tiles = {
			'round_trunks_pine_top.png',
			'round_trunks_pine_top.png',
			'default_pine_tree.png',
			'default_pine_tree.png',
			'default_pine_tree.png',
			'default_pine_tree.png'
		}
	}

	local t_TEXTURES_DEFAULT_TREE = {
		tiles = {
			'round_trunks_default_tree_top.png',
			'round_trunks_default_tree_top.png',
			'default_tree.png',
			'default_tree.png',
			'default_tree.png',
			'default_tree.png'
		}
	}


	-- Nodes to override
	local t_TREE_NODES = {
		'default:acacia_tree',
		'default:aspen_tree',
		'default:jungletree',
		'default:pine_tree',
		'default:tree'
	}

	local t_LEAVES = {
		'default:acacia_bush_leaves',
		'default:acacia_leaves',
		'default:aspen_leaves',
		'default:blueberry_bush_leaves',
		'default:blueberry_bush_leaves_with_berries',
		'default:bush_leaves',
		'default:jungleleaves',
		'default:leaves',
		'default:pine_bush_needles',
		'default:pine_needles'
	}


	--
	-- Overriders
	--

	-- Trunks overrider
	for i_element = 1, 5 do
		minetest.override_item(t_TREE_NODES[i_element], t_ROUND_TRUNK)
	end

	-- Textures' overriders
	if (b_roundTrunksTextures == true) then
		minetest.override_item('default:acacia_tree', t_TEXTURES_ACACIA_TREE)
		minetest.override_item('default:aspen_tree', t_TEXTURES_ASPEN_TREE)
		minetest.override_item('default:pine_tree', t_TEXTURES_PINE_TREE)
		minetest.override_item('default:tree', t_TEXTURES_DEFAULT_TREE)
	end

	-- Leaves' overrider
	if (b_roundTrunksLeaves == true) then
		for i_element = 1, 10 do
			minetest.override_item(t_LEAVES[i_element], t_ALTERNATIVE_LEAVES)
		end
	end
end


--
-- Main body
--

pr_Overrider()
