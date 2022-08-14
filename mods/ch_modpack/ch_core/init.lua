print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local modpath = minetest.get_modpath("ch_core")
ch_core = {
	storage = minetest.get_mod_storage(),
	submods_loaded = {}, -- submod => true

	vezeni_data = {
		min = vector.new(-1000, -1000, -1000),
		max = vector.new(1000, 1000, 1000),
		-- dvere = nil,
		stred = vector.new(0, 0, 0),
	},
}

function ch_core.require_submod(current_submod, wanted_submod)
	if ch_core.submods_loaded[wanted_submod] then
		return true
	end
	error("ch_core submodule '"..wanted_submod.."' is required to be loaded before '"..current_submod.."'!")
end
function ch_core.submod_loaded(current_submod)
	ch_core.submods_loaded[current_submod] = true
	return true
end

dofile(modpath .. "/privs.lua")
dofile(modpath .. "/data.lua")
dofile(modpath .. "/lib.lua") -- : data
dofile(modpath .. "/chat.lua") -- : data, lib, privs
dofile(modpath .. "/dennoc.lua") -- : privs, chat
dofile(modpath .. "/hud.lua") -- : data, lib
dofile(modpath .. "/joinplayer.lua") -- : data, lib
dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/padlock.lua") -- : data, lib
dofile(modpath .. "/vezeni.lua") -- : privs, data, lib, chat, hud
dofile(modpath .. "/sickles.lua")
dofile(modpath .. "/timers.lua") -- : data, chat, hud
dofile(modpath .. "/hotbar.lua")
dofile(modpath .. "/pryc.lua") -- : data, lib, chat, privs
dofile(modpath .. "/teleportace.lua") -- : data, lib, chat, privs, timers

-- KOHOUT: při přechodu mezi dnem a nocí přehraje zvuk
-- TODO: přehrávat, jen když je postava na povrchu (tzn. ne v hlubokém podzemí)

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

local function globalstep(dtime)
	globstep_dtime_accumulated = globstep_dtime_accumulated + dtime
	local os_clock = os.clock()

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

	-- PRO KAŽDÉHO HRÁČE/KU:
	local connected_players = minetest.get_connected_players()
	for _, player in pairs(connected_players) do
		local player_name = player:get_player_name()
		local player_pos = player:get_pos()
		local online_charinfo = ch_core.online_charinfo[player_name]
		local offline_charinfo = ch_core.get_offline_charinfo(player_name)
		local disrupt_teleport_flag = false
		local disrupt_pryc_flag = false

		if online_charinfo then
			-- ÚHEL HLAVY:
			local emote = emoting[player]
			if not emote or emote ~= "lehni" then
				local puvodni_uhel_hlavy = online_charinfo.uhel_hlavy or 0
				local novy_uhel_hlavy = player:get_look_vertical()
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
				elseif not new_controls.aux1 and old_controls.aux1 then
					print(player_name.." leaved aux1")
					ch_core.hide_player_list(player, online_charinfo)
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
				elseif (online_charinfo.pristi_kontrola_krumpace or 0.0) < globstep_dtime_accumulated then
					online_charinfo.pristi_kontrola_krumpace = (online_charinfo.pristi_kontrola_krumpace or 0.0) + 900.0
					ch_core.vezeni_kontrola_krumpace(player)
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
					local remains = timer_def.run_at - os_clock
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
		end
	end
end
minetest.register_globalstep(globalstep)

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
