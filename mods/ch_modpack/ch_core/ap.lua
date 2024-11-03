ch_core.open_submod("ap", {chat = true, data = true, events = true, hud = true, lib = true})

-- Systém „Activity Points“

local ap_increase = 2
local ap_decrease = 1
local ap_min = 0
local ap_max_default = 26
local ap_max_book = 10
local min = math.min
local def

local levels = {
	{base = 0, count = 500, next = 500},
}

local ifthenelse = ch_core.ifthenelse

ch_core.register_event_type("level_up", {
	description = "zvýšení úrovně",
	access = "public",
	chat_access = "public",
	color = "#eeee00",
})

ch_core.register_event_type("level_down", {
	description = "snížení úrovně",
	access = "public",
	chat_access = "public",
})

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

local function adjust_coef(t, key, amount)
	local ap_max = ap_max_default
	if key == "book_coef" then
		ap_max = ap_max_book
	end
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

function ch_core.ap_announce_craft(player_or_player_name)
	local player_name
	if type(player_or_player_name) == "string" then
		player_name = player_or_player_name
	else
		player_name = player_or_player_name and player_or_player_name:is_player() and player_or_player_name:get_player_name()
	end
	local online_charinfo = player_name and ch_core.online_charinfo[player_name]
	if online_charinfo then
		local ap = online_charinfo.ap
		if ap then
			ap.craft_gen = ap.craft_gen + 1
		end
	end
end

local update_xp_hud

if minetest.get_modpath("hudbars") then
	update_xp_hud = function(player, player_name, offline_charinfo)
		local pinfo = ch_core.normalize_player(player)
		local player_role = pinfo.role
		local has_creative_priv = false
		if pinfo.privs.creative then
			local online_charinfo = ch_core.online_charinfo[pinfo.player_name]
			if online_charinfo ~= nil then
				-- a creative priv icon can only appear after a second after login
				has_creative_priv = minetest.get_us_time() - online_charinfo.join_timestamp > 1000000
			end
		end
		local role_icon = ch_core.player_role_to_image(player_role, has_creative_priv, 16)
		local skryt_body = player_role == "new" or offline_charinfo.skryt_body == 1

		if skryt_body then
			hb.hide_hudbar(player, "ch_xp")
		else
			local level, xp, max_xp = offline_charinfo.ap_level, offline_charinfo.ap_xp
			if level and xp then
				max_xp = ch_core.ap_get_level(level).count
			else
				level, xp, max_xp = 1, 0, ch_core.ap_get_level(1).count
			end
			hb.unhide_hudbar(player, "ch_xp")
			hb.change_hudbar(player, "ch_xp", math.min(xp, max_xp), max_xp, role_icon, nil, nil, level, nil)
		end
	end
else
	update_xp_hud = function(player, player_name, offline_charinfo)
		return false
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
		chat_mistni_gen = 0,
		chat_celoserverovy_gen = 0,
		chat_sepot_gen = 0,
		chat_soukromy_gen = 0,
		craft_gen = 0,
		book_gen = 0,

		-- koeficienty
		book_coef = default_coef,
		craft_coef = default_coef,
		chat_coef = default_coef,
		dig_coef = default_coef,
		place_coef = default_coef,
		walk_coef  = default_coef,
	}
	online_charinfo.ap = table.copy(ap)
	online_charinfo.ap1 = ap
	online_charinfo.ap2 = ap
	online_charinfo.ap_modify_timestamp = minetest.get_us_time()

	return true
end

