-- Ks signals
-- Can display main aspects (no Zs) + Sht

-- Note that the group value of advtrains_signal is 2, which means "step 2 of signal capabilities"
-- advtrains_signal=1 is meant for signals that do not implement set_aspect.

local function asp_to_zs3type(asp)
	local n = tonumber(asp)
	if not n or n < 4 then return "off" end
	if n < 8 then return 2*math.floor(n/2) end
	return math.min(16,4*math.floor(n/4))
end

local function setzs3(msp, asp, rot)
	local pos = {x = msp.x, y = msp.y+1, z = msp.z}
	local node = advtrains.ndb.get_node(pos)
	if node.name:find("^advtrains_signals_ks:zs3_") then
		advtrains.ndb.swap_node(pos, {name="advtrains_signals_ks:zs3_"..asp.."_"..rot, param2 = node.param2})
	end
end

local function getzs3(msp)
	local pos = {x = msp.x, y = msp.y+1, z = msp.z}
	local nodename = advtrains.ndb.get_node(pos).name
	local speed = nodename:match("^advtrains_signals_ks:zs3_(%w+)_%d+$")
	if not speed then return nil end
	speed = tonumber(speed)
	if not speed then return false end
	return speed
end

local function setzs3v(msp, lim, rot)
	local pos = {x = msp.x, y = msp.y-1, z = msp.z}
	local node = advtrains.ndb.get_node(pos)
	local asp = asp_to_zs3type(lim)
	if node.name:find("^advtrains_signals_ks:zs3v_") then
		advtrains.ndb.swap_node(pos, {name="advtrains_signals_ks:zs3v_"..asp.."_"..rot, param2 = node.param2})
	end
end

local function getzs3v(msp)
	local pos = {x = msp.x, y = msp.y-1, z = msp.z}
	local nodename = advtrains.ndb.get_node(pos).name
	local speed = nodename:match("^advtrains_signals_ks:zs3v_(%w+)_%d+$")
	if not speed then return nil end
	speed = tonumber(speed)
	if not speed then return false end
	return speed
end

local applyaspectf_main = function(rot)
 return function(pos, node, main_aspect, dst_aspect, dst_aspect_info)
	if main_aspect.halt then
		-- halt aspect, set red and don't do anything further
		advtrains.ndb.swap_node(pos, {name="advtrains_signals_ks:hs_danger_"..rot, param2 = node.param2})
		setzs3(pos, "off", rot)
		setzs3v(pos, nil, rot)
		return
	end
	-- set zs3 signal to show speed according to main_aspect
	setzs3(pos, main_aspect.zs3, rot)
	-- select appropriate lamps based on mainaspect and dst
	if main_aspect.shunt then
		advtrains.ndb.swap_node(pos, {name="advtrains_signals_ks:hs_shunt_"..rot, param2 = node.param2})
		setzs3v(pos, nil, rot)
	else
		if not dst_aspect_info
				or not dst_aspect_info.main
				or dst_aspect_info.main == -1 then
			advtrains.ndb.swap_node(pos, {name="advtrains_signals_ks:hs_free_"..rot, param2 = node.param2})
			setzs3v(pos, nil, rot)
		elseif dst_aspect_info.main == 0 then
			advtrains.ndb.swap_node(pos, {name="advtrains_signals_ks:hs_slow_"..rot, param2 = node.param2})
			setzs3v(pos, nil, rot)
		else
			advtrains.ndb.swap_node(pos, {name="advtrains_signals_ks:hs_nextslow_"..rot, param2 = node.param2})
			setzs3v(pos, dst_aspect_info.main, rot)
		end
	end
 end
end

