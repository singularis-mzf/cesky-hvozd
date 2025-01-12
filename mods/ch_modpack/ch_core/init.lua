ch_base.open_mod(core.get_current_modname())

local modpath = core.get_modpath("ch_core")
ch_core = {
	storage = minetest.get_mod_storage(),
	submods_loaded = {}, -- submod => true

	ap_interval = 15, -- interval pro podmód „ap“
	cas = 0,
	gs_tasks = {},
	inventory_size = {
		normal = 32,
		extended = 64,
	},
	supported_lang_codes = {cs = true, sk = true},
	verze_ap = 1, -- aktuální verze podmódu „ap“
	vezeni_data = {
		min = vector.new(-1000, -1000, -1000),
		max = vector.new(1000, 1000, 1000),
		-- dvere = nil,
		stred = vector.new(0, 0, 0),
	},
	colors = {
		black = minetest.get_color_escape_sequence("#000000"),
		blue = minetest.get_color_escape_sequence("#0000AA"),
		green = minetest.get_color_escape_sequence("#00AA00"),
		cyan = minetest.get_color_escape_sequence("#00AAAA"),
		red = minetest.get_color_escape_sequence("#AA0000"),
		magenta = minetest.get_color_escape_sequence("#AA00AA"),
		brown = minetest.get_color_escape_sequence("#AA5500"),
		yellow = minetest.get_color_escape_sequence("#AAAA00"),
		light_gray = minetest.get_color_escape_sequence("#CCCCCC"),
		dark_gray = minetest.get_color_escape_sequence("#555555"),
		light_blue = minetest.get_color_escape_sequence("#5555FF"),
		light_green = minetest.get_color_escape_sequence("#55FF55"),
		light_cyan = minetest.get_color_escape_sequence("#55FFFF"),
		light_red = minetest.get_color_escape_sequence("#FF5555"),
		light_magenta = minetest.get_color_escape_sequence("#FF55FF"),
		light_yellow = minetest.get_color_escape_sequence("#FFFF55"),
		white = minetest.get_color_escape_sequence("#FFFFFF"),
	},
	overridable = {
		-- funkce a proměnné, které mohou být přepsány z ostatních módů
		reset_bank_account = function(player_name) return end,
		trash_all_sound = "", -- zvuk k přehrání při mazání více předmětů
		trash_one_sound = "", -- zvuk k přehrání při mazání jednoho předmětu
		chyba_handler = function(player, text) return end,
	},
}

ch_time.set_time_speed_during_day(26) -- was 24
ch_time.set_time_speed_during_night(132) -- was 48

local current_submod

function ch_core.open_submod(submod, required_submods)
	if current_submod ~= nil then
		error("[ch_core/"..current_submod.."] modul nebyl uzavřen!")
	end
	for s, c in pairs(required_submods or {}) do
		if c and not ch_core.submods_loaded[s] then
			error("ch_core submodule '"..s.."' is required to be loaded before '"..submod.."'!")
		end
	end
	current_submod = submod
	return true
end
function ch_core.close_submod(submod)
	if current_submod == nil then
		error("Vícenásobné volání ch_core.close_submod()!")
	elseif current_submod ~= submod then
		error("[ch_core/"..current_submod.."] modul chybně uzavřen jako "..submod.."!")
	end
	current_submod = nil
	ch_core.submods_loaded[submod] = true
	return true
end

