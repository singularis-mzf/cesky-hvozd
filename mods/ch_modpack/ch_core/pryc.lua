ch_core.open_submod("pryc", {chat = true, data = true, lib = true, privs = true})

local empty_table = {}

local disrupt_pryc_silent = function(player, online_charinfo)
	if not online_charinfo.pryc then
		return false
	end
	online_charinfo.pryc = nil

	local player_name = player:get_player_name()

	-- remove HUD
	local hud_id = online_charinfo.pryc_hud_id
	if hud_id then
		online_charinfo.pryc_hud_id = nil
		player:hud_remove(hud_id)
	end
	-- remove titul
	ch_core.set_temporary_titul(player_name, "pryč od počítače", false)

	return true
end

local disrupt_pryc = function(player, online_charinfo)
	if disrupt_pryc_silent(player, online_charinfo) then
		-- announce
		ch_core.systemovy_kanal("", ch_core.prihlasovaci_na_zobrazovaci(online_charinfo.player_name).." je zpět u počítače")
		return true
	else
		return false
	end
end

function ch_core.set_pryc(player_name, options)
	local cod = ch_core.online_charinfo[player_name]
	if not cod then
		minetest.log("error", "Internal error: missing online_charinfo for character '"..player_name.."'!")
		return false, "Interní chyba: chybí online_charinfo"
	end
	local player = minetest.get_player_by_name(player_name)
	if not player then
		minetest.log("error", "Internal error: missing player ref for character '"..player_name.."'!")
		return false, "Interní chyba: chybí PlayerRef"
	end
	if cod.pryc then
		minetest.log("warning", "Character '"..player_name.."' is already away from keyboard!")
		return false, "Interní chyba: postava již je pryč od počítače!"
	end

	if not options then
		options = empty_table
	end
	local no_hud, silently = options.no_hud, options.silently

	if silently then
		cod.pryc = disrupt_pryc_silent
	else
		cod.pryc = disrupt_pryc
	end

	-- HUD
	if not no_hud then
		local hud_def = {
			hud_elem_type = "image",
			-- text = "ch_core_white_pixel.png^[invert:rgb^[opacity:192",
			text = "ch_core_pryc.png",
			position = { x = 0, y = 0 },
			scale = { x = -100, y = -100 },
			alignment = { x = 1, y = 1 },
			offset = { x = 0, y = 0},
		}
		cod.pryc_hud_id = player:hud_add(hud_def)
	end

	-- set titul
	ch_core.set_temporary_titul(player_name, "pryč od počítače", true)

	-- announce
	if not silently then
		ch_core.systemovy_kanal("", ch_core.prihlasovaci_na_zobrazovaci(player_name).." jde pryč od počítače")
	end

	return true
end

local def = {
	privs = {},
	description = "",
	func = function(player_name, param)
		return ch_core.set_pryc(player_name, empty_table)
	end
}
minetest.register_chatcommand("pop", def)
minetest.register_chatcommand("pryč", def)
minetest.register_chatcommand("pryc", def)

ch_core.close_submod("pryc")
