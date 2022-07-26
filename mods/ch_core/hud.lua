ch_core.require_submod("hud", "data")
ch_core.require_submod("hud", "lib")

local base_y_offset = 90
local y_scale = 20

local text_hud_defaults = {
	hud_elem_type = "text",
	position = { x = 0.5, y = 0 },
	-- offset
	-- text
	alignment = { x = 1, y = 1 },
	scale = { x = 100, y = 100 },
	number = 0xFFFFFF,
}

function ch_core.show_player_list(player, online_charinfo)
	if online_charinfo.player_list_huds then
		return false
	end
	local huds, hud_defs, new_hud

	hud_defs = {}
	for c_player_name, c_online_charinfo in pairs(ch_core.online_charinfo) do
		local c_offline_charinfo = ch_core.offline_charinfo[c_player_name]
		local titul = c_offline_charinfo and c_offline_charinfo.titul
		local dtituly = c_online_charinfo.docasne_tituly or {}

		if not titul then
			if string.sub(c_player_name, -2) == "PP" then
				titul = "pomocná postava"
			elseif not minetest.check_player_privs(c_player_name, "ch_registered_player") then
				titul = "nová postava"
			end
		end

		new_hud = table.copy(text_hud_defaults)
		new_hud.offset = { x = 5, y = base_y_offset + 3 + #hud_defs * y_scale }
		new_hud.text = ch_core.prihlasovaci_na_zobrazovaci(c_player_name)
		if titul then
			new_hud.text = new_hud.text.." ["..titul.."]"
		end
		for dtitul, _ in pairs(dtituly) do
			new_hud.text = new_hud.text.." ["..dtitul.."]"
		end
		table.insert(hud_defs, new_hud)
	end
	new_hud = {
		hud_elem_type = "image",
		alignment = { x = -1, y = 1 },
		position = { x = 1, y = 0 },
		offset = { x = 0, y = base_y_offset },
		text = "ch_core_white_pixel.png^[multiply:#333333^[opacity:128",
		scale = { x = -50, y = #hud_defs * y_scale + 8 },
		number = text_hud_defaults.number,
	}
	huds = {
		player:hud_add(new_hud)
	}
	online_charinfo.player_list_huds = huds
	for i, hud_def in ipairs(hud_defs) do
		huds[i + 1] = player:hud_add(hud_def)
	end
	return true
end

function ch_core.hide_player_list(player, online_charinfo)
	if not online_charinfo.player_list_huds then
		return false
	end
	local huds = online_charinfo.player_list_huds
	online_charinfo.player_list_huds = nil
	for _, hud_id in ipairs(huds) do
		player:hud_remove(hud_id)
	end
	return true
end

ch_core.submod_loaded("hud")
