local F = minetest.formspec_escape
local ifthenelse = ch_core.ifthenelse
local green, red, white, light_green, light_red = ch_core.colors.green, ch_core.colors.red, ch_core.colors.white, ch_core.colors.light_green, ch_core.colors.light_red

local inactive_param2 = 0
local active_param2 = 4

local log_prefix = "[ch_extras/anchor] "

local wa_epoch_start = 1577836800 -- 1. 1. 2020
local wa_records_limit = 512
local wa_node_name = "ch_extras:world_anchor"
local wa_anchors_per_player_limit = 20
local wa_blocks_per_player_limit = 640
local wa_blocks_per_admin_limit = 720
local wa_minutes_limit = 2880

local player_name_to_active_anchors = {}
local player_name_to_formspec_state = {}

local get_formspec

local function log(message, level)
	return minetest.log(level or "action", log_prefix..message)
end

local function get_wa_time()
	return math.max(0, math.min(2147483647, os.time() - wa_epoch_start))
end

local function wa_time_to_string(wa_time)
	local c = ch_core.cas_na_strukturu(wa_time + wa_epoch_start)
	return string.format("%04d-%02d-%02dT%02d:%02d:%02d%s", c.rok, c.mesic, c.den, c.hodina, c.minuta, c.sekunda, c.posun_text)
end

local function wa_add_record(meta, str, wa_time)
	if wa_time == nil then
		wa_time = get_wa_time()
	end
	local s = meta:get_string("records")
	local t = wa_time_to_string(wa_time)
	s = (t.." "..str.."\n"..s):sub(1, wa_records_limit)
	meta:set_string("records", s)
end

local function wa_get_records(meta)
	local result = {}
	local s, b, e -- string, begin, end
	s = meta:get_string("records")
	b = 1
	e = s:find("\n")
	while e ~= nil do
		table.insert(result, s:sub(b, e - 1))
		b = e + 1
		e = s:find("\n", b)
	end
	return result
end

local function count_anchors(map)
	local count, k = 0, next(map, nil)
	while k ~= nil do
		count = count + 1
		k = next(map, k)
	end
	return count
end

local function wa_update_infotext(pos, node, meta, wa_time)
	local owner = meta:get_string("owner")
	if owner == "" then return end
	if wa_time == nil then
		wa_time = get_wa_time()
	end
	local is_active = node.param2 == active_param2
	local owner_viewname = ch_core.prihlasovaci_na_zobrazovaci(owner)

	local s1, s4
	local s2 = "\nkotvu vlastní: "..owner_viewname
	local s3 = "\nčas: "..wa_time_to_string(wa_time)
	if is_active then
		s1, s4 = "soukromá světová kotva je zapnutá, blok je ukotven", "\nčasovač vyprší: "..wa_time_to_string(meta:get_int("timeout"))
	else
		s1, s4 = "světová kotva je vypnutá", ""
	end
	meta:set_string("infotext", s1..s2..s3..s4.."\n"..minetest.pos_to_string(pos))
end

local function aktivnich_kotev(n)
	if n == 1 then
		return n.." aktivní kotvu"
	elseif n >= 2 and n <= 4 then
		return n.." aktivní kotvy"
	else
		return n.." aktivních kotev"
	end
end