dofile(modpath .. "/active_objects.lua")
dofile(modpath .. "/markers.lua")
dofile(modpath .. "/barvy_linek.lua")
dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/plaster.lua")
dofile(modpath .. "/hotbar.lua")
dofile(modpath .. "/vgroups.lua")
dofile(modpath .. "/data.lua")
dofile(modpath .. "/lib.lua") -- : data
dofile(modpath .. "/entity_register.lua") -- : lib
dofile(modpath .. "/interiors.lua") -- : lib
dofile(modpath .. "/shapes_db.lua") -- : lib
dofile(modpath .. "/penize.lua") -- : lib
dofile(modpath .. "/nodedir.lua") -- : lib
dofile(modpath .. "/formspecs.lua") -- : data, lib
dofile(modpath .. "/areas.lua") -- : data, lib
dofile(modpath .. "/nametag.lua") -- : data, lib
dofile(modpath .. "/privs.lua")
dofile(modpath .. "/clean_players.lua") -- : data, lib, privs
dofile(modpath .. "/localize_chatcommands.lua") -- : data, lib, privs
dofile(modpath .. "/udm.lua") -- : areas, data, lib
dofile(modpath .. "/chat.lua") -- : areas, data, lib, privs, nametag, udm
dofile(modpath .. "/shape_selector.lua") -- : chat, formspecs, lib
dofile(modpath .. "/events.lua") -- : chat, data, lib, privs
dofile(modpath .. "/stavby.lua") -- : chat, events, lib
-- dofile(modpath .. "/inv_inspector.lua") -- : data, formspecs, lib, chat
dofile(modpath .. "/podnebi.lua") -- : privs, chat
dofile(modpath .. "/dennoc.lua") -- : privs, chat
dofile(modpath .. "/hud.lua") -- : data, lib, chat
dofile(modpath .. "/ap.lua") -- : chat, data, events, hud, lib
dofile(modpath .. "/registrace.lua") -- : chat, data, events, lib, nametag
dofile(modpath .. "/pryc.lua") -- : data, lib, events, privs
dofile(modpath .. "/joinplayer.lua") -- : chat, data, formspecs, lib, nametag, pryc, events
dofile(modpath .. "/padlock.lua") -- : data, lib
dofile(modpath .. "/vezeni.lua") -- : privs, data, lib, chat, hud
dofile(modpath .. "/timers.lua") -- : data, chat, hud
dofile(modpath .. "/wielded_light.lua") -- : data, lib, nodes
dofile(modpath .. "/teleportace.lua") -- : data, lib, chat, privs, stavby, timers
dofile(modpath .. "/creative_inventory.lua") -- : lib
dofile(modpath .. "/kos.lua") -- : lib


local ifthenelse = assert(ch_core.ifthenelse)
local last_timeofday = 0 -- pravděpodobně se pokusí něco přehrát v prvním globalstepu,
-- ale to nevadí, protöže v tu chvíli stejně nemůže být ještě nikdo online.
local abs = math.abs
local get_timeofday = core.get_timeofday
local gain_1 = {gain = 1.0}
local head_bone_name = "Head"
local head_bone_override = {
	position = {vec = vector.new(0, 6.35, 0), absolute = true},
	rotation = {vec = vector.zero(), absolute = true},
}
local emoting = (core.get_modpath("emote") and emote.emoting) or {}
local globstep_dtime_accumulated = 0.0
local hud_dtime_accumulated = 0.0
local get_us_time = assert(core.get_us_time)
local has_wielded_light = core.get_modpath("wielded_light")
local custom_globalsteps = {}
local last_ap_timestamp = 0
local use_forbidden_height = ifthenelse(core.settings:get_bool("ch_forbidden_height", false), true, false)
local gs_task
local gs_task_next_step
local gs_handler = {
	cancel = "on_cancelled",
	finished = "on_finished",
	failed = "on_failed",
}