-- Main aspects main signal
-- These aspects tell only the speed signalization at this signal.
-- Actual signal aspect is chosen based on this and the Dst signal.
local mainaspects_main = {
	{
		name = "proceed",
		description = "Proceed",
		zs3 = "off"
	},
	{
		name = "shunt",
		description = "Shunt",
		zs3 = "off",
		shunt = true,
	},
	{
		name = "proceed_16",
		description = "Proceed (speed 16)",
		zs3 = "16",
	},
	{
		name = "proceed_12",
		description = "Proceed (speed 12)",
		zs3 = "12",
	},
	{
		name = "proceed_8",
		description = "Proceed (speed 8)",
		zs3 = "8",
	},
	{
		name = "proceed_6",
		description = "Proceed (speed 6)",
		zs3 = "6",
	},
	{
		name = "proceed_4",
		description = "Proceed (speed 4)",
		zs3 = "4",
	},
}

local applyaspectf_distant = function(rot)
 return function(pos, node, main_aspect, dst_aspect, dst_aspect_info)
	if main_aspect.halt then
		-- halt aspect, set red and don't do anything further
		advtrains.ndb.swap_node(pos, {name="advtrains_signals_ks:vs_slow_"..rot, param2 = node.param2})
		setzs3v(pos, nil, rot)
		return
	end
	-- select appropriate lamps based on mainaspect and dst
	if not dst_aspect_info
			or not dst_aspect_info.main
			or dst_aspect_info.main == -1 then
		advtrains.ndb.swap_node(pos, {name="advtrains_signals_ks:vs_free_"..rot, param2 = node.param2})
		setzs3v(pos, nil, rot)
	elseif dst_aspect_info.main == 0 then
		advtrains.ndb.swap_node(pos, {name="advtrains_signals_ks:vs_slow_"..rot, param2 = node.param2})
		setzs3v(pos, nil, rot)
	else
		advtrains.ndb.swap_node(pos, {name="advtrains_signals_ks:vs_nextslow_"..rot, param2 = node.param2})
		setzs3v(pos, dst_aspect_info.main, rot)
	end
 end
end

-- Main aspects distant signal
-- Only one aspect for "expect free". Whether green or yellow lamp is shown and which speed indicator is determined by remote signal
local mainaspects_dst = {
	{
		name = "expectclear",
		description = "Expect Clear",
	},
}

--Rangiersignal
local applyaspectf_ra = function(rot)
 -- we get here the full main_aspect table
 return function(pos, node, main_aspect, dst_aspect, dst_aspect_info)
	if not main_aspect.halt then
		-- any non-halt main aspect is fine, there's only one anyway
		advtrains.ndb.swap_node(pos, {name="advtrains_signals_ks:ra_shuntd_"..rot, param2 = node.param2})
	else
		advtrains.ndb.swap_node(pos, {name="advtrains_signals_ks:ra_danger_"..rot, param2 = node.param2})
	end
 end
end

-- Main aspects shunt signal
-- Shunt signals have only two states, distant doesn't matter
local mainaspects_ra = {
	{
		name = "shunt",
		description = "Shunt",
		shunt = true,
	},
}