local function wa_enable(player_name, pos, node, rel_timeout)
	if node.param2 == inactive_param2 then
		minetest.load_area(pos)
		local player_role = ch_core.get_player_role(player_name)
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		if owner == "" then
			return false, "Tuto kotvu nikdo nevlastní, takovou kotvu nelze použít."
		end
		local poshash = minetest.hash_node_position(pos)
		local posstr = minetest.pos_to_string(pos)
		local anchors_per_player = ch_core.get_or_add(player_name_to_active_anchors, owner)
		if anchors_per_player[poshash] ~= nil then
			error("The anchor at "..posstr.." has an inactive param2, but it is already in the list of active anchors for player "..owner.."!")
		end
		local current_app_count = count_anchors(anchors_per_player)
		if current_app_count >= wa_anchors_per_player_limit and player_role ~= "admin" then
			return false, "Limit "..wa_anchors_per_player_limit.." aktivních kotev na postavu byl překročen."
		end
		local forceload_limit = ifthenelse(player_role == "admin", wa_blocks_per_admin_limit, wa_blocks_per_player_limit)
		-- try to forceload the block:
		local result = minetest.forceload_block(pos, false, forceload_limit)
		if result then
			-- forceload succeeded
			-- 1. update param2
			node.param2 = active_param2
			minetest.swap_node(pos, node)
			-- 2. add to the list of active anchors
			anchors_per_player[poshash] = pos
			-- 3. set the timeout
			local wa_time = get_wa_time()
			local timeout = math.max(0, math.min(2147483647, wa_time + rel_timeout))
			meta:set_int("timeout", timeout)
			local timeout_str = wa_time_to_string(timeout)
			-- 4. update metadata
			wa_add_record(meta, "zap", wa_time)
			wa_update_infotext(pos, node, meta, wa_time)
			-- 5. write to the log
			log("Private World Anchor at "..posstr.." owned by "..owner.." has been enabled and the block is anchored! Timeout set to "..timeout.." (after "..(timeout - wa_time).." seconds).")
			-- 6. announce to the owner
			if minetest.get_player_by_name(owner) ~= nil then
				ch_core.systemovy_kanal(owner, "Vaše soukromá světová kotva na pozici "..posstr.." se zapnula a časovač vypnutí byl nastaven na čas "..timeout_str..". Nyní máte "..aktivnich_kotev(current_app_count + 1)..".")
			end
			-- 7. announce to the admin
			if owner ~= "Administrace" and minetest.get_player_by_name("Administrace") then
				ch_core.systemovy_kanal("Administrace", "Soukromá světová kotva na pozici "..posstr.." (vlastní: "..ch_core.prihlasovaci_na_zobrazovaci(owner)..") se zapnula a časovač vypnutí byl nastaven na čas "..timeout_str..". Vlastník/ice má nyní "..aktivnich_kotev(current_app_count + 1)..".")
			end
			-- 8. update formspecs
			for _, custom_state in pairs(player_name_to_formspec_state) do
				if vector.equals(pos, custom_state.pos) then
					ch_core.update_formspec(custom_state.player_name, "ch_extras:anchor", get_formspec(custom_state))
				end
			end
			return true
		else
			minetest.log("warning", "Forceloading at "..minetest.pos_to_string(pos).." failed!")
			return false, "Pokus o ukotvení mapového bloku selhal."
		end
	end
	return nil
end

