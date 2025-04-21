-- advtrains_signals_muc_ubahn
-- Signals modeled after the Munich U-Bahn signalling system
-- It reuses the original historic wall signal mesh, but extends it to 4 signal lamps and supports the new signal API only. 

-- For a reference of the signals (in German) see: https://www.u-bahn-muenchen.de/betrieb/zugsicherung/signale/
-- Hp4 and Hp5 are not implemented because they do not make sense.
-- Also the speed signals are not yet added (they will be added later)

local all_sigs = {
	hp0 = { asp = { main = 0 }, crea = true }, -- halt
	hp1 = { asp = { main = -1, proceed_as_main = true } }, -- free full speed
	hp2 = { asp = { main = 12, proceed_as_main = true } }, -- slow speed
	hp3 = { asp = { main = 0, shunt = true } }, -- shunting
	vr0 = { asp = { dst = 0 }, distant = true, crea = true }, -- distant halt/slow
	vr1 = { asp = { dst = -1 }, distant = true }, -- distant free
}

local mainaspects = {
	{ name = "hp1", description = "Hp1: Full speed" },
	{ name = "hp2", description = "Hp2: Reduced Speed" },
	{ name = "hp3", description = "Hp3: Shunt" },
}
local dstaspects = {
	{ name = "vr1", description = "Vr1: Expect Full speed" },
}

local function applyaspect_main(loc)
	return function(pos, node, main_aspect, rem_aspect, rem_aspinfo)
		local ma_node = main_aspect.name
		if all_sigs[ma_node] and not all_sigs[ma_node].distant then
			-- ma_node is fine
		elseif main_aspect.halt then
			ma_node = "hp0" -- default halt aspect
		else
			ma_node = "hp1" -- default free aspect
		end
		advtrains.ndb.swap_node(pos, {name = "advtrains_signals_muc_ubahn:signal_wall_"..loc.."_"..ma_node, param2 = node.param2})
	end
end

local function applyaspect_distant(loc)
	return function(pos, node, main_aspect, rem_aspect, rem_aspinfo)
		local ma_node = "vr0" -- show expect stop by default
		if not main_aspect.halt and (not rem_aspinfo or not rem_aspinfo.main or rem_aspinfo.main>12 or rem_aspinfo.main==-1) then
			ma_node = "vr1" -- show free when dst is at least 12
		end
		advtrains.ndb.swap_node(pos, {name = "advtrains_signals_muc_ubahn:signal_wall_"..loc.."_"..ma_node, param2 = node.param2})
	end
end

for r,f in pairs(all_sigs) do
	for loc, sbox in pairs({l={-1/2, -1/2, -1/4, 0, 1/2, 1/4}, r={0, -1/2, -1/4, 1/2, 1/2, 1/4}, t={-1/2, 0, -1/4, 1/2, 1/2, 1/4}}) do
		minetest.register_node("advtrains_signals_muc_ubahn:signal_wall_"..loc.."_"..r, {
			drawtype = "mesh",
			paramtype="light",
			paramtype2="facedir",
			walkable = false,
			selection_box = {
				type = "fixed",
				fixed = sbox,
			},
			mesh = "advtrains_signals_muc_ubahn_wsig_"..loc..".obj",
			tiles = {"advtrains_signals_muc_ubahn_"..r..".png"},
			drop = f.distant and "advtrains_signals_muc_ubahn:signal_wall_"..loc.."_vr0" or "advtrains_signals_muc_ubahn:signal_wall_"..loc.."_hp0",
			description = f.distant and attrans("Munich U-Bahn Distant Signal ("..loc..")") or attrans("Munich U-Bahn Main Signal ("..loc..")"),
			groups = {
				cracky=3,
				not_blocking_trains=1,
				save_in_at_nodedb=1,
				advtrains_signal = 2,
				not_in_creative_inventory = f.crea and 0 or 1
			},
			light_source = 1,
			sunlight_propagates=true,
			on_rightclick = advtrains.interlocking.signal.on_rightclick,
			can_dig = advtrains.interlocking.signal.can_dig,
			after_dig_node = advtrains.interlocking.signal.after_dig,
			-- new signal API
			advtrains = {
				main_aspects = f.distant and dstaspects or mainaspects, -- main aspects only for main
				apply_aspect = f.distant and applyaspect_distant(loc) or applyaspect_main(loc),
				pure_distant = f.distant,
				get_aspect_info = function() return f.asp end,
				route_role = f.distant and "distant" or "main"
			},
		})
	end
end
