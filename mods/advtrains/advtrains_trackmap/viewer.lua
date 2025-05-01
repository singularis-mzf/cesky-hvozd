-- viewer.lua
-- standalone chatcommand/tool trackmap viewer window

local tm = advtrains.trackmap

local function node_left_click(pos, pname)
	local node_ok, conns, rail_y=advtrains.get_rail_info_at(pos)
	if not node_ok then
		minetest.chat_send_player(pname, "Toto není kolej!")
		return
	end
	
	local function node_callback(npos, conns, connid)
		if vector.equals(pos, npos) then
			return {color = "red"}
		end
		return nil
	end

	local gridtbl = tm.generate_grid_map(pos, node_callback)
	local fslabel = tm.render_grid_formspec(20, 20, gridtbl, {x=pos.x-35, z=pos.z-22}, 70, 44)
	
	minetest.show_formspec(pname, "advtrains_trackmap:test", fslabel)
end


minetest.register_craftitem("advtrains_trackmap:tool",{
	description = "nástroj na mapování kolejí",
	_ch_help = "levý klik na kolej pro zobrazení „mapy“",
	groups = {cracky=1}, -- key=name, value=rating; rating=1..3.
	inventory_image = "ch_core_white_pixel.png^[multiply:#dddddd^[resize:32x32^(at_il_tool.png^[resize:32x32)",
	wield_image = "ch_core_white_pixel.png^[multiply:#dddddd^[resize:32x32^(at_il_tool.png^[resize:32x32)",
	stack_max = 1,
	on_use = function(itemstack, player, pointed_thing)
		local pname = player:get_player_name()
		if not pname then
			return
		end
		if pointed_thing.type=="node" then
			local pos=pointed_thing.under
			node_left_click(pos, pname)
		end
	end
})

core.register_craft({
	output = "advtrains_trackmap:tool",
	recipe = {
		{"advtrains_interlocking:tool", "default:paper"},
		{"default:paper", "default:paper"},
	},
})
core.register_craft({
	output = "advtrains_interlocking:tool",
	recipe = {{"advtrains_trackmap:tool"}},
})
