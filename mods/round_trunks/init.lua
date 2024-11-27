ch_base.open_mod(minetest.get_current_modname())
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

round_trunks = {}

-- Constant
local round_trunk_def = {
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

function round_trunks.trunks_overrider(itemname)
	if minetest.registered_nodes[itemname] then
		minetest.override_item(itemname, round_trunk_def)
	end
end

round_trunks.trunks_overrider('default:acacia_tree')
round_trunks.trunks_overrider('default:aspen_tree')
-- round_trunks.trunks_overrider('default:jungletree')
-- round_trunks.trunks_overrider('default:pine_tree')
round_trunks.trunks_overrider('default:tree')
round_trunks.trunks_overrider('moretrees:ebony_trunk')
round_trunks.trunks_overrider('moretrees:beech_trunk')
round_trunks.trunks_overrider('moretrees:cherrytree_trunk')
round_trunks.trunks_overrider('moretrees:chestnut_tree_trunk')
round_trunks.trunks_overrider('moretrees:date_palm_trunk')
round_trunks.trunks_overrider('moretrees:date_palm_mfruit_trunk')
round_trunks.trunks_overrider('moretrees:date_palm_ffruit_trunk')
round_trunks.trunks_overrider('moretrees:fir_trunk')
round_trunks.trunks_overrider('moretrees:palm_trunk')
round_trunks.trunks_overrider('moretrees:poplar_trunk')
round_trunks.trunks_overrider('moretrees:plumtree_trunk')
round_trunks.trunks_overrider('plumtree:trunk')


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

--[[
minetest.override_item('default:acacia_tree', t_TEXTURES_ACACIA_TREE)
minetest.override_item('default:aspen_tree', t_TEXTURES_ASPEN_TREE)
minetest.override_item('default:pine_tree', t_TEXTURES_PINE_TREE)
minetest.override_item('default:tree', t_TEXTURES_DEFAULT_TREE)
]]
ch_base.close_mod(minetest.get_current_modname())
