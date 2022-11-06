print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local modpath = minetest.get_modpath("ch_core")
ch_core = {
	storage = minetest.get_mod_storage(),
	submods_loaded = {}, -- submod => true

	ap_interval = 15, -- interval pro podmód „ap“
	cas = 0,
	supported_lang_codes = {cs = true, sk = true},
	verze_ap = 1, -- aktuální verze podmódu „ap“
	vezeni_data = {
		min = vector.new(-1000, -1000, -1000),
		max = vector.new(1000, 1000, 1000),
		-- dvere = nil,
		stred = vector.new(0, 0, 0),
	},
}

function ch_core.open_submod(submod, required_submods)
	for s, c in pairs(required_submods or {}) do
		if c and not ch_core.submods_loaded[s] then
			error("ch_core submodule '"..s.."' is required to be loaded before '"..submod.."'!")
		end
	end
	return true
end
function ch_core.close_submod(submod)
	ch_core.submods_loaded[submod] = true
	return true
end

dofile(modpath .. "/privs.lua")
dofile(modpath .. "/data.lua")
dofile(modpath .. "/lib.lua") -- : data
dofile(modpath .. "/localize_chatcommands.lua") -- : privs, data, lib
dofile(modpath .. "/formspecs.lua") -- : data, lib
dofile(modpath .. "/areas.lua") -- : lib
dofile(modpath .. "/nametag.lua") -- : data, lib
dofile(modpath .. "/chat.lua") -- : data, lib, privs, nametag
dofile(modpath .. "/dennoc.lua") -- : privs, chat
dofile(modpath .. "/hud.lua") -- : data, lib, chat
dofile(modpath .. "/ap.lua") -- : data, chat, hud, lib
dofile(modpath .. "/registrace.lua") -- : chat, data, lib, nametag
dofile(modpath .. "/pryc.lua") -- : data, lib, chat, privs
dofile(modpath .. "/joinplayer.lua") -- : data, formspecs, lib, nametag, pryc
dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/padlock.lua") -- : data, lib
dofile(modpath .. "/vezeni.lua") -- : privs, data, lib, chat, hud
dofile(modpath .. "/timers.lua") -- : data, chat, hud
dofile(modpath .. "/hotbar.lua")
dofile(modpath .. "/vgroups.lua")
dofile(modpath .. "/wielded_light.lua") -- : data, lib, nodes
dofile(modpath .. "/teleportace.lua") -- : data, lib, chat, privs, timers
dofile(modpath .. "/creative_inventory.lua") -- : lib


-- KOHOUT: při přechodu mezi dnem a nocí přehraje zvuk

local last_timeofday = 0 -- pravděpodobně se pokusí něco přehrát v prvním globalstepu,
-- ale to nevadí, protöže v tu chvíli stejně nemůže být ještě nikdo online.
local abs = math.abs
local deg = math.deg
local get_timeofday = minetest.get_timeofday
local max = math.max
local min = math.min
local gain_1 = {gain = 1.0}
local head_bone_name = "Head"
local head_bone_position = vector.new(0, 6.35, 0)
local head_bone_angle = vector.new(0, 0, 0)
local emoting = (minetest.get_modpath("emote") and emote.emoting) or {}
local globstep_dtime_accumulated = 0.0
local ch_timer_hudbars = ch_core.count_of_ch_timer_hudbars
local get_us_time = minetest.get_us_time
local has_wielded_light = minetest.get_modpath("wielded_light")
local custom_globalsteps = {}
local last_ap_timestamp = 0

local stepheight_low = {stepheight = 0.3}
local stepheight_high = {stepheight = 1.1}

local function vector_eq(a, b) return a.x == b.x and a.y == b.y and a.z == b.z end
local function get_root(o)
	local r = o:get_attach()
	while r do
		o = r
		r = o:get_attach()
	end
	return o
end

function ch_core.register_player_globalstep(func, index)
	if not index then
		index = #custom_globalsteps + 1
	end
	if not func then
		error("Invalid call to ch_core.register_player_globalstep()!")
	end
	custom_globalsteps[index] = func
	return index
end

