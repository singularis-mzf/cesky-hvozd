ch_core.open_submod("ap", {chat = true, data = true, hud = true, lib = true})

-- Systém „Activity Points“

local ap_increase = 2
local ap_decrease = 1
local ap_min = 0
local ap_max = 26
local min, max = math.min, math.max

local levels = {
	{base = 0, count = 500, next = 500},
}

local function add_level(level, count)
	local last_level_number = #levels
	local last_level = levels[last_level_number]
	levels[last_level_number + 1] = {
		base = last_level.base + last_level.count,
		count = count,
		next = last_level.base + last_level.count + count
	}
	return last_level_number + 1
end

add_level(2, 1100)
add_level(3, 2400)
add_level(4, 4200)
add_level(5, 6500)
add_level(6, 9300)
add_level(7, 12600)
add_level(8, 16400)
add_level(9, 20700)
add_level(10, 25500)
add_level(11, 30800)
add_level(12, 36600)
add_level(13, 42900)
add_level(14, 49700)
add_level(15, 57000)
add_level(16, 64800)
add_level(17, 73100)
add_level(18, 81900)
add_level(19, 91200)
add_level(20, 101000)
add_level(21, 111300)
add_level(22, 122100)
add_level(23, 133400)
add_level(24, 145200)
add_level(25, 157500)
add_level(26, 170300)
add_level(27, 183600)
add_level(28, 197400)
add_level(29, 211700)
add_level(30, 226500)
add_level(31, 241800)
add_level(32, 257600)
add_level(33, 273900)
add_level(34, 290700)
add_level(35, 308000)
add_level(36, 325800)
add_level(37, 344100)
add_level(38, 362900)
add_level(39, 382200)
add_level(40, 402000)
add_level(41, 422300)
add_level(42, 443100)
add_level(43, 464400)
add_level(44, 486200)
add_level(45, 508500)
add_level(46, 531300)
add_level(47, 554600)
add_level(48, 578400)
add_level(49, 602700)
add_level(50, 627500)
add_level(51, 652800)
add_level(52, 678600)
add_level(53, 704900)
add_level(54, 731700)
add_level(55, 759000)
add_level(56, 786800)
add_level(57, 815100)
add_level(58, 843900)
add_level(59, 873200)
add_level(60, 903000)
add_level(61, 933300)
add_level(62, 964100)
add_level(63, 995400)
add_level(64, 1027200)
add_level(65, 1059500)
add_level(66, 1092300)
add_level(67, 1125600)
add_level(68, 1159400)
add_level(69, 1193700)
add_level(70, 1228500)
add_level(71, 1263800)
add_level(72, 1299600)
add_level(73, 1335900)
add_level(74, 1372700)
add_level(75, 1410000)
add_level(76, 1447800)
add_level(77, 1486100)
add_level(78, 1524900)
add_level(79, 1564200)
add_level(80, 1604000)
add_level(81, 1644300)
add_level(82, 1685100)
add_level(83, 1726400)
add_level(84, 1768200)
add_level(85, 1810500)
add_level(86, 1853300)
add_level(87, 1896600)
add_level(88, 1940400)
add_level(89, 1984700)
add_level(90, 2029500)
add_level(91, 2074800)
add_level(92, 2120600)
add_level(93, 2166900)
add_level(94, 2213700)
add_level(95, 2261000)
add_level(96, 2308800)
add_level(97, 2357100)
add_level(98, 2405900)
add_level(99, 2455200)
add_level(100, 2505000)
add_level(101, 2555300)
add_level(102, 2606100)
add_level(103, 2657400)
add_level(104, 2709200)
add_level(105, 2761500)
add_level(106, 2814300)
add_level(107, 2867600)
add_level(108, 2921400)
add_level(109, 2975700)
add_level(110, 3030500)
add_level(111, 3085800)
add_level(112, 3141600)
add_level(113, 3197900)
add_level(114, 3254700)
add_level(115, 3312000)
add_level(116, 3369800)
add_level(117, 3428100)
add_level(118, 3486900)
add_level(119, 3546200)
add_level(120, 3606000)
add_level(121, 3666300)
add_level(122, 3727100)
add_level(123, 3788400)
add_level(124, 3850200)
add_level(125, 3912500)
add_level(126, 3975300)
add_level(127, 4038600)
add_level(128, 4102400)

