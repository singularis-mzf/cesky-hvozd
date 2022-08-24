ch_core.open_submod("pryc", {chat = true, data = true, lib = true, privs = true})

local disrupt_pryc = function(player, online_charinfo)
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
	-- announce
	ch_core.systemovy_kanal("", ch_core.prihlasovaci_na_zobrazovaci(player_name).." je zpět u počítače")
end
local def = {
	privs = {},
	description = "",
	func = function(player_name, param)
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
		cod.pryc = disrupt_pryc

		-- HUD
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

		-- set titul
		ch_core.set_temporary_titul(player_name, "pryč od počítače", true)

		-- announce
		ch_core.systemovy_kanal("", ch_core.prihlasovaci_na_zobrazovaci(player_name).." jde pryč od počítače")
	end
}
minetest.register_chatcommand("pop", def)
minetest.register_chatcommand("pryč", def)
minetest.register_chatcommand("pryc", def)

ch_core.close_submod("pryc")