local function globalstep(dtime)
	globstep_dtime_accumulated = globstep_dtime_accumulated + dtime
	ch_core.cas = globstep_dtime_accumulated
	local ch_core_cas = ch_core.cas
	local us_time = get_us_time()

	-- DEN: 5:30 .. 19:00
	local tod = get_timeofday()
	local byla_noc = last_timeofday < 0.2292 or last_timeofday > 0.791666
	local je_noc = tod < 0.2292 or tod > 0.791666
	if byla_noc and not je_noc then
		-- Ráno
		minetest.sound_play("birds", gain_1)
	elseif not byla_noc and je_noc then
		-- Noc
		minetest.sound_play("owl", gain_1)
	end
	last_timeofday = tod

	local process_ap = us_time - last_ap_timestamp >= ch_core.ap_interval * 1000000
	if process_ap then
		last_ap_timestamp = us_time
	end

	-- PRO KAŽDÉHO HRÁČE/KU:
	local connected_players = minetest.get_connected_players()
	for _, player in pairs(connected_players) do
		local player_name = player:get_player_name()
		local player_pos = player:get_pos()
		local online_charinfo = ch_core.online_charinfo[player_name]
		local offline_charinfo = ch_core.get_offline_charinfo(player_name)
		local disrupt_teleport_flag = false
		local disrupt_pryc_flag = false
		local player_wielded_item_name = player:get_wielded_item():get_name() or ""
		local player_root = get_root(player)

		if online_charinfo then
			local previous_wield_item_name = online_charinfo.wielded_item_name or ""
			online_charinfo.wielded_item_name = player_wielded_item_name

			-- ÚHEL HLAVY:
			local emote = emoting[player]
			if not emote or emote ~= "lehni" then
				local puvodni_uhel_hlavy = online_charinfo.uhel_hlavy or 0
				local novy_uhel_hlavy = player:get_look_vertical() - 0.01745329251994329577 * (online_charinfo.head_offset or 0)
				local rozdil = novy_uhel_hlavy - puvodni_uhel_hlavy
				if rozdil > 0.001 or rozdil < -0.001 then
					if rozdil > 0.3 then
						-- omezit pohyb hlavy
						novy_uhel_hlavy = puvodni_uhel_hlavy + 0.3
					elseif rozdil < -0.3 then
						novy_uhel_hlavy = puvodni_uhel_hlavy - 0.3
					end
					head_bone_angle.x = -0.5 * deg(puvodni_uhel_hlavy + novy_uhel_hlavy)
					player:set_bone_position(head_bone_name, head_bone_position, head_bone_angle)
					online_charinfo.uhel_hlavy = novy_uhel_hlavy
				end
			else
				head_bone_angle.x = 0
				player:set_bone_position(head_bone_name, head_bone_position, head_bone_angle)
			end

			-- REAGOVAT NA KLÁVESY:
			local old_control_bits = online_charinfo.klavesy_b or 0
			local new_control_bits = player:get_player_control_bits()
			if not (new_control_bits == old_control_bits) then
				local old_controls = online_charinfo.klavesy
				local new_controls = player:get_player_control()
				online_charinfo.klavesy = new_controls
				online_charinfo.klavesy_b = new_control_bits
				if not old_controls then
					--
				elseif new_controls.aux1 and not old_controls.aux1 then
					print(player_name.." pressed aux1")
					ch_core.show_player_list(player, online_charinfo)
					player:set_properties(stepheight_high)
				elseif not new_controls.aux1 and old_controls.aux1 then
					print(player_name.." leaved aux1")
					ch_core.hide_player_list(player, online_charinfo)
					player:set_properties(stepheight_low)
				end

				disrupt_pryc_flag = true
				if not disrupt_teleport_flag and (new_controls.up or new_controls.down or new_controls.left or new_controls.right or new_controls.jump or new_controls.dig or new_controls.place) then
					disrupt_teleport_flag = true
				end
			end

			-- VĚZENÍ:
			if ch_core.submods_loaded["vezeni"] and offline_charinfo.trest > 0 then
				local vezeni_data = ch_core.vezeni_data
				if not ch_core.pos_in_area(player_pos, vezeni_data.min, vezeni_data.max) then
					player:set_pos(vezeni_data.stred)
				elseif us_time >= (online_charinfo.pristi_kontrola_krumpace or 0) then
					online_charinfo.pristi_kontrola_krumpace = us_time + 900000000
					ch_core.vezeni_kontrola_krumpace(player)
				end
			end

			-- pokud se změnil držený předmět, možná bude potřeba zobrazit jeho nápovědu
			if player_wielded_item_name ~= previous_wield_item_name then
				disrupt_pryc_flag = true
				local help_def = ch_core.should_show_help(player, online_charinfo, player_wielded_item_name)
				if help_def then
					local zluta = minetest.get_color_escape_sequence("#ffff00")
					local zelena = minetest.get_color_escape_sequence("#00ff00")
					local s = zluta.."Nápověda k předmětu „"..zelena..(help_def.description or ""):gsub("\n", "\n  "..zelena)..zluta.."“:\n  "..zluta..(help_def._ch_help or ""):gsub("\n", "\n  "..zluta)
					ch_core.systemovy_kanal(player_name, s)
				end
			end

			-- ZRUŠIT /pryč:
			if disrupt_pryc_flag and online_charinfo.pryc then
				online_charinfo.pryc(player, online_charinfo)
			end

			-- ČASOVAČE
			local timers = online_charinfo.ch_timers
			if timers then
				for timer_id, timer_def in pairs(table.copy(timers)) do
					local remains = timer_def.run_at - ch_core_cas
					if remains <= 0.1 then
						local func_to_run = timer_def.func
						ch_core.cancel_ch_timer(online_charinfo, timer_id)
						if func_to_run then
							minetest.after(0.1, function()
								return func_to_run()
							end)
						end
					elseif timer_def.hudbar then
						remains = math.ceil(remains)
						if remains ~= timer_def.last_hud_value then
							hb.change_hudbar(player, timer_def.hudbar, remains)
							timer_def.last_hud_value = remains
						end
					end
				end
			end

			-- ZRUŠIT teleport
			local teleport_def = ch_core.get_ch_timer_info(online_charinfo, "teleportace")
			if teleport_def then
				if not disrupt_teleport_flag then
					local ts_pos = teleport_def.start_pos
					if ts_pos then
						disrupt_teleport_flag = abs(ts_pos.x - player_pos.x) > 0.5 or abs(ts_pos.z - player_pos.z) > 0.5
					end
				end
				if disrupt_teleport_flag then
					ch_core.cancel_ch_timer(online_charinfo, "teleportace")
					ch_core.systemovy_kanal(player_name, "Teleportace zrušena v důsledku akce hráče/ky nebo postavy.")
				end
			end

			-- ZRUŠIT horkou zprávu
			local horka_zprava = online_charinfo.horka_zprava
			if horka_zprava and ch_core_cas >= horka_zprava.timeout then
				online_charinfo.horka_zprava = nil
				player:set_nametag_attributes(ch_core.compute_player_nametag(online_charinfo, offline_charinfo))
			end

			-- nesmrtelnost (stačilo by spouštět občas)
			if minetest.is_creative_enabled(player_name) then
				if not online_charinfo.is_creative then
					online_charinfo.is_creative = true
					ch_core.set_immortal(player, online_charinfo.is_creative)
				end
			else
				if online_charinfo.is_creative then
					online_charinfo.is_creative = false
					ch_core.set_immortal(player, online_charinfo.is_creative)
				end
			end

			-- SPUSTIT registrované obslužné funkce
			local i = 1
			while custom_globalsteps[i] do
				custom_globalsteps[i](player, player_name, online_charinfo, offline_charinfo, us_time)
				i = i + 1
			end

			-- SLEDOVÁNÍ AKTIVITY
			local ap = online_charinfo.ap
			if ap then
				if player_pos.x ~= ap.pos.x then
					ap.pos_x_gen = ap.pos_x_gen + 1
				end
				if player_pos.y ~= ap.pos.y then
					ap.pos_y_gen = ap.pos_y_gen + 1
				end
				if player_pos.z ~= ap.pos.z then
					ap.pos_z_gen = ap.pos_z_gen + 1
				end
				ap.pos = player_pos

				local player_velocity = player_root:get_velocity()
				if player_velocity.x ~= ap.velocity.x then
					ap.velocity_x_gen = ap.velocity_x_gen + 1
				end
				if player_velocity.y ~= ap.velocity.y then
					ap.velocity_y_gen = ap.velocity_y_gen + 1
				end
				if player_velocity.z ~= ap.velocity.z then
					ap.velocity_z_gen = ap.velocity_z_gen + 1
				end
				ap.velocity = player_velocity

				local player_control_bits = player:get_player_control_bits()
				if player_control_bits ~= ap.control then
					ap.control = player_control_bits
					ap.control_gen = ap.control_gen + 1
				end

				local look_horizontal = player:get_look_horizontal()
				if look_horizontal ~= ap.look_h then
					ap.look_h = look_horizontal
					ap.look_h_gen = ap.look_h_gen + 1
				end
				local look_vertical = player:get_look_vertical()
				if look_vertical ~= ap.look_v then
					ap.look_v = look_vertical
					ap.look_v_gen = ap.look_v_gen + 1
				end

				for _, rezim in ipairs({"mistni", "celoserverovy", "sepot", "soukromy"}) do
					local last = ch_core["last_"..rezim]
					if last.char == player_name then
						ap["chat_"..rezim.."_gen"] = last.char_gen
					end
				end

				if process_ap then
					ch_core.ap_update(player, online_charinfo, offline_charinfo)
				end
			elseif process_ap then
				ch_core.ap_init(player, online_charinfo, offline_charinfo)
			end

			-- NASTAVIT OSVĚTLENÍ [data, nodes, wielded_light]
			-- - provést po proběhnutí registrovaných obslužných funkcí,
			--   protože ty mohly osvětlení změnit
			local light_slots = has_wielded_light and online_charinfo.wielded_lights
			if light_slots then
				local new_light_level = 0
				for _, light_level in pairs(light_slots) do
					if light_level > new_light_level then
						new_light_level = light_level
					end
				end
				if new_light_level ~= online_charinfo.light_level then
					minetest.log("info", "Light level of player "..player_name.." changed: "..online_charinfo.light_level.." to "..new_light_level)
					if new_light_level > 0 then
						wielded_light.track_user_entity(player, "ch_core", string.format("ch_core:light_%02d", new_light_level))
					else
						wielded_light.track_user_entity(player, "ch_core", "default:cobble")
					end
					online_charinfo.light_level = new_light_level
					online_charinfo.light_level_timestamp = us_time
				elseif new_light_level > 0 and us_time - online_charinfo.light_level_timestamp > 5000000 then
					-- refresh non-zero light level each 5 seconds
					wielded_light.track_user_entity(player, "ch_core", string.format("ch_core:light_%02d", new_light_level))
					online_charinfo.light_level_timestamp = us_time
				end
			end
		end
	end
end
minetest.register_globalstep(globalstep)

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