--[[ local function clip_coef(coef)
	if coef > ap_max then
		return ap_max
	elseif coef < ap_min then
		return ap_min
	else
		return coef
	end
end ]]

local function adjust_coef(t, key, amount)
	local value = t[key] + amount
	if value > ap_max then
		value = ap_max
	elseif value < ap_min then
		value = ap_min
	end
	t[key] = value
	return value
end

function ch_core.ap_get_level(l)
	if l < 0 then
		return nil
	else
		return levels[min(l, #levels)]
	end
end

function ch_core.ap_init(player, online_charinfo, offline_charinfo)
	local vector_zero = vector.zero()
	local default_coef = 0
	local player_name = online_charinfo.player_name

	if offline_charinfo.ap_level == nil or offline_charinfo.ap_version ~= ch_core.verze_ap then
		offline_charinfo.ap_level = 1
		offline_charinfo.ap_xp = 0
		offline_charinfo.ap_version = ch_core.verze_ap
		ch_core.save_offline_charinfo(player_name, {"ap_level", "ap_version", "ap_xp"})
	end
	local ap = {
		-- aktuální údaje
		dig_gen = 0,
		dig_pos = vector_zero,
		look_h = 0,
		look_h_gen = 0,
		look_v = 0,
		look_v_gen = 0,
		place_gen = 0,
		place_pos = vector_zero,
		pos = player:get_pos(),
		pos_x_gen = 0,
		pos_y_gen = 0,
		pos_z_gen = 0,
		velocity = player:get_velocity(),
		velocity_x_gen = 0,
		velocity_y_gen = 0,
		velocity_z_gen = 0,
		control = player:get_player_control_bits(),
		control_gen = 0,

		-- koeficienty
		dig_coef = default_coef,
		place_coef = default_coef,
		walk_coef  = default_coef,
	}
	online_charinfo.ap = table.copy(ap)
	online_charinfo.ap1 = ap
	online_charinfo.ap2 = ap

	return true
end

function ch_core.ap_update(player, online_charinfo, offline_charinfo)
	local result, ap, ap1, ap2 = 0, online_charinfo.ap, online_charinfo.ap1, online_charinfo.ap2

	-- posunout struktury
	local ap_new = table.copy(ap)
	online_charinfo.ap2 = ap1
	online_charinfo.ap1 = ap
	online_charinfo.ap = ap_new

	-- aktivity
	local act_dig = ap.dig_gen > ap1.dig_gen and (not ap.dig_pos or not ap1.dig_pos or not ap2.dig_pos or vector.angle(vector.subtract(ap2.dig_pos, ap1.dig_pos), vector.subtract(ap1.dig_pos, ap.dig_pos)) ~= 0)
	local act_place = ap.place_gen - ap1.place_gen > 1
	local act_walk = (ap.look_h_gen - ap1.look_h_gen) + (ap.look_v_gen - ap1.look_v_gen) > 2 and ap.velocity_x_gen - ap1.velocity_x_gen > 8 and ap.velocity_z_gen - ap1.velocity_z_gen > 8 and ap.control_gen > ap1.control_gen

	local act_any = act_dig or act_place or act_walk
	local debug_coef_changes = {}

	for coef_key, active in pairs({dig_coef = act_dig, place_coef = act_place, walk_coef = act_walk}) do
		local old_coef = ap_new[coef_key]
		local new_coef = adjust_coef(ap_new, coef_key, active and ap_increase or -ap_decrease)
		result = result + new_coef
		if new_coef ~= old_coef then
			table.insert(debug_coef_changes, coef_key..":"..old_coef.."=>"..new_coef..";")
		end
	end

	if act_any then
		offline_charinfo.past_ap_playtime = offline_charinfo.past_ap_playtime + ch_core.ap_interval
		ch_core.save_offline_charinfo(online_charinfo.player_name, "past_ap_playtime")
	end

	if result == 0 then
		if debug_coef_changes[1] then
			minetest.log("action", online_charinfo.player_name..": no xp change, but :"..table.concat(debug_coef_changes))
		end
		return 0
	end

	-- vyhodnotit zvýšení úrovně
	local level_up = false
	local old_level, old_xp = offline_charinfo.ap_level, offline_charinfo.ap_xp
	local level = old_level
	local level_def = ch_core.ap_get_level(old_level)
	local new_xp = old_xp + result
	while new_xp >= level_def.count do
		new_xp = new_xp - level_def.count
		level = level + 1
		level_def = ch_core.ap_get_level(level)
		level_up = true
	end

	-- aktualizovat offline_charinfo
	local keys_to_update = {"ap_xp"}
	offline_charinfo.ap_xp = new_xp
	if level_up then
		keys_to_update[2] = "ap_level"
		offline_charinfo.ap_level = level
	end
	ch_core.save_offline_charinfo(online_charinfo.player_name, keys_to_update)

	-- aktualizovat HUD
	local level_def = ch_core.ap_get_level(level)
	if minetest.get_modpath("hudbars") then
		hb.change_hudbar(player, "ch_xp", math.min(new_xp, level_def.count), level_def.count, nil, nil, nil, level, nil)
	end

	minetest.log("action", online_charinfo.player_name..": level_up="..(level_up and "true" or "false")..", level="..old_level.."=>"..level..", xp="..old_xp.."=>"..new_xp..", coefs = "..table.concat(debug_coef_changes))

	-- oznámit
	if level_up then
		ch_core.systemovy_kanal("", "Postava "..ch_core.prihlasovaci_na_zobrazovaci(online_charinfo.player_name).." dosáhla úrovně "..level)
	end

	return result
end

local function on_dignode(pos, oldnode, digger)
	local player_name = digger and digger:is_player() and digger:get_player_name()
	local online_charinfo = player_name and ch_core.online_charinfo[player_name]
	if online_charinfo then -- nil if digged by digtron
		local ap = online_charinfo.ap
		if ap then
			local old_pos = ap.dig_pos
			if not old_pos or pos.x ~= old_pos.x or pos.y ~= old_pos.y or pos.z ~= old_pos.z then
				ap.dig_gen = ap.dig_gen + 1
				ap.dig_pos = pos
			end
		end
	end
end

local function on_placenode(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	local player_name = placer and placer:is_player() and placer:get_player_name()
	local online_charinfo = player_name and ch_core.online_charinfo[player_name]
	if online_charinfo then
		local ap = online_charinfo.ap
		if ap then
			local old_pos = ap.place_pos
			pos = vector.round(pos)
			if not old_pos or pos.x ~= old_pos.x or pos.y ~= old_pos.y or pos.z ~= old_pos.z then
				ap.place_gen = ap.place_gen + 1
				ap.place_pos = pos
			end
		end
	else
		minetest.log("warning", "DEBUG: on_placenode called with none or invalid placer")
	end
end

minetest.register_on_dignode(on_dignode)
minetest.register_on_placenode(on_placenode)

-- HUD
if minetest.get_modpath("hudbars") then
	local hudbar_formatstring = "úr. @1: @2/@3"
	local hudbar_formatstring_config = {
		order = { "label", "value", "max_value" },
		textdomain = "hudbars",
	}
	local hudbar_defaults = {
		icon = "ch_core_empty.png", bgicon = nil, bar = "hudbars_bar_xp.png"
	}
	hb.register_hudbar("ch_xp", 0xFFFFFF, "*", hudbar_defaults, 0, 100, true, hudbar_formatstring, hudbar_formatstring_config)
	minetest.register_on_joinplayer(function(player, last_login)
		local offline_charinfo = ch_core.get_offline_charinfo(player:get_player_name())
		local level, xp, max_xp = offline_charinfo.ap_level, offline_charinfo.ap_xp
		if level and xp then
			max_xp = ch_core.ap_get_level(level).count
		else
			level, xp, max_xp = 1, 0, ch_core.ap_get_level(1).count
		end
		hb.init_hudbar(player, "ch_xp", 0, 10, false)
		hb.change_hudbar(player, "ch_xp", math.min(xp, max_xp), max_xp, nil, nil, nil, level, nil)
	end)
end

ch_core.close_submod("ap")
