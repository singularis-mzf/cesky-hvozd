--[[
    digiterms mod for Minetest - Digiline monitors using Display API / Font API
    (c) Pierre-Yves Rollo

    This file is part of digiterms.

    signs is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    signs is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with signs.  If not, see <http://www.gnu.org/licenses/>.
--]]

local node_def_defaults = {
	use_texture_alpha = "opaque",
	groups = { display_api = 1},
	-- on_place = display_api.on_place,
	on_destruct = display_api.on_destruct,
	on_rotate = signs_api.on_rotate,
	on_punch = function(pos, node, player, pointed_thing)
		signs_api.set_formspec(pos)
		display_api.update_entities(pos)
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("font", digiterms.font)
		signs_api.set_formspec(pos)
		display_api.on_construct(pos)
	end,
	on_receive_fields =  signs_api.on_receive_fields,
}

function superpose_table(base, exceptions)
  local result = table.copy(base)
  for key, value in pairs(exceptions) do
		if type(value) == 'table' then
      result[key] = superpose_table(result[key] or {}, value)
    else
      result[key] = value
    end
  end
  return result
end

function digiterms.register_monitor(nodename, nodedef, nodedefon, nodedefoff)
	local ndef = superpose_table(node_def_defaults, nodedef)
	if nodedefon and nodedefoff then
		ndef.on_punch = function(pos, node)
			display_api.on_destruct(pos)
			local meta = minetest.get_meta(pos)
			-- meta:set_string("display_text", nil)
			node.name = nodename.."_off"
			minetest.swap_node(pos, node)
		end
		minetest.register_node(nodename, superpose_table(ndef, nodedefon))

		-- Register the corresponding Off node
		if ndef.display_entities then
			ndef.display_entities["signs:display_text"] = nil
		end
		ndef.drop = nodename
		ndef.groups = table.copy(ndef.groups)
		ndef.groups.not_in_creative_inventory = 1
		ndef.on_destruct = nil
		ndef.on_punch = function(pos, node)
			node.name = nodename
			minetest.swap_node(pos, node)
			display_api.update_entities(pos)
		end
		minetest.register_node(nodename..'_off', superpose_table(ndef, nodedefoff))
	else
		minetest.register_node(nodename, ndef)
	end
end
