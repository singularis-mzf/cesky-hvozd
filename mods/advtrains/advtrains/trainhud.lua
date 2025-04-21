--trainhud.lua: holds all the code for train controlling

local T = advtrains.texture

advtrains.hud = {}
advtrains.hhud = {}

minetest.register_on_leaveplayer(function(player)
advtrains.hud[player:get_player_name()] = nil
advtrains.hhud[player:get_player_name()] = nil
end)

local hud_type_key = minetest.features.hud_def_type_field and "type" or "hud_elem_type"

local mletter={[1]="F", [-1]="R", [0]="N"}

function advtrains.on_control_change(pc, train, flip)
   	local maxspeed = train.max_speed or 10
	if pc.sneak then
		if pc.up then
			train.tarvelocity = maxspeed
		end
		if pc.down then
			train.tarvelocity = 0
		end
		if pc.left then
			train.tarvelocity = 4
		end
		if pc.right then
			train.tarvelocity = 8
		end
		--[[if pc.jump then
			train.brake = true
			--0: released, 1: brake and pressed, 2: released and brake, 3: pressed and brake
			if not train.brake_hold_state or train.brake_hold_state==0 then
				train.brake_hold_state = 1
			elseif train.brake_hold_state==2 then
				train.brake_hold_state = 3
			end
		elseif train.brake_hold_state==1 then
			train.brake_hold_state = 2
		elseif train.brake_hold_state==3 then
			train.brake = false
			train.brake_hold_state = 0
		end]]
		--shift+use:see wagons.lua
	else
		local act=false
		if pc.jump then
			train.ctrl_user = 1
			act=true
		end
		if train.ars_disable and pc.up then
			-- up clears ars disable flag in any situation
			train.ars_disable = nil
		end
		-- If atc command set, only "Jump" key can clear command. To prevent accidental control.
		if train.tarvelocity or train.atc_command then
			return
		end
		if pc.up then
		   train.ctrl_user=4
		   act=true
		end
		if pc.down then
			if train.velocity>0 then
				if pc.jump then
					train.ctrl_user = 0
				else
					train.ctrl_user = 2
				end
				act=true
			else
				advtrains.invert_train(train.id)
				advtrains.atc.train_reset_command(train)
			end
		end
		if pc.left then
			if train.door_open ~= 0 then
				train.door_open = 0
			else
				train.door_open = -1
			end
		end
		if pc.right then
			if train.door_open ~= 0 then
				train.door_open = 0
			else
				train.door_open = 1
			end
		end
		if not act then
			train.ctrl_user = nil
		end
	end
end
function advtrains.update_driver_hud(pname, train, flip)
	local inside=train.text_inside or ""
	local ft, ht = advtrains.hud_train_format(train, flip)
	advtrains.set_trainhud(pname, inside.."\n"..ft, ht)
end
function advtrains.clear_driver_hud(pname)
	advtrains.set_trainhud(pname, "")
end

function advtrains.set_trainhud(name, text, driver)
	local hud = advtrains.hud[name]
	local player=minetest.get_player_by_name(name)
	if not player then
	   return
	end
	local drivertext = driver or ""
	local driverhud = {
		[hud_type_key] = "image",
		name = "ADVTRAINS_DRIVER",
		position = {x=0.5, y=1},
		offset = {x=0,y=-170},
		text = drivertext,
		alignment = {x=0,y=-1},
		scale = {x=1,y=1},
	}
	if not hud then
		hud = {}
		advtrains.hud[name] = hud
		hud.id = player:hud_add({
			[hud_type_key] = "text",
			name = "ADVTRAINS",
			number = 0xFFFFFF,
			position = {x=0.5, y=1},
			offset = {x=0, y=-300},
			text = text,
			scale = {x=200, y=60},
			alignment = {x=0, y=-1},
		})
		hud.driver = player:hud_add(driverhud)
		hud.oldText = text
		hud.oldDriver = drivertext
	else
		if hud.oldText ~= text then
			player:hud_change(hud.id, "text", text)
			hud.oldText=text
		end
		if hud.driver then
			if hud.oldDriver ~= drivertext then
				player:hud_change(hud.driver, "text", drivertext)
				hud.oldDriver = drivertext
			end
		elseif driver then
			hud.driver = player:hud_add(driverhud)
			hud.oldDriver = drivertext
		end
	end
end

function advtrains.set_help_hud(name, text)
	local hud = advtrains.hhud[name]
	local player=minetest.get_player_by_name(name)
	if not player then
	   return
	end
	if not hud then
		hud = {}
		advtrains.hhud[name] = hud
		hud.id = player:hud_add({
			[hud_type_key] = "text",
			name = "ADVTRAINS_HELP",
			number = 0xFFFFFF,
			position = {x=1, y=0.3},
			offset = {x=0, y=0},
			text = text,
			scale = {x=200, y=60},
			alignment = {x=1, y=0},
		})
		hud.oldText=text
		return
	elseif hud.oldText ~= text then
		player:hud_change(hud.id, "text", text)
		hud.oldText=text
	end
end

--train.lever:
--Speed control lever in train, for new train control system.
--[[
Value	Disp	Control	Meaning
0		BB		S+Space	Emergency Brake
1		B		Space	Normal Brake
2		-		S		Roll
3		o		<none>	Stay at speed
4		+		W		Accelerate
]]