for _, rtab in ipairs({
		{rot =  "0", sbox = {-1/8, -1/2, -1/2,  1/8, 1/2, -1/4}, ici=true, nextrot = "30"},
		{rot = "30", sbox = {-3/8, -1/2, -1/2, -1/8, 1/2, -1/4}, nextrot = "45"},
		{rot = "45", sbox = {-1/2, -1/2, -1/2, -1/4, 1/2, -1/4}, nextrot = "60"},
		{rot = "60", sbox = {-1/2, -1/2, -3/8, -1/4, 1/2, -1/8}, nextrot = "0"},
	}) do
	local rot = rtab.rot
	
	-- Hauptsignal
	for typ, prts in pairs({
			danger   = {asp = advtrains.interlocking.signal.ASPI_HALT, n = "slow", ici=true},
			slow     = {
				asp = function(pos)
					return { main = getzs3(pos) or -1, proceed_as_main = true, dst = 0 }
				end,
				n = "nextslow"
			},
			nextslow = {
				asp = function(pos)
					return { main = getzs3(pos) or -1, proceed_as_main = true, dst = getzs3v(pos) or 6 }
				end,
				n = "free"
			},
			free     = {
				asp = function(pos)
					return { main = getzs3(pos) or -1, proceed_as_main = true, dst = -1 }
				end,
	                        n = "shunt"
			},
			shunt    = {asp = { main =  0, shunt = true} , n = "danger"},
		}) do
		local tile = "advtrains_signals_ks_ltm_"..typ..".png"
		local afunc = prts.asp
		if type(afunc) == "table" then
			afunc = function() return prts.asp end
		end
		if typ == "nextslow" then
			tile = {
				name = tile,
				animation = {
					type = "vertical_frames",
					aspect_w = 32,
					aspect_h = 32,
					length = 1,
				}
			}
		end
		minetest.register_node("advtrains_signals_ks:hs_"..typ.."_"..rot, {
			description = "Ks Main Signal",
			drawtype = "mesh",
			mesh = "advtrains_signals_ks_main_smr"..rot..".obj",
			tiles = {"advtrains_signals_ks_mast.png", "advtrains_signals_ks_head.png", "advtrains_signals_ks_head.png", tile},
			
			paramtype="light",
			sunlight_propagates=true,
			light_source = 4,
			
			paramtype2 = "facedir",
			selection_box = {
				type = "fixed",
				fixed = {rtab.sbox, {-1/4, -1/2, -1/4, 1/4, -7/16, 1/4}}
			},
			groups = {
				cracky = 2,
				advtrains_signal = 2,
				not_blocking_trains = 1,
				save_in_at_nodedb = 1,
				not_in_creative_inventory = (rtab.ici and prts.ici) and 0 or 1,
			},
			drop = "advtrains_signals_ks:hs_danger_0",
			inventory_image = "advtrains_signals_ks_hs_inv.png",
			advtrains = {
				main_aspects = mainaspects_main,
				apply_aspect = applyaspectf_main(rot),
				get_aspect_info = afunc,
				route_role = "main_distant",
				trackworker_next_rot = "advtrains_signals_ks:hs_"..typ.."_"..rtab.nextrot,
				trackworker_rot_incr_param2 = (rot=="60")
			},
			on_rightclick = advtrains.interlocking.signal.on_rightclick,
			can_dig = advtrains.interlocking.signal.can_dig,
			after_dig_node = advtrains.interlocking.signal.after_dig,
		})
		-- rotatable by trackworker
	end
	
	-- Vorsignal (NEU!)
	for typ, prts in pairs({
			-- note: the names are taken from the main signal equivalent so that the same names for the lamp images can be used
			slow   = {asp = function(pos) return { dst = 0, shunt = true } end, n = "nextslow", ici=true},
			nextslow = {
				asp = function(pos)
					return { dst = getzs3v(pos) or 6, shunt = true }
				end,
				n = "free"
			},
			free     = {
				asp = function(pos)
					return { dst = -1, shunt = true }
				end,
	            n = "slow"
			},
		}) do
		local tile = "advtrains_signals_ks_ltm_"..typ..".png"
		local afunc = prts.asp
		if type(afunc) == "table" then
			afunc = function() return prts.asp end
		end
		if typ == "nextslow" then
			tile = {
				name = tile,
				animation = {
					type = "vertical_frames",
					aspect_w = 32,
					aspect_h = 32,
					length = 1,
				}
			}
		end
		minetest.register_node("advtrains_signals_ks:vs_"..typ.."_"..rot, {
			description = "Ks Distant Signal",
			drawtype = "mesh",
			mesh = "advtrains_signals_ks_distant_smr"..rot..".obj",
			tiles = {"advtrains_signals_ks_mast.png", "advtrains_signals_ks_head.png", "advtrains_signals_ks_head.png", tile},
			
			paramtype="light",
			sunlight_propagates=true,
			light_source = 4,
			
			paramtype2 = "facedir",
			selection_box = {
				type = "fixed",
				fixed = {rtab.sbox, {-1/4, -1/2, -1/4, 1/4, -7/16, 1/4}}
			},
			groups = {
				cracky = 2,
				advtrains_signal = 2,
				not_blocking_trains = 1,
				save_in_at_nodedb = 1,
				not_in_creative_inventory = (rtab.ici and prts.ici) and 0 or 1,
			},
			drop = "advtrains_signals_ks:vs_slow_0",
			inventory_image = "advtrains_signals_ks_vs_inv.png",
			advtrains = {
				main_aspects = mainaspects_dst,
				apply_aspect = applyaspectf_distant(rot),
				get_aspect_info = afunc,
				route_role = "distant",
				pure_distant = true,
				trackworker_next_rot = "advtrains_signals_ks:vs_"..typ.."_"..rtab.nextrot,
				trackworker_rot_incr_param2 = (rot=="60")
			},
			on_rightclick = advtrains.interlocking.signal.on_rightclick,
			can_dig = advtrains.interlocking.signal.can_dig,
			after_dig_node = advtrains.interlocking.signal.after_dig,
		})
		-- rotatable by trackworker
	end
	
	
	--Rangiersignale:
	for typ, prts in pairs({
			danger = {asp = { main = false, shunt = false }, n = "shuntd", ici=true},
			shuntd = {asp = { main = false, shunt = true } , n = "danger"},
		}) do
		local sbox = table.copy(rtab.sbox)
		sbox[5] = 0
		local afunc = prts.asp
		if type(afunc) == "table" then
			afunc = function() return prts.asp end
		end
		minetest.register_node("advtrains_signals_ks:ra_"..typ.."_"..rot, {
			description = "Ks Shunting Signal",
			drawtype = "mesh",
			mesh = "advtrains_signals_ks_sht_smr"..rot..".obj",
			tiles = {"advtrains_signals_ks_mast.png", "advtrains_signals_ks_head.png", "advtrains_signals_ks_head.png", "advtrains_signals_ks_ltm_"..typ..".png"},
			
			paramtype="light",
			sunlight_propagates=true,
			light_source = 4,
			
			paramtype2 = "facedir",
			selection_box = {
				type = "fixed",
				fixed = {sbox, rotation_sbox}
			},
			collision_box = {
				type = "fixed",
				fixed = sbox,
			},
			groups = {
				cracky = 2,
				advtrains_signal = 2,
				not_blocking_trains = 1,
				save_in_at_nodedb = 1,
				not_in_creative_inventory = (rtab.ici and prts.ici) and 0 or 1,
			},
			drop = "advtrains_signals_ks:ra_danger_0",
			inventory_image = "advtrains_signals_ks_ra_inv.png",
			advtrains = {
				main_aspects = mainaspects_ra,
				apply_aspect = applyaspectf_ra(rot),
				get_aspect_info = afunc,
				route_role = "shunt",
				trackworker_next_rot = "advtrains_signals_ks:ra_"..typ.."_"..rtab.nextrot,
				trackworker_rot_incr_param2 = (rot=="60")
			},
			on_rightclick = advtrains.interlocking.signal.on_rightclick,
			can_dig = advtrains.interlocking.signal.can_dig,
			after_dig_node = advtrains.interlocking.signal.after_dig,
		})
		-- rotatable by trackworker
	end

	-- Schilder:
	local function register_sign(prefix, typ, nxt, description, mesh, tile2, dtyp, inv, asp)
		minetest.register_node("advtrains_signals_ks:"..prefix.."_"..typ.."_"..rot, {
			description = description,
			drawtype = "mesh",
			mesh = "advtrains_signals_ks_"..mesh.."_smr"..rot..".obj",
			tiles = {"advtrains_signals_ks_signpost.png", tile2},
			
			paramtype="light",
			sunlight_propagates=true,
			light_source = 4,
			
			paramtype2 = "facedir",
			selection_box = {
				type = "fixed",
				fixed = {rtab.sbox, {-1/4, -1/2, -1/4, 1/4, -7/16, 1/4}}
			},
			groups = {
				cracky = 2,
				advtrains_signal = 2,
				not_blocking_trains = 1,
				save_in_at_nodedb = 1,
				not_in_creative_inventory = (rtab.ici and typ == dtyp) and 0 or 1,
			},
			drop = "advtrains_signals_ks:"..prefix.."_"..dtyp.."_0",
			inventory_image = inv,
			advtrains = {
				get_aspect_info = asp,
				trackworker_next_rot = "advtrains_signals_ks:"..prefix.."_"..typ.."_"..rtab.nextrot,
				trackworker_rot_incr_param2 = (rot=="60"),
				trackworker_next_var = "advtrains_signals_ks:"..prefix.."_"..nxt.."_"..rot,
			},
			on_rightclick = advtrains.interlocking.signal.on_rightclick,
			can_dig = advtrains.interlocking.signal.can_dig,
			after_dig_node = advtrains.interlocking.signal.after_dig,
		})
		-- rotatable by trackworker
		--TODO add rotation using trackworker
	end

	for typ, prts in pairs {
		["hfs"] = {asp = {main = false, shunt = false}, n = "pam", mesh = "_hfs", owntile = true},
		["pam"] = {asp = {main = -1, shunt = false, proceed_as_main = true}, n = "ne4"},
		["ne4"] = {asp = {}, n = "ne3x1", mesh="_ne4", owntile = true},
		["ne3x1"] = {asp = {}, n = "ne3x2", mesh="_ne3", owntile = true},
		["ne3x2"] = {asp = {}, n = "ne3x3", mesh="_ne3", owntile = true},
		["ne3x3"] = {asp = {}, n = "ne3x4", mesh="_ne3", owntile = true},
		["ne3x4"] = {asp = {}, n = "ne3x5", mesh="_ne3", owntile = true},
		["ne3x5"] = {asp = {}, n = "hfs", mesh="_ne3", owntile = true},
	} do
		local mesh = prts.mesh or ""
		local tile2 = "advtrains_signals_ks_sign_lf7.png^(advtrains_signals_ks_sign_"..typ..".png^[makealpha:255,255,255)"
		if prts.owntile then
			tile2 = "advtrains_signals_ks_sign_"..typ..".png"
		end
		register_sign("sign", typ, prts.n, "Signal Sign", "sign"..mesh, tile2, "hfs", "advtrains_signals_ks_sign_lf7.png", prts.asp)
	end
	
	for typ, prts in pairs {
		-- Speed restrictions:
		["4"] = {asp = { main = 4, shunt = true }, n = "6"},
		["6"] = {asp = { main = 6, shunt = true }, n = "8"},
		["8"] = {asp = { main = 8, shunt = true }, n = "12"},
		["12"] = {asp = { main = 12, shunt = true }, n = "16"},
		["16"] = {asp = { main = 16, shunt = true }, n = "e"},
		-- Speed restriction lifted
		["e"] = {asp = { main = -1, shunt = true }, n = "4", mesh = "_zs10"},
	} do
		local mesh = tonumber(typ) and "_zs3" or prts.mesh or ""
		local tile2 = "[combine:40x40:0,0=\\(advtrains_signals_ks_sign_off.png\\^[resize\\:40x40\\):3,-2=advtrains_signals_ks_sign_"..typ..".png^[invert:rgb"
		if typ == "e" then
			tile2 = "advtrains_signals_ks_sign_zs10.png"
		end
		register_sign("sign", typ, prts.n, "Permanent local speed restriction sign", "sign"..mesh, tile2, "8", "advtrains_signals_ks_sign_8.png^[invert:rgb", prts.asp)
	end

	for typ, prts in pairs {
		["4"]   = {main =  4, n = "6"},
		["6"]   = {main =  6, n = "8"},
		["8"]   = {main =  8, n = "12"},
		["12"]  = {main = 12, n = "16"},
		["16"]  = {main = 16, n = "e"},
		["e"] = {main = -1, n = "4"},
	} do
		local tile2 = "advtrains_signals_ks_sign_lf7.png^(advtrains_signals_ks_sign_"..typ..".png^[makealpha:255,255,255)^[multiply:orange"
		local inv = "advtrains_signals_ks_sign_lf7.png^(advtrains_signals_ks_sign_8.png^[makealpha:255,255,255)^[multiply:orange"
		register_sign("sign_lf", typ, prts.n, "Temporary local speed restriction sign", "sign", tile2, "8", inv, {main = prts.main, shunt = true, type = "temp"})
	end

	for typ, prts in pairs {
		["4"]   = {main =  4, n = "6"},
		["6"]   = {main =  6, n = "8"},
		["8"]   = {main =  8, n = "12"},
		["12"]  = {main = 12, n = "16"},
		["16"]  = {main = 16, n = "e"},
		["e"]  = {main = -1, n = "4"},
	} do
		local tile2 = "advtrains_signals_ks_sign_lf7.png^(advtrains_signals_ks_sign_"..typ..".png^[makealpha:255,255,255)"
		local inv = "advtrains_signals_ks_sign_lf7.png^(advtrains_signals_ks_sign_8.png^[makealpha:255,255,255)"
		register_sign("sign_lf7", typ, prts.n, "Line speed restriction sign", "sign", tile2, "8", inv, {main = prts.main, shunt = true, type = "line"})
	end
	
	-- Geschwindigkeits(vor)anzeiger für Ks-Signale
	for typ, prts in pairs({
			["off"] = {n = "4", ici = true},
			["4"] = {n = "6"},
			["6"] = {n = "8"},
			["8"] = {n = "12"},
			["12"] = {n = "16"},
			["16"] = {n = "off"},
		}) do
		local def = {
			drawtype = "mesh",
			tiles = {"advtrains_signals_ks_mast.png","advtrains_signals_ks_head.png","advtrains_signals_ks_sign_"..typ..".png^[invert:rgb^[noalpha"},
			paramtype = "light",
			sunlight_propagates = true,
			light_source = 4,
			paramtype2 = "facedir",
			selection_box = {
				type = "fixed",
				fixed = {rtab.sbox, {-1/4, -1/2, -1/4, 1/4, -7/16, 1/4}}
			},
			groups = {
				cracky = 2,
				not_blocking_trains = 1,
				save_in_at_nodedb = 1,
				not_in_creative_inventory = (rtab.ici and prts.ici) and 0 or 1,
			},
			after_dig_node = function(pos) advtrains.ndb.update(pos) end
		}

		-- Zs 3
		local t = table.copy(def)
		t.description = "Ks speed limit indicator"
		t.mesh = "advtrains_signals_ks_zs_top_smr"..rot..".obj"
		t.drop = "advtrains_signals_ks:zs3_off_0"
		t.selection_box.fixed[1][5] = 0
		t.advtrains = {
				trackworker_next_rot = "advtrains_signals_ks:zs3_"..typ.."_"..rtab.nextrot,
				trackworker_rot_incr_param2 = (rot=="60")
			}
		minetest.register_node("advtrains_signals_ks:zs3_"..typ.."_"..rot, t)
		--TODO add rotation using trackworker

		-- Zs 3v
		local t = table.copy(def)
		t.description = "Ks distant speed limit indicator"
		t.mesh = "advtrains_signals_ks_zs_bottom_smr"..rot..".obj"
		t.drop = "advtrains_signals_ks:zs3v_off_0"
		t.tiles[3] = t.tiles[3] .. "^[multiply:yellow"
		t.advtrains = {
				trackworker_next_rot = "advtrains_signals_ks:zs3v_"..typ.."_"..rtab.nextrot,
				trackworker_rot_incr_param2 = (rot=="60")
			}
		minetest.register_node("advtrains_signals_ks:zs3v_"..typ.."_"..rot, t)
		--TODO add rotation using trackworker
	end
	
	minetest.register_node("advtrains_signals_ks:mast_mast_"..rot, {
		description = "Ks Mast",
		drawtype = "mesh",
		mesh = "advtrains_signals_ks_mast_smr"..rot..".obj",
		tiles = {"advtrains_signals_ks_mast.png"},
		
		paramtype="light",
		sunlight_propagates=true,
		--light_source = 4,
		
		paramtype2 = "facedir",
		selection_box = {
			type = "fixed",
			fixed = {rtab.sbox, {-1/4, -1/2, -1/4, 1/4, -7/16, 1/4}}
		},
		groups = {
			cracky = 2,
			not_blocking_trains = 1,
			not_in_creative_inventory = (rtab.ici) and 0 or 1,
		},
		advtrains = {
			trackworker_next_rot = "advtrains_signals_ks:mast_mast_"..rtab.nextrot,
			trackworker_rot_incr_param2 = (rot=="60")
		},
		drop = "advtrains_signals_ks:mast_mast_0",
	})
	--TODO add rotation using trackworker