function ch_core.ap_add(player_name, offline_charinfo, points_to_add, debug_coef_changes)
	local player = minetest.get_player_by_name(player_name)

	if points_to_add == nil or points_to_add == 0 then
		if player ~= nil then
			update_xp_hud(player, player_name, offline_charinfo)
		end
		return 0
	end

	local player_role = ch_core.get_player_role(player_name)
	local old_level, old_xp = offline_charinfo.ap_level, offline_charinfo.ap_xp
	local new_level = old_level
	local level_def = ch_core.ap_get_level(old_level)
	local new_xp = old_xp + points_to_add

	if points_to_add > 0 then
		-- vyhodnotit zvýšení úrovně
		while new_xp >= level_def.count do
			new_xp = new_xp - level_def.count
			new_level = new_level + 1
			level_def = ch_core.ap_get_level(new_level)
		end
	else
		-- vyhodnotit snížení úrovně
		while new_xp < 0 do
			if new_level > 1 then
				new_level = new_level - 1
				level_def = ch_core.ap_get_level(new_level)
				new_xp = new_xp + level_def.count
			else
				new_xp = 0
				break
			end
		end
	end

	-- aktualizovat offline_charinfo
	local keys_to_update = {"ap_xp"}
	offline_charinfo.ap_xp = new_xp
	if new_level ~= old_level then
		keys_to_update[2] = "ap_level"
		offline_charinfo.ap_level = new_level
	end
	ch_core.save_offline_charinfo(player_name, keys_to_update)

	-- je-li postava online, aktualizovat HUD
	if player ~= nil then
		update_xp_hud(player, player_name, offline_charinfo)
	end

	if debug_coef_changes then
		minetest.log("info", player_name..": level_op="..(new_level > old_level and ">" or new_level < old_level and "<" or "=")..", level="..old_level.."=>"..new_level..", xp="..old_xp.."=>"..new_xp..", coefs = "..table.concat(debug_coef_changes))
		-- print("DEBUG: "..player_name..": level_op="..(new_level > old_level and ">" or new_level < old_level and "<" or "=")..", level="..old_level.."=>"..new_level..", xp="..old_xp.."=>"..new_xp..", coefs = "..table.concat(debug_coef_changes))
	end

	-- oznámit
	if player_role ~= "new" then
		if new_level > old_level then
			-- ch_core.systemovy_kanal("", "Postava "..ch_core.prihlasovaci_na_zobrazovaci(player_name).." dosáhla úrovně "..new_level)
			ch_core.add_event("level_up", "Postava {PLAYER} dosáhla úrovně "..new_level, player_name)
		elseif new_level < old_level then
			-- ch_core.systemovy_kanal("", "Postava "..ch_core.prihlasovaci_na_zobrazovaci(player_name).." klesla na úroveň "..new_level)
			ch_core.add_event("level_down", "Postava {PLAYER} klesla na úroveň "..new_level, player_name)
		end
	end

	-- je-li postava online, aktualizovat online_charinfo.ap_modify_timestamp
	local online_charinfo = ch_core.online_charinfo[player_name]
	if online_charinfo ~= nil then
		online_charinfo.ap_modify_timestamp = minetest.get_us_time()
	end

	return new_xp, new_level
end

function ch_core.ap_update(player, online_charinfo, offline_charinfo)
	local result, ap, ap1, ap2 = 0, online_charinfo.ap, online_charinfo.ap1, online_charinfo.ap2

	-- posunout struktury
	local ap_new = table.copy(ap)
	online_charinfo.ap2 = ap1
	online_charinfo.ap1 = ap
	online_charinfo.ap = ap_new

	-- aktivity
	local act_book = ap.book_gen > ap1.book_gen
	local act_chat = ap.chat_mistni_gen > ap1.chat_mistni_gen or ap.chat_celoserverovy_gen > ap1.chat_celoserverovy_gen or ap.chat_sepot_gen > ap1.chat_sepot_gen or ap.chat_soukromy_gen > ap1.chat_soukromy_gen
	local act_craft = ap.craft_gen > ap1.craft_gen
	local act_dig = ap.dig_gen > ap1.dig_gen and (not ap.dig_pos or not ap1.dig_pos or not ap2.dig_pos or vector.angle(vector.subtract(ap2.dig_pos, ap1.dig_pos), vector.subtract(ap1.dig_pos, ap.dig_pos)) ~= 0)
	local act_place = ap.place_gen - ap1.place_gen > 1
	local act_walk = (ap.look_h_gen - ap1.look_h_gen) + (ap.look_v_gen - ap1.look_v_gen) > 2 and ap.velocity_x_gen - ap1.velocity_x_gen > 8 and ap.velocity_z_gen - ap1.velocity_z_gen > 8 and ap.control_gen > ap1.control_gen

	local act_any = act_chat or act_craft or act_dig or act_place or act_walk
	local debug_coef_changes = {}

	for coef_key, active in pairs({book_coef = act_book, chat_coef = act_chat, craft_coef = act_craft, dig_coef = act_dig, place_coef = act_place, walk_coef = act_walk}) do
		local adjustment
		if not active then
			adjustment = -ap_decrease
		elseif coef_key ~= "chat_coef" then
			adjustment = ap_increase
		else
			adjustment = 2 * ap_increase -- čet => dvojnásobný vzrůst
		end
		local old_coef = ap_new[coef_key]
		local new_coef = adjust_coef(ap_new, coef_key, adjustment)
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

	ch_core.ap_add(online_charinfo.player_name, offline_charinfo, result, debug_coef_changes)
	return result
end

local function on_dignode(pos, oldnode, digger)
	if digger == nil then
		return
	end
	local player_name = digger:is_player() and digger:get_player_name()
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
	if placer == nil then
		return
	end
	local player_name = placer:is_player() and placer:get_player_name()
	if player_name == nil or player_name == false or player_name == "" then
		return
	end
	local online_charinfo = ch_core.online_charinfo[player_name]
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
		minetest.log("warning", "on_placenode called with an offline player "..player_name)
	end
end

local function on_craft(itemstack, player, old_craft_grid, craft_inv)
	if craft_inv:get_location().type == "player" then
		local ap = ch_core.safe_get_3(ch_core.online_charinfo, assert(player:get_player_name()), "ap")
		if ap then
			ap.craft_gen = ap.craft_gen + 1
		end
	end
