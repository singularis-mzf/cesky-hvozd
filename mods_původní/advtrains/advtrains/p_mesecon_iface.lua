-- p_mesecon_iface.lua
-- Mesecons interface by overriding the switch

if minetest.get_modpath("mesecons_switch") == nil then return end

minetest.override_item("mesecons_switch:mesecon_switch_off", {
	groups = {
		dig_immediate=2,
		save_in_at_nodedb=1,
	},
	on_rightclick = function (pos, node)
		advtrains.ndb.swap_node(pos, {name="mesecons_switch:mesecon_switch_on", param2=node.param2})
		mesecon.receptor_on(pos)
		minetest.sound_play("mesecons_switch", {pos=pos})
	end,
	advtrains = {
		node_state = "off",
		node_state_map = { on = "mesecons_switch:mesecon_switch_on", off = "mesecons_switch:mesecon_switch_off" },
		node_on_switch_state = function(pos, new_node, old_state, new_state)
			if advtrains.is_node_loaded(pos) then
				mesecon.receptor_on(pos)
			end
		end,
		on_updated_from_nodedb = function(pos, node)
			mesecon.receptor_off(pos)
		end,
	},
})

minetest.override_item("mesecons_switch:mesecon_switch_on", {
	groups = {
		dig_immediate=2,
		save_in_at_nodedb=1,
		not_in_creative_inventory=1,
	},
	on_rightclick = function (pos, node)
		advtrains.ndb.swap_node(pos, {name="mesecons_switch:mesecon_switch_off", param2=node.param2})
		mesecon.receptor_off(pos)
		minetest.sound_play("mesecons_switch", {pos=pos})
	end,
	advtrains = {
		node_state = "on",
		node_state_map = { on = "mesecons_switch:mesecon_switch_on", off = "mesecons_switch:mesecon_switch_off" },
		node_on_switch_state = function(pos, new_node, old_state, new_state)
			if advtrains.is_node_loaded(pos) then
				mesecon.receptor_off(pos)
			end
		end,
		node_fallback_state = "off",
		on_updated_from_nodedb = function(pos, node)
			mesecon.receptor_on(pos)
		end,
	},
})
