print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local modpath = minetest.get_modpath("ch_core")
ch_core = {
	storage = minetest.get_mod_storage(),
	submods_loaded = {}, -- submod => true

	klavesy = {}, -- player_name => {sneak => true|false, aux1 => true|false, ...}
	uhel_hlavy = {}, -- player_name => posledni_uhel
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
dofile(modpath .. "/hud.lua") -- : data, lib
dofile(modpath .. "/joinplayer.lua") -- : data, lib
dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/padlock.lua") -- : data, lib
dofile(modpath .. "/sickles.lua")
dofile(modpath .. "/hotbar.lua")
dofile(modpath .. "/pryc.lua") -- : data, lib, chat, privs
dofile(modpath .. "/zacatek.lua") -- : privs

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
local uhel_hlavy = ch_core.uhel_hlavy
local emoting = (minetest.get_modpath("emote") and emote.emoting) or {}

local function globalstep(dtime)
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
		local online_charinfo = ch_core.online_charinfo[player_name]
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
			end

			-- ZRUŠIT /pryč:
			if disrupt_pryc_flag and online_charinfo.pryc then
				online_charinfo.pryc(player, online_charinfo)
			end
		end
	end
end
minetest.register_globalstep(globalstep)

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