function advtrains.hud_train_format(train, flip)
	if not train then return "","" end
	local sformat = string.format -- this appears to be faster than (...):format
	
	local max = train.max_speed or 10
	local res = train.speed_restriction
	local vel = advtrains.abs_ceil(train.velocity)
	local vel_kmh=advtrains.abs_ceil(advtrains.ms_to_kmh(train.velocity))
	
	local tlev=train.lever or 3
	if train.velocity==0 and not train.active_control then tlev=1 end
	if train.hud_lzb_effect_tmr then
		tlev=1
	end
	
	local hud = T.combine(440, 110, "black")
	local st = {}
	if train.debug then st = {train.debug} end
	
	-- lever
	hud:add_multicolor_fill_topdown(275, 10, 5, 90, 1, "cyan", 1, "white", 2, "orange", 1, "red")
	hud:add_lever_topdown(280, 10, 30, 90, 18, 6, (4-tlev)/4, "gray", "darkslategray")
	-- reverser
	hud:add(245, 10, T"advtrains_hud_arrow.png":transform"FY":multiply(flip and "gray" or "cyan"))
	hud:add(245, 85, T"advtrains_hud_arrow.png":multiply(flip and "orange" or "gray"))
	hud:add_lever_topdown(240, 30, 25, 50, 15, 5, flip and 1 or 0, "gray", "darkslategray")
	-- train control/safety indication
	hud:add(10, 10, T"advtrains_hud_atc.png":resize(30, 30):multiply((train.tarvelocity or train.atc_command) and "cyan" or "darkslategray"))
	hud:add(50, 10, T"advtrains_hud_lzb.png":resize(30, 30):multiply(train.hud_lzb_effect_tmr and "red" or "darkslategray"))
	hud:add(90, 10, T"advtrains_hud_shunt.png":resize(30, 30):multiply(train.is_shunt and "orange" or "darkslategray"))
	-- door
	hud:add_fill(187, 10, 26, 30, "white"):add_fill(189, 12, 22, 11, "black")
	hud:add_fill(170, 10, 15, 30, train.door_open==-1 and "white" or "darkslategray"):add_fill(172, 12, 11, 11, "black")
	hud:add_fill(215, 10, 15, 30, train.door_open==1 and "white" or "darkslategray"):add_fill(217, 12, 11, 11, "black")
	-- speed indication(s)
	hud:add_n7seg(320, 10, 110, 90, vel, 2, "red")
	hud:add_segmentbar_leftright(10, 65, 217, 20, 3, 20, max, 20, "darkslategray", 0, vel, "white")
	if res and res > 0 then
		hud:add_fill(7+res*11, 60, 3, 30, "red")
	end
	if train.tarvelocity then
		hud:add(1+train.tarvelocity*11, 85, T"advtrains_hud_arrow.png":transform"FY":multiply"cyan")
	end
	local lzb = train.lzb
	local lzbdisp = {c = "darkslategray", d = 888}
	if lzb and lzb.checkpoints and lzb.checkpoints[1] then
		local cp = lzb.checkpoints[1]
		if advtrains.interlocking and cp.udata and cp.udata.signal_pos then
			local sigd = advtrains.interlocking.db.get_sigd_for_signal(cp.udata.signal_pos)
			if sigd then
				local tcbs = advtrains.interlocking.db.get_tcbs(sigd) or {}
				if tcbs.route_rsn then
					table.insert(st, ("%s: %s"):format(minetest.pos_to_string(sigd.p), tcbs.route_rsn))
				end
			end
		end
		local spd = cp.speed
		local c, arrow
		if not spd or spd == -1 then
			c = "lime"
		elseif spd == 0 then
			c = "red"
		elseif not res or spd <= res then
			c = "orange"
			arrow = true
		elseif spd <= max then
			c = "yellow"
			arrow = true
		else
			c = "cyan"
			arrow = true
		end
		if arrow then
			hud:add(1+spd*11, 50, T"advtrains_hud_arrow.png":multiply"red")
		end
		local dist = math.floor(((cp.index or train.index)-train.index))
		dist = math.max(0, math.min(999, dist))
		lzbdisp = {c = c, d = dist}
	end
	hud:add_fill(130, 10, 30, 5, lzbdisp.c)
	hud:add_fill(130, 35, 30, 5, lzbdisp.c)
	hud:add_n7seg(131, 18, 28, 14, lzbdisp.d, 3, lzbdisp.c)
	
	if res and res == 0 then
		table.insert(st, attrans("OVERRUN RED SIGNAL! Examine situation and reverse train to move again."))
	end
	
	if train.atc_command then
		local delay_str = ""
		if train.atc_delay and train.atc_delay >= 0 then
			delay_str = advtrains.abs_ceil(train.atc_delay).."s "
		end
		if train.atc_wait_finish then
			delay_str = delay_str.."[W] "
		end
		if train.atc_wait_autocouple then
			delay_str = delay_str.."[Cpl] "
		end
		if train.atc_wait_signal then
			delay_str = delay_str.."[G] "
		end
		table.insert(st, ("ATC: %s%s"):format(delay_str, train.atc_command or ""))
	end
	
	return table.concat(st,"\n"), tostring(hud)
end

local _, texture = advtrains.hud_train_format { -- dummy train object to demonstrate the train hud
	max_speed = 15, speed_restriction = 15, velocity = 15, tarvelocity = 12,
	active_control = true, lever = 3, ctrl = {lzb = true}, is_shunt = true,
	door_open = 1, lzb = {checkpoints = {{speed=6, index=125.7}}}, index = 100,
}

minetest.register_node("advtrains:hud_demo",{
	description = "Train HUD demonstration",
	tiles = {texture},
	groups = {cracky = 3, not_in_creative_inventory = 1}
})

minetest.register_craft {
	output = "advtrains:hud_demo",
	recipe = {
		{"default:paper", "default:paper", "default:paper"},
		{"default:paper", "advtrains:trackworker", "default:paper"},
		{"default:paper", "default:paper", "default:paper"},
	}
}