end

-- Crafting

minetest.register_craft({
	output = "advtrains_signals_ks:hs_danger_0 2",
	recipe = {
		{'default:steel_ingot', 'dye:red', 'default:steel_ingot'},
		{'dye:yellow', 'default:steel_ingot', 'dye:dark_green'},
		{'default:steel_ingot', 'advtrains_signals_ks:mast_mast_0', 'default:steel_ingot'},
	},
})

minetest.register_craft({
	output = "advtrains_signals_ks:mast_mast_0 10",
	recipe = {
		{'default:steel_ingot'},
		{'dye:cyan'},
		{'default:steel_ingot'},
	},
})

minetest.register_craft({
	output = "advtrains_signals_ks:ra_danger_0 2",
	recipe = {
		{'dye:red', 'dye:white', 'dye:red'},
		{'dye:white', 'default:steel_ingot', 'default:steel_ingot'},
		{'default:steel_ingot', 'advtrains_signals_ks:mast_mast_0', 'default:steel_ingot'},
	},
})

minetest.register_craft({
	output = "advtrains_signals_ks:zs3_off_0 2",
	recipe = {
		{"","default:steel_ingot",""},
		{"default:steel_ingot","dye:white","default:steel_ingot"},
		{"","advtrains_signals_ks:mast_mast_0",""}
	},
})
minetest.register_craft({
	output = "advtrains_signals_ks:zs3v_off_0 2",
	recipe = {
		{"","default:steel_ingot",""},
		{"default:steel_ingot","dye:yellow","default:steel_ingot"},
		{"","advtrains_signals_ks:mast_mast_0",""}
	},
})

local sign_material = "default:sign_wall_steel" --fallback
if minetest.get_modpath("basic_materials") then
	sign_material = "basic_materials:plastic_sheet"
end
--print("Sign Material: "..sign_material)

minetest.register_craft({
	output = "advtrains_signals_ks:sign_8_0 2",
	recipe = {
		{sign_material, 'dye:black'},
		{'default:stick', ''},
		{'default:stick', ''},
	},
})
sign_material = nil

minetest.register_craft{
	output = "advtrains_signals_ks:sign_8_0 1",
	recipe = {{"advtrains_signals_ks:sign_lf7_8_0"}}
}

minetest.register_craft{
	output = "advtrains_signals_ks:sign_hfs_0 1",
	recipe = {{"advtrains_signals_ks:sign_8_0"}}
}

minetest.register_craft{
	output = "advtrains_signals_ks:sign_lf_8_0 1",
	recipe = {{"advtrains_signals_ks:sign_hfs_0"}}
}

minetest.register_craft{
	output = "advtrains_signals_ks:sign_lf7_8_0 1",
	recipe = {{"advtrains_signals_ks:sign_lf_8_0"}}
}