end

local function on_player_inventory_action(player, action, inventory, inventory_info)
	local ap = ch_core.safe_get_3(ch_core.online_charinfo, assert(player:get_player_name()), "ap")
	if ap then
		ap.craft_gen = ap.craft_gen + 1
	end
end

local function on_item_eat(hp_change, replace_with_item, itemstack, user, pointed_thing)
	local ap = ch_core.safe_get_3(ch_core.online_charinfo, assert(user:get_player_name()), "ap")
	if ap then
		ap.craft_gen = ap.craft_gen + 1
	end
end

local function on_item_pickup(itemstack, picker, pointed_thing, time_from_last_punch,  ...)
	local ap = ch_core.safe_get_3(ch_core.online_charinfo, assert(picker:get_player_name()), "ap")
	if ap then
		ap.craft_gen = ap.craft_gen + 1
	end
end

minetest.register_on_craft(on_craft)
minetest.register_on_dignode(on_dignode)
minetest.register_on_placenode(on_placenode)
minetest.register_on_player_inventory_action(on_player_inventory_action)
minetest.register_on_item_eat(on_item_eat)
minetest.register_on_item_pickup(on_item_pickup)

local function body(admin_name, param)
	local player_name, ap_to_add = param:match("^(%S+)%s(%S+)$")
	if not player_name then
		return false, "Chybné zadání!"
	end
	player_name = ch_core.jmeno_na_prihlasovaci(player_name)
	local offline_charinfo = ch_core.offline_charinfo[player_name]
	if not offline_charinfo then
		return false, "Vnitřní chyba: nenalezeno offline_charinfo pro '"..player_name.."'!"
	end
	ap_to_add = tonumber(ap_to_add)
	local old_level, old_xp = offline_charinfo.ap_level, offline_charinfo.ap_xp
	ch_core.ap_add(player_name, offline_charinfo, ap_to_add)
	local new_level, new_xp = offline_charinfo.ap_level, offline_charinfo.ap_xp
	return true, "Změna: úroveň "..old_level.." => "..new_level..", body: "..old_xp.." => "..new_xp
end

def = {
	params = "<Jméno_Postavy> <celé_číslo>",
	privs = {server = true},
	description = "Přidá či odebere příslušné postavě body.",
	func = body,
}
minetest.register_chatcommand("body", def)

--[[
	Zobrazí či skryje ukazatel úrovní a bodů. Postava nemusí být zrovna
	ve hře.
]]
function ch_core.showhide_ap_hud(player_name, show)
	local offline_charinfo = ch_core.offline_charinfo[player_name]
	if not offline_charinfo then
		return false
	end
	local new_value = ifthenelse(show, 0, 1)
	if offline_charinfo.skryt_body == new_value then
		return nil
	end
	offline_charinfo.skryt_body = new_value
	ch_core.save_offline_charinfo(player_name, "skryt_body")
	local player = minetest.get_player_by_name(player_name)
	if player ~= nil then
		update_xp_hud(player, player_name, offline_charinfo)
	end
	return true
end

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
		local pinfo = ch_core.normalize_player(player)
		local offline_charinfo = ch_core.get_offline_charinfo(pinfo.player_name)
		local level, xp, max_xp = offline_charinfo.ap_level, offline_charinfo.ap_xp
		if level and xp then
			max_xp = ch_core.ap_get_level(level).count
		else
			level, xp, max_xp = 1, 0, ch_core.ap_get_level(1).count
		end
		local skryt_body = pinfo.role == "new" or offline_charinfo.skryt_body == 1
		hb.init_hudbar(player, "ch_xp", 0, 10, skryt_body)
		update_xp_hud(player, pinfo.player_name, offline_charinfo)
	end)

	def = {
		description = "Skryje hráči/ce ukazatel úrovní a bodů, je-li zobrazen.",
		func = function(player_name, param)
			local result = ch_core.showhide_ap_hud(player_name, false)
			if result == false then
				return false, "Vnitřní chyba"
			elseif result == nil then
				return false, "Ukazatel úrovně a bodů je již skryt."
			else
				return true, "Ukazatel úrovně a bodů úspěšně skryt."
			end
		end,
	}

	minetest.register_chatcommand("skrýtbody", def)
	minetest.register_chatcommand("skrytbody", def)

	def = {
		description = "Zobrazí hráči/ce ukazatel úrovní a bodů, je-li skryt.",
		func = function(player_name, param)
			local result = ch_core.showhide_ap_hud(player_name, true)
			if result == false then
				return false, "Vnitřní chyba"
			elseif result == nil then
				return false, "Ukazatel úrovně a bodů je již zobrazen."
			else
				return true, "Ukazatel úrovně a bodů úspěšně zobrazen."
			end
		end,
	}

	minetest.register_chatcommand("zobrazitbody", def)
end

ch_core.close_submod("ap")