local stepheight_low = {stepheight = 0.3}
local stepheight_high = {stepheight = 1.1}

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
	if globstep_dtime_accumulated == 0 then
		-- první globalstep:
		ch_core.update_creative_inventory(true)
		globstep_dtime_accumulated = globstep_dtime_accumulated + dtime
		return
	end

	globstep_dtime_accumulated = globstep_dtime_accumulated + dtime
	ch_core.cas = globstep_dtime_accumulated
	local ch_core_cas = globstep_dtime_accumulated
	local us_time = get_us_time()

	-- DEN: 5:30 .. 19:00
	local tod = get_timeofday()
	local byla_noc = last_timeofday < 0.2292 or last_timeofday > 0.791666
	local je_noc = tod < 0.2292 or tod > 0.791666
	if byla_noc and not je_noc then
		-- Ráno
		minetest.sound_play("birds", gain_1)
		local new_speed = ch_time.get_time_speed_during_day()
		if new_speed ~= nil then
			core.settings:set("time_speed", tostring(new_speed))
		end
	elseif not byla_noc and je_noc then
		-- Noc
		core.sound_play("owl", gain_1)
		local new_speed = ch_time.get_time_speed_during_night()
		if new_speed ~= nil then
			core.settings:set("time_speed", tostring(new_speed))
		end
	end
	last_timeofday = tod

	local process_ap = us_time - last_ap_timestamp >= ch_core.ap_interval * 1000000
	if process_ap then
		last_ap_timestamp = us_time
	end

	hud_dtime_accumulated = hud_dtime_accumulated + dtime
	if hud_dtime_accumulated > 1 then
		hud_dtime_accumulated = 0
		ch_core.update_gametime_hudbar(nil, tod)
	end

	-- PRO KAŽDÉHO HRÁČE/KU:
	local connected_players = core.get_connected_players()
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
					head_bone_override.rotation.vec.x = -0.5 * (puvodni_uhel_hlavy + novy_uhel_hlavy)
					player:set_bone_override(head_bone_name, head_bone_override)
					online_charinfo.uhel_hlavy = novy_uhel_hlavy
				end
			else
				head_bone_override.rotation.vec.x = 0
				player:set_bone_override(head_bone_name, head_bone_override)
			end

			-- REAGOVAT NA KLÁVESY:
			local old_control_bits = online_charinfo.klavesy_b or 0
			local new_control_bits = player:get_player_control_bits()
			if new_control_bits ~= old_control_bits then
				local new_controls = player:get_player_control()
				local old_controls = online_charinfo.klavesy or new_controls
				online_charinfo.klavesy = new_controls
				online_charinfo.klavesy_b = new_control_bits
				if new_controls.aux1 and not old_controls.aux1 then
					ch_core.show_player_list(player, online_charinfo)
					player:set_properties(stepheight_high)
				elseif not new_controls.aux1 and old_controls.aux1 then
					ch_core.hide_player_list(player, online_charinfo)
					player:set_properties(stepheight_low)
				end

				disrupt_pryc_flag = true
				if not disrupt_teleport_flag and (new_controls.up or new_controls.down or new_controls.left or new_controls.right or new_controls.jump or new_controls.dig or new_controls.place) then
					disrupt_teleport_flag = true
				end
			end

			-- VĚZENÍ, zakázaná výška:
			if --[[ ch_core.submods_loaded["vezeni"] and ]] offline_charinfo.trest > 0 then
				ch_core.vykon_trestu(player, player_pos, us_time, online_charinfo)
			elseif use_forbidden_height and player_pos.y >= 1024 and player_pos.y <= 1256 then
				-- zakázaná výška
				minetest.log("warning", "Player "..player_name.." reached forbidden area at "..minetest.pos_to_string(player_pos).."!")
				minetest.after(0.1, function()
					ch_core.teleport_player({
						type = "admin",
						player = player,
						target_pos = ch_core.positions["zacatek_1"] or vector.zero(),
						sound_after = "chat3_bell",
					})
					ch_core.systemovy_kanal(player_name, "Dostali jste se do zakázaného výškového pásma! Pozice y >= 1024 jsou nepřístupné.")
				end)
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

				-- periskop:
				if online_charinfo.periskop ~= nil and player_wielded_item_name ~= "ch_extras:periskop" then
					online_charinfo.periskop.cancel()
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
					ch_core.cancel_teleport(player_name, true)
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

				local last
				last = ch_core.last_mistni
				if last.char == player_name then
					ap.chat_mistni_gen = last.char_gen
				end
				last = ch_core.last_celoserverovy
				if last.char == player_name then
					ap.chat_celoserverovy_gen = last.char_gen
				end
				last = ch_core.last_sepot
				if last.char == player_name then
					ap.chat_sepot_gen = last.char_gen
				end
				last = ch_core.last_soukromy
				if last.char == player_name then
					ap.chat_soukromy_gen = last.char_gen
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

	-- globalstep tasks:
	if gs_task ~= nil then
		-- run the step
		local context = gs_task.context
		local step = gs_task.steps[gs_task_next_step]
		local n_steps = #gs_task.steps
		local result = gs_task.on_step(context, step, gs_task_next_step, n_steps)
		local handler = gs_handler[result] -- if this crashes on nil, add 'or ""'
		if handler == nil then
			if gs_task_next_step < n_steps then
				-- příště pokračovat dalším krokem stejného úkolu
				gs_task_next_step = gs_task_next_step + 1
			else
				-- úkol dokončen
				handler = "on_finished"
			end
		end
		if handler ~= nil then
			-- zavolat obsluhu a skončit
			handler = gs_task[handler]
			if handler ~= nil then
				handler(context, gs_task_next_step, n_steps)
			end
			gs_task = nil
		end

	elseif ch_core.gs_tasks[1] ~= nil then
		-- vyzvednout další úkol a zavolat jeho on_start()
		gs_task = ch_core.gs_tasks[1]
		gs_task_next_step = 1
		table.remove(ch_core.gs_tasks, 1)
		if gs_task.on_start ~= nil then
			local result = gs_task.on_start(gs_task.context)
			local handler = gs_handler[result] -- if this crashes on nil, add 'or ""'
			if handler ~= nil then
				gs_task = nil
			end
		end
	end
end
core.register_globalstep(globalstep)

ch_base.close_mod(minetest.get_current_modname())