local function wa_disable(pos, node, meta)
	assert(pos)
	assert(node)
	assert(meta)
	if node.param2 ~= active_param2 then
		return
	end
	-- 1. update param2
	minetest.load_area(pos)
	node.param2 = inactive_param2
	minetest.swap_node(pos, node)
	-- 2. remove from the list of active anchors
	local owner = meta:get_string("owner")
	local poshash = minetest.hash_node_position(pos)
	local posstr = minetest.pos_to_string(pos)
	local anchors_per_player = ch_core.get_or_add(player_name_to_active_anchors, owner)
	if anchors_per_player[poshash] ~= nil then
		anchors_per_player[poshash] = nil
	else
		log("Private World Anchor at "..posstr.." is being disabled, but it's not found in the anchors_per_player["..owner.."]! Dump: "..dump2({pos = pos, poshash = poshash, anchors_per_player = anchors_per_player, owner = owner}), "warning")
	end
	local new_app_count = count_anchors(anchors_per_player)
	-- 3. update metadata
	wa_add_record(meta, "vyp")
	wa_update_infotext(pos, node, meta, get_wa_time())
	-- 4. free the block (and don't touch it again)
	minetest.forceload_free_block(pos, false)
	-- 5. write to the log
	log("Private World Anchor at "..posstr.." owned by "..owner.." has been disabled and the block has been freed.")
	-- 6. announce to the owner
	if minetest.get_player_by_name(owner) ~= nil then
		ch_core.systemovy_kanal(owner, "Vaše soukromá světová kotva na pozici "..posstr.." se vypnula. Nyní máte "..aktivnich_kotev(new_app_count)..".")
	end
	-- 7. announce to the admin
	if owner ~= "Administrace" and minetest.get_player_by_name("Administrace") then
		ch_core.systemovy_kanal(owner, "Soukromá světová kotva na pozici "..posstr.." (vlastní: "..ch_core.prihlasovaci_na_zobrazovaci(owner)..") se vypnula. Vlastník/ice má nově "..aktivnich_kotev(new_app_count)..".")
	end
	-- 8. update formspecs
	for _, custom_state in pairs(player_name_to_formspec_state) do
		if vector.equals(pos, custom_state.pos) then
			ch_core.update_formspec(custom_state.player_name, "ch_extras:anchor", get_formspec(custom_state))
		end
	end
	return true
end

-- zap = kotva byla zapnuta
-- vyp = kotva byla vypnuta (popř. se vypnula sama)
-- akt = kotva se stala aktivní
-- dkt = kotva přestala být aktivní

local function wa_watchdog(pos)
	if minetest.compare_block_status(pos, "active") then
		minetest.after(1, wa_watchdog, pos)
	else
		log("Anchor at "..minetest.pos_to_string(pos).." was deactivated with its map block.")
	end
end

local function wa_start_watchdog(pos)
	if minetest.compare_block_status(pos, "active") then
		log("Anchor at "..minetest.pos_to_string(pos).." was activated with its map block.")
		minetest.after(1, wa_watchdog, pos)
	end
end

-- LBM:
local function on_wa_lbm(pos, node, dtime_s)
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	if owner == "" then return end
	local last_tick = meta:get_int("time")
	local now = get_wa_time()
	if last_tick > 0 then
		wa_add_record(meta, "dkt", last_tick)
	end
	wa_add_record(meta, "akt", now)
	wa_update_infotext(pos, node, meta, now)
	wa_start_watchdog(pos)

	if node.param2 == active_param2 then
		local poshash = minetest.hash_node_position(pos)
		local anchors_per_player = ch_core.get_or_add(player_name_to_active_anchors, owner)
		anchors_per_player[poshash] = pos
	end
end

-- ABM:
local function on_wa_abm(pos, node, active_object_count, active_object_count_wider)
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	if owner == "" then return end
	local now = get_wa_time()
	meta:set_int("time", now)

	-- if the anchor is active, check for timeout:
	if node.param2 == active_param2 then
		local timeout = meta:get_int("timeout")
		if now > timeout then
			wa_disable(pos, node, meta)
			return
		end
	end
	wa_update_infotext(pos, node, meta, now)
end

--[[
custom_state = {
	pos = vector,
	owner = string,
	owner_viewname = string,
	player_name = string,
	has_rights = bool,
}
]]
function get_formspec(custom_state)
	local pos, owner = custom_state.pos, custom_state.owner
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	local is_active = node.param2 == active_param2
	local records = wa_get_records(meta)
	for i, record in ipairs(records) do
		records[i] = F(record)
	end
	local state_message
	if is_active then
		local timeout = meta:get_int("timeout")
		state_message = green.."Kotva je zapnutá"..white..", časovač vyprší: "..F(wa_time_to_string(timeout))
	else
		state_message = red.."Kotva je vypnutá."..white
	end
	local area_min = vector.offset(pos, -(pos.x % 16), -(pos.y % 16), -(pos.z % 16))
	local area_max = vector.offset(area_min, 15, 15, 15)

	local formspec = {
		ch_core.formspec_header{
			formspec_version = 6,
			size = {16, 8},
			auto_background = true,
		},
		"item_image[0.375,0.375;1,1;", wa_node_name, "]",
		"label[1.6,0.9;Soukromá světová kotva]",
		"label[0.3,2;", state_message,
			"\nKotvu vlastní: ", ch_core.prihlasovaci_na_zobrazovaci(custom_state.owner, true), white,
			"\nKotva pokrývá oblast: "..F(minetest.pos_to_string(area_min)..".."..minetest.pos_to_string(area_max)).."]",
		"button_exit[0.25,6.25;7.25,1;show;ukázat pokrytou oblast]",
		"label[9.5,0.5;záznamy:]",
		"tableoptions[background=#1e1e1e;border=true;highlight=#467832]",
		"tablecolumns[text]",
		"table[9.5,0.75;6,6.75;zaznamy;",
		table.concat(records, ","),
		";1]",
		"tooltip[zaznamy;zap = kotva se zapnula\n"..
		"vyp = kotva se vypnula\nakt = mapový blok začal být aktivní\n"..
		"dkt = mapový blok přestal být aktivní]",
	}
	if custom_state.has_rights then
		table.insert(formspec,
			"label[0.3,4;Vypršet za:\n(max. 2880 = 48 hodin)]"..
			"field[1.9,3.75;1.5,0.5;timeout;;2880]"..
			"label[3.5,4;minut.]"..
			"tooltip[timeout;60 = 1 hodina\\, 120 = 2 hodiny\\, 300 = 5 hodin\\,\n720 = 12 hodn\\, 1440 = 24 hodin\\, 2880 = 48 hodin]")
		if is_active then
			table.insert(formspec,
				"button[0.25,5;3.5,1;set;nastavit]"..
				"button[4,5;3.5,1;vyp;"..light_red.."vypnout kotvu]")
		else
			table.insert(formspec, "button[0.25,5;3.5,1;set;"..light_green.."nastavit\na zapnout]")
		end
	end
	return table.concat(formspec)
end

local function formspec_callback(custom_state, player, formname, fields)
	local player_info = ch_core.normalize_player(player)
	if player_info.player_name ~= custom_state.player_name or not custom_state.has_rights then
		return
	end
	local player_name = custom_state.player_name
	if fields.quit then
		player_name_to_formspec_state[player_name] = nil
	end
	if fields.show then
		local pos = custom_state.pos
		local x, y, z = pos.x - (pos.x % 16), pos.y - (pos.y % 16), pos.z - (pos.z % 16)
		ch_core.show_aabb({x, y, z, x + 16, y + 16, z + 16}, 16)
		return
	elseif fields.set then
		local player_role = player_info.role
		local wa_time = get_wa_time()
		local new_rel_timeout
		if player_info.role == "admin" and fields.timeout == "max" then
			new_rel_timeout = 2147483640 - wa_time
		else
			new_rel_timeout = math.ceil(tonumber(fields.timeout))
			if new_rel_timeout <= 1 then
				new_rel_timeout = 1
			elseif new_rel_timeout > wa_minutes_limit and player_role ~= "admin" then
				new_rel_timeout = wa_minutes_limit
			end
			new_rel_timeout = new_rel_timeout * 60 -- minutes to seconds
		end
		local node = minetest.get_node(custom_state.pos)
		if node.param2 == active_param2 then
			-- update timeout only
			local pos = custom_state.pos
			local meta = minetest.get_meta(pos)
			meta:set_int("timeout", wa_time + new_rel_timeout)
			wa_update_infotext(pos, node, meta, wa_time)
		elseif not wa_enable(player_name, vector.copy(custom_state.pos), minetest.get_node(custom_state.pos), new_rel_timeout, player_role == "admin") then
			ch_core.systemovy_kanal(player_name, "Pokus o zapnutí soukromé světové kotvy selhal.")
			return
		end
	elseif fields.vyp then
		wa_disable(custom_state.pos, minetest.get_node(custom_state.pos), minetest.get_meta(custom_state.pos))
	else
		return
	end
	return get_formspec(custom_state)
end

def = {
	description = "soukromá světová kotva",
	tiles = {"ch_extras_anchor.png"},
	paramtype = "light",
	paramtype2 = "color",
	light_source = 5,
	palette = "[combine:16x16:0,0=ch_core_white_pixel.png\\^[resize\\:16x16"..
		":0,0=ch_core_white_pixel.png\\^[multiply\\:#cc0000"..
		":4,0=ch_core_white_pixel.png\\^[multiply\\:#00ff00",
	groups = {oddly_breakable_by_hand = 1},
	is_ground_content = false,
	place_param2 = 0,
	drop = {
		items = {
			{items = {wa_node_name}, inherit_color = false},
		},
	},
	sounds = default.node_sound_metal_defaults(),
	_ch_help = "Soukromá světová kotva umožňuje dělnickým i kouzelnickým postavám dočasně ukotvit\n"..
		"mapový blok (16x16 bloků) v paměti serveru, takže ten zůstane aktivní i poté,\n"..
		"co z něj odejdou hráčské postavy, a všechny stroje v něm poběží normálně.\n"..
		"Časový limit své kotvy můžete kdykoliv opakovaně prodlužovat (nebo zkracovat),\n"..
		"ale ne na víc než na 48 hodin. Jedna postava může mít až "..wa_anchors_per_player_limit.." současně aktivních kotev.",
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		local player_name = (placer and placer:get_player_name()) or ""
		if player_name ~= "" then
			meta:set_string("owner", player_name)
		end
		local min = vector.offset(pos,
			-(pos.x % 16), -(pos.y % 16), -(pos.z % 16))
		ch_core.show_aabb({min.x, min.y, min.z, min.x + 16, min.y + 16, min.z + 16}, 16)
	end,
	can_dig = function(pos, player)
		local node = minetest.get_node(pos)
		local meta = minetest.get_meta(pos)
		local player_name = player and player:get_player_name()
		local owner = meta:get_string("owner")
		return node.param2 ~= active_param2 and (player_name == owner or owner == "" or ch_core.get_player_role(player) == "admin")
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local player_info = ch_core.normalize_player(clicker)
		if player_info.role == "new" or player_info.role == "none" then
			return
		end
		local owner = minetest.get_meta(pos):get_string("owner")
		local custom_state = {
			pos = vector.copy(pos),
			owner = owner,
			owner_viewname = ch_core.prihlasovaci_na_zobrazovaci(owner),
			player_name = player_info.player_name,
			has_rights = player_info.player_name == owner or player_info.role == "admin",
		}
		player_name_to_formspec_state[player_info.player_name] = custom_state
		ch_core.show_formspec(clicker, "ch_extras:anchor", get_formspec(custom_state), formspec_callback, custom_state, {})
		return
	end,
	on_rotate = screwdriver.disallow,
}
minetest.register_node(wa_node_name, def)

minetest.register_lbm{
	label = "Private World Anchor Load",
	name = "ch_extras:world_anchor_load",
	nodenames = {wa_node_name},
	run_at_every_load = true,
	action = on_wa_lbm,
}

minetest.register_abm{
	label = "Private World Anchor ABM",
	nodenames = {wa_node_name},
	interval = 5.0,
	chance = 1,
	catch_up = true,
	action = on_wa_abm,
}

minetest.register_craft{
	output = wa_node_name,
	recipe = {
		{"default:gold_ingot", "", "default:gold_ingot"},
		{"", "technic:red_energy_crystal", ""},
		{"technic:lead_block", "technic:lead_ingot", "technic:lead_block"},
	},
}

local function cc_moje_kotvy(player_name, param)
	local player_role = ch_core.get_player_role(player_name)
	if player_role == nil or player_role == "new" then return false end
	local count = 0
	local result = {}
	if player_role == "admin" then
		local mycount = 0
		for subplayer_name, anchors in pairs(player_name_to_active_anchors) do
			for poshash, _ in pairs(anchors) do
				local pos = minetest.get_position_from_hash(poshash)
				local node = minetest.get_node_or_nil(pos)
				if node ~= nil then
					local meta = minetest.get_meta(pos)
					local owner_viewname = ch_core.prihlasovaci_na_zobrazovaci(meta:get_string("owner"))
					local timeout = meta:get_int("timeout")
					if node.param2 == active_param2 and timeout > 0 then
						timeout = wa_time_to_string(timeout)
					else
						timeout = "???"
					end
					table.insert(result, "- "..minetest.pos_to_string(pos).." ("..owner_viewname..") vyprší = "..timeout)
				else
					table.insert(result, "- "..minetest.pos_to_string(pos).." ???")
				end
				if subplayer_name == player_name then
					mycount = mycount + 1
				end
				count = count + 1
			end
		end
		table.insert(result, "Celkem: "..count.." kotev (z toho "..mycount.." vašich).")
	else
		local anchors = player_name_to_active_anchors[player_name] or {}
		for poshash, _ in pairs(anchors) do
			local pos = minetest.get_position_from_hash(poshash)
			local node = minetest.get_node_or_nil(pos)
			if node ~= nil then
				local meta = minetest.get_meta(pos)
				local timeout = meta:get_int("timeout")
				if node.param2 == active_param2 and timeout > 0 then
					timeout = wa_time_to_string(timeout)
				else
					timeout = "???"
				end
				table.insert(result, "- "..minetest.pos_to_string(pos).." vyprší: "..timeout)
			else
				table.insert(result, "- "..minetest.pos_to_string(pos).." ???")
			end
			count = count + 1
		end
		table.insert(result, "Celkem: "..count.." kotev.")
	end
	ch_core.systemovy_kanal(player_name, table.concat(result, "\n"))
end

minetest.register_chatcommand("mojekotvy", {
	params = "",
	description = "Vypíše vám seznam vašich aktivních soukromých světových kotev",
	privs = {ch_registered_player = true},
	func = cc_moje_kotvy,
})
